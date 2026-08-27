import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

import '../../../graphql/queries/__generated__/statistics_dashboard.data.gql.dart';

// --- Data Models ---

enum Performance { good, medium, weak, none }

class ChartData {
  final String topLabel;
  final String day;
  final String label;
  final double hoursValue; // Max 8.0
  final Performance performance;
  final String tasksCount;
  final String dayOfWeek;
  final String dayOfMonth;
  final String hours;
  final String minutes;
  final String year;

  ChartData({
    required this.topLabel,
    required this.day,
    required this.label,
    required this.hoursValue,
    required this.performance,
    this.tasksCount = '',
    this.dayOfWeek = '',
    this.hours = '',
    this.minutes = '',
    this.dayOfMonth = '',
    this.year = '',
  });
}

// --- Main Widget ---

class StudyChart extends StatefulWidget {
  final bool isDailyChart;
  final List<GStatisticsDashboardData_statisticsDashboard_dailyBuckets> dailyBuckets;

  final List<GStatisticsDashboardData_statisticsDashboard_subjectBuckets> subjectBuckets;

  const StudyChart({
    required this.isDailyChart,
    required this.dailyBuckets,
    required this.subjectBuckets,
    super.key,
  });

  @override
  State<StudyChart> createState() => _StudyChartState();
}

class _StudyChartState extends State<StudyChart> {
  int? _selectedIndex;
  Timer? _closeTimer;

  List<ChartData> get _dateData {
    return widget.dailyBuckets.map<ChartData>((bucket) {
      Jalali startTime = Jalali.fromDateTime(DateTime.parse(bucket.start.value));
      final seconds = bucket.studySeconds;
      final duration = Duration(seconds: seconds);

      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return ChartData(
        topLabel: _formatDuration(hours, minutes),
        day: _toPersianNumber(startTime.day.toString()),
        label: _getPersianMonth(startTime.month),
        hoursValue: seconds / 3600.0,
        performance: _getPerformance(bucket),
        tasksCount: _toPersianNumber(
          bucket.completedTasks.toString(),
        ),
        dayOfMonth: _toPersianNumber(
          '${startTime.day} ${_getPersianMonth(startTime.month)}',
        ),
        dayOfWeek: _getPersianWeekday(startTime.toDateTime()),
        hours: _toPersianNumber(hours.toString()),
        minutes: _toPersianNumber(minutes.toString()),
        year: _toPersianNumber(
          startTime.year.toString(),
        ),
      );
    }).toList();
  }

  List<ChartData> get _tagData {
    return widget.subjectBuckets.map<ChartData>((bucket) {
      final seconds = bucket.studySeconds;
      final duration = Duration(seconds: seconds);

      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);

      return ChartData(
        topLabel: _formatDuration(hours, minutes),
        day: '',
        label: bucket.tagName,
        hoursValue: seconds / 3600.0,
        performance: _getPerformance(bucket),
        tasksCount: _toPersianNumber(
          bucket.completedTasks.toString(),
        ),
        dayOfWeek: '',
        dayOfMonth: '',
        hours: _toPersianNumber(hours.toString()),
        minutes: _toPersianNumber(minutes.toString()),
        year: '',
      );
    }).toList();
  }

  String _formatDuration(int hours, int minutes) {
    if (hours == 0 && minutes == 0) {
      return '۰';
    }

    return '${_toPersianNumber(hours.toString())}:'
        '${_toPersianNumber(minutes.toString().padLeft(2, '0'))}"';
  }

  Performance _getPerformance(dynamic bucket) {
    final seconds = bucket.studySeconds as int;

    if (seconds <= 0) {
      return Performance.none;
    }

    final hours = seconds / 3600.0;

    if (hours >= 4) {
      return Performance.good;
    }

    if (hours >= 2) {
      return Performance.medium;
    }

    return Performance.weak;
  }

  Jalali _toJalali(DateTime date) {
    return Jalali.fromDateTime(date);
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

  String _toPersianNumber(String value) {
    const english = '0123456789';
    const persian = '۰۱۲۳۴۵۶۷۸۹';

    for (var i = 0; i < english.length; i++) {
      value = value.replaceAll(
        english[i],
        persian[i],
      );
    }

    return value;
  }

  List<ChartData> get _currentData => widget.isDailyChart ? _dateData : _tagData;

  @override
  void didUpdateWidget(covariant StudyChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isDailyChart != widget.isDailyChart) {
      _selectedIndex = null;
      _closeTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _handleTap(int index) {
    final item = _currentData[index];

    // Prevent opening popup for 0 data columns
    if (item.hoursValue <= 0) return;

    setState(() {
      if (_selectedIndex == index) {
        _selectedIndex = null;
        _closeTimer?.cancel();
      } else {
        _selectedIndex = index;
        _closeTimer?.cancel();

        // Auto-close after 3 seconds
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

  Color _getColor(Performance perf) {
    switch (perf) {
      case Performance.good:
        return const Color(0xFF4263EB); // Blue
      case Performance.medium:
        return const Color(0xFFF5B031); // Yellow
      case Performance.weak:
        return const Color(0xFFF7553A); // Red
      case Performance.none:
        return const Color(0xFFE9ECEF); // Light Grey
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 270,
        decoration: BoxDecoration(
          color: const Color(0xfffafafa),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(blurRadius: 10, color: AppColors.black1.withAlpha(15)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(right: 24, left: 24, top: 32, bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    textDirection: TextDirection.ltr,
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
                                if (_selectedIndex != null) _buildTooltip(constraints, widget.isDailyChart),
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

  double get _maxHours {
    if (_currentData.isEmpty) return 8.0;

    final maxValue = _currentData.map((item) => item.hoursValue).reduce((a, b) => a > b ? a : b);

    return maxValue <= 0 ? 1.0 : maxValue;
  }

  Widget _buildYAxis() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('۸ ساعت', style: TextStyle(color: AppColors.black1, fontSize: 10)),
        Text('۶ ساعت', style: TextStyle(color: AppColors.black1, fontSize: 10)),
        Text('۴ ساعت', style: TextStyle(color: AppColors.black1, fontSize: 10)),
        Text('۲ ساعت', style: TextStyle(color: AppColors.black1, fontSize: 10)),
        Text('۰ ساعت', style: TextStyle(color: AppColors.black1, fontSize: 10)),
        SizedBox(height: 18),
      ],
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
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_currentData.length, (index) {
            final item = _currentData[index];
            final chartHeight = constraints.maxHeight - 48;

            // Minimum height for 0 values to show the grey dot
            final barHeight = item.hoursValue > 0 ? (item.hoursValue / 8) * chartHeight : 12.0;
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () => _handleTap(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedScale(
                // Column scales slightly up when selected
                scale: isSelected ? 1.08 : 1.0,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutBack,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      item.topLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        // Change text color slightly when selected
                        color: isSelected ? _getColor(item.performance) : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      margin: EdgeInsets.only(bottom: isSelected ? 4 : 0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 12,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: _getColor(item.performance),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _getColor(item.performance).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: Column(
                        children: [
                          Text(
                            item.day,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: AppColors.black1,
                              fontSize: 8,
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
      ),
    );
  }

  Widget _buildTooltip(BoxConstraints constraints, bool isDaily) {
    if (_selectedIndex == null) return const SizedBox.shrink();

    final item = _currentData[_selectedIndex!];
    final double columnWidth = constraints.maxWidth / _currentData.length;

    final double leftPosition = (_selectedIndex! * columnWidth) + (columnWidth / 2) + 12;

    final chartHeight = constraints.maxHeight - 48;
    final barHeight = (item.hoursValue / 8.0) * chartHeight;
    final topPosition = chartHeight - barHeight - 40;

    return Positioned(
      left: leftPosition,
      top: topPosition,
      // Blur and Fade animation for Popup
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_selectedIndex), // Re-trigger animation when index changes
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                // Decreasing blur as animation completes
                sigmaX: 8 * (1 - value),
                sigmaY: 8 * (1 - value),
              ),
              child: Transform.scale(
                // Slight pop-in scale effect along with the blur
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.tasksCount,
                      style: const TextStyle(color: AppColors.white, fontSize: 12),
                    ),
                    const Text(
                      ' تسک',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                isDaily
                    ? Row(
                        children: [
                          ReText(
                            item.dayOfWeek,
                            color: Colors.white, fontSize: 12,
                          ),
                          ReText(
                            ' ${item.dayOfMonth} ',
                            color: Colors.white70, fontSize: 12,
                          ),
                          ReText(
                           ' ${item.year}',
                            color: Colors.white70, fontSize: 12,
                          ),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ReText(
                      item.hours,
                      color: AppColors.white,
                      fontSize: 12,
                    ),
                    const ReText(
                      ' ساعت و ',
                      color: Colors.white70, fontSize: 12,
                    ),
                    ReText(
                      ' ${item.minutes}',
                      color: Colors.white70, fontSize: 12,
                    ),
                    const ReText(
                      ' دقیقه',
                      color: Colors.white70, fontSize: 12,
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
          _legendItem('خوب', _getColor(Performance.good)),
          const SizedBox(width: 24),
          _legendItem('متوسط', _getColor(Performance.medium)),
          const SizedBox(width: 24),
          _legendItem('ضعیف', _getColor(Performance.weak)),
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
        const SizedBox(width: 6),
        Text(title, style: const TextStyle(fontSize: 12, color: AppColors.gray)),
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
    final paint = Paint()..color = AppColors.black1;

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
