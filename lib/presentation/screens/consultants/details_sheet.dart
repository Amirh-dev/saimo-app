// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Screen 3 of the consultants flow: "جزئیات مشاوره" — pick consultation
/// duration. Shown as a modal bottom sheet over the list. Static data.
class ConsultationDurationOption {
  const ConsultationDurationOption({
    required this.label,
    required this.discount,
    required this.planTitle,
    required this.months,
  });

  final String label;
  final String discount;

  /// Title used on the plans sheet, e.g. "مشاوره های ۶ ماهه".
  final String planTitle;

  /// Duration in months, sent to the API (requestCounseling.durationMonths).
  final int months;
}

const List<ConsultationDurationOption> kDurations = [
  ConsultationDurationOption(
      label: '۱ سال',
      discount: '۲۵٪',
      planTitle: 'مشاوره های ۱ ساله',
      months: 12),
  ConsultationDurationOption(
      label: '۶ ماه',
      discount: '۱۰٪',
      planTitle: 'مشاوره های ۶ ماهه',
      months: 6),
  ConsultationDurationOption(
      label: '۳ ماه',
      discount: '۵٪',
      planTitle: 'مشاوره های ۳ ماهه',
      months: 3),
];

/// Opens the duration sheet. Returns the selected option, or null on
/// cancel/dismiss.
Future<ConsultationDurationOption?> showConsultationDetailsSheet(
  BuildContext context,
) {
  return showModalBottomSheet<ConsultationDurationOption>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ConsultationDetailsSheet(),
  );
}

class _ConsultationDetailsSheet extends StatefulWidget {
  const _ConsultationDetailsSheet();

  @override
  State<_ConsultationDetailsSheet> createState() =>
      _ConsultationDetailsSheetState();
}

class _ConsultationDetailsSheetState extends State<_ConsultationDetailsSheet> {
  // Default to "۶ ماه" (middle), matching the design.
  int _selected = 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildDiscountBanner(),
            const SizedBox(height: 24),
            const ReText(
              'مدت زمان مشاوره',
              color: AppColors.black1,
              fontSize: 14,
              fontWeight: 600,
              textAlign: TextAlign.start,
            ),
            const SizedBox(height: 12),
            _buildDurationSelector(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ReText(
              '۱/۳',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 13,
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
                child: SvgPicture.asset(
                  'assets/icons/Plus.svg',
                  width: 24,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.black1.withOpacity(0.5),
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ReText(
              'جزئیات مشاوره',
              color: AppColors.black1,
              fontSize: 18,
              fontWeight: 1000,
            ),
            SizedBox(height: 4),
            ReText(
              'انتخاب مدت زمان مشاوره',
              color: AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDiscountBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  // Outer orange glow. Note: the inset white highlight from the
                  // design can't be expressed with Flutter's BoxShadow (no
                  // `inset`); only this outer shadow is applied.
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.30),
                    offset: const Offset(0, 12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  SvgPicture.asset(
                    'assets/icons/discount.svg',
                    width: 24,
                    height: 24,
                  ),
                  // Fakes the inset white highlight (Flutter has no real inset
                  // shadow): a soft white top-glow clipped to the icon shape.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.white.withOpacity(0.20),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: ReText(
                'اگر پلن های بلند مدت رو انتخاب کنی، تخفیف بیشتری میگیری!',
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                maxLines: 2,
                lineHeight: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            for (var i = 0; i < kDurations.length; i++)
              Expanded(
                child: _DurationChip(
                  option: kDurations[i],
                  selected: i == _selected,
                  onTap: () => setState(() => _selected = i),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: ReButton(
            text: 'تایید',
            icon: SolarIconsOutline.altArrowLeft,
            reverseIconPosition: true,
            background: AppColors.primary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            onPressed: () => Navigator.of(context).pop(kDurations[_selected]),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
          child: ReButton(
            text: 'لغو',
            icon: Icons.close_rounded,
            isOutlined: true,
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
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ConsultationDurationOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.black1 : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ReText(
                option.discount,
                color: selected ? AppColors.white : AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            ReText(
              option.label,
              color: selected ? AppColors.white : AppColors.gray,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
          ],
        ),
      ),
    );
  }
}
