import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/statistics/date_range_picker.dart';
import 'package:simo_learn/presentation/screens/statistics/study_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/test_chart.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/extentions.dart';
import 'package:simo_learn/utils/fonts.dart' show AppFonts;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool _isDateStudyChart = true;
  String statGridTimeUnit = 'هفته';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) => navigateToIndex(context, index, 3),
      ),
      backgroundColor: AppColors.gray1,
      body: Column(
        children: [
          _statisticsAppBar(onChanged: (index) {
            switch (index) {
              case 0:
                statGridTimeUnit = 'روز';
              case 1:
                statGridTimeUnit = 'هفته';
              case 2:
                statGridTimeUnit = 'ماه';
            }
          }),
          Expanded(
            child: BlocBuilder<StatisticsCubit, StatisticsState>(builder: (context, state) {
              final dashboard = state.dashboard;
              final weeklyDashboard = state.weeklyDashboard;

              // We need BOTH the dynamic stats and the permanent weekly charts to render
              if (dashboard == null || weeklyDashboard == null) {
                if (state.status == StatisticsStatus.failure && state.errorMessage != null) {
                  return _errorView(
                    message: state.errorMessage ?? 'خطا در دریافت اطلاعات',
                    onRetry: () => context.read<StatisticsCubit>().refresh(),
                  );
                }
                return const Center(child: CupertinoActivityIndicator());
              }

              // The grid takes the dynamically selected range data
              final comparison = dashboard.comparison;

              return RefreshIndicator(
                onRefresh: () => context.read<StatisticsCubit>().refresh(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _StatsGrid(
                        unit: statGridTimeUnit,
                        data: {
                          'commitment': '${comparison.current.adherencePercentage.round()}٪',
                          'commitmentChanges': (comparison.adherenceChangePercentage ?? 0).round(),
                          'studyHours': (comparison.current.studySeconds ~/ 60) ~/ 60,
                          'studyHoursChanges': (comparison.studySecondsChangePercentage ?? 0).round(),
                          'doneTests': comparison.current.totalQuestions,
                          'doneTestsChanges': (comparison.totalQuestionsChangePercentage ?? 0).round(),
                          'correctTests': comparison.current.correctAnswers,
                          'correctTestsChanges': (comparison.correctAnswersChangePercentage ?? 0).round(),
                        },
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: ReText(
                          'نمودار میزان مطالعه',
                          fontWeight: FontWeight(800),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _StudyTabs(
                        onChanged: (final int selected) {
                          setState(() {
                            _isDateStudyChart = selected == 0;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: StudyChart(
                          isDailyChart: _isDateStudyChart,
                          // The charts strictly take the weeklyDashboard data
                          dailyBuckets: weeklyDashboard.dailyBuckets.toList(),
                          subjectBuckets: weeklyDashboard.subjectBuckets.toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: ReText(
                          'نمودار تعداد تست',
                          fontWeight: FontWeight(800),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: TestChart(
                          // The charts strictly take the weeklyDashboard data
                          dailyBuckets: weeklyDashboard.dailyBuckets.toList(),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _errorView({
    required final String message,
    required final VoidCallback onRetry,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReText(message),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            child: ReOutlineButton(title: 'تلاش دوباره', icon: IconsaxPlusLinear.refresh, onTap: onRetry),
          ),
        ],
      );

  Widget _statisticsAppBar({
    final ValueChanged<int>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xffFCFCFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(48))),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    IconsaxPlusLinear.notification,
                    size: 24,
                    color: Color(0xFF24242C),
                  ),
                  ReText(
                    'آمـــار',
                    color: AppColors.black1,
                    fontSize: 16,
                    fontWeight: 1000,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _PeriodTabs(
              initialIndex: 1, // 'این هفته'
              onChanged: (index) {
                context.read<StatisticsCubit>().changePeriod(
                      StatisticsPeriod.values[index], // Maps perfectly to today, week, month
                    );
                onChanged?.call(index);
              },
              onDateRangePicked: (startDate, endDate) {
                context.read<StatisticsCubit>().selectDateRange(
                      startDate,
                      endDate ?? startDate,
                    );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _onBottomNavigationTap(int index) {
    if (index == 2) return;
    switch (index) {
      case 0:
        context.toOff(const GoalScreen());
        break;
      case 1:
        context.toOff(const TrophiesScreen());
        break;
      case 3:
        context.toOff(const StatisticsScreen());
        break;
      case 4:
        context.toOff(const ProfileScreen());
        break;
    }
  }
}

class _PeriodTabs extends StatefulWidget {
  const _PeriodTabs({
    super.key,
    this.initialIndex = 1,
    this.onChanged,
    this.fontFamily = AppFonts.iranSansVar,
    this.onDateRangePicked,
  });

  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final String? fontFamily;
  final Function(Jalali start, Jalali? end)? onDateRangePicked;

  @override
  State<_PeriodTabs> createState() => _PeriodTabsState();
}

class _PeriodTabsState extends State<_PeriodTabs> {
  late int _index = widget.initialIndex;

  Jalali? _startDate;
  Jalali? _endDate;

  static const _labels = ['امروز', 'این هفته', 'این ماه'];
  // ... keep your existing colors and constants here ...
  static const _white = Color(0xFFFCFCFC);
  static const _grey = Color(0xFFEBECF0);
  static const _black = Color(0xFF23232B);
  static const _blue = Color(0xFF526EF5);
  static const _h = 46.0;
  static const _pad = 22.0;
  static const _dur = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  void _select(int i) {
    debugPrint("🟣 UI TAB PRESSED: Index $i (${_labels[i]})");

    if (i == _index) {
      debugPrint("🟣 UI TAB IGNORED: Tab $i is already selected!");
      return;
    }

    setState(() => _index = i);
    debugPrint("🟣 UI TAB UPDATED: State set to index $i. Calling widget.onChanged...");

    widget.onChanged?.call(i);
  }

  Future<void> _openCalendar() async {
    debugPrint("🟣 UI CALENDAR: Opening DatePicker bottom sheet...");
    final dynamic result = await DateRangePickerBottomSheet.show(context);

    if (result != null && result.startDate != null) {
      debugPrint("🟣 UI CALENDAR: Dates picked successfully!");
      setState(() {
        _startDate = result.startDate;
        _endDate = result.endDate;
      });
      widget.onDateRangePicked?.call(_startDate!, _endDate);
    } else {
      debugPrint("🟣 UI CALENDAR: Bottom sheet closed without picking dates.");
    }
  }

  // ... keep your existing _formatJalali, _style, _slot, and build methods ...
  String _formatJalali(Jalali? date) {
    if (date == null) return '';
    final f = date.formatter;
    return toPersianNumber('${f.d} ${f.mN} ${f.yyyy}', separated: false);
  }

  TextStyle _style(bool selected) => TextStyle(
        fontFamily: widget.fontFamily,
        fontSize: 13,
        height: 1,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        color: _black,
      );

  double _slot(String text, TextScaler scaler) =>
      (TextPainter(
        text: TextSpan(text: text, style: _style(true)),
        textDirection: TextDirection.rtl,
        textScaler: scaler,
        maxLines: 1,
      )..layout())
          .width +
      _pad * 2;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _startDate == null ? _grey : AppColors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: _startDate == null ? AppColors.white : AppColors.gray.withAlpha(50)),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: child,
          ),
          child: _startDate != null ? _buildDateRangeView() : _buildTabsView(context),
        ),
      ),
    );
  }

  // (Paste your _buildDateRangeView and _buildTabsView here, they don't need changes)

  Widget _buildDateRangeView() {
    return Row(
      key: const ValueKey('date_range_view'),
      mainAxisSize: MainAxisSize.max,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _startDate = null;
              _endDate = null;
              _index = widget.initialIndex;
            });
            widget.onChanged?.call(_index);
          },
          child: Container(
            width: _h,
            height: _h,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 35, 43, 38),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DatePill(
            label: 'از تاریخ',
            dateText: _formatJalali(_startDate),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right, color: _blue, size: 20),
        ),
        Expanded(
          child: _DatePill(
            label: 'تا تاریخ',
            dateText: _endDate != null ? _formatJalali(_endDate) : 'امروز',
          ),
        ),
      ],
    );
  }

  Widget _buildTabsView(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    final widths = _labels.map((l) => _slot(l, scaler)).toList();
    final starts = <double>[];
    var offset = 0.0;
    for (final w in widths) {
      starts.add(offset);
      offset += w;
    }

    return Row(
      key: const ValueKey('tabs_view'),
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(),
        SizedBox(
          height: _h,
          width: offset,
          child: Stack(
            children: [
              AnimatedPositionedDirectional(
                duration: _dur,
                curve: _curve,
                top: 0,
                bottom: 0,
                start: starts[_index],
                width: widths[_index],
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < _labels.length; i++)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _select(i),
                      child: SizedBox(
                        width: widths[i],
                        height: _h,
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: _dur,
                            curve: _curve,
                            style: _style(i == _index),
                            child: Text(_labels[i], maxLines: 1),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openCalendar,
          child: Container(
            width: _h,
            height: _h,
            decoration: BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(IconsaxPlusLinear.calendar, size: 24, color: _black),
          ),
        ),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.label,
    required this.dateText,
  });

  final String label;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.0,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReText(
            label,
            color: const Color(0xFF9E9E9E),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: 1),
          ReText(
            dateText,
            color: const Color(0xFF23232B),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.data,
    required this.unit,
    super.key,
  });

  final Map<String, dynamic> data;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final stats = <_StatItem>[
      _StatItem(
        value: data['commitment'],
        change: data['commitmentChanges'],
        title: 'میزان تعهد',
        iconSvg: 'assets/icons/medal_star.svg',
        iconBackground: const Color(0xFFFFC445),
        iconShadow: const Color(0xFFFFC445),
      ),
      _StatItem(
        value: data['studyHours'],
        change: data['studyHoursChanges'],
        title: 'ساعت مطالعه',
        icon: IconsaxPlusBold.clock,
        iconBackground: const Color(0xFFFF573D),
        iconShadow: const Color(0xFFFF573D),
      ),
      _StatItem(
        value: data['doneTests'],
        change: data['doneTestsChanges'],
        title: 'تست انجام شده',
        icon: Icons.check_rounded,
        iconBackground: const Color(0xFF38D27D),
        iconShadow: const Color(0xFF38D27D),
      ),
      _StatItem(
        value: data['correctTests'],
        change: data['correctTestsChanges'],
        title: 'تست صحیح',
        icon: IconsaxPlusBold.clipboard_tick,
        iconBackground: const Color(0xFF526EF5),
        iconShadow: const Color(0xFF526EF5),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.15,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return _StatCard(
          stat: stats[index],
          unit: unit,
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.stat,
    required this.unit,
  });

  final _StatItem stat;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final bool isPositive = stat.change >= 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatIcon(
            icon: stat.icon,
            iconSvg: stat.iconSvg,
            backgroundColor: stat.iconBackground,
            shadowColor: stat.iconShadow,
          ),
          ReText(
            toPersianNumber(stat.value.toString()),
            textAlign: TextAlign.center,
            fontWeight: const FontWeight(900),
            fontSize: 16,
          ),
          ReText(
            stat.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            fontSize: 13,
            color: AppColors.black1.withAlpha(180),
            overflow: TextOverflow.ellipsis,
          ),
          _ChangePill(
            change: stat.change,
            isPositive: isPositive,
            unit: unit,
          ),
        ],
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon({
    required this.backgroundColor,
    required this.shadowColor,
    this.iconColor,
    this.icon,
    this.iconSvg,
  });

  final IconData? icon;
  final Color backgroundColor;
  final Color shadowColor;
  final Color? iconColor;
  final String? iconSvg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [backgroundColor.withAlpha(140), backgroundColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.6),
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: icon != null
          ? Icon(
              icon,
              size: 16,
              color: iconColor ?? Colors.white,
            )
          : Padding(
              padding: const EdgeInsets.all(6.0),
              child: SvgPicture.asset(iconSvg!, color: const Color(0xffb25a22)),
            ),
    );
  }
}

class _ChangePill extends StatelessWidget {
  const _ChangePill({
    required this.change,
    required this.isPositive,
    required this.unit,
  });

  final num change;
  final bool isPositive;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final foregroundColor = isPositive ? AppColors.success : AppColors.errorColor;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      width: double.infinity,
      decoration: BoxDecoration(
        color: foregroundColor.withAlpha(30),
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ReText(
            isPositive ? '+' : '-',
            fontSize: 13,
            color: foregroundColor,
          ),
          const SizedBox(width: 7),
          ReText(
            '${toPersianNumber(change.abs().toString())}٪ از ${unit} قبل',
            textAlign: TextAlign.center,
            fontSize: 13,
            color: foregroundColor,
            fontWeight: const FontWeight(600),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  const _StatItem({
    required this.value,
    required this.change,
    required this.title,
    required this.iconBackground,
    required this.iconShadow,
    this.icon,
    this.iconSvg,
  });

  final dynamic value;
  final num change;
  final String title;
  final IconData? icon;
  final String? iconSvg;
  final Color iconBackground;
  final Color iconShadow;
}

class _StudyTabs extends StatefulWidget {
  const _StudyTabs({
    super.key,
    this.initialIndex = 0,
    this.onChanged,
    this.fontFamily = AppFonts.iranSansVar,
  });

  final int initialIndex;
  final Function(int)? onChanged;
  final String? fontFamily;

  @override
  State<_StudyTabs> createState() => _StudyTabsState();
}

class _StudyTabsState extends State<_StudyTabs> {
  late int _index = widget.initialIndex;

  static const _labels = [
    'بر اساس روز',
    'بر اساس تگ',
  ];

  static const _white = Color(0xFFFCFCFC);
  static const _grey = Color(0xFFEBECF0);
  static const _black = Color(0xFF23232B);

  static const _height = 50;
  static const _duration = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  void _select(int index) {
    if (index == _index) return;

    setState(() => _index = index);
    widget.onChanged?.call(index);
  }

  TextStyle _style(bool selected) => TextStyle(
        fontFamily: widget.fontFamily,
        fontSize: 13,
        height: 1,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        color: _black,
      );

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        width: double.infinity,
        height: _height.toDouble(),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _grey,
          borderRadius: BorderRadius.circular(999),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / 2;

            return Stack(
              children: [
                AnimatedPositionedDirectional(
                  duration: _duration,
                  curve: _curve,
                  top: 0,
                  bottom: 0,
                  start: _index * tabWidth,
                  width: tabWidth,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: _white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < _labels.length; i++)
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => _select(i),
                          child: SizedBox(
                            child: Center(
                              child: AnimatedDefaultTextStyle(
                                duration: _duration,
                                curve: _curve,
                                style: _style(i == _index),
                                child: Text(
                                  _labels[i],
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
