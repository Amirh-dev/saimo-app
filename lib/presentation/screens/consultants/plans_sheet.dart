// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Step 1 of the purchase flow: pick a plan (پایه / حرفه‌ای / پیشرفته) and how
/// long to take it, on one sheet, so the price of every choice is visible
/// before committing. Shown as a modal bottom sheet.

/// What one plan costs for [months]. Prices are whole toman.
class PlanPrice {
  const PlanPrice({
    required this.months,
    required this.total,
    required this.baseTotal,
    required this.discountPercent,
  });

  final int months;

  /// What the student pays for the whole period.
  final int total;

  /// The undiscounted total; shown struck through.
  final int baseTotal;

  final int discountPercent;

  /// The per-month equivalent, rounded down to a thousand toman.
  int get monthly => total ~/ months ~/ 1000 * 1000;

  int get baseMonthly => baseTotal ~/ months ~/ 1000 * 1000;

  bool get hasDiscount => discountPercent > 0 && total < baseTotal;
}

class ConsultationPlan {
  const ConsultationPlan({
    required this.planType,
    required this.name,
    required this.tagline,
    required this.features,
    required this.color,
    required this.icon,
    required this.prices,
    this.includes,
    this.recommended = false,
  });

  /// API enum value: NORMAL | PROFESSIONAL | ADVANCED.
  final String planType;

  /// Short name, e.g. "حرفه‌ای"; [title] adds the "پلن" prefix.
  final String name;

  /// Who the plan is for, in one line.
  final String tagline;

  /// What the plan gives. For every plan above the first, only what it adds
  /// over the previous one, introduced by [includes].
  final List<String> features;

  /// E.g. "همه امکانات پلن پایه، به‌علاوه:".
  final String? includes;

  final Color color;
  final IconData icon;
  final bool recommended;

  /// Keyed by duration in months.
  final Map<int, PlanPrice> prices;

  String get title => 'پلن $name';

  ConsultationPlan withPrices(Map<int, PlanPrice> prices) {
    return ConsultationPlan(
      planType: planType,
      name: name,
      tagline: tagline,
      features: features,
      color: color,
      icon: icon,
      prices: prices,
      includes: includes,
      recommended: recommended,
    );
  }
}

/// The plan and duration the student picked.
class ConsultationChoice {
  const ConsultationChoice({required this.plan, required this.price});

  final ConsultationPlan plan;
  final PlanPrice price;

  int get months => price.months;
  bool get hasGift => months >= kGiftMinMonths;
}

/// Plans of at least this many months come with [kYearlyGift].
const int kGiftMinMonths = 12;
const String kYearlyGift = 'پکیج رایگان مدیریت استرس و جمع‌بندی سایمو';

/// "۶ ماه", "۱ سال".
String durationLabel(int months) => months % 12 == 0
    ? convertToPersianNumbers('${months ~/ 12} سال')
    : convertToPersianNumbers('$months ماه');

/// "۶ ماهه", "۱ ساله".
String durationAdjective(int months) => '${durationLabel(months)}ه';

String formatToman(int amount) =>
    convertToPersianNumbers(amount.toString(), addSeparator: true);

/// Discounts below this are too small to badge.
const int _kMinBadgeDiscount = 5;

PlanPrice _price(int months, int total, int baseMonthly, int discount) =>
    PlanPrice(
      months: months,
      total: total,
      baseTotal: baseMonthly * months,
      discountPercent: discount,
    );

/// The published price list; real offers from the server replace [prices].
final List<ConsultationPlan> kPlans = [
  ConsultationPlan(
    planType: 'NORMAL',
    name: 'پایه',
    tagline: 'مناسب دانش‌آموز منظم و خودخوان',
    color: AppColors.secondary,
    icon: SolarIconsBold.userSpeakRounded,
    features: const [
      'برنامه هفتگی شخصی با متد سایمو',
      'جدول مرور هوشمند درس‌ها',
      '۱ تماس در هفته با مشاور',
      'بررسی روزانه گزارش کار',
    ],
    prices: {
      1: _price(1, 1190000, 1200000, 1),
      3: _price(3, 3140000, 1200000, 14),
      6: _price(6, 5590000, 1200000, 22),
      12: _price(12, 9480000, 1200000, 34),
    },
  ),
  ConsultationPlan(
    planType: 'PROFESSIONAL',
    name: 'حرفه‌ای',
    tagline: 'همراهی کامل تا روز آزمون',
    color: AppColors.primary,
    icon: SolarIconsBold.rocket,
    recommended: true,
    includes: 'همه امکانات پلن پایه، به‌علاوه:',
    features: const [
      '۲ تماس در هفته با مشاور',
      'تحلیل آزمون‌های آزمایشی',
      'پاسخ به سوالات در چت، هر روز',
      'مدیریت استرس، خواب و تغذیه',
    ],
    prices: {
      1: _price(1, 1790000, 1800000, 1),
      3: _price(3, 4640000, 1800000, 14),
      6: _price(6, 8280000, 1800000, 23),
      12: _price(12, 13960000, 1800000, 35),
    },
  ),
  ConsultationPlan(
    planType: 'ADVANCED',
    name: 'پیشرفته',
    tagline: 'نظارت کامل همراه با والدین',
    color: AppColors.simoCoin,
    icon: SolarIconsBold.crown,
    includes: 'همه امکانات پلن حرفه‌ای، به‌علاوه:',
    features: const [
      'پشتیبانی فوری و ارتباط مستقیم',
      'جلسات روان‌شناسی و تقویت تمرکز',
      'گزارش ماهانه و جلسه با والدین',
      'بررسی ویدیویی روش مطالعه و خلاصه‌نویسی',
    ],
    prices: {
      1: _price(1, 2580000, 2600000, 1),
      3: _price(3, 6630000, 2600000, 15),
      6: _price(6, 11840000, 2600000, 24),
      12: _price(12, 19880000, 2600000, 36),
    },
  ),
];

/// Opens the plans sheet. Returns the chosen plan and duration, or null on
/// cancel/dismiss. [plans] defaults to [kPlans]; callers pass offer-priced
/// plans when available.
Future<ConsultationChoice?> showPlansSheet(
  BuildContext context, {
  required String counselorName,
  List<ConsultationPlan>? plans,
}) {
  return showModalBottomSheet<ConsultationChoice>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PlansSheet(
      counselorName: counselorName,
      plans: plans ?? kPlans,
    ),
  );
}

class PlansSheet extends StatefulWidget {
  const PlansSheet({
    super.key,
    required this.counselorName,
    required this.plans,
  });

  final String counselorName;
  final List<ConsultationPlan> plans;

  @override
  State<PlansSheet> createState() => _PlansSheetState();
}

class _PlansSheetState extends State<PlansSheet> {
  late final List<int> _durations = _offeredDurations();
  late int _selected = _initialPlan();
  late int _months = _durations.contains(6)
      ? 6
      : (_durations.isEmpty ? 0 : _durations.last);

  /// Shortest first, so in RTL the shortest sits on the right.
  List<int> _offeredDurations() {
    final months = {for (final plan in widget.plans) ...plan.prices.keys}
        .toList()
      ..sort();
    return months;
  }

  int _initialPlan() {
    final recommended = widget.plans.indexWhere((plan) => plan.recommended);
    return recommended >= 0 ? recommended : 0;
  }

  ConsultationPlan get _plan => widget.plans[_selected];
  PlanPrice? get _price => _plan.prices[_months];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: SafeArea(
        top: false,
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  // Room for the cards' soft shadows.
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_durations.length > 1) ...[
                        _buildDurationSelector(),
                        const SizedBox(height: 10),
                      ],
                      if (_durations.contains(kGiftMinMonths)) ...[
                        _buildGiftBanner(),
                        const SizedBox(height: 16),
                      ],
                      for (var i = 0; i < widget.plans.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _PlanCard(
                            plan: widget.plans[i],
                            price: widget.plans[i].prices[_months],
                            selected: i == _selected,
                            onTap: () => setState(() => _selected = i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  /// Title on the right (start), step and close on the left (end).
  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ReText(
                'انتخاب پلن مشاوره',
                color: AppColors.black1,
                fontSize: 18,
                fontWeight: 1000,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 4),
              ReText(
                widget.counselorName.isEmpty
                    ? 'پلن و مدت همراهی را انتخاب کنید'
                    : 'مشاور: ${widget.counselorName}',
                color: AppColors.gray,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ),
        ReText(
          'مرحله ۱ از ۲',
          color: AppColors.black1.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).maybePop(),
          child: Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gray2),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 22,
              color: AppColors.black1.withOpacity(0.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (final months in _durations)
            Expanded(
              child: _DurationChip(
                label: durationLabel(months),
                discount: _plan.prices[months]?.discountPercent ?? 0,
                selected: months == _months,
                onTap: () => setState(() => _months = months),
              ),
            ),
        ],
      ),
    );
  }

  /// Names the yearly gift: as a nudge (tap to switch to a year) until a
  /// year is picked, then as a confirmation.
  Widget _buildGiftBanner() {
    final yearly = _months >= kGiftMinMonths;
    final yearDiscount = _plan.prices[kGiftMinMonths]?.discountPercent ?? 0;
    final text = yearly
        ? 'هدیه ۱ ساله: پکیج مدیریت استرس و جمع‌بندی'
        : yearDiscount >= _kMinBadgeDiscount
            ? 'ثبت‌نام ۱ ساله: $yearDiscount٪ تخفیف + پکیج هدیه'
            : 'ثبت‌نام ۱ ساله: پکیج هدیه مدیریت استرس';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: yearly ? null : () => setState(() => _months = kGiftMinMonths),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // The gift is the banner's one accent.
            const Icon(
              SolarIconsBold.gift,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ReText(
                text,
                color: AppColors.black1,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.right,
                maxLines: 2,
                lineHeight: 1.6,
              ),
            ),
            if (!yearly) ...[
              const SizedBox(width: 6),
              Icon(
                SolarIconsOutline.altArrowLeft,
                size: 16,
                color: AppColors.black1.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The main action on the right (start), cancel on the left.
  Widget _buildActions() {
    final price = _price;
    return Row(
      children: [
        Expanded(
          child: ReButton(
            text: 'ادامه با ${_plan.title}',
            icon: SolarIconsOutline.altArrowLeft,
            reverseIconPosition: true,
            background: AppColors.primary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            isEnabled: price != null,
            onPressed: () => Navigator.of(context).pop(
              ConsultationChoice(plan: _plan, price: price!),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 96,
          child: ReButton(
            text: 'لغو',
            icon: Icons.close_rounded,
            isOutlined: true,
            reverseIconPosition: true,
            color: AppColors.gray2,
            textColor: AppColors.black1,
            iconColor: AppColors.black1,
            borderRadius: 40,
            fontSize: 16,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.discount,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int discount;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.black1 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReText(
              label,
              color: selected ? AppColors.white : AppColors.gray,
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
            if (discount >= _kMinBadgeDiscount) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: ReText(
                  '$discount٪',
                  color: selected ? AppColors.white : AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final ConsultationPlan plan;

  /// Null when the plan isn't offered for the picked duration.
  final PlanPrice? price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (!plan.recommended) return _buildCard();
    // The ribbon sits on the card's top edge, over the price.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        _buildCard(),
        const Positioned(
          top: -10,
          left: 20,
          child: _RecommendedRibbon(),
        ),
      ],
    );
  }

  /// The plan's color marks only its icon and, once picked, the card's edge.
  Widget _buildCard() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: selected ? plan.color : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(selected ? 0.10 : 0.06),
              blurRadius: selected ? 30 : 44,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopRow(),
              if (selected) _buildDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PlanAvatar(color: plan.color, icon: plan.icon, size: 48),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ReText(
                plan.title,
                color: AppColors.black1,
                fontSize: 15,
                fontWeight: 900,
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 3),
              ReText(
                plan.tagline,
                color: AppColors.black1.withOpacity(0.5),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                maxLines: 2,
                lineHeight: 1.5,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _buildPrice(),
      ],
    );
  }

  Widget _buildPrice() {
    final price = this.price;
    if (price == null) {
      return const ReText(
        'ناموجود',
        color: AppColors.gray,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        ReText(
          'ماهانه',
          color: AppColors.black1.withOpacity(0.5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ReText(
              formatToman(price.monthly),
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 900,
            ),
            const SizedBox(width: 3),
            ReText(
              'تومان',
              color: AppColors.black1.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
        if (price.hasDiscount)
          ReText(
            formatToman(price.baseMonthly),
            color: AppColors.black1.withOpacity(0.45),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.lineThrough,
          ),
      ],
    );
  }

  /// What the plan gives, and what the picked duration costs in total.
  Widget _buildDetails() {
    final price = this.price;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(height: 1, thickness: 1, color: AppColors.gray2.withOpacity(0.6)),
          const SizedBox(height: 10),
          if (plan.includes != null) ...[
            ReText(
              plan.includes!,
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 4),
          ],
          for (final feature in plan.features) _buildFeatureRow(feature),
          if (price != null) ...[
            const SizedBox(height: 8),
            _buildTotal(price),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.gray1,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 14,
              color: AppColors.black1,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ReText(
              text,
              color: AppColors.black1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal(PlanPrice price) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ReText(
            'مبلغ کل ${durationLabel(price.months)}',
            color: AppColors.black1.withOpacity(0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          const Spacer(),
          ReText(
            formatToman(price.total),
            color: AppColors.black1,
            fontSize: 14,
            fontWeight: 900,
          ),
          const SizedBox(width: 3),
          const ReText(
            'تومان',
            color: AppColors.black1,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

class _RecommendedRibbon extends StatelessWidget {
  const _RecommendedRibbon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(SolarIconsBold.star, size: 11, color: AppColors.primary),
          SizedBox(width: 3),
          ReText(
            'پیشنهاد سایمو',
            color: AppColors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

/// The plan's icon on a soft tile of its color.
class PlanAvatar extends StatelessWidget {
  const PlanAvatar({
    super.key,
    required this.color,
    this.icon = SolarIconsBold.userSpeakRounded,
    this.size = 56,
  });

  final Color color;
  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(size * 2 / 7),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
