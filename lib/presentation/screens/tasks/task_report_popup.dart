import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/_utils.dart';

/// Asks how a task went: a 1–5 self-rating and, optionally, a test's
/// question counts. [initial] prefills an earlier report. [onSubmit] saves it;
/// while it runs the popup waits, and if it throws the popup stays open with
/// the error so nothing typed is lost. [finishesTask] is true when saving
/// will also mark the task done. Resolves to the saved report, or null when
/// skipped.
Future<TaskReport?> showTaskReportPopup(
  BuildContext context, {
  required Future<void> Function(TaskReport report) onSubmit,
  TaskReport? initial,
  bool finishesTask = false,
}) {
  return showGeneralDialog<TaskReport>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'بستن',
    barrierColor: AppColors.black1.withValues(alpha: 0.28),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondary) => _TaskReportPopup(
      initial: initial,
      finishesTask: finishesTask,
      onSubmit: onSubmit,
    ),
    transitionBuilder: (context, animation, secondary, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.settle,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _TaskReportPopup extends StatefulWidget {
  const _TaskReportPopup({
    required this.initial,
    required this.finishesTask,
    required this.onSubmit,
  });

  final TaskReport? initial;
  final bool finishesTask;
  final Future<void> Function(TaskReport report) onSubmit;

  @override
  State<_TaskReportPopup> createState() => _TaskReportPopupState();
}

class _TaskReportPopupState extends State<_TaskReportPopup> {
  late int? _rating = widget.initial?.rating;
  late bool _tookTest = widget.initial?.tookTest ?? false;
  late final TextEditingController _total = TextEditingController(
    text: _digits(widget.initial?.totalQuestions),
  );
  late final TextEditingController _correct = TextEditingController(
    text: _digits(widget.initial?.correctAnswers),
  );
  late final TextEditingController _note =
      TextEditingController(text: widget.initial?.note ?? '');
  late bool _showNote = widget.initial?.note != null;
  bool _saving = false;
  String? _error;

  static String _digits(int? value) =>
      value == null ? '' : convertToPersianNumbers(value.toString());

  static int? _parse(TextEditingController controller) =>
      int.tryParse(convertToEnglishNumbers(controller.text.trim()));

  /// Correct answers as a share of the questions, once both make sense.
  double? get _accuracy {
    final total = _parse(_total);
    final correct = _parse(_correct);
    if (total == null || correct == null || total <= 0 || correct > total) {
      return null;
    }
    return correct / total;
  }

  @override
  void dispose() {
    _total.dispose();
    _correct.dispose();
    _note.dispose();
    super.dispose();
  }

  /// The report as entered, or why it cannot be saved yet.
  (TaskReport?, String?) _validate() {
    final rating = _rating;
    if (rating == null) return (null, 'به عملکردت در این تسک امتیاز بده.');
    final note = _note.text.trim().isEmpty ? null : _note.text.trim();
    if (!_tookTest) return (TaskReport(rating: rating, note: note), null);

    final total = _parse(_total);
    final correct = _parse(_correct);
    if (total == null || total <= 0) {
      return (null, 'تعداد کل سوالات را وارد کن.');
    }
    if (correct == null) return (null, 'تعداد پاسخ‌های صحیح را وارد کن.');
    if (correct > total) {
      return (null, 'پاسخ صحیح نمی‌تواند از تعداد کل سوالات بیشتر باشد.');
    }
    return (
      TaskReport(
        rating: rating,
        totalQuestions: total,
        correctAnswers: correct,
        note: note,
      ),
      null,
    );
  }

  Future<void> _submit() async {
    if (_saving) return;
    final (report, error) = _validate();
    if (report == null) {
      setState(() => _error = error);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.onSubmit(report);
      if (mounted) Navigator.of(context).pop(report);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = taskFailureMessage(
          error,
          fallback: 'ثبت گزارش ناموفق بود. دوباره تلاش کنید.',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboard),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Material(
                key: const ValueKey('task-report-popup'),
                color: AppColors.whiteSec,
                borderRadius: BorderRadius.circular(28),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SuccessHeader(finishesTask: widget.finishesTask),
                      const SizedBox(height: 24),
                      _RatingCard(
                        rating: _rating,
                        onChanged: _saving
                            ? null
                            : (value) => setState(() {
                                  _rating = value;
                                  _error = null;
                                }),
                      ).hMargin(8),
                      const SizedBox(height: 20),
                      _TestCheckbox(
                        checked: _tookTest,
                        onTap: _saving
                            ? null
                            : () => setState(() {
                                  _tookTest = !_tookTest;
                                  _error = null;
                                }),
                      ).hMargin(8),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        alignment: Alignment.topCenter,
                        child: _tookTest
                            ? _TestFields(
                                total: _total,
                                correct: _correct,
                                enabled: !_saving,
                                accuracy: _accuracy,
                                // Rebuilds the live percentage too.
                                onChanged: () => setState(() => _error = null),
                              ).tMargin(12).hMargin(8)
                            : const SizedBox(width: double.infinity),
                      ),
                      _NoteField(
                        controller: _note,
                        expanded: _showNote,
                        enabled: !_saving,
                        onExpand: () => setState(() => _showNote = true),
                      ).tMargin(14).hMargin(8),
                      if (_error != null)
                        ReText(
                          _error!,
                          key: const ValueKey('task-report-error'),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.errorColor,
                          textAlign: TextAlign.center,
                        ).tMargin(14).hMargin(16),
                      const SizedBox(height: 24),
                      _PopupButton(
                        key: const ValueKey('task-report-submit'),
                        text: 'ثبت گزارش',
                        background: AppColors.secondary,
                        textColor: AppColors.white,
                        loading: _saving,
                        onTap: _submit,
                      ).hMargin(8),
                      const SizedBox(height: 10),
                      _PopupButton(
                        key: const ValueKey('task-report-skip'),
                        text: 'رد کردن',
                        background: AppColors.whiteSec,
                        textColor: AppColors.black1,
                        borderColor: AppColors.gray2,
                        onTap:
                            _saving ? null : () => Navigator.of(context).pop(),
                      ).hMargin(8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The green banner with a check badge sitting on its top edge.
class _SuccessHeader extends StatelessWidget {
  const _SuccessHeader({required this.finishesTask});

  final bool finishesTask;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 40, 16, 22),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(22),
          ),
          child: ReText(
            finishesTask
                ? 'با ثبت گزارش، تسک به پایان می‌رسد.'
                : 'تسک با موفقیت به پایان رسید.',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: AppColors.success,
            textAlign: TextAlign.center,
          ),
        ),
        Positioned(
          top: -22,
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.whiteSec, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.check_rounded,
                size: 22, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({required this.rating, required this.onChanged});

  final int? rating;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 22, 14, 16),
          decoration: BoxDecoration(
            color: AppColors.simoCoin.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              const ReText(
                'به عملکرد خودت در این تسک چه امتیازی میدی؟',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.black1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              // Ascending left to right, as in the design.
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  for (var value = 1; value <= 5; value++) ...[
                    if (value > 1) const SizedBox(width: 8),
                    Expanded(
                      child: _RatingChip(
                        value: value,
                        selected: rating == value,
                        onTap:
                            onChanged == null ? null : () => onChanged!(value),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: -12,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.black1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.star_rounded,
                size: 15, color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final int value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: 'امتیاز ${convertToPersianNumbers('$value')}',
      excludeSemantics: true,
      child: GestureDetector(
        key: ValueKey('task-report-rating-$value'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap!();
              },
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxWidth: 52, maxHeight: 52),
            decoration: BoxDecoration(
              color: selected ? AppColors.simoCoin : AppColors.whiteSec,
              shape: BoxShape.circle,
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.simoCoin.withValues(alpha: 0.45),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            child: ReText(
              convertToPersianNumbers('$value'),
              fontSize: selected ? 20 : 16,
              fontWeight: FontWeight.w900,
              color: AppColors.black1,
            ),
          ),
        ),
      ),
    );
  }
}

class _TestCheckbox extends StatelessWidget {
  const _TestCheckbox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: checked,
      label: 'تست زدم',
      excludeSemantics: true,
      child: GestureDetector(
        key: const ValueKey('task-report-took-test'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.whiteSec,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: checked ? AppColors.primary : AppColors.gray2,
                  width: 1.4,
                ),
              ),
              child: checked
                  ? const Icon(Icons.check_rounded,
                      size: 18, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(width: 10),
            const ReText(
              'تست زدم',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.black1,
            ),
          ],
        ).vPadding(6),
      ),
    );
  }
}

class _TestFields extends StatelessWidget {
  const _TestFields({
    required this.total,
    required this.correct,
    required this.enabled,
    required this.accuracy,
    required this.onChanged,
  });

  final TextEditingController total;
  final TextEditingController correct;
  final bool enabled;
  final double? accuracy;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gray2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(
            key: const ValueKey('task-report-total'),
            label: 'تعداد کل سوالات',
            placeholder: 'تعداد کل سوالات',
            controller: total,
            action: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          _field(
            key: const ValueKey('task-report-correct'),
            label: 'پاسخ صحیح',
            placeholder: 'مثلا ۹۰',
            controller: correct,
            action: TextInputAction.done,
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            child: accuracy == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _AccuracyBar(accuracy: accuracy!),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _field({
    required Key key,
    required String label,
    required String placeholder,
    required TextEditingController controller,
    required TextInputAction action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.black1,
        ).rMargin(6).bMargin(8),
        ReTextField(
          key: key,
          controller: controller,
          placeholder: placeholder,
          isEnabled: enabled,
          keyboardType: TextInputType.number,
          textInputAction: action,
          maxLength: 4,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩]')),
            const PersianDigitsInputFormatter(),
          ],
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

/// An optional note: a small link until tapped, then a multiline field.
class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.controller,
    required this.expanded,
    required this.enabled,
    required this.onExpand,
  });

  final TextEditingController controller;
  final bool expanded;
  final bool enabled;
  final VoidCallback onExpand;

  /// Matches the server's limit on a report note.
  static const int maxLength = 500;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: expanded
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ReText(
                  'یادداشت',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.black1,
                ).rMargin(6).bMargin(8),
                ReTextField(
                  key: const ValueKey('task-report-note'),
                  controller: controller,
                  placeholder: 'چه چیزی سخت بود؟ دفعه بعد چه کار می‌کنی؟',
                  isEnabled: enabled,
                  autofocus: controller.text.isEmpty,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  maxLines: 3,
                  height: 108,
                  maxLength: maxLength,
                  borderRadius: 24,
                ),
              ],
            )
          : Align(
              alignment: AlignmentDirectional.centerStart,
              child: GestureDetector(
                key: const ValueKey('task-report-add-note'),
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? onExpand : null,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, size: 18, color: AppColors.black1),
                    SizedBox(width: 6),
                    ReText(
                      'افزودن یادداشت',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.black1,
                    ),
                    SizedBox(width: 6),
                    ReText(
                      '(اختیاری)',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray,
                    ),
                  ],
                ).vPadding(6),
              ),
            ),
    );
  }
}

/// "درصد پاسخ صحیح ۸۴٪" over a thin green bar.
class _AccuracyBar extends StatelessWidget {
  const _AccuracyBar({required this.accuracy});

  final double accuracy;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('task-report-accuracy'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const ReText(
              'درصد پاسخ صحیح',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.gray,
            ),
            const Spacer(),
            ReText(
              formatPercent(accuracy),
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
            ),
          ],
        ).hMargin(6),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: accuracy,
            minHeight: 6,
            backgroundColor: AppColors.gray2,
            valueColor: const AlwaysStoppedAnimation(AppColors.success),
          ),
        ),
      ],
    );
  }
}

/// [share] (0–1) as a whole Persian percentage: ۸۴٪.
String formatPercent(double share) =>
    '${convertToPersianNumbers((share * 100).round().toString())}٪';

class _PopupButton extends StatelessWidget {
  const _PopupButton({
    super.key,
    required this.text,
    required this.background,
    required this.textColor,
    required this.onTap,
    this.borderColor,
    this.loading = false,
  });

  final String text;
  final Color background;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: text,
      excludeSemantics: true,
      child: PressScale(
        onTap: loading ? null : onTap,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(100),
            border:
                borderColor == null ? null : Border.all(color: borderColor!),
          ),
          child: loading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: textColor,
                  ),
                )
              : ReText(
                  text,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
        ),
      ),
    );
  }
}
