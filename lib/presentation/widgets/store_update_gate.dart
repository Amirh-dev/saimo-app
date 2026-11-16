import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:simo_learn/data/app_update/store_update_check.dart';
import 'package:simo_learn/presentation/widgets/re_button.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// Covers the whole app when this version is older than the one the server
/// requires ([StoreUpdateCheck.required]). There is no way past it but
/// installing the new version from Google Play or the website. Mounted once,
/// above the navigator, through `MaterialApp.builder`; it shows nothing
/// otherwise.
class StoreUpdateGate extends StatelessWidget {
  const StoreUpdateGate({super.key, this.check});

  /// Defaults to [StoreUpdateCheck.instance]; tests pass their own.
  final StoreUpdateCheck? check;

  @override
  Widget build(BuildContext context) {
    final check = this.check ?? StoreUpdateCheck.instance;
    if (check == null) return const SizedBox.shrink();
    return ListenableBuilder(
      listenable: check,
      builder: (context, _) =>
          check.required ? _GateScreen(check: check) : const SizedBox.shrink(),
    );
  }
}

class _GateScreen extends StatefulWidget {
  const _GateScreen({required this.check});

  final StoreUpdateCheck check;

  @override
  State<_GateScreen> createState() => _GateScreenState();
}

class _GateScreenState extends State<_GateScreen> {
  bool _failed = false;

  Future<void> _open(StoreUpdateTarget target) async {
    setState(() => _failed = false);
    final opened = await widget.check.openUpdate(target);
    if (mounted && !opened) setState(() => _failed = true);
  }

  @override
  Widget build(BuildContext context) {
    final check = widget.check;
    final policy = check.policy;
    final opening = check.opening;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        key: const ValueKey('store-update-gate'),
        color: AppColors.gray1,
        child: SafeArea(
          // Scrolls on short screens; the buttons sit at the bottom otherwise.
          child: LayoutBuilder(
            builder: (context, viewport) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 420,
                    minHeight:
                        viewport.maxHeight > 28 ? viewport.maxHeight - 28 : 0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(height: 8),
                      Column(
                        children: [
                          const _Badge(),
                          const SizedBox(height: 24),
                          const ReText(
                            'اپ رو به‌روز کن',
                            fontSize: 22,
                            fontWeight: 1000,
                            color: AppColors.black1,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          const ReText(
                            'این نسخه دیگه پشتیبانی نمی‌شه.\nبرای ادامه، نسخه‌ی جدید رو نصب کن.',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray,
                            textAlign: TextAlign.center,
                            lineHeight: 1.9,
                            overflow: TextOverflow.visible,
                          ),
                          const SizedBox(height: 22),
                          _VersionCard(
                            running: check.runningVersion,
                            latest: policy?.latestVersion,
                            message: policy?.message,
                          ),
                          const SizedBox(height: 12),
                          const _BazaarNote(),
                        ],
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 28),
                          ReButton(
                            key: const ValueKey('store-update-play'),
                            text: 'نصب از گوگل‌پلی',
                            onPressed: () =>
                                _open(StoreUpdateTarget.googlePlay),
                            isLoading: opening == StoreUpdateTarget.googlePlay,
                            height: 54,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 10),
                          ReButton(
                            key: const ValueKey('store-update-website'),
                            text: 'دانلود از سایت سایمو',
                            onPressed: () => _open(StoreUpdateTarget.website),
                            isLoading: opening == StoreUpdateTarget.website,
                            background: AppColors.whiteSec,
                            textColor: AppColors.black1,
                            height: 54,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                          SizedBox(
                            height: 36,
                            child: _failed
                                ? const Center(
                                    child: ReText(
                                      'باز کردن صفحه‌ی دانلود ناموفق بود. دوباره امتحان کن.',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.errorColor,
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ],
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

class _Badge extends StatelessWidget {
  const _Badge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.14),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.10),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          SolarIconsBold.smartphoneUpdate,
          color: AppColors.primary,
          size: 38,
        ),
      ),
    );
  }
}

/// Bazaar installs can't be updated in place: the app has to be removed
/// first (product decision, Nov 2026).
class _BazaarNote extends StatelessWidget {
  const _BazaarNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              SolarIconsBold.infoCircle,
              size: 20,
              color: AppColors.black1,
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: ReText(
              'اگه سایمو رو از بازار نصب کردی، اول اپ رو پاک کن و بعد از یکی از دو راه زیر نصبش کن.',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.black1,
              textAlign: TextAlign.right,
              lineHeight: 1.8,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}

/// «نسخه‌ی تو → نسخه‌ی جدید», and the admin's line about it, if any.
class _VersionCard extends StatelessWidget {
  const _VersionCard({this.running, this.latest, this.message});

  final String? running;
  final String? latest;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final running = this.running;
    final latest = this.latest;
    final message = this.message;
    final versions = running != null && latest != null;
    if (!versions && message == null) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (versions)
            Row(
              children: [
                Expanded(
                  child: _Version(label: 'نسخه‌ی تو', value: running),
                ),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.gray1,
                    shape: BoxShape.circle,
                  ),
                  // Mirrors in RTL: points from «نسخه‌ی تو» to «نسخه‌ی جدید».
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.gray,
                  ),
                ),
                Expanded(
                  child: _Version(
                    label: 'نسخه‌ی جدید',
                    value: latest,
                    highlighted: true,
                  ),
                ),
              ],
            ),
          if (message != null) ...[
            if (versions) ...[
              const SizedBox(height: 14),
              const Divider(height: 1, thickness: 1, color: AppColors.gray2),
              const SizedBox(height: 14),
            ],
            ReText(
              message,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.black1,
              textAlign: TextAlign.right,
              lineHeight: 1.8,
              overflow: TextOverflow.visible,
            ),
          ],
        ],
      ),
    );
  }
}

class _Version extends StatelessWidget {
  const _Version({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  final String label;
  final String value;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReText(
          label,
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: AppColors.gray,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        ReText(
          value,
          fontSize: 17,
          fontWeight: highlighted ? 900 : FontWeight.w700,
          color: highlighted ? AppColors.black1 : AppColors.gray,
          textAlign: TextAlign.center,
          // Keep "1.0.43" in reading order.
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
