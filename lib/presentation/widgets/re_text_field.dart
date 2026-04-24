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

  @override
  void initState() {
    super.initState();
    if (widget.useSeprator && widget.controller?.text.isNotEmpty == true) {
      widget.controller?.text = _applyThousandSeparator(
        widget.controller!.text,
      );
    }
  }

  @override
  void didUpdateWidget(covariant ReTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.useSeprator && widget.controller?.text.isNotEmpty == true) {
      widget.controller?.text = _applyThousandSeparator(
        widget.controller!.text,
      );
    }
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
    final resolvedRadius = widget.borderRadius ?? 16;
    final resolvedBorderColor = widget.borderColor ?? AppColors.dark2Color;
    final resolvedFontWeight = widget.fontWeight ?? FontWeight.w400;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: TextFormField(
        focusNode: widget.focusNode,
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
        cursorColor: widget.color,
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
          constraints:
              isMultiline
                  ? null
                  : BoxConstraints.tightFor(height: resolvedHeight),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isMultiline ? 12 : 18,
          ),
          hintStyle: TextStyle(
            fontFamily: AppFonts.iranSans,
            fontSize: widget.fontSize ?? 14,
            height: 1.2,
            fontWeight: resolvedFontWeight,
            color: Colors.grey.shade500,
          ),
          labelStyle: TextStyle(
            fontFamily: AppFonts.iranSans,
            fontSize: widget.fontSize ?? 10,
            fontWeight: resolvedFontWeight,
            color: Colors.grey.shade500,
          ),
          errorStyle: const TextStyle(
            fontFamily: AppFonts.iranSans,
            color: AppColors.errorColor,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: resolvedBorderColor),
          ),
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: resolvedBorderColor),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(color: resolvedBorderColor),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: const BorderSide(color: AppColors.errorColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(resolvedRadius),
            borderSide: BorderSide(
              color: widget.color ?? AppColors.primary,
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
                          color: Colors.grey.shade500,
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
              ? Icon(widget.icon, color: Colors.grey.shade500)
              : null,
          fillColor: widget.backgroundColor ?? Colors.white,
        ),
        validator: widget.validator,
        style: TextStyle(
          fontSize: widget.fontSize ?? 16,
          height: 1.2,
          fontFamily: AppFonts.iranSans,
          fontWeight: resolvedFontWeight,
          color: widget.textColor ?? Colors.black,
        ),
        textAlign: widget.placeholderAlign ??
            (_isNumericKeyboard ? TextAlign.left : widget.inputTextAlign),
        textDirection: _inputDirection,
        textAlignVertical:
            isMultiline ? TextAlignVertical.top : TextAlignVertical.center,
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
