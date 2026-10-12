import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// A short-lived pill confirming a change, with a way to take it back.
class UndoBar extends StatelessWidget {
  const UndoBar({super.key, required this.message, required this.onUndo});

  final String message;
  final VoidCallback onUndo;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Material(
        color: Colors.transparent,
        child: Container(
          key: const ValueKey('undo-bar'),
          height: 52,
          padding: const EdgeInsetsDirectional.only(start: 18, end: 6),
          decoration: BoxDecoration(
            color: AppColors.black1,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: AppColors.black1.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.done),
              const SizedBox(width: 8),
              Expanded(
                child: ReText(
                  message,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
              Semantics(
                button: true,
                child: GestureDetector(
                  key: const ValueKey('undo-bar-action'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onUndo,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: ReText(
                      'بازگرداندن',
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
