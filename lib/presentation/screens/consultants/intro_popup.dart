import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/intro_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Promotes consultants to students who don't have an active one: a while
/// after the app opens, shows [ConsultantIntroCard] in a popup. Shown at most
/// once per app launch.
class ConsultantIntroPopup {
  ConsultantIntroPopup._();

  static const Duration delay = Duration(seconds: 15);

  static bool _scheduled = false;

  /// Starts the countdown. The returned timer should be cancelled by the
  /// caller on dispose; null when the popup was already scheduled this launch.
  static Timer? schedule(BuildContext context) {
    if (_scheduled) return null;
    _scheduled = true;

    return Timer(delay, () {
      if (context.mounted) unawaited(_showIfNoConsultant(context));
    });
  }

  static Future<void> _showIfNoConsultant(BuildContext context) async {
    try {
      final repository =
          ConsultantRepository(context.read<GraphQLRepository>());
      final counselor = await repository.fetchMyActiveCounselor();
      if (counselor != null || !context.mounted) return;
      // Don't interrupt another screen or dialog the user has moved on to.
      if (ModalRoute.of(context)?.isCurrent != true) return;
      await _show(context);
    } catch (_) {
      // Best effort: a failed lookup just skips the promotion.
    }
  }

  static Future<void> _show(BuildContext context) {
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: AppColors.black1.withOpacity(0.2),
      transitionDuration: const Duration(milliseconds: 220),
      transitionBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.94, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: child,
        ),
      ),
      pageBuilder: (dialogContext, _, __) => SafeArea(
        child: Center(
          child: SingleChildScrollView(
            // Room for the hero art that pops above the card.
            padding: const EdgeInsets.fromLTRB(32, 110, 32, 24),
            child: Material(
              type: MaterialType.transparency,
              child: ConsultantIntroCard(
                onClose: () => Navigator.of(dialogContext).pop(),
                onStart: () {
                  Navigator.of(dialogContext).pop();
                  if (context.mounted) {
                    unawaited(context.to(const ConsultantListScreen()));
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
