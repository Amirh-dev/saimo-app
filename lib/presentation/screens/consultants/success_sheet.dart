// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/details_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Final screen of the consultants flow: success confirmation. Shown as a modal
/// bottom sheet after the counseling request is submitted, replacing the old
/// snackbar. Static data driven by the chosen [duration] and [plan].
Future<void> showConsultationSuccessSheet(
  BuildContext context, {
  required ConsultationDurationOption duration,
  required ConsultationPlan plan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SuccessSheet(duration: duration, plan: plan),
  );
}

class _SuccessSheet extends StatelessWidget {
  const _SuccessSheet({required this.duration, required this.plan});

  final ConsultationDurationOption duration;
  final ConsultationPlan plan;

  // Intrinsic aspect ratio of the banner art (1572x916).
  static const double _bannerAspect = 1572 / 916;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(context),
            const SizedBox(height: 8),
            _buildSectionTitle(),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: SolarIconsOutline.alarm,
              iconColor: AppColors.black1,
              label: 'مدت زمان',
              value: duration.label,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              icon: SolarIconsBold.userSpeakRounded,
              iconColor: AppColors.primary,
              label: 'نوع',
              value: 'مشاوره ${plan.subtitle}',
            ),
            const SizedBox(height: 20),
            const ReText(
              'درخواستت برای انتخاب مشاور با موفقیت ثبت و تایید شد. در سریع ترین '
              'زمان ممکن مشاور اطلاعاتت رو بررسی می کنه و بهت پیام میده!',
              color: AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
              maxLines: 3,
              lineHeight: 1.8,
            ),
            const SizedBox(height: 20),
            ReButton(
              text: 'تایید',
              background: AppColors.secondary,
              borderRadius: 40,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width / _bannerAspect;
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Image.asset(
                'assets/images/done_consult_req.png',
                width: width,
                height: height,
                fit: BoxFit.contain,
              ),
              // White circular close button on the green card's top-right,
              // matching the design.
              Positioned(
                top: height * 0.30,
                right: width * 0.14,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              SolarIconsOutline.infoCircle,
              size: 16,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(width: 8),
          const ReText(
            'اطلاعات درخواست',
            color: AppColors.black1,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: AppColors.white),
            ),
            const SizedBox(width: 10),
            ReText(
              label,
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const Spacer(),
            ReText(
              value,
              color: AppColors.black1,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}
