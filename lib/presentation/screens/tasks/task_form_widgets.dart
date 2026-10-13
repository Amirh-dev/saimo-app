import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_text_field.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Building blocks shared by quick add and the full task forms, so the two
/// read as one design: the same header, headings, fields, duration choice,
/// error box and entrance. Everything here is pinned RTL, since the full
/// forms' screens are not.

/// A title with a gray subtitle and a round close button on the far side.
class TaskFormHeader extends StatelessWidget {
  const TaskFormHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onClose,
  });

  final String title;
  final String? subtitle;

  /// Defaults to closing the current route.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReText(
                  title,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.black1,
                  maxLines: 1,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    layoutBuilder: (current, previous) => Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [...previous, if (current != null) current],
                    ),
                    child: ReText(
                      subtitle!,
                      key: ValueKey(subtitle),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                      maxLines: 2,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          Semantics(
            button: true,
            label: 'بستن',
            child: GestureDetector(
              key: const ValueKey('task-form-close'),
              onTap: onClose ?? () => Navigator.of(context).maybePop(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white,
                  border: Border.all(color: AppColors.gray2),
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.black1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small gray heading above a group of options, with an optional note on
/// the far side.
class TaskSectionLabel extends StatelessWidget {
  const TaskSectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 10),
        child: Row(
          children: [
            ReText(
              text,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.gray,
            ),
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

/// The forms' text field: a gray pill that wears the app's focus border and
/// glow, and turns red with a short shake when [error] appears (again, each
/// time [errorTick] changes). A [maxLength] shows a counter on the far side.
class TaskTextField extends StatefulWidget {
  const TaskTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.fieldKey,
    this.focusNode,
    this.autofocus = false,
    this.maxLength,
    this.maxLines = 1,
    this.error,
    this.errorTick = 0,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hint;

  /// Key of the inner [TextField], for tests.
  final Key? fieldKey;
  final FocusNode? focusNode;
  final bool autofocus;
  final int? maxLength;
  final int maxLines;
  final String? error;
  final int errorTick;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<TaskTextField> createState() => _TaskTextFieldState();
}

class _TaskTextFieldState extends State<TaskTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focus = widget.focusNode ?? FocusNode();
  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(TaskTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focus.removeListener(_onFocus);
      if (oldWidget.focusNode == null) _focus.dispose();
      _focus = widget.focusNode ?? FocusNode();
      _focus.addListener(_onFocus);
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onText);
      widget.controller.addListener(_onText);
    }
    final errorShown = widget.error != null &&
        (oldWidget.error == null || oldWidget.errorTick != widget.errorTick);
    if (errorShown && !reduceMotion(context)) {
      HapticFeedback.lightImpact();
      _shake.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    if (widget.focusNode == null) _focus.dispose();
    widget.controller.removeListener(_onText);
    _shake.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _onText() {
    if (widget.maxLength != null) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final multiline = widget.maxLines > 1;
    final hasError = widget.error != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? AppColors.errorColor
        : focused
            ? AppColors.primary
            : Colors.transparent;
    final count = widget.controller.text.characters.length;

    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      constraints: BoxConstraints(minHeight: multiline ? 104 : 54),
      padding: EdgeInsetsDirectional.fromSTEB(
        18,
        multiline ? 14 : 0,
        widget.maxLength == null ? 18 : 10,
        multiline ? 14 : 0,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(multiline ? 28 : 100),
        border: Border.all(
          color: borderColor,
          width: kFocusedFieldBorderWidth,
        ),
        boxShadow: focused && !hasError ? kFocusedFieldShadow : null,
      ),
      alignment: multiline ? Alignment.topCenter : Alignment.center,
      child: Row(
        crossAxisAlignment:
            multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Expanded(
            child: TextField(
              key: widget.fieldKey,
              controller: widget.controller,
              focusNode: _focus,
              autofocus: widget.autofocus,
              maxLength: widget.maxLength,
              maxLines: widget.maxLines,
              minLines: multiline ? 3 : 1,
              textInputAction: widget.textInputAction,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              onTapOutside: (_) => _focus.unfocus(),
              textAlignVertical: TextAlignVertical.center,
              inputFormatters: const [PersianDigitsInputFormatter()],
              style: TextStyle(
                fontFamily: AppFonts.iranSansVar,
                fontVariations: AppFonts.fontVariations(FontWeight.w700),
                fontSize: 14.5,
                height: 1.5,
                color: AppColors.black1,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                counterText: '',
                contentPadding: EdgeInsets.zero,
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontFamily: AppFonts.iranSansVar,
                  fontVariations: AppFonts.fontVariations(FontWeight.w500),
                  fontSize: 13.5,
                  color: AppColors.gray,
                ),
              ),
            ),
          ),
          if (widget.maxLength != null) ...[
            const SizedBox(width: 8),
            Padding(
              padding: EdgeInsets.only(top: multiline ? 2 : 0),
              child: _Counter(count: count, max: widget.maxLength!),
            ),
          ],
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _shake,
            builder: (context, child) {
              final t = _shake.value;
              // A few quick swings that die out.
              final dx = math.sin(t * math.pi * 6) * 7 * (1 - t);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: field,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: hasError
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(
                      start: 18,
                      top: 6,
                    ),
                    child: ReText(
                      widget.error!,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.errorColor,
                      textAlign: TextAlign.start,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.count, required this.max});

  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final nearLimit = count >= max * 0.9;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gray2,
        borderRadius: BorderRadius.circular(100),
      ),
      child: ReText(
        '${convertToPersianNumbers(math.min(count, max).toString())}/'
        '${convertToPersianNumbers(max.toString())}',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: nearLimit ? AppColors.black1 : AppColors.gray,
        textDirection: TextDirection.ltr,
      ),
    );
  }
}

/// The durations a timed task can take, one tap each. Keys are
/// `'$keyPrefix-minutes-$minutes'`.
class TaskDurationPicker extends StatelessWidget {
  const TaskDurationPicker({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.keyPrefix,
  });

  final List<int> options;
  final int selected;
  final ValueChanged<int> onChanged;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          for (var index = 0; index < options.length; index++) ...[
            if (index > 0) const SizedBox(width: 8),
            Expanded(
              child: _MinutesOption(
                key: ValueKey('$keyPrefix-minutes-${options[index]}'),
                minutes: options[index],
                selected: options[index] == selected,
                onTap: () => onChanged(options[index]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MinutesOption extends StatelessWidget {
  const _MinutesOption({
    super.key,
    required this.minutes,
    required this.selected,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '${convertToPersianNumbers('$minutes')} دقیقه',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (selected) return;
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedScale(
          scale: selected ? 1 : 0.96,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.black1 : AppColors.white,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected ? AppColors.black1 : AppColors.gray2,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ReText(
                  convertToPersianNumbers('$minutes'),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: selected ? AppColors.white : AppColors.black1,
                ),
                ReText(
                  'دقیقه',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? AppColors.white.withValues(alpha: 0.7)
                      : AppColors.gray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A failure the user should read before trying again: slides open above
/// the actions, and closes once [message] is null.
class TaskFormError extends StatelessWidget {
  const TaskFormError({super.key, required this.message, this.messageKey});

  final String? message;
  final Key? messageKey;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, -0.15),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: message == null
              ? const SizedBox(width: double.infinity)
              : Container(
                  key: ValueKey(message),
                  margin: const EdgeInsets.only(top: 14),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 18,
                        color: AppColors.errorColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ReText(
                          message!,
                          key: messageKey,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorColor,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

/// Fades a form section up into place when the form opens, a beat after
/// the one before it ([index]); once only.
class TaskFormEntrance extends StatefulWidget {
  const TaskFormEntrance({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  State<TaskFormEntrance> createState() => _TaskFormEntranceState();
}

class _TaskFormEntranceState extends State<TaskFormEntrance>
    with SingleTickerProviderStateMixin {
  static const int _runMs = 360;
  static const int _staggerMs = 40;

  // The wait is part of the animation (no timer), so it ends with it.
  late final int _delayMs = _staggerMs * widget.index;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _delayMs + _runMs),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Interval(
      _delayMs / (_delayMs + _runMs),
      1,
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// The forms' two actions side by side: a quiet one and the main one.
class TaskFormActions extends StatelessWidget {
  const TaskFormActions({
    super.key,
    required this.secondary,
    required this.primary,
  });

  final Widget secondary;
  final Widget primary;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Row(
        children: [
          Expanded(child: secondary),
          const SizedBox(width: 10),
          Expanded(child: primary),
        ],
      ),
    );
  }
}
