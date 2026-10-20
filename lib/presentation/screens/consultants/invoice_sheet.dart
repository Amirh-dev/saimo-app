// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Step 2 of the purchase flow: "صورتحساب" — payment summary. Shown as a
/// modal bottom sheet.
///
/// "تایید و پرداخت" runs [onConfirm] (preparing the bank gateway) with the
/// button in its loading state and the sheet still open, so a failure shows
/// inline and the student can retry without picking the plan again. Returns
/// [onConfirm]'s result, or null on cancel/dismiss. [notice] explains the
/// previous try (e.g. "payment was not completed") when the sheet reopens;
/// [noticeIsError] tints it as an error.
Future<T?> showInvoiceSheet<T>(
  BuildContext context, {
  required ConsultationChoice choice,
  required Future<T> Function() onConfirm,
  String? notice,
  bool noticeIsError = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    // Closing mid-request is blocked below; the buttons stay available.
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => _InvoiceSheet<T>(
      choice: choice,
      onConfirm: onConfirm,
      notice: notice,
      noticeIsError: noticeIsError,
    ),
  );
}

class _InvoiceSheet<T> extends StatefulWidget {
  const _InvoiceSheet({
    super.key,
    required this.choice,
    required this.onConfirm,
    this.notice,
    this.noticeIsError = false,
  });

  final ConsultationChoice choice;
  final Future<T> Function() onConfirm;
  final String? notice;
  final bool noticeIsError;

  @override
  State<_InvoiceSheet<T>> createState() => _InvoiceSheetState<T>();
}

class _InvoiceSheetState<T> extends State<_InvoiceSheet<T>> {
  bool _busy = false;
  late String? _message = widget.notice;
  late bool _messageIsError = widget.noticeIsError;

  ConsultationChoice get choice => widget.choice;
  ConsultationPlan get plan => widget.choice.plan;
  PlanPrice get price => widget.choice.price;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _message = checkoutErrorMessage(error);
        _messageIsError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: _buildSheet(context),
    );
  }

  Widget _buildSheet(BuildContext context) {
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
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildDurationRow(),
            const SizedBox(height: 12),
            _buildPlanRow(),
            if (choice.hasGift) ...[
              const SizedBox(height: 12),
              _buildGiftRow(),
            ],
            if (_message != null) ...[
              const SizedBox(height: 16),
              _buildMessage(_message!),
            ],
            const SizedBox(height: 24),
            _buildActions(context),
            const SizedBox(height: 12),
            _buildSecureNote(),
          ],
        ),
      ),
    );
  }

  /// Title on the right (start), step and close on the left (end).
  Widget _buildHeader(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ReText(
                'صورتحساب',
                color: AppColors.black1,
                fontSize: 18,
                fontWeight: 1000,
              ),
              SizedBox(height: 4),
              ReText(
                'جزئیات پرداخت و هزینه مشاوره',
                color: AppColors.gray,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),
        ReText(
          'مرحله ۲ از ۲',
          color: AppColors.black1.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(width: 12),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _busy ? null : () => Navigator.of(context).maybePop(),
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

  Widget _buildDurationRow() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          border: Border.all(color: AppColors.gray2)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.black1,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: const Icon(
                SolarIconsOutline.alarm,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 10),
            ReText(
              'مدت زمان',
              color: AppColors.black1.withOpacity(0.5),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            const Spacer(),
            ReText(
              durationLabel(price.months),
              color: AppColors.black1,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanRow() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 44,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
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
                    fontSize: 14,
                    fontWeight: 900,
                    textAlign: TextAlign.right,
                  ),
                  const SizedBox(height: 2),
                  ReText(
                    'قابل پرداخت',
                    color: AppColors.black1.withOpacity(0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _priceNumber(formatToman(price.total)),
                      const SizedBox(width: 4),
                      ReText(
                        'تومــان',
                        color: AppColors.black1.withOpacity(0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                if (price.hasDiscount) ...[
                  const SizedBox(height: 2),
                  ReText(
                    formatToman(price.baseTotal),
                    color: AppColors.black1.withOpacity(0.5),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.lineThrough,
                  ),
                ],
              ],
            ),
            if (price.hasDiscount) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ReText(
                  '${price.discountPercent}٪',
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Renders the price in black, digit groups and separators as separate
  /// runs so the separators stay bold.
  Widget _priceNumber(String price) {
    final parts = price.split(',');
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      children.add(
        ReText(
          parts[i],
          color: AppColors.black1,
          fontSize: 16,
          fontWeight: FontWeight.w900,
          textDirection: TextDirection.ltr,
        ),
      );
      if (i != parts.length - 1) {
        children.add(
          const ReText(
            ',',
            color: AppColors.black1,
            fontSize: 16,
            fontWeight: 900,
            textDirection: TextDirection.ltr,
          ),
        );
      }
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: children,
    );
  }

  Widget _buildGiftRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            Icon(SolarIconsBold.gift, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: ReText(
                'هدیه: $kYearlyGift',
                color: AppColors.black1,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.right,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Inline result of the last try: red for errors, neutral otherwise.
  Widget _buildMessage(String message) {
    final color = _messageIsError ? AppColors.errorColor : AppColors.black1;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _messageIsError
            ? AppColors.errorColor.withOpacity(0.06)
            : AppColors.gray1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _messageIsError
                  ? SolarIconsOutline.dangerCircle
                  : SolarIconsOutline.infoCircle,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ReText(
                message,
                maxLines: 5,
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecureNote() {
    return const Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            size: 14,
            color: AppColors.gray,
          ),
          SizedBox(width: 4),
          ReText(
            'پرداخت از طریق درگاه امن بانکی (شاپرک)',
            color: AppColors.gray,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  /// The main action on the right (start), cancel on the left.
  Widget _buildActions(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        Expanded(
          child: ReButton(
            text: widget.notice == null ? 'تایید و پرداخت' : 'پرداخت دوباره',
            icon: SolarIconsOutline.altArrowLeft,
            reverseIconPosition: true,
            background: AppColors.primary,
            borderRadius: 40,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            isLoading: _busy,
            onPressed: _confirm,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 110,
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
            isEnabled: !_busy,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ),
      ],
    );
  }
}
