// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/details_sheet.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 5 of the consultants flow: "صورتحساب" — payment summary. Shown as a
/// modal bottom sheet. Static data.
///
/// Returns true when the user taps "تایید و پرداخت", null on cancel/dismiss.
Future<bool?> showInvoiceSheet(
  BuildContext context, {
  required ConsultationDurationOption duration,
  required ConsultationPlan plan,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _InvoiceSheet(duration: duration, plan: plan),
  );
}

class _InvoiceSheet extends StatelessWidget {
  const _InvoiceSheet({required this.duration, required this.plan});

  final ConsultationDurationOption duration;
  final ConsultationPlan plan;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildDurationRow(),
            const SizedBox(height: 12),
            _buildPlanRow(),
            const SizedBox(height: 24),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ReText(
              '۳/۳',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        Row(
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ReText(
                  'صورتحساب',
                  color: AppColors.black1,
                  fontSize: 18,
                  fontWeight: 1000,
                ),
                SizedBox(height: 4),
                ReText(
                  'جزئیات پرداخت و هزینه مشاوره',
                  color: AppColors.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ).rMargin(6),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).maybePop(),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.gray2),
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 22,
                  color: AppColors.black1.withOpacity(0.5),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildDurationRow() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          border: Border.all(color: AppColors.gray2)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.black1,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(
                SolarIconsOutline.alarm,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 10),
            ReText(
              'مدت زمان',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReText(
                duration.discount,
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 8),
            ReText(
              duration.label,
              color: AppColors.black1,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 44,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            PlanAvatar(color: plan.color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ReText(
                  plan.title,
                  color: AppColors.black1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 2),
                ReText(
                  plan.subtitle,
                  color: plan.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _priceNumber(plan.price, plan.color),
                      const SizedBox(width: 4),
                      ReText(
                        'تومــان',
                        color: plan.color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                ReText(
                  plan.oldPrice,
                  color: AppColors.black1.withOpacity(0.5),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.lineThrough,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Renders the price with black digits and separators tinted [color].
  Widget _priceNumber(String price, Color color) {
    final parts = price.split(',');
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      children.add(
        ReText(
          parts[i],
          color: AppColors.black1,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          textDirection: TextDirection.ltr,
        ),
      );
      if (i != parts.length - 1) {
        children.add(
          ReText(
            ',',
            color: color,
            fontSize: 16,
            fontWeight: 1000,
            textDirection: TextDirection.ltr,
          ),
        );
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: children,
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ReButton(
            text: 'تایید و پرداخت',
            icon: SolarIconsOutline.altArrowLeft,
            reverseIconPosition: true,
            background: AppColors.primary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: ReButton(
            text: 'لغو',
            icon: Icons.close_rounded,
            isOutlined: true,
            color: AppColors.gray2,
            textColor: AppColors.black1,
            iconColor: AppColors.black1,
            borderRadius: 40,
            fontSize: 16,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
