import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:simo_learn/presentation/screens/tasks/task_timer_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';

/// Floating "dynamic island" style timer.
///
/// It shows the task that the global [TaskTimerService] currently holds, and
/// hides itself automatically while [TaskTimerScreen] is open. Mount it once,
/// app-wide, through `MaterialApp.builder` (see the notes in chat).
class TaskTimerBanner extends StatelessWidget {
  /// Distance from the bottom of the screen. Raise it so the banner floats
  /// above your bottom navigation bar.
  final double bottomOffset;

  /// Needed to push the timer screen from outside the Navigator's subtree.
  final GlobalKey<NavigatorState>? navigatorKey;

  const TaskTimerBanner({
    super.key,
    this.bottomOffset = 110,
    this.navigatorKey,
  });

  static const Color _background = Color(0xFF1A1A1A);
  static const Color _accent = Color(0xFFEE5A2B);

  String _toPersianDigits(String text) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    for (int i = 0; i < english.length; i++) {
      text = text.replaceAll(english[i], persian[i]);
    }
    return text;
  }

  String _formatTime(int seconds) {
    final safe = math.max(0, seconds);
    final m = safe ~/ 60;
    final s = safe % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _openTimerScreen(BuildContext context, TaskTimerService timer) {
    final task = timer.taskData;
    if (task == null) return;

    final navigator = navigatorKey?.currentState ?? Navigator.maybeOf(context);
    if (navigator == null) return;

    navigator.push(
      MaterialPageRoute(
        builder: (_) => TaskTimerScreen(task: task, onPop: () {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timer = TaskTimerService.instance;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListenableBuilder(
        listenable: timer,
        builder: (context, _) {
          final visible = timer.shouldShowBanner;

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: !visible
                ? const SizedBox.shrink(key: ValueKey('timer-banner-hidden'))
                : Padding(
              key: const ValueKey('timer-banner'),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                bottom: bottomOffset,
              ),
              child: _buildPill(context, timer),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPill(BuildContext context, TaskTimerService timer) {
    final remaining = _toPersianDigits(_formatTime(timer.remainingSeconds));
    final total = _toPersianDigits(_formatTime(timer.totalSeconds));

    return Material(
      color: Colors.transparent,
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.28),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20,8,20,0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: AppColors.gray,
                      size: 19,
                    ),
                    const SizedBox(width: 12),

                    // Remaining / total
                    ReText(
                      remaining,
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(width: 6),
                    ReText(
                      '$total  /',
                      color: Colors.white.withOpacity(0.55),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(width: 10),

                    // Expand back into the full timer screen
                    _CircleAction(
                      icon: Icons.north_east,
                      iconSize: 18,
                      color: Colors.white.withOpacity(0.7),
                      onTap: () => _openTimerScreen(context, timer),
                    ),

                    const Spacer(),

                    // Play / pause
                    _CircleAction(
                      icon: timer.isRunning ? Icons.pause : Icons.play_arrow,
                      iconSize: 24,
                      color: Colors.white,
                      onTap: () {
                        if (timer.isRunning) {
                          timer.pause();
                        } else {
                          timer.start();
                        }
                      },
                    ),
                    const SizedBox(width: 4),

                    // Dismiss the banner (pauses first)
                    _CircleAction(
                      icon: Icons.close,
                      iconSize: 20,
                      color: Colors.white.withOpacity(0.7),
                      onTap: () async {
                        if (timer.isRunning) await timer.pause();
                        timer.dismissBanner();
                      },
                    ),
                  ],
                ),
              ),

              // Progress line pinned to the bottom edge
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        height: 4,
                        width: constraints.maxWidth * timer.progress,
                        decoration: const BoxDecoration(
                          color: _accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final Color color;
  final VoidCallback onTap;

  const _CircleAction({
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 24,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: color, size: iconSize),
      ),
    );
  }
}