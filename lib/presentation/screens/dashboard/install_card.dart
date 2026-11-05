import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:simo_learn/data/install/home_screen_install.dart';
import 'package:simo_learn/presentation/widgets/re_modal_bottom_sheet.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The home's offer to add the web app to the home screen (see
/// [HomeScreenInstall]); takes no space when there is nothing to offer.
class InstallAppCard extends StatelessWidget {
  const InstallAppCard({super.key, this.install});

  /// Defaults to [HomeScreenInstall.instance]; tests pass their own.
  final HomeScreenInstall? install;

  @override
  Widget build(BuildContext context) {
    final install = this.install ?? HomeScreenInstall.instance;
    return ListenableBuilder(
      listenable: install,
      builder: (context, _) {
        final offer = install.offer;
        return AnimatedSize(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: offer == InstallOffer.none
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: _Card(install: install, offer: offer),
                ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.install, required this.offer});

  final HomeScreenInstall install;
  final InstallOffer offer;

  @override
  Widget build(BuildContext context) {
    final ios = offer == InstallOffer.iosSteps;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        key: const ValueKey('install-card'),
        decoration: BoxDecoration(
          color: AppColors.whiteSec,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.black1.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 12, 8, 12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  SolarIconsBold.homeAdd,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReText(
                      'سایمو را نصب کنید',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(height: 4),
                    ReText(
                      'از صفحه اصلی، مثل یک اپ باز می‌شود.',
                      color: AppColors.gray,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.right,
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _InstallButton(
                label: ios ? 'روش نصب' : 'نصب',
                onTap: ios
                    ? () => showIosInstallSheet(context)
                    : install.install,
              ),
              IconButton(
                key: const ValueKey('install-dismiss'),
                onPressed: install.dismiss,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.gray,
                  size: 18,
                  semanticLabel: 'بعداً',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        key: const ValueKey('install-action'),
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: SizedBox(
          height: 38,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: ReText(
                label,
                color: AppColors.whiteSec,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS has no install dialog: the steps for Safari's Share menu.
Future<void> showIosInstallSheet(BuildContext context) {
  return showReModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => const _IosStepsSheet(),
  );
}

class _IosStepsSheet extends StatelessWidget {
  const _IosStepsSheet();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(0, 8, 0, 24),
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: AppColors.gray2,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Expanded(
                      child: ReText(
                        'نصب سایمو روی آیفون',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.gray,
                        semanticLabel: 'بستن',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const ReText(
                  'این صفحه را در Safari باز کنید و این سه قدم را بزنید:',
                  color: AppColors.gray,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                ),
                const SizedBox(height: 20),
                const _Step(
                  number: '۱',
                  icon: SolarIconsOutline.uploadSquare,
                  title: 'دکمه‌ی Share را بزنید',
                  hint: 'مربع با فلش رو به بالا، پایین یا بالای صفحه',
                ),
                const SizedBox(height: 10),
                const _Step(
                  number: '۲',
                  icon: SolarIconsOutline.addSquare,
                  title: 'گزینه‌ی Add to Home Screen',
                  hint: 'در فارسی: «افزودن به صفحه اصلی»؛ کمی پایین‌تر در فهرست',
                ),
                const SizedBox(height: 10),
                const _Step(
                  number: '۳',
                  icon: SolarIconsOutline.checkCircle,
                  title: 'بالای صفحه Add را بزنید',
                  hint: 'آیکون سایمو به صفحه اصلی اضافه می‌شود.',
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: Material(
                    color: AppColors.black1,
                    borderRadius: BorderRadius.circular(100),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(100),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Center(
                        child: ReText(
                          'متوجه شدم',
                          color: AppColors.whiteSec,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
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

class _Step extends StatelessWidget {
  const _Step({
    required this.number,
    required this.icon,
    required this.title,
    required this.hint,
  });

  final String number;
  final IconData icon;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.black1,
              shape: BoxShape.circle,
            ),
            child: ReText(
              number,
              color: AppColors.whiteSec,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ReText(
                  title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 3),
                ReText(
                  hint,
                  color: AppColors.gray,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  textAlign: TextAlign.right,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.whiteSec,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.secondary, size: 22),
          ),
        ],
      ),
    );
  }
}
