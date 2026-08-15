import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:simo_learn/presentation/screens/app_navigation_tabs.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/statistics/study_chart.dart';
import 'package:simo_learn/presentation/screens/statistics/test_chart.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) => navigateToIndex(context, index, 3),
      ),
      backgroundColor: const Color(0xffF5F5F9),
      body: Column(
        children: [
          _statisticsAppBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const _StatsGrid(
                    data: {
                      'commitment': "89٪",
                      'commitmentChanges': 6,
                      'studyHours': 1032,
                      'studyHoursChanges': 9,
                      'doneTests': 570,
                      'doneTestsChanges': 4,
                      'correctTests': 312,
                      'correctTestsChanges': -4,
                    },
                  ),
                  const Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 32),
                    child: ReText(
                      'نمودار میزان مطالعه',
                      fontWeight: FontWeight(800),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _StudyTabs(
                    onChanged: (final int selected){
                      debugPrint(selected.toString());
                      setState(() {
                        _isDateStudyChart = selected == 0;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: StudyChart(isDateChart: _isDateStudyChart),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 32),
                    child: ReText(
                      'نمودار تعداد تست',
                      fontWeight: FontWeight(800),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32.0),
                    child: TestChart(),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statisticsAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color(0xffFCFCFC), borderRadius: BorderRadius.vertical(bottom: Radius.circular(48))),
      child: const SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: 8),
            Padding(
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
            SizedBox(height: 32),
            _PeriodTabs(),
            SizedBox(height: 16),
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
    this.initialIndex = 1, // 0 = امروز، 1 = این هفته، 2 = این ماه
    this.onChanged,
    this.fontFamily = AppFonts.iranSansVar,
  });

  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final String? fontFamily;

  @override
  State<_PeriodTabs> createState() => _PeriodTabsState();
}

class _PeriodTabsState extends State<_PeriodTabs> {
  late int _index = widget.initialIndex;

  static const _labels = ['امروز', 'این هفته', 'این ماه'];
  static const _white = Color(0xFFFCFCFC);
  static const _grey = Color(0xFFEBECF0);
  static const _black = Color(0xFF23232B);
  static const _h = 46.0;
  static const _pad = 22.0;
  static const _dur = Duration(milliseconds: 320);
  static const _curve = Curves.easeOutCubic;

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    widget.onChanged?.call(i);
  }

  Future<void> _openCalendar() async {
    Jalali? picked = await showPersianDatePicker(
      context: context,
      locale: Locale('fa'),
      initialDate: Jalali.now(),
      firstDate: Jalali(1385, 8),
      lastDate: Jalali(1450, 9),
    );
  }

  TextStyle _style(bool selected) => TextStyle(
    fontFamily: widget.fontFamily,
    fontSize: 13,
    height: 1,
    fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
    color: _black,
  );

  // Measured with the bold style so slots never resize mid-animation.
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
    final scaler = MediaQuery.textScalerOf(context);
    final widths = _labels.map((l) => _slot(l, scaler)).toList();
    final starts = <double>[];
    var offset = 0.0;
    for (final w in widths) {
      starts.add(offset);
      offset += w;
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: _grey,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
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
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.data,
    super.key,
  });

  /// Expected:
  ///
  /// {
  ///   'commitment': 819,
  ///   'commitmentChanges': 6,
  ///
  ///   'studyHours': 1032,
  ///   'studyHoursChanges': 9,
  ///
  ///   'doneTests': 570,
  ///   'doneTestsChanges': 4,
  ///
  ///   'correctTests': 312,
  ///   'correctTestsChanges': 9,
  /// }
  final Map<String, dynamic> data;

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

        // Screenshot is approximately this proportion.
        childAspectRatio: 1.15,

        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        return _StatCard(stat: stats[index]);
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.stat,
  });

  final _StatItem stat;

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
  });

  final num change;
  final bool isPositive;

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
            '${toPersianNumber(change.abs().toString())}٪ از هفته قبل',
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
                // Sliding white background
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

                // Labels
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