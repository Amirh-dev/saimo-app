import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/screens/statistics/statistics_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

class BarSegment {
  const BarSegment(this.value, this.color);

  final double value;
  final Color color;
}

/// One bar: its stacked [segments] (bottom first) and the words around it.
class ChartBar {
  const ChartBar({
    this.segments = const [],
    this.label = '',
    this.caption = '',
    this.valueLabel,
    this.isFuture = false,
    this.isToday = false,
    this.isFocused = false,
    this.tooltipTitle = '',
    this.tooltipBody = '',
  });

  final List<BarSegment> segments;

  /// Under the bar: a weekday initial, and the day under it.
  final String label;
  final String caption;

  /// Over the bar, when there is room for it.
  final String? valueLabel;

  final bool isFuture;
  final bool isToday;

  /// The day a single-day view is about: its label sits in a dark pill.
  final bool isFocused;

  final String tooltipTitle;
  final String tooltipBody;

  double get total => segments.fold(0.0, (sum, s) => sum + s.value);
}

/// Bars over days, the first on the right. They rise in a short wave the
/// first time and move to their new heights when the numbers change; a tap
/// dims the others and shows the bar's numbers.
///
/// The bars are painted in one [CustomPainter] driven by the animations, so
/// a frame of motion repaints them without rebuilding a widget.
class StatBarChart extends StatefulWidget {
  const StatBarChart({
    super.key,
    required this.bars,
    required this.maxValue,
    this.ticks = const [],
    this.tickLabel,
    this.reference,
    this.referenceLabel,
    this.plotHeight = 130,
    this.barWidth = 14,
  });

  final List<ChartBar> bars;
  final double maxValue;

  /// Grid lines, with [tickLabel] beside each on the right.
  final List<double> ticks;
  final String Function(double value)? tickLabel;

  /// A dashed line across, such as the average, named by [referenceLabel].
  final double? reference;
  final String? referenceLabel;

  final double plotHeight;
  final double barWidth;

  @override
  State<StatBarChart> createState() => _StatBarChartState();
}

class _StatBarChartState extends State<StatBarChart>
    with TickerProviderStateMixin {
  late final AnimationController _grow =
      AnimationController(vsync: this, duration: StatMotion.grow);
  late final AnimationController _select =
      AnimationController(vsync: this, duration: StatMotion.quick);

  late List<List<double>> _to = _valuesOf(widget.bars);
  late List<List<double>> _from = _zerosLike(_to);

  /// The tapped bar; [_shown] stays on it while its tooltip fades out.
  int? _selected;
  int? _shown;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _select.addStatusListener((status) {
      if (status == AnimationStatus.dismissed &&
          _selected == null &&
          _shown != null &&
          mounted) {
        setState(() => _shown = null);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _play();
  }

  @override
  void didUpdateWidget(covariant StatBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final values = _valuesOf(widget.bars);
    if (_sameValues(values, _to) && widget.maxValue == oldWidget.maxValue) {
      return;
    }
    // The same bars move from where they are; a new set rises from zero.
    _from = values.length == _to.length &&
            values.isNotEmpty &&
            values.first.length == _to.first.length
        ? _current()
        : _zerosLike(values);
    _to = values;
    _selected = null;
    _shown = null;
    _select.value = 0;
    _play();
  }

  void _play() {
    if (reduceMotion(context)) {
      _grow.value = 1;
    } else {
      _grow.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _grow.dispose();
    _select.dispose();
    super.dispose();
  }

  static List<List<double>> _valuesOf(List<ChartBar> bars) {
    final segments = bars.fold<int>(
      1,
      (most, bar) => math.max(most, bar.segments.length),
    );
    return [
      for (final bar in bars)
        [
          for (var s = 0; s < segments; s++)
            s < bar.segments.length ? bar.segments[s].value : 0.0,
        ],
    ];
  }

  static List<List<double>> _zerosLike(List<List<double>> values) => [
        for (final bar in values) List.filled(bar.length, 0.0),
      ];

  static bool _sameValues(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].length != b[i].length) return false;
      for (var s = 0; s < a[i].length; s++) {
        if (a[i][s] != b[i][s]) return false;
      }
    }
    return true;
  }

  List<List<double>> _current() => [
        for (var i = 0; i < _to.length; i++)
          [
            for (var s = 0; s < _to[i].length; s++)
              _lerp(_from, i, s, _progress(i, _to.length, _grow.value)),
          ],
      ];

  double _lerp(List<List<double>> from, int i, int s, double t) {
    final start = i < from.length && s < from[i].length ? from[i][s] : 0.0;
    return start + (_to[i][s] - start) * t;
  }

  void _tap(int? index) {
    if (index != null &&
        (index < 0 ||
            index >= widget.bars.length ||
            widget.bars[index].isFuture)) {
      index = null;
    }
    if (index == _selected) index = null;
    HapticFeedback.selectionClick();
    final previous = _shown;
    setState(() {
      _selected = index;
      if (index != null) _shown = index;
    });
    if (index != null) {
      // From one bar to the next: a short pop, without the other bars
      // flashing back to full color in between.
      _select.forward(
        from: previous == null
            ? 0
            : previous == index
                ? _select.value
                : 0.4,
      );
    } else {
      _select.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    return LayoutBuilder(builder: (context, constraints) {
      final geometry = _Geometry(
        width: constraints.maxWidth,
        count: bars.length,
        plotHeight: widget.plotHeight,
        maxValue: widget.maxValue,
        hasAxis: widget.ticks.isNotEmpty,
        barWidth: widget.barWidth,
      );
      final growLabels = CurvedAnimation(
        parent: _grow,
        curve: const Interval(0.55, 1, curve: Curves.easeOut),
      );
      final shown = _shown;

      return Semantics(
        container: true,
        label: [
          for (final bar in bars)
            if (!bar.isFuture) '${bar.tooltipTitle}: ${bar.tooltipBody}',
        ].join('، '),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (details) => _tap(geometry.indexAt(details.localPosition.dx)),
          child: SizedBox(
            height: geometry.height,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _BarsPainter(
                        geometry: geometry,
                        bars: bars,
                        from: _from,
                        to: _to,
                        grow: _grow,
                        select: _select,
                        selected: shown,
                        ticks: widget.ticks,
                        reference: widget.reference,
                      ),
                    ),
                  ),
                ),
                if (widget.tickLabel != null)
                  for (final tick in widget.ticks)
                    Positioned(
                      left: geometry.plotRight + 6,
                      width: _Geometry.axisWidth - 6,
                      top: geometry.yOf(tick) - 9,
                      child: ReText(
                        widget.tickLabel!(tick),
                        fontSize: 9.5,
                        fontWeight: 600,
                        color: StatColors.muted,
                        textAlign: TextAlign.right,
                      ),
                    ),
                if (widget.reference != null && widget.referenceLabel != null)
                  Positioned(
                    left: 0,
                    top: geometry.yOf(widget.reference!) - 11,
                    child: FadeTransition(
                      opacity: growLabels,
                      child: _ReferenceTag(widget.referenceLabel!),
                    ),
                  ),
                for (var i = 0; i < bars.length; i++)
                  if (bars[i].valueLabel != null &&
                      !bars[i].isFuture &&
                      bars[i].total > 0)
                    Positioned(
                      left: geometry.xOf(i) - 26,
                      width: 52,
                      top: geometry.yOf(bars[i].total) - 18,
                      child: FadeTransition(
                        opacity: growLabels,
                        child: FadeTransition(
                          opacity: i == shown
                              ? ReverseAnimation(_select)
                              : kAlwaysCompleteAnimation,
                          child: ReText(
                            bars[i].valueLabel!,
                            fontSize: 10.5,
                            fontWeight: 900,
                            color: StatColors.ink,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                for (var i = 0; i < bars.length; i++)
                  // Wider than a month's narrow slots; such labels are thinned
                  // out, so they never meet.
                  Positioned(
                    left: geometry.xOf(i) - 22,
                    width: 44,
                    top: geometry.plotBottom + 8,
                    child: _AxisLabel(bars[i]),
                  ),
                if (shown != null && shown < bars.length)
                  _tooltip(geometry, shown),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _tooltip(_Geometry geometry, int index) {
    const width = 170.0;
    final bar = widget.bars[index];
    final x = geometry.xOf(index);
    final top = geometry.yOf(bar.total) - (bar.total > 0 ? 8 : 14);
    final left = (x - width / 2).clamp(0.0, geometry.width - width);
    final curved = CurvedAnimation(parent: _select, curve: StatMotion.curve);
    return Positioned(
      left: left,
      width: width,
      bottom: geometry.height - top,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(curved),
            alignment: Alignment(((x - left) / width) * 2 - 1, 1),
            child: _Tooltip(
              title: bar.tooltipTitle,
              body: bar.tooltipBody,
              arrowX: x - left,
            ),
          ),
        ),
      ),
    );
  }
}

/// Where everything sits: bars from the right (RTL), the axis on the right.
class _Geometry {
  _Geometry({
    required this.width,
    required this.count,
    required this.plotHeight,
    required this.maxValue,
    required bool hasAxis,
    required double barWidth,
  })  : plotRight = width - (hasAxis ? axisWidth : 0),
        _barWidth = barWidth;

  static const axisWidth = 28.0;
  static const plotTop = 30.0;
  static const labelsHeight = 46.0;

  final double width;
  final int count;
  final double plotHeight;
  final double maxValue;
  final double plotRight;
  final double _barWidth;

  double get height => plotTop + plotHeight + labelsHeight;

  double get plotBottom => plotTop + plotHeight;

  double get slot => count == 0 ? plotRight : plotRight / count;

  double get barWidth => math.min(_barWidth, slot * 0.55);

  double xOf(int index) => plotRight - slot * (index + 0.5);

  double yOf(double value) =>
      plotBottom - plotHeight * (maxValue <= 0 ? 0 : value / maxValue);

  int? indexAt(double dx) {
    if (dx > plotRight) return null;
    return ((plotRight - dx) / slot).floor();
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.geometry,
    required this.bars,
    required this.from,
    required this.to,
    required this.grow,
    required this.select,
    required this.selected,
    required this.ticks,
    required this.reference,
  }) : super(repaint: Listenable.merge([grow, select]));

  final _Geometry geometry;
  final List<ChartBar> bars;
  final List<List<double>> from;
  final List<List<double>> to;
  final Animation<double> grow;
  final Animation<double> select;
  final int? selected;
  final List<double> ticks;
  final double? reference;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;

    final grid = Paint()
      ..color = const Color(0xFFE8E8EC)
      ..strokeWidth = 1;
    for (final tick in ticks) {
      if (tick == 0) continue;
      _dashed(canvas, g.yOf(tick), g.plotRight, grid, 3, 4);
    }
    canvas.drawLine(
      Offset(0, g.plotBottom),
      Offset(g.plotRight, g.plotBottom),
      Paint()
        ..color = StatColors.line
        ..strokeWidth = 1.5,
    );

    if (reference != null && reference! > 0) {
      final paint = Paint()
        ..color = StatColors.ink.withAlpha((110 * grow.value).round())
        ..strokeWidth = 1.3;
      _dashed(canvas, g.yOf(reference!), g.plotRight, paint, 6, 4);
    }

    final dim = select.value;
    for (var i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final x = g.xOf(i);
      if (bar.isFuture) {
        canvas.drawCircle(
          Offset(x, g.plotBottom - 6),
          3.5,
          Paint()
            ..color = StatColors.line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4,
        );
        continue;
      }
      final t = _progress(i, bars.length, grow.value);
      final values = [
        for (var s = 0; s < to[i].length; s++)
          (i < from.length && s < from[i].length ? from[i][s] : 0.0) +
              (to[i][s] - (i < from.length && s < from[i].length
                      ? from[i][s]
                      : 0.0)) *
                  t,
      ];
      final total = values.fold(0.0, (sum, v) => sum + v);
      if (total <= 0) {
        if (bar.total <= 0) {
          canvas.drawCircle(
            Offset(x, g.plotBottom - 6),
            4,
            Paint()..color = StatColors.line,
          );
        }
        continue;
      }

      final alpha = selected != null && i != selected ? 1 - 0.65 * dim : 1.0;
      final w = g.barWidth;
      var height = g.plotHeight * total / g.maxValue;
      if (height < 3) height = 3;
      final rect = Rect.fromLTWH(x - w / 2, g.plotBottom - height, w, height);
      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndCorners(
          rect,
          topLeft: Radius.circular(w / 2),
          topRight: Radius.circular(w / 2),
          bottomLeft: const Radius.circular(2),
          bottomRight: const Radius.circular(2),
        ),
      );
      var bottom = g.plotBottom;
      for (var s = 0; s < values.length; s++) {
        if (values[s] <= 0 || s >= bar.segments.length) continue;
        final h = height * values[s] / total;
        final color = bar.segments[s].color;
        canvas.drawRect(
          Rect.fromLTWH(rect.left, bottom - h, w, h),
          Paint()..color = color.withValues(alpha: color.a * alpha),
        );
        bottom -= h;
      }
      canvas.restore();
    }
  }

  void _dashed(
    Canvas canvas,
    double y,
    double right,
    Paint paint,
    double dash,
    double gap,
  ) {
    for (var x = 0.0; x < right; x += dash + gap) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dash, right), y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter oldDelegate) =>
      oldDelegate.bars != bars ||
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.selected != selected ||
      oldDelegate.geometry.width != geometry.width ||
      oldDelegate.geometry.maxValue != geometry.maxValue ||
      oldDelegate.reference != reference;
}

/// How far bar [index] of [count] has risen at [t]: they start one after
/// another from the right, and all land together.
double _progress(int index, int count, double t) {
  const spread = 0.3;
  final start = count <= 1 ? 0.0 : spread * index / (count - 1);
  final local = ((t - start) / (1 - spread)).clamp(0.0, 1.0);
  return StatMotion.curve.transform(local);
}

class _AxisLabel extends StatelessWidget {
  const _AxisLabel(this.bar);

  final ChartBar bar;

  @override
  Widget build(BuildContext context) {
    final faded = bar.isFuture;
    final strong = bar.isToday || bar.isFocused;
    final label = ReText(
      bar.label,
      fontSize: 11.5,
      fontWeight: strong ? 1000 : 700,
      color: bar.isFocused
          ? AppColors.white
          : faded
              ? StatColors.muted.withAlpha(120)
              : StatColors.ink,
      textAlign: TextAlign.center,
      maxLines: 1,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (bar.label.isNotEmpty)
          bar.isFocused
              ? Container(
                  width: 24,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: StatColors.ink,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: label,
                )
              : SizedBox(height: 20, child: Center(child: label)),
        if (bar.caption.isNotEmpty)
          ReText(
            bar.caption,
            fontSize: 10,
            fontWeight: strong ? 900 : 600,
            color: faded ? StatColors.muted.withAlpha(120) : StatColors.muted,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        const SizedBox(height: 3),
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
            color: bar.isToday ? StatColors.study : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _ReferenceTag extends StatelessWidget {
  const _ReferenceTag(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: StatColors.line),
      ),
      child: ReText(
        label,
        fontSize: 9.5,
        fontWeight: 800,
        color: StatColors.ink,
      ),
    );
  }
}

class _Tooltip extends StatelessWidget {
  const _Tooltip({
    required this.title,
    required this.body,
    required this.arrowX,
  });

  final String title;
  final String body;
  final double arrowX;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: StatColors.ink,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                blurRadius: 12,
                color: StatColors.ink.withAlpha(50),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                title,
                fontSize: 11.5,
                fontWeight: 900,
                color: AppColors.white,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
              ReText(
                body,
                fontSize: 10.5,
                fontWeight: 600,
                color: AppColors.white.withAlpha(195),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.only(left: (arrowX - 6).clamp(12.0, 146.0)),
            child: CustomPaint(
              size: const Size(12, 6),
              painter: _ArrowPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = StatColors.ink,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Grid values for a chart whose tallest bar is [max]: zero and two or three
/// round steps above it.
List<double> niceTicks(double max, List<double> steps) {
  if (max <= 0) return [0, steps.first, steps.first * 2];
  final step = steps.firstWhere(
    (step) => max / step <= 3,
    orElse: () => steps.last * (max / steps.last / 3).ceil(),
  );
  final count = (max / step).ceil().clamp(1, 3);
  return [for (var i = 0; i <= count; i++) i * step];
}
