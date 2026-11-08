// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';
import 'package:simo_learn/presentation/screens/consultants/counseling_checkout.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/_utils.dart';
import 'package:solar_icons/solar_icons.dart';

/// Step 2 of the purchase flow: "صورتحساب" — payment summary. Shown as a
/// modal bottom sheet.
///
/// "تأیید و پرداخت" runs [onConfirm] (preparing the bank gateway) with the
/// button in its loading state and the sheet still open, so a failure shows
/// inline and the student can retry without picking the plan again. Returns
/// [onConfirm]'s result, or null on cancel/dismiss. [notice] explains the
/// previous try (e.g. "payment was not completed") when the sheet reopens;
/// [noticeIsError] tints it as an error.
///
/// With [checkDiscount] the student can apply a discount code; [onConfirm]
/// receives the applied one. [discount] restores a code applied before the
/// sheet was reopened.
Future<T?> showInvoiceSheet<T>(
  BuildContext context, {
  required ConsultationChoice choice,
  required Future<T> Function(DiscountPreview? discount) onConfirm,
  Future<DiscountPreview> Function(String code)? checkDiscount,
  DiscountPreview? discount,
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
      checkDiscount: checkDiscount,
      discount: discount,
      notice: notice,
      noticeIsError: noticeIsError,
    ),
  );
}

/// Upper-cases a typed code and keeps only what the server accepts: English
/// letters, digits (Persian and Arabic ones converted), '-' and '_'.
class DiscountCodeFormatter extends TextInputFormatter {
  const DiscountCodeFormatter();

  static const int maxLength = 32;

  static String normalize(String text) {
    final out = StringBuffer();
    for (final rune in text.runes) {
      var c = rune;
      if (c >= 0x06F0 && c <= 0x06F9) c = 0x30 + c - 0x06F0;
      if (c >= 0x0660 && c <= 0x0669) c = 0x30 + c - 0x0660;
      if (c >= 0x61 && c <= 0x7A) c -= 0x20;
      final keep = (c >= 0x41 && c <= 0x5A) ||
          (c >= 0x30 && c <= 0x39) ||
          c == 0x2D ||
          c == 0x5F;
      if (keep && out.length < maxLength) out.writeCharCode(c);
    }
    return out.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = normalize(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class _InvoiceSheet<T> extends StatefulWidget {
  const _InvoiceSheet({
    super.key,
    required this.choice,
    required this.onConfirm,
    this.checkDiscount,
    this.discount,
    this.notice,
    this.noticeIsError = false,
  });

  final ConsultationChoice choice;
  final Future<T> Function(DiscountPreview? discount) onConfirm;
  final Future<DiscountPreview> Function(String code)? checkDiscount;
  final DiscountPreview? discount;
  final String? notice;
  final bool noticeIsError;

  @override
  State<_InvoiceSheet<T>> createState() => _InvoiceSheetState<T>();
}

class _InvoiceSheetState<T> extends State<_InvoiceSheet<T>> {
  bool _busy = false;
  late String? _message = widget.notice;
  late bool _messageIsError = widget.noticeIsError;

  late DiscountPreview? _discount = widget.discount;
  bool _codeOpen = false;
  bool _checking = false;
  String? _codeError;
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();

  ConsultationChoice get choice => widget.choice;
  ConsultationPlan get plan => widget.choice.plan;
  PlanPrice get price => widget.choice.price;

  @override
  void initState() {
    super.initState();
    _codeFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_busy || _checking) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await widget.onConfirm(_discount);
      if (mounted) Navigator.of(context).pop(result);
    } catch (error) {
      if (!mounted) return;
      // The code stopped being usable after it was applied: drop it and say
      // why next to the field, so paying the full price is a choice.
      final discountMessage = discountRejectionMessage(error);
      setState(() {
        _busy = false;
        if (discountMessage != null && _discount != null) {
          _codeController.text = _discount!.code;
          _discount = null;
          _codeOpen = true;
          _codeError = discountMessage;
        } else {
          _message = checkoutErrorMessage(error);
          _messageIsError = true;
        }
      });
    }
  }

  Future<void> _applyCode() async {
    final code = DiscountCodeFormatter.normalize(_codeController.text);
    final check = widget.checkDiscount;
    if (code.isEmpty || check == null || _checking) return;
    setState(() {
      _checking = true;
      _codeError = null;
    });
    try {
      final preview = await check(code);
      if (!mounted) return;
      setState(() {
        _checking = false;
        if (preview.isValid) {
          _discount = preview;
          _codeOpen = false;
          _codeFocus.unfocus();
        } else {
          _codeError = discountStatusMessage(preview.status);
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _codeError = discountCheckErrorMessage(error);
      });
    }
  }

  void _removeCode() {
    setState(() {
      _discount = null;
      _codeError = null;
      _codeController.clear();
    });
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
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        12 + MediaQuery.viewInsetsOf(context).bottom,
      ),
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
            if (widget.checkDiscount != null) ...[
              const SizedBox(height: 12),
              if (_discount != null)
                _buildCodeApplied(_discount!)
              else if (_codeOpen)
                _buildCodeField()
              else
                _buildCodeCollapsed(),
              if (_codeError != null && _discount == null) ...[
                const SizedBox(height: 8),
                _buildCodeError(_codeError!),
              ],
              if (_discount != null) ...[
                const SizedBox(height: 12),
                _buildBreakdown(_discount!),
              ],
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
                    // With a code, the amount to pay is in the breakdown.
                    _discount == null ? 'قابل پرداخت' : 'قیمت پلن',
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
  Widget _priceNumber(String price,
      {double fontSize = 16, Color color = AppColors.black1}) {
    final parts = price.split(',');
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      children.add(
        ReText(
          parts[i],
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          textDirection: TextDirection.ltr,
        ),
      );
      if (i != parts.length - 1) {
        children.add(
          ReText(
            ',',
            color: color,
            fontSize: fontSize,
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

  /// A quiet capsule; tapping it opens the code field.
  Widget _buildCodeCollapsed() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _busy
          ? null
          : () {
              setState(() => _codeOpen = true);
              _codeFocus.requestFocus();
            },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Icon(SolarIconsOutline.ticketSale,
                  size: 20, color: AppColors.black1),
              SizedBox(width: 8),
              Expanded(
                child: ReText(
                  'کد تخفیف داری؟',
                  color: AppColors.black1,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.right,
                ),
              ),
              ReText(
                'وارد کن',
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
              SizedBox(width: 2),
              Icon(SolarIconsOutline.altArrowLeft,
                  size: 16, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  /// The code field with a dark «اعمال» pill inside it. Red after a rejected
  /// code, primary while focused.
  Widget _buildCodeField() {
    final hasError = _codeError != null;
    final focused = _codeFocus.hasFocus;
    final canApply = _codeController.text.isNotEmpty && !_checking && !_busy;
    return Container(
      height: 52,
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: hasError
              ? AppColors.errorColor
              : focused
                  ? AppColors.primary
                  : AppColors.gray2,
          width: hasError || focused ? kFocusedFieldBorderWidth : 1,
        ),
        boxShadow: focused && !hasError ? kFocusedFieldShadow : null,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            const Icon(SolarIconsOutline.ticketSale,
                size: 20, color: AppColors.black1),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                key: const ValueKey('discount-code-field'),
                controller: _codeController,
                focusNode: _codeFocus,
                enabled: !_busy,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.visiblePassword,
                textCapitalization: TextCapitalization.characters,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.done,
                inputFormatters: const [DiscountCodeFormatter()],
                onChanged: (_) => setState(() => _codeError = null),
                onSubmitted: (_) => _applyCode(),
                cursorColor: AppColors.primary,
                style: const TextStyle(
                  color: AppColors.black1,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'کد تخفیف',
                  hintTextDirection: TextDirection.rtl,
                  hintStyle: TextStyle(
                    color: AppColors.black1.withOpacity(0.35),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: canApply ? _applyCode : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: canApply || _checking ? 1 : 0.35,
                child: Container(
                  height: 40,
                  width: 76,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.black1,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const ReText(
                          'اعمال',
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeError(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(SolarIconsOutline.dangerCircle,
                size: 16, color: AppColors.errorColor),
            const SizedBox(width: 6),
            Expanded(
              child: ReText(
                message,
                color: AppColors.errorColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.right,
                maxLines: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The applied code as a green-tinted capsule with a remove action.
  Widget _buildCodeApplied(DiscountPreview discount) {
    return Container(
      height: 48,
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Row(
          children: [
            const Icon(SolarIconsBold.checkCircle,
                size: 20, color: AppColors.success),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  const ReText(
                    'کد',
                    color: AppColors.black1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: ReText(
                      discount.code,
                      isPersian: false,
                      color: AppColors.black1,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const ReText(
                    'اعمال شد',
                    color: AppColors.black1,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _busy ? null : _removeCode,
              child: Container(
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(SolarIconsOutline.trashBinMinimalistic,
                        size: 16, color: AppColors.black1.withOpacity(0.6)),
                    const SizedBox(width: 4),
                    ReText(
                      'حذف',
                      color: AppColors.black1.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _breakdownLine(
    String label,
    Widget amount, {
    bool strong = false,
  }) {
    return Row(
      children: [
        ReText(
          label,
          color: strong ? AppColors.black1 : AppColors.black1.withOpacity(0.55),
          fontSize: strong ? 14 : 13,
          fontWeight: strong ? FontWeight.w900 : FontWeight.w600,
        ),
        const Spacer(),
        amount,
        const SizedBox(width: 4),
        ReText(
          'تومان',
          color: AppColors.black1.withOpacity(0.5),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ],
    );
  }

  /// Plan price, the code's discount and the amount actually charged, all
  /// from the server's preview.
  Widget _buildBreakdown(DiscountPreview discount) {
    final percent = discount.percentOff;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _breakdownLine(
              'قیمت پلن',
              ReText(
                formatToman(discount.listPrice),
                color: AppColors.black1,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            _breakdownLine(
              percent == null
                  ? 'کد تخفیف'
                  : 'کد تخفیف ${convertToPersianNumbers('$percent')}٪',
              ReText(
                '${formatToman(discount.discountAmount)}-',
                color: AppColors.success,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Container(height: 1, color: AppColors.gray2),
            ),
            _breakdownLine(
              'مبلغ قابل پرداخت',
              _priceNumber(formatToman(discount.finalPrice), fontSize: 17),
              strong: true,
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
            text: widget.notice == null ? 'تأیید و پرداخت' : 'پرداخت دوباره',
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
