import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/helpers.dart';
import 'package:solar_icons/solar_icons.dart';

enum ReToastType {
  success,
  error,
  info,
  warning;

  static const ReToastType failed = error;
}

OverlayEntry? _currentToastEntry;

class _AnimatedReToast extends StatefulWidget {
  const _AnimatedReToast({
    required this.title,
    required this.backgroundColor,
    required this.contentColor,
    required this.slideDuration,
    required this.showDuration,
    required this.onDismissed,
    this.icon,
  });

  final String title;
  final Color backgroundColor;
  final Color contentColor;
  final IconData? icon;
  final Duration slideDuration;
  final Duration showDuration;
  final VoidCallback onDismissed;

  @override
  State<_AnimatedReToast> createState() => _AnimatedReToastState();
}

class _AnimatedReToastState extends State<_AnimatedReToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _positionAnimation;
  Timer? _dismissTimer;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.slideDuration,
    );
    _positionAnimation = Tween<double>(
      begin: -100,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _dismissTimer = Timer(widget.showDuration, _dismiss);
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_isDismissing || !mounted) return;
    _isDismissing = true;
    _dismissTimer?.cancel();
    await _controller.reverse();
    if (mounted) widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: true,
        child: Material(
          color: Colors.transparent,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _positionAnimation.value),
                child: Opacity(opacity: _controller.value, child: child),
              );
            },
            child: Container(
              constraints: const BoxConstraints(minHeight: 68),
              margin: const EdgeInsets.only(top: 16, left: 16, right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.12),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                textDirection: TextDirection.ltr,
                children: [
                  widget.icon != null ? _ToastCircle(
                    backgroundColor: AppColors.white,
                    child: Icon(
                      widget.icon,
                      color: widget.backgroundColor,
                      size: 28,
                    ),
                  ) : const SizedBox(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ReText(
                      widget.title,
                      textDirection: TextDirection.rtl,
                      color: widget.contentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      lineHeight: 1.55,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    key: const Key('re-toast-dismiss'),
                    button: true,
                    label: 'بستن اعلان',
                    child: Material(
                      color: AppColors.white.withOpacity(0.20),
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _dismiss,
                        child: const SizedBox.square(
                          dimension: 40,
                          child: Icon(
                            Icons.close_rounded,
                            color: AppColors.white,
                            size: 28,
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
      ),
    );
  }
}

class _ToastCircle extends StatelessWidget {
  const _ToastCircle({required this.backgroundColor, required this.child});

  final Color backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: child,
    );
  }
}

void showReToast(
  BuildContext context,
  String title,
  ReToastType type,
) {
  vibrate(duration: 80);

  final style = switch (type) {
    ReToastType.success => (
        backgroundColor: AppColors.toastSuccess,
        contentColor: AppColors.white,
        icon: Icons.check_rounded,
      ),
    ReToastType.error => (
        backgroundColor: AppColors.toastError,
        contentColor: AppColors.white,
        icon: Icons.error_outline,
      ),
    ReToastType.info => (
        backgroundColor: AppColors.toastInfo,
        contentColor: AppColors.white,
        icon: SolarIconsOutline.infoCircle,
      ),
    ReToastType.warning => (
        backgroundColor: AppColors.toastWarning,
        contentColor: AppColors.black1,
        icon: SolarIconsOutline.dangerTriangle,
      ),
  };

  const slideDuration = Duration(milliseconds: 420);
  const showDuration = Duration(milliseconds: 3000);

  if (_currentToastEntry?.mounted ?? false) {
    _currentToastEntry?.remove();
  }
  _currentToastEntry = null;

  final overlayState =
      Navigator.maybeOf(context, rootNavigator: true)?.overlay ??
          Overlay.maybeOf(context, rootOverlay: true);
  if (overlayState == null) return;

  late final OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) {
      return _AnimatedReToast(
        title: title,
        backgroundColor: style.backgroundColor,
        contentColor: style.contentColor,
        icon: style.icon,
        slideDuration: slideDuration,
        showDuration: showDuration,
        onDismissed: () {
          if (_currentToastEntry == overlayEntry) {
            _currentToastEntry = null;
          }
          if (overlayEntry.mounted) overlayEntry.remove();
        },
      );
    },
  );

  _currentToastEntry = overlayEntry;
  overlayState.insert(overlayEntry);
}
