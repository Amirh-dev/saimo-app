import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:simo_learn/data/app_update/app_update_check.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// Offers to reload when a newer web release is out (see [AppUpdateCheck]).
/// Mounted once, app-wide, through `MaterialApp.builder`; it shows nothing
/// until there is something to offer.
class AppUpdateBanner extends StatelessWidget {
  const AppUpdateBanner({super.key, this.check});

  /// Defaults to [AppUpdateCheck.instance]; tests pass their own.
  final AppUpdateCheck? check;

  static const Color _background = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final check = this.check ?? AppUpdateCheck.instance;
    return ListenableBuilder(
      listenable: check,
      builder: (context, _) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.4),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: !check.available
              ? const SizedBox.shrink(key: ValueKey('app-update-hidden'))
              : Padding(
                  key: const ValueKey('app-update'),
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.viewPaddingOf(context).top + 12,
                    16,
                    0,
                  ),
                  child: Center(
                    heightFactor: 1,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 460),
                      child: _Pill(check: check),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.check});

  final AppUpdateCheck check;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppUpdateBanner._background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10),
            child: Row(
              children: [
                const Icon(
                  SolarIconsBold.refreshCircle,
                  color: AppColors.white,
                  size: 22,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ReText(
                        'نسخه‌ی جدید آماده است',
                        color: AppColors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: 2),
                      ReText(
                        'با یک لمس، آخرین نسخه را ببینید.',
                        color: AppColors.gray,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _UpdateButton(check: check),
                const SizedBox(width: 2),
                IconButton(
                  key: const ValueKey('app-update-dismiss'),
                  onPressed: check.updating ? null : check.dismiss,
                  tooltip: 'بعداً',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.gray,
                    size: 18,
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

class _UpdateButton extends StatelessWidget {
  const _UpdateButton({required this.check});

  final AppUpdateCheck check;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        key: const ValueKey('app-update-reload'),
        borderRadius: BorderRadius.circular(100),
        onTap: check.updating ? null : check.update,
        child: SizedBox(
          height: 36,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Center(
              child: check.updating
                  ? const SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.whiteSec,
                      ),
                    )
                  : const ReText(
                      'به‌روزرسانی',
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
