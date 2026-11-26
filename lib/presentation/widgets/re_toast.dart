import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/notice_card.dart';
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

// `OverlayEntry.mounted` stays true until the next frame after `remove()`,
// so it can't guard against a second removal (which throws on `_overlay!`).
final Expando<bool> _removedToastEntries = Expando<bool>();

void _removeToastEntry(OverlayEntry entry) {
  if (_removedToastEntries[entry] == true) return;
  _removedToastEntries[entry] = true;
  try {
    entry.remove();
  } catch (_) {
    // Overlay already gone (e.g. navigator disposed) — nothing to remove.
  }
}

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
            child: Padding(
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
              child: NoticeCard(
                title: widget.title,
                leading: widget.icon == null ? null : NoticeIcon(icon: widget.icon!, color: widget.backgroundColor, iconColor: widget.contentColor),
                duration: widget.showDuration,
                onClose: _dismiss,
              ),
            ),
          ),
        ),
      ),
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
        contentColor: AppColors.toastSuccess,
        icon: Icons.check_rounded,
      ),
    ReToastType.error => (
        backgroundColor: AppColors.toastError,
        contentColor: AppColors.toastError,
        icon: Icons.error_outline,
      ),
    ReToastType.info => (
        backgroundColor: AppColors.toastInfo,
        contentColor: AppColors.toastInfo,
        icon: SolarIconsOutline.infoCircle,
      ),
    ReToastType.warning => (
        backgroundColor: AppColors.toastWarning,
        contentColor: const Color(0xFFC98A00),
        icon: SolarIconsOutline.dangerTriangle,
      ),
  };

  const slideDuration = Duration(milliseconds: 420);
  const showDuration = Duration(milliseconds: 3000);

  final previousEntry = _currentToastEntry;
  if (previousEntry != null) _removeToastEntry(previousEntry);
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
          _removeToastEntry(overlayEntry);
        },
      );
    },
  );

  _currentToastEntry = overlayEntry;
  overlayState.insert(overlayEntry);
}
