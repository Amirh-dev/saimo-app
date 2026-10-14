import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// The chat is a direct line to the student's advisor. These are the pieces
/// built around that: the page shown before an advisor is chosen, the
/// welcome of an empty conversation, and the advisor's sheet.

/// Ready-made first messages for an empty conversation.
const List<String> kAdvisorStarters = [
  'سلام، وقت بخیر 👋',
  'برنامه این هفته‌ام را بررسی می‌کنید؟',
  'برای تمرکز بیشتر چه پیشنهادی دارید؟',
  'در یک درس عقب افتاده‌ام',
];

int? _daysLeft(DateTime? endDate, DateTime now) {
  if (endDate == null) return null;
  return DateUtils.dateOnly(endDate.toLocal()).difference(DateUtils.dateOnly(now)).inDays;
}

/// "اشتراک فعال تا ۲۴ آبان ۱۴۰۵", or the days left in its last two weeks.
String advisorSubscriptionLabel(DateTime? endDate, {DateTime? now}) {
  final days = _daysLeft(endDate, now ?? DateTime.now());
  if (days == null) return 'اشتراک فعال';
  if (days <= 0) return 'امروز آخرین روز اشتراک است';
  if (days <= 14) return convertToPersianNumbers('$days روز تا پایان اشتراک');
  final end = Jalali.fromDateTime(endDate!.toLocal());
  return convertToPersianNumbers(
    'اشتراک فعال تا ${end.day} ${kPersianMonths[end.month - 1]} ${end.year}',
  );
}

/// Whether the subscription ends within a week, worth a warmer color.
bool advisorSubscriptionEndsSoon(DateTime? endDate, {DateTime? now}) {
  final days = _daysLeft(endDate, now ?? DateTime.now());
  return days != null && days <= 7;
}

// ------------------------------------------------------------- shared bits

class AdvisorAvatar extends StatelessWidget {
  const AdvisorAvatar({super.key, required this.path, this.size = 46, this.ring = false});

  final String? path;
  final double size;

  /// A soft colored halo, for the large avatars.
  final bool ring;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ring ? 4 : 2),
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: ring
            ? [
                BoxShadow(
                  color: AppColors.secondary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: UserAvatar(imageUrl: path, size: size),
    );
  }
}

/// Rises into place [order] beats after its siblings.
class _Rise extends StatelessWidget {
  const _Rise({required this.order, required this.child});

  final int order;
  final Widget child;

  static const int _stepMs = 90;
  static const int _riseMs = 420;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return child;
    final total = _riseMs + order * _stepMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(order * _stepMs / total, 1, curve: AppMotion.settle),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 12),
          child: Transform.scale(scale: 0.96 + 0.04 * value, child: child),
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _pressed = false;

  void _set(bool pressed) {
    if (_pressed != pressed) setState(() => _pressed = pressed);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 260),
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

// ------------------------------------------------------- no advisor chosen

/// The chat before an advisor is chosen: what it is for, a glimpse of such a
/// conversation, and the way to choose one.
class AdvisorIntroView extends StatelessWidget {
  const AdvisorIntroView({super.key, required this.onChoose});

  final VoidCallback onChoose;

  static const List<(IconData, String)> _benefits = [
    (SolarIconsOutline.calendarMark, 'بررسی و تنظیم برنامه هفتگی'),
    (SolarIconsOutline.chatRoundDots, 'پاسخ به سوال‌های درسی و انگیزشی'),
    (SolarIconsOutline.graphUp, 'پیگیری پیشرفت شما در طول مسیر'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _SampleConversation(),
              const SizedBox(height: 26),
              const _Rise(
                order: 4,
                child: Column(
                  children: [
                    ReText(
                      'گفتگو با مشاور',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black1,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    ReText(
                      'این بخش برای گفتگوی مستقیم با مشاور شخصی شماست. پس از انتخاب '
                      'مشاور، برنامه، سوال‌ها و حال درس‌خواندنتان را همین‌جا با او '
                      'در میان بگذارید.',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      textAlign: TextAlign.center,
                      lineHeight: 1.8,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _Rise(
                order: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      for (var index = 0; index < _benefits.length; index++) ...[
                        if (index > 0)
                          const Divider(height: 1, thickness: 1, color: AppColors.gray1),
                        _BenefitRow(icon: _benefits[index].$1, text: _benefits[index].$2),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              _Rise(
                order: 6,
                child: ReButton(
                  key: const ValueKey('advisor-choose'),
                  text: 'انتخاب مشاور',
                  borderRadius: 100,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  onPressed: onChoose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.secondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ReText(
              text,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.black1,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

/// A short made-up exchange that plays in, showing what the chat is for.
class _SampleConversation extends StatelessWidget {
  const _SampleConversation();

  static const List<(bool, String)> _lines = [
    (false, 'سلام، خسته نباشی! گزارش این هفته‌ت رو دیدم؛ خیلی خوب پیش رفتی.'),
    (true, 'سلام، مرسی! به نظرتون برای فیزیک وقت بیشتری بذارم؟'),
    (false, 'آره، به نظرم روزی ۴۵ دقیقه تست فیزیک بذار توی برنامه‌ت.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          for (var index = 0; index < _lines.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            _Rise(
              order: index + 1,
              child: _SampleBubble(mine: _lines[index].$1, text: _lines[index].$2),
            ),
          ],
        ],
      ),
    );
  }
}

class _SampleBubble extends StatelessWidget {
  const _SampleBubble({required this.mine, required this.text});

  final bool mine;
  final String text;

  @override
  Widget build(BuildContext context) {
    const radius = Radius.circular(20);
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 250),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          decoration: BoxDecoration(
            color: mine ? const Color(0xFFEFF2FF) : AppColors.gray1,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: mine ? radius : const Radius.circular(6),
              bottomRight: mine ? const Radius.circular(6) : radius,
            ),
          ),
          child: ReText(
            text,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.black1,
            textAlign: TextAlign.start,
            lineHeight: 1.6,
            maxLines: 3,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------- empty conversation

/// An empty conversation: who the advisor is, and first messages to send.
class AdvisorWelcome extends StatelessWidget {
  const AdvisorWelcome({super.key, required this.advisor, required this.onStarter});

  final ActiveCounselor? advisor;
  final ValueChanged<String> onStarter;

  @override
  Widget build(BuildContext context) {
    final advisor = this.advisor;
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Rise(
              order: 0,
              child: AdvisorAvatar(path: advisor?.avatar, size: 92, ring: true),
            ),
            const SizedBox(height: 14),
            _Rise(
              order: 1,
              child: Column(
                children: [
                  ReText(
                    advisor?.name ?? 'مشاور شما',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  ReText(
                    advisor?.title ?? 'مشاور شما',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const _Rise(
              order: 2,
              child: ReText(
                'گفتگو را با یکی از این پیام‌ها شروع کنید',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.gray,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var index = 0; index < kAdvisorStarters.length; index++)
                  _Rise(
                    order: 3 + index,
                    child: _Pressable(
                      key: ValueKey('advisor-starter-$index'),
                      onTap: () => onStarter(kAdvisorStarters[index]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ReText(
                          kAdvisorStarters[index],
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black1,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------- advisor sheet

/// The advisor's card: who they are, how long the subscription runs, and the
/// way to other advisors.
Future<void> showAdvisorSheet(
  BuildContext context, {
  required ActiveCounselor advisor,
  VoidCallback? onBrowseAdvisors,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.black1.withValues(alpha: 0.25),
    builder: (sheetContext) => Directionality(
      textDirection: TextDirection.rtl,
      child: _AdvisorSheet(
        advisor: advisor,
        onBrowseAdvisors: onBrowseAdvisors == null
            ? null
            : () {
                Navigator.of(sheetContext).pop();
                onBrowseAdvisors();
              },
      ),
    ),
  );
}

class _AdvisorSheet extends StatelessWidget {
  const _AdvisorSheet({required this.advisor, this.onBrowseAdvisors});

  final ActiveCounselor advisor;
  final VoidCallback? onBrowseAdvisors;

  @override
  Widget build(BuildContext context) {
    final endsSoon = advisorSubscriptionEndsSoon(advisor.endDate);
    final tone = endsSoon ? AppColors.primary : AppColors.done;

    return Container(
      key: const ValueKey('advisor-sheet'),
      padding: EdgeInsets.fromLTRB(20, 10, 20, 20 + MediaQuery.paddingOf(context).bottom),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray2,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: AdvisorAvatar(path: advisor.avatar, size: 80, ring: true)),
          const SizedBox(height: 12),
          ReText(
            advisor.name ?? 'مشاور شما',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: AppColors.black1,
            textAlign: TextAlign.center,
          ),
          if (advisor.title != null) ...[
            const SizedBox(height: 2),
            ReText(
              advisor.title!,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: tone.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(SolarIconsOutline.calendarMark, size: 15, color: tone),
                  const SizedBox(width: 6),
                  ReText(
                    advisorSubscriptionLabel(advisor.endDate),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: tone,
                  ),
                ],
              ),
            ),
          ),
          if (onBrowseAdvisors != null) ...[
            const SizedBox(height: 20),
            _Pressable(
              key: const ValueKey('advisor-browse'),
              onTap: onBrowseAdvisors!,
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.gray1,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(SolarIconsOutline.usersGroupRounded, size: 20, color: AppColors.black1),
                    SizedBox(width: 10),
                    Expanded(
                      child: ReText(
                        'مشاوران دیگر',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.black1,
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Icon(SolarIconsOutline.altArrowLeft, size: 16, color: AppColors.gray),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
