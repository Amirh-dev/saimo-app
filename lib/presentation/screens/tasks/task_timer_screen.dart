import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:developer' as developer;

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
  bool _isRunning = false;
  bool _isCompleted = false;

  int _solidSeconds = 0;
  int _currentSessionSeconds = 0;
  late TaskTimerRepository _timerRepo;

  @override
  void initState() {
    super.initState();
    GlobalData.instance.globalTotalSeconds = widget.task['durationSeconds'] ?? 2700;
    GlobalData.instance.globalRemainingSeconds = widget.task['remainingSeconds'] ?? 2700;
    _solidSeconds = GlobalData.instance.globalTotalSeconds - GlobalData.instance.globalRemainingSeconds;
    if (GlobalData.instance.globalRemainingSeconds == 0) {
      _isCompleted = true;
    }
    // Initialize the repository
    _timerRepo = TaskTimerRepository(context.read<GraphQLRepository>());
    if (widget.task['status'] == 'running') {
      _isRunning = true;
      // GlobalData.instance.globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      //   if (GlobalData.instance.globalRemainingSeconds > 0) {
      //     setState(() {
      //       GlobalData.instance.globalRemainingSeconds--;
      //       _currentSessionSeconds++;
      //     });
      //   } else {
      //     // Auto-complete when time runs out
      //     GlobalData.instance.globalTimer.cancel();
      //     setState(() {
      //       _isRunning = false;
      //       _solidSeconds += _currentSessionSeconds;
      //       _currentSessionSeconds = 0;
      //     });
      //     await _completeTask();
      //   }
      // });
    }
  }

  @override
  void dispose() {
    // GlobalData.instance.globalTimer.cancel();
    super.dispose();
  }

  Future<void> _completeTask() async {
    final taskId = widget.task['id'];
    if (taskId == null) return;

    developer.log('🏁 Completing timed task: $taskId', name: 'TaskTimer');
    try {
      await _timerRepo.completeTimedTask(taskId);
      developer.log('✅ Task completed successfully.', name: 'TaskTimer');
    } catch (e) {
      developer.log('❌ Failed to complete task: $e', name: 'TaskTimer', error: e);
    }
  }

  void _toggleTimer() async {
    final taskId = widget.task['id'];
    if (taskId == null) return;

    if (_isRunning) {
      // Pause Logic
      GlobalData.instance.globalTimer.cancel();
      setState(() {
        _isRunning = false;
        _solidSeconds += _currentSessionSeconds;
        _currentSessionSeconds = 0;
      });

      developer.log('⏸️ Pausing timer for task: $taskId', name: 'TaskTimer');
      try {
        await _timerRepo.pauseTimedTask(taskId);
        developer.log('✅ Task paused successfully.', name: 'TaskTimer');
      } catch (e) {
        developer.log('❌ Failed to pause task: $e', name: 'TaskTimer', error: e);
      }
    } else {
      // Play Logic
      if (GlobalData.instance.globalRemainingSeconds > 0) {
        setState(() {
          _isRunning = true;
        });

        developer.log('▶️ Starting timer for task: $taskId', name: 'TaskTimer');
        try {
          await _timerRepo.startTimedTask(taskId);
          developer.log('✅ Task started successfully.', name: 'TaskTimer');
        } catch (e) {
          developer.log('❌ Failed to start task: $e', name: 'TaskTimer', error: e);
        }

        GlobalData.instance.globalTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
          if (GlobalData.instance.globalRemainingSeconds > 0) {
            setState(() {
              GlobalData.instance.globalRemainingSeconds--;
              _currentSessionSeconds++;
            });
            debugPrint("CURRENT TASK REMAINING SEC: ${GlobalData.instance.globalRemainingSeconds}");
          } else {
            // Auto-complete when time runs out
            GlobalData.instance.globalTimer.cancel();
            setState(() {
              _isRunning = false;
              _solidSeconds += _currentSessionSeconds;
              _currentSessionSeconds = 0;
            });
            await _completeTask();
          }
        });
      }
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
    final formattedRemaining = _toPersianDigits(_formatTime(GlobalData.instance.globalRemainingSeconds));
    final formattedTotal = _toPersianDigits(_formatTime(GlobalData.instance.globalTotalSeconds));

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
                            totalSeconds: GlobalData.instance.globalTotalSeconds.toDouble(),
                            solidSeconds: _solidSeconds.toDouble(),
                            hatchedSeconds: _currentSessionSeconds.toDouble(),
                          ),
                          child: SizedBox(
                            width: 280,
                            height: 240,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 20),
                                ReText(
                                  _isCompleted ? 'انجام شده' : formattedRemaining,
                                  fontSize: _isCompleted ? 25 : 54,
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
                            GlobalData.instance.globalTimer.cancel();
                            setState(() {
                              _isRunning = false;
                            });
                            await _completeTask();
                            if (mounted) {
                              Navigator.pop(context);
                            }
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
                          opacity: _isCompleted ? 0.5 : 1,
                          child: GestureDetector(
                            onTap: _isCompleted ? (){} : _toggleTimer,
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
                                  _isRunning ? Icons.pause : Icons.play_arrow,
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
