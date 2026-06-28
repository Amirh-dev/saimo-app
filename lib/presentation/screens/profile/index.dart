import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';
import 'package:simo_learn/presentation/screens/chat/chat_repository.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

import 'friendship_models.dart';
import 'friendship_repository.dart';

enum ProfileContentSection {
  profile,
  friends,
  notifications,
  competition,
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.initialSection = ProfileContentSection.profile,
  });

  final ProfileContentSection initialSection;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileContentSection _section;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
  }

  @override
  void didUpdateWidget(covariant ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _section = widget.initialSection;
    }
  }

  void _setSection(ProfileContentSection section) {
    setState(() {
      _section = section;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigationScaffold(
      currentIndex: 4,
      onTap: (index) => navigateToIndex(context, index),
      body: SafeArea(
        child: _buildSection(),
      ),
    );
  }

  Widget _buildSection() {
    switch (_section) {
      case ProfileContentSection.profile:
        return _ProfileHomeContent(
          onSectionSelected: _setSection,
        );
      case ProfileContentSection.friends:
        return _FriendsContent(
          onSectionSelected: _setSection,
        );
      case ProfileContentSection.notifications:
        return _SimpleProfileContent(
          title: 'اعلان‌ها',
          emptyTitle: 'اعلانی وجود ندارد!',
          emptyDescription: 'اعلان‌های جدید شما در این قسمت نمایش داده می‌شود.',
          icon: SolarIconsOutline.bell,
          onSectionSelected: _setSection,
          selectedSection: _section,
        );
      case ProfileContentSection.competition:
        return _SimpleProfileContent(
          title: 'مسابقه',
          emptyTitle: 'مسابقه‌ای فعال نیست!',
          emptyDescription:
              'مسابقه‌ها و رتبه‌بندی‌ها به‌زودی اینجا قرار می‌گیرند.',
          icon: SolarIconsOutline.cupFirst,
          onSectionSelected: _setSection,
          selectedSection: _section,
        );
    }
  }
}

class _ProfileHomeContent extends StatelessWidget {
  const _ProfileHomeContent({
    required this.onSectionSelected,
  });

  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(42),
                bottomRight: Radius.circular(42),
              ),
            ),
            child: Column(
              children: [
                _ProfileHeader(
                  title: 'پروفایل',
                  selectedSection: ProfileContentSection.profile,
                  onSectionSelected: onSectionSelected,
                ).tMargin(20).hMargin(36),
                const _ProfileSummaryCard(),
              ],
            ).bMargin(12),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: AppColors.gray2),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.replay_rounded,
                          size: 15,
                        ),
                        ReText('بروزرسانی'),
                      ],
                    ),
                  ),
                  const ReText(
                    'حساب کاربری',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ],
              ).hMargin(16).tMargin(20).bMargin(10),
              _ProfileItem(
                title: 'اشتراک ویژه',
                icon: SolarIconsOutline.user,
                itemColor: AppColors.secondary,
                onTap: () {},
              ),
              _ProfileItem(
                title: 'مشخصات حساب',
                icon: SolarIconsOutline.user,
                itemColor: AppColors.secondary,
                onTap: () {},
              ).vMargin(12),
              _ProfileItem(
                title: 'تنظیمات',
                icon: SolarIconsOutline.settings,
                itemColor: AppColors.secondary,
                onTap: () {},
              ),
              Row(
                children: [
                  Flexible(
                    child: _ProfileItem(
                      title: 'پشتیبانی',
                      icon: SolarIconsOutline.headphonesRound,
                      itemColor: AppColors.black1,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 0,
                    child: _ProfileItem(
                      title: 'خروج',
                      icon: SolarIconsOutline.logout,
                      itemColor: AppColors.errorColor,
                      onTap: () {
                        context.to(const TasksScreen());
                      },
                      showSuffixIcon: false,
                    ),
                  ),
                ],
              ).vMargin(12),
            ],
          ).hMargin(36),
        ],
      ),
    );
  }
}

class _FriendsContent extends StatefulWidget {
  const _FriendsContent({
    required this.onSectionSelected,
  });

  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  State<_FriendsContent> createState() => _FriendsContentState();
}

class _FriendsContentState extends State<_FriendsContent>
    with WidgetsBindingObserver {
  final TextEditingController _targetUserIDController = TextEditingController();
  late final FriendshipRepository _friendshipRepository;
  late final ChatRepository _chatRepository;
  late final InboxSubscriptionClient _inboxClient;
  StreamSubscription<InboxEvent>? _eventSubscription;
  var _friends = <FriendshipItem>[];
  final _activityByUserID = <String, UserActivity>{};
  CurrentFriendshipUser? _currentUser;
  Timer? _refreshTimer;
  String? _error;
  String? _busyTargetID;
  bool _isLoading = true;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final graphql = context.read<GraphQLRepository>();
    _friendshipRepository = FriendshipRepository(graphql);
    _chatRepository = ChatRepository(graphql);
    _inboxClient = context.read<InboxSubscriptionClient>();
    _startInboxSubscription();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFriendships());
    _refreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      if (!mounted || _busyTargetID != null || _isSendingRequest) return;
      // Only poll while this screen is actually the visible top route. When a
      // chat (or any screen) is pushed on top, this state stays mounted but
      // must not keep hitting the server in the background.
      if (ModalRoute.of(context)?.isCurrent != true) return;
      _loadFriendships(silent: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _refreshTimer?.cancel();
    _eventSubscription?.cancel();
    _targetUserIDController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _inboxClient.connect();
    _loadFriendships(silent: true);
  }

  void _startInboxSubscription() {
    _eventSubscription = _inboxClient.events.listen((event) {
      if (event is! UserActivityInboxEvent || event.userID.isEmpty) return;
      if (!mounted) return;
      setState(() {
        _activityByUserID[event.userID] = UserActivity(
          isOnline: event.isOnline,
          currentTaskName: event.currentTaskName,
        );
      });
    });
    _inboxClient.connect();
  }

  Future<void> _loadFriendships({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final currentUser =
          _currentUser ?? await _friendshipRepository.getCurrentUser();
      String? expandedID;
      for (final friend in _friends) {
        if (friend.isExpanded) {
          expandedID = friend.id;
          break;
        }
      }
      final friendships =
          await _friendshipRepository.getFriendships(currentUser.id);
      if (!mounted) return;
      setState(() {
        _currentUser = currentUser;
        _friends = [
          for (final friendship in friendships)
            friendship.copyWith(isExpanded: friendship.id == expandedID),
        ];
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      if (silent) return;
      setState(() {
        _error = _friendlyProfileError(error);
        _isLoading = false;
      });
    }
  }

  void _toggleFriend(FriendshipItem friend) {
    setState(() {
      _friends = [
        for (final item in _friends)
          item.copyWith(
            isExpanded: item.id == friend.id ? !item.isExpanded : false,
          ),
      ];
    });
  }

  void _openAddFriendSheet() {
    showReModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => _AddFriendBottomSheet(
        controller: _targetUserIDController,
        isSubmitting: _isSendingRequest,
        onCancel: () => Navigator.of(sheetContext).pop(),
        onSubmit: () {
          final targetUserID = _targetUserIDController.text.trim();
          if (!_canSubmitFriendRequest(targetUserID)) return;
          Navigator.of(sheetContext).pop();
          _sendFriendRequest(targetUserID);
        },
      ),
    );
  }

  bool _canSubmitFriendRequest(String targetUserID) {
    if (targetUserID.isEmpty) {
      showReToast(context, 'شناسه کاربر را وارد کنید', ReToastType.warning);
      return false;
    }
    if (!_looksLikeUUID(targetUserID)) {
      showReToast(
        context,
        'در حال حاضر افزودن دوست با شناسه کاربر انجام می‌شود',
        ReToastType.warning,
      );
      return false;
    }
    if (targetUserID == _currentUser?.id) {
      showReToast(
          context, 'شناسه خودتان قابل افزودن نیست', ReToastType.warning);
      return false;
    }
    return true;
  }

  Future<void> _sendFriendRequest(String targetUserID) async {
    final currentUser = _currentUser;
    if (currentUser == null || _isSendingRequest) return;

    setState(() => _isSendingRequest = true);
    try {
      final friendship = await _friendshipRepository.sendFriendRequest(
        currentUserID: currentUser.id,
        targetUserID: targetUserID,
      );
      if (!mounted) return;
      setState(() {
        _friends = _upsertFriendship(friendship.copyWith(isExpanded: true));
        _targetUserIDController.clear();
        _isSendingRequest = false;
      });
      showReToast(context, 'درخواست دوستی ارسال شد', ReToastType.success);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSendingRequest = false);
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    }
  }

  Future<void> _acceptFriend(FriendshipItem friend) async {
    await _runFriendAction(
      friend,
      action: () async {
        final currentUser = _currentUser!;
        final accepted = await _friendshipRepository.acceptFriendRequest(
          currentUserID: currentUser.id,
          targetUserID: friend.targetUserID,
        );
        if (!mounted) return;
        setState(() {
          _friends = _upsertFriendship(accepted.copyWith(isExpanded: true));
        });
        showReToast(context, 'درخواست دوستی تایید شد', ReToastType.success);
      },
    );
  }

  Future<void> _rejectFriend(FriendshipItem friend) async {
    await _runFriendAction(
      friend,
      action: () async {
        await _friendshipRepository.rejectFriendRequest(friend.targetUserID);
        if (!mounted) return;
        setState(() {
          _friends = _removeFriendship(friend.targetUserID);
        });
        showReToast(context, 'درخواست دوستی رد شد', ReToastType.success);
      },
    );
  }

  Future<void> _cancelFriend(FriendshipItem friend) async {
    await _runFriendAction(
      friend,
      action: () async {
        await _friendshipRepository.cancelFriendRequest(friend.targetUserID);
        if (!mounted) return;
        setState(() {
          _friends = _removeFriendship(friend.targetUserID);
        });
        showReToast(context, 'درخواست دوستی لغو شد', ReToastType.success);
      },
    );
  }

  Future<void> _removeFriend(FriendshipItem friend) async {
    await _runFriendAction(
      friend,
      action: () async {
        await _friendshipRepository.removeFriend(friend.targetUserID);
        if (!mounted) return;
        setState(() {
          _friends = _removeFriendship(friend.targetUserID);
        });
        showReToast(context, 'دوست حذف شد', ReToastType.success);
      },
    );
  }

  Future<void> _openChat(FriendshipItem friend) async {
    final currentUser = _currentUser;
    if (currentUser == null || _busyTargetID != null) return;

    setState(() => _busyTargetID = friend.targetUserID);
    try {
      final chatID =
          await _chatRepository.createDirectChat(friend.targetUserID);
      if (!mounted) return;
      await context.to(
        ChatRoomScreen(
          chatID: chatID,
          currentUserID: currentUser.id,
          targetUserID: friend.targetUserID,
          title: friend.targetUser.displayName,
        ),
      );
      if (mounted) {
        setState(() => _busyTargetID = null);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _busyTargetID = null);
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    }
  }

  Future<void> _runFriendAction(
    FriendshipItem friend, {
    required Future<void> Function() action,
  }) async {
    if (_busyTargetID != null || _currentUser == null) return;

    setState(() => _busyTargetID = friend.targetUserID);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    } finally {
      if (mounted) {
        setState(() => _busyTargetID = null);
      }
    }
  }

  List<FriendshipItem> _upsertFriendship(FriendshipItem friendship) {
    final next = [
      friendship,
      for (final item in _friends)
        if (item.targetUserID != friendship.targetUserID) item,
    ];
    next.sort((a, b) => _friendSort(a).compareTo(_friendSort(b)));
    return next;
  }

  List<FriendshipItem> _removeFriendship(String targetUserID) {
    return [
      for (final item in _friends)
        if (item.targetUserID != targetUserID) item,
    ];
  }

  int _friendSort(FriendshipItem item) {
    return switch (item.relation) {
      FriendshipRelation.incomingPending => 0,
      FriendshipRelation.accepted => 1,
      FriendshipRelation.outgoingPending => 2,
    };
  }

  Future<void> _copyCurrentUserID() async {
    final userID = _currentUser?.id;
    if (userID == null || userID.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: userID));
    if (!mounted) return;
    showReToast(context, 'شناسه شما کپی شد', ReToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FriendsTopPanel(
          onAddFriend: _openAddFriendSheet,
          onSectionSelected: widget.onSectionSelected,
        ),
        if (_currentUser != null)
          _FriendCodeCard(
            userID: _currentUser!.id,
            onCopy: _copyCurrentUserID,
          ).hMargin(24).tMargin(14),
        Expanded(child: _buildBody()),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (_error != null) {
      return _FriendStatusView(
        icon: SolarIconsOutline.dangerTriangle,
        title: 'دوستان دریافت نشدند',
        subtitle: _error!,
        actionText: 'تلاش دوباره',
        onAction: _loadFriendships,
      );
    }

    if (_friends.isEmpty) return _buildEmptyState();
    return _buildList();
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
      child: Column(
        children: [
          const SizedBox(
            width: 190,
            height: 150,
            child: _FriendsEmptyIllustration(),
          ),
          const ReText(
            'لیست دوستان خالی است!',
            color: AppColors.black1,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.center,
          ).tMargin(18),
          ReText(
            'برای افزودن دوست کلیک کنید.',
            color: AppColors.black1.withOpacity(0.55),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
          ).tMargin(4),
          const SizedBox(height: 16),
          SizedBox(
            width: 170,
            child: ReButton(
              text: 'افزودن دوست',
              icon: SolarIconsOutline.userPlus,
              onPressed: _openAddFriendSheet,
              background: AppColors.secondary,
              height: 54,
              borderRadius: 100,
              fontSize: 15,
              iconSize: 18,
              reverseIconPosition: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadFriendships,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(36, 22, 36, 28),
        itemBuilder: (context, index) => _FriendTile(
          friend: _friends[index],
          activity: _activityByUserID[_friends[index].targetUserID],
          isBusy: _busyTargetID == _friends[index].targetUserID,
          onTap: () => _toggleFriend(_friends[index]),
          onMessage: () => _openChat(_friends[index]),
          onProfile: () {},
          onAccept: () => _acceptFriend(_friends[index]),
          onReject: () => _rejectFriend(_friends[index]),
          onCancel: () => _cancelFriend(_friends[index]),
          onDelete: () => _removeFriend(_friends[index]),
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: _friends.length,
      ),
    );
  }
}

class _FriendCodeCard extends StatelessWidget {
  const _FriendCodeCard({
    required this.userID,
    required this.onCopy,
  });

  final String userID;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.04),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onCopy,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  SolarIconsOutline.copy,
                  color: AppColors.primary,
                  size: 17,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const ReText(
                    'شناسه شما برای افزودن دوست',
                    color: AppColors.black1,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                  ReText(
                    userID,
                    color: AppColors.black1.withOpacity(0.56),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                  ).tMargin(2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FriendStatusView extends StatelessWidget {
  const _FriendStatusView({
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

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.friend,
    required this.activity,
    required this.isBusy,
    required this.onTap,
    required this.onMessage,
    required this.onProfile,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
    required this.onDelete,
  });

  final FriendshipItem friend;
  final UserActivity? activity;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onMessage;
  final VoidCallback onProfile;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(8, 7, 8, friend.isExpanded ? 10 : 7),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(friend.isExpanded ? 0.08 : 0.04),
            blurRadius: friend.isExpanded ? 24 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          _FriendTileHeader(
            friend: friend,
            activity: activity,
            onTap: onTap,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: friend.isExpanded
                ? _FriendActions(
                    key: const ValueKey('friend-actions'),
                    friend: friend,
                    isBusy: isBusy,
                    onMessage: onMessage,
                    onProfile: onProfile,
                    onAccept: onAccept,
                    onReject: onReject,
                    onCancel: onCancel,
                    onDelete: onDelete,
                  ).tMargin(8)
                : const SizedBox.shrink(key: ValueKey('friend-actions-empty')),
          ),
        ],
      ),
    );
  }
}

class _FriendTileHeader extends StatelessWidget {
  const _FriendTileHeader({
    required this.friend,
    required this.activity,
    required this.onTap,
  });

  final FriendshipItem friend;
  final UserActivity? activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.03),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                friend.isExpanded
                    ? SolarIconsOutline.altArrowUp
                    : SolarIconsOutline.altArrowDown,
                color: AppColors.black1.withOpacity(0.5),
                size: 17,
              ),
            ),
          ),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReText(
                    friend.targetUser.displayName,
                    color: AppColors.black1,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                  SizedBox(
                    width: 168,
                    child: ReText(
                      _friendStatusText(friend, activity),
                      color: _friendStatusColor(friend, activity),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.end,
                    ),
                  ).tMargin(2),
                ],
              ).rMargin(9),
              const _FriendAvatar(path: 'assets/images/sample_profile.png'),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.path,
  });

  final String path;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: ReImage(
          path,
          width: 42,
          height: 42,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _FriendActions extends StatelessWidget {
  const _FriendActions({
    super.key,
    required this.friend,
    required this.isBusy,
    required this.onMessage,
    required this.onProfile,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
    required this.onDelete,
  });

  final FriendshipItem friend;
  final bool isBusy;
  final VoidCallback onMessage;
  final VoidCallback onProfile;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    if (isBusy) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final actions = switch (friend.relation) {
      FriendshipRelation.accepted => [
          _FriendActionSpec(
            title: 'پیام',
            icon: SolarIconsBold.chatRound,
            color: AppColors.secondary,
            onTap: onMessage,
          ),
          _FriendActionSpec(
            title: 'پروفایل',
            icon: SolarIconsBold.user,
            color: AppColors.primary,
            onTap: onProfile,
          ),
          _FriendActionSpec(
            title: 'حذف',
            icon: SolarIconsBold.trashBinTrash,
            color: AppColors.errorColor,
            onTap: onDelete,
          ),
        ],
      FriendshipRelation.incomingPending => [
          _FriendActionSpec(
            title: 'تایید',
            icon: SolarIconsOutline.checkSquare,
            color: AppColors.done,
            onTap: onAccept,
          ),
          _FriendActionSpec(
            title: 'رد',
            icon: SolarIconsBold.trashBinTrash,
            color: AppColors.errorColor,
            onTap: onReject,
          ),
        ],
      FriendshipRelation.outgoingPending => [
          _FriendActionSpec(
            title: 'لغو درخواست',
            icon: SolarIconsOutline.closeSquare,
            color: AppColors.errorColor,
            onTap: onCancel,
          ),
        ],
    };

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          for (int index = 0; index < actions.length; index++) ...[
            Expanded(
              child: _FriendActionButton(
                title: actions[index].title,
                icon: actions[index].icon,
                color: actions[index].color,
                onTap: actions[index].onTap,
              ),
            ),
            if (index != actions.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _FriendActionSpec {
  const _FriendActionSpec({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

String _friendStatusText(FriendshipItem friend, UserActivity? activity) {
  if (friend.relation == FriendshipRelation.accepted) {
    final taskName = activity?.currentTaskName?.trim();
    if (taskName != null && taskName.isNotEmpty) {
      return 'درحال انجام $taskName';
    }
    if (activity?.isOnline == true) return 'آنلاین';
    if (activity?.isOnline == false) return 'آفلاین';
  }

  return switch (friend.relation) {
    FriendshipRelation.accepted => 'دوست شما',
    FriendshipRelation.incomingPending => 'درخواست دوستی جدید',
    FriendshipRelation.outgoingPending => 'در انتظار تایید درخواست',
  };
}

Color _friendStatusColor(FriendshipItem friend, UserActivity? activity) {
  if (friend.relation == FriendshipRelation.accepted) {
    if (activity?.currentTaskName?.trim().isNotEmpty == true) {
      return AppColors.secondary;
    }
    if (activity?.isOnline == true) return AppColors.done;
    if (activity?.isOnline == false) return AppColors.gray;
  }

  return switch (friend.relation) {
    FriendshipRelation.accepted => AppColors.done,
    FriendshipRelation.incomingPending => AppColors.primary,
    FriendshipRelation.outgoingPending => AppColors.simoCoin,
  };
}

class _FriendActionButton extends StatelessWidget {
  const _FriendActionButton({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ReText(
              title,
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ).rMargin(7),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFriendBottomSheet extends StatelessWidget {
  const _AddFriendBottomSheet({
    required this.controller,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(30, 0, 30, 28),
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      const ReText(
                        'افزودن دوست',
                        color: AppColors.black1,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.center,
                      ),
                      ReText(
                        'شناسه کاربر را وارد کنید',
                        color: AppColors.black1.withOpacity(0.7),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.center,
                      ).tMargin(4),
                    ],
                  ).tMargin(28),
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: onCancel,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.gray2),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                  ).tMargin(22),
                ],
              ),
              ReTextField(
                controller: controller,
                placeholder: 'شناسه کاربر',
                keyboardType: TextInputType.text,
                height: 48,
                backgroundColor: AppColors.gray1,
                borderRadius: 100,
                showFocusShadow: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 22),
              ).tMargin(26),
              Row(
                children: [
                  Expanded(
                    child: ReButton(
                      text: isSubmitting ? 'در حال ارسال' : 'ارسال درخواست',
                      icon: Icons.chevron_left_rounded,
                      onPressed: isSubmitting ? null : onSubmit,
                      background: AppColors.primary,
                      height: 48,
                      borderRadius: 18,
                      fontSize: 14,
                      iconSize: 22,
                      reverseIconPosition: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 96,
                    child: ReButton(
                      text: 'لغو',
                      icon: Icons.close_rounded,
                      onPressed: onCancel,
                      isOutlined: true,
                      background: AppColors.white,
                      color: AppColors.gray2,
                      textColor: AppColors.black1,
                      iconColor: AppColors.black1,
                      height: 48,
                      borderRadius: 18,
                      fontSize: 14,
                      iconSize: 17,
                      reverseIconPosition: true,
                    ),
                  ),
                ],
              ).tMargin(22),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleProfileContent extends StatelessWidget {
  const _SimpleProfileContent({
    required this.title,
    required this.emptyTitle,
    required this.emptyDescription,
    required this.icon,
    required this.onSectionSelected,
    required this.selectedSection,
  });

  final String title;
  final String emptyTitle;
  final String emptyDescription;
  final IconData icon;
  final ValueChanged<ProfileContentSection> onSectionSelected;
  final ProfileContentSection selectedSection;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileSectionTopPanel(
          title: title,
          selectedSection: selectedSection,
          onSectionSelected: onSectionSelected,
        ),
        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.secondary,
                    size: 34,
                  ),
                ),
                ReText(
                  emptyTitle,
                  color: AppColors.black1,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  textAlign: TextAlign.center,
                ).tMargin(18),
                ReText(
                  emptyDescription,
                  color: AppColors.black1.withOpacity(0.55),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.center,
                ).tMargin(6).hMargin(36),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FriendsTopPanel extends StatelessWidget {
  const _FriendsTopPanel({
    required this.onAddFriend,
    required this.onSectionSelected,
  });

  final VoidCallback onAddFriend;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionTopPanel(
      title: 'دوستان',
      selectedSection: ProfileContentSection.friends,
      onSectionSelected: onSectionSelected,
      bottom: Row(
        children: [
          GestureDetector(
            onTap: onAddFriend,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                SolarIconsOutline.userPlus,
                color: AppColors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: ReSearchPill(),
          ),
        ],
      ).hMargin(24).tMargin(18),
    );
  }
}

class _ProfileSectionTopPanel extends StatelessWidget {
  const _ProfileSectionTopPanel({
    required this.title,
    required this.selectedSection,
    required this.onSectionSelected,
    this.bottom,
  });

  final String title;
  final ProfileContentSection selectedSection;
  final ValueChanged<ProfileContentSection> onSectionSelected;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
      ),
      child: Column(
        children: [
          _ProfileHeader(
            title: title,
            selectedSection: selectedSection,
            onSectionSelected: onSectionSelected,
          ).tMargin(20).hMargin(36),
          if (bottom != null) bottom!.bMargin(18),
          if (bottom == null) const SizedBox(height: 22),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.title,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final String title;
  final ProfileContentSection selectedSection;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _HeaderActionIcon(
              icon: SolarIconsOutline.bell,
              section: ProfileContentSection.notifications,
              selectedSection: selectedSection,
              onTap: onSectionSelected,
              showBadge: true,
            ),
            _HeaderActionIcon(
              icon: SolarIconsOutline.chatRound,
              section: ProfileContentSection.friends,
              selectedSection: selectedSection,
              onTap: onSectionSelected,
              showBadge: true,
            ),
            _HeaderActionIcon(
              icon: SolarIconsOutline.cupFirst,
              section: ProfileContentSection.competition,
              selectedSection: selectedSection,
              onTap: onSectionSelected,
            ),
          ],
        ),
        ReText(
          title,
          fontSize: 16,
          fontWeight: 1000,
        ),
      ],
    );
  }
}

class _HeaderActionIcon extends StatelessWidget {
  const _HeaderActionIcon({
    required this.icon,
    required this.section,
    required this.selectedSection,
    required this.onTap,
    this.showBadge = false,
  });

  final IconData icon;
  final ProfileContentSection section;
  final ProfileContentSection selectedSection;
  final ValueChanged<ProfileContentSection> onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedSection == section;

    return GestureDetector(
      onTap: () => onTap(section),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 34,
        height: 40,
        margin: const EdgeInsets.only(right: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gray1 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: AppColors.black1,
            ),
            if (showBadge)
              Positioned(
                top: 7,
                right: 7,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.gray1,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const ReText(
                    'علیرضا یوسفی',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Row(
                        children: [
                          ReText(
                            'تا پایان اشتراک ویژه',
                            color: AppColors.black1,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                          ReText(
                            '24 روز',
                            color: AppColors.black1,
                            fontWeight: FontWeight.w400,
                            fontSize: 13,
                          ),
                        ],
                      ).rMargin(4),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.simoCoin,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Row(
                          children: [
                            ReText(
                              'کاربر ویژه',
                              fontSize: 14,
                              color: AppColors.white,
                              fontWeight: FontWeight.w400,
                            ),
                            SizedBox(width: 2),
                            Icon(
                              SolarIconsOutline.stars,
                              size: 15,
                              color: AppColors.white,
                            ),
                          ],
                        ).hMargin(8).vMargin(2),
                      ),
                    ],
                  ).tMargin(5),
                ],
              ).rMargin(16),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: const ReImage(
                  'assets/images/sample_profile.png',
                  width: 50,
                  height: 50,
                ),
              ).rMargin(16).vMargin(16),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: const EdgeInsets.only(left: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.gray2),
                  ),
                  child: const Icon(
                    SolarIconsOutline.infoCircle,
                    size: 20,
                  ).vMargin(4).hMargin(4),
                ),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Row(
                          children: [
                            ReText(
                              '36',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              isBold: true,
                            ),
                            ReText(
                              '79.',
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ],
                        ).rMargin(8),
                        const ReText(
                          'سایموکوین',
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black1,
                        ),
                      ],
                    ).rMargin(4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: AppColors.simoCoin.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        color: AppColors.simoCoin,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ],
                ).hMargin(16).vMargin(10),
              ],
            ),
          ),
        ],
      ).bMargin(12).hMargin(10),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.title,
    required this.icon,
    required this.itemColor,
    required this.onTap,
    this.showSuffixIcon = true,
  });

  final String title;
  final IconData icon;
  final Color itemColor;
  final VoidCallback onTap;
  final bool showSuffixIcon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 26),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: AppColors.white,
        ),
        child: Row(
          mainAxisAlignment: showSuffixIcon
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (showSuffixIcon)
              Icon(
                Icons.arrow_back_ios,
                size: 16,
                color: itemColor,
              ),
            Row(
              children: [
                ReText(
                  title,
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ).rMargin(10),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: itemColor,
                    size: 16,
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

class _FriendsEmptyIllustration extends StatelessWidget {
  const _FriendsEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _FriendsEmptyIllustrationPainter(),
      size: Size.infinite,
    );
  }
}

class _FriendsEmptyIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 190;
    canvas.save();
    canvas.scale(scale);

    final navy = Paint()
      ..color = AppColors.black1
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final blue = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;
    final orange = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final white = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    final darkFill = Paint()
      ..color = AppColors.black1
      ..style = PaintingStyle.fill;

    canvas.drawCircle(const Offset(94, 74), 42, navy);
    canvas.drawLine(const Offset(66, 45), const Offset(121, 104), navy);
    canvas.drawLine(const Offset(125, 37), const Offset(94, 74), navy);
    canvas.drawCircle(const Offset(127, 30), 4, navy);

    final leftHand = Path()
      ..moveTo(42, 75)
      ..cubicTo(58, 80, 66, 89, 72, 104)
      ..cubicTo(58, 102, 50, 95, 42, 84)
      ..cubicTo(38, 80, 38, 76, 42, 75)
      ..moveTo(72, 104)
      ..cubicTo(78, 100, 83, 93, 86, 84);
    canvas.drawPath(leftHand, white);
    canvas.drawPath(leftHand, navy);

    final rightHand = Path()
      ..moveTo(141, 84)
      ..cubicTo(128, 88, 117, 97, 111, 111)
      ..cubicTo(126, 109, 138, 101, 146, 91)
      ..cubicTo(150, 86, 147, 82, 141, 84)
      ..moveTo(111, 111)
      ..cubicTo(103, 105, 99, 98, 96, 90);
    canvas.drawPath(rightHand, white);
    canvas.drawPath(rightHand, navy);

    final speaker = Path()
      ..moveTo(34, 40)
      ..lineTo(54, 31)
      ..lineTo(55, 63)
      ..lineTo(35, 55)
      ..close();
    canvas.drawPath(speaker, orange);
    canvas.drawPath(speaker, navy);
    canvas.drawRect(const Rect.fromLTWH(26, 43, 13, 23), orange);
    canvas.drawRect(const Rect.fromLTWH(26, 43, 13, 23), navy);
    canvas.drawLine(const Offset(28, 68), const Offset(21, 90), navy);
    canvas.drawLine(const Offset(34, 68), const Offset(39, 87), navy);

    final sleeve = Path()
      ..moveTo(143, 109)
      ..lineTo(174, 126)
      ..lineTo(163, 150)
      ..lineTo(128, 126)
      ..close();
    canvas.drawPath(sleeve, darkFill);
    canvas.drawPath(sleeve, navy);

    final cuff = Path()
      ..moveTo(127, 126)
      ..lineTo(141, 137)
      ..lineTo(135, 146);
    canvas.drawPath(cuff, blue);

    canvas.drawCircle(const Offset(158, 124), 2, blue);
    canvas.drawCircle(const Offset(150, 134), 2, blue);
    canvas.drawCircle(const Offset(43, 24), 3, orange);
    canvas.drawCircle(const Offset(143, 68), 4, blue);
    canvas.drawCircle(const Offset(157, 72), 3, blue);
    canvas.drawLine(const Offset(58, 18), const Offset(68, 31), navy);
    canvas.drawLine(const Offset(73, 18), const Offset(75, 33), navy);

    final flag1 = Path()
      ..moveTo(72, 12)
      ..lineTo(82, 23)
      ..lineTo(82, 6)
      ..close();
    final flag2 = Path()
      ..moveTo(90, 13)
      ..lineTo(101, 22)
      ..lineTo(102, 6)
      ..close();
    canvas.drawPath(flag1, orange);
    canvas.drawPath(flag1, navy);
    canvas.drawPath(flag2, orange);
    canvas.drawPath(flag2, navy);

    canvas.drawLine(const Offset(46, 128), const Offset(39, 139), navy);
    canvas.drawCircle(const Offset(36, 143), 4, navy);
    canvas.drawLine(const Offset(75, 130), const Offset(69, 145), navy);
    canvas.drawCircle(const Offset(64, 148), 5, navy);
    canvas.drawLine(const Offset(88, 125), const Offset(87, 138), navy);
    canvas.drawLine(const Offset(100, 124), const Offset(107, 136), navy);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

bool _looksLikeUUID(String value) {
  return RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  ).hasMatch(value.trim());
}

String _friendlyProfileError(Object error) {
  final text = error.toString();
  if (text.contains('Unauthorized') || text.contains('Authentication')) {
    return 'برای ادامه دوباره وارد حساب شوید.';
  }
  if (text.contains('uuid') || text.contains('UUID')) {
    return 'شناسه کاربر معتبر نیست.';
  }
  if (text.trim().isEmpty) return 'خطای ناشناخته رخ داد.';
  return text.replaceFirst('Exception: ', '');
}
