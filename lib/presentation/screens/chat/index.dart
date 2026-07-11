// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

import 'chat_message_store.dart';
import 'chat_models.dart';
import 'chat_repository.dart';
import 'inbox_subscription_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  late final ChatRepository _chatRepository;
  late final InboxSubscriptionClient _inboxClient;
  StreamSubscription<InboxEvent>? _eventSubscription;
  StreamSubscription<InboxConnectionStatus>? _statusSubscription;
  var _contacts = <ChatContact>[];
  final _activityByUserID = <String, UserActivity>{};
  final _latestMessageByUserID = <String, ChatMessage>{};
  final _unreadByUserID = <String, int>{};
  final _chatUserByChatID = <String, String>{};
  var _connectionStatus = InboxConnectionStatus.idle;
  var _displayConnectionStatus = InboxConnectionStatus.connected;
  Timer? _connectionDebounce;
  late final ScrollController _contactsController;
  Future<void>? _contactsLoadFuture;
  String? _currentUserID;
  String? _activeChatUserID;
  String? _error;
  bool _isLoading = true;
  bool _isLoadingMoreContacts = false;
  bool _hasMoreContacts = true;
  String? _openingUserID;

  static const int _contactsPageSize = 20;
  static const Duration _connectionGrace = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatRepository = ChatRepository(context.read<GraphQLRepository>());
    _inboxClient = context.read<InboxSubscriptionClient>();
    _connectionStatus = _inboxClient.currentStatus;
    _contactsController = ScrollController()
      ..addListener(_handleContactsScroll);
    _startInboxSubscription();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContacts());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSubscription?.cancel();
    _statusSubscription?.cancel();
    _connectionDebounce?.cancel();
    _contactsController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _inboxClient.connect(source: 'chat_list');
    _loadContacts(silent: true);
  }

  void _handleContactsScroll() {
    if (!_contactsController.hasClients) return;
    final position = _contactsController.position;
    if (position.pixels >= position.maxScrollExtent - 160) {
      _loadMoreContacts();
    }
  }

  void _startInboxSubscription() {
    _eventSubscription = _inboxClient.events.listen(_handleInboxEvent);
    _statusSubscription = _inboxClient.status.listen((status) {
      if (!mounted) return;
      _applyConnectionStatus(status);
    });
    _applyConnectionStatus(_inboxClient.currentStatus);
    _inboxClient.connect(source: 'chat_list');
  }

  /// Surfaces a disconnection only after it persists past a short grace period,
  /// so transient reconnects never flash "در حال اتصال" in the list.
  void _applyConnectionStatus(InboxConnectionStatus status) {
    _connectionStatus = status;

    if (status == InboxConnectionStatus.connected) {
      _connectionDebounce?.cancel();
      if (_displayConnectionStatus != status) {
        setState(() => _displayConnectionStatus = status);
      }
      return;
    }

    if (_displayConnectionStatus == InboxConnectionStatus.connected) {
      _connectionDebounce?.cancel();
      _connectionDebounce = Timer(_connectionGrace, () {
        if (!mounted) return;
        if (_connectionStatus != InboxConnectionStatus.connected) {
          setState(() => _displayConnectionStatus = _connectionStatus);
        }
      });
    } else if (_displayConnectionStatus != status) {
      setState(() => _displayConnectionStatus = status);
    }
  }

  Future<void> _loadContacts({bool silent = false}) {
    final activeLoad = _contactsLoadFuture;
    if (activeLoad != null) return activeLoad;

    late final Future<void> loadFuture;
    loadFuture = _loadContactsOnce(silent: silent).whenComplete(() {
      if (identical(_contactsLoadFuture, loadFuture)) {
        _contactsLoadFuture = null;
      }
    });
    _contactsLoadFuture = loadFuture;
    return loadFuture;
  }

  Future<void> _loadContactsOnce({required bool silent}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // The current user id never changes during a session, so fetch `getMe`
      // once instead of on every (including silent/resume) refresh.
      final currentUserID =
          _currentUserID ?? await _chatRepository.getCurrentUserID();
      final contacts = await _chatRepository.getFriends(
        currentUserID,
        limit: _contactsPageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _currentUserID = currentUserID;
        _contacts = contacts;
        _hasMoreContacts = contacts.length == _contactsPageSize;
        _isLoadingMoreContacts = false;
        final contactIDs =
            contacts.map((contact) => contact.targetUserID).toSet();
        _latestMessageByUserID.removeWhere(
          (userID, _) => !contactIDs.contains(userID),
        );
        _unreadByUserID.removeWhere(
          (userID, _) => !contactIDs.contains(userID),
        );
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (silent) return;
      setState(() {
        _error = _friendlyError(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreContacts() async {
    final currentUserID = _currentUserID;
    if (currentUserID == null ||
        _isLoading ||
        _isLoadingMoreContacts ||
        !_hasMoreContacts) {
      return;
    }
    setState(() => _isLoadingMoreContacts = true);

    try {
      final more = await _chatRepository.getFriends(
        currentUserID,
        limit: _contactsPageSize,
        offset: _contacts.length,
      );
      if (!mounted) return;
      setState(() {
        final existingIDs =
            _contacts.map((contact) => contact.targetUserID).toSet();
        final fresh = more.where(
          (contact) => existingIDs.add(contact.targetUserID),
        );
        _contacts = [..._contacts, ...fresh];
        _hasMoreContacts = more.length == _contactsPageSize;
        _isLoadingMoreContacts = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMoreContacts = false);
    }
  }

  void _handleInboxEvent(InboxEvent event) {
    if (!mounted) return;

    if (event is UserActivityInboxEvent) {
      if (event.userID.isEmpty) return;
      setState(() {
        _activityByUserID[event.userID] = UserActivity(
          isOnline: event.isOnline,
          currentTaskName: event.currentTaskName,
        );
      });
      return;
    }

    if (event is NewMessageInboxEvent) {
      final contactUserID = _contactUserIDForMessage(event.message);
      if (contactUserID == null) return;
      final currentUserID = _currentUserID;
      setState(() {
        _latestMessageByUserID[contactUserID] = event.message;
        if (event.message.senderID != currentUserID) {
          if (contactUserID == _activeChatUserID) {
            _unreadByUserID.remove(contactUserID);
          } else {
            _unreadByUserID[contactUserID] =
                (_unreadByUserID[contactUserID] ?? 0) + 1;
          }
        }
      });
      return;
    }

    if (event is MessageSeenInboxEvent) {
      _handleMessageSeenEvent(event);
      return;
    }

    if (event is MessageDeletedInboxEvent) {
      final contactUserID = _chatUserByChatID[event.chatID];
      if (contactUserID == null) return;
      final latestMessage = _latestMessageByUserID[contactUserID];
      if (latestMessage?.id != event.messageID) return;
      setState(() {
        _latestMessageByUserID[contactUserID] = latestMessage!.copyWith(
          isDeleted: true,
          content: '',
        );
      });
    }
  }

  void _handleMessageSeenEvent(MessageSeenInboxEvent event) {
    final currentUserID = _currentUserID;
    if (currentUserID == null || event.userID != currentUserID) return;
    final contactUserID = _contactUserIDForChatID(event.chatID);
    if (contactUserID == null) return;

    setState(() {
      _unreadByUserID.remove(contactUserID);
    });
  }

  String? _contactUserIDForChatID(String chatID) {
    final mappedUserID = _chatUserByChatID[chatID];
    if (mappedUserID != null) return mappedUserID;

    for (final entry in _latestMessageByUserID.entries) {
      if (entry.value.chatID == chatID) {
        _chatUserByChatID[chatID] = entry.key;
        return entry.key;
      }
    }

    return null;
  }

  String? _contactUserIDForMessage(ChatMessage message) {
    final currentUserID = _currentUserID;
    final mappedUserID = _chatUserByChatID[message.chatID];
    if (mappedUserID != null) return mappedUserID;

    if (currentUserID != null && message.senderID != currentUserID) {
      final hasContact = _contacts.any(
        (contact) => contact.targetUserID == message.senderID,
      );
      if (hasContact) {
        _chatUserByChatID[message.chatID] = message.senderID;
        return message.senderID;
      }
    }

    return null;
  }

  Future<void> _openChat(ChatContact contact) async {
    if (contact.isPending || _openingUserID != null) return;

    setState(() {
      _openingUserID = contact.targetUserID;
      _activeChatUserID = contact.targetUserID;
      _unreadByUserID.remove(contact.targetUserID);
    });
    try {
      final chatID = await _chatRepository.createDirectChat(
        contact.targetUserID,
      );
      if (!mounted) return;
      setState(() {
        _chatUserByChatID[chatID] = contact.targetUserID;
      });
      await context.to(
        ChatRoomScreen(
          chatID: chatID,
          currentUserID: _currentUserID,
          targetUserID: contact.targetUserID,
          title: contact.displayName,
        ),
      );
      if (mounted) {
        setState(() {
          _openingUserID = null;
          _activeChatUserID = null;
          _unreadByUserID.remove(contact.targetUserID);
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _openingUserID = null;
        _activeChatUserID = null;
      });
      showReToast(context, _friendlyError(error), ReToastType.failed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        body: SafeArea(
          child: Column(
            children: [
              _ChatListHeader(onRefresh: _loadContacts),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return _ChatStateView(
        icon: SolarIconsOutline.dangerTriangle,
        title: 'اتصال برقرار نشد',
        subtitle: _error!,
        actionText: 'تلاش دوباره',
        onAction: _loadContacts,
      );
    }

    if (_contacts.isEmpty) {
      return _ChatStateView(
        icon: SolarIconsOutline.chatRound,
        title: 'هنوز گفتگویی ندارید',
        subtitle:
            'بعد از اضافه شدن دوستان، گفتگوهای مستقیم از اینجا شروع می‌شوند.',
        actionText: 'بروزرسانی',
        onAction: _loadContacts,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadContacts,
      child: ListView.separated(
        controller: _contactsController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 32),
        itemCount: _contacts.length + (_isLoadingMoreContacts ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index >= _contacts.length) {
            return const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }
          final contact = _contacts[index];
          return _ContactTile(
            contact: contact,
            activity: _activityByUserID[contact.targetUserID],
            latestMessage: _latestMessageByUserID[contact.targetUserID],
            unreadCount: _unreadByUserID[contact.targetUserID] ?? 0,
            connectionStatus: _displayConnectionStatus,
            isOpening: _openingUserID == contact.targetUserID,
            onTap: () => _openChat(contact),
          );
        },
      ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.chatID,
    this.currentUserID,
    this.targetUserID,
    this.title,
  });

  final String chatID;
  final String? currentUserID;
  final String? targetUserID;
  final String? title;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen>
    with WidgetsBindingObserver {
  static const int _pageSize = 30;

  late final ChatRepository _chatRepository;
  late final InboxSubscriptionClient _inboxClient;
  late final ScrollController _scrollController;
  late final TextEditingController _messageController;
  StreamSubscription<InboxEvent>? _eventSubscription;
  StreamSubscription<InboxConnectionStatus>? _statusSubscription;
  StreamSubscription<ChatMessageBatch>? _initialMessagesSubscription;

  var _messages = <ChatMessage>[];
  var _activityByUserID = <String, UserActivity>{};
  var _connectionStatus = InboxConnectionStatus.idle;
  // What the UI actually shows. Stays optimistic ("connected") until a real
  // disconnection persists, so routine/transient reconnects never flash the
  // "در حال اتصال" message.
  var _displayConnectionStatus = InboxConnectionStatus.connected;
  Timer? _connectionDebounce;
  Timer? _targetViewingChatTimer;
  ChatMessage? _replyingTo;
  String? _selectedMessageID;
  String? _currentUserID;
  String? _error;
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingOlder = false;
  bool _isSyncingLatest = false;
  bool _isTargetViewingChat = false;
  bool _hasMore = true;
  bool _isSending = false;
  String? _outgoingSeenReadAt;
  Future<void>? _markReadFuture;
  bool _markReadAgain = false;

  static const Duration _connectionGrace = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _chatRepository = ChatRepository(context.read<GraphQLRepository>());
    _inboxClient = context.read<InboxSubscriptionClient>();
    _connectionStatus = _inboxClient.currentStatus;
    _scrollController = ScrollController()..addListener(_handleScroll);
    _messageController = TextEditingController();
    _currentUserID = widget.currentUserID;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInboxSubscription();
      _loadInitial();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _logChatLive('room listener disposed chatID=${widget.chatID}');
    _eventSubscription?.cancel();
    _statusSubscription?.cancel();
    _initialMessagesSubscription?.cancel();
    _connectionDebounce?.cancel();
    _targetViewingChatTimer?.cancel();
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  /// Applies a raw connection status with a grace period before surfacing a
  /// disconnection to the user, and triggers a resync when the link recovers.
  void _applyConnectionStatus(InboxConnectionStatus status) {
    final wasConnected = _connectionStatus == InboxConnectionStatus.connected;
    _connectionStatus = status;

    if (status == InboxConnectionStatus.connected) {
      _connectionDebounce?.cancel();
      if (_displayConnectionStatus != status) {
        setState(() => _displayConnectionStatus = status);
      }
      if (!wasConnected) _syncLatestMessages();
      return;
    }

    if (_displayConnectionStatus == InboxConnectionStatus.connected) {
      // Was healthy: wait out the grace period before showing a warning.
      _connectionDebounce?.cancel();
      _connectionDebounce = Timer(_connectionGrace, () {
        if (!mounted) return;
        if (_connectionStatus != InboxConnectionStatus.connected) {
          setState(() => _displayConnectionStatus = _connectionStatus);
        }
      });
    } else if (_displayConnectionStatus != status) {
      // Already showing an issue: keep the detail in sync immediately.
      setState(() => _displayConnectionStatus = status);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // The app-level connector forces one socket reconnect on resume. Its next
    // connected status triggers the single NetworkOnly catch-up below.
    _inboxClient.connect(source: 'chat_room');
    _markChatRead(source: 'resume');
  }

  Future<void> _loadInitial() async {
    await _initialMessagesSubscription?.cancel();
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userID = _currentUserID ?? await _chatRepository.getCurrentUserID();
      if (!mounted) return;
      _currentUserID = userID;
      _initialMessagesSubscription = _chatRepository
          .getInitialChatMessages(
            chatID: widget.chatID,
            limit: _pageSize,
            offset: 0,
          )
          .listen(
            _applyInitialMessageBatch,
            onError: _handleInitialMessageError,
          );
    } catch (error) {
      _handleInitialMessageError(error);
    }
  }

  void _applyInitialMessageBatch(ChatMessageBatch batch) {
    if (!mounted) return;
    final initialLoad = applyInitialMessagesToRoom(
      messages: _messages,
      fetchedMessages: batch.messages,
      pageSize: _pageSize,
    );
    setState(() {
      _messages = _applyOutgoingSeenWatermark(initialLoad.messages);
      _offset = initialLoad.offset;
      _hasMore = initialLoad.hasMore;
      _error = null;
      _isLoading = false;
    });
    _markChatRead(source: 'initial_load');
    _scrollToBottomSoon();
  }

  void _handleInitialMessageError(Object error, [StackTrace? _]) {
    if (!mounted) return;
    setState(() {
      if (_messages.isEmpty) {
        _error = _friendlyError(error);
      }
      _isLoading = false;
    });
  }

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder || !_hasMore || _isLoading) return;
    setState(() => _isLoadingOlder = true);

    try {
      final olderMessages = await _chatRepository.getChatMessagesFromNetwork(
        chatID: widget.chatID,
        limit: _pageSize,
        offset: _offset,
      );
      if (!mounted) return;
      setState(() {
        _messages = _applyOutgoingSeenWatermark(
          upsertMessages(_messages, olderMessages),
        );
        _offset += olderMessages.length;
        _hasMore = olderMessages.length == _pageSize;
        _isLoadingOlder = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoadingOlder = false);
      showReToast(context, _friendlyError(error), ReToastType.failed);
    }
  }

  void _startInboxSubscription() {
    _logChatLive('room listener started chatID=${widget.chatID}');
    _eventSubscription = _inboxClient.events.listen((event) {
      if (!mounted) return;
      _chatRepository.applyInboxEventToCache(
        event,
        limit: _pageSize,
        cachedPageOffsets: _cachedPageOffsets,
      );

      if (event case NewMessageInboxEvent(:final message)) {
        _logChatLive(
          'event received typename=NewMessageEvent '
          'eventChatID=${message.chatID} currentChatID=${widget.chatID}',
        );
        if (message.chatID != widget.chatID) {
          _logChatLive('ignored event for other chat');
          return;
        }
        if (message.senderID != _currentUserID) {
          _markTargetViewingChat();
        }

        final matchingLocal = findMatchingPendingLocalMessage(
          _messages,
          message,
        );
        final alreadyExists = _messages.any(
          (existingMessage) => existingMessage.id == message.id,
        );
        final beforeCount = _messages.length;
        _logChatLive(
          'applying NewMessageEvent messageId=${message.id} '
          'senderID=${message.senderID}',
        );
        _logChatLive('before count=$beforeCount');
        final shouldScroll = _isNearBottom;
        final result = applyInboxEventToRoom(
          messages: _messages,
          activityByUserID: _activityByUserID,
          event: event,
          chatID: widget.chatID,
        );
        final nextMessages = _applyOutgoingSeenWatermark(result.messages);
        setState(() {
          _messages = nextMessages;
          _activityByUserID = result.activityByUserID;
        });
        _logChatLive('after count=${nextMessages.length}');
        _logChatLive('setState called');
        if (matchingLocal != null) {
          _logChatLive(
            'replaced optimistic localId=${matchingLocal.id} '
            'serverId=${message.id}',
          );
        } else if (alreadyExists) {
          _logChatLive('duplicate serverId=${message.id} updated');
        } else {
          _logChatLive('inserted messageId=${message.id}');
        }
        if (message.senderID != _currentUserID) {
          _markChatRead(source: 'incoming_message');
        }
        if (shouldScroll) _scrollToBottomSoon();
        return;
      }

      if (event
          case MessageSeenInboxEvent(
            chatID: final eventChatID,
            :final userID,
            :final readAt,
          )) {
        _logChatLive(
          'MessageSeenEvent eventChatID=$eventChatID '
          'currentChatID=${widget.chatID} userID=$userID readAt=$readAt',
        );
        if (eventChatID != widget.chatID) {
          _logChatLive('ignored MessageSeenEvent for other chat');
          return;
        }
        if (userID == widget.targetUserID) {
          _markTargetViewingChat();
        }

        final currentUserID = _currentUserID;
        if (currentUserID == null || currentUserID.isEmpty) {
          _logChatLive(
            'no matching message for MessageSeenEvent '
            'reason=missing_current_user userID=$userID readAt=$readAt',
          );
          return;
        }
        final beforeMessages = _messages;
        final nextReadAt = _latestReadAt(_outgoingSeenReadAt, readAt);
        final nextMessages = markMessagesSeenForSender(
          _messages,
          chatID: widget.chatID,
          senderID: currentUserID,
          readAt: nextReadAt,
        );
        final updatedSeenMessageIDs = _updatedSeenMessageIDs(
          beforeMessages,
          nextMessages,
        );
        setState(() {
          _outgoingSeenReadAt = nextReadAt;
          _messages = nextMessages;
        });
        if (updatedSeenMessageIDs.isEmpty) {
          _logChatLive(
            'no matching message for MessageSeenEvent '
            'userID=$userID readAt=$readAt storedReadAt=$nextReadAt',
          );
        } else {
          for (final messageID in updatedSeenMessageIDs) {
            _logChatLive('updated seen messageId=$messageID');
          }
        }
        return;
      }

      final result = applyInboxEventToRoom(
        messages: _messages,
        activityByUserID: _activityByUserID,
        event: event,
        chatID: widget.chatID,
      );
      setState(() {
        _messages = result.messages;
        _activityByUserID = result.activityByUserID;
      });
    });
    _statusSubscription = _inboxClient.status.listen((status) {
      if (!mounted) return;
      _applyConnectionStatus(status);
    });
    _applyConnectionStatus(_inboxClient.currentStatus);
    _inboxClient.connect(source: 'chat_room');
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 120) {
      _loadOlderMessages();
    }
  }

  Future<void> _sendMessage({ChatMessage? retryMessage}) async {
    final userID = _currentUserID;
    final rawContent = retryMessage?.content ?? _messageController.text;
    final content = rawContent.trim();
    if (userID == null || content.isEmpty || _isSending) return;

    final localID =
        retryMessage?.id ?? 'local-${DateTime.now().microsecondsSinceEpoch}';
    final composingReply = _replyingTo;
    final replyToID = retryMessage?.replyToID ?? composingReply?.id;
    final replyPreview = retryMessage?.replyTo ??
        (composingReply == null
            ? null
            : ChatReplyMessage(
                id: composingReply.id,
                content: composingReply.content,
                senderID: composingReply.senderID,
                createdAt: composingReply.createdAt,
              ));
    final localMessage = retryMessage ??
        ChatMessage(
          id: localID,
          content: content,
          type: 'TEXT',
          chatID: widget.chatID,
          senderID: userID,
          replyToID: replyToID,
          isDeleted: false,
          createdAt: DateTime.now().toUtc().toIso8601String(),
          updatedAt: DateTime.now().toUtc().toIso8601String(),
          replyTo: replyPreview,
          sender: ChatUser(id: userID),
          isSending: true,
        );

    setState(() {
      _isSending = true;
      _messages = upsertMessages(removeLocalMessage(_messages, localID), [
        localMessage.copyWith(isSending: true, isFailed: false),
      ]);
      if (retryMessage == null) {
        _messageController.clear();
        _replyingTo = null;
      }
    });
    _scrollToBottomSoon();

    try {
      final sentMessage = await _chatRepository.sendMessage(
        chatID: widget.chatID,
        content: content,
        replyToID: replyToID,
      );
      if (!mounted) return;
      setState(() {
        _messages = _applyOutgoingSeenWatermark(replaceLocalMessage(
          _messages,
          localID: localID,
          serverMessage: sentMessage,
        ));
        _isSending = false;
      });
      _scrollToBottomSoon();
    } catch (error) {
      if (!mounted) return;
      if (_isCommittedTransactionError(error)) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (!mounted) return;
        final isStillPending = _messages.any(
          (message) => message.id == localID && message.isSending,
        );
        setState(() {
          if (isStillPending) {
            _messages = markMessageFailed(_messages, localID);
          }
          _isSending = false;
        });
        if (isStillPending) {
          showReToast(
            context,
            'تأیید ارسال پیام دریافت نشد.',
            ReToastType.failed,
          );
        }
        return;
      }
      setState(() {
        _messages = markMessageFailed(_messages, localID);
        _isSending = false;
      });
      showReToast(context, _friendlyError(error), ReToastType.failed);
    }
  }

  Future<void> _syncLatestMessages() async {
    if (_isLoading || _isSyncingLatest) return;
    _isSyncingLatest = true;
    final shouldScroll = _isNearBottom;
    try {
      final latestMessages = await _chatRepository.getChatMessagesFromNetwork(
        chatID: widget.chatID,
        limit: _pageSize,
        offset: 0,
      );
      if (!mounted) return;
      setState(() {
        _messages = _applyOutgoingSeenWatermark(
          upsertMessages(_messages, latestMessages),
        );
        _offset = math.max(_offset, latestMessages.length);
        _hasMore = latestMessages.length == _pageSize || _hasMore;
      });
      if (shouldScroll) _scrollToBottomSoon();
    } catch (_) {
      // The foreground subscription will retry separately; this sync is best effort.
    } finally {
      _isSyncingLatest = false;
    }
  }

  Iterable<int> get _cachedPageOffsets sync* {
    yield 0;
    for (var offset = _pageSize; offset < _offset; offset += _pageSize) {
      yield offset;
    }
  }

  List<ChatMessage> _applyOutgoingSeenWatermark(
    List<ChatMessage> messages,
  ) {
    final currentUserID = _currentUserID;
    final readAt = _outgoingSeenReadAt;
    if (currentUserID == null || currentUserID.isEmpty || readAt == null) {
      return messages;
    }
    return markMessagesSeenForSender(
      messages,
      chatID: widget.chatID,
      senderID: currentUserID,
      readAt: readAt,
    );
  }

  void _markTargetViewingChat() {
    if (widget.targetUserID == null || widget.targetUserID!.isEmpty) return;
    _targetViewingChatTimer?.cancel();
    if (!_isTargetViewingChat) {
      setState(() => _isTargetViewingChat = true);
    }
    _targetViewingChatTimer = Timer(const Duration(seconds: 45), () {
      if (!mounted) return;
      setState(() => _isTargetViewingChat = false);
    });
  }

  void _markChatRead({required String source}) {
    if (!mounted || _currentUserID == null) return;
    if (_markReadFuture != null) {
      _markReadAgain = true;
      _logChatLive('markChatRead queued source=$source');
      return;
    }

    _logChatLive('markChatRead started source=$source chatID=${widget.chatID}');
    late final Future<void> future;
    future = _chatRepository.markChatRead(chatID: widget.chatID).then((readAt) {
      _logChatLive('markChatRead completed source=$source readAt=$readAt');
    }).catchError((Object error) {
      _logChatLive(
        'markChatRead failed source=$source '
        'error=${error.runtimeType}',
      );
    }).whenComplete(() {
      if (_markReadFuture == future) {
        _markReadFuture = null;
      }
      if (!mounted || !_markReadAgain) return;
      _markReadAgain = false;
      _markChatRead(source: 'queued');
    });
    _markReadFuture = future;
  }

  Future<void> _deleteMessage(ChatMessage message) async {
    try {
      final deletedMessage = await _chatRepository.deleteMessage(message.id);
      if (!mounted) return;
      setState(() {
        _messages = upsertMessages(_messages, [deletedMessage]);
      });
    } catch (error) {
      if (!mounted) return;
      showReToast(context, _friendlyError(error), ReToastType.failed);
    }
  }

  Future<void> _confirmDeleteMessage(ChatMessage message) async {
    final shouldDelete = await showReModalBottomSheet<bool>(
      context: context,
      builder: (context) => _DeleteMessageSheet(message: message),
    );
    if (shouldDelete == true) {
      await _deleteMessage(message);
    }
  }

  Future<void> _copyMessage(ChatMessage message) async {
    if (message.isDeleted) return;

    await Clipboard.setData(ClipboardData(text: message.content));
    if (!mounted) return;
    showReToast(context, 'پیام کپی شد', ReToastType.success);
  }

  void _openMessageActions(ChatMessage message, Offset globalPosition) {
    if (message.isDeleted) return;

    setState(() => _selectedMessageID = message.id);
    unawaited(showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.black.withOpacity(0.06),
      transitionDuration: const Duration(milliseconds: 120),
      pageBuilder: (dialogContext, _, __) => _MessageActionsDialog(
        anchor: globalPosition,
        canDelete: message.senderID == _currentUserID && !message.isLocal,
        canRetry: message.isFailed,
        onReply: () {
          Navigator.of(dialogContext).pop();
          setState(() => _replyingTo = message);
        },
        onCopy: () {
          Navigator.of(dialogContext).pop();
          _copyMessage(message);
        },
        onDelete: () {
          Navigator.of(dialogContext).pop();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _confirmDeleteMessage(message);
          });
        },
        onRetry: () {
          Navigator.of(dialogContext).pop();
          _sendMessage(retryMessage: message);
        },
      ),
    ).whenComplete(() {
      if (mounted && _selectedMessageID == message.id) {
        setState(() => _selectedMessageID = null);
      }
    }));
  }

  void _openRoomMenu() {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.black.withOpacity(0.04),
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (dialogContext, _, __) => _RoomOverflowDialog(
        onViewProfile: () {
          Navigator.of(dialogContext).pop();
          _showUnsupportedRoomAction();
        },
        onClearConversation: () {
          Navigator.of(dialogContext).pop();
          _showUnsupportedRoomAction();
        },
        onDeleteChat: () {
          Navigator.of(dialogContext).pop();
          _showUnsupportedRoomAction();
        },
      ),
    );
  }

  void _showUnsupportedRoomAction() {
    showReToast(
      context,
      'این عملیات هنوز از سمت سرور پشتیبانی نمی‌شود',
      ReToastType.warning,
    );
  }

  void _sendWelcomeGreeting() {
    if (_isSending) return;
    const greeting = 'سلام چطوری؟ 👋';
    _messageController
      ..text = greeting
      ..selection = const TextSelection.collapsed(offset: greeting.length);
    _sendMessage();
  }

  void _showUnsupportedAttachmentAction() {
    showReToast(
      context,
      'ارسال فایل هنوز پشتیبانی نمی‌شود',
      ReToastType.info,
    );
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    return _scrollController.position.pixels < 120;
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final targetActivity = widget.targetUserID == null
        ? null
        : _activityByUserID[widget.targetUserID!];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _ChatPatternBackground()),
              Column(
                children: [
                  _ChatRoomHeader(
                    title: widget.title ?? 'گفتگو',
                    subtitle: _roomSubtitle(
                      targetActivity,
                      isTargetViewingChat: _isTargetViewingChat,
                    ),
                    isOnline: _isTargetViewingChat,
                    onBack: () => Navigator.of(context).pop(),
                    onMenu: _openRoomMenu,
                    connectionStatus: _displayConnectionStatus,
                  ),
                  Expanded(child: _buildMessagesBody()),
                  _MessageComposer(
                    controller: _messageController,
                    replyingTo: _replyingTo,
                    onCancelReply: () => setState(() => _replyingTo = null),
                    onSend: _sendMessage,
                    onAttachment: _showUnsupportedAttachmentAction,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return _ChatStateView(
        icon: SolarIconsOutline.dangerTriangle,
        title: 'پیام‌ها دریافت نشد',
        subtitle: _error!,
        actionText: 'تلاش دوباره',
        onAction: _loadInitial,
      );
    }

    if (_messages.isEmpty) {
      return _EmptyChatWelcome(
        onGreetingTap: _sendWelcomeGreeting,
      );
    }

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 18, 0, 18),
      itemCount: _messages.length + (_isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingOlder && index == _messages.length) {
          return const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final messageIndex = _messages.length - index - 1;
        final message = _messages[messageIndex];
        return _MessageBubble(
          message: message,
          isMine: message.senderID == _currentUserID,
          isSelected: message.id == _selectedMessageID,
          onReply: () => setState(() => _replyingTo = message),
          onLongPress: (position) => _openMessageActions(message, position),
        );
      },
    );
  }

  String _roomSubtitle(
    UserActivity? activity, {
    required bool isTargetViewingChat,
  }) {
    if (_displayConnectionStatus == InboxConnectionStatus.connecting ||
        _displayConnectionStatus == InboxConnectionStatus.reconnecting) {
      return 'در حال اتصال...';
    }
    if (_displayConnectionStatus == InboxConnectionStatus.error ||
        _displayConnectionStatus == InboxConnectionStatus.disconnected) {
      return 'اتصال زنده قطع است';
    }
    if (isTargetViewingChat) return 'آنلاین';
    final taskName = activity?.currentTaskName?.trim();
    if (taskName != null && taskName.isNotEmpty) {
      return 'درحال انجام $taskName';
    }
    return 'گفتگوی مستقیم';
  }
}

class _ChatListHeader extends StatelessWidget {
  const _ChatListHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Row(
        children: [
          _CircleIconButton(icon: SolarIconsOutline.refresh, onTap: onRefresh),
          const Spacer(),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ReText(
                'پیام‌ها',
                color: AppColors.black1,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              ReText(
                'گفتگو با دوستان',
                color: AppColors.gray,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.activity,
    required this.latestMessage,
    required this.unreadCount,
    required this.connectionStatus,
    required this.isOpening,
    required this.onTap,
  });

  final ChatContact contact;
  final UserActivity? activity;
  final ChatMessage? latestMessage;
  final int unreadCount;
  final InboxConnectionStatus connectionStatus;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = _contactSubtitle(
      contact,
      activity,
      connectionStatus,
      latestMessage,
    );
    final subtitleColor = _contactSubtitleColor(
      contact,
      activity,
      latestMessage,
      unreadCount,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: isOpening
                  ? const CircularProgressIndicator.adaptive()
                  : unreadCount > 0
                      ? _UnreadBadge(count: unreadCount)
                      : Icon(
                          contact.isPending
                              ? SolarIconsOutline.clockCircle
                              : SolarIconsBold.chatRound,
                          color: contact.isPending
                              ? AppColors.simoCoin
                              : AppColors.primary,
                          size: 22,
                        ),
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  contact.displayName,
                  color: AppColors.black1,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                if (contact.hasFullName && contact.usernameLabel != null)
                  ReText(
                    contact.usernameLabel!,
                    color: AppColors.black1.withOpacity(0.5),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    isPersian: false,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                  ).tMargin(1),
                SizedBox(
                  width: 180,
                  child: ReText(
                    subtitle,
                    color: subtitleColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ).tMargin(2),
              ],
            ).rMargin(10),
            const _ChatAvatar(),
          ],
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';

    return Center(
      child: Container(
        constraints: const BoxConstraints(minWidth: 24),
        height: 24,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 7),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.20),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ReText(
          label,
          color: AppColors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          isPersian: false,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _contactSubtitle(
  ChatContact contact,
  UserActivity? activity,
  InboxConnectionStatus connectionStatus,
  ChatMessage? latestMessage,
) {
  if (contact.isPending) return contact.subtitle;

  if (latestMessage != null) {
    if (latestMessage.isDeleted) return 'پیام حذف شد';
    final content = latestMessage.content.trim();
    if (content.isNotEmpty) return content;
    return 'پیام جدید';
  }

  final taskName = activity?.currentTaskName?.trim();
  if (taskName != null && taskName.isNotEmpty) {
    return 'درحال انجام $taskName';
  }

  if (connectionStatus == InboxConnectionStatus.connecting ||
      connectionStatus == InboxConnectionStatus.reconnecting) {
    return 'در حال اتصال زنده...';
  }

  return contact.subtitle;
}

Color _contactSubtitleColor(
  ChatContact contact,
  UserActivity? activity,
  ChatMessage? latestMessage,
  int unreadCount,
) {
  if (contact.isPending) return AppColors.simoCoin;
  if (unreadCount > 0) return AppColors.black1;
  if (latestMessage != null) return AppColors.gray;
  if (activity?.currentTaskName?.trim().isNotEmpty == true) {
    return AppColors.secondary;
  }
  return AppColors.gray;
}

class _ChatRoomHeader extends StatelessWidget {
  const _ChatRoomHeader({
    required this.title,
    required this.subtitle,
    required this.isOnline,
    required this.onBack,
    required this.onMenu,
    required this.connectionStatus,
  });

  final String title;
  final String subtitle;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback onMenu;
  final InboxConnectionStatus connectionStatus;

  @override
  Widget build(BuildContext context) {
    final hasConnectionWarning =
        connectionStatus == InboxConnectionStatus.reconnecting ||
            connectionStatus == InboxConnectionStatus.error ||
            connectionStatus == InboxConnectionStatus.disconnected;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            textDirection: TextDirection.ltr,
            children: [
              _CircleIconButton(
                icon: SolarIconsOutline.menuDots,
                onTap: onMenu,
                iconColor: AppColors.black1.withOpacity(0.78),
                backgroundColor: Colors.transparent,
                showShadow: false,
                size: 38,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  textDirection: TextDirection.ltr,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          ReText(
                            title,
                            color: AppColors.black1,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            maxLines: 1,
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReText(
                                subtitle,
                                color: hasConnectionWarning
                                    ? AppColors.simoCoin
                                    : isOnline
                                        ? AppColors.done
                                        : AppColors.gray,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(width: 5),
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOnline
                                      ? AppColors.done
                                      : AppColors.gray2,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 9),
                    const _ChatAvatar(size: 46),
                    const SizedBox(width: 3),
                    _CircleIconButton(
                      icon: SolarIconsOutline.altArrowRight,
                      onTap: onBack,
                      iconColor: AppColors.black1.withOpacity(0.72),
                      backgroundColor: Colors.transparent,
                      showShadow: false,
                      size: 36,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasConnectionWarning)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.simoCoin.withOpacity(0.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const ReText(
                'پیام‌های جدید پس از اتصال دوباره همگام می‌شوند',
                color: AppColors.simoCoin,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyChatWelcome extends StatelessWidget {
  const _EmptyChatWelcome({required this.onGreetingTap});

  final VoidCallback onGreetingTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = math.min(
          constraints.maxWidth * 0.68,
          math.min(290.0, constraints.maxHeight * 0.50),
        );
        final verticalShift = math.min(28.0, constraints.maxHeight * 0.04);

        return Center(
          child: Transform.translate(
            offset: Offset(0, -verticalShift),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    image: true,
                    label: 'تصویر خوش‌آمدگویی شروع گفتگو',
                    child: ReImage(
                      'assets/images/empty_chat_welcome.png',
                      width: imageSize,
                      height: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const ReText(
                    'سلام کنید!',
                    color: AppColors.black1,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Semantics(
                    button: true,
                    label: 'ارسال پیام سلام چطوری',
                    child: GestureDetector(
                      key: const ValueKey('empty-chat-greeting'),
                      onTap: onGreetingTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 22,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.035),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const ReText(
                          '👋 سلام چطوری؟',
                          color: AppColors.black1,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MessageBubble extends StatefulWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.isSelected,
    required this.onReply,
    required this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final bool isSelected;
  final VoidCallback onReply;
  final ValueChanged<Offset> onLongPress;

  @override
  State<_MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<_MessageBubble> {
  static const double _replySwipeThreshold = 58;
  static const double _replySwipeMaxOffset = 86;

  double _dragOffset = 0;
  bool _replyArmed = false;

  bool get _canSwipeReply => !widget.message.isDeleted;

  @override
  void didUpdateWidget(covariant _MessageBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message.id != widget.message.id) {
      _dragOffset = 0;
      _replyArmed = false;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_canSwipeReply) return;
    final nextOffset =
        (_dragOffset + details.delta.dx).clamp(-_replySwipeMaxOffset, 0.0);
    final isArmed = nextOffset.abs() >= _replySwipeThreshold;
    if (nextOffset == _dragOffset && isArmed == _replyArmed) return;
    setState(() {
      _dragOffset = nextOffset.toDouble();
      _replyArmed = isArmed;
    });
  }

  void _handleDragEnd([DragEndDetails? _]) {
    final shouldReply = _canSwipeReply && _replyArmed;
    setState(() {
      _dragOffset = 0;
      _replyArmed = false;
    });
    if (!shouldReply) return;
    HapticFeedback.selectionClick();
    widget.onReply();
  }

  void _handleDragCancel() {
    if (_dragOffset == 0 && !_replyArmed) return;
    setState(() {
      _dragOffset = 0;
      _replyArmed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isMine = widget.isMine;
    final isSelected = widget.isSelected;
    final replyProgress =
        (_dragOffset.abs() / _replySwipeThreshold).clamp(0.0, 1.0);
    final bubbleColor = message.isFailed
        ? const Color(0xFFF9F9FC)
        : isMine
            ? const Color(0xFFEFF2FF)
            : AppColors.white;

    return GestureDetector(
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      onHorizontalDragCancel: _handleDragCancel,
      onLongPressStart: (details) => widget.onLongPress(details.globalPosition),
      onSecondaryTapDown: (details) =>
          widget.onLongPress(details.globalPosition),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        color: isSelected
            ? AppColors.secondary.withOpacity(0.10)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 3),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_canSwipeReply && replyProgress > 0)
              Positioned(
                right: 24,
                child: Opacity(
                  opacity: replyProgress,
                  child: Transform.scale(
                    scale: 0.74 + replyProgress * 0.26,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color:
                            _replyArmed ? AppColors.secondary : AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.18),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        SolarIconsOutline.reply,
                        size: 18,
                        color:
                            _replyArmed ? AppColors.white : AppColors.secondary,
                      ),
                    ),
                  ),
                ),
              ),
            Transform.translate(
              offset: Offset(_dragOffset, 0),
              child: Padding(
                padding: EdgeInsets.only(
                  right: isSelected && isMine ? 38 : 0,
                  left: isSelected && !isMine ? 38 : 0,
                ),
                child: Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: math.min(
                        MediaQuery.of(context).size.width * 0.72,
                        430,
                      ),
                    ),
                    child: PhysicalShape(
                      clipper: _MessageBubbleClipper(isMine: isMine),
                      clipBehavior: Clip.antiAlias,
                      color: bubbleColor,
                      shadowColor: AppColors.black.withOpacity(0.10),
                      elevation: 1,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          isMine ? 12 : 18,
                          11,
                          isMine ? 18 : 12,
                          9,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (message.replyTo != null && !message.isDeleted)
                              _InlineReplyPreview(
                                reply: message.replyTo!,
                                isMine: isMine,
                              ).bMargin(7),
                            ReText(
                              message.isDeleted
                                  ? 'این پیام حذف شده است'
                                  : message.content,
                              color: message.isDeleted
                                  ? AppColors.gray
                                  : AppColors.black1.withOpacity(0.94),
                              fontSize: 13.5,
                              fontWeight: message.isDeleted
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              lineHeight: 1.55,
                              maxLines: 20,
                              overflow: TextOverflow.fade,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (message.isFailed)
                                  const Icon(
                                    SolarIconsOutline.dangerTriangle,
                                    color: AppColors.errorColor,
                                    size: 15,
                                  ).lMargin(4)
                                else if (message.isSending)
                                  SizedBox(
                                    width: 11,
                                    height: 11,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 1.5,
                                      color: AppColors.black1.withOpacity(0.45),
                                    ),
                                  ).lMargin(4)
                                else if (isMine)
                                  Icon(
                                    message.seenAt == null
                                        ? Icons.done_rounded
                                        : Icons.done_all_rounded,
                                    color: message.seenAt == null
                                        ? AppColors.secondary
                                        : AppColors.done,
                                    size: 16,
                                  ).lMargin(4),
                                ReText(
                                  _formatMessageTime(message.createdAt),
                                  color: AppColors.black1.withOpacity(0.40),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ).tMargin(5),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (isSelected)
              Align(
                alignment:
                    isMine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.16),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.secondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubbleClipper extends CustomClipper<Path> {
  const _MessageBubbleClipper({required this.isMine});

  final bool isMine;

  @override
  Path getClip(Size size) {
    const tailWidth = 9.0;
    final bubbleRect = Rect.fromLTRB(
      isMine ? 0 : tailWidth,
      0,
      isMine ? size.width - tailWidth : size.width,
      size.height,
    );
    final path = Path()
      ..addRRect(
          RRect.fromRectAndRadius(bubbleRect, const Radius.circular(20)));

    final tailTop = size.height - 33;
    final tailBottom = size.height - 17;
    if (isMine) {
      path
        ..moveTo(size.width - tailWidth - 2, tailTop)
        ..quadraticBezierTo(size.width - 2, tailTop + 6, size.width, tailBottom)
        ..lineTo(size.width - tailWidth - 3, tailBottom - 2)
        ..close();
    } else {
      path
        ..moveTo(tailWidth + 2, tailTop)
        ..quadraticBezierTo(2, tailTop + 6, 0, tailBottom)
        ..lineTo(tailWidth + 3, tailBottom - 2)
        ..close();
    }
    return path;
  }

  @override
  bool shouldReclip(covariant _MessageBubbleClipper oldClipper) {
    return oldClipper.isMine != isMine;
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.controller,
    required this.replyingTo,
    required this.onCancelReply,
    required this.onSend,
    required this.onAttachment,
  });

  final TextEditingController controller;
  final ChatMessage? replyingTo;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;
  final VoidCallback onAttachment;

  @override
  State<_MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<_MessageComposer> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(covariant _MessageComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleTextChanged);
      widget.controller.addListener(_handleTextChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChanged);
    super.dispose();
  }

  void _handleTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText == _hasText) return;
    setState(() => _hasText = hasText);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.replyingTo != null)
              _ComposerReplyPreview(
                message: widget.replyingTo!,
                onCancel: widget.onCancelReply,
              ).bMargin(8),
            Row(
              children: [
                GestureDetector(
                  onTap: _hasText ? widget.onSend : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.26),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.near_me_rounded,
                      color: AppColors.white,
                      size: 23,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    decoration: BoxDecoration(
                      color: AppColors.gray1,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: TextField(
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.newline,
                      keyboardType: TextInputType.multiline,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontFamily: AppFonts.iranSansVar,
                        fontSize: 12.5,
                        fontVariations: [FontVariation.weight(600)],
                        color: AppColors.black1,
                      ),
                      decoration: InputDecoration(
                        hintText: 'پیام...',
                        hintStyle: TextStyle(
                          fontFamily: AppFonts.iranSansVar,
                          fontSize: 12,
                          color: AppColors.black1.withOpacity(0.36),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  key: const ValueKey('chat-attachment-button'),
                  onTap: widget.onAttachment,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gray2),
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: AppColors.black1,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageActionsDialog extends StatelessWidget {
  const _MessageActionsDialog({
    required this.anchor,
    required this.canDelete,
    required this.canRetry,
    required this.onReply,
    required this.onCopy,
    required this.onDelete,
    required this.onRetry,
  });

  final Offset anchor;
  final bool canDelete;
  final bool canRetry;
  final VoidCallback onReply;
  final VoidCallback onCopy;
  final VoidCallback onDelete;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    const menuWidth = 128.0;
    final itemCount = 2 + (canRetry ? 1 : 0) + (canDelete ? 1 : 0);
    final menuHeight = 14.0 + itemCount * 39.0;
    final media = MediaQuery.of(context);
    final left = (anchor.dx - menuWidth / 2)
        .clamp(12.0, media.size.width - menuWidth - 12.0)
        .toDouble();
    final top = (anchor.dy - menuHeight - 10)
        .clamp(media.padding.top + 8.0, media.size.height - menuHeight - 12.0)
        .toDouble();

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: menuWidth,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _CompactActionRow(
                        icon: SolarIconsOutline.reply,
                        title: 'پاسخ',
                        onTap: onReply,
                      ),
                      _CompactActionRow(
                        icon: SolarIconsOutline.copy,
                        title: 'کپی',
                        backgroundColor: AppColors.gray1,
                        onTap: onCopy,
                      ),
                      if (canRetry)
                        _CompactActionRow(
                          icon: SolarIconsOutline.refresh,
                          title: 'ارسال دوباره',
                          onTap: onRetry,
                        ),
                      if (canDelete)
                        _CompactActionRow(
                          icon: SolarIconsOutline.trashBinTrash,
                          title: 'حذف',
                          onTap: onDelete,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactActionRow extends StatelessWidget {
  const _CompactActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.backgroundColor = Colors.transparent,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: backgroundColor,
        child: SizedBox(
          height: 39,
          child: Row(
            children: [
              const SizedBox(width: 13),
              Icon(
                icon,
                color: AppColors.black1.withOpacity(0.62),
                size: 16,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: ReText(
                  title,
                  color: AppColors.black1,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteMessageSheet extends StatelessWidget {
  const _DeleteMessageSheet({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray2,
                  borderRadius: BorderRadius.circular(100),
                ),
              ).bMargin(18),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.errorColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.errorColor.withOpacity(0.28),
                  ),
                ),
                child: const Icon(
                  SolarIconsOutline.trashBinTrash,
                  color: AppColors.errorColor,
                  size: 19,
                ),
              ),
              const ReText(
                'حذف پیام',
                color: AppColors.black1,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                textAlign: TextAlign.center,
              ).tMargin(12),
              ReText(
                message.content,
                color: AppColors.black1.withOpacity(0.62),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                maxLines: 2,
                lineHeight: 1.6,
              ).tMargin(5),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(false),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.gray2),
                        ),
                        child: const ReText(
                          'لغو',
                          color: AppColors.black1,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(true),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        height: 48,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.errorColor,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.errorColor.withOpacity(0.20),
                              blurRadius: 14,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: const ReText(
                          'حذف',
                          color: AppColors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ).tMargin(20),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoomOverflowDialog extends StatelessWidget {
  const _RoomOverflowDialog({
    required this.onViewProfile,
    required this.onClearConversation,
    required this.onDeleteChat,
  });

  final VoidCallback onViewProfile;
  final VoidCallback onClearConversation;
  final VoidCallback onDeleteChat;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              top: 48,
              left: 18,
              width: 186,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.10),
                        blurRadius: 26,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _RoomMenuRow(
                          icon: SolarIconsOutline.user,
                          title: 'نمایش پروفایل',
                          onTap: onViewProfile,
                        ),
                        _RoomMenuRow(
                          icon: SolarIconsOutline.trashBinTrash,
                          title: 'پاک کردن گفتگو',
                          color: AppColors.errorColor,
                          onTap: onClearConversation,
                        ),
                        _RoomMenuRow(
                          icon: SolarIconsOutline.closeSquare,
                          title: 'حذف مکالمه',
                          color: AppColors.errorColor,
                          onTap: onDeleteChat,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomMenuRow extends StatelessWidget {
  const _RoomMenuRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = AppColors.black1,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 42,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 9),
            Expanded(
              child: ReText(
                title,
                color: AppColors.black1,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 14),
          ],
        ),
      ),
    );
  }
}

class _InlineReplyPreview extends StatelessWidget {
  const _InlineReplyPreview({required this.reply, required this.isMine});

  final ChatReplyMessage reply;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 7),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(isMine ? 0.62 : 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          right: BorderSide(
            color: isMine ? AppColors.secondary : AppColors.primary,
            width: 3,
          ),
        ),
      ),
      child: ReText(
        reply.content,
        color: AppColors.black1.withOpacity(0.58),
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        maxLines: 2,
      ),
    );
  }
}

class _ComposerReplyPreview extends StatelessWidget {
  const _ComposerReplyPreview({required this.message, required this.onCancel});

  final ChatMessage message;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onCancel,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.gray,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const ReText(
                  'پاسخ به پیام',
                  color: AppColors.secondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
                ReText(
                  message.content,
                  color: AppColors.black1.withOpacity(0.60),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatStateView extends StatelessWidget {
  const _ChatStateView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.primary, size: 28),
            ),
            ReText(
              title,
              color: AppColors.black1,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              textAlign: TextAlign.center,
            ).tMargin(18),
            ReText(
              subtitle,
              color: AppColors.black1.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              lineHeight: 1.7,
              maxLines: 3,
            ).tMargin(5),
            if (actionText != null && onAction != null)
              SizedBox(
                width: 150,
                child: ReButton(
                  text: actionText,
                  onPressed: onAction,
                  height: 46,
                  borderRadius: 100,
                  fontSize: 13,
                ),
              ).tMargin(18),
          ],
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.black1,
    this.backgroundColor = AppColors.white,
    this.showShadow = true,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
  final bool showShadow;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: ReImage(
          'assets/images/sample_profile.png',
          width: size - 4,
          height: size - 4,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _ChatPatternBackground extends StatelessWidget {
  const _ChatPatternBackground();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF3F4F9),
      child: Image.asset(
        'assets/images/chat_background.png',
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.topCenter,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

void _logChatLive(String message) {
  if (kDebugMode) debugPrint('[ChatLive] $message');
}

List<String> _updatedSeenMessageIDs(
  List<ChatMessage> before,
  List<ChatMessage> after,
) {
  final beforeSeenAtByID = {
    for (final message in before) message.id: message.seenAt,
  };
  return [
    for (final message in after)
      if (message.seenAt != null &&
          beforeSeenAtByID[message.id] != message.seenAt)
        message.id,
  ];
}

String _latestReadAt(String? current, String incoming) {
  final currentDate = DateTime.tryParse(current ?? '');
  final incomingDate = DateTime.tryParse(incoming);
  if (incomingDate == null) return current ?? incoming;
  if (currentDate == null || incomingDate.isAfter(currentDate)) return incoming;
  return current!;
}

String _formatMessageTime(String isoDate) {
  final parsed = DateTime.tryParse(isoDate)?.toLocal();
  if (parsed == null) return '';
  return '${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')}';
}

String _friendlyError(Object error) {
  if (_isCommittedTransactionError(error)) {
    return 'پیام ارسال شد و در حال همگام‌سازی است.';
  }
  final text = error.toString();
  if (text.contains('Unauthorized') || text.contains('Authentication')) {
    return 'برای ادامه دوباره وارد حساب شوید.';
  }
  if (text.trim().isEmpty) return 'خطای ناشناخته رخ داد.';
  return text.replaceFirst('Exception: ', '');
}

bool _isCommittedTransactionError(Object error) {
  final text = error.toString().toLowerCase();
  final isTransactionError =
      text.contains('transaction') && text.contains('already');
  final mentionsCommittedOrRolledBack = text.contains('committed') ||
      text.contains('rolled back') ||
      text.contains('rollback');
  return isTransactionError && mentionsCommittedOrRolledBack;
}
