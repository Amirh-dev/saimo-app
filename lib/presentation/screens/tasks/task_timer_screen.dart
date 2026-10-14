import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/simo_guard.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';

/// Where the loaded task stands; it picks the status label and the dial's
/// color, following the app's task stage colors.
enum _Stage { ready, running, paused, done }

class TaskTimerScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onPop;

  const TaskTimerScreen({Key? key, required this.task, required this.onPop}) : super(key: key);

  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen> with SingleTickerProviderStateMixin {
  final TaskTimerService _timer = TaskTimerService.instance;

  /// True while a start, pause or finish is on its way to the server, so a
  /// second tap cannot flip the timer back before the first one lands.
  bool _busy = false;

  /// Plays once on entry: the dial draws itself, the time studied pours into
  /// it, and the rest rises into place. See [_Intro].
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_intro.isAnimating || _intro.isCompleted) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _intro.value = 1;
    } else {
      _intro.forward();
    }
  }

  @override
  void initState() {
    super.initState();

    // Give the global service a repository (safe to call more than once).
    _timer.bindRepository(TaskTimerRepository(context.read<GraphQLRepository>()));

    // Load this task into the service. If this exact task is already running
    // in the background, load() is a no-op and the session keeps going.
    // If a *different* task is currently running, load() pauses it first
    // (state + API) before switching over. See TaskTimerService.load.
    _timer.load(
      taskId: widget.task['id'] as String,
      totalSeconds: widget.task['durationSeconds'] as int? ?? 2700,
      elapsedSeconds: widget.task['elapsedSeconds'] as int? ?? 0,
      isDone: widget.task['status'] == 'done',
      taskData: widget.task,
    );

    // Hide the floating banner while this screen is on top.
    _timer.timerScreenOpened();
  }

  @override
  void dispose() {
    // Only tell the service we left. The timer itself keeps running.
    _timer.timerScreenClosed();
    _intro.dispose();
    super.dispose();
  }

  _Stage get _stage {
    if (_timer.isCompleted) return _Stage.done;
    if (_timer.isRunning) return _Stage.running;
    return _timer.elapsedSeconds > 0 ? _Stage.paused : _Stage.ready;
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _toggleTimer() => _run(() async {
        HapticFeedback.mediumImpact();
        if (_timer.isRunning) {
          await _timer.pause();
          return;
        }
        final started = await _timer.start();
        if (!started && !_timer.isCompleted && mounted) {
          showReToast(
            context,
            'شروع تایمر ناموفق بود. دوباره تلاش کنید.',
            ReToastType.failed,
          );
        }
      });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_timer, SimoGuard.instance, _intro]),
      builder: (context, _) {
        final stage = _stage;
        final intro = _Intro(_intro.value);

        return PopScope(
          onPopInvokedWithResult: (final v, final _) {
            widget.onPop();
          },
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              backgroundColor: AppColors.gray1,
              body: SafeArea(
                child: Column(
                  children: [
                    _Header(
                      guardOn: SimoGuard.instance.enabled,
                      onBack: () => Navigator.of(context).maybePop(),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _TimerCard(
                              task: widget.task,
                              stage: stage,
                              timer: _timer,
                              intro: intro,
                            ),
                            if (_note case final note?) ...[
                              const SizedBox(height: 12),
                              _Rise(t: intro.rise(3), child: _NoteCard(note: note)),
                            ],
                          ],
                        ),
                      ),
                    ),
                    _Rise(
                      t: intro.rise(4),
                      child: _Controls(
                        stage: stage,
                        busy: _busy,
                        onToggle: _toggleTimer,
                        onBack: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String? get _note {
    final note = (widget.task['note'] as String?)?.trim();
    return note == null || note.isEmpty ? null : note;
  }
}

/// `mm:ss`, or `h:mm:ss` from an hour up.
String _clock(int seconds) {
  final safe = max(0, seconds);
  final h = safe ~/ 3600;
  final m = (safe % 3600) ~/ 60;
  final s = safe % 60;
  String two(int v) => v.toString().padLeft(2, '0');
  return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
}

/// The entry animation's phases, read off one controller running 0 to 1.
class _Intro {
  const _Intro(this.t);

  final double t;

  double _phase(double from, double to, Curve curve) =>
      curve.transform(((t - from) / (to - from)).clamp(0.0, 1.0));

  /// The dial's track drawing itself, from the right.
  double get track => _phase(0.0, 0.45, Curves.easeOutCubic);

  /// The time studied pouring into the dial; the clock and the stats count
  /// along with it.
  double get fill => _phase(0.3, 0.95, Curves.easeOutQuart);

  /// The done check popping in once the dial is full.
  double get check => _phase(0.7, 1.0, Curves.easeOutBack);

  /// The parts of the screen rising into place, one after another.
  double rise(int order) => _phase(0.08 * order, 0.08 * order + 0.4, Curves.easeOutCubic);
}

/// Fades [child] in as it rises the last few pixels into place.
class _Rise extends StatelessWidget {
  final double t;
  final Widget child;

  const _Rise({required this.t, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: t.clamp(0.0, 1.0),
      child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
    );
  }
}

Color _stageColor(_Stage stage) => switch (stage) {
      _Stage.ready => AppColors.gray,
      _Stage.running => AppColors.primary,
      _Stage.paused => AppColors.secondary,
      _Stage.done => AppColors.done,
    };

class _Header extends StatelessWidget {
  final bool guardOn;
  final VoidCallback onBack;

  const _Header({required this.guardOn, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 4),
      child: Row(
        children: [
          IconButton(
            key: const ValueKey('timer-back'),
            tooltip: 'بازگشت',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.black1),
          ),
          const SizedBox(width: 4),
          const ReText(
            'تایمــــر',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.black1,
          ),
          const Spacer(),
          Material(
            color: AppColors.white,
            shape: const StadiumBorder(side: BorderSide(color: AppColors.gray2)),
            child: InkWell(
              key: const ValueKey('timer-guard'),
              customBorder: const StadiumBorder(),
              onTap: () => showShieldBottomSheet(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      IconsaxPlusBold.shield_tick,
                      size: 18,
                      color: guardOn ? AppColors.done : AppColors.gray,
                    ),
                    const SizedBox(width: 6),
                    const ReText(
                      'سایموگارد',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.black1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  final Map<String, dynamic> task;
  final _Stage stage;
  final TaskTimerService timer;
  final _Intro intro;

  const _TimerCard({required this.task, required this.stage, required this.timer, required this.intro});

  @override
  Widget build(BuildContext context) {
    final title = (task['title'] as String?)?.trim() ?? '';
    final subtitle = (task['subtitle'] as String?)?.trim() ?? '';
    final note = (task['note'] as String?)?.trim() ?? '';
    final color = _stageColor(stage);
    final done = stage == _Stage.done;
    final fill = intro.fill;
    final elapsed = (timer.elapsedSeconds * fill).round();

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Rise(
            t: intro.rise(0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReText(
                  title,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                ),
                // The note gets its own card, so it is not repeated here.
                if (subtitle.isNotEmpty && subtitle != note) ...[
                  const SizedBox(height: 4),
                  ReText(
                    subtitle,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray,
                    textAlign: TextAlign.start,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.gray2),
          const SizedBox(height: 20),
          Center(child: _Rise(t: intro.rise(1), child: _StatusPill(stage: stage))),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: 260,
              height: 150,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TimerPainter(
                        totalSeconds: timer.totalSeconds.toDouble(),
                        solidSeconds: timer.solidSeconds * fill,
                        hatchedSeconds: timer.currentSessionSeconds * fill,
                        trackFraction: intro.track,
                        color: color,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: done
                          ? [
                              Transform.scale(
                                scale: intro.check,
                                child: const Icon(Icons.check_circle_rounded, color: AppColors.done, size: 36),
                              ),
                              const SizedBox(height: 6),
                              ReText(
                                '${_clock(elapsed)} مطالعه',
                                key: const ValueKey('timer-clock'),
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.black1,
                                textAlign: TextAlign.center,
                              ),
                            ]
                          : [
                              ReText(
                                // Counts down from the full duration while the
                                // time studied pours into the dial.
                                _clock(timer.totalSeconds - elapsed),
                                key: const ValueKey('timer-clock'),
                                fontSize: 40,
                                fontWeight: const FontWeight(1000),
                                color: AppColors.black1,
                                textAlign: TextAlign.center,
                              ),
                              ReText(
                                'باقی‌مانده از ${_clock(timer.totalSeconds)}',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.gray,
                                textAlign: TextAlign.center,
                              ),
                            ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _Rise(
            t: intro.rise(2),
            child: _Stats(timer: timer, stage: stage, fill: fill),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final _Stage stage;

  const _StatusPill({required this.stage});

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(stage);
    final label = switch (stage) {
      _Stage.ready => 'آماده‌ی شروع',
      _Stage.running => 'در حال مطالعه',
      _Stage.paused => 'متوقف شده',
      _Stage.done => 'انجام شد',
    };

    return AnimatedContainer(
      key: const ValueKey('timer-status'),
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          ReText(label, fontSize: 12, fontWeight: FontWeight.w800, color: color),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final TaskTimerService timer;
  final _Stage stage;

  /// How far the entry animation has counted the numbers up, 0 to 1.
  final double fill;

  const _Stats({required this.timer, required this.stage, required this.fill});

  @override
  Widget build(BuildContext context) {
    final percent = (timer.progress * 100 * fill).floor();
    final cells = [
      ('انجام‌شده', _clock((timer.elapsedSeconds * fill).round())),
      // Time since the last start, without a pause.
      if (stage == _Stage.running) ('این دور', _clock((timer.currentSessionSeconds * fill).round())),
      ('پیشرفت', '$percent٪'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          for (final (i, (label, value)) in cells.indexed) ...[
            if (i > 0) Container(width: 1, height: 28, color: AppColors.gray2),
            Expanded(
              child: Column(
                children: [
                  ReText(label, fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.gray),
                  const SizedBox(height: 2),
                  ReText(value, fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.black1),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  final String note;

  const _NoteCard({required this.note});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(IconsaxPlusLinear.note_1, size: 16, color: AppColors.gray),
              SizedBox(width: 6),
              ReText('یادداشت', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.gray),
            ],
          ),
          const SizedBox(height: 8),
          ReText(
            note,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black1,
            textAlign: TextAlign.start,
            maxLines: 6,
            lineHeight: 1.7,
          ),
        ],
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  final _Stage stage;
  final bool busy;
  final VoidCallback onToggle;
  final VoidCallback onBack;

  const _Controls({
    required this.stage,
    required this.busy,
    required this.onToggle,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    if (stage == _Stage.done) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: _PillButton(
          key: const ValueKey('timer-done-back'),
          label: 'بازگشت به تسک‌ها',
          background: AppColors.black1,
          foreground: AppColors.white,
          onTap: onBack,
        ),
      );
    }

    final running = stage == _Stage.running;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PillButton(
            key: const ValueKey('timer-toggle'),
            label: switch (stage) {
              _Stage.running => 'توقف',
              _Stage.paused => 'ادامه',
              _ => 'شروع',
            },
            icon: running ? Icons.pause_rounded : Icons.play_arrow_rounded,
            // Orange invites starting; a running timer's stop is calm.
            background: running ? AppColors.black1 : AppColors.primary,
            foreground: AppColors.white,
            onTap: busy ? null : onToggle,
          ),
          const SizedBox(height: 10),
          // Kept at a fixed height so the buttons never jump.
          SizedBox(
            height: 18,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              opacity: running ? 1 : 0,
              child: const ReText(
                'با خروج از این صفحه، تایمر ادامه پیدا می‌کند.',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  const _PillButton({
    super.key,
    required this.label,
    this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: Material(
        color: background,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 56,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: foreground, size: 24),
                  const SizedBox(width: 6),
                ],
                ReText(label, fontSize: 15, fontWeight: FontWeight.w800, color: foreground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  final double totalSeconds;
  final double solidSeconds;
  final double hatchedSeconds;
  final Color color;

  /// How much of the track is drawn, 0 to 1; below 1 only while the dial
  /// draws itself in.
  final double trackFraction;

  TimerPainter({
    required this.totalSeconds,
    required this.solidSeconds,
    required this.hatchedSeconds,
    this.color = AppColors.secondary,
    this.trackFraction = 1,
  });

  static const double _strokeWidth = 26;

  // The half circle from the left end, over the top, to the right end.
  static const double _startAngle = pi;
  static const double _sweepAngle = pi;

  @override
  void paint(Canvas canvas, Size size) {
    // Progress runs right to left, the way the app's text reads.
    canvas.translate(size.width, 0);
    canvas.scale(-1, 1);

    // The arc and its round ends fit inside [size]: full width, and the ends
    // reach half a stroke below the center.
    final radius = (size.width - _strokeWidth) / 2;
    final center = Offset(size.width / 2, radius + _strokeWidth / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. The track (light gray), round at both ends. While it draws itself
    // in, its growing end is round too.
    Paint track(Paint paint) => paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = _strokeWidth
      ..strokeCap = StrokeCap.round;
    if (trackFraction <= 0) return;
    canvas.drawArc(rect, _startAngle, _sweepAngle * trackFraction.clamp(0.0, 1.0), false,
        track(Paint()..color = AppColors.gray2));

    if (totalSeconds <= 0) return;

    // Progress is the track itself, in color, cut at the progress angle.
    // Drawing it as its own round-capped arc (as before) put a cap half the
    // stroke wide past the true end: about 9% showed at 1%, and the end
    // always ran ahead. Clipping keeps it exact, inside the track, with the
    // round ends filled as it reaches them.
    void fillTo(double seconds, Paint paint) {
      final fraction = (seconds / totalSeconds).clamp(0.0, 1.0);
      if (fraction <= 0) return;
      canvas.save();
      canvas.clipPath(_wedge(center, radius, fraction));
      canvas.drawArc(rect, _startAngle, _sweepAngle, false, track(paint));
      canvas.restore();
    }

    // 2. This session so far (hatched), under what was already done.
    fillTo(
      solidSeconds + hatchedSeconds,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(5, 5),
          [
            color.withAlpha(200),
            color.withAlpha(200),
            color.withAlpha(120),
            color.withAlpha(120),
          ],
          [0.0, 0.2, 0.2, 1.0],
          TileMode.repeated,
        ),
    );

    // 3. Earlier sessions (solid).
    fillTo(solidSeconds, Paint()..color = color);
  }

  /// The slice of the dial from the start of the track (its round end
  /// included) to [fraction] of the way to the end of the other round end.
  static Path _wedge(Offset center, double radius, double fraction) {
    // How far, as an angle seen from the center, a round end reaches past
    // the arc's own end.
    final capAngle = atan((_strokeWidth / 2) / (radius - _strokeWidth / 2));
    final from = _startAngle - capAngle;
    final sweep = (_sweepAngle + 2 * capAngle) * fraction;
    final reach = radius + _strokeWidth;
    return Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(Rect.fromCircle(center: center, radius: reach), from, sweep,
          false)
      ..close();
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.solidSeconds != solidSeconds ||
        oldDelegate.hatchedSeconds != hatchedSeconds ||
        oldDelegate.totalSeconds != totalSeconds ||
        oldDelegate.color != color ||
        oldDelegate.trackFraction != trackFraction;
  }
}

/// Explains SimoGuard and turns it on or off.
Future<void> showShieldBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) => const _ShieldSheetContent(),
  );
}

class _ShieldSheetContent extends StatelessWidget {
  const _ShieldSheetContent();

  @override
  Widget build(BuildContext context) {
    final guard = SimoGuard.instance;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: shield, status and the switch.
              ListenableBuilder(
                listenable: guard,
                builder: (context, _) {
                  final on = guard.enabled;
                  return Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: on ? AppColors.done : AppColors.gray2,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          IconsaxPlusBold.shield_tick,
                          color: on ? AppColors.white : AppColors.gray,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ReText(
                          on ? 'سایموگارد روشن است' : 'سایموگارد خاموش است',
                          key: const ValueKey('simo-guard-status'),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                          textAlign: TextAlign.start,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _GuardSwitch(
                        value: on,
                        onChanged: (value) {
                          HapticFeedback.selectionClick();
                          guard.setEnabled(value);
                        },
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1, color: AppColors.gray2),
              const SizedBox(height: 28),

              const _Section(
                title: 'سایموگارد چیست؟',
                body: 'سایموگارد کمک می‌کند تمرکزتان را حفظ کنید و فقط زمانی ثبت '
                    'شود که واقعاً مطالعه کرده‌اید. وقتی روشن باشد، خروج از برنامه '
                    'در حین کار تایمر، تایمر را متوقف می‌کند.',
              ),

              const SizedBox(height: 28),

              const _Section(
                title: 'چه زمانی تایمر متوقف می‌شود؟',
                body: 'اگر سایموگارد روشن باشد و تایمر در حال اجرا باشد، با رفتن به '
                    'برنامه‌ای دیگر یا بستن برنامه، تایمر متوقف می‌شود. قفل شدن گوشی '
                    'تایمر را متوقف نمی‌کند. با بازگشت به برنامه می‌توانید تایمر را '
                    'ادامه دهید.',
              ),

              const SizedBox(height: 36),

              // Confirm
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gray2, width: 1.5),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: const ReText(
                    'تایید',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app's switch, as on the task form's reminder row.
class _GuardSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _GuardSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      label: 'سایموگارد',
      child: GestureDetector(
        key: const ValueKey('simo-guard-switch'),
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            width: 44,
            height: 28,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: value ? AppColors.primary.withAlpha(64) : AppColors.gray2,
              borderRadius: BorderRadius.circular(100),
            ),
            // In RTL, start is the right: off on the right, on on the left.
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? AppColors.primary : AppColors.dark4Color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;

  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReText(
          title,
          fontSize: 17,
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ),
        const SizedBox(height: 12),
        ReText(
          body,
          textAlign: TextAlign.justify,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.gray,
          maxLines: 100,
        ),
      ],
    );
  }
}
