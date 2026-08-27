// ignore_for_file: deprecated_member_use, prefer_const_constructors,
// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/auth/username_repository.dart';
import 'package:simo_learn/features/profile/profile_cubit.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';
import 'package:simo_learn/presentation/screens/chat/chat_models.dart';
import 'package:simo_learn/presentation/screens/chat/chat_repository.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';
import 'package:simo_learn/presentation/screens/chat/index.dart';
import 'package:simo_learn/presentation/screens/authentication/register/widgets/birth_date_picker_bottom_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/presentation/screens/premium/index.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/modal.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/presentation/widgets/re_image.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

import 'friendship_models.dart';
import 'friendship_repository.dart';
import 'dart:typed_data';

import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

enum ProfileContentSection {
  profile,
  friends,
  notifications,
  competition,
  accountDetails,
  settings,
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
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

  Future<void> _loadProfile({bool forceRefresh = false}) async {
    try {
      await context.read<ProfileCubit>().getMe(
            forceRefresh: forceRefresh,
          );
    } catch (error) {
      if (!mounted) return;
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    }
  }

  Future<ProfileUser> _updateProfile({
    required String fullName,
    required String username,
    required DateTime birthDate,
    String? major,
  }) async {
    return context.read<ProfileCubit>().updateProfile(
          fullName: fullName,
          username: username,
          birthDate: birthDate,
          major: major,
        );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<ProfileCubit>().state;
    return AppExitGuard(
      child: AppBottomNavigationScaffold(
        currentIndex: 4,
        onTap: (index) {
          if (index == 4) {
            _setSection(ProfileContentSection.profile);
            unawaited(_loadProfile(forceRefresh: true));
            return;
          }
          navigateToIndex(context, index, 4);
        },
        body: ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: ColoredBox(
              color: AppColors.gray1,
              child: _buildSection(profileState),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(ProfileState profileState) {
    final profile = profileState.profile;
    switch (_section) {
      case ProfileContentSection.profile:
        return _ProfileHomeContent(
          profile: profile,
          isRefreshing: profileState.isLoading,
          onRefresh: () => _loadProfile(forceRefresh: true),
          onOpenAccountDetails: () => _setSection(ProfileContentSection.accountDetails),
          onOpenSettings: () => _setSection(ProfileContentSection.settings),
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
          emptyDescription: 'مسابقه‌ها و رتبه‌بندی‌ها به‌زودی اینجا قرار می‌گیرند.',
          icon: SolarIconsOutline.cupFirst,
          onSectionSelected: _setSection,
          selectedSection: _section,
        );
      case ProfileContentSection.accountDetails:
        return _AccountDetailsContent(
          profile: profile,
          onBack: () => _setSection(ProfileContentSection.profile),
          onSectionSelected: _setSection,
          onSave: _updateProfile,
        );
      case ProfileContentSection.settings:
        return _ProfileSettingsContent(
          profile: profile,
          onBack: () => _setSection(ProfileContentSection.profile),
          onSectionSelected: _setSection,
        );
    }
  }
}

class FriendProfileScreen extends StatefulWidget {
  const FriendProfileScreen({
    super.key,
    required this.userID,
    required this.displayName,
    this.initialRelation,
  });

  final String userID;
  final String displayName;
  final FriendshipRelation? initialRelation;

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  late final ProfileRepository _profileRepository;
  late final FriendshipRepository _friendshipRepository;
  late final ChatRepository _chatRepository;
  ProfileUser? _profile;
  CurrentFriendshipUser? _currentUser;
  FriendshipRelation? _relation;
  bool _isLoading = true;
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    final graphql = context.read<GraphQLRepository>();
    _profileRepository = ProfileRepository(graphql);
    _friendshipRepository = FriendshipRepository(graphql);
    _chatRepository = ChatRepository(graphql);
    _relation = widget.initialRelation;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void didUpdateWidget(covariant FriendProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userID != widget.userID || oldWidget.initialRelation != widget.initialRelation) {
      _relation = widget.initialRelation;
      if (oldWidget.userID != widget.userID) {
        _profile = null;
        _isLoading = true;
        WidgetsBinding.instance.addPostFrameCallback((_) => _load());
      }
    }
  }

  Future<void> _load() async {
    try {
      final values = await Future.wait<Object>([
        _profileRepository.getUserProfile(widget.userID),
        _friendshipRepository.getCurrentUser(),
      ]);
      if (!mounted) return;
      setState(() {
        _profile = values[0] as ProfileUser;
        _currentUser = values[1] as CurrentFriendshipUser;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    }
  }

  Future<void> _changeFriendship() async {
    final currentUser = _currentUser;
    if (_isBusy || currentUser == null) return;
    setState(() => _isBusy = true);
    try {
      switch (_relation) {
        case FriendshipRelation.accepted:
          await _friendshipRepository.removeFriend(widget.userID);
          if (mounted) setState(() => _relation = null);
          break;
        case FriendshipRelation.outgoingPending:
          await _friendshipRepository.cancelFriendRequest(widget.userID);
          if (mounted) setState(() => _relation = null);
          break;
        case FriendshipRelation.incomingPending:
          await _friendshipRepository.acceptFriendRequest(
            currentUserID: currentUser.id,
            targetUserID: widget.userID,
          );
          if (mounted) setState(() => _relation = FriendshipRelation.accepted);
          break;
        case null:
          await _friendshipRepository.sendFriendRequest(
            currentUserID: currentUser.id,
            targetUserID: widget.userID,
          );
          if (mounted) {
            setState(() => _relation = FriendshipRelation.outgoingPending);
          }
          break;
      }
    } catch (error) {
      if (mounted) {
        showReToast(context, _friendlyProfileError(error), ReToastType.failed);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _openChat() async {
    final currentUser = _currentUser;
    if (_isBusy || currentUser == null || _relation != FriendshipRelation.accepted) {
      return;
    }
    setState(() => _isBusy = true);
    try {
      final chatID = await _chatRepository.createDirectChat(widget.userID);
      if (!mounted) return;
      await context.to(
        ChatRoomScreen(
          chatID: chatID,
          currentUserID: currentUser.id,
          targetUserID: widget.userID,
          title: _profile?.displayName ?? widget.displayName,
        ),
      );
    } catch (error) {
      if (mounted) {
        showReToast(context, _friendlyProfileError(error), ReToastType.failed);
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  String get _actionTitle => switch (_relation) {
        FriendshipRelation.accepted => 'لغو دوستی',
        FriendshipRelation.incomingPending => 'تایید درخواست',
        FriendshipRelation.outgoingPending => 'لغو درخواست',
        null => 'درخواست دوستی',
      };

  bool get _isDestructiveAction => _relation == FriendshipRelation.accepted || _relation == FriendshipRelation.outgoingPending;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigationScaffold(
      currentIndex: 4,
      onTap: (index) => navigateToIndex(context, index, 4),
      body: ColoredBox(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: AppColors.gray1,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator.adaptive())
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        _FriendProfileHeader(
                          title: _profile?.displayName ?? widget.displayName,
                          onBack: () => Navigator.of(context).pop(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
                          child: ReButton(
                            key: const ValueKey('friendship-action'),
                            text: _actionTitle,
                            icon: _isDestructiveAction ? SolarIconsOutline.userMinus : SolarIconsOutline.userPlus,
                            reverseIconPosition: true,
                            isLoading: _isBusy,
                            isOutlined: _isDestructiveAction,
                            background: _isDestructiveAction ? AppColors.white : AppColors.secondary,
                            textColor: _isDestructiveAction ? AppColors.black1 : AppColors.white,
                            color: _isDestructiveAction ? AppColors.gray2 : AppColors.secondary,
                            onPressed: _changeFriendship,
                            height: 52,
                            borderRadius: 100,
                          ),
                        ),
                        _FriendProfileSummaryCard(
                          profile: _profile,
                          relation: _relation,
                          onChat: _openChat,
                        ),
                        _ProfileInfoSections(
                          profile: _profile,
                        ),
                        const _AchievementsSection(),
                        _ProfileStatusSection(profile: _profile),
                        if (_relation != FriendshipRelation.accepted)
                          const _SuggestedProfilesSection(
                            isRefreshing: false,
                            onRefresh: _noop,
                          ),
                        const SizedBox(height: 26),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _FriendProfileHeader extends StatelessWidget {
  const _FriendProfileHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 18, 10),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            SolarIconsOutline.menuDots,
            color: AppColors.black1,
            size: 22,
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              GestureDetector(
                onTap: onBack,
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.gray,
                  size: 14,
                ),
              ),
              const SizedBox(width: 8),
              const ClipOval(
                child: ReImage(
                  Assets.profilePlaceholder,
                  width: 46,
                  height: 46,
                ),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReText(
                    title,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.simoCoin,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const ReText(
                      'کاربر ویژه',
                      color: AppColors.white,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FriendProfileSummaryCard extends StatelessWidget {
  const _FriendProfileSummaryCard({
    required this.profile,
    required this.relation,
    required this.onChat,
  });

  final ProfileUser? profile;
  final FriendshipRelation? relation;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ProfileMetricCard(
                  value: '3×',
                  label: 'ضریب امتیاز',
                  color: const Color(0xFFFF3040),
                  icon: SvgPicture.asset('assets/icons/flame.svg'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileMetricCard(
                  value: '${profile?.simoCoins ?? 36}',
                  label: 'سیموکوین',
                  color: const Color(0xFFFFC94C),
                  icon: SvgPicture.asset('assets/icons/simo_coin.svg', color: Color(0xffe56929)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _RoundProfileAction(
                icon: Icons.sports_martial_arts_rounded,
                color: AppColors.errorColor,
                onTap: _noop,
              ),
              const SizedBox(width: 8),
              _RoundProfileAction(
                icon: SolarIconsBold.chatRound,
                color: AppColors.secondary,
                onTap: relation == FriendshipRelation.accepted ? onChat : _noop,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReText(
                        '+33',
                        color: AppColors.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                      SizedBox(width: 8),
                      _MiniAvatarStack(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundProfileAction extends StatelessWidget {
  const _RoundProfileAction({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.gray1,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 19),
      ),
    );
  }
}

class _ProfileHomeContent extends StatelessWidget {
  const _ProfileHomeContent({
    required this.profile,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onOpenAccountDetails,
    required this.onOpenSettings,
    required this.onSectionSelected,
  });

  final ProfileUser? profile;
  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenAccountDetails;
  final VoidCallback onOpenSettings;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    final loadedProfile = profile;
    if (loadedProfile == null || isRefreshing) {
      return _ProfileHomeShimmer(
        onSectionSelected: onSectionSelected,
      );
    }

    return RefreshIndicator(
      key: const ValueKey('profile-pull-to-refresh'),
      color: AppColors.primary,
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        key: const ValueKey('profile-scroll-view'),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        child: Column(
          children: [
            _ProfileTopCard(
              profile: loadedProfile,
              selectedSection: ProfileContentSection.profile,
              onSectionSelected: onSectionSelected,
            ),
            _ProfileAccountMenu(
              isRefreshing: isRefreshing,
              onRefresh: onRefresh,
              // onPremium: () => context.to(const PremiumPlansScreen()),
              onPremium: () => showFreePremiumMessage(context),
              onAccountDetails: onOpenAccountDetails,
              onSettings: onOpenSettings,
              onSupport: () => showReToast(
                context,
                'پشتیبانی به‌زودی در دسترس قرار می‌گیرد',
                ReToastType.info,
              ),
              onLogout: () => _confirmProfileLogout(context),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ProfileAccountMenu extends StatelessWidget {
  const _ProfileAccountMenu({
    required this.isRefreshing,
    required this.onRefresh,
    required this.onPremium,
    required this.onAccountDetails,
    required this.onSettings,
    required this.onSupport,
    required this.onLogout,
  });

  final bool isRefreshing;
  final Future<void> Function() onRefresh;
  final VoidCallback onPremium;
  final VoidCallback onAccountDetails;
  final VoidCallback onSettings;
  final VoidCallback onSupport;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _OutlinedProfileAction(
                title: 'بروزرسانی',
                icon: Icons.refresh_rounded,
                onTap: isRefreshing ? () {} : onRefresh,
              ),
              const Flexible(
                child: ReText(
                  'حساب کاربری',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _ProfileAccountMenuTile(
            key: const ValueKey('open-premium-subscription'),
            title: 'اشتراک ویژه',
            icon: SolarIconsOutline.user,
            onTap: onPremium,
          ),
          const SizedBox(height: 10),
          _ProfileAccountMenuTile(
            key: const ValueKey('open-account-details'),
            title: 'مشخصات حساب',
            icon: SolarIconsOutline.user,
            onTap: onAccountDetails,
          ),
          const SizedBox(height: 10),
          _ProfileAccountMenuTile(
            key: const ValueKey('open-profile-settings'),
            title: 'تنظیمات',
            icon: SolarIconsOutline.settings,
            onTap: onSettings,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ProfileAccountCompactAction(
                  title: 'پشتیبانی',
                  icon: SolarIconsOutline.headphonesRound,
                  onTap: onSupport,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileAccountCompactAction(
                  title: 'خروج',
                  icon: Icons.logout_rounded,
                  iconColor: AppColors.primary,
                  onTap: onLogout,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileAccountMenuTile extends StatelessWidget {
  const _ProfileAccountMenuTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(36),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 13,
              color: AppColors.secondary,
            ),
            const Spacer(),
            ReText(
              title,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            const SizedBox(width: 12),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.secondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAccountCompactAction extends StatelessWidget {
  const _ProfileAccountCompactAction({
    required this.title,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.black1,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(35),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 13,
              color: AppColors.black1,
            ),
            Expanded(
              child: ReText(
                title,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: iconColor == AppColors.primary ? const Color(0xFFFFECE8) : AppColors.gray1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: iconColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHomeShimmer extends StatefulWidget {
  const _ProfileHomeShimmer({
    required this.onSectionSelected,
  });

  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  State<_ProfileHomeShimmer> createState() => _ProfileHomeShimmerState();
}

class _ProfileHomeShimmerState extends State<_ProfileHomeShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _animation;

  @override
  void initState() {
    super.initState();
    _animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1350),
    )..repeat();
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('profile-loading-shimmer'),
      physics: const NeverScrollableScrollPhysics(),
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
                  onSectionSelected: widget.onSectionSelected,
                ).tMargin(20).hMargin(36),
                _ProfileSummaryShimmer(animation: _animation),
              ],
            ).bMargin(10),
          ),
          _ProfileAccountMenuShimmer(animation: _animation),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileSummaryShimmer extends StatelessWidget {
  const _ProfileSummaryShimmer({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('profile-summary-shimmer'),
      margin: const EdgeInsets.fromLTRB(16, 15, 16, 0),
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(32),
      ),
      child: _ProfileShimmerShader(
        animation: animation,
        child: Column(
          children: [
            const Row(
              textDirection: TextDirection.rtl,
              children: [
                _ProfileShimmerBox(
                  width: 56,
                  height: 56,
                  borderRadius: 12,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _ProfileShimmerBox(
                        width: 112,
                        height: 14,
                        borderRadius: 7,
                      ),
                      SizedBox(height: 9),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _ProfileShimmerBox(
                            width: 118,
                            height: 10,
                            borderRadius: 5,
                          ),
                          SizedBox(width: 10),
                          _ProfileShimmerBox(
                            width: 82,
                            height: 26,
                            borderRadius: 100,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(
                  child: _ProfileShimmerBox(
                    height: 62,
                    borderRadius: 30,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ProfileShimmerBox(
                    height: 62,
                    borderRadius: 30,
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

class _ProfileAccountMenuShimmer extends StatelessWidget {
  const _ProfileAccountMenuShimmer({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const ValueKey('profile-account-menu-shimmer'),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 0),
      child: _ProfileShimmerShader(
        animation: animation,
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProfileShimmerBox(
                  width: 92,
                  height: 36,
                  borderRadius: 100,
                ),
                _ProfileShimmerBox(
                  width: 86,
                  height: 17,
                  borderRadius: 9,
                ),
              ],
            ),
            SizedBox(height: 14),
            _ProfileShimmerBox(height: 72, borderRadius: 36),
            SizedBox(height: 10),
            _ProfileShimmerBox(height: 72, borderRadius: 36),
            SizedBox(height: 10),
            _ProfileShimmerBox(height: 72, borderRadius: 36),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ProfileShimmerBox(height: 70, borderRadius: 35),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _ProfileShimmerBox(height: 70, borderRadius: 35),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileShimmerShader extends StatelessWidget {
  const _ProfileShimmerShader({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final travel = animation.value * 3;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1.5 + travel, 0),
            end: Alignment(-0.5 + travel, 0),
            colors: const [
              Color(0xFFE3E5EA),
              Color(0xFFF8F9FB),
              Color(0xFFE3E5EA),
            ],
            stops: const [0.18, 0.5, 0.82],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

class _ProfileShimmerBox extends StatelessWidget {
  const _ProfileShimmerBox({
    this.width,
    required this.height,
    required this.borderRadius,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class _MiniAvatarStack extends StatelessWidget {
  const _MiniAvatarStack();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 34,
      child: Stack(
        children: [
          for (var index = 0; index < 3; index++)
            Positioned(
              right: index * 10,
              child: Container(
                width: 32,
                height: 32,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: index == 0 ? AppColors.secondary : AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: index == 0
                    ? const Icon(
                        SolarIconsBold.usersGroupRounded,
                        color: AppColors.white,
                        size: 15,
                      )
                    : const ClipOval(
                        child: ReImage(
                          Assets.profilePlaceholder,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProfileInfoSections extends StatelessWidget {
  const _ProfileInfoSections({
    required this.profile,
  });

  final ProfileUser? profile;

  @override
  Widget build(BuildContext context) {
    final interests = profile?.interests.isNotEmpty == true ? profile!.interests : const ['ریاضی', 'ورزش', 'هنر'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(36, 20, 36, 18),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(38),
          bottomRight: Radius.circular(38),
        ),
      ),
      child: Column(
        children: [
          _ProfileSectionHeading(
            title: 'بیوگرافی',
            icon: SolarIconsOutline.infoCircle,
          ),
          ReText(
            profile?.bio?.trim().isNotEmpty == true ? profile!.bio!.trim() : 'سلام! ${profile?.displayName ?? 'علیرضا یوسفی'} هستم. دانش آموز رشته ریاضی فیزیک! از مدرسه خواجه نصیر شهرستان چهرم.',
            color: AppColors.gray,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            lineHeight: 1.7,
            maxLines: 3,
          ).tMargin(10),
          Divider(color: AppColors.gray2, height: 30),
          _ProfileSectionHeading(
            title: 'علاقه مندی ها',
            icon: SolarIconsOutline.heart,
            iconColor: AppColors.errorColor,
          ),
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 8,
            runSpacing: 7,
            children: [
              for (final interest in interests)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: AppColors.gray2),
                  ),
                  child: ReText(
                    '#$interest',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ).tMargin(10),
        ],
      ),
    );
  }
}

class _ProfileSectionHeading extends StatelessWidget {
  const _ProfileSectionHeading({
    required this.title,
    required this.icon,
    this.iconColor = AppColors.secondary,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          children: [
            ReText(
              title,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            const SizedBox(width: 7),
            Icon(icon, color: iconColor, size: 17),
          ],
        ),
      ],
    );
  }
}

class _SuggestedProfilesSection extends StatelessWidget {
  const _SuggestedProfilesSection({
    required this.isRefreshing,
    required this.onRefresh,
  });

  final bool isRefreshing;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OutlinedProfileAction(
                  title: 'بروزرسانی',
                  icon: Icons.refresh_rounded,
                  onTap: isRefreshing ? () {} : onRefresh,
                ),
                const ReText(
                  'پیشنهادی',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              reverse: true,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) => _SuggestedProfileCard(index: index),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedProfileCard extends StatelessWidget {
  const _SuggestedProfileCard({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ClipOval(
            child: const ReImage(
              Assets.profilePlaceholder,
              width: 48,
              height: 48,
            ),
          ),
          const SizedBox(height: 7),
          ReText(
            index.isEven ? 'علیرضا یوسفی' : 'علیرضا یوسفی',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Container(
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(100),
            ),
            child: const ReText(
              'افزودن',
              color: AppColors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsSection extends StatelessWidget {
  const _AchievementsSection();

  @override
  Widget build(BuildContext context) {
    const achievements = [
      ('۳ پیروزی در لیگ', '۳ بار پیروزی اول لیگ های مختلف را کسب کنید.'),
      ('مدال وفاداری', 'یک سال فعالیت در سیمو'),
      ('شکست ناپذیر', 'پیروزی در ۱۰ دوئل'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 14, 36, 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _OutlinedProfileAction(
                title: 'مشاهده همه',
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: _noop,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: ReText(
                  'دستاورد ها 33',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < achievements.length; index++) ...[
            _AchievementTile(
              title: achievements[index].$1,
              subtitle: achievements[index].$2,
              icon: index == 0
                  ? SolarIconsBold.cupFirst
                  : index == 1
                      ? SolarIconsBold.suitcase
                      : SolarIconsBold.medalRibbonStar,
            ),
            if (index != achievements.length - 1) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD45F),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.simoCoin, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  title,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                ),
                ReText(
                  subtitle,
                  fontSize: 8.5,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatusSection extends StatelessWidget {
  const _ProfileStatusSection({required this.profile});

  final ProfileUser? profile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 18, 36, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const ReText(
            'خلاصه وضعیت',
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2.45,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              _ProfileStatusCard(
                value: '+3333',
                label: 'تسک انجام شده',
                color: AppColors.done,
                icon: Icons.check_rounded,
              ),
              _ProfileStatusCard(
                value: '13 روز',
                label: 'شرکت در لیگ',
                color: AppColors.secondary,
                icon: SolarIconsBold.cupFirst,
              ),
              _ProfileStatusCard(
                value: '+880',
                label: 'مجموع تمرکز',
                color: AppColors.primary,
                icon: Icons.timer_rounded,
              ),
              _ProfileStatusCard(
                value: '+117',
                label: 'چالش انجام شده',
                color: AppColors.simoCoin,
                icon: Icons.check_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileStatusCard extends StatelessWidget {
  const _ProfileStatusCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.white, size: 19),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  value,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                ),
                ReText(
                  label,
                  fontSize: 8,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _noop() {}

Future<void> _confirmProfileLogout(BuildContext context) async {
  final authCubit = context.read<AuthCubit>();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: AppColors.errorColor,
                size: 26,
              ),
            ),
            const SizedBox(height: 16),
            const ReText(
              'خروج از حساب کاربری',
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
            const SizedBox(height: 8),
            const ReText(
              'آیا از خروج از حساب کاربری خود مطمئن هستید؟',
              fontSize: 12.5,
              color: AppColors.gray,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: ReButton(
                    text: 'انصراف',
                    isOutlined: true,
                    color: AppColors.gray2,
                    textColor: AppColors.black1,
                    height: 48,
                    fontSize: 13,
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ReButton(
                    text: 'خروج',
                    background: AppColors.errorColor,
                    height: 48,
                    fontSize: 13,
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  if (confirmed == true) await authCubit.logout();
}

class _ProfileSettingsContent extends StatefulWidget {
  const _ProfileSettingsContent({
    required this.profile,
    required this.onBack,
    required this.onSectionSelected,
  });

  final ProfileUser? profile;
  final VoidCallback onBack;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  State<_ProfileSettingsContent> createState() => _ProfileSettingsContentState();
}

class _ProfileSettingsContentState extends State<_ProfileSettingsContent> {
  static const _notificationsKey = 'profile_notifications_enabled';
  static const _newsKey = 'profile_news_enabled';

  bool _notificationsEnabled = true;
  bool _newsEnabled = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = preferences.getBool(_notificationsKey) ?? true;
      _newsEnabled = preferences.getBool(_newsKey) ?? false;
    });
  }

  void _reset() {
    setState(() {
      _notificationsEnabled = true;
      _newsEnabled = false;
    });
  }

  Future<void> _save() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.wait([
      preferences.setBool(_notificationsKey, _notificationsEnabled),
      preferences.setBool(_newsKey, _newsEnabled),
    ]);
    if (!mounted) return;
    showReToast(context, 'تنظیمات ذخیره شد', ReToastType.success);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _ProfileTopCard(
            profile: widget.profile,
            selectedSection: ProfileContentSection.settings,
            onSectionSelected: widget.onSectionSelected,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: _reset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: AppColors.gray2),
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: [
                              Icon(
                                Icons.replay_rounded,
                                size: 16,
                                color: AppColors.gray,
                              ),
                              SizedBox(width: 7),
                              ReText(
                                'بازگشت به پیش فرض',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const ReText(
                  'تنظیمات',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.035),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _SettingsRow(
                  title: 'اعلان ها',
                  subtitle: 'نمایش یا عدم نمایش اعلان ها',
                  trailing: _SettingsToggle(
                    value: _notificationsEnabled,
                    onChanged: (value) => setState(() => _notificationsEnabled = value),
                  ),
                ),
                const SizedBox(height: 10),
                _SettingsRow(
                  title: 'اخبار ها',
                  subtitle: 'نمایش یا عدم نمایش اعلان ها',
                  trailing: _SettingsToggle(
                    value: _newsEnabled,
                    onChanged: (value) => setState(() => _newsEnabled = value),
                  ),
                ),
                const SizedBox(height: 10),
                AppVersionWidget(),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _SettingsActionButton(
                        title: 'ذخیره',
                        icon: SolarIconsOutline.checkSquare,
                        isPrimary: true,
                        onTap: _save,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SettingsActionButton(
                        title: 'لغو تغییرات',
                        icon: Icons.close_rounded,
                        onTap: widget.onBack,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class AppVersionWidget extends StatefulWidget {
  const AppVersionWidget({
    super.key,
  });

  @override
  State<AppVersionWidget> createState() => _AppVersionWidgetState();
}

class _AppVersionWidgetState extends State<AppVersionWidget> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    if (!mounted) return;

    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_version.isEmpty) {
      return const SizedBox.shrink();
    }

    return _SettingsRow(
      title: 'نسخه $_version',
      subtitle: 'نسخه اپلیکیشن',
    );
  }
}

class _AccountDetailsContent extends StatefulWidget {
  const _AccountDetailsContent({
    required this.profile,
    required this.onBack,
    required this.onSectionSelected,
    required this.onSave,
  });

  final ProfileUser? profile;
  final VoidCallback onBack;
  final ValueChanged<ProfileContentSection> onSectionSelected;
  final Future<ProfileUser> Function({
    required String fullName,
    required String username,
    required DateTime birthDate,
    String? major,
  }) onSave;

  @override
  State<_AccountDetailsContent> createState() => _AccountDetailsContentState();
}

class _AccountDetailsContentState extends State<_AccountDetailsContent> {
  Future<void> _showEditSheet() async {
    final profile = widget.profile;
    if (profile == null) return;
    await showReModalBottomSheet<void>(
      context: context,
      barrierColor: AppColors.white.withOpacity(0.56),
      builder: (sheetContext) => _ProfileEditSheet(
        profile: profile,
        onSave: widget.onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      child: Column(
        children: [
          _ProfileTopCard(
            profile: profile,
            selectedSection: ProfileContentSection.accountDetails,
            onSectionSelected: widget.onSectionSelected,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _OutlinedProfileAction(
                  key: const ValueKey('open-profile-edit-sheet'),
                  title: 'ویرایش',
                  icon: IconsaxPlusLinear.edit,
                  onTap: _showEditSheet,
                ),
                const ReText(
                  'مشخصات حساب',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              children: [
                _ProfileDetailsRow(
                  title: 'نام و نام خانوادگی',
                  value: profile?.displayName ?? '—',
                ),
                const SizedBox(height: 8),
                _ProfileDetailsRow(
                  title: 'شماره تماس',
                  value: _profilePhoneLabel(profile?.phoneNumber),
                ),
                const SizedBox(height: 8),
                _ProfileDetailsRow(
                  title: 'رشته، شغل، حوزه و ...',
                  value: profile?.major?.trim().isNotEmpty == true ? profile!.major!.trim() : 'ثبت نشده',
                ),
                const SizedBox(height: 8),
                _ProfileDetailsRow(
                  title: 'تاریخ تولد',
                  value: _profileBirthDateLabel(profile?.birthDate),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileDetailsRow extends StatelessWidget {
  const _ProfileDetailsRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ReText(
            title,
            fontSize: 11.5,
            color: AppColors.gray,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 4),
          ReText(
            value,
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.profile,
    required this.onSave,
  });

  final ProfileUser profile;
  final Future<ProfileUser> Function({
    required String fullName,
    required String username,
    required DateTime birthDate,
    String? major,
  }) onSave;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  DateTime? _birthDate;
  String? _major;
  String? _nameError;
  String? _birthDateError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final parts = _profileFullNameParts(widget.profile.fullName);
    _firstNameController = TextEditingController(text: parts.$1);
    _lastNameController = TextEditingController(text: parts.$2);
    _birthDate = widget.profile.birthDate?.toLocal();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _pickMajor() async {
    final selected = await showReModalBottomSheet<String>(
      context: context,
      isScrollControlled: false,
      builder: (sheetContext) => _ProfileMajorPicker(
        selected: _major ?? widget.profile.major,
      ),
    );
    if (selected == null || !mounted) return;
    setState(() => _major = selected);
  }

  Future<void> _pickBirthDate() async {
    final initialDate = _birthDate == null ? Jalali.now() : Jalali.fromDateTime(_birthDate!);
    final selected = await showReModalBottomSheet<Jalali>(
      context: context,
      isScrollControlled: false,
      builder: (_) => BirthDatePickerBottomSheet(initialDate: initialDate),
    );
    if (selected == null || !mounted) return;
    setState(() {
      _birthDate = selected.toGregorian().toDateTime();
      _birthDateError = null;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;
    final fullName = [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
    final birthDate = _birthDate;

    setState(() {
      _nameError = isValidPersianFullName(fullName) ? null : 'نام و نام خانوادگی را به فارسی وارد کنید.';
      _birthDateError = birthDate == null ? 'تاریخ تولد را انتخاب کنید.' : null;
    });
    if (_nameError != null || _birthDateError != null) return;

    setState(() => _isSaving = true);
    try {
      await widget.onSave(
        fullName: fullName,
        username: widget.profile.username,
        birthDate: birthDate!,
        major: _major ?? widget.profile.major,
      );
      if (!mounted) return;
      showReToast(context, 'مشخصات حساب ذخیره شد', ReToastType.success);
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    final sheetHeight = math.min(
      610.0,
      math.max(480.0, screenHeight * 0.63 - keyboardHeight),
    );

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        key: const ValueKey('profile-edit-sheet'),
        height: sheetHeight,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(34),
            topRight: Radius.circular(34),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                width: 62,
                height: 5,
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(28, 22, 28, 20),
                  child: Column(
                    children: [
                      _ProfileEditSheetHeader(
                        onClose: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ReTextField(
                              key: const ValueKey('profile-last-name-field'),
                              controller: _lastNameController,
                              placeholder: 'نام خانوادگی',
                              maxLength: 40,
                              height: 56,
                              borderRadius: 100,
                              backgroundColor: AppColors.gray1,
                              showFocusShadow: false,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                              onChanged: (_) => setState(() => _nameError = null),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ReTextField(
                              key: const ValueKey('profile-first-name-field'),
                              controller: _firstNameController,
                              placeholder: 'نام',
                              maxLength: 40,
                              height: 56,
                              borderRadius: 100,
                              backgroundColor: AppColors.gray1,
                              showFocusShadow: false,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 18),
                              onChanged: (_) => setState(() => _nameError = null),
                            ),
                          ),
                        ],
                      ),
                      if (_nameError != null)
                        ReText(
                          _nameError!,
                          color: AppColors.errorColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ).tMargin(5),
                      const SizedBox(height: 10),
                      _ProfileEditReadOnlyField(
                        key: const ValueKey('profile-phone-number-field'),
                        label: 'شماره تماس',
                        value: _profilePhoneLabel(widget.profile.phoneNumber),
                      ),
                      const SizedBox(height: 10),
                      _ProfileEditSelector(
                        key: const ValueKey('profile-major-field'),
                        label: _major ?? 'انتخاب رشته، شغل و ...',
                        onTap: _pickMajor,
                      ),
                      const SizedBox(height: 10),
                      _ProfileBirthDateEditor(
                        key: const ValueKey('profile-birth-date-field'),
                        onTap: _pickBirthDate,
                        currentDate: _birthDate ?? DateTime.now(),
                      ),
                      if (_birthDateError != null)
                        ReText(
                          _birthDateError!,
                          color: AppColors.errorColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ).tMargin(5),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ReButton(
                              key: const ValueKey('save-profile-edit'),
                              text: 'افزودن',
                              icon: Icons.add_rounded,
                              reverseIconPosition: true,
                              isLoading: _isSaving,
                              onPressed: _save,
                              height: 54,
                              borderRadius: 100,
                              background: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 112,
                            child: ReButton(
                              text: 'لغو',
                              icon: Icons.close_rounded,
                              reverseIconPosition: true,
                              onPressed: () => Navigator.of(context).pop(),
                              height: 54,
                              borderRadius: 100,
                              isOutlined: true,
                              background: AppColors.white,
                              color: AppColors.gray2,
                              textColor: AppColors.black1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileEditSheetHeader extends StatelessWidget {
  const _ProfileEditSheetHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ReText(
                    'ویرایش مشخصات',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  SizedBox(height: 4),
                  ReText(
                    'مشخصات حساب کاربری خود را ویرایش کنید.',
                    color: AppColors.gray,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gray2),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.gray,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileEditReadOnlyField extends StatelessWidget {
  const _ProfileEditReadOnlyField({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          ReText(
            value,
            isPersian: false,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          const Spacer(),
          ReText(
            label,
            color: AppColors.gray,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _ProfileEditSelector extends StatelessWidget {
  const _ProfileEditSelector({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 19,
              color: AppColors.black1,
            ),
            const Spacer(),
            ReText(
              label,
              color: AppColors.gray,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBirthDateEditor extends StatelessWidget {
  const _ProfileBirthDateEditor({
    super.key,
    required this.onTap,
    required this.currentDate,
  });

  final VoidCallback onTap;
  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 112,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const ReText(
              'تاریخ تولد',
              color: AppColors.gray,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ).rMargin(8),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _ProfileDatePart(label: 'سال: ${Jalali.fromDateTime(currentDate).year}')),
                const SizedBox(width: 8),
                Expanded(child: _ProfileDatePart(label: 'ماه: ${Jalali.fromDateTime(currentDate).month}')),
                const SizedBox(width: 8),
                Expanded(child: _ProfileDatePart(label: 'روز: ${Jalali.fromDateTime(currentDate).day}')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDatePart extends StatelessWidget {
  const _ProfileDatePart({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AppColors.black1,
          ),
          const Spacer(),
          ReText(
            label,
            color: AppColors.gray,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _ProfileMajorPicker extends StatelessWidget {
  const _ProfileMajorPicker({required this.selected});

  final String? selected;

  static const _options = [
    'ریاضی فیزیک',
    'علوم تجربی',
    'علوم انسانی',
    'هنر',
    'شاغل',
    'سایر',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const ReText(
              'انتخاب رشته، شغل یا حوزه',
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ).vMargin(18),
            for (final option in _options)
              GestureDetector(
                onTap: () => Navigator.of(context).pop(option),
                child: Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: option == selected ? AppColors.primary.withOpacity(0.08) : AppColors.gray1,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReText(
                        option,
                        color: option == selected ? AppColors.primary : AppColors.black1,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

(String, String) _profileFullNameParts(String? fullName) {
  final parts = (fullName ?? '').trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
  if (parts.isEmpty) return ('', '');
  if (parts.length == 1) return (parts.first, '');
  return (parts.first, parts.skip(1).join(' '));
}

String _profilePhoneLabel(String? phoneNumber) {
  final value = phoneNumber?.trim() ?? '';
  return value.isEmpty ? 'ثبت نشده' : value;
}

String _profileBirthDateLabel(DateTime? birthDate) {
  if (birthDate == null) return 'ثبت نشده';
  final jalali = Jalali.fromDateTime(birthDate.toLocal());
  return '${jalali.year}/${jalali.month}/${jalali.day}';
}

class _ProfileTopCard extends StatelessWidget {
  const _ProfileTopCard({
    required this.profile,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  final ProfileUser? profile;
  final ProfileContentSection selectedSection;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(42),
          bottomRight: Radius.circular(42),
        ),
      ),
      child: Column(
        children: [
          reAppHeader(
            'پروفایل',
            prefixIcon: GestureDetector(
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(SolarIconsOutline.bell, size: 24),
              ),
            ),
            suffixIcon: GestureDetector(
              child: const SizedBox(
                width: 48,
                height: 48,
                child: Icon(SolarIconsOutline.chatRoundLine, size: 24),
              ),
            ),
          ),
          _ProfileSummaryCard(profile: profile),
        ],
      ).bMargin(12),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Row(
        children: [
          if (trailing != null) trailing!,
          if (trailing != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  title,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
                const SizedBox(height: 3),
                ReText(
                  subtitle,
                  fontSize: 11.5,
                  color: AppColors.gray,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  const _SettingsToggle({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 180),
          alignment: value ? Alignment.centerLeft : Alignment.centerRight,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : AppColors.white,
              shape: BoxShape.circle,
              border: value ? null : Border.all(color: AppColors.gray),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsActionButton extends StatelessWidget {
  const _SettingsActionButton({
    required this.title,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary.withOpacity(0.10) : AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isPrimary ? AppColors.primary.withOpacity(0.08) : AppColors.gray2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isPrimary ? AppColors.primary : AppColors.gray,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: ReText(
                title,
                color: isPrimary ? AppColors.primary : AppColors.black1,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutlinedProfileAction extends StatelessWidget {
  const _OutlinedProfileAction({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.gray),
            const SizedBox(width: 7),
            ReText(
              title,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
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

class _FriendsContentState extends State<_FriendsContent> with WidgetsBindingObserver {
  final TextEditingController _usernameController = TextEditingController();
  late final FriendshipRepository _friendshipRepository;
  late final ChatRepository _chatRepository;
  late final InboxSubscriptionClient _inboxClient;
  StreamSubscription<InboxEvent>? _eventSubscription;
  var _friends = <FriendshipItem>[];
  final _activityByUserID = <String, UserActivity>{};
  final _unreadByUserID = <String, int>{};
  final _chatUserByChatID = <String, String>{};
  CurrentFriendshipUser? _currentUser;
  Timer? _refreshTimer;
  Future<void>? _friendshipsLoadFuture;
  String? _error;
  String? _busyTargetID;
  String? _activeChatUserID;
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
    _usernameController.dispose();
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
        _handleNewMessageEvent(event.message);
        return;
      }

      if (event is MessageSeenInboxEvent) {
        _handleMessageSeenEvent(event);
      }
    });
    _inboxClient.connect();
  }

  void _handleNewMessageEvent(ChatMessage message) {
    final currentUserID = _currentUser?.id;
    if (currentUserID == null || message.senderID == currentUserID) return;
    final isAcceptedFriend = _friends.any(
      (friend) => friend.relation == FriendshipRelation.accepted && friend.targetUserID == message.senderID,
    );
    if (!isAcceptedFriend) return;

    setState(() {
      _chatUserByChatID[message.chatID] = message.senderID;
      if (message.senderID == _activeChatUserID) {
        _unreadByUserID.remove(message.senderID);
      } else {
        _unreadByUserID[message.senderID] = (_unreadByUserID[message.senderID] ?? 0) + 1;
      }
    });
  }

  void _handleMessageSeenEvent(MessageSeenInboxEvent event) {
    final currentUserID = _currentUser?.id;
    if (currentUserID == null || event.userID != currentUserID) return;
    final targetUserID = _targetUserIDForChatID(event.chatID);
    if (targetUserID == null) return;

    setState(() {
      _unreadByUserID.remove(targetUserID);
    });
  }

  String? _targetUserIDForChatID(String chatID) {
    final mappedUserID = _chatUserByChatID[chatID];
    if (mappedUserID != null) return mappedUserID;
    return null;
  }

  Future<void> _loadFriendships({bool silent = false}) {
    final activeLoad = _friendshipsLoadFuture;
    if (activeLoad != null) return activeLoad;

    late final Future<void> loadFuture;
    loadFuture = _loadFriendshipsOnce(silent: silent).whenComplete(() {
      if (identical(_friendshipsLoadFuture, loadFuture)) {
        _friendshipsLoadFuture = null;
      }
    });
    _friendshipsLoadFuture = loadFuture;
    return loadFuture;
  }

  Future<void> _loadFriendshipsOnce({required bool silent}) async {
    if (!silent) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final currentUser = _currentUser ?? await _friendshipRepository.getCurrentUser();
      String? expandedID;
      for (final friend in _friends) {
        if (friend.isExpanded) {
          expandedID = friend.id;
          break;
        }
      }
      final friendships = await _friendshipRepository.getFriendships(currentUser.id);
      if (!mounted) return;
      setState(() {
        _currentUser = currentUser;
        _friends = [
          for (final friendship in friendships) friendship.copyWith(isExpanded: friendship.id == expandedID),
        ];
        final acceptedIDs = friendships.where((friend) => friend.relation == FriendshipRelation.accepted).map((friend) => friend.targetUserID).toSet();
        _unreadByUserID.removeWhere(
          (userID, _) => !acceptedIDs.contains(userID),
        );
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

  Future<void> _openAddFriendSheet() async {
    final wasSent = await showReModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => _AddFriendBottomSheet(
        controller: _usernameController,
        currentUserID: _currentUser?.id,
        friendships: _friends,
        onSearch: _friendshipRepository.searchUsersByUsername,
        onSubmit: _sendFriendRequest,
      ),
    );
    if (!mounted || wasSent != true) return;
    showReToast(context, 'درخواست دوستی ارسال شد', ReToastType.success);
  }

  Future<void> _openConsultants() async {
    await context.to(const ConsultantListScreen());
  }

  Future<String?> _sendFriendRequest(UsernameSearchUser user) async {
    final currentUser = _currentUser;
    if (currentUser == null) return 'اطلاعات حساب کاربری در دسترس نیست.';
    if (_isSendingRequest) return 'درخواست قبلی در حال ارسال است.';

    if (currentUser.id == user.id) {
      return 'نمی‌توانید خودتان را به دوستان اضافه کنید.';
    }

    setState(() => _isSendingRequest = true);
    try {
      final friendship = await _friendshipRepository.sendFriendRequest(
        currentUserID: currentUser.id,
        targetUserID: user.id,
      );
      if (!mounted) return null;
      setState(() {
        _friends = _upsertFriendship(friendship.copyWith(isExpanded: true));
        _usernameController.clear();
      });
      return null;
    } catch (error) {
      return _friendlyProfileError(error);
    } finally {
      if (mounted) setState(() => _isSendingRequest = false);
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
    if (currentUser == null || _busyTargetID != null || friend.relation != FriendshipRelation.accepted) {
      return;
    }

    setState(() {
      _busyTargetID = friend.targetUserID;
      _activeChatUserID = friend.targetUserID;
      _unreadByUserID.remove(friend.targetUserID);
    });
    try {
      final chatID = await _chatRepository.createDirectChat(friend.targetUserID);
      if (!mounted) return;
      setState(() {
        _chatUserByChatID[chatID] = friend.targetUserID;
      });
      await context.to(
        ChatRoomScreen(
          chatID: chatID,
          currentUserID: currentUser.id,
          targetUserID: friend.targetUserID,
          title: friend.targetUser.displayName,
        ),
      );
      if (mounted) {
        setState(() {
          _busyTargetID = null;
          _activeChatUserID = null;
          _unreadByUserID.remove(friend.targetUserID);
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busyTargetID = null;
        _activeChatUserID = null;
      });
      showReToast(context, _friendlyProfileError(error), ReToastType.failed);
    }
  }

  Future<void> _openFriendProfile(FriendshipItem friend) async {
    await context.to(
      FriendProfileScreen(
        userID: friend.targetUserID,
        displayName: friend.targetUser.displayName,
        initialRelation: friend.relation,
      ),
    );
    if (mounted) await _loadFriendships(silent: true);
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FriendsTopPanel(
          onSearch: _openAddFriendSheet,
          onSectionSelected: widget.onSectionSelected,
        ),
        _ConsultationEntry(onTap: _openConsultants),
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
    final incoming = _friends.where((item) => item.relation == FriendshipRelation.incomingPending).toList();
    final outgoing = _friends.where((item) => item.relation == FriendshipRelation.outgoingPending).toList();
    final accepted = _friends.where((item) => item.relation == FriendshipRelation.accepted).toList();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadFriendships,
      child: ListView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(36, 8, 36, 28),
        children: [
          ..._buildFriendSection('درخواست‌های دریافتی', incoming),
          ..._buildFriendSection('درخواست‌های ارسال‌شده', outgoing),
          ..._buildFriendSection(
            'دوستان',
            accepted,
            showFriendsHeading: true,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFriendSection(String title, List<FriendshipItem> items, {bool showFriendsHeading = false}) {
    if (items.isEmpty && !showFriendsHeading) return const [];
    return [
      _FriendSectionTitle(
        title: title,
        count: items.length,
        showIcon: showFriendsHeading,
      ),
      for (final friend in items) ...[
        _FriendTile(
          friend: friend,
          activity: _activityByUserID[friend.targetUserID],
          isBusy: _busyTargetID == friend.targetUserID,
          onTap: () => _toggleFriend(friend),
          onOpenProfile: () => _openFriendProfile(friend),
          onMessage: () => _openChat(friend),
          unreadCount: _unreadByUserID[friend.targetUserID] ?? 0,
          onAccept: () => _acceptFriend(friend),
          onReject: () => _rejectFriend(friend),
          onCancel: () => _cancelFriend(friend),
          onDelete: () => _removeFriend(friend),
        ),
        Divider(height: 1, thickness: 1, color: AppColors.gray2.withOpacity(.7)),
      ],
      const SizedBox(height: 18),
    ];
  }
}

class _FriendSectionTitle extends StatelessWidget {
  const _FriendSectionTitle({
    required this.title,
    required this.count,
    this.showIcon = false,
  });

  final String title;
  final int count;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          if (showIcon) ...[
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                SolarIconsBold.usersGroupRounded,
                color: AppColors.secondary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          ReText(
            title,
            color: AppColors.black1,
            fontSize: showIcon ? 16 : 12,
            fontWeight: FontWeight.w900,
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8),
          ReText(
            convertToPersianNumbers(count.toString()),
            color: AppColors.black1.withOpacity(.45),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    ).bMargin(10);
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
    required this.unreadCount,
    required this.isBusy,
    required this.onTap,
    required this.onOpenProfile,
    required this.onMessage,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
    required this.onDelete,
  });

  final FriendshipItem friend;
  final UserActivity? activity;
  final int unreadCount;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onOpenProfile;
  final VoidCallback onMessage;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.fromLTRB(0, 6, 0, friend.isExpanded ? 10 : 6),
      child: Column(
        children: [
          _FriendTileHeader(
            friend: friend,
            activity: activity,
            unreadCount: unreadCount,
            onTap: onTap,
            onOpenProfile: onOpenProfile,
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: friend.isExpanded
                ? _FriendActions(
                    key: const ValueKey('friend-actions'),
                    friend: friend,
                    unreadCount: unreadCount,
                    isBusy: isBusy,
                    onMessage: onMessage,
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
    required this.unreadCount,
    required this.onTap,
    required this.onOpenProfile,
  });

  final FriendshipItem friend;
  final UserActivity? activity;
  final int unreadCount;
  final VoidCallback onTap;
  final VoidCallback onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final username = friend.targetUser.usernameLabel;
    return SizedBox(
      height: 66,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 52,
              height: 42,
              child: Row(
                children: [
                  Icon(
                    friend.isExpanded ? SolarIconsOutline.altArrowUp : SolarIconsOutline.altArrowLeft,
                    color: AppColors.black1.withOpacity(0.45),
                    size: 16,
                  ),
                  if (unreadCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      height: 24,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: ReText(
                        convertToPersianNumbers(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                        ),
                        color: AppColors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onOpenProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
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
                    if (username != null && friend.targetUser.hasFullName)
                      ReText(
                        username,
                        color: AppColors.black1.withOpacity(0.5),
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        isPersian: false,
                        textDirection: TextDirection.ltr,
                        textAlign: TextAlign.right,
                      ).tMargin(1),
                    SizedBox(
                      child: ReText(
                        _friendStatusText(friend, activity),
                        color: _friendStatusColor(friend, activity),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.end,
                      ),
                    ).tMargin(2),
                  ],
                ).rMargin(9),
                _FriendAvatar(
                  path: Assets.profilePlaceholder,
                  isOnline: activity?.isOnline == true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendAvatar extends StatelessWidget {
  const _FriendAvatar({
    required this.path,
    required this.isOnline,
  });

  final String path;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ReImage(path, fit: BoxFit.cover),
            ),
          ),
          if (isOnline)
            Positioned(
              top: -1,
              right: 2,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ConsultationEntry extends StatelessWidget {
  const _ConsultationEntry({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 22, 36, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              children: [
                _ConsultationIcon(),
                SizedBox(width: 8),
                ReText(
                  'مشاور',
                  color: AppColors.black1,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            key: const ValueKey('open-consultants'),
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: CustomPaint(
              painter: _DashedRoundedBorderPainter(
                color: AppColors.black1.withOpacity(.18),
                radius: 30,
              ),
              child: SizedBox(
                height: 76,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          SolarIconsOutline.userSpeak,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const Expanded(
                        child: ReText(
                          'هنوز مشاوری انتخاب نکردی!',
                          color: AppColors.black1,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ),
                      Container(
                        height: 46,
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(.035),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const ReText(
                              'انتخاب',
                              color: AppColors.black1,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              SolarIconsOutline.altArrowLeft,
                              color: AppColors.black1.withOpacity(.45),
                              size: 14,
                            ),
                          ],
                        ),
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

class _ConsultationIcon extends StatelessWidget {
  const _ConsultationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.1),
        borderRadius: BorderRadius.circular(9),
      ),
      child: const Icon(
        SolarIconsOutline.userSpeak,
        color: AppColors.primary,
        size: 18,
      ),
    );
  }
}

class _DashedRoundedBorderPainter extends CustomPainter {
  const _DashedRoundedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(radius),
        ),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 5, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRoundedBorderPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}

class _FriendActions extends StatelessWidget {
  const _FriendActions({
    super.key,
    required this.friend,
    required this.unreadCount,
    required this.isBusy,
    required this.onMessage,
    required this.onAccept,
    required this.onReject,
    required this.onCancel,
    required this.onDelete,
  });

  final FriendshipItem friend;
  final int unreadCount;
  final bool isBusy;
  final VoidCallback onMessage;
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
            title: _messageActionTitle(unreadCount),
            icon: SolarIconsBold.chatRound,
            color: AppColors.secondary,
            onTap: onMessage,
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
            title: 'قبول',
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

String _messageActionTitle(int unreadCount) {
  if (unreadCount <= 0) return 'پیام';
  final label = unreadCount > 99 ? '99+' : '$unreadCount';
  return 'پیام $label';
}

String _friendStatusText(FriendshipItem friend, UserActivity? activity) {
  if (friend.relation == FriendshipRelation.accepted) {
    final taskName = activity?.currentTaskName?.trim();
    if (taskName != null && taskName.isNotEmpty) {
      return 'درحال انجام $taskName';
    }
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
            ReText(
              title,
              color: AppColors.black1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ).rMargin(7),
          ],
        ),
      ),
    );
  }
}

typedef _SearchUsersByUsername = Future<List<UsernameSearchUser>> Function({
  required String query,
  int? limit,
  int? offset,
});

class _AddFriendBottomSheet extends StatefulWidget {
  const _AddFriendBottomSheet({
    required this.controller,
    required this.currentUserID,
    required this.friendships,
    required this.onSearch,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String? currentUserID;
  final List<FriendshipItem> friendships;
  final _SearchUsersByUsername onSearch;
  final Future<String?> Function(UsernameSearchUser user) onSubmit;

  @override
  State<_AddFriendBottomSheet> createState() => _AddFriendBottomSheetState();
}

class _AddFriendBottomSheetState extends State<_AddFriendBottomSheet> {
  static const _pageSize = 20;
  static const _minimumQueryLength = 3;
  static const _searchDebounce = Duration(milliseconds: 700);
  static const _rateLimitWindow = Duration(minutes: 1);
  static const _maxRequestsPerWindow = 25;

  final _searchCache = <String, List<UsernameSearchUser>>{};
  final _hasMoreCache = <String, bool>{};
  final _searchRequestTimes = <DateTime>[];
  Timer? _searchTimer;
  List<UsernameSearchUser> _results = const [];
  String? _error;
  String? _submittingUserID;
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _hasMore = false;
  int _searchRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.trim().length >= _minimumQueryLength) {
      _scheduleSearch(widget.controller.text);
    }
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    super.dispose();
  }

  String get _query => widget.controller.text.trim();

  Map<String, FriendshipRelation> get _relationsByUserID => {
        for (final friendship in widget.friendships) friendship.targetUserID: friendship.relation,
      };

  void _scheduleSearch(String value) {
    _searchTimer?.cancel();
    _searchRevision += 1;
    final query = value.trim();

    if (query.length < _minimumQueryLength || !hasValidUsernameCharacters(query)) {
      setState(() {
        _results = const [];
        _error = null;
        _isSearching = false;
        _hasSearched = false;
        _hasMore = false;
      });
      return;
    }

    final cached = _searchCache[query];
    if (cached != null) {
      setState(() {
        _results = cached;
        _error = null;
        _isSearching = false;
        _hasSearched = true;
        _hasMore = _hasMoreCache[query] ?? false;
      });
      return;
    }

    setState(() {
      _error = null;
      _isSearching = true;
      _hasSearched = false;
      _hasMore = false;
    });
    final revision = _searchRevision;
    _searchTimer = Timer(
      _searchDebounce,
      () => _search(query: query, revision: revision, reset: true),
    );
  }

  bool _canMakeSearchRequest() {
    final now = DateTime.now();
    _searchRequestTimes.removeWhere(
      (requestTime) => now.difference(requestTime) >= _rateLimitWindow,
    );
    if (_searchRequestTimes.length >= _maxRequestsPerWindow) return false;
    _searchRequestTimes.add(now);
    return true;
  }

  Future<void> _search({
    required String query,
    required int revision,
    required bool reset,
  }) async {
    if (!mounted || query != _query || revision != _searchRevision) return;
    if (!reset && (_isSearching || !_hasMore)) return;
    if (!_canMakeSearchRequest()) {
      setState(() {
        _isSearching = false;
        _error = 'تعداد جست‌وجوها زیاد شده است؛ لطفاً یک دقیقه دیگر دوباره تلاش کنید.';
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final offset = reset ? 0 : _results.length;
      final page = await widget.onSearch(
        query: query,
        limit: _pageSize,
        offset: offset,
      );
      if (!mounted || query != _query || revision != _searchRevision) return;

      final usersByID = <String, UsernameSearchUser>{
        if (!reset)
          for (final user in _results) user.id: user,
        for (final user in page) user.id: user,
      };
      final results = usersByID.values.toList(growable: false);
      _searchCache[query] = results;
      _hasMoreCache[query] = page.length == _pageSize;
      setState(() {
        _results = results;
        _isSearching = false;
        _hasSearched = true;
        _hasMore = _hasMoreCache[query]!;
      });
    } catch (error) {
      if (!mounted || query != _query || revision != _searchRevision) return;
      setState(() {
        _isSearching = false;
        _hasSearched = true;
        _error = _friendlyProfileError(error);
      });
    }
  }

  Future<void> _submit(UsernameSearchUser user) async {
    if (_submittingUserID != null || _relationFor(user.id) != null) return;
    setState(() {
      _submittingUserID = user.id;
      _error = null;
    });
    final error = await widget.onSubmit(user);
    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop(true);
      return;
    }
    setState(() {
      _submittingUserID = null;
      _error = error;
    });
  }

  FriendshipRelation? _relationFor(String userID) => _relationsByUserID[userID];

  String? _resultStatus(String userID) {
    if (userID == widget.currentUserID) return 'حساب شما';
    return switch (_relationFor(userID)) {
      FriendshipRelation.accepted => 'دوست شما',
      FriendshipRelation.incomingPending => 'درخواست دریافت‌شده',
      FriendshipRelation.outgoingPending => 'در انتظار تایید',
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight = mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        height: availableHeight * 0.82,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
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
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              _buildHeader(),
              ReTextField(
                controller: widget.controller,
                autofocus: true,
                placeholder: 'نام کاربری را وارد کنید',
                inputTextAlign: TextAlign.left,
                placeholderAlign: TextAlign.right,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                icon: Icons.search_rounded,
                onChanged: _scheduleSearch,
                onFieldSubmitted: (value) {
                  _searchTimer?.cancel();
                  final query = value.trim();
                  if (query.length < _minimumQueryLength || !hasValidUsernameCharacters(query)) {
                    return;
                  }
                  _search(
                    query: query,
                    revision: _searchRevision,
                    reset: true,
                  );
                },
                inputFormatters: [LengthLimitingTextInputFormatter(64)],
                height: 48,
                backgroundColor: AppColors.gray1,
                borderRadius: 100,
                showFocusShadow: false,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18),
              ).tMargin(22),
              Expanded(child: _buildSearchBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
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
              'دوستتان را با نام کاربری پیدا کنید',
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
            onTap: _submittingUserID == null ? () => Navigator.of(context).pop(false) : null,
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
    );
  }

  Widget _buildSearchBody() {
    if (_query.length < _minimumQueryLength) {
      return _searchHint('برای جست‌وجو حداقل ۳ کاراکتر وارد کنید.');
    }
    if (!hasValidUsernameCharacters(_query)) {
      return _searchHint(
        'نام کاربری را با حروف انگلیسی، عدد و _ جست‌وجو کنید.',
        isError: true,
      );
    }
    if (_isSearching && _results.isEmpty) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_error != null && _results.isEmpty) {
      return _searchHint(_error!, isError: true);
    }
    if (_hasSearched && _results.isEmpty) {
      return _searchHint('کاربری با این نام کاربری پیدا نشد.');
    }

    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      itemCount: _results.length + (_hasMore || _isSearching ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        if (index == _results.length) return _buildLoadMore();
        return _buildSearchResult(_results[index]);
      },
    );
  }

  Widget _searchHint(String text, {bool isError = false}) {
    return Center(
      child: ReText(
        text,
        color: isError ? AppColors.errorColor : AppColors.black1.withOpacity(0.55),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        textAlign: TextAlign.center,
        maxLines: 4,
      ).hMargin(18),
    );
  }

  Widget _buildSearchResult(UsernameSearchUser user) {
    final status = _resultStatus(user.id);
    final isSelf = user.id == widget.currentUserID;
    final isDisabled = isSelf || status != null;
    final isSubmitting = _submittingUserID == user.id;
    return GestureDetector(
      onTap: isSelf
          ? null
          : () => context.to(
                FriendProfileScreen(
                  userID: user.id,
                  displayName: user.displayName,
                  initialRelation: _relationFor(user.id),
                ),
              ),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: ReButton(
                text: status ?? 'ارسال درخواست',
                onPressed: isDisabled || _submittingUserID != null ? null : () => _submit(user),
                isLoading: isSubmitting,
                background: isDisabled ? AppColors.gray2 : AppColors.primary,
                height: 38,
                borderRadius: 16,
                fontSize: 10,
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ReText(
                    user.displayName,
                    color: AppColors.black1,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    maxLines: 1,
                  ),
                  ReText(
                    '@${user.username}',
                    color: AppColors.black1.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    textAlign: TextAlign.left,
                    isPersian: false,
                    maxLines: 1,
                  ).tMargin(2),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(100),
              ),
              child: const Icon(
                SolarIconsOutline.user,
                color: AppColors.secondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadMore() {
    if (_isSearching) {
      return const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }
    return Center(
      child: SizedBox(
        width: 140,
        child: ReButton(
          text: 'نمایش بیشتر',
          onPressed: () => _search(
            query: _query,
            revision: _searchRevision,
            reset: false,
          ),
          height: 42,
          borderRadius: 18,
          fontSize: 12,
          background: AppColors.secondary,
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
    required this.onSearch,
    required this.onSectionSelected,
  });

  final VoidCallback onSearch;
  final ValueChanged<ProfileContentSection> onSectionSelected;

  @override
  Widget build(BuildContext context) {
    return _ProfileSectionTopPanel(
      title: 'پیام‌ها',
      selectedSection: ProfileContentSection.friends,
      onSectionSelected: onSectionSelected,
      bottom: ReSearchPill(
        onTap: onSearch,
        height: 56,
        horizontalPadding: 22,
      ).hMargin(36).tMargin(18),
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
    final usesCompactProfileHeader = selectedSection == ProfileContentSection.profile || selectedSection == ProfileContentSection.accountDetails || selectedSection == ProfileContentSection.settings;

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
              showBadge: false,
            ),
            if (!usesCompactProfileHeader) ...[
              _HeaderActionIcon(
                icon: SolarIconsOutline.chatRound,
                section: ProfileContentSection.friends,
                selectedSection: selectedSection,
                onTap: onSectionSelected,
                showBadge: true,
              ),
              _HeaderActionIcon(
                icon: Icons.sports_martial_arts_rounded,
                section: ProfileContentSection.competition,
                selectedSection: selectedSection,
                onTap: onSectionSelected,
              ),
            ],
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
          color: isSelected ? AppColors.black1 : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.white : AppColors.black1,
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
  const _ProfileSummaryCard({required this.profile});

  final ProfileUser? profile;

  @override
  Widget build(BuildContext context) {
    final isPremium = profile?.isPremium ?? false;
    final simoCoins = profile?.simoCoins ?? 0;
    final score = profile?.score ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 15),
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: AppColors.gray1,
      ),
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              GestureDetector(
                onTap: () async {
                  final avatarUrl = await showReModalBottomSheet<String>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) {
                      return ProfileAvatarBottomSheet(
                        currentImageUrl: profile?.avatarURL ?? Assets.profilePlaceholder,
                        onUpload: ({
                          required Uint8List imageBytes,
                          required String fileName,
                        }) {
                          return context.read<ProfileCubit>().uploadProfileImage(
                                imageBytes: imageBytes,
                                fileName: fileName,
                              );
                        },
                      );
                    },
                  );
                },
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: ReImage(
                        profile?.avatarURL ?? Assets.profilePlaceholder,
                        fit: BoxFit.cover,
                        width: 56,
                        height: 56,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: AppColors.black1.withAlpha(100), borderRadius: BorderRadius.circular(10)),
                      child: Icon(IconsaxPlusBroken.edit, size: 14,color: AppColors.gray2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ReText(
                      profile?.displayName ?? 'علیرضا یوسفی',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ReText(
                            isPremium ? '${isPremium ? 24 : 0} روز تا پایان اشتراک ویژه' : 'اشتراک ندارید',
                            color: AppColors.gray,
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.simoCoin,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ReText(
                                isPremium ? 'کاربر ویژه' : 'کاربر عادی',
                                fontSize: 11.5,
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                SolarIconsOutline.stars,
                                size: 14,
                                color: AppColors.white,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ProfileMetricCard(
                  value: '$score×',
                  label: 'ضریب امتیاز',
                  color: Color(0xFFFF3040),
                  icon: SvgPicture.asset('assets/icons/flame.svg'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ProfileMetricCard(
                  value: '$simoCoins',
                  label: 'سایموکوین',
                  color: const Color(0xFFFFC94C),
                  icon: SvgPicture.asset('assets/icons/simo_coin.svg', color: Color(0xffe56929)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMetricCard extends StatelessWidget {
  const _ProfileMetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  final String value;
  final String label;
  final Color color;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              SolarIconsOutline.infoCircle,
              size: 15,
              color: AppColors.black1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  value,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  maxLines: 1,
                ),
                ReText(
                  label,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: icon,
          ),
        ],
      ),
    );
  }
}

class _FriendsEmptyIllustration extends StatelessWidget {
  const _FriendsEmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return const ReImage(
      'assets/images/empty_list_friends.png',
      fit: BoxFit.contain,
    );
  }
}

String _friendlyProfileError(Object error) {
  final text = error.toString();
  final upperText = text.toUpperCase();
  if (text.contains('Unauthorized') || text.contains('Authentication')) {
    return 'برای ادامه دوباره وارد حساب شوید.';
  }
  if (upperText.contains('RATE_LIMIT') || upperText.contains('TOO MANY REQUESTS') || upperText.contains('429')) {
    return 'تعداد درخواست‌ها زیاد شده است؛ لطفاً یک دقیقه دیگر تلاش کنید.';
  }
  if (upperText.contains('USER_NOT_FOUND') || upperText.contains('USER NOT FOUND')) {
    return 'کاربری با این نام کاربری پیدا نشد.';
  }
  if (upperText.contains('CANNOT_ADD_SELF')) {
    return 'نمی‌توانید خودتان را به دوستان اضافه کنید.';
  }
  if (upperText.contains('ALREADY_FRIENDS')) {
    return 'این کاربر از قبل در فهرست دوستان شماست.';
  }
  if (upperText.contains('REQUEST_ALREADY_SENT')) {
    return 'درخواست دوستی قبلاً ارسال شده است.';
  }
  if (upperText.contains('UUID')) {
    return 'انجام درخواست دوستی ناموفق بود.';
  }
  if (text.trim().isEmpty) return 'خطای ناشناخته رخ داد.';
  return text.replaceFirst('Exception: ', '');
}

class ProfileAvatarBottomSheet extends StatefulWidget {
  const ProfileAvatarBottomSheet({
    super.key,
    required this.currentImageUrl,
    required this.onUpload,
  });

  final String? currentImageUrl;

  /// Receives the cropped image bytes and returns the uploaded avatar URL.
  final Future<String> Function({
    required Uint8List imageBytes,
    required String fileName,
  }) onUpload;

  @override
  State<ProfileAvatarBottomSheet> createState() => _ProfileAvatarBottomSheetState();
}

class _ProfileAvatarBottomSheetState extends State<ProfileAvatarBottomSheet> {
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _newImageBytes;
  String? _newFileName;

  bool _isPicking = false;
  bool _isSaving = false;

  bool get _hasChanges => _newImageBytes != null;

  Future<void> _editImage() async {
    if (_isPicking || _isSaving) return;

    setState(() => _isPicking = true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        if (mounted) {
          setState(() => _isPicking = false);
        }
        return;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'ویرایش تصویر',
            toolbarColor: AppColors.white,
            toolbarWidgetColor: AppColors.black1,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'ویرایش تصویر',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
          ),
          WebUiSettings(
            context: context,
            presentStyle: WebPresentStyle.dialog,
            size: const CropperSize(
              width: 500,
              height: 500,
            ),
          ),
        ],
      );

      if (croppedFile == null) {
        if (mounted) {
          setState(() => _isPicking = false);
        }
        return;
      }

      final bytes = await croppedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        _newImageBytes = bytes;
        _newFileName = pickedFile.name;
        _isPicking = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _isPicking = false);

      showReToast(
        context,
        'انتخاب تصویر با خطا مواجه شد',
        ReToastType.failed,
      );
    }
  }

  Future<void> _save() async {
    if (_isSaving || _newImageBytes == null) return;

    setState(() => _isSaving = true);

    try {
      final avatarUrl = await widget.onUpload(
        imageBytes: _newImageBytes!,
        fileName: _newFileName ?? 'avatar.jpg',
      );

      if (!mounted) return;

      showReToast(
        context,
        'تصویر پروفایل با موفقیت ذخیره شد',
        ReToastType.success,
      );

      try {
        await context.read<ProfileCubit>().getMe(
          forceRefresh: true,
        );
      } catch (error) {
        if (!mounted) return;
        showReToast(context, _friendlyProfileError(error), ReToastType.failed);
      }

      Navigator.of(context).pop(avatarUrl);
    } catch (error) {
      if (!mounted) return;

      setState(() => _isSaving = false);

      showReToast(
        context,
        _friendlyAvatarError(error),
        ReToastType.failed,
      );
    }
  }

  String _friendlyAvatarError(Object error) {
    final message = error.toString();

    if (message.contains('Access token')) {
      return 'نشست شما منقضی شده است.';
    }

    if (message.contains('Failed to upload')) {
      return 'آپلود تصویر با خطا مواجه شد.';
    }

    return 'ذخیره تصویر با خطا مواجه شد.';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    final sheetHeight = screenHeight < 700 ? screenHeight * 0.78 : math.min(620.0, screenHeight * 0.68);

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(34),
          topRight: Radius.circular(34),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 62,
              height: 5,
              margin: const EdgeInsets.only(top: 0),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  28,
                  22,
                  28,
                  20,
                ),
                child: Column(
                  children: [
                    _ProfileAvatarSheetHeader(
                      onClose: () => Navigator.of(context).pop(),
                    ),

                    const SizedBox(height: 28),

                    // Avatar
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _AvatarPreview(
                        key: ValueKey(
                          _newImageBytes != null ? 'new-avatar' : 'current-avatar',
                        ),
                        imageUrl: widget.currentImageUrl,
                        imageBytes: _newImageBytes,
                        isLoading: _isPicking,
                      ),
                    ),

                    const SizedBox(height: 22),

                    ReText(
                      _hasChanges ? 'تصویر جدید آماده ذخیره است' : 'تصویر پروفایل',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),

                    const SizedBox(height: 7),

                    ReText(
                      _hasChanges ? 'در صورت تأیید، تصویر جدید برای پروفایل شما ذخیره می‌شود.' : 'تصویر پروفایل خود را انتخاب یا ویرایش کنید.',
                      color: AppColors.gray,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: ReButton(
                            key: ValueKey(
                              _hasChanges ? 'save-avatar' : 'edit-avatar',
                            ),
                            text: _hasChanges ? 'ذخیره' : 'ویرایش',
                            icon: _hasChanges ? Icons.check_rounded : Icons.edit_rounded,
                            reverseIconPosition: true,
                            isLoading: _isSaving || _isPicking,
                            onPressed: _hasChanges ? _save : _editImage,
                            height: 54,
                            borderRadius: 100,
                            background: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 112,
                          child: ReButton(
                            text: 'لغو',
                            icon: Icons.close_rounded,
                            reverseIconPosition: true,
                            onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
                            height: 54,
                            borderRadius: 100,
                            isOutlined: true,
                            background: AppColors.white,
                            color: AppColors.gray2,
                            textColor: AppColors.black1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({
    super.key,
    required this.imageUrl,
    required this.imageBytes,
    required this.isLoading,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageBytes != null) {
      image = Image.memory(
        imageBytes!,
        width: 250,
        height: 250,
        fit: BoxFit.cover,
        gaplessPlayback: true,
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      image = imageUrl?.startsWith('http') ?? false
          ? Image.network(
              imageUrl!,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const _DefaultAvatar();
              },
            )
          : Image.asset(
              imageUrl!,
              width: 250,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const _DefaultAvatar();
              },
            );
    } else {
      image = const _DefaultAvatar();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gray2,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 30,
                offset: const Offset(0, 12),
                color: Colors.black.withOpacity(0.08),
              ),
            ],
          ),
          child: ClipOval(
            child: image,
          ),
        ),
        if (isLoading)
          Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.white,
              ),
            ),
          ),
      ],
    );
  }
}

class _DefaultAvatar extends StatelessWidget {
  const _DefaultAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray1,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 90,
          color: AppColors.gray,
        ),
      ),
    );
  }
}

class _ProfileAvatarSheetHeader extends StatelessWidget {
  const _ProfileAvatarSheetHeader({
    required this.onClose,
  });

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ReText(
                  'تصویر پروفایل',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
                SizedBox(height: 4),
                ReText(
                  'تصویر پروفایل خود را تغییر دهید.',
                  color: AppColors.gray,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gray2,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: AppColors.gray,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
