import 'package:flutter/material.dart';
import 'package:simo_learn/features/onboarding/onboarding_store.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart'
    show PressScale;
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// «شروع با سایمو» on the home screen: the new student's three first steps,
/// the next one with its own button. Gone once all are done.
class StartChecklistCard extends StatelessWidget {
  const StartChecklistCard({
    super.key,
    required this.store,
    required this.onPlan,
    required this.onStudy,
    required this.onGoal,
  });

  final OnboardingStore store;
  final VoidCallback onPlan;
  final VoidCallback onStudy;
  final VoidCallback onGoal;

  @override
  Widget build(BuildContext context) {
    final steps = [
      (store.planned, 'برنامه‌ی امروزتو بچین', 'ساختن', onPlan, 'plan'),
      (store.studied, 'اولین تسکتو انجام بده', 'تسک‌ها', onStudy, 'study'),
      (store.goalSet, 'هدف خودتو مشخص کن', 'ساختن', onGoal, 'goal'),
    ];
    final next = steps.indexWhere((step) => !step.$1);
    final done = store.doneCount;

    return Container(
      key: const ValueKey('onboarding-checklist'),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const ReText(
                      'شروع با سایمو',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black1,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 2),
                    ReText(
                      convertToPersianNumbers(
                          '$done از ${OnboardingStore.stepCount} انجام شد'),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray,
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 40,
                height: 40,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: done / OnboardingStore.stepCount),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 5,
                    strokeCap: StrokeCap.round,
                    color: AppColors.done,
                    backgroundColor: AppColors.gray2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            _ChecklistRow(
              key: ValueKey('onboarding-step-${steps[i].$5}'),
              done: steps[i].$1,
              title: steps[i].$2,
              action: i == next ? steps[i].$3 : null,
              onTap: steps[i].$1 ? null : steps[i].$4,
            ),
        ],
      ),
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    super.key,
    required this.done,
    required this.title,
    required this.action,
    required this.onTap,
  });

  final bool done;
  final String title;

  /// The button label, only on the next step.
  final String? action;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isNext = action != null;
    return PressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: EdgeInsets.symmetric(
          horizontal: isNext ? 12 : 2,
          vertical: isNext ? 10 : 9,
        ),
        decoration: BoxDecoration(
          color: isNext ? AppColors.gray1 : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _CheckCircle(done: done, emphasized: isNext),
            const SizedBox(width: 10),
            Expanded(
              child: ReText(
                title,
                fontSize: 13,
                fontWeight: isNext ? FontWeight.w900 : FontWeight.w800,
                color: done ? AppColors.gray : AppColors.black1,
                textAlign: TextAlign.right,
                decoration: done ? TextDecoration.lineThrough : null,
              ),
            ),
            if (isNext)
              Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ReText(
                  action!,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckCircle extends StatelessWidget {
  const _CheckCircle({required this.done, required this.emphasized});

  final bool done;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: done ? AppColors.done : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: done
              ? AppColors.done
              : (emphasized ? AppColors.black1 : AppColors.gray2),
          width: 2,
        ),
      ),
      child: done
          ? const Icon(Icons.check_rounded, size: 15, color: AppColors.white)
          : null,
    );
  }
}

/// A dark speech bubble pointing up at the control it is about. Tapping it
/// does what that control does.
class OnboardingHint extends StatelessWidget {
  const OnboardingHint({
    super.key,
    required this.text,
    required this.onTap,
    this.arrowAlignment = Alignment.centerLeft,
    this.arrowInset = 52,
  });

  final String text;
  final VoidCallback onTap;

  /// Which end of the bubble the arrow sits near.
  final Alignment arrowAlignment;

  /// How far the arrow's centre is from that end.
  final double arrowInset;

  @override
  Widget build(BuildContext context) {
    final fromLeft = arrowAlignment.x < 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment:
            fromLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: fromLeft ? arrowInset - 8 : 0,
              right: fromLeft ? 0 : arrowInset - 8,
            ),
            child: const CustomPaint(
              size: Size(16, 8),
              painter: _ArrowPainter(AppColors.black1),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.black1,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black1.withValues(alpha: 0.22),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ReText(
              text,
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  const _ArrowPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, size.height)
      ..quadraticBezierTo(size.width / 2 - 2, -1, size.width / 2, 0)
      ..quadraticBezierTo(size.width / 2 + 2, -1, size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ArrowPainter oldDelegate) => oldDelegate.color != color;
}

/// After the first finished task: a short well done, then an offer to plan
/// with a counselor. Resolves to true when the student wants to see the
/// counselors.
Future<bool> showFirstTaskDoneSheet(
  BuildContext context, {
  required String title,
  required int minutes,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.whiteSec,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (_) => _FirstTaskDoneSheet(title: title, minutes: minutes),
  );
  return result ?? false;
}

class _FirstTaskDoneSheet extends StatelessWidget {
  const _FirstTaskDoneSheet({required this.title, required this.minutes});

  final String title;
  final int minutes;

  String get _summary {
    final name = title.trim();
    if (minutes <= 0) return name;
    final time = convertToPersianNumbers('$minutes دقیقه');
    return name.isEmpty ? time : '$time $name';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Padding(
          key: const ValueKey('onboarding-first-task-sheet'),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.gray2,
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.done.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 34, color: AppColors.done),
                ),
              ),
              const SizedBox(height: 12),
              const ReText(
                'اولین تسک انجام شد',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
                textAlign: TextAlign.center,
              ),
              if (_summary.isNotEmpty) ...[
                const SizedBox(height: 4),
                ReText(
                  _summary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gray1,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(SolarIconsBold.userSpeakRounded,
                              size: 20, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: ReText(
                            'برنامه‌ریزی با مشاور',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.black1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ReButton(
                      key: const ValueKey('onboarding-see-counselors'),
                      text: 'دیدن مشاوران',
                      onPressed: () => Navigator.of(context).pop(true),
                      background: AppColors.secondary,
                      color: AppColors.secondary,
                      textColor: AppColors.white,
                      height: 44,
                      borderRadius: 100,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              ReButton(
                key: const ValueKey('onboarding-first-task-continue'),
                text: 'ادامه',
                onPressed: () => Navigator.of(context).pop(false),
                background: AppColors.primary,
                color: AppColors.primary,
                textColor: AppColors.white,
                height: 54,
                borderRadius: 100,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
