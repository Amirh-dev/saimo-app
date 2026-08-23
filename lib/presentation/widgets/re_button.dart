import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_dots_loader.dart';

import '../../utils/_utils.dart';
import '_widgets.dart';

class ReButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Object? fontWeight;
  final bool? isLoading;
  final bool isOutlined;
  final Color? color;
  final Color? background;
  final Color? textColor;
  final double? borderRadius;
  final double? height;
  final double? fontSize;
  final double? iconSize;
  final Color? iconColor;
  final EdgeInsets? padding;
  final TextDirection textDirection;
  final bool? useGestureDetector;
  final bool? showOnlyIcon;
  final bool reverseIconPosition;
  final bool? isEnabled;
  final bool? isPersianText;

  const ReButton({
    super.key,
    this.text,
    required this.onPressed,
    this.icon,
    this.isLoading,
    this.isOutlined = false,
    this.color,
    this.background,
    this.borderRadius,
    this.height,
    this.fontSize,
    this.iconSize,
    this.textDirection = TextDirection.rtl,
    this.padding,
    this.textColor,
    this.iconColor,
    this.fontWeight,
    this.useGestureDetector,
    this.showOnlyIcon,
    this.reverseIconPosition = false,
    this.isEnabled,
    this.isPersianText,
  });

  void onPressedFunc(BuildContext context) {
    if ((isEnabled ?? true) && (isLoading != true)) {
      onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = (isEnabled ?? true) && onPressed != null;
    final double radius = borderRadius ?? 32;
    final Color resolvedButtonColor = _resolveButtonColor(enabled);

    return SizedBox(
      width: double.infinity,
      height: height ?? 55,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onPressedFunc(context) : null,
        child: Container(
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color: resolvedButtonColor,
            borderRadius: BorderRadius.circular(radius),
            border: isOutlined
                ? Border.all(color: color ?? AppColors.dark4Color)
                : null,
          ),
          alignment: Alignment.center,
          child: buildContent(resolvedButtonColor),
        ),
      ),
    );
  }

  Color _resolveButtonColor(bool enabled) {
    return background ??
        (enabled ? (color ?? AppColors.primary) : AppColors.dark4Color);
  }

  Object _resolveTextFontWeight(Color resolvedButtonColor) {
    return fontWeight ??
        (resolvedButtonColor == AppColors.primary
            ? FontWeight.w800
            : FontWeight.w600);
  }

  Widget buildContent(Color resolvedButtonColor) {
    final bool hasIcon = icon != null;
    final bool hasText = text != null && text!.trim().isNotEmpty;
    final bool shouldShowOnlyIcon = (showOnlyIcon ?? false) && hasIcon;
    final Color resolvedContentColor = textColor ??
        (isOutlined ? (color ?? AppColors.dark4Color) : Colors.white);
    final Object resolvedFontWeight =
        _resolveTextFontWeight(resolvedButtonColor);

    if (isLoading != null && isLoading!) {
      return ReDotsLoader(color: resolvedContentColor);
    }

    final iconWidget = Icon(
      icon,
      color: iconColor ?? resolvedContentColor,
      size: iconSize ?? 22,
    );
    final textWidget = ReText(
      text ?? '',
      isPersian: isPersianText ?? true,
      color: resolvedContentColor,
      fontSize: fontSize ?? 16,
      textAlign: TextAlign.center,
      fontWeight: resolvedFontWeight,
      maxLines: 2,
    );

    return Directionality(
      textDirection: textDirection,
      child: shouldShowOnlyIcon
          ? Icon(
              icon!,
              color: resolvedContentColor,
              size: iconSize ?? 22,
            ).center
          : hasIcon && hasText
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: reverseIconPosition
                        ? [textWidget, iconWidget]
                        : [iconWidget, textWidget],
                  ),
                )
              : hasIcon
                  ? Icon(
                      icon!,
                      color: iconColor ?? resolvedContentColor,
                      size: iconSize ?? 20,
                    ).center
                  : hasText
                      ? ReText(
                          text!,
                          isPersian: isPersianText ?? true,
                          color: resolvedContentColor,
                          fontSize: fontSize ?? 16,
                          textAlign: TextAlign.center,
                          fontWeight: resolvedFontWeight,
                          maxLines: 2,
                        )
                      : const SizedBox.shrink(),
    );
  }
}

class ReOutlineButton extends StatelessWidget {
  const ReOutlineButton({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.gray2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.gray),
            const SizedBox(width: 7),
            ReText(
              title,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ],
        ),
      ),
    );
  }
}