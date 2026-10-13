import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/presentation/screens/consultants/active_counselor_store.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/intro_screen.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Promotes consultants to students who don't have an active one: a while
/// after the app opens, shows [ConsultantIntroCard] in a popup. Shown at most
/// once per app launch, never during the first [gracePeriod] after the app is
/// first opened, and not again on a day the popup was already dismissed.
class ConsultantIntroPopup {
  ConsultantIntroPopup._();

  static const Duration delay = Duration(seconds: 15);
  static const Duration gracePeriod = Duration(days: 2);

  static const String _firstSeenKey = 'consultant_popup_first_seen_at';
  static const String _dismissedDayKey = 'consultant_popup_dismissed_day';

  static bool _scheduled = false;

  /// Starts the countdown. The returned timer should be cancelled by the
  /// caller on dispose; null when the popup was already scheduled this launch.
  static Timer? schedule(BuildContext context) {
    if (_scheduled) return null;
    _scheduled = true;

    unawaited(_recordFirstSeen());
    return Timer(delay, () {
      if (context.mounted) unawaited(_showIfNoConsultant(context));
    });
  }

  static Future<void> _recordFirstSeen() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(_firstSeenKey)) return;
    await preferences.setString(
      _firstSeenKey,
      DateTime.now().toIso8601String(),
    );
  }

  static Future<bool> _isAllowedNow() async {
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();

    final firstSeen =
        DateTime.tryParse(preferences.getString(_firstSeenKey) ?? '');
    if (firstSeen == null || now.difference(firstSeen) < gracePeriod) {
      return false;
    }

    return preferences.getString(_dismissedDayKey) != _dayKey(now);
  }

  static Future<void> _recordDismissedToday() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_dismissedDayKey, _dayKey(DateTime.now()));
  }

  static String _dayKey(DateTime time) =>
      '${time.year}-${time.month}-${time.day}';

  static Future<void> _showIfNoConsultant(BuildContext context) async {
    try {
      if (!await _isAllowedNow() || !context.mounted) return;
      final repository =
          ConsultantRepository(context.read<GraphQLRepository>());
      final counselor = await repository.fetchMyActiveCounselor();
      ActiveCounselorStore.instance.set(counselor);
      if (counselor != null || !context.mounted) return;
      // Don't interrupt another screen or dialog the user has moved on to.
      if (ModalRoute.of(context)?.isCurrent != true) return;
      await _show(context);
      await _recordDismissedToday();
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
