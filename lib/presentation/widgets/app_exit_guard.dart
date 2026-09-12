import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:simo_learn/utils/_utils.dart';

import '_widgets.dart';

/// Prevents accidental app exit from the root screens and shows
/// a Simo-styled confirmation dialog.
///
/// This widget is intended to wrap the whole screen/Scaffold rather than
/// individual pieces such as the bottom navigation bar.
class AppExitGuard extends StatefulWidget {
  const AppExitGuard({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<AppExitGuard> createState() => _AppExitGuardState();
}

class _AppExitGuardState extends State<AppExitGuard> {
  bool _isShowingDialog = false;

  Future<void> _handleBack() async {
    if (!mounted || _isShowingDialog) return;

    _isShowingDialog = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: true,
      barrierColor: AppColors.black1.withOpacity(0.35),
      builder: (dialogContext) {
        return const _ExitConfirmationDialog();
      },
    );

    _isShowingDialog = false;

    if (!mounted || shouldExit != true) return;

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        _handleBack();
      },
      child: widget.child,
    );
  }
}

class _ExitConfirmationDialog extends StatelessWidget {
  const _ExitConfirmationDialog();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.10),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ExitIcon(),
              const SizedBox(height: 16),
              const ReText(
                'خروج از برنامه',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.black1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const ReText(
                'آیا مطمئن هستید که می‌خواهید از برنامه خارج شوید؟',
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: AppColors.gray,
                textAlign: TextAlign.center,
                lineHeight: 1.7,
                maxLines: 2,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: ReButton(
                      text: 'انصراف',
                      height: 48,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      isOutlined: true,
                      color: AppColors.gray2,
                      textColor: AppColors.black1,
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ReButton(
                      text: 'خروج',
                      height: 48,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      background: AppColors.primary,
                      textColor: AppColors.white,
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExitIcon extends StatelessWidget {
  const _ExitIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.10),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.exit_to_app_rounded,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }
}
