// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/re_header.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 1 of the consultants flow: static onboarding intro card.
/// No server calls — pure UI. Tapping "لیست مشاوران" will later push the
/// consultants list screen (screen 2).
class ConsultantIntroScreen extends StatelessWidget {
  const ConsultantIntroScreen({super.key, this.onStart});

  final VoidCallback? onStart;

  static const String _illustration = 'assets/images/consultant_intro.png';

  static const List<String> _benefits = [
    'برنامه ریزی شخصی سازی شده',
    'ارتباط مستقیم با مشاور',
    'تحلیل وضعیت و عملکرد درسی',
    'کمک به مدیریت استرس امتحان',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
              child: reAppHeader(
                'مشاوران',
                prefixIcon: const SizedBox(width: 48),
                suffixIcon: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => Navigator.of(context).maybePop(),
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      SolarIconsOutline.altArrowRight,
                      size: 22,
                      color: AppColors.black1,
                    ),
                  ),
                ),
              ).bMargin(18),
            ),
            Expanded(
              child: SingleChildScrollView(
                // Extra top padding leaves room for the hero art to overflow
                // above the card without being clipped by the scroll viewport.
                padding: const EdgeInsets.fromLTRB(32, 110, 32, 24),
                child: _buildCard(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 44,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHero(),
          const SizedBox(height: 24),
          _buildSectionTitle(),
          const SizedBox(height: 16),
          _buildBenefits(),
          const SizedBox(height: 16),
          _buildPrice(),
          const SizedBox(height: 8),
          ReButton(
            text: 'لیست مشاوران',
            background: AppColors.secondary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            onPressed: onStart ??
                () => Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) =>
                            const ConsultantListScreen(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    // Gray box is the hero background and spans the full illustration area, so
    // whatever is behind the (transparent) art is gray, not white. Only the top
    // slice of the art overflows above the card (Clip.none) onto the
    // transparent scaffold area, giving the "popping out" look.
    const double boxHeight = 200;
    const double artHeight = 300;
    const double artTop = -100; // ~100px of art pops above the gray box
    const double artSideInset = 50; // image inset from the card sides

    return SizedBox(
      height: boxHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.gray1,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            top: artTop,
            left: artSideInset,
            right: artSideInset,
            child: Image.asset(
              _illustration,
              height: artHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox(height: artHeight),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              width: 32,
              height: 32,
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
        ],
      ),
    );
  }

  Widget _buildSectionTitle() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                SolarIconsOutline.infoCircle,
                size: 16,
                color: AppColors.secondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const ReText(
            'مزایای مشاوره',
            color: AppColors.black1,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final items = <Widget>[];
    for (var i = 0; i < _benefits.length; i++) {
      items.add(_buildBenefitRow(_benefits[i]));
      if (i != _benefits.length - 1) {
        items.add(
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.gray2.withOpacity(0.6),
          ),
        );
      }
    }
    return Column(children: items);
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
                shape: BoxShape.rectangle,
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

  Widget _buildPrice() {
    return Container(
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ReText(
              'شروع از',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(width: 8),
            const Row(
              mainAxisSize: MainAxisSize.min,
              textDirection: TextDirection.ltr,
              children: [
                ReText(
                  '۴۹۹',
                  color: AppColors.black1,
                  fontSize: 20,
                  fontWeight: 900,
                  textDirection: TextDirection.ltr,
                ),
                ReText(
                  ',',
                  color: AppColors.secondary,
                  fontSize: 20,
                  fontWeight: 900,
                  textDirection: TextDirection.ltr,
                ),
                ReText(
                  '۰۰۰',
                  color: AppColors.black1,
                  fontSize: 20,
                  fontWeight: 900,
                  textDirection: TextDirection.ltr,
                ),
              ],
            ),
            const SizedBox(width: 4),
            const ReText(
              'تومان',
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }
}
