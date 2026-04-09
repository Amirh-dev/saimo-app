import 'package:flutter/material.dart';

import '../../utils/_utils.dart';

class ReText extends StatelessWidget {
  final String text;
  final double fontSize;
  final int? maxLines;
  final FontWeight fontWeight;
  final bool isBold;
  final bool isPersian;
  final TextAlign textAlign;
  final Color? color;
  final String? fontFamily;
  final double? lineHeight;
  final TextOverflow overflow;
  final TextDirection textDirection;
  final TextDecoration? decoration;
  final List<Shadow>? shadows;

  const ReText(
    this.text, {
    super.key,
    this.fontSize = 13.0,
    this.fontWeight = FontWeight.normal,
    this.isBold = false,
    this.isPersian = true,
    this.textAlign = TextAlign.end,
    this.color,
    this.fontFamily = 'Sanse',
    this.overflow = TextOverflow.ellipsis,
    this.textDirection = TextDirection.rtl,
    this.lineHeight,
    this.maxLines,
    this.decoration,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      isPersian ? convertToPersianNumbers(text) : text,
      maxLines: maxLines,
      style: TextStyle(
        shadows: shadows,
        decoration: decoration,
        height: lineHeight,
        fontSize: fontSize,
        decorationColor: color,
        decorationThickness: 2,
        fontWeight: isBold ? FontWeight.bold : fontWeight,
        color: color,
        letterSpacing: -0.5,
        fontFamily: fontFamily,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
      overflow: overflow,
    );
  }
}
