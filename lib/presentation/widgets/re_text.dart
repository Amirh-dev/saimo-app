import 'package:flutter/material.dart';
import 'package:simo_learn/utils/colors.dart';

class ReText extends StatelessWidget {
  final String text;
  final double? size;
  final Color? color;
  final FontWeight? weight;

  const ReText(
    this.text, {
    super.key,
    this.size,
    this.color,
    this.weight,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: size ?? 14,
        color: color ?? AppColors.textPrimary,
        fontWeight: weight ?? FontWeight.normal,
      ),
    );
  }
}
