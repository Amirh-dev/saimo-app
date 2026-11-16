import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/feedback/feedback_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_form_widgets.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';
import 'package:simo_learn/utils/jalali_text.dart';
import 'package:solar_icons/solar_icons.dart';

/// «شکایت و پیشنهاد»: a student writes a suggestion, or a complaint that can
/// name one of their counselors; the senior counselor reads it in the panel.
/// Below the form the student sees what they sent and its status.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key, this.repository});

  /// For tests; defaults to one built from the app's GraphQLRepository.
  final FeedbackRepository? repository;

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  late final FeedbackRepository _repo =
      widget.repository ?? FeedbackRepository(context.read<GraphQLRepository>());
  final _body = TextEditingController();

  FeedbackKind _kind = FeedbackKind.suggestion;
  String? _counselorId;
  List<FeedbackCounselor> _counselors = const [];
  List<SentFeedback> _sent = const [];
  bool _sending = false;
  String? _error;
  int _errorTick = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    // Each list is optional: the form still works when one fails.
    try {
      final counselors = await _repo.myCounselors();
      if (mounted) setState(() => _counselors = counselors);
    } catch (_) {}
    try {
      final sent = await _repo.myFeedback();
      if (mounted) setState(() => _sent = sent);
    } catch (_) {}
  }

  Future<void> _send() async {
    final text = _body.text.trim();
    final length = text.characters.length;
    if (length < FeedbackRepository.minLength || length > FeedbackRepository.maxLength) {
      setState(() {
        _error = length < FeedbackRepository.minLength
            ? 'یه کم بیشتر بنویس.'
            : 'خیلی طولانیه، کوتاه‌ترش کن.';
        _errorTick++;
      });
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final sent = await _repo.submit(
        kind: _kind,
        body: text,
        counselorUserId: _kind == FeedbackKind.complaint ? _counselorId : null,
      );
      if (!mounted) return;
      setState(() {
        _sent = [sent, ..._sent];
        _body.clear();
        _counselorId = null;
      });
      FocusScope.of(context).unfocus();
      showReToast(context, 'فرستاده شد. ممنون!', ReToastType.success);
    } catch (_) {
      if (mounted) {
        showReToast(context, 'فرستادن ناموفق بود. دوباره امتحان کن.', ReToastType.error);
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final complaint = _kind == FeedbackKind.complaint;
    return Scaffold(
      backgroundColor: AppColors.gray1,
      body: Column(
        children: [
          _header(context),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _KindSwitch(
                          kind: _kind,
                          onChanged: (kind) => setState(() {
                            _kind = kind;
                            _error = null;
                          }),
                        ),
                        if (complaint && _counselors.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          const ReText(
                            'درباره‌ی',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Choice(
                                key: const ValueKey('feedback-about-general'),
                                label: 'کلی',
                                selected: _counselorId == null,
                                onTap: () => setState(() => _counselorId = null),
                              ),
                              for (final c in _counselors)
                                _Choice(
                                  key: ValueKey('feedback-about-${c.userId}'),
                                  label: c.name,
                                  selected: _counselorId == c.userId,
                                  onTap: () => setState(() => _counselorId = c.userId),
                                ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 18),
                        TaskTextField(
                          fieldKey: const ValueKey('feedback-body'),
                          controller: _body,
                          hint: complaint
                              ? 'چی شده؟ بنویس تا پیگیری کنیم.'
                              : 'چی رو بهتر کنیم؟',
                          maxLines: 8,
                          error: _error,
                          errorTick: _errorTick,
                          onChanged: (_) {
                            if (_error != null) setState(() => _error = null);
                          },
                        ),
                        const SizedBox(height: 10),
                        const ReText(
                          'مشاور ارشد سایمو می‌خونه و پیگیری می‌کنه.',
                          fontSize: 12,
                          color: AppColors.gray,
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.visible,
                          maxLines: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ReButton(
                    key: const ValueKey('feedback-send'),
                    text: 'بفرست',
                    background: AppColors.primary,
                    borderRadius: 40,
                    height: 55,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    isLoading: _sending,
                    onPressed: _sending ? null : _send,
                  ),
                  if (_sent.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    const ReText(
                      'فرستاده‌هات',
                      fontSize: 15,
                      fontWeight: 1000,
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 12),
                    for (final item in _sent) ...[
                      _SentTile(item: item),
                      const SizedBox(height: 10),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Spacer(),
            const ReText(
              'شکایت و پیشنهاد',
              color: AppColors.black1,
              fontSize: 16,
              fontWeight: 1000,
            ),
            IconButton(
              tooltip: 'بازگشت',
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                SolarIconsOutline.altArrowRight,
                size: 22,
                color: AppColors.black1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.whiteSec,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }
}

/// Capsule switch like «یک روز» | «هر هفته» in the task forms.
class _KindSwitch extends StatelessWidget {
  const _KindSwitch({required this.kind, required this.onChanged});

  final FeedbackKind kind;
  final ValueChanged<FeedbackKind> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(FeedbackKind value, String label, IconData icon) {
      final selected = kind == value;
      return Expanded(
        child: GestureDetector(
          key: ValueKey('feedback-kind-${value.name}'),
          onTap: () => onChanged(value),
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.whiteSec : Colors.transparent,
              borderRadius: BorderRadius.circular(22),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.black1.withValues(alpha: 0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: selected ? AppColors.black1 : AppColors.gray),
                const SizedBox(width: 6),
                ReText(
                  label,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.black1 : AppColors.gray,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          segment(FeedbackKind.suggestion, 'پیشنهاد', SolarIconsOutline.lightbulb),
          segment(FeedbackKind.complaint, 'شکایت', SolarIconsOutline.dangerTriangle),
        ],
      ),
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({super.key, required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.black1 : AppColors.gray1,
          borderRadius: BorderRadius.circular(40),
        ),
        child: ReText(
          label,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.whiteSec : AppColors.black1,
        ),
      ),
    );
  }
}

class _SentTile extends StatelessWidget {
  const _SentTile({required this.item});
  final SentFeedback item;

  @override
  Widget build(BuildContext context) {
    final (label, color, background) = switch (item.status) {
      FeedbackStatus.open => ('فرستاده شد', AppColors.gray, AppColors.gray1),
      FeedbackStatus.inReview => ('در حال بررسی', AppColors.secondary, const Color(0xFFEEF0FF)),
      FeedbackStatus.resolved => ('پیگیری شد', AppColors.done, const Color(0xFFE6F8EE)),
    };
    final date = Jalali.fromDateTime(item.createdAt.toLocal());
    final kind = item.kind == FeedbackKind.complaint ? 'شکایت' : 'پیشنهاد';
    final about = item.counselorName == null ? '' : '، درباره‌ی ${item.counselorName}';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ReText(
                '$kind$about',
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ReText(label, fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ReText(
            item.body,
            fontSize: 13,
            color: AppColors.black1,
            textAlign: TextAlign.right,
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          ReText(
            '${date.day} ${JalaliText.month(date)}',
            fontSize: 11.5,
            color: AppColors.gray,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
