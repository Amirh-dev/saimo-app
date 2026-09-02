import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:solar_icons/solar_icons.dart';

// Ensure you import your repository path here
// import 'package:simo_learn/data/repositories/task_timer_repository.dart';

class TaskTimerScreen extends StatefulWidget {
  final Map<String, dynamic> task;
  final VoidCallback onPop;

  const TaskTimerScreen({Key? key, required this.task, required this.onPop}) : super(key: key);

  @override
  State<TaskTimerScreen> createState() => _TaskTimerScreenState();
}

class _TaskTimerScreenState extends State<TaskTimerScreen> {
  final TaskTimerService _timer = TaskTimerService.instance;

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
    super.dispose();
  }

  Future<void> _toggleTimer() async {
    if (_timer.isRunning) {
      await _timer.pause();
    } else {
      await _timer.start();
    }
  }

  String _toPersianDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _timer,
      builder: (context, _) {
        final bool isRunning = _timer.isRunning;
        final bool isCompleted = _timer.isCompleted;
        final formattedRemaining = _toPersianDigits(_formatTime(_timer.remainingSeconds));
        final formattedTotal = _toPersianDigits(_formatTime(_timer.totalSeconds));

        return PopScope(
          onPopInvokedWithResult: (final v, final _) {
            widget.onPop();
          },
          child: Scaffold(
            backgroundColor: const Color(0xFFF5F6F9),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomCenter,
                    children: [
                      widget.task['note'] == null || widget.task['note'] == ''
                          ? const SizedBox()
                          : Positioned(
                              bottom: -150,
                              child: Container(
                                height: 100,
                                padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
                                alignment: Alignment.bottomCenter,
                                width: MediaQuery.of(context).size.width - 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xfffafafa).withAlpha(200),
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    )
                                  ],
                                ),
                                child: ReText(
                                  widget.task['note'],
                                  maxLines: 2,
                                  textAlign: TextAlign.start,
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: -85,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          alignment: Alignment.bottomCenter,
                          height: 200,
                          width: MediaQuery.of(context).size.width - 64,
                          decoration: BoxDecoration(
                            color: const Color(0xfffafafa),
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.chevron_left, size: 16, color: Colors.grey.shade700),
                                        const SizedBox(width: 4),
                                        Text(
                                          'جزئیات تسک',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.task['title'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF111827),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        widget.task['subtitle'] ?? '',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top White Container with Timer
                      Container(
                        padding: const EdgeInsets.only(top: 60, bottom: 60, left: 20, right: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // App Bar
                            reAppHeader(
                              'تایمــــر',
                              firstIcon: GestureDetector(
                                child: const Icon(SolarIconsOutline.bell, size: 24),
                              ),
                            ),
                            const SizedBox(height: 50),
                            // Custom Timer Arc
                            CustomPaint(
                              size: const Size(280, 240),
                              painter: TimerPainter(
                                totalSeconds: _timer.totalSeconds.toDouble(),
                                solidSeconds: _timer.solidSeconds.toDouble(),
                                hatchedSeconds: _timer.currentSessionSeconds.toDouble(),
                              ),
                              child: SizedBox(
                                width: 280,
                                height: 240,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 20),
                                    ReText(
                                      isCompleted ? 'انجام شده' : formattedRemaining,
                                      fontSize: isCompleted ? 25 : 54,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF1F2937),
                                    ),
                                    ReText(
                                      'از $formattedTotal',
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Floating Controls
                      Positioned(
                        bottom: -35,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Check Button (Manual Complete)
                            GestureDetector(
                              onTap: () async {
                                showShieldBottomSheet(context);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.success)),
                                    child: const Icon(IconsaxPlusBold.shield_tick, color: AppColors.success, size: 20),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Play/Pause Button
                            Opacity(
                              opacity: isCompleted ? 0.5 : 1,
                              child: GestureDetector(
                                onTap: isCompleted ? () {} : _toggleTimer,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: AppColors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Container(
                                    width: 70,
                                    height: 70,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isRunning ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Close Button
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gray)),
                                    child: const Icon(Icons.close, color: AppColors.black1, size: 15),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 60),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class TimerPainter extends CustomPainter {
  final double totalSeconds;
  final double solidSeconds;
  final double hatchedSeconds;

  TimerPainter({
    required this.totalSeconds,
    required this.solidSeconds,
    required this.hatchedSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Arc starts at 150 degrees (bottom-left) and sweeps 240 degrees to bottom-right
    const startAngle = 5 * pi / 6;
    const sweepAngle = 4 * pi / 3;
    const strokeW = 34.0;

    // 1. Draw Background Arc (Light Gray)
    final bgPaint = Paint()
      ..color = const Color(0xFFF1F3F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, startAngle, sweepAngle, false, bgPaint);

    final totalDrawn = solidSeconds + hatchedSeconds;

    // 2. Draw Hatched Arc (Light Blue with diagonal lines)
    if (totalDrawn > 0) {
      final totalSweep = (totalDrawn / totalSeconds) * sweepAngle;

      final hatchPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round
        ..shader = ui.Gradient.linear(
          Offset.zero,
          const Offset(18, 18),
          [
            const Color(0xFFA5B4FC),
            const Color(0xFFA5B4FC),
            const Color(0xFF818CF8),
            const Color(0xFF818CF8),
          ],
          [0.0, 0.5, 0.5, 1.0],
          TileMode.repeated,
        );

      canvas.drawArc(rect, startAngle, totalSweep, false, hatchPaint);
    }

    // 3. Draw Solid Arc (Dark Blue)
    if (solidSeconds > 0) {
      final solidSweep = (solidSeconds / totalSeconds) * sweepAngle;
      final solidPaint = Paint()
        ..color = const Color(0xFF3B82F6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(rect, startAngle, solidSweep, false, solidPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TimerPainter oldDelegate) {
    return oldDelegate.solidSeconds != solidSeconds || oldDelegate.hatchedSeconds != hatchedSeconds || oldDelegate.totalSeconds != totalSeconds;
  }
}

/// Explains what SimoGuard is and when it turns off.
///
/// Pass [isActive] to flip the header between the active and inactive state.
Future<void> showShieldBottomSheet(
  BuildContext context, {
  bool isActive = true,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) => _ShieldSheetContent(isActive: isActive),
  );
}

class _ShieldSheetContent extends StatelessWidget {
  final bool isActive;

  const _ShieldSheetContent({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final accent = isActive ? AppColors.success : AppColors.primary;

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
              // Header: glowing shield + status
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.45),
                          blurRadius: 22,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      IconsaxPlusBold.shield_tick,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      isActive ? 'سایموگارد فعال است' : 'سایموگارد غیرفعال است',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight(1000),
                        color: AppColors.black1,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              const Divider(height: 1, thickness: 1, color: AppColors.gray2),
              const SizedBox(height: 28),

              const _Section(
                title: 'سایموگارد چیه؟',
                body: 'وقتی سایموگارد فعاله ینی هرچی درس بخونی و از تایمر استفاده '
                    'کنی روی امتیاز گرفتنت تاثیر مثبتی می‌ذاره. اما وقتی سایموگارد '
                    'غیرفعال باشه دیگ امتیازی دریافت نمیکنی و تایمر هم متوقف می‌شه.',
              ),

              const SizedBox(height: 28),

              const _Section(
                title: 'چه زمانی سایموگارد غیرفعال می‌شه؟',
                body: 'زمانی که درحین مطالعه از اپلیکیشن خارج بشی، سایموگارد '
                    'غیرفعال می‌شه، تایمر متوقف می‌شه و دیگ امتیازی دریافت نمی‌کنی.',
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
