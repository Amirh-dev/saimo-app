import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'active_chat_tracker.dart';

/// Android notification channel id. Must match the value declared in
/// AndroidManifest.xml (`default_notification_channel_id`) so FCM system
/// notifications and our local notifications land in the same channel.
/// Web Push certificate key pair (VAPID) from Firebase console →
/// Project settings → Cloud Messaging → Web configuration. Required for
/// [FirebaseMessaging.getToken] on web; ignored on mobile.
const String _webVapidKey = String.fromEnvironment(
  'FCM_VAPID_KEY',
  defaultValue:
      'BM6nWkj1zNeBH-YGBbzXE6wC3aWKIHyE9diHHmNp71KGTvgOXnAtsOWB3PeG4IR6FE88oThi5xU-s0pdEUwnEGo',
);

const String kMessagesChannelId = 'high_importance_channel';
const String _messagesChannelName = 'پیام‌ها';
const String _messagesChannelDescription =
    'اعلان دریافت پیام‌های جدید در گفتگوها';

/// All chat-message notifications share this group. Android bundles them under
/// a single expandable summary (Telegram-style): messages from different chats
/// stack under one header, while multiple messages from the *same* chat
/// accumulate inside that chat's own MessagingStyle notification.
const String kMessagesGroupKey = 'app.ravi.saimo.messages';

/// Fixed id for the group summary notification that heads the bundle. A large
/// constant that won't collide with per-conversation ids (those are masked to
/// 31 bits from a hash code).
const int _summaryNotificationId = 2147483646;

/// Most recent messages kept per conversation. Android only renders a handful
/// in the expanded view; capping keeps the accumulated payload bounded.
const int _maxMessagesPerConversation = 8;

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
  // The channel usually already exists (created by the main isolate on a prior
  // run), but recreate it here so a data-only push in a cold isolate still
  // lands in a high-importance channel.
  await plugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(_messagesChannel());

  await _showGroupedMessageNotification(
    plugin,
    title: title,
    body: body,
    conversationKey: _conversationKeyFromData(data),
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

  bool _hasPendingOpenChat = false;
  String? _pendingOpenChatSenderID;

  /// Records a notification-tap intent that can't be handled immediately,
  /// e.g. tapped from a terminated state before the UI mounted, or before the
  /// user is authenticated. The app consumes it once it can navigate.
  void setPendingOpenChat(String? senderID) {
    _hasPendingOpenChat = true;
    _pendingOpenChatSenderID = senderID;
  }

  /// If a tap intent is pending, hands its sender id to [onOpen] and clears it.
  /// Returns whether anything was consumed.
  bool consumePendingOpenChat(void Function(String? senderID) onOpen) {
    if (!_hasPendingOpenChat) return false;
    final senderID = _pendingOpenChatSenderID;
    _hasPendingOpenChat = false;
    _pendingOpenChatSenderID = null;
    onOpen(senderID);
    return true;
  }

  /// Invoked with the FCM token on first fetch and on every refresh. The app
  /// wires this (in `_LiveInboxConnector`) to the `registerDeviceToken`
  /// mutation, which stores the token against the current user so the server
  /// can target this device. Registration is a no-op until authenticated.
  Future<void> Function(String token)? onToken;

  /// Full setup. Call once, after `Firebase.initializeApp()` and before
  /// `runApp`. Safe to call again; subsequent calls are ignored.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    // flutter_local_notifications has no web support; on web the service
    // worker (firebase-messaging-sw.js) renders notifications instead.
    if (!kIsWeb) {
      await _initLocalNotifications();
    }
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
        ?.createNotificationChannel(_messagesChannel());

    final launchDetails =
        await _localNotifications.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      final response = launchDetails?.notificationResponse;
      if (response != null) {
        _onNotificationResponse(response);
      } else {
        _dispatchOpenChat(null);
      }
    }
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
      final token = kIsWeb
          ? await _messaging.getToken(vapidKey: _webVapidKey)
          : await _messaging.getToken();
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
      title: title,
      body: body,
      senderID: senderID,
      chatID: data[_payloadChatIDKey]?.toString(),
    );
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    _dispatchOpenChat(message.data[_payloadSenderIDKey]?.toString());
  }

  void _onNotificationResponse(NotificationResponse response) {
    _dispatchOpenChat(_senderIDFromPayload(response.payload));
  }

  void _dispatchOpenChat(String? senderID) {
    final handler = onOpenChat;
    if (handler != null) {
      handler(senderID);
      return;
    }

    // Cold launch from a terminated state: the UI isn't ready to navigate yet,
    // so stash the intent for the app to consume once it mounts.
    setPendingOpenChat(senderID);
  }

  String? _senderIDFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      return null;
    }
    try {
      final data = jsonDecode(payload);
      return data is Map ? data[_payloadSenderIDKey]?.toString() : null;
    } catch (_) {
      return null;
    }
  }

  /// Displays a local notification for a new chat message. Used by both the
  /// FCM foreground handler and the live WebSocket inbox stream.
  ///
  /// Messages from the same conversation accumulate into a single expandable
  /// notification; messages from different conversations bundle under a shared
  /// group summary. The conversation identity is derived from [senderID] (or
  /// [chatID], falling back to [title]).
  Future<void> showMessageNotification({
    required String title,
    required String body,
    String? senderID,
    String? chatID,
  }) async {
    // No local-notification plugin on web; the browser/service worker handles
    // display there.
    if (kIsWeb) return;
    final payload = jsonEncode({
      if (senderID != null) _payloadSenderIDKey: senderID,
      if (chatID != null) _payloadChatIDKey: chatID,
    });
    await _showGroupedMessageNotification(
      _localNotifications,
      title: title,
      body: body,
      conversationKey: _conversationKey(senderID, chatID, title),
      payload: payload,
    );
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[Notifications] $message');
  }
}

/// Shows a chat-message notification with Telegram-style grouping.
///
/// On Android: appends the message to the conversation's [MessagingStyleInformation]
/// (read back from the currently-shown notification so earlier messages are
/// preserved), tags it with [kMessagesGroupKey], and refreshes the bundle
/// summary. On other platforms: posts a unique notification threaded by
/// conversation so the OS stacks a chat's messages natively.
Future<void> _showGroupedMessageNotification(
  FlutterLocalNotificationsPlugin plugin, {
  required String title,
  required String body,
  required String conversationKey,
  required String payload,
}) async {
  if (defaultTargetPlatform != TargetPlatform.android) {
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch & 0x7fffffff,
      title,
      body,
      NotificationDetails(
        iOS: DarwinNotificationDetails(threadIdentifier: conversationKey),
      ),
      payload: payload,
    );
    return;
  }

  final android = plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  if (android == null) return;

  final conversationId = conversationKey.hashCode & 0x7fffffff;

  // Read back the messages already shown for this conversation (Android 6+) so
  // the new message is appended rather than replacing them.
  final existing =
      await android.getActiveNotificationMessagingStyle(conversationId);
  final sender = Person(key: conversationKey, name: title, important: true);
  final messages = <Message>[
    ...?existing?.messages,
    Message(body, DateTime.now(), sender),
  ];
  if (messages.length > _maxMessagesPerConversation) {
    messages.removeRange(0, messages.length - _maxMessagesPerConversation);
  }

  await plugin.show(
    conversationId,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        kMessagesChannelId,
        _messagesChannelName,
        channelDescription: _messagesChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        // Monochrome status-bar icon (Android renders it as a white silhouette).
        icon: '@drawable/ic_stat_notification',
        // Full-color app logo shown inside the notification body.
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        groupKey: kMessagesGroupKey,
        number: messages.length,
        styleInformation: MessagingStyleInformation(
          _me,
          groupConversation: false,
          messages: messages,
        ),
      ),
    ),
    payload: payload,
  );

  await _updateMessagesGroupSummary(plugin, android);
}

/// Rebuilds the bundle summary that heads every chat notification, listing one
/// line per active conversation and a total count. Android shows it when the
/// bundle is collapsed and on versions that don't auto-generate a summary.
Future<void> _updateMessagesGroupSummary(
  FlutterLocalNotificationsPlugin plugin,
  AndroidFlutterLocalNotificationsPlugin android,
) async {
  final active = await plugin.getActiveNotifications();
  final conversations = active
      .where((n) =>
          n.groupKey == kMessagesGroupKey && n.id != _summaryNotificationId)
      .toList();
  if (conversations.isEmpty) return;

  final lines = <String>[];
  var totalMessages = 0;
  for (final n in conversations) {
    final style = n.id == null
        ? null
        : await android.getActiveNotificationMessagingStyle(n.id!);
    final msgs = style?.messages;
    totalMessages += (msgs == null || msgs.isEmpty) ? 1 : msgs.length;
    final name = (msgs != null && msgs.isNotEmpty)
        ? (msgs.last.person?.name ?? n.title ?? '')
        : (n.title ?? '');
    final text =
        (msgs != null && msgs.isNotEmpty) ? msgs.last.text : (n.body ?? '');
    lines.add('$name: $text');
  }

  final summaryText = conversations.length > 1
      ? '${_fa(totalMessages)} پیام از ${_fa(conversations.length)} گفتگو'
      : '${_fa(totalMessages)} پیام جدید';

  await plugin.show(
    _summaryNotificationId,
    _messagesChannelName,
    summaryText,
    NotificationDetails(
      android: AndroidNotificationDetails(
        kMessagesChannelId,
        _messagesChannelName,
        channelDescription: _messagesChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/ic_stat_notification',
        groupKey: kMessagesGroupKey,
        setAsGroupSummary: true,
        // Let the individual messages make the sound; the summary stays quiet.
        onlyAlertOnce: true,
        groupAlertBehavior: GroupAlertBehavior.children,
        styleInformation: InboxStyleInformation(
          lines,
          contentTitle: summaryText,
          summaryText: _messagesChannelName,
        ),
      ),
    ),
  );
}

/// The device owner, shown for MessagingStyle notifications as the "you" side.
const Person _me = Person(name: 'شما');

AndroidNotificationChannel _messagesChannel() =>
    const AndroidNotificationChannel(
      kMessagesChannelId,
      _messagesChannelName,
      description: _messagesChannelDescription,
      importance: Importance.high,
    );

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

/// Stable per-conversation key: prefer the sender, then the chat, then the
/// display name so notifications from one conversation always collide (and thus
/// accumulate) while different conversations stay distinct.
String _conversationKey(String? senderID, String? chatID, String title) {
  final key = senderID ?? chatID;
  if (key != null && key.isNotEmpty) return key;
  return title.isNotEmpty ? title : 'unknown';
}

String _conversationKeyFromData(Map<String, dynamic> data) {
  return _conversationKey(
    data[_payloadSenderIDKey]?.toString(),
    data[_payloadChatIDKey]?.toString(),
    _titleFromData(data),
  );
}

/// Converts Western digits to Persian for notification copy.
String _fa(int n) {
  const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  var s = n.toString();
  for (var i = 0; i < western.length; i++) {
    s = s.replaceAll(western[i], persian[i]);
  }
  return s;
}
