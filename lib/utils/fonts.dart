import 'dart:ui';

class AppFonts {
  static const String iranSansVar = 'IRANSansVar';

  const AppFonts._();

  static double variableWeight(Object? weight) {
    if (weight is num) {
      return weight.clamp(1, 1000).toDouble();
    }

    if (weight is FontWeight) {
      final weightIndex = FontWeight.values.indexOf(weight);
      if (weightIndex >= 0) {
        return ((weightIndex + 1) * 100).toDouble();
      }
    }

    return 400;
  }

  static List<FontVariation> fontVariations(Object? weight) {
    return <FontVariation>[
      FontVariation.weight(variableWeight(weight)),
      const FontVariation('DOTS', 4),
    ];
  }
}
