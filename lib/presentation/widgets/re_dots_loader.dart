import 'dart:math';

import 'package:flutter/material.dart';

import '../../utils/extentions.dart';

class ReDotsLoader extends StatefulWidget {
  final Color color;
  final double dotRadius;
  final Duration duration;

  const ReDotsLoader({
    Key? key,
    this.color = Colors.white,
    this.dotRadius = 5.0,
    this.duration = const Duration(milliseconds: 350),
  }) : super(key: key);

  @override
  State<ReDotsLoader> createState() => _ReDotsLoaderState();
}

class _ReDotsLoaderState extends State<ReDotsLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _animations = List.generate(3, (index) {
      return Tween<double>(begin: 0.1, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(0.0, (index + 1) * 0.3),
        ),
      );
    });

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          return AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Opacity(
                opacity: max(0.1, _animations[index].value),
                child: child,
              );
            },
            child: AnimatedBuilder(
              animation: _animations[index],
              builder: (context, child) {
                return Opacity(
                  opacity: max(0.1, _animations[index].value),
                  child: child,
                );
              },
              child: _Dot(
                color: widget.color,
                radius: widget.dotRadius,
              ).lMargin(5),
            ),
          );
        }),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  final double radius;

  const _Dot({Key? key, required this.color, required this.radius})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
