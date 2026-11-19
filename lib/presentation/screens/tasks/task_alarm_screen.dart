import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// Full-screen page shown when a task alarm rings, also over the lock
/// screen. The ringing itself belongs to the notification; this page offers
/// what to do next. It is dark at night and orange by day.
class TaskAlarmScreen extends StatefulWidget {
  const TaskAlarmScreen({
    super.key,
    required this.title,
    required this.at,
    this.tagName,
    this.minutes,
    required this.onStart,
    required this.onSnooze,
    required this.onDismiss,
    this.night,
    this.animate = true,
  });

  final String title;
  final DateTime at;
  final String? tagName;

  /// Planned length of a timed task; null for a regular task.
  final int? minutes;

  final VoidCallback onStart;
  final VoidCallback onSnooze;
  final VoidCallback onDismiss;

  /// Forces the night or day look; by default it follows [at].
  final bool? night;

  /// Off in screenshots and tests, where a repeating animation never settles.
  final bool animate;

  static const snoozeMinutes = 10;

  /// Night is 19:00 to 06:00: a dark page in a dark room.
  static bool isNight(DateTime at) => at.hour >= 19 || at.hour < 6;

  @override
  State<TaskAlarmScreen> createState() => _TaskAlarmScreenState();
}

const _nightBg = Color(0xFF15151B);
const _nightGlow = Color(0xFF3A1E17);
const _nightCard = Color(0xFF22222B);
const _nightSoft = Color(0xFF9A9AA6);
const _dayTop = Color(0xFFFF6A43);
const _dayBottom = Color(0xFFD93A16);
const _daySoft = Color(0xFFFFD9CE);

class _TaskAlarmScreenState extends State<TaskAlarmScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
    value: 0.3,
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _pulse.repeat();
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  bool get _night => widget.night ?? TaskAlarmScreen.isNight(widget.at);

  bool get _timed => widget.minutes != null && widget.minutes! > 0;

  String get _time =>
      '${widget.at.hour.toString().padLeft(2, '0')}:${widget.at.minute.toString().padLeft(2, '0')}';

  String get _date {
    final j = Jalali.fromDateTime(widget.at);
    return '${JalaliText.weekday(j)}، ${j.day} ${JalaliText.month(j)}';
  }

  String get _details => [
        if (widget.tagName != null && widget.tagName!.isNotEmpty) widget.tagName!,
        if (_timed) '${widget.minutes} دقیقه',
      ].join('، ');

  @override
  Widget build(BuildContext context) {
    final night = _night;
    final soft = night ? _nightSoft : _daySoft;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: night ? _nightBg : AppColors.primary,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: night
                  ? const RadialGradient(
                      center: Alignment(0, -0.4),
                      radius: 0.9,
                      colors: [_nightGlow, _nightBg],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_dayTop, AppColors.primary, _dayBottom],
                    ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  children: [
                    _TopBar(color: soft, onDismiss: widget.onDismiss),
                    const Spacer(flex: 3),
                    _Bell(pulse: _pulse, night: night),
                    const SizedBox(height: 20),
                    ReText(_time,
                        fontSize: night ? 76 : 84,
                        fontWeight: 1000,
                        color: Colors.white,
                        textAlign: TextAlign.center,
                        lineHeight: 1.05),
                    const SizedBox(height: 4),
                    ReText(_date,
                        fontSize: 15, color: soft, textAlign: TextAlign.center),
                    const Spacer(flex: 3),
                    if (night)
                      _NightCard(
                          title: widget.title, details: _details, timed: _timed)
                    else
                      _DayTitle(title: widget.title, details: _details),
                    const Spacer(flex: 2),
                    _SnoozeButton(outlined: !night, onTap: widget.onSnooze),
                    const SizedBox(height: 14),
                    _SlideToStart(
                      label: _timed ? 'بکش تا تایمر شروع شه' : 'بکش بریم سراغش',
                      icon: _timed
                          ? IconsaxPlusBold.timer_start
                          : IconsaxPlusLinear.arrow_left,
                      track: night
                          ? _nightCard
                          : Colors.white.withValues(alpha: 0.18),
                      fill: night
                          ? AppColors.primary.withValues(alpha: 0.25)
                          : Colors.white.withValues(alpha: 0.22),
                      knob: night ? AppColors.primary : Colors.white,
                      knobIcon: night ? Colors.white : AppColors.primary,
                      onDone: widget.onStart,
                      animate: widget.animate,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.color, required this.onDismiss});

  final Color color;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        children: [
          ReText('یادآوری تسک', fontSize: 13, fontWeight: 700, color: color),
          const Spacer(),
          IconButton(
            key: const ValueKey('task-alarm-dismiss'),
            onPressed: onDismiss,
            icon: Icon(Icons.close_rounded, color: color, size: 22),
          ),
        ],
      ),
    );
  }
}

/// The bell, swinging at the start of every pulse, inside rings that keep
/// spreading while it rings.
class _Bell extends StatelessWidget {
  const _Bell({required this.pulse, required this.night});

  final Animation<double> pulse;
  final bool night;

  @override
  Widget build(BuildContext context) {
    final ringColor = night ? AppColors.primary : Colors.white;
    return SizedBox(
      width: 200,
      height: 200,
      child: AnimatedBuilder(
        animation: pulse,
        builder: (context, child) {
          Widget ring(double phase) {
            final t = (pulse.value + phase) % 1;
            return Transform.scale(
              scale: 0.46 + 0.54 * t,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: night ? null : Colors.white.withValues(alpha: 0.14 * (1 - t)),
                  border: night
                      ? Border.all(
                          color: ringColor.withValues(alpha: 0.55 * (1 - t)),
                          width: 1.2)
                      : null,
                ),
              ),
            );
          }

          final swing = pulse.value < 0.33
              ? sin(pulse.value * 2 * pi * 3) * 0.14 * (1 - pulse.value * 3)
              : 0.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(child: ring(0)),
              Positioned.fill(child: ring(1 / 3)),
              Positioned.fill(child: ring(2 / 3)),
              Container(
                width: night ? 92 : 88,
                height: night ? 92 : 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: night ? AppColors.primary : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: night
                          ? AppColors.primary.withValues(alpha: 0.6)
                          : _dayBottom.withValues(alpha: 0.35),
                      blurRadius: night ? 40 : 24,
                      offset: night ? Offset.zero : const Offset(0, 8),
                    ),
                  ],
                ),
                child: Transform.rotate(
                  angle: swing,
                  alignment: const Alignment(0, -0.6),
                  child: Icon(IconsaxPlusBold.notification_bing,
                      size: 42,
                      color: night ? Colors.white : AppColors.primary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NightCard extends StatelessWidget {
  const _NightCard(
      {required this.title, required this.details, required this.timed});

  final String title;
  final String details;
  final bool timed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: _nightCard, borderRadius: BorderRadius.circular(24)),
      child: Row(
        children: [
          Icon(timed ? IconsaxPlusBold.timer_1 : IconsaxPlusBold.task_square,
              color: AppColors.primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ReText(title,
                      fontSize: 17,
                      fontWeight: 900,
                      color: Colors.white,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      lineHeight: 1.5),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  ReText(details, fontSize: 12.5, color: _nightSoft),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTitle extends StatelessWidget {
  const _DayTitle({required this.title, required this.details});

  final String title;
  final String details;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ReText('وقتشه!',
            fontSize: 15, fontWeight: 700, color: _daySoft),
        const SizedBox(height: 6),
        SizedBox(
          width: double.infinity,
          child: ReText(title,
              fontSize: 26,
              fontWeight: 1000,
              color: Colors.white,
              textAlign: TextAlign.center,
              maxLines: 2,
              lineHeight: 1.45),
        ),
        if (details.isNotEmpty) ...[
          const SizedBox(height: 4),
          ReText(details,
              fontSize: 13.5, color: _daySoft, textAlign: TextAlign.center),
        ],
      ],
    );
  }
}

class _SnoozeButton extends StatelessWidget {
  const _SnoozeButton({required this.outlined, required this.onTap});

  final bool outlined;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: const ValueKey('task-alarm-snooze'),
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: outlined
                  ? BorderSide(color: Colors.white.withValues(alpha: 0.5))
                  : BorderSide.none,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(IconsaxPlusLinear.clock, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              ReText('${TaskAlarmScreen.snoozeMinutes} دقیقه دیگه',
                  fontSize: 14, fontWeight: 700, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

/// Capsule with a knob dragged from the right edge to the left one. A slide,
/// not a tap, so a pocket or a sleepy hand can't start the task.
class _SlideToStart extends StatefulWidget {
  const _SlideToStart({
    required this.label,
    required this.icon,
    required this.track,
    required this.fill,
    required this.knob,
    required this.knobIcon,
    required this.onDone,
    required this.animate,
  });

  final String label;
  final IconData icon;
  final Color track;
  final Color fill;
  final Color knob;
  final Color knobIcon;
  final VoidCallback onDone;
  final bool animate;

  @override
  State<_SlideToStart> createState() => _SlideToStartState();
}

class _SlideToStartState extends State<_SlideToStart>
    with TickerProviderStateMixin {
  static const _height = 66.0;
  static const _knobSize = 56.0;
  static const _inset = 5.0;

  double _drag = 0;
  double _backFrom = 0;
  bool _done = false;

  late final AnimationController _shine = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
    value: 0.55,
  );
  late final AnimationController _back = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..addListener(() => setState(() =>
      _drag = _backFrom * (1 - Curves.easeOut.transform(_back.value))));

  @override
  void initState() {
    super.initState();
    if (widget.animate) _shine.repeat();
  }

  @override
  void dispose() {
    _shine.dispose();
    _back.dispose();
    super.dispose();
  }

  void _release(double max) {
    if (_done) return;
    if (_drag > max * 0.8) {
      setState(() {
        _drag = max;
        _done = true;
      });
      HapticFeedback.mediumImpact();
      widget.onDone();
    } else {
      _backFrom = _drag;
      _back.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final max = constraints.maxWidth - _knobSize - _inset * 2;
      final progress = max <= 0 ? 0.0 : (_drag / max).clamp(0.0, 1.0);
      return Container(
        key: const ValueKey('task-alarm-start'),
        height: _height,
        decoration:
            ShapeDecoration(color: widget.track, shape: const StadiumBorder()),
        child: Stack(
          children: [
            // Fill trailing the knob.
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              width: _drag + _knobSize + _inset * 2,
              child: DecoratedBox(
                decoration: ShapeDecoration(
                    color: widget.fill, shape: const StadiumBorder()),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 1 - progress,
                child: Padding(
                  padding: const EdgeInsets.only(right: _knobSize + 8),
                  child: Center(
                    child: AnimatedBuilder(
                      animation: _shine,
                      builder: (context, child) => ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) {
                          // A light sweep running the way the knob goes.
                          final x = 1.4 - _shine.value * 2.8;
                          return LinearGradient(
                            begin: Alignment(x - 0.5, 0),
                            end: Alignment(x + 0.5, 0),
                            colors: [
                              Colors.white.withValues(alpha: 0.6),
                              Colors.white,
                              Colors.white.withValues(alpha: 0.6),
                            ],
                          ).createShader(bounds);
                        },
                        child: child,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: ReText(widget.label,
                                fontSize: 15,
                                fontWeight: 700,
                                color: Colors.white),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.keyboard_double_arrow_left_rounded,
                              size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: _inset + _drag,
              top: _inset,
              child: GestureDetector(
                key: const ValueKey('task-alarm-knob'),
                onHorizontalDragUpdate: _done
                    ? null
                    : (details) {
                        _back.stop();
                        setState(() => _drag =
                            (_drag - details.delta.dx).clamp(0.0, max));
                      },
                onHorizontalDragEnd: (_) => _release(max),
                child: Container(
                  width: _knobSize,
                  height: _knobSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.knob,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: widget.knobIcon, size: 24),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
