import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'active_chat_tracker.dart';

/// Android notification channel id. Must match the value declared in
/// AndroidManifest.xml (`default_notification_channel_id`) so FCM system
/// notifications and our local notifications land in the same channel.
const String kMessagesChannelId = 'high_importance_channel';
const String _messagesChannelName = 'پیام‌ها';
const String _messagesChannelDescription =
    'اعلان دریافت پیام‌های جدید در گفتگوها';

/// Payload keys used to route a notification tap to the right conversation.
const String _payloadSenderIDKey = 'senderID';
const String _payloadChatIDKey = 'chatID';

/// Background/terminated FCM handler. Must be a top-level function annotated
/// with `@pragma('vm:entry-point')` because it runs in its own isolate.
///
/// For messages that carry a `notification` block, the OS already displays the
/// system notification, so we do nothing. For data-only messages we surface a
/// local notification ourselves.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.notification != null) return;

  final data = message.data;
  final title = _titleFromData(data);
  final body = _bodyFromData(data);
  if (body == null) return;

  final plugin = FlutterLocalNotificationsPlugin();
  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const darwinInit = DarwinInitializationSettings();
  await plugin.initialize(
    const InitializationSettings(android: androidInit, iOS: darwinInit),
  );
  await plugin.show(
    _notificationIdFor(data),
    title,
    body,
    _messageNotificationDetails(),
    payload: jsonEncode(data),
  );
}

/// Owns all notification concerns: local notification display plus the Firebase
/// Cloud Messaging lifecycle (permissions, token, foreground/background/tap
/// handling). A single instance is created in `main` and shared app-wide.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  bool _initialized = false;

  /// The current FCM registration token, exposed for UI (e.g. a copyable tile
  /// used to test pushes from the Firebase console). Updates when the token is
  /// first fetched and on every refresh.
  final ValueNotifier<String?> tokenNotifier = ValueNotifier<String?>(null);
  String? get currentToken => tokenNotifier.value;

  /// Called when the user taps a notification. The app wires this to navigate
  /// to the chat. Receives the sender's user id when known.
  void Function(String? senderID)? onOpenChat;

  /// Invoked with the FCM token on first fetch and on every refresh. The app
  /// should wire this to a backend mutation that stores the token against the
  /// current user so the server can target this device.
  ///
  /// TODO(backend): the GraphQL schema currently has no device-registration
  /// mutation. Once it exists, set this to send [token] to the server.
  Future<void> Function(String token)? onToken;

  /// Full setup. Call once, after `Firebase.initializeApp()` and before
  /// `runApp`. Safe to call again — subsequent calls are ignored.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _initLocalNotifications();
    await _requestPermissions();
    await _configureFcm();
  }

  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwinInit = DarwinInitializationSettings(
      // Permission requests are handled explicitly in [_requestPermissions].
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _localNotifications.initialize(
      const InitializationSettings(android: androidInit, iOS: darwinInit),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create the Android channel up front so its importance is correct.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        kMessagesChannelId,
        _messagesChannelName,
        description: _messagesChannelDescription,
        importance: Importance.high,
      ),
    );
  }

  Future<void> _requestPermissions() async {
    // Android 13+ runtime notification permission.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // iOS / FCM permission prompt.
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _configureFcm() async {
    // Foreground presentation is handled by us via local notifications, so keep
    // the OS from also showing its own banner on iOS (avoids duplicates).
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // App launched from a terminated state by tapping a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }

    _messaging.onTokenRefresh.listen(_publishToken);
    try {
      final token = await _messaging.getToken();
      if (token != null) await _publishToken(token);
    } catch (error) {
      _log('getToken failed: ${error.runtimeType}');
    }
  }

  Future<void> _publishToken(String token) async {
    _log('FCM token: $token');
    tokenNotifier.value = token;
    final sender = onToken;
    if (sender == null) return;
    try {
      await sender(token);
    } catch (error) {
      _log('token registration failed: ${error.runtimeType}');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final senderID = data[_payloadSenderIDKey]?.toString();
    if (senderID != null &&
        !ActiveChatTracker.instance.shouldNotifyForMessageFrom(senderID)) {
      return;
    }

    final notification = message.notification;
    final title = notification?.title ?? _titleFromData(data);
    final body = notification?.body ?? _bodyFromData(data);
    if (body == null) return;

    showMessageNotification(
      id: _notificationIdFor(data),
      title: title,
      body: body,
      senderID: senderID,
      chatID: data[_payloadChatIDKey]?.toString(),
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    onOpenChat?.call(message.data[_payloadSenderIDKey]?.toString());
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) {
      onOpenChat?.call(null);
      return;
    }
    try {
      final data = jsonDecode(payload);
      final senderID =
          data is Map ? data[_payloadSenderIDKey]?.toString() : null;
      onOpenChat?.call(senderID);
    } catch (_) {
      onOpenChat?.call(null);
    }
  }

  /// Displays a local notification for a new chat message. Used by both the
  /// FCM foreground handler and the live WebSocket inbox stream.
  Future<void> showMessageNotification({
    required String title,
    required String body,
    int? id,
    String? senderID,
    String? chatID,
  }) async {
    final payload = jsonEncode({
      if (senderID != null) _payloadSenderIDKey: senderID,
      if (chatID != null) _payloadChatIDKey: chatID,
    });
    await _localNotifications.show(
      id ??
          ((senderID?.hashCode ?? DateTime.now().millisecondsSinceEpoch) &
              0x7fffffff),
      title,
      body,
      _messageNotificationDetails(),
      payload: payload,
    );
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[Notifications] $message');
  }
}

NotificationDetails _messageNotificationDetails() {
  return const NotificationDetails(
    android: AndroidNotificationDetails(
      kMessagesChannelId,
      _messagesChannelName,
      channelDescription: _messagesChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      // Monochrome status-bar icon (Android renders it as a white silhouette).
      icon: '@drawable/ic_stat_notification',
      // Full-color app logo shown inside the notification body.
      largeIcon: DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
    ),
    iOS: DarwinNotificationDetails(),
  );
}

String _titleFromData(Map<String, dynamic> data) {
  final title = data['title']?.toString();
  if (title != null && title.trim().isNotEmpty) return title;
  return 'پیام جدید';
}

String? _bodyFromData(Map<String, dynamic> data) {
  final body = (data['body'] ?? data['content'] ?? data['message'])?.toString();
  if (body == null || body.trim().isEmpty) return null;
  return body;
}

int _notificationIdFor(Map<String, dynamic> data) {
  final key = (data[_payloadSenderIDKey] ?? data[_payloadChatIDKey])?.toString();
  if (key == null || key.isEmpty) {
    return DateTime.now().millisecondsSinceEpoch & 0x7fffffff;
  }
  return key.hashCode & 0x7fffffff;
}
