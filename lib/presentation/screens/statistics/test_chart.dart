import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/fonts.dart';

class DayData {
  final String dateDay;
  final String dateMonth;
  final int correctAnswers; // Green bar
  final int totalQuestions;
  final bool hasData;
  final String year;
  final String dayOfWeek;

  DayData({
    required this.dateDay,
    required this.dateMonth,
    this.correctAnswers = 0,
    this.totalQuestions = 0,
    this.year = "",
    this.dayOfWeek = "",
    required this.hasData,
  });

  int get wrongAnswers => totalQuestions - correctAnswers;
}

// --- Main Widget ---

class TestChart extends StatefulWidget {
  final List<GStatisticsDashboardData_statisticsDashboard_dailyBuckets> dailyBuckets;
  const TestChart({super.key, required this.dailyBuckets});

  @override
  State<TestChart> createState() => _TestChartState();
}

class _TestChartState extends State<TestChart> {
  int? _selectedIndex;
  Timer? _closeTimer;

  List<DayData> get _data {
    return widget.dailyBuckets.map<DayData>((bucket) {
      Jalali startTime = Jalali.fromDateTime(DateTime.parse(bucket.start.value));
      final seconds = bucket.studySeconds;
      final duration = Duration(seconds: seconds);

      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return DayData(
        dateDay: toPersianNumber(startTime.day.toString()),
        dateMonth: _getPersianMonth(startTime.month),
        dayOfWeek: _getPersianWeekday(startTime.toDateTime()),
        year: toPersianNumber(startTime.year.toString(), separated: false),
        correctAnswers: bucket.correctAnswers,
        totalQuestions: bucket.totalQuestions,
        hasData: !(bucket.correctAnswers == 0 && bucket.totalQuestions == 0),
      );
    }).toList();
  }

  String _getPersianMonth(int month) {
    const months = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند',
    ];

    return months[month - 1];
  }

  String _getPersianWeekday(DateTime date) {
    const weekdays = [
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنج‌شنبه',
      'جمعه',
      'شنبه',
      'یکشنبه',
    ];

    return weekdays[date.weekday - 1];
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _handleTap(int index) {
    final item = _data[index];

    // Issue 3: Prevent popup on empty columns
    if (!item.hasData) return;

    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = null;
        _closeTimer?.cancel();
      } else {
        _selectedIndex = index;
        _closeTimer?.cancel();

        // Auto-close popup after 3 seconds
        _closeTimer = Timer(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _selectedIndex = null;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 250,
        decoration: BoxDecoration(
          color: const Color(0xfffafafa),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(left: 24, right: 24,top: 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: AppColors.black1.withAlpha(15)),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildYAxis(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _buildGridLines(),
                                _buildAxesLines(),
                                _buildBars(constraints),
                                if (_selectedIndex != null) _buildTooltip(constraints),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  // Issue 5: Corrected format to "۱۰۰ تست"
  Widget _buildYAxis() {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text('۵۰۰ تست', style: TextStyle(color: AppColors.black1, fontSize: 8)),
          Text('۱۰۰ تست', style: TextStyle(color: AppColors.black1, fontSize: 8)),
          Text('۵۰ تست', style: TextStyle(color: AppColors.black1, fontSize: 8)),
          Text('۲۰ تست', style: TextStyle(color: AppColors.black1, fontSize: 8)),
          Text('۰ تست', style: TextStyle(color: AppColors.black1, fontSize: 8)),
          SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildGridLines() {
    return CustomPaint(
      size: const Size(double.infinity, double.infinity),
      painter: GridPainter(),
    );
  }

  Widget _buildAxesLines() {
    return Positioned(
      left: 0,
      top: 0,
      bottom: 48,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(color: Color(0xFFE5E5E5), width: 2),
            bottom: BorderSide(color: Color(0xFFE5E5E5), width: 2),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildBars(BoxConstraints constraints) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      top: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_data.length, (index) {
          final item = _data[index];
          final isSelected = _selectedIndex == index;

          return GestureDetector(
            onTap: () => _handleTap(index),
            behavior: HitTestBehavior.opaque,
            // Issue 3: Only the tapped pair scales up smoothly
            child: AnimatedScale(
              scale: isSelected ? 1.12 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Issue 4: Bolder numerator in ratio text (e.g., 9 in 9/25)
                  SizedBox(
                    height: 16,
                    child: item.hasData
                        ? RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                              ),
                              children: [
                                TextSpan(
                                  text: toPersianNumber('${item.correctAnswers}'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900, // Extra bold
                                    fontSize: 10,
                                    fontFamily: AppFonts.iranSansVar,
                                  ),
                                ),
                                TextSpan(
                                  text: toPersianNumber('/${item.totalQuestions}'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF757575),
                                    fontSize: 6,
                                    fontFamily: AppFonts.iranSansVar,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Text(
                            '۰/۰',
                            style: TextStyle(
                              fontSize: 8,
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // Issue 1 & 2: Pair container aligning bars to the bottom baseline
                  SizedBox(
                    child: item.hasData
                        ? Row(
                            // CRITICAL: Ensures short bars don't fly and start from the bottom line
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Green Bar (Correct) - Issue 6: Width set to 6px
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(bottom: isSelected ? 5 : 0),
                                width: 6,
                                height: (item.correctAnswers / item.totalQuestions) * 100,
                                decoration: const BoxDecoration(
                                  color: AppColors.success,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ),
                              const SizedBox(width: 3),
                              // Red Bar (Wrong) - Issue 6: Width set to 6px
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(bottom: isSelected ? 5 : 0),
                                width: 6,
                                height: ((item.totalQuestions - item.correctAnswers) / item.totalQuestions) * 100,
                                decoration: const BoxDecoration(
                                  color: AppColors.errorColor,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                                ),
                              ),
                            ],
                          )
                        : Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: 14,
                              height: 14,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE9ECEF),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),

                  // X-Axis Labels
                  SizedBox(
                    height: 40,
                    child: Column(
                      children: [
                        Text(
                          item.dateDay,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          item.dateMonth,
                          style: const TextStyle(
                            color: AppColors.black1,
                            fontSize: 6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTooltip(BoxConstraints constraints) {
    if (_selectedIndex == null) return const SizedBox.shrink();

    final item = _data[_selectedIndex!];
    final double columnWidth = constraints.maxWidth / _data.length;

    // Calculate dynamic left offset for popup relative to selected pair
    final double leftPosition = (_selectedIndex! * columnWidth) + (columnWidth / 2) + 10;

    return Positioned(
      left: leftPosition,
      top: 20,
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_selectedIndex),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 8 * (1 - value),
                sigmaY: 8 * (1 - value),
              ),
              child: Transform.scale(
                scale: 0.9 + (0.1 * value),
                child: child,
              ),
            ),
          );
        },
        child: CustomPaint(
          painter: TooltipPainter(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ReText(
                      ' پاسخ صحیح',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    ReText(
                      ' ${item.correctAnswers} ',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const ReText(
                      'مجموع سوالات ',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    ReText(
                      ' ${item.totalQuestions} ',
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ReText(
                      ' ${item.year}',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    ReText(
                      ' ${item.dateMonth} ',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    ReText(
                      ' ${item.dateDay} ',
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    ReText(
                      item.dayOfWeek,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem('صحیح', AppColors.success),
          const SizedBox(width: 24),
          _legendItem('غلط', AppColors.errorColor),
        ],
      ),
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 10, color: AppColors.gray)),
      ],
    );
  }
}

// --- Custom Painters ---

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFE5E5E5)
      ..strokeWidth = 1.0;

    final double chartHeight = size.height - 48;
    const int lines = 4;
    final double spacing = chartHeight / lines;

    for (int i = 0; i < lines; i++) {
      double y = i * spacing;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const int dashWidth = 4;
    const int dashSpace = 4;
    double startX = p1.dx;
    while (startX < p2.dx) {
      canvas.drawLine(
        Offset(startX, p1.dy),
        Offset(startX + dashWidth, p1.dy),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class TooltipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF222226);

    final path = Path();
    const double radius = 12.0;
    const double arrowSize = 10.0;
    const double arrowPosition = 30.0;

    path.moveTo(arrowSize + radius, 0);
    path.lineTo(size.width - radius, 0);
    path.arcToPoint(Offset(size.width, radius), radius: const Radius.circular(radius));
    path.lineTo(size.width, size.height - radius);
    path.arcToPoint(Offset(size.width - radius, size.height), radius: const Radius.circular(radius));
    path.lineTo(arrowSize + radius, size.height);
    path.arcToPoint(Offset(arrowSize, size.height - radius), radius: const Radius.circular(radius));

    path.lineTo(arrowSize, arrowPosition + arrowSize);
    path.lineTo(0, arrowPosition + (arrowSize / 2));
    path.lineTo(arrowSize, arrowPosition);

    path.lineTo(arrowSize, radius);
    path.arcToPoint(Offset(arrowSize + radius, 0), radius: const Radius.circular(radius));
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
