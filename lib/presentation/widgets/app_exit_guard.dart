import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    if (_isShowingDialog || !mounted) {
      return;
    }

    _isShowingDialog = true;

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text(
              'خروج از برنامه',
              textAlign: TextAlign.right,
            ),
            content: const Text(
              'آیا مطمئن هستید که می‌خواهید از برنامه خارج شوید؟',
              textAlign: TextAlign.right,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('انصراف'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('خروج'),
              ),
            ],
          ),
        );
      },
    );

    _isShowingDialog = false;

    if (!mounted || shouldExit != true) {
      return;
    }

    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }

        _handleBack();
      },
      child: widget.child,
    );
  }
}