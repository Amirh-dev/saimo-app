// CupertinoPageTransitionsBuilder moved from material to cupertino in recent
// Flutter releases; importing both resolves it on either side of the move.
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simo_learn/utils/colors.dart';

/// Timing shared by every screen change in the app.
class AppMotion {
  const AppMotion._();

  /// Switching bottom-navigation tabs.
  static const Duration tab = Duration(milliseconds: 320);

  /// Opening a page, and closing it again.
  static const Duration push = Duration(milliseconds: 340);
  static const Duration pop = Duration(milliseconds: 260);

  /// Material's "emphasized decelerate": a quick start and a soft landing.
  static const Curve settle = Cubic(0.05, 0.7, 0.1, 1.0);
}

/// True when the user asked the system to reduce motion.
bool reduceMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// Fade-through: the outgoing page first sinks under the background color,
/// then the incoming one rises with a small move, so the two pages never
/// show through each other. Played backwards when the page closes.
class _FadeThrough extends StatelessWidget {
  const _FadeThrough({
    required this.animation,
    required this.child,
    this.travel = 0,
    this.scaleFrom = 1,
  });

  final Animation<double> animation;
  final Widget child;

  /// Pixels the page glides in from the left, "forward" when reading RTL.
  final double travel;

  /// Scale the page grows from while it appears.
  final double scaleFrom;

  static final Animatable<double> _cover =
      CurveTween(curve: const Interval(0, 0.3, curve: Curves.easeOut));
  static final Animatable<double> _reveal =
      CurveTween(curve: const Interval(0.3, 1, curve: Curves.easeOut));
  static final Animatable<double> _move =
      CurveTween(curve: const Interval(0.3, 1, curve: AppMotion.settle));

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final move = animation.drive(_move);
    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: animation.drive(_cover),
          child: const ColoredBox(
            key: ValueKey('page-transition-cover'),
            color: AppColors.gray1,
          ),
        ),
        FadeTransition(
          opacity: animation.drive(_reveal),
          child: AnimatedBuilder(
            animation: move,
            builder: (context, child) {
              final t = move.value;
              return Transform.translate(
                offset: Offset(-travel * (1 - t), 0),
                child: Transform.scale(
                  scale: scaleFrom + (1 - scaleFrom) * t,
                  child: child,
                ),
              );
            },
            child: child,
          ),
        ),
      ],
    );
  }
}

/// A page opening: it fades through while gliding a few pixels from the
/// left, which is "forward" when reading right to left.
class AppPageTransition extends StatelessWidget {
  const AppPageTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FadeThrough(animation: animation, travel: 28, child: child);
  }
}

/// Switching tabs: the new screen fades through from a hair smaller, while
/// the bottom bar stays in place (it is a [Hero]).
class AppTabTransition extends StatelessWidget {
  const AppTabTransition({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _FadeThrough(animation: animation, scaleFrom: 0.96, child: child);
  }
}

/// The route of a bottom-navigation tab, replacing the previous tab.
class AppTabRoute<T> extends PageRouteBuilder<T> {
  AppTabRoute({required Widget page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: AppMotion.tab,
          reverseTransitionDuration: AppMotion.tab,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              AppTabTransition(animation: animation, child: child),
        );
}

/// [AppPageTransition] for every [MaterialPageRoute].
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Duration get transitionDuration => AppMotion.push;

  @override
  Duration get reverseTransitionDuration => AppMotion.pop;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return AppPageTransition(animation: animation, child: child);
  }
}

const PageTransitionsTheme kAppPageTransitionsTheme = PageTransitionsTheme(
  builders: <TargetPlatform, PageTransitionsBuilder>{
    TargetPlatform.android: AppPageTransitionsBuilder(),
    TargetPlatform.fuchsia: AppPageTransitionsBuilder(),
    TargetPlatform.linux: AppPageTransitionsBuilder(),
    TargetPlatform.windows: AppPageTransitionsBuilder(),
    // iOS keeps its native slide, which carries the swipe-back gesture.
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  },
);
