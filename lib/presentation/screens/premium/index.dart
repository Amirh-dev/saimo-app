// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

const String _crownAsset = 'assets/images/premium_crown.png';

const List<_PremiumPlan> _premiumPlans = [
  _PremiumPlan(
    title: 'یک ماهه',
    price: '۵۰۰,۰۰۰',
    accent: AppColors.secondary,
    crownBackground: Color(0xFFEEF0FF),
  ),
  _PremiumPlan(
    title: 'شش ماهه',
    price: '۲,۷۰۰,۰۰۰',
    accent: AppColors.primary,
    crownBackground: Color(0xFFFFEFEB),
  ),
  _PremiumPlan(
    title: 'یک ساله',
    price: '۶,۷۰۰,۰۰۰',
    accent: Color(0xFFF0A813),
    crownBackground: Color(0xFFFFF7E7),
  ),
];

class _PremiumPlan {
  const _PremiumPlan({
    required this.title,
    required this.price,
    required this.accent,
    required this.crownBackground,
  });

  final String title;
  final String price;
  final Color accent;
  final Color crownBackground;
}

Future<void> showPremiumBanner(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: AppColors.white.withOpacity(0.52),
    builder: (dialogContext) => _PremiumBannerDialog(
      onViewPlans: () {
        Navigator.of(dialogContext).pop();
        context.to(const PremiumPlansScreen());
      },
    ),
  );
}

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen> {
  int _expandedPlan = 0;

  @override
  Widget build(BuildContext context) {
    return AppBottomNavigationScaffold(
      currentIndex: 4,
      onTap: (index) {
        if (index == 4) {
          Navigator.of(context).maybePop();
          return;
        }
        navigateToIndex(context, index, 6);
      },
      body: ColoredBox(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: ColoredBox(
            color: AppColors.gray1,
            child: Column(
              children: [
                const _PremiumHeader(),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(32, 16, 32, 28),
                    itemCount: _premiumPlans.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _PremiumPlanCard(
                        key: ValueKey('premium-plan-$index'),
                        plan: _premiumPlans[index],
                        expanded: index == _expandedPlan,
                        onTap: () => setState(() => _expandedPlan = index),
                        onPurchase: () => showReToast(
                          context,
                          'درگاه پرداخت به‌زودی فعال می‌شود',
                          ReToastType.info,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumHeader extends StatelessWidget {
  const _PremiumHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _PremiumHeaderIcon(
                icon: SolarIconsOutline.bell,
                showBadge: true,
              ),
              SizedBox(width: 8),
              _PremiumHeaderIcon(
                icon: SolarIconsOutline.chatRound,
                showBadge: true,
              ),
              SizedBox(width: 8),
              _PremiumHeaderIcon(
                icon: Icons.sports_martial_arts_rounded,
              ),
            ],
          ),
          ReText(
            'اشتراک ویژه',
            color: AppColors.black1,
            fontSize: 16,
            fontWeight: 1000,
          ),
        ],
      ),
    );
  }
}

class _PremiumHeaderIcon extends StatelessWidget {
  const _PremiumHeaderIcon({
    required this.icon,
    this.showBadge = false,
  });

  final IconData icon;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, size: 21, color: AppColors.black1),
          if (showBadge)
            Positioned(
              top: 5,
              right: 1,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumPlanCard extends StatelessWidget {
  const _PremiumPlanCard({
    super.key,
    required this.plan,
    required this.expanded,
    required this.onTap,
    required this.onPurchase,
  });

  final _PremiumPlan plan;
  final bool expanded;
  final VoidCallback onTap;
  final VoidCallback onPurchase;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.whiteSec,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.black1.withOpacity(0.045),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PlanSummary(plan: plan, expanded: expanded),
              if (expanded) ...[
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _BenefitsTitle(),
                ),
                const SizedBox(height: 14),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _PremiumBenefits(),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ReButton(
                    key: const ValueKey('purchase-premium-plan'),
                    text: 'پرداخت و فعالسازی',
                    height: 56,
                    background: AppColors.secondary,
                    borderRadius: 40,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    onPressed: onPurchase,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanSummary extends StatelessWidget {
  const _PlanSummary({
    required this.plan,
    required this.expanded,
  });

  final _PremiumPlan plan;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(32),
        boxShadow: expanded
            ? [
                BoxShadow(
                  color: AppColors.black1.withOpacity(0.055),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : const [],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 64,
              height: 80,
              margin: const EdgeInsets.only(right: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: plan.crownBackground,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Image.asset(
                _crownAsset,
                width: 42,
                height: 38,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ReText(
                      plan.title,
                      color: AppColors.black1,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ReText(
                          plan.price,
                          color: AppColors.black1,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                        const SizedBox(width: 5),
                        ReText(
                          'تومان',
                          color: plan.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Icon(
                expanded
                    ? SolarIconsOutline.altArrowUp
                    : SolarIconsOutline.altArrowDown,
                size: 16,
                color: AppColors.gray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitsTitle extends StatelessWidget {
  const _BenefitsTitle();

  @override
  Widget build(BuildContext context) {
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
              'مزایای اشتراک',
              color: AppColors.black1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBenefits extends StatelessWidget {
  const _PremiumBenefits();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _BenefitRow(label: 'ایجاد تسک', value: 'نامحدود'),
        SizedBox(height: 12),
        _BenefitRow(label: 'لیگ', value: 'آزاد'),
        SizedBox(height: 12),
        _BenefitRow(label: 'چالش ها', value: 'آزاد'),
      ],
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            ReText(
              label,
              color: AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: AppColors.gray2,
              ),
            ),
            const SizedBox(width: 14),
            ReText(
              value,
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}

class _PremiumBannerDialog extends StatelessWidget {
  const _PremiumBannerDialog({required this.onViewPlans});

  final VoidCallback onViewPlans;

  static const double _dialogWidth = 328;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: const Alignment(0, 0.16),
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
            _buildGradientBanner(context),
            const SizedBox(height: 19),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _BenefitsTitle(),
            ),
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: _PremiumBenefits(),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _DialogPlanSummary(),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ReButton(
                key: const ValueKey('view-premium-plans'),
                text: 'مشاهده پلن ها',
                height: 56,
                background: AppColors.secondary,
                borderRadius: 40,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                onPressed: onViewPlans,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientBanner(BuildContext context) {
    return Container(
      height: 118,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFCD45),
            Color(0xFFF4B21A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            top: -63,
            left: 93,
            child: Image(
              image: AssetImage(_crownAsset),
              width: 126,
              height: 109,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 13,
            right: 10,
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
          const Positioned(
            left: 42,
            right: 42,
            bottom: 17,
            child: ReText(
              'برای استفاده از این بخش به\nاشتراک ویژه نیاز دارید!',
              color: Color(0xFFB86800),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              textAlign: TextAlign.center,
              maxLines: 2,
              lineHeight: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogPlanSummary extends StatelessWidget {
  const _DialogPlanSummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            ReText(
              'یک ماهه',
              color: AppColors.gray,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            Spacer(),
            ReText(
              '۵۰۰,۰۰۰',
              color: AppColors.black1,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
            SizedBox(width: 5),
            ReText(
              'تومان',
              color: AppColors.secondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}
