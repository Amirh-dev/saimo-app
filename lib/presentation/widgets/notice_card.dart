import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// The app's one message look: a white card with a soft shadow, an optional
/// picture or tinted icon at the start, a dark pill button, and a thin line at
/// the bottom that runs down while the message stays.
class NoticeCard extends StatelessWidget {
  const NoticeCard({
    super.key,
    required this.title,
    this.sub,
    this.leading,
    this.action,
    this.actionIcon,
    this.onAction,
    this.onClose,
    this.duration,
    this.titleLines = 3,
  });

  final String title;
  final String? sub;
  final Widget? leading;
  final String? action;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Shows a small close button when set.
  final VoidCallback? onClose;

  /// How long the message stays; the bottom line runs down over it.
  final Duration? duration;
  final int titleLines;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: const Color(0xFF19192D).withValues(alpha: 0.13), blurRadius: 34, offset: const Offset(0, 14)),
            BoxShadow(color: const Color(0xFF19192D).withValues(alpha: 0.06), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Stack(children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14, 12, onClose != null && action == null ? 8 : 12, 14),
            child: Row(children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  ReText(
                    title,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    color: AppColors.black1,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    lineHeight: 1.6,
                    maxLines: titleLines,
                  ),
                  if (sub != null)
                    ReText(
                      sub!,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.right,
                      color: AppColors.gray,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                    ),
                ]),
              ),
              if (action != null) ...[
                const SizedBox(width: 10),
                Semantics(
                  button: true,
                  label: action,
                  child: GestureDetector(
                    onTap: onAction,
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(color: AppColors.black1, borderRadius: BorderRadius.circular(100)),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        if (actionIcon != null) ...[Icon(actionIcon, size: 18, color: AppColors.white, textDirection: TextDirection.ltr), const SizedBox(width: 6)],
                        ReText(action!, color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w900, maxLines: 1),
                      ]),
                    ),
                  ),
                ),
              ],
              if (onClose != null && action == null) ...[
                const SizedBox(width: 8),
                Semantics(
                  key: const Key('re-toast-dismiss'),
                  button: true,
                  label: 'بستن اعلان',
                  child: Material(
                    color: AppColors.gray1,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onClose,
                      child: const SizedBox.square(dimension: 36, child: Icon(Icons.close_rounded, color: AppColors.gray, size: 20)),
                    ),
                  ),
                ),
              ],
            ]),
          ),
          if (duration != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 3,
              child: ColoredBox(
                color: AppColors.gray2,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 1, end: 0),
                  duration: duration!,
                  builder: (context, v, _) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(widthFactor: v, child: const ColoredBox(color: AppColors.black1, child: SizedBox.expand())),
                  ),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}

/// A tinted round icon for the start of a [NoticeCard].
class NoticeIcon extends StatelessWidget {
  const NoticeIcon({super.key, required this.icon, required this.color, this.iconColor});

  final IconData icon;
  final Color color;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.13), shape: BoxShape.circle),
      child: Icon(icon, color: iconColor ?? color, size: 22),
    );
  }
}

/// Shows a [NoticeCard] at the bottom of the screen. [onClosed] runs once it
/// goes away without its action pressed.
void showNoticeBar(
  BuildContext context, {
  required String title,
  String? sub,
  Widget? leading,
  String? action,
  IconData? actionIcon,
  VoidCallback? onAction,
  VoidCallback? onClosed,
  Duration duration = const Duration(seconds: 5),
  double bottom = 16,
  int titleLines = 3,
}) {
  final m = ScaffoldMessenger.of(context);
  var acted = false;
  m.hideCurrentSnackBar();
  final bar = m.showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    elevation: 0,
    padding: EdgeInsets.zero,
    margin: EdgeInsets.fromLTRB(16, 0, 16, bottom),
    duration: duration,
    content: NoticeCard(
      title: title,
      sub: sub,
      leading: leading,
      action: action,
      actionIcon: actionIcon,
      titleLines: titleLines,
      duration: duration,
      onAction: action == null
          ? null
          : () {
              acted = true;
              m.hideCurrentSnackBar();
              onAction?.call();
            },
    ),
  ));
  if (onClosed != null) {
    bar.closed.then((_) {
      if (!acted) onClosed();
    });
  }
}
