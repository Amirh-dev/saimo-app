import 'package:flutter/material.dart';

import '../../utils/_utils.dart';

class ReText extends StatelessWidget {
  final String text;
  final double fontSize;
  final int? maxLines;
  final Object? fontWeight;
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
    this.fontFamily = AppFonts.iranSans,
    this.overflow = TextOverflow.ellipsis,
    this.textDirection = TextDirection.rtl,
    this.lineHeight,
    this.maxLines,
    this.decoration,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedWeightConfig = _resolveFontWeight(
      requestedWeight: isBold ? FontWeight.bold : fontWeight,
    );
    final resolvedFontFamily = resolvedWeightConfig.variableWeight == null
        ? fontFamily
        : AppFonts.iranSansVar;

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
        fontWeight: resolvedWeightConfig.staticWeight,
        fontVariations: resolvedWeightConfig.variableWeight == null
            ? null
            : <FontVariation>[
                FontVariation.weight(resolvedWeightConfig.variableWeight!),
              ],
        color: color,
        letterSpacing: -0.5,
        fontFamily: resolvedFontFamily,
      ),
      textDirection: textDirection,
      textAlign: textAlign,
      overflow: overflow,
    );
  }

  _ResolvedFontWeight _resolveFontWeight({
    required Object? requestedWeight,
  }) {
    if (requestedWeight is num) {
      final normalizedWeight = requestedWeight.toDouble();
      if (normalizedWeight > 900) {
        return _ResolvedFontWeight(
          variableWeight: normalizedWeight.clamp(1, 1000).toDouble(),
        );
      }

      final roundedWeightStep =
          (normalizedWeight.clamp(100, 900) / 100).round().clamp(1, 9);
      return _ResolvedFontWeight(
        staticWeight: FontWeight.values[roundedWeightStep - 1],
      );
    }

    return _ResolvedFontWeight(
      staticWeight:
          requestedWeight is FontWeight ? requestedWeight : FontWeight.normal,
    );
  }
}

class _ResolvedFontWeight {
  final FontWeight? staticWeight;
  final double? variableWeight;

  const _ResolvedFontWeight({
    this.staticWeight,
    this.variableWeight,
  });
}
