import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:simo_learn/utils/_utils.dart';

// --- Data Models ---

enum Performance { good, medium, weak, none }

class ChartData {
  final String topLabel;
  final String day;
  final String month;
  final double hoursValue; // Max 8.0
  final Performance performance;
  final String tooltipLine1;
  final String tooltipLine2;
  final String tooltipLine3;

  ChartData({
    required this.topLabel,
    required this.day,
    required this.month,
    required this.hoursValue,
    required this.performance,
    this.tooltipLine1 = '',
    this.tooltipLine2 = '',
    this.tooltipLine3 = '',
  });
}

// --- Main Widget ---

class StudyChart extends StatefulWidget {
  const StudyChart({super.key});

  @override
  State<StudyChart> createState() => _StudyChartState();
}

class _StudyChartState extends State<StudyChart> {
  int? _selectedIndex;
  Timer? _closeTimer;

  // Added sample data for all columns to ensure tooltips have content
  final List<ChartData> _data = [
    ChartData(
      topLabel: '۲:۱۲"',
      day: '۲۸',
      month: 'فروردین',
      hoursValue: 2.2,
      performance: Performance.medium,
      tooltipLine1: '۲ تسک',
      tooltipLine2: 'دوشنبه ۲۸ فروردین',
      tooltipLine3: '۲ ساعت و ۱۲ دقیقه',
    ),
    ChartData(
      topLabel: '۵:۴۵"',
      day: '۲۹',
      month: 'فروردین',
      hoursValue: 5.75,
      performance: Performance.good,
      tooltipLine1: '۵ تسک',
      tooltipLine2: 'سه‌شنبه ۲۹ فروردین',
      tooltipLine3: '۵ ساعت و ۴۵ دقیقه',
    ),
    ChartData(
      topLabel: '۳:۳۲"',
      day: '۳۰',
      month: 'فروردین',
      hoursValue: 3.5,
      performance: Performance.medium,
      tooltipLine1: '۳ تسک',
      tooltipLine2: 'چهارشنبه ۳۰ فروردین',
      tooltipLine3: '۳ ساعت و ۳۲ دقیقه',
    ),
    ChartData(
      topLabel: '۳\':۰۰',
      day: '۳۱',
      month: 'فروردین',
      hoursValue: 1.0,
      performance: Performance.weak,
      tooltipLine1: '۱ تسک',
      tooltipLine2: 'پنج‌شنبه ۳۱ فروردین',
      tooltipLine3: '۱ ساعت',
    ),
    ChartData(
      topLabel: '۱:۱۵"',
      day: '۱',
      month: 'اردیبهشت',
      hoursValue: 1.25,
      performance: Performance.weak,
      tooltipLine1: '۱ تسک',
      tooltipLine2: 'جمعه ۱ اردیبهشت',
      tooltipLine3: '۱ ساعت و ۱۵ دقیقه',
    ),
    ChartData(
      topLabel: '۰',
      day: '۲',
      month: 'اردیبهشت',
      hoursValue: 0.0,
      performance: Performance.none,
      tooltipLine1: '۴ تسک',
      tooltipLine2: 'شنبه ۲ اردیبهشت',
      tooltipLine3: '۴ ساعت و ۱۰ دقیقه',
    ),
    ChartData(
      topLabel: '۰', // Example of a 0 value to demonstrate it won't open
      day: '۳',
      month: 'اردیبهشت',
      hoursValue: 0.0,
      performance: Performance.none,
    ),
  ];

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  void _handleTap(int index) {
    final item = _data[index];

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
        height: 300,
        decoration: BoxDecoration(
          color: AppColors.gray2,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  color: AppColors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                                if (_selectedIndex != null)
                                  _buildTooltip(constraints),
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

  Widget _buildYAxis() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text('۸ ساعت', style: TextStyle(color: Colors.grey, fontSize: 8)),
        Text('۶ ساعت', style: TextStyle(color: Colors.grey, fontSize: 8)),
        Text('۴ ساعت', style: TextStyle(color: Colors.grey, fontSize: 8)),
        Text('۲ ساعت', style: TextStyle(color: Colors.grey, fontSize: 8)),
        Text('۰ ساعت', style: TextStyle(color: Colors.grey, fontSize: 8)),
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
          children: List.generate(_data.length, (index) {
            final item = _data[index];
            final chartHeight = constraints.maxHeight - 48;

            // Minimum height for 0 values to show the grey dot
            final barHeight = item.hoursValue > 0
                ? (item.hoursValue / 8.0) * chartHeight
                : 12.0;

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
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      width: 12,
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: _getColor(item.performance),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: _getColor(item.performance).withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : [],
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
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            item.month,
                            style: const TextStyle(
                              color: Colors.grey,
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

  Widget _buildTooltip(BoxConstraints constraints) {
    if (_selectedIndex == null) return const SizedBox.shrink();

    final item = _data[_selectedIndex!];
    final double columnWidth = constraints.maxWidth / _data.length;

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
                Text(
                  item.tooltipLine1,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tooltipLine2,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  item.tooltipLine3,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
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
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(width: 8),
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
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