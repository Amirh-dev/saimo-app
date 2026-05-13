import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:simo_learn/utils/_utils.dart';

import '_widgets.dart';

class ReTextField extends StatefulWidget {
  final String? placeholder;
  final TextAlign? placeholderAlign;

  final TextAlign inputTextAlign;

  final String? byText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? icon;
  final Widget? suffixIcon;
  final bool? obscureText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool useSeprator;
  final bool isEnabled;
  final int? maxLines;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onObsecureToggle;
  final void Function()? onClear;
  final Color? color;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final Color? textColor;
  final int? maxLength;
  final bool showClearButton;
  final bool showFocusShadow;
  final double? height;

  const ReTextField({
    super.key,
    this.placeholder,
    this.placeholderAlign,
    this.inputTextAlign = TextAlign.right,
    this.byText,
    this.keyboardType,
    this.controller,
    this.focusNode,
    this.icon,
    this.suffixIcon,
    this.obscureText,
    this.autofocus = false,
    this.useSeprator = false,
    this.isEnabled = true,
    this.maxLines,
    this.validator,
    this.onChanged,
    this.onObsecureToggle,
    this.onClear,
    this.color,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.maxLength,
    this.showClearButton = false,
    this.showFocusShadow = true,
    this.height,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.onFieldSubmitted,
    this.textInputAction,
  });

  @override
  State<ReTextField> createState() => _ReTextFieldState();
}

class _ReTextFieldState extends State<ReTextField> {
  final intl.NumberFormat _formatter = intl.NumberFormat.decimalPattern();
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _attachFocusNode(widget.focusNode);
    if (widget.useSeprator && widget.controller?.text.isNotEmpty == true) {
      widget.controller?.text = _applyThousandSeparator(
        widget.controller!.text,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ReTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode(oldWidget.focusNode);
      _attachFocusNode(widget.focusNode);
    }
    if (widget.useSeprator && widget.controller?.text.isNotEmpty == true) {
      widget.controller?.text = _applyThousandSeparator(
        widget.controller!.text,
      );
    }
  }

  @override
  void dispose() {
    _detachFocusNode(widget.focusNode);
    super.dispose();
  }

  void _attachFocusNode(FocusNode? focusNode) {
    _focusNode = focusNode ?? FocusNode();
    _ownsFocusNode = focusNode == null;
    _hasFocus = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  void _detachFocusNode(FocusNode? focusNode) {
    _focusNode.removeListener(_handleFocusChange);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
  }

  void _handleFocusChange() {
    if (_hasFocus == _focusNode.hasFocus) return;
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  String _applyThousandSeparator(String text) {
    final normalized = convertToEnglishNumbers(text).replaceAll(',', '');
    final value = int.tryParse(normalized);
    if (value == null) return '';
    return convertToPersianNumbers(_formatter.format(value));
  }

  TextDirection get _inputDirection {
    return widget.inputTextAlign == TextAlign.right
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  bool get _isNumericKeyboard {
    return widget.keyboardType == TextInputType.number ||
        widget.keyboardType == TextInputType.phone;
  }

  @override
  Widget build(BuildContext context) {
    final isObscured = widget.obscureText ?? false;
    final isMultiline = (widget.maxLines ?? 1) > 1 && !isObscured;
    final resolvedHeight = widget.height ?? 55;
    final resolvedRadius = widget.borderRadius ?? 100;
    final resolvedFillColor = widget.backgroundColor ?? AppColors.gray1;
    final resolvedInactiveBorderColor = resolvedFillColor;
    final resolvedFontWeight = widget.fontWeight ?? FontWeight.w400;
    final resolvedFontVariations = AppFonts.fontVariations(resolvedFontWeight);
    final resolvedHintColor = AppColors.black1.withOpacity(0.45);
    final resolvedIconColor = AppColors.black1.withOpacity(0.45);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(resolvedRadius),
        boxShadow: widget.showFocusShadow && _hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.20),
                  spreadRadius: 2.5,
                  offset: Offset.zero,
                ),
              ]
            : null,
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: TextFormField(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onChanged: widget.onChanged,
          maxLines: isMultiline ? widget.maxLines : 1,
          enabled: widget.isEnabled,
          obscureText: isObscured,
          obscuringCharacter: "*",
          textInputAction: widget.textInputAction,
          controller: widget.controller,
          onFieldSubmitted: widget.onFieldSubmitted,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          inputFormatters: [
            if (_isNumericKeyboard)
              FilteringTextInputFormatter.allow(
                RegExp(r'[0-9۰-۹٠-٩]'),
              ),
            if (_isNumericKeyboard) const PersianDigitsInputFormatter(),
            LengthLimitingTextInputFormatter(widget.maxLength),
            if (widget.useSeprator) ThousandSeparatorInputFormatter(),
          ],
          cursorColor: widget.color ?? AppColors.primary,
          keyboardType: widget.keyboardType,
          
          buildCounter: widget.maxLength == null
              ? null
              : (
                  context, {
                  required int currentLength,
                  required bool isFocused,
                  int? maxLength,
                }) =>
                  null,
          decoration: InputDecoration(
            
            hintText: widget.placeholder,
            constraints: isMultiline
                ? null
                : BoxConstraints.tightFor(height: resolvedHeight),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 18,
              vertical: isMultiline ? 12 : 18,
            ),
            hintStyle: TextStyle(
              fontFamily: AppFonts.iranSansVar,
              fontSize: widget.fontSize ?? 14,
              height: 1.2,
              fontVariations: resolvedFontVariations,
              color: resolvedHintColor,
            ),
            labelStyle: TextStyle(
              fontFamily: AppFonts.iranSansVar,
              fontSize: widget.fontSize ?? 10,
              fontVariations: resolvedFontVariations,
              color: resolvedHintColor,
            ),
            errorStyle: const TextStyle(
              fontFamily: AppFonts.iranSansVar,
              color: AppColors.errorColor,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(resolvedRadius),
              borderSide: BorderSide(
                color: resolvedInactiveBorderColor,
                width: 0,
              ),
            ),
            filled: true,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(resolvedRadius),
              borderSide: BorderSide(
                color: resolvedInactiveBorderColor,
                width: 0,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(resolvedRadius),
              borderSide: BorderSide(
                color: resolvedInactiveBorderColor,
                width: 0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(resolvedRadius),
              borderSide: const BorderSide(
                color: AppColors.errorColor,
                width: 2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(resolvedRadius),
              borderSide: BorderSide(
                color: (widget.color ?? AppColors.primary).withOpacity(0.80),
                width: 1.5,
              ),
            ),
            suffixIcon: widget.suffixIcon ??
                (widget.byText == null
                    ? null
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ReText(
                            widget.byText!,
                            fontSize: 16,
                            color: resolvedHintColor,
                            fontWeight: FontWeight.bold,
                          ),
                          if (widget.showClearButton)
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close),
                              iconSize: 18,
                              onPressed: () {
                                widget.controller?.clear();
                                widget.onChanged?.call('');
                                widget.onClear?.call();
                                FocusScope.of(context).unfocus();
                              },
                            ),
                        ],
                      )),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, color: resolvedIconColor)
                : null,
            fillColor: resolvedFillColor,
          ),
          validator: widget.validator,
          style: TextStyle(
            fontSize: widget.fontSize ?? 16,
            height: 1.2,
            fontFamily: AppFonts.iranSansVar,
            fontVariations: resolvedFontVariations,
            color: widget.textColor ?? AppColors.black1,
          ),
          textAlign: widget.placeholderAlign ??
              (_isNumericKeyboard ? TextAlign.left : widget.inputTextAlign),
          textDirection: _inputDirection,
          textAlignVertical:
              isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
        ),
      ),
    ).sizedBox(height: resolvedHeight, width: double.infinity);
  }
}

class ThousandSeparatorInputFormatter extends TextInputFormatter {
  final intl.NumberFormat _formatter = intl.NumberFormat.decimalPattern();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final normalized = convertToEnglishNumbers(newValue.text);
    final rawNumberText = normalized.replaceAll(',', '');
    final parsed = int.tryParse(rawNumberText);
    if (parsed == null) return oldValue;

    final int selectionIndexFromEnd =
        normalized.length - newValue.selection.end;
    final String formattedText =
        convertToPersianNumbers(_formatter.format(parsed));
    final selectionOffset = (formattedText.length - selectionIndexFromEnd)
        .clamp(0, formattedText.length)
        .toInt();

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: selectionOffset,
      ),
    );
  }
}
