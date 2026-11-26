import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/colors.dart';

/// Today's timed tasks from the desk: the one on the timer now, the rest with
/// a play button to switch to, a quick add, and the finished ones at the end.
/// Returns the task to switch to.
/// [onPlan] leaves the desk for the tasks tab, where tasks are added and planned.
Future<Map<String, dynamic>?> showDeskTasksSheet(BuildContext context,
    {required TasksApi api, required String? currentId, required VoidCallback onPlan}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TasksSheet(api: api, currentId: currentId, onPlan: onPlan),
  );
}

int _duration(Map<String, dynamic> t) => (t['durationSeconds'] as int?) ?? 0;
int _elapsed(Map<String, dynamic> t) => ((t['elapsedSeconds'] as int?) ?? 0).clamp(0, _duration(t));
bool _done(Map<String, dynamic> t) => t['status'] == 'done';

String _subject(Map<String, dynamic> t) {
  final s = t['subject'];
  if (s is String && s.trim().isNotEmpty) return s.trim();
  final tags = t['tags'];
  if (tags is List && tags.isNotEmpty) return '${tags.first}';
  return '';
}

String _hm(int seconds) => '${seconds ~/ 3600}:${((seconds % 3600) ~/ 60).toString().padLeft(2, '0')}';

/// Soft colours for subject chips, picked by the subject's name.
const _chipColors = [
  (Color(0xFFE6EEFF), Color(0xFF3D6FB6)),
  (Color(0xFFE6F4EA), Color(0xFF2F8F57)),
  (Color(0xFFFFF0E0), Color(0xFFC27A2C)),
  (Color(0xFFF2E9FF), Color(0xFF7E58B5)),
  (Color(0xFFFFE9EE), Color(0xFFB8354A)),
];

class _TasksSheet extends StatefulWidget {
  const _TasksSheet({required this.api, required this.currentId, required this.onPlan});
  final TasksApi api;
  final String? currentId;
  final VoidCallback onPlan;

  @override
  State<_TasksSheet> createState() => _TasksSheetState();
}

class _TasksSheetState extends State<_TasksSheet> {
  List<Map<String, dynamic>>? _tasks;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final today = Jalali.now();
      final all = await widget.api.fetchSchedule(start: today, end: today.addDays(1));
      if (!mounted) return;
      setState(() {
        _tasks = [for (final t in all) if (t['type'] == 'TIMED') t];
        _failed = false;
      });
    } catch (_) {
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _tasks;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .86),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + MediaQuery.viewInsetsOf(context).bottom + MediaQuery.paddingOf(context).bottom),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                  width: 44, height: 5, decoration: BoxDecoration(color: AppColors.gray2, borderRadius: BorderRadius.circular(100))),
            ),
            const SizedBox(height: 14),
            const ReText('تسک‌های امروز', fontSize: 18, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right),
            if (tasks == null)
              SizedBox(
                height: 180,
                child: Center(
                  child: _failed
                      ? TextButton(
                          onPressed: () {
                            setState(() => _failed = false);
                            _load();
                          },
                          child: const ReText('باز نشد؛ دوباره', fontSize: 13, fontWeight: 900, color: AppColors.black1))
                      : const CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.gray),
                ),
              )
            else
              Flexible(child: _list(tasks)),
          ],
        ),
      ),
    );
  }

  Widget _list(List<Map<String, dynamic>> tasks) {
    final open = [for (final t in tasks) if (!_done(t)) t];
    final done = [for (final t in tasks) if (_done(t)) t];
    final plan = tasks.fold<int>(0, (a, t) => a + _duration(t));
    final did = tasks.fold<int>(0, (a, t) => a + (_done(t) ? _duration(t) : _elapsed(t)));
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _Stat(big: '${done.length} از ${tasks.length}', small: 'انجام شده')),
          const SizedBox(width: 8),
          Expanded(
            child: _Stat(
              key: const ValueKey('desk-plan-percent'),
              big: '${plan == 0 ? 0 : (did * 100 / plan).round()}٪',
              small: 'از برنامه‌ی امروز (${_hm(did)} از ${_hm(plan)})',
              progress: plan == 0 ? 0 : did / plan,
            ),
          ),
        ]),
        for (final t in open) _row(t),
        if (open.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: ReText('برای امروز تسک زمان‌دار دیگه‌ای نداری.',
                fontSize: 13, fontWeight: 700, color: AppColors.gray, textAlign: TextAlign.center, maxLines: 2),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            key: const ValueKey('desk-go-tasks'),
            onPressed: () {
              Navigator.of(context).pop();
              widget.onPlan();
            },
            style: OutlinedButton.styleFrom(
              shape: const StadiumBorder(),
              side: const BorderSide(color: AppColors.gray2, width: 1.5),
            ),
            icon: const Icon(Icons.edit_calendar_rounded, size: 18, color: AppColors.black1),
            label: const ReText('برو به تسک‌ها و برنامه‌ریزی', fontSize: 13.5, fontWeight: 900, color: AppColors.black1),
          ),
        ),
        if (done.isNotEmpty) ...[
          const SizedBox(height: 16),
          const ReText('تموم‌شده‌ها', fontSize: 12, fontWeight: 900, color: AppColors.gray, textAlign: TextAlign.right),
          for (final t in done) _row(t),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _row(Map<String, dynamic> t) {
    final current = t['id'] == widget.currentId, done = _done(t);
    final subject = _subject(t);
    final total = _duration(t), elapsed = _elapsed(t);
    final (bg, fg) = _chipColors[subject.hashCode.abs() % _chipColors.length];
    final minutes = total ~/ 60, did = elapsed ~/ 60;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Opacity(
        opacity: done ? .55 : 1,
        child: Material(
          color: current ? const Color(0xFFFFF3EF) : AppColors.gray1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: current ? const BorderSide(color: AppColors.primary, width: 2) : BorderSide.none,
          ),
          child: InkWell(
            key: ValueKey('desk-task-${t['id']}'),
            borderRadius: BorderRadius.circular(20),
            onTap: done || current ? null : () => Navigator.of(context).pop(t),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: done
                        ? Container(
                            decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 22))
                        : CircularProgressIndicator(
                            value: total == 0 ? 0 : elapsed / total,
                            strokeWidth: 4,
                            backgroundColor: const Color(0xFFE4E4EA),
                            color: AppColors.primary,
                            strokeCap: StrokeCap.round,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ReText('${t['title'] ?? ''}',
                            fontSize: 13.5,
                            fontWeight: 900,
                            color: AppColors.black1,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            decoration: done ? TextDecoration.lineThrough : null),
                        const SizedBox(height: 4),
                        Row(children: [
                          if (subject.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(100)),
                              child: ReText(subject, fontSize: 10.5, fontWeight: 900, color: fg),
                            ),
                            const SizedBox(width: 6),
                          ],
                          ReText(
                            done
                                ? '$minutes دقیقه، تموم شد'
                                : did > 0
                                    ? '$did از $minutes دقیقه'
                                    : '$minutes دقیقه',
                            fontSize: 11,
                            fontWeight: 700,
                            color: AppColors.gray,
                          ),
                        ]),
                      ],
                    ),
                  ),
                  if (current)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(100)),
                      child: const ReText('الان', fontSize: 10.5, fontWeight: 1000, color: Colors.white),
                    )
                  else if (!done)
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.big, required this.small, this.progress});
  final String big;
  final String small;

  /// Shows a thin bar under the text when set.
  final double? progress;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
        decoration: BoxDecoration(color: AppColors.gray1, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ReText(big, fontSize: 16, fontWeight: 1000, color: AppColors.black1, textAlign: TextAlign.right),
            ReText(small, fontSize: 11, fontWeight: 700, color: AppColors.gray, textAlign: TextAlign.right, maxLines: 1),
            if (progress != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                    value: progress!.clamp(0.0, 1.0), minHeight: 5, backgroundColor: Colors.white, color: AppColors.primary),
              ),
            ],
          ],
        ),
      );
}
