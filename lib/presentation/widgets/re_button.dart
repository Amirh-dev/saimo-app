import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_dots_loader.dart';

import '../../utils/_utils.dart';
import '_widgets.dart';

class ReButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final FontWeight? fontWeight;
  final bool? isLoading;
  final bool isOutlined;
  final Color? color;
  final Color? background;
  final Color? textColor;
  final double? borderRadius;
  final double? fontSize;
  final double? iconSize;
  final EdgeInsets? padding;
  final TextDirection textDirection;
  final bool? useGestureDetector;
  final bool? showOnlyIcon;
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
    this.fontSize,
    this.iconSize,
    this.textDirection = TextDirection.rtl,
    this.padding,
    this.textColor,
    this.fontWeight,
    this.useGestureDetector,
    this.showOnlyIcon,
    this.isEnabled,
    this.isPersianText,
  });

  void onPressedFunc(BuildContext context) {
    if ((isEnabled ?? true) && (isLoading != true)) {
      vibrate(duration: 20);
      onPressed?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = (isEnabled ?? true) && onPressed != null;
    final double radius = borderRadius ?? 32;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? () => onPressedFunc(context) : null,
        child: Container(
          padding: padding ?? EdgeInsets.zero,
          decoration: BoxDecoration(
            color: (background != null)
                ? background
                : (enabled
                    ? (color ?? AppColors.primary)
                    : AppColors.dark4Color),
            borderRadius: BorderRadius.circular(radius),
            border: isOutlined
                ? Border.all(color: color ?? AppColors.dark4Color)
                : null,
          ),
          alignment: Alignment.center,
          child: buildContent(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return Directionality(
      textDirection: textDirection,
      child: (isLoading != null && isLoading!)
          ? ReDotsLoader(
              color:
                  isOutlined ? (color ?? AppColors.dark4Color) : Colors.white,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showOnlyIcon != null && icon != null) ...[
                  Icon(
                    icon!,
                    color: textColor ??
                        (isOutlined
                            ? (color ?? AppColors.dark4Color)
                            : Colors.white),
                    size: iconSize ?? 22,
                  ).center,
                  if (text != null) const SizedBox(width: 0),
                ],
                if (text != null)
                  Flexible(
                    child: ReText(
                      text!,
                      isPersian: isPersianText ?? true,
                      color: textColor ??
                          (isOutlined
                              ? (color ?? AppColors.dark4Color)
                              : Colors.white),
                      fontSize: fontSize ?? 16,
                      textAlign: TextAlign.center,
                      fontWeight: fontWeight ?? FontWeight.bold,
                      maxLines: 2,
                    ),
                  ),
              ],
            ),
    );
  }
}
