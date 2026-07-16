// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 4 of the consultants flow: pick a plan (معمولی / حرفه‌ای / پیشرفته).
/// Shown as a modal bottom sheet. Static data.
class ConsultationPlan {
  const ConsultationPlan({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.oldPrice,
    required this.color,
    required this.planType,
    this.benefits = const [],
  });

  final String title;
  final String subtitle;
  final String price;
  final String oldPrice;
  final Color color;

  /// API enum value: NORMAL | PROFESSIONAL | ADVANCED.
  final String planType;

  /// Extra benefits shown when the plan is selected (empty = no expansion).
  final List<String> benefits;
}

const List<String> _kBenefits = [
  'برنامه ریزی شخصی سازی شده',
  'ارتباط مستقیم با مشاور',
];

const List<ConsultationPlan> kPlans = [
  ConsultationPlan(
    title: 'مشاوره',
    subtitle: 'معمولی',
    price: '۴۴۹,۰۰۰',
    oldPrice: '۴۹۹,۰۰۰',
    color: AppColors.primary,
    planType: 'NORMAL',
    benefits: _kBenefits,
  ),
  ConsultationPlan(
    title: 'مشاوره',
    subtitle: 'حرفه ای',
    price: '۲,۲۴۹,۰۰۰',
    oldPrice: '۲,۴۹۹,۰۰۰',
    color: AppColors.primary,
    planType: 'PROFESSIONAL',
    benefits: _kBenefits,
  ),
  ConsultationPlan(
    title: 'مشاوره',
    subtitle: 'پیشرفته',
    price: '۵,۹۴۹,۰۰۰',
    oldPrice: '۶,۴۹۹,۰۰۰',
    color: AppColors.primary,
    planType: 'ADVANCED',
    benefits: _kBenefits,
  ),
];

/// Opens the plans sheet. Returns the selected plan, or null on
/// cancel/dismiss.
Future<ConsultationPlan?> showPlansSheet(
  BuildContext context, {
  required String title,
  required String discount,
}) {
  return showModalBottomSheet<ConsultationPlan>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlansSheet(title: title, discount: discount),
  );
}

class _PlansSheet extends StatefulWidget {
  const _PlansSheet({required this.title, required this.discount});

  final String title;
  final String discount;

  @override
  State<_PlansSheet> createState() => _PlansSheetState();
}

class _PlansSheetState extends State<_PlansSheet> {
  // Default to "حرفه ای" (middle), matching the design.
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
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
            _buildHeader(),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var i = 0; i < kPlans.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PlanCard(
                          plan: kPlans[i],
                          selected: i == _selected,
                          onTap: () => setState(() => _selected = i),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ReText(
              '۲/۳',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(width: 12),
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
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ReText(
              widget.title,
              color: AppColors.black1,
              fontSize: 18,
              fontWeight: 1000,
              isPersian: false,
            ),
            const SizedBox(height: 6),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ReText(
                      widget.discount,
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const ReText(
                    'تخفیف روی همه پلن ها',
                    color: AppColors.gray,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ReButton(
            text: 'تایید',
            icon: SolarIconsOutline.altArrowLeft,
            reverseIconPosition: true,
            background: AppColors.primary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            onPressed: () => Navigator.of(context).pop(kPlans[_selected]),
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

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  final ConsultationPlan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: selected ? Border.all(color: plan.color, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 44,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildTopRow(),
            if (plan.benefits.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildBenefits(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Directionality(
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
          fontWeight: 900,
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

  Widget _buildBenefits() {
    return Column(
      children: [
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              const ReText(
                'مزایای مشاوره',
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.gray2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  SolarIconsOutline.infoCircle,
                  size: 14,
                  color: AppColors.black1,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < plan.benefits.length; i++) ...[
          _buildBenefitRow(plan.benefits[i]),
          if (i != plan.benefits.length - 1)
            Divider(
              height: 1,
              thickness: 1,
              color: AppColors.gray2.withOpacity(0.6),
            ),
        ],
      ],
    );
  }

  Widget _buildBenefitRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.done,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 15,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReText(
                text,
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlanAvatar extends StatelessWidget {
  const PlanAvatar({
    super.key,
    required this.color,
    this.size = 56,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        SolarIconsBold.stars,
        color: color,
        size: 24,
      ),
    );
  }
}
