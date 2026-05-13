import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simo_learn/utils/_utils.dart';

class ReTimelineDot extends StatelessWidget {
  const ReTimelineDot({
    super.key,
    required this.showTopLine,
    required this.showBottomLine,
    required this.height,
    this.isDone = false,
    this.onTap,
    this.width = 34,
    this.circleSize = 32,
    this.innerCircleSize = 24,
    this.lineColor = AppColors.gray,
    this.dotColor = AppColors.white,
    this.activeColor = AppColors.done,
    this.activeBackgroundColor,
    this.inactiveBorderColor = AppColors.gray,
    this.inactiveBorderWidth = 2,
    this.segmentWidth = 2,
    this.segmentHeight = 2.8,
    this.segmentGap = 3,
    this.dotConnectorGap = 3,
    this.child,
    this.innerPadding,
    this.outerPadding,
  });

  final bool showTopLine;
  final bool showBottomLine;
  final bool isDone;
  final double height;
  final VoidCallback? onTap;
  final double width;
  final double circleSize;
  final double innerCircleSize;
  final Color lineColor;
  final Color dotColor;
  final Color activeColor;
  final Color? activeBackgroundColor;
  final Color inactiveBorderColor;
  final double inactiveBorderWidth;
  final double segmentWidth;
  final double segmentHeight;
  final double segmentGap;
  final double dotConnectorGap;
  final Widget? child;
  final EdgeInsets? innerPadding;
  final EdgeInsets? outerPadding;

  @override
  Widget build(BuildContext context) {
    final lineAreaHeight = math.max(
      0.0,
      (height - circleSize - (dotConnectorGap * 2)) / 2,
    );
    final fittedSegmentCount = math.max(
      1,
      (lineAreaHeight / (segmentHeight + segmentGap)).floor(),
    );

    Widget buildShortLine() => Container(
          width: segmentWidth,
          height: segmentHeight,
          decoration: BoxDecoration(
            color: lineColor,
            borderRadius: BorderRadius.circular(100),
          ),
        );

    Widget buildShortLines(bool visible) {
      if (!visible ||
          lineAreaHeight < segmentHeight ||
          fittedSegmentCount == 0) {
        return SizedBox(height: lineAreaHeight);
      }

      final effectiveGap = math.max(
        0.0,
        (lineAreaHeight / fittedSegmentCount) - segmentHeight,
      );
      final edgeGap = effectiveGap / 2;

      return SizedBox(
        height: lineAreaHeight,
        child: Stack(
          children: List.generate(
            fittedSegmentCount,
            (index) {
              final top = edgeGap + (index * (segmentHeight + effectiveGap));
              return Positioned(
                top: top,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: buildShortLine(),
                ),
              );
            },
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildShortLines(showTopLine),
          SizedBox(height: dotConnectorGap),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Container(
              width: circleSize,
              height: circleSize,
              padding: outerPadding,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: Container(
                width: innerCircleSize,
                height: innerCircleSize,
                margin: innerPadding ?? const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDone
                      ? (activeBackgroundColor ?? activeColor.withOpacity(0.2))
                      : dotColor,
                  border: Border.all(
                    width: inactiveBorderWidth,
                    color: isDone ? Colors.transparent : inactiveBorderColor,
                  ),
                  shape: BoxShape.circle,
                ),
                child: child ??
                    (isDone
                        ? Icon(
                            CupertinoIcons.checkmark_alt,
                            size: innerCircleSize * 0.66,
                            color: activeColor,
                          )
                        : null),
              ),
            ),
          ),
          SizedBox(height: dotConnectorGap),
          buildShortLines(showBottomLine),
        ],
      ),
    );
  }
}
