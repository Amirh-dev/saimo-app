import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/presentation/screens/dashboard/live_tasks.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/widgets/modal.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// The two numbers that keep the user going, as the home and the profile
/// show them: today's study and the score multiplier.
class StudyMetricsRow extends StatelessWidget {
  const StudyMetricsRow({
    super.key,
    required this.consistency,
    required this.currentTab,
  });

  /// Null until the server has answered; both boxes show «—» meanwhile.
  final DashboardConsistency? consistency;

  /// The tab showing the row, for opening the statistics tab from it.
  final int currentTab;

  @override
  Widget build(BuildContext context) {
    final consistency = this.consistency;
    // The study box counts on while a timer runs.
    return ListenableBuilder(
      listenable: TaskTimerService.instance,
      builder: (context, _) {
        final studiedSeconds = consistency == null
            ? null
            : liveStudiedSeconds(consistency, TaskTimerService.instance);
        return Row(
          children: [
            Expanded(
              child: _MetricCard(
                value: studiedSeconds == null ? '—' : _clock(studiedSeconds),
                label: 'مطالعه‌ی امروز',
                color: AppColors.secondary,
                icon: const Icon(
                  SolarIconsOutline.clockCircle,
                  color: AppColors.white,
                  size: 17,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: AppColors.black1,
                ),
                semanticsLabel: 'آمار',
                onTap: () => navigateToIndex(context, 3, currentTab),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MetricCard(
                value: consistency == null ? '—' : '${consistency.level}×',
                label: _multiplierLine(consistency),
                color: _flameRed,
                ring: consistency?.fraction ?? 0,
                icon: SvgPicture.asset('assets/icons/flame.svg'),
                trailing: SvgPicture.asset('assets/icons/info_circle.svg'),
                semanticsLabel: 'درباره‌ی ضریب امتیاز',
                onTap: () => _openMultiplierInfo(context),
              ),
            ),
          ],
        );
      },
    );
  }

  /// «۳:۳۵»
  static String _clock(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes ~/ 60}:${(minutes % 60).toString().padLeft(2, '0')}';
  }

  /// What today still needs for the multiplier, in a few words.
  static String _multiplierLine(DashboardConsistency? consistency) {
    if (consistency == null) return 'ضریب امتیاز';
    if (consistency.countedToday) return 'امروز حساب شد';
    if (!consistency.hasPlan) return 'بدون برنامه';
    final minutes = consistency.remainingMinutes;
    if (consistency.level >= consistency.maxLevel) {
      return '$minutes دقیقه مانده';
    }
    return '$minutes دقیقه تا ${consistency.level + 1}×';
  }

  void _openMultiplierInfo(BuildContext context) => openInfoModal(
        context,
        title: 'ضریب امتیاز',
        iconAsset: 'assets/icons/flame.svg',
        iconColor: _flameRed,
        sections: const [
          InfoSection(
            'ضریب امتیاز چیست؟',
            'ضریب امتیاز نشان می‌دهد چقدر منظم درس می‌خوانید؛ از ۱× تا ۵×.',
          ),
          InfoSection(
            'چطور بیشتر می‌شود؟',
            'هر روزی که دست‌کم ۷۰٪ برنامه‌ی زمان‌دار همان روز را انجام دهید و حداقل ۹۰ دقیقه با تایمر مطالعه کنید، ضریب یکی بیشتر می‌شود.',
          ),
          InfoSection(
            'اگر روزی نشد؟',
            'روزی که برنامه داشتید ولی به این حد نرسیدید، ضریب یکی کم می‌شود. روزی که برنامه‌ای نچیده باشید، ضریب تغییری نمی‌کند.',
          ),
        ],
      );
}

const Color _flameRed = Color(0xFFFF3040);

/// «ارتقا به ویژه» for a regular account, opening the premium offer;
/// «کاربر ویژه» once premium.
class PlanBadge extends StatelessWidget {
  const PlanBadge({super.key, required this.isPremium, this.onTap});

  final bool isPremium;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.fromSTEB(9, 5, 11, 5),
          decoration: BoxDecoration(
            color: AppColors.simoCoin,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(SolarIconsOutline.stars,
                  size: 14, color: AppColors.white),
              const SizedBox(width: 4),
              ReText(
                isPremium ? 'کاربر ویژه' : 'ارتقا به ویژه',
                fontSize: 11.5,
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              if (!isPremium) ...[
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppColors.white,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
    required this.trailing,
    required this.semanticsLabel,
    required this.onTap,
    this.ring,
  });

  final String value;
  final String label;
  final Color color;
  final Widget icon;
  final Widget trailing;
  final String semanticsLabel;
  final VoidCallback onTap;

  /// Progress drawn around the icon, from 0 to 1; none when null.
  final double? ring;

  @override
  Widget build(BuildContext context) {
    final ring = this.ring;
    final badge = Container(
      width: 32,
      height: 32,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: icon,
    );

    return Semantics(
      button: true,
      label: semanticsLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // The ring hugs the icon without taking room from the text.
              Stack(
                clipBehavior: Clip.none,
                children: [
                  badge,
                  if (ring != null)
                    Positioned(
                      left: -5,
                      top: -5,
                      right: -5,
                      bottom: -5,
                      child: CustomPaint(
                        painter: _RingPainter(fraction: ring, color: color),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReText(
                      value,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      maxLines: 1,
                    ),
                    // Shrinks a little on narrow phones rather than cut.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: ReText(
                        label,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gray,
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray2),
                  shape: BoxShape.circle,
                ),
                child: Center(child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A thin track around the metric icon, filled clockwise from the top.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction, required this.color});

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 2.5;
    final rect = Offset.zero & size;
    final arc = rect.deflate(stroke / 2);
    canvas.drawOval(
      arc,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color.withValues(alpha: 0.15),
    );
    if (fraction <= 0) return;
    canvas.drawArc(
      arc,
      -math.pi / 2,
      2 * math.pi * fraction.clamp(0.0, 1.0),
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color;
}
