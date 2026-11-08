import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:simo_learn/utils/jalali_text.dart';

/// The first page after registration: what a first plan looks like and the
/// three steps of using the app. It adds nothing by itself. Pops with true
/// when the student chooses to build the plan now, false for «بعداً».
class OnboardingWelcomeScreen extends StatelessWidget {
  const OnboardingWelcomeScreen({super.key});

  static const List<String> steps = [
    'تسک زمان‌دار خودتو بساز',
    'با شروع تایمر، تسک رو تکمیل کن',
    'پیشرفت خودت رو از بخش آمار دنبال کن',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(false);
      },
      child: Scaffold(
        backgroundColor: AppColors.gray1,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 60,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Align(
                          alignment: Alignment.centerRight,
                          child: _FirstStepPill(),
                        ),
                        const SizedBox(height: 14),
                        const ReText(
                          'اولین تسک زمان‌دار امروز رو بساز',
                          key: ValueKey('onboarding-welcome-title'),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black1,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.visible,
                          lineHeight: 1.5,
                        ),
                        const SizedBox(height: 22),
                        const _SamplePlanCard(),
                        const SizedBox(height: 26),
                        for (var i = 0; i < steps.length; i++) ...[
                          _Step(number: i + 1, text: steps[i]),
                          if (i < steps.length - 1) const SizedBox(height: 14),
                        ],
                        const Spacer(),
                        const SizedBox(height: 28),
                        ReButton(
                          key: const ValueKey('onboarding-welcome-start'),
                          text: 'ساختن برنامه',
                          onPressed: () => Navigator.of(context).pop(true),
                          background: AppColors.primary,
                          color: AppColors.primary,
                          textColor: AppColors.white,
                          height: 56,
                          borderRadius: 100,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          key: const ValueKey('onboarding-welcome-later'),
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const ReText(
                            'بعداً',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FirstStepPill extends StatelessWidget {
  const _FirstStepPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const ReText(
        'قدم اول',
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
      ),
    );
  }
}

/// A made-up day, labelled «نمونه», so the student sees what a plan is
/// before making one. Nothing in it is saved.
class _SamplePlanCard extends StatelessWidget {
  const _SamplePlanCard();

  static const _samples = [
    ('زیست، فصل ۱', AppColors.secondary),
    ('تست شیمی', AppColors.primary),
    ('ریاضی، تابع', AppColors.done),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(22),
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
                child: ReText(
                  JalaliText.fullDay(Jalali.now()),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gray1,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const ReText(
                  'نمونه',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.gray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final (title, color) in _samples)
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppColors.gray1,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      ReText(
                        title,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black1,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.whiteSec,
            shape: BoxShape.circle,
          ),
          child: ReText(
            convertToPersianNumbers('$number'),
            fontSize: 13,
            fontWeight: FontWeight.w900,
            color: AppColors.black1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ReText(
            text,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.black1,
            textAlign: TextAlign.right,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}
