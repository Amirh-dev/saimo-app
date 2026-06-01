import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/helpers.dart';
import 'package:solar_icons/solar_icons.dart';

enum ReToastType { success, warning, failed }

OverlayEntry? _currentToastEntry;

class _AnimatedReToast extends StatefulWidget {
  const _AnimatedReToast({
    required this.title,
    required this.backgroundColor,
    required this.contentColor,
    required this.icon,
    required this.slideDuration,
    required this.showDuration,
    required this.onDismissed,
  });

  final String title;
  final Color backgroundColor;
  final Color contentColor;
  final IconData icon;
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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.slideDuration,
    );
    _positionAnimation = Tween<double>(
      begin: -78,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    Future.delayed(widget.showDuration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                child: child,
              );
            },
            child: Container(
              height: 68,
              margin: const EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            Icon(
                              widget.icon,
                              color: widget.contentColor,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ReText(
                                widget.title,
                                textDirection: TextDirection.rtl,
                                color: widget.contentColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                textAlign: TextAlign.right,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 1, end: 0),
                    duration: widget.showDuration,
                    builder: (context, value, child) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: LinearProgressIndicator(
                          value: value,
                          backgroundColor:
                              widget.backgroundColor.withOpacity(0.4),
                          color: widget.contentColor,
                          minHeight: 4,
                        ),
                      );
                    },
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

void showReToast(
  BuildContext context,
  String title,
  ReToastType type,
) {
  vibrate(duration: 80);

  final style = switch (type) {
    ReToastType.success => (
        backgroundColor: AppColors.toastSuccessBackground,
        contentColor: AppColors.toastSuccessText,
        icon: SolarIconsOutline.checkSquare,
      ),
    ReToastType.warning => (
        backgroundColor: AppColors.toastWarningBackground,
        contentColor: AppColors.toastWarningText,
        icon: SolarIconsOutline.dangerSquare,
      ),
    ReToastType.failed => (
        backgroundColor: AppColors.toastErrorBackground,
        contentColor: AppColors.toastErrorText,
        icon: SolarIconsOutline.closeSquare,
      ),
  };

  const slideDuration = Duration(milliseconds: 420);
  const showDuration = Duration(milliseconds: 2400);

  _currentToastEntry?.remove();
  _currentToastEntry = null;

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
          overlayEntry.remove();
        },
      );
    },
  );

  _currentToastEntry = overlayEntry;
  Overlay.of(context).insert(overlayEntry);
}
