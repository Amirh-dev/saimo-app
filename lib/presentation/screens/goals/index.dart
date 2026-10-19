import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/cubit/goals_state.dart';
import 'package:simo_learn/features/goals/goal_timing.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/goals/goal_celebration.dart';
import 'package:simo_learn/presentation/screens/goals/goal_details_sheet.dart';
import 'package:simo_learn/presentation/screens/goals/goal_form_sheet.dart';
import 'package:simo_learn/presentation/screens/goals/goal_widgets.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_sections.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/_utils.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> with AppTabRevisit {
  @override
  int get tabIndex => 2;

  /// Shown goals stay while they refresh; only an empty list shows loading.
  @override
  void onTabRevisited() {
    final goals = context.read<GoalsCubit>();
    if (!goals.state.isMutating) goals.refresh();
  }

  @override
  void initState() {
    super.initState();
    // The first load runs at app start and may have failed (for one, before
    // signing in); opening the tab tries again.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final goals = context.read<GoalsCubit>();
      if (goals.state.goals.isEmpty && !goals.state.isLoading) {
        goals.loadGoals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppExitGuard(
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: 2,
          onTap: (index) => navigateToIndex(context, index, 2),
        ),
        body: const GoalsView(),
      ),
    );
  }
}

/// The goals tab: the main goal's countdown set large, the other goals by
/// deadline, and the ones reached folded away below.
class GoalsView extends StatefulWidget {
  const GoalsView({super.key});

  /// A goal another screen asked to open (the home's goal card). The tab
  /// opens its details once that goal is loaded, then clears the request.
  static final ValueNotifier<String?> pendingDetails = ValueNotifier(null);

  @override
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: StatMotion.reveal,
  );

  @override
  void initState() {
    super.initState();
    if (context.read<GoalsCubit>().state.goals.isNotEmpty) _reveal.value = 1;
    GoalsView.pendingDetails.addListener(_schedulePending);
    _schedulePending();
  }

  @override
  void dispose() {
    GoalsView.pendingDetails.removeListener(_schedulePending);
    _reveal.dispose();
    super.dispose();
  }

  /// After the frame, so the tab is on screen before its sheet rises.
  void _schedulePending() {
    if (GoalsView.pendingDetails.value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _openPending());
  }

  void _openPending() {
    final id = GoalsView.pendingDetails.value;
    if (id == null || !mounted) return;
    final state = _cubit.state;
    final goal = state.goals.where((goal) => goal.id == id).firstOrNull;
    if (goal == null) {
      // Still loading: the load brings it. Loaded without it: drop it.
      if (state.status == GoalsStatus.success) {
        GoalsView.pendingDetails.value = null;
      }
      return;
    }
    GoalsView.pendingDetails.value = null;
    _open(goal);
  }

  GoalsCubit get _cubit => context.read<GoalsCubit>();

  Future<void> _add({String? title}) => showGoalForm(context, title: title);

  Future<void> _open(Goal goal) async {
    final action = await showGoalDetails(context, goal);
    if (!mounted || action == null) return;
    switch (action) {
      case GoalAction.complete:
        await _complete(goal);
      case GoalAction.reopen:
        final done = await _cubit.reopen(goal.id);
        if (mounted && !done) _failed('برگرداندن هدف ناموفق بود.');
      case GoalAction.edit:
        await showGoalForm(context, goal: goal);
      case GoalAction.delete:
        await _delete(goal);
    }
  }

  Future<void> _complete(Goal goal) async {
    // How early it came is measured before the goal is marked.
    final timing = GoalTiming.of(goal);
    final done = await _cubit.complete(goal.id);
    if (!mounted) return;
    if (!done) {
      _failed('ثبت رسیدن به هدف ناموفق بود.');
      return;
    }
    final next = await showGoalCelebration(context, goal, timing: timing);
    if (mounted && next) await _add();
  }

  Future<void> _extend(Goal goal) =>
      showGoalForm(context, goal: goal, extend: true);

  Future<void> _delete(Goal goal) async {
    if (!await confirmGoalDelete(context, goal) || !mounted) return;
    final deleted = await _cubit.deleteGoal(goal.id);
    if (!mounted) return;
    if (deleted) {
      showReToast(context, 'هدف حذف شد', ReToastType.success);
    } else {
      _failed('حذف هدف ناموفق بود.');
    }
  }

  void _failed(String fallback) => showReToast(
        context,
        _cubit.state.errorMessage ?? fallback,
        ReToastType.failed,
      );

  @override
  Widget build(BuildContext context) {
    return BlocListener<GoalsCubit, GoalsState>(
      // A goal asked for from the home opens once it has loaded.
      listenWhen: (previous, current) =>
          previous.goals != current.goals || previous.status != current.status,
      listener: (context, state) => _schedulePending(),
      child: _layout(context),
    );
  }

  Widget _layout(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(48)),
          ),
          child: SafeArea(
            bottom: false,
            child: const AppTabHeader('اهداف').bMargin(24),
          ),
        ),
        Expanded(
          child: BlocConsumer<GoalsCubit, GoalsState>(
            listenWhen: (previous, current) =>
                previous.goals.isEmpty && current.goals.isNotEmpty,
            listener: (context, state) {
              if (reduceMotion(context)) {
                _reveal.value = 1;
              } else {
                _reveal.forward(from: 0);
              }
            },
            builder: (context, state) => Directionality(
              textDirection: TextDirection.rtl,
              child: RefreshIndicator(
                color: GoalColors.ink,
                backgroundColor: AppColors.white,
                onRefresh: _cubit.refresh,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
                      sliver: SliverToBoxAdapter(
                        child: AnimatedSwitcher(
                          duration: StatMotion.of(
                              context, const Duration(milliseconds: 220)),
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              ...previous,
                              if (current != null) current,
                            ],
                          ),
                          child: _body(state),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _body(GoalsState state) {
    if (state.goals.isEmpty &&
        (state.status == GoalsStatus.initial || state.isLoading)) {
      return const GoalsSkeleton(key: ValueKey('skeleton'));
    }
    if (state.goals.isEmpty && state.status == GoalsStatus.failure) {
      return StatisticsErrorView(
        key: const ValueKey('error'),
        message: state.errorMessage ?? 'خطا در دریافت اهداف',
        onRetry: _cubit.loadGoals,
      );
    }
    final board = GoalsBoard.of(state.goals, pinnedId: state.pinnedId);
    if (board.isEmpty) {
      return GoalsEmpty(
        key: const ValueKey('empty'),
        onAdd: _add,
        onSuggestion: (title) => _add(title: title),
      );
    }

    var order = 0;
    Widget reveal(Widget child) =>
        Reveal(animation: _reveal, index: order++, child: child);
    final hero = board.hero;

    return Column(
      key: const ValueKey('board'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hero != null) ...[
          reveal(
            AnimatedSwitcher(
              duration:
                  StatMotion.of(context, const Duration(milliseconds: 260)),
              child: GoalsHero(
                key: ValueKey(hero.id),
                goal: hero,
                pinned: board.heroIsPinned,
                onTap: () => _open(hero),
              ),
            ),
          ),
          const SizedBox(height: 26),
        ],
        reveal(
          Row(
            children: [
              ReText(hero == null ? 'اهداف تو' : 'اهداف دیگر',
                  fontSize: 15, fontWeight: 900, color: GoalColors.ink),
              const Spacer(),
              AddGoalButton(onTap: state.isMutating ? null : _add),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (board.others.isNotEmpty)
          reveal(
            GoalsListCard(
              goals: board.others,
              busy: state.isMutating,
              onOpen: _open,
              onComplete: _complete,
              onExtend: _extend,
            ),
          )
        else
          reveal(
            Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
              ),
              child: const ReText(
                'هدف دیگری نداری؛ یک هدف تازه بگذار.',
                fontSize: 12.5,
                fontWeight: 700,
                color: GoalColors.muted,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (board.achieved.isNotEmpty) ...[
          const SizedBox(height: 12),
          reveal(AchievedSection(goals: board.achieved, onOpen: _open)),
        ],
      ],
    );
  }
}
