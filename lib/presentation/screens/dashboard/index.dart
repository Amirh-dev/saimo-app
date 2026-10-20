import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/consultants/intro_popup.dart';
import 'package:simo_learn/presentation/screens/dashboard/activity_widget.dart';
import 'package:simo_learn/presentation/screens/dashboard/live_tasks.dart';
import 'package:simo_learn/presentation/screens/dashboard/study_metrics.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/tasks/add_task/index.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/modal.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/user_avatar.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/jalali_text.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with AppTabRevisit {
  Timer? _consultantPopupTimer;

  @override
  int get tabIndex => 0;

  @override
  void onTabRevisited() => context.read<DashboardCubit>().load();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<DashboardCubit>().load();
        _consultantPopupTimer = ConsultantIntroPopup.schedule(context);
      }
    });
  }

  @override
  void dispose() {
    _consultantPopupTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AppExitGuard(
        child: BlocConsumer<DashboardCubit, DashboardState>(
          listenWhen: (previous, current) =>
              previous.tasksFetchedAt != current.tasksFetchedAt,
          listener: (context, state) => _adoptServerTimer(state.tasks),
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.gray1,
              bottomNavigationBar: AppBottomNavigationBar(
                currentIndex: 0,
                onTap: (index) => navigateToIndex(context, index, 0),
              ),
              body: _DashboardContent(state: state),
            );
          },
        ),
      );

  /// A timer still running on the server (say, the app was closed while it
  /// ran) becomes the app's live timer again, as the tasks tab does, so the
  /// home, the banner and the timer screen all count the same seconds. Only
  /// from a fresh server list: a cached one may be out of date.
  void _adoptServerTimer(List<DashboardTaskItem>? tasks) {
    final timer = TaskTimerService.instance;
    if (tasks == null || timer.isRunning) return;
    for (final task in tasks) {
      final startedAt = task.timerStartedAt;
      if (!task.isRunning || startedAt == null) continue;
      timer.bindRepository(
        TaskTimerRepository(context.read<GraphQLRepository>()),
      );
      timer.resumeRunning(
        taskId: task.id,
        totalSeconds: task.maxDuration * 60,
        elapsedSeconds: task.elapsedSeconds,
        startedAt: startedAt,
        taskData: task.toMap(),
      );
      return;
    }
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<DashboardCubit>();
    final tasks = state.tasks;

    return Column(
      children: [
        Container(
          color: AppColors.white,
          child: const SafeArea(
            child: Column(
              children: [
                AppTabHeader('خوش آمدید'),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _DashboardSection(
                    failed: state.hasFailed(DashboardSection.profile),
                    ready: state.profile != null,
                    skeleton: const _SkeletonUserInfo(),
                    onRetry: cubit.retry,
                    builder: () => _ProfileCard(state: state),
                  ),
                  const SizedBox(height: 24),
                  _goals(context),
                  const SizedBox(height: 24),
                  _DashboardSection(
                    failed: state.hasFailed(DashboardSection.tasks),
                    ready: tasks != null,
                    skeleton: const _SkeletonActivity(),
                    onRetry: cubit.retry,
                    // Rebuilt by the app's live timer: a task started,
                    // paused or finished anywhere shows here at once, and a
                    // running one fills second by second.
                    builder: () => ListenableBuilder(
                      listenable: TaskTimerService.instance,
                      builder: (context, _) => TodayActivityWidget(
                        date: JalaliText.fullDay(Jalali.now()),
                        tasks: liveTodayTasks(
                          tasks!,
                          TaskTimerService.instance,
                        ),
                        consistency: state.consistency,
                        onAllTasksTap: () => navigateToIndex(context, 1, 0),
                        onAddTap: () => context.to(
                          AddTimedTaskScreen(onBack: cubit.load),
                        ),
                        onOpenTask: (task) => context.to<void>(
                          TaskTimerScreen(task: task.toMap(), onPop: () {}),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _goals(BuildContext context) {
    final goals = state.goals;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              const ReText('اهداف', fontSize: 16, fontWeight: FontWeight.w900),
              const Spacer(),
              HomeOutlineButton(
                title: 'همه اهداف',
                onTap: () => navigateToIndex(context, 2, 0),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _DashboardSection(
          failed: state.hasFailed(DashboardSection.goals),
          ready: goals != null,
          skeleton: const _SkeletonBox(
            height: 75,
            radius: 100,
            margin: EdgeInsets.symmetric(horizontal: 32),
          ),
          onRetry: context.read<DashboardCubit>().retry,
          builder: () => goals!.isEmpty
              ? _EmptyGoals(onTap: () => navigateToIndex(context, 2, 0))
              : GoalsCarouselWidget(
                  goals: goals,
                  pinnedId: state.pinnedGoalId,
                  onOpen: (goal) => _openGoal(context, goal),
                ),
        ),
      ],
    );
  }

  /// The goal's details live on the goals tab, which also carries out what
  /// the user picks there (reach, edit, delete).
  void _openGoal(BuildContext context, DashboardGoal goal) {
    navigateToIndex(context, 2, 0);
    GoalsView.pendingDetails.value = goal.id;
  }
}

/// The user, their plan, and the two numbers that keep them going: today's
/// study and the score multiplier.
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.state});

  final DashboardState state;

  @override
  Widget build(BuildContext context) {
    final profile = state.profile;
    final consistency = state.consistency;
    final isPremium = profile?.isPremium ?? false;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Row(
              children: [
                UserAvatar(
                  imageUrl: profile?.avatarURL,
                  name: profile?.fullName,
                  size: 56,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReText(
                        profile?.displayName ?? 'کاربر سایمو',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 7),
                      PlanBadge(
                        isPremium: isPremium,
                        onTap: isPremium
                            ? null
                            : () => showFreePremiumMessage(context),
                      ),
                    ],
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'پروفایل',
                  child: GestureDetector(
                    onTap: () => navigateToIndex(context, 4, 0),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                      ),
                      child: const Icon(IconsaxPlusLinear.setting_2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            StudyMetricsRow(
              consistency: consistency,
              currentTab: 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyGoals extends StatelessWidget {
  const _EmptyGoals({required this.onTap});

  /// Opens the goals section so the user can create their first goal.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 75,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.gray2),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReText(
                      'هنوز هدف فعالی ندارید',
                      textAlign: TextAlign.right,
                      color: AppColors.black1,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: 3),
                    ReText(
                      'برای ساختن اولین هدف ضربه بزنید',
                      textAlign: TextAlign.right,
                      color: AppColors.gray,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.gray,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One part of the home screen: its content once there is data for it, its
/// own skeleton until then, or a retry row if loading it failed. Data already
/// on screen stays while it refreshes, so a return to the screen shows no
/// skeleton at all.
class _DashboardSection extends StatelessWidget {
  const _DashboardSection({
    required this.ready,
    required this.failed,
    required this.skeleton,
    required this.onRetry,
    required this.builder,
  });

  final bool ready;
  final bool failed;
  final Widget skeleton;
  final VoidCallback onRetry;
  final Widget Function() builder;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (ready) {
      child = KeyedSubtree(key: const ValueKey('ready'), child: builder());
    } else if (failed) {
      child = _SectionRetry(key: const ValueKey('failed'), onRetry: onRetry);
    } else {
      child = _Shimmer(key: const ValueKey('loading'), child: skeleton);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      ),
      child: child,
    );
  }
}

/// Shown in place of a section that could not load and has nothing cached.
class _SectionRetry extends StatelessWidget {
  const _SectionRetry({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: const Row(
          textDirection: TextDirection.rtl,
          children: [
            Expanded(
              child: ReText(
                'دریافت اطلاعات ناموفق بود',
                textAlign: TextAlign.right,
                color: AppColors.gray,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: 12),
            ReText(
              'تلاش دوباره',
              color: AppColors.black1,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
            SizedBox(width: 6),
            Icon(Icons.refresh_rounded, size: 18, color: AppColors.black1),
          ],
        ),
      ),
    );
  }
}

class _Shimmer extends StatelessWidget {
  const _Shimmer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFE4E5E8), Color(0xFFF7F7F8), Color(0xFFE4E5E8)],
          stops: [0.25, 0.5, 0.75],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}

class _SkeletonUserInfo extends StatelessWidget {
  const _SkeletonUserInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(48),
      ),
      child: const Column(
        children: [
          Row(
            children: [
              _SkeletonBox(width: 56, height: 56, radius: 100),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 110, height: 15, radius: 8),
                    SizedBox(height: 10),
                    _SkeletonBox(width: 90, height: 25, radius: 20),
                  ],
                ),
              ),
              SizedBox(width: 14),
              _SkeletonBox(width: 56, height: 56, radius: 100),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _SkeletonBox(height: 62, radius: 30)),
              SizedBox(width: 10),
              Expanded(child: _SkeletonBox(height: 62, radius: 30)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonActivity extends StatelessWidget {
  const _SkeletonActivity();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            children: [
              _SkeletonBox(width: 120, height: 18, radius: 8),
              Spacer(),
              _SkeletonBox(width: 90, height: 36, radius: 100),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            children: [
              const _SkeletonBox(height: 52, radius: 100),
              const SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  7,
                  (index) => const _SkeletonBox(
                    width: 38,
                    height: 93,
                    radius: 100,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    this.width = double.infinity,
    required this.height,
    required this.radius,
    this.margin,
  });

  final double width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

/// The running goals, one at a time, the main goal first. A card opens its
/// goal; the arrows and the swipe move between them.
class GoalsCarouselWidget extends StatefulWidget {
  const GoalsCarouselWidget({
    super.key,
    required this.goals,
    required this.onOpen,
    this.pinnedId,
  });

  final List<DashboardGoal> goals;
  final ValueChanged<DashboardGoal> onOpen;

  /// The goal made the main one on the goals tab, tagged «اصلی».
  final String? pinnedId;

  @override
  State<GoalsCarouselWidget> createState() => _GoalsCarouselWidgetState();
}

class _GoalsCarouselWidgetState extends State<GoalsCarouselWidget> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int page) {
    if (page < 0 || page >= widget.goals.length) return;
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.goals.length;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 72,
          child: Stack(
            alignment: Alignment.topCenter,
            clipBehavior: Clip.none,
            children: [
              Positioned(
                bottom: -25,
                left: 45,
                right: 45,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 36),
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6E7EB).withAlpha(160),
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(50)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
              PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: count,
                itemBuilder: (context, index) {
                  final goal = widget.goals[index];
                  return _GoalCard(
                    goal: goal,
                    pinned: goal.id == widget.pinnedId,
                    onTap: () => widget.onOpen(goal),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Slide controls only make sense with more than one goal.
        if (count > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _navButton(
                icon: Icons.chevron_right_rounded,
                label: 'هدف قبلی',
                onTap: () => _goTo(_currentPage - 1),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 12,
                child: CustomPaint(painter: _GoalDashPainter()),
              ),
              const SizedBox(width: 4),
              Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: OutOfText(
                  _currentPage + 1,
                  count,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 4),
              const SizedBox(
                width: 12,
                child: CustomPaint(painter: _GoalDashPainter()),
              ),
              const SizedBox(width: 4),
              _navButton(
                icon: Icons.chevron_left_rounded,
                label: 'هدف بعدی',
                onTap: () => _goTo(_currentPage + 1),
              ),
            ],
          ),
      ],
    );
  }

  Widget _navButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          // Drawn as given: the right arrow goes back, the left one on.
          child: Icon(
            icon,
            color: AppColors.black1,
            size: 20,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.pinned,
    required this.onTap,
  });

  final DashboardGoal goal;
  final bool pinned;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 26),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: ReText(
                            goal.title,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            maxLines: 1,
                          ),
                        ),
                        if (pinned) ...[
                          const SizedBox(width: 6),
                          const _MainGoalChip(),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    _deadline(),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.black1.withAlpha(150),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _deadline() {
    final target = goal.targetDate?.toLocal();
    if (target == null) {
      return const ReText('بدون موعد',
          fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.gray);
    }
    final now = DateTime.now();
    final days = DateTime(target.year, target.month, target.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
    if (days < 0) {
      return const ReText('موعدش گذشته',
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.errorColor);
    }
    if (days == 0) {
      return const ReText('موعدش امروز است',
          fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.black1);
    }
    final date = Jalali.fromDateTime(target);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        ReText('$days', fontSize: 14, fontWeight: FontWeight.w900),
        const SizedBox(width: 4),
        Flexible(
          child: ReText(
            'روز مانده، تا ${JalaliText.dayMonth(date)} ${date.year}',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            color: AppColors.gray,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

/// «اصلی» beside the goal made the main one on the goals tab.
class _MainGoalChip extends StatelessWidget {
  const _MainGoalChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.push_pin_rounded, size: 10, color: AppColors.black1),
          SizedBox(width: 3),
          ReText('اصلی', fontSize: 9.5, fontWeight: FontWeight.w800),
        ],
      ),
    );
  }
}

class _GoalDashPainter extends CustomPainter {
  const _GoalDashPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    var startX = 0.0;

    final paint = Paint()
      ..color = const Color(0xFFC4C5C9).withAlpha(170)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth, size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
