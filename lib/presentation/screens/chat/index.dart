// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math' as math;

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
    _contactsController = ScrollController()..addListener(_handleContactsScroll);
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
    _inboxClient.connect();
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
    _inboxClient.connect();
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

  Future<void> _loadContacts({bool silent = false}) async {
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
        if (event.message.senderID != currentUserID &&
            contactUserID != _activeChatUserID) {
          _unreadByUserID[contactUserID] =
              (_unreadByUserID[contactUserID] ?? 0) + 1;
        }
      });
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
  ChatMessage? _replyingTo;
  String? _currentUserID;
  String? _error;
  int _offset = 0;
  bool _isLoading = true;
  bool _isLoadingOlder = false;
  bool _isSyncingLatest = false;
  bool _hasMore = true;
  bool _isSending = false;

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
    _eventSubscription?.cancel();
    _statusSubscription?.cancel();
    _initialMessagesSubscription?.cancel();
    _connectionDebounce?.cancel();
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
    _inboxClient.connect();
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
      _messages = initialLoad.messages;
      _offset = initialLoad.offset;
      _hasMore = initialLoad.hasMore;
      _error = null;
      _isLoading = false;
    });
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
        _messages = upsertMessages(_messages, olderMessages);
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
    _eventSubscription = _inboxClient.events.listen((event) {
      _chatRepository.applyInboxEventToCache(
        event,
        limit: _pageSize,
        cachedPageOffsets: _cachedPageOffsets,
      );
      final result = applyInboxEventToRoom(
        messages: _messages,
        activityByUserID: _activityByUserID,
        event: event,
        chatID: widget.chatID,
      );
      if (!mounted) return;
      final shouldScroll = event is NewMessageInboxEvent &&
          event.message.chatID == widget.chatID &&
          _isNearBottom;
      setState(() {
        _messages = result.messages;
        _activityByUserID = result.activityByUserID;
      });
      if (shouldScroll) _scrollToBottomSoon();
    });
    _statusSubscription = _inboxClient.status.listen((status) {
      if (!mounted) return;
      _applyConnectionStatus(status);
    });
    _applyConnectionStatus(_inboxClient.currentStatus);
    _inboxClient.connect();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels < 120) {
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
        _messages = upsertMessages(removeLocalMessage(_messages, localID), [
          sentMessage,
        ]);
        _isSending = false;
      });
      _scrollToBottomSoon();
    } catch (error) {
      if (!mounted) return;
      if (_isCommittedTransactionError(error)) {
        await _recoverCommittedSend(
          localMessage.copyWith(isSending: false, isFailed: false),
        );
        return;
      }
      setState(() {
        _messages = markMessageFailed(_messages, localID);
        _isSending = false;
      });
      showReToast(context, _friendlyError(error), ReToastType.failed);
    }
  }

  Future<void> _recoverCommittedSend(ChatMessage localMessage) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    if (_hasRecoveredCommittedSend(localMessage)) {
      setState(() {
        _messages = removeLocalMessage(_messages, localMessage.id);
        _isSending = false;
      });
      _scrollToBottomSoon();
      return;
    }

    await _syncLatestMessages();
    if (!mounted) return;
    if (_hasRecoveredCommittedSend(localMessage)) {
      setState(() {
        _messages = removeLocalMessage(_messages, localMessage.id);
        _isSending = false;
      });
      _scrollToBottomSoon();
      return;
    }

    setState(() {
      _messages = upsertMessages(
        removeLocalMessage(_messages, localMessage.id),
        [localMessage.copyWith(isSending: false, isFailed: false)],
      );
      _isSending = false;
    });
    _scrollToBottomSoon();
  }

  bool _hasRecoveredCommittedSend(ChatMessage localMessage) {
    final localMessageAlreadyReplaced = !_messages.any(
      (message) => message.id == localMessage.id,
    );
    return localMessageAlreadyReplaced ||
        hasServerEchoOfLocalMessage(_messages, localMessage);
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
        _messages = upsertMessages(_messages, latestMessages);
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

    showGeneralDialog<void>(
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
    );
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

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final distance = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    return distance < 120;
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
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
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.gray1,
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(child: _ChatPatternBackground()),
              Column(
                children: [
                  _ChatRoomHeader(
                    title: widget.title ?? 'گفتگو',
                    subtitle: _roomSubtitle(targetActivity),
                    isOnline: targetActivity?.isOnline == true,
                    onBack: () => Navigator.of(context).pop(),
                    onMenu: _openRoomMenu,
                    connectionStatus: _displayConnectionStatus,
                  ),
                  Expanded(child: _buildMessagesBody()),
                  _MessageComposer(
                    controller: _messageController,
                    replyingTo: _replyingTo,
                    isSending: _isSending,
                    onCancelReply: () => setState(() => _replyingTo = null),
                    onSend: _sendMessage,
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
      return const _ChatStateView(
        icon: SolarIconsOutline.chatRoundDots,
        title: 'اولین پیام را بفرستید',
        subtitle: 'این گفتگو هنوز پیامی ندارد.',
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      itemCount: _messages.length + (_isLoadingOlder ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isLoadingOlder && index == 0) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        final messageIndex = index - (_isLoadingOlder ? 1 : 0);
        final message = _messages[messageIndex];
        return _MessageBubble(
          message: message,
          isMine: message.senderID == _currentUserID,
          onLongPress: (position) => _openMessageActions(message, position),
        );
      },
    );
  }

  String _roomSubtitle(UserActivity? activity) {
    if (_displayConnectionStatus == InboxConnectionStatus.connecting ||
        _displayConnectionStatus == InboxConnectionStatus.reconnecting) {
      return 'در حال اتصال...';
    }
    if (_displayConnectionStatus == InboxConnectionStatus.error ||
        _displayConnectionStatus == InboxConnectionStatus.disconnected) {
      return 'اتصال زنده قطع است';
    }
    final taskName = activity?.currentTaskName?.trim();
    if (taskName != null && taskName.isNotEmpty) {
      return 'درحال انجام $taskName';
    }
    if (activity?.isOnline == true) return 'آنلاین';
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

  if (activity?.isOnline == true) return 'آنلاین';
  if (activity?.isOnline == false) return 'آفلاین';

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
  if (activity?.isOnline == true) return AppColors.done;
  if (activity?.isOnline == false) return AppColors.gray;
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
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
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
                            fontSize: 13.5,
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
                    const _ChatAvatar(size: 42),
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

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.onLongPress,
  });

  final ChatMessage message;
  final bool isMine;
  final ValueChanged<Offset> onLongPress;

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMine ? const Color(0xFFEFF3FF) : AppColors.white;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMine ? 18 : 5),
      bottomRight: Radius.circular(isMine ? 5 : 18),
    );

    return GestureDetector(
      onLongPressStart: (details) => onLongPress(details.globalPosition),
      onSecondaryTapDown: (details) => onLongPress(details.globalPosition),
      behavior: HitTestBehavior.opaque,
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: math.min(MediaQuery.of(context).size.width * 0.72, 430),
          ),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: radius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
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
                  message.isDeleted ? 'این پیام حذف شده است' : message.content,
                  color: message.isDeleted
                      ? AppColors.gray
                      : AppColors.black1.withOpacity(0.92),
                  fontSize: 12,
                  fontWeight:
                      message.isDeleted ? FontWeight.w600 : FontWeight.w700,
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
                        size: 13,
                      ).lMargin(4)
                    else if (message.isSending)
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppColors.black1.withOpacity(0.45),
                        ),
                      ).lMargin(4)
                    else if (isMine)
                      const Icon(
                        Icons.done_rounded,
                        color: AppColors.secondary,
                        size: 14,
                      ).lMargin(4),
                    ReText(
                      _formatMessageTime(message.createdAt),
                      color: AppColors.black1.withOpacity(0.38),
                      fontSize: 9.5,
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
    );
  }
}

class _MessageComposer extends StatefulWidget {
  const _MessageComposer({
    required this.controller,
    required this.replyingTo,
    required this.isSending,
    required this.onCancelReply,
    required this.onSend,
  });

  final TextEditingController controller;
  final ChatMessage? replyingTo;
  final bool isSending;
  final VoidCallback onCancelReply;
  final VoidCallback onSend;

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
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.88),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
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
                  onTap: _hasText && !widget.isSending ? widget.onSend : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _hasText && !widget.isSending
                          ? AppColors.primary
                          : AppColors.gray2,
                      shape: BoxShape.circle,
                      boxShadow: _hasText && !widget.isSending
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.26),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: widget.isSending
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(
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
                          color: AppColors.errorColor,
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
        height: 39,
        child: Row(
          children: [
            const SizedBox(width: 14),
            Expanded(
              child: ReText(
                title,
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                maxLines: 1,
              ),
            ),
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 13),
          ],
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
                color: color,
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
    return CustomPaint(
      painter: _ChatPatternPainter(),
      child: Container(color: const Color(0xFFF3F5FB).withOpacity(0.86)),
    );
  }
}

class _ChatPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.black1.withOpacity(0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    const gap = 58.0;
    for (double y = 16; y < size.height; y += gap) {
      for (double x = 18; x < size.width; x += gap) {
        final shift = ((x + y) ~/ gap).isEven ? 0.0 : 18.0;
        final rect = Rect.fromCenter(
          center: Offset(x + shift, y),
          width: 18,
          height: 12,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          paint,
        );
        canvas.drawCircle(Offset(x + 24 + shift, y + 18), 5, paint);
        canvas.drawLine(
          Offset(x - 9 + shift, y + 22),
          Offset(x + 7 + shift, y + 32),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
