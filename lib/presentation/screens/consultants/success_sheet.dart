// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/details_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Final screen of the consultants flow: success confirmation. Shown as a
/// centered dialog after the counseling request is submitted. Static data
/// driven by the chosen [duration] and [plan].
Future<void> showConsultationSuccessSheet(
  BuildContext context, {
  required ConsultationDurationOption duration,
  required ConsultationPlan plan,
}) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.white.withOpacity(0.52),
    builder: (_) => _SuccessDialog(duration: duration, plan: plan),
  );
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog({required this.duration, required this.plan});

  final ConsultationDurationOption duration;
  final ConsultationPlan plan;

  static const double _dialogWidth = 328;
  static const double _artworkWidth = 390;
  static const double _artworkAspectRatio = 1572 / 916;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, 0.18),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      elevation: 0,
      shadowColor: Colors.transparent,
      backgroundColor: Colors.transparent,
      child: Container(
        width: _dialogWidth,
        decoration: BoxDecoration(
          color: AppColors.whiteSec,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withOpacity(0.10),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildBanner(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildSectionTitle(),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildInfoRow(
                icon: SolarIconsOutline.alarm,
                iconColor: AppColors.black1,
                label: 'مدت زمان',
                value: '${duration.label}ه',
              ),
            ),
            const SizedBox(height: 9),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _buildInfoRow(
                icon: SolarIconsBold.userSpeakRounded,
                iconColor: AppColors.primary,
                label: 'نوع',
                value: 'مشاوره ${plan.subtitle}',
              ),
            ),
            const SizedBox(height: 35),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: ReText(
                'درخواستت برای انتخاب مشاور با موفقیت ثبت و تایید شد. در سریع ترین '
                'زمان ممکن مشاور اطلاعاتت رو بررسی می کنه و بهت پیام میده!',
                color: AppColors.gray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
                maxLines: 3,
                lineHeight: 1.8,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReButton(
                text: 'تایید',
                height: 56,
                background: AppColors.secondary,
                borderRadius: 40,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -51,
            left: (_dialogWidth - _artworkWidth) / 2,
            child: Image.asset(
              'assets/images/done_consult_req.png',
              width: _artworkWidth,
              height: _artworkWidth / _artworkAspectRatio,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.whiteSec,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.black1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return SizedBox(
      height: 24,
      child: Directionality(
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
      height: 39,
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
              width: 24,
              height: 24,
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
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            const Spacer(),
            Flexible(
              child: ReText(
                value,
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
