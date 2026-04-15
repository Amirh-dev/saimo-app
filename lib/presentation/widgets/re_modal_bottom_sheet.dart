import 'package:flutter/material.dart';
import 'package:simo_learn/utils/colors.dart';

Future<T?> showReModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
  bool enableDrag = true,
  Color backgroundColor = Colors.transparent,
  Color? barrierColor,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor ?? AppColors.black1.withOpacity(0.2),
    builder: builder,
  );
}
