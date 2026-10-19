import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_overview.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/statistics/date_range_picker.dart';
import 'package:simo_learn/presentation/screens/statistics/rating_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_format.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_header.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_sections.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/screens/statistics/summary_bento.dart';
import 'package:simo_learn/presentation/screens/statistics/summary_cards.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with AppTabRevisit {
  @override
  int get tabIndex => 3;

  @override
  void onTabRevisited() =>
      context.read<StatisticsCubit>().refresh(quiet: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<StatisticsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppExitGuard(
        child: AppBottomNavigationBar(
          currentIndex: 3,
          onTap: (index) => navigateToIndex(context, index, 3),
        ),
      ),
      backgroundColor: AppColors.gray1,
      body: const StatisticsView(),
    );
  }
}

/// The statistics page: the period header, then the range's numbers. A new
/// range fades the old numbers back until its own arrive, and then every
/// number and bar moves from the old value to the new one.
class StatisticsView extends StatefulWidget {
  const StatisticsView({super.key});

  @override
  State<StatisticsView> createState() => _StatisticsViewState();
}

class _StatisticsViewState extends State<StatisticsView>
    with SingleTickerProviderStateMixin {
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();

  /// Whether the header has scrolled away, so the slim range bar shows.
  final _compact = ValueNotifier(false);

  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: StatMotion.reveal,
  );

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    if (context.read<StatisticsCubit>().state.hasData) _reveal.value = 1;
  }

  @override
  void dispose() {
    _scroll.dispose();
    _compact.dispose();
    _reveal.dispose();
    super.dispose();
  }

  void _onScroll() {
    final header = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    final height = header?.hasSize == true ? header!.size.height : 200.0;
    final compact = _scroll.offset > height - 24;
    if (compact != _compact.value) _compact.value = compact;
  }

  Future<void> _pickRange(StatisticsRange range) async {
    final custom = range.period == StatisticsPeriod.custom;
    final result = await DateRangePickerBottomSheet.show(
      context,
      initialStartDate: custom ? range.first : null,
      initialEndDate: custom ? range.last : null,
    );
    if (!mounted || result == null) return;
    context.read<StatisticsCubit>().selectDateRange(
          result.startDate,
          result.endDate ?? jalaliToday(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatisticsCubit>();
    return MultiBlocListener(
      listeners: [
        BlocListener<StatisticsCubit, StatisticsState>(
          listenWhen: (previous, current) =>
              !previous.hasData && current.hasData,
          listener: (context, _) {
            if (reduceMotion(context)) {
              _reveal.value = 1;
            } else {
              _reveal.forward(from: 0);
            }
          },
        ),
        // A refresh of numbers on screen failed: keep them, and say so.
        BlocListener<StatisticsCubit, StatisticsState>(
          listenWhen: (previous, current) =>
              current.isFailure &&
              current.errorMessage != null &&
              current.errorMessage != previous.errorMessage &&
              current.hasData &&
              !current.isStale,
          listener: (context, state) =>
              showReToast(context, state.errorMessage!, ReToastType.error),
        ),
      ],
      child: BlocBuilder<StatisticsCubit, StatisticsState>(
        builder: (context, state) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: Stack(
              children: [
                RefreshIndicator(
                  color: StatColors.ink,
                  backgroundColor: AppColors.white,
                  onRefresh: cubit.refresh,
                  child: CustomScrollView(
                    controller: _scroll,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: _Header(
                          key: _headerKey,
                          state: state,
                          onPickRange: () => _pickRange(state.range),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                        sliver: SliverToBoxAdapter(child: _body(state)),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _compact,
                    // Clipped: a slide only moves the painting, so without it
                    // the hidden bar would show over the header above.
                    builder: (context, compact, child) => IgnorePointer(
                      ignoring: !compact,
                      child: ClipRect(
                        child: AnimatedSlide(
                          offset:
                              compact ? Offset.zero : const Offset(0, -1.1),
                          duration: StatMotion.of(
                            context,
                            const Duration(milliseconds: 280),
                          ),
                          curve: StatMotion.curve,
                          child: child,
                        ),
                      ),
                    ),
                    child: StickyRangeBar(
                      range: state.range,
                      onShift: cubit.shift,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(StatisticsState state) {
    final cubit = context.read<StatisticsCubit>();
    final Widget body;
    if (state.isFailure && (!state.hasData || state.isStale)) {
      body = StatisticsErrorView(
        key: const ValueKey('error'),
        message: state.errorMessage ?? 'دریافت اطلاعات آمار با مشکل مواجه شد.',
        onRetry: cubit.retry,
      );
    } else if (!state.hasData) {
      body = const StatisticsSkeleton(key: ValueKey('skeleton'));
    } else {
      body = AnimatedOpacity(
        key: const ValueKey('content'),
        opacity: state.isStale ? 0.4 : 1,
        duration: StatMotion.of(context, const Duration(milliseconds: 200)),
        child: IgnorePointer(
          ignoring: state.isStale,
          child: _Sections(state: state, reveal: _reveal),
        ),
      );
    }
    return AnimatedSwitcher(
      duration: StatMotion.of(context, const Duration(milliseconds: 220)),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        children: [...previous, if (current != null) current],
      ),
      child: body,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    super.key,
    required this.state,
    required this.onPickRange,
  });

  final StatisticsState state;
  final VoidCallback onPickRange;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatisticsCubit>();
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTabHeader('آمــــار'),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Column(
                children: [
                  PeriodTabs(
                    period: state.range.period,
                    onPeriod: cubit.selectPeriod,
                    onCalendar: onPickRange,
                  ),
                  const SizedBox(height: 14),
                  RangeNavigator(
                    range: state.range,
                    direction: state.direction,
                    onShift: cubit.shift,
                    onCurrent: cubit.goToCurrent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Sections extends StatelessWidget {
  const _Sections({required this.state, required this.reveal});

  final StatisticsState state;
  final Animation<double> reveal;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StatisticsCubit>();
    final range = state.loadedRange!;
    final isDay = range.period == StatisticsPeriod.today;
    final overview = StatisticsOverview.of(state.dashboard!);
    final days = StatisticsDay.listFor(
      range.chartRange,
      state.chartDashboard!,
      focus: isDay ? range.first : null,
    );
    final subjects = SubjectStatistics.listOf(state.dashboard!);
    final charted = days.any((day) => day.hasActivity);

    var order = 0;
    Widget reveal(Widget child) =>
        Reveal(animation: this.reveal, index: order++, child: child);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        reveal(
          overview.isEmpty
              ? EmptyStatsCard(
                  range: range,
                  onStart: () => navigateToIndex(context, 1, 3),
                  onCurrent: cubit.goToCurrent,
                )
              : StudyHeroCard(overview: overview, range: range),
        ),
        const SizedBox(height: 12),
        reveal(
          SummaryBento(
            overview: overview,
            range: range,
            days: days,
          ),
        ),
        if (charted) ...[
          const SizedBox(height: 26),
          reveal(
            StudyChartSection(
              days: days,
              caption:
                  isDay ? StatsFormat.rangeShort(range.chartRange) : null,
            ),
          ),
          const SizedBox(height: 26),
          reveal(
            TestsChartSection(
              days: days,
              showAccuracy: !isDay,
              isCurrent: range.chartRange.isCurrent,
            ),
          ),
        ],
        if (subjects.isNotEmpty) ...[
          const SizedBox(height: 26),
          reveal(SubjectsSection(subjects: subjects)),
        ],
        if (charted) ...[
          const SizedBox(height: 26),
          reveal(RatingChart(days: days, subjects: subjects)),
        ],
      ],
    );
  }
}
