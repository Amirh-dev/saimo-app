import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';

/// Run when a reminder is turned on. Returns whether the alarm can ring:
/// when something is still off, a checklist opens each settings page and
/// checks again on return; closing it with anything missing returns false,
/// and the caller turns the reminder back off.
Future<bool> ensureAlarmAccess(BuildContext context) async {
  final reminders = TaskReminderService.instance;
  final allowed = await reminders.requestPermission();
  final missing = await reminders.missingAccess();
  if (missing.isEmpty) {
    // Android lists notifications in the checklist; iOS has only the prompt.
    if (!allowed && !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return false;
    }
    await reminders.requestFullScreen();
    return true;
  }
  if (!context.mounted) return false;
  final done = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AlarmAccessSheet(
      needs: missing,
      check: reminders.missingAccess,
      open: reminders.openAccess,
      confirm: reminders.confirmAccess,
    ),
  );
  if (done != true) return false;
  await reminders.requestFullScreen();
  return true;
}

/// The message shown when the checklist was left unfinished.
const kAlarmNotSetMessage = 'یادآوری تنظیم نشد. بدون این اجازه‌ها زنگ نمی‌زنه.';

/// The checklist of settings an alarm needs. Each row opens its page; when
/// the user comes back every row is checked again.
class AlarmAccessSheet extends StatefulWidget {
  const AlarmAccessSheet({
    super.key,
    required this.needs,
    required this.check,
    required this.open,
    required this.confirm,
  });

  /// What was missing when the sheet opened; these rows stay listed.
  final List<AlarmNeed> needs;
  final Future<List<AlarmNeed>> Function() check;
  final Future<void> Function(AlarmNeed need) open;
  final Future<void> Function(AlarmNeed need) confirm;

  @override
  State<AlarmAccessSheet> createState() => _AlarmAccessSheetState();
}

class _AlarmAccessSheetState extends State<AlarmAccessSheet>
    with WidgetsBindingObserver {
  late Set<AlarmNeed> _missing = widget.needs.toSet();
  final Set<AlarmNeed> _visited = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _recheck();
  }

  Future<void> _recheck() async {
    final missing = await widget.check();
    if (mounted) setState(() => _missing = missing.toSet());
  }

  Future<void> _open(AlarmNeed need) async {
    // Xiaomi's switches cannot always be read back: after a visit the row
    // asks the user instead, so a wrong reading never blocks the reminder.
    if (need.confirmable && _visited.contains(need)) {
      await widget.confirm(need);
      await _recheck();
      return;
    }
    _visited.add(need);
    await widget.open(need);
    // Pages that are only a prompt (notifications) return without a resume.
    await _recheck();
  }

  @override
  Widget build(BuildContext context) {
    final ready = _missing.isEmpty;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
        decoration: BoxDecoration(
          color: AppColors.whiteSec,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(IconsaxPlusBold.notification_bing,
                    color: AppColors.primary, size: 28),
              ),
              const SizedBox(height: 14),
              const ReText('برای اینکه یادآوری زنگ بزنه',
                  fontSize: 17,
                  fontWeight: 900,
                  color: AppColors.black1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 6),
              const SizedBox(
                width: double.infinity,
                child: ReText(
                  'این‌ها رو روشن کن. هر کدوم رو بزنی صفحه‌ش باز می‌شه، روشنش کن و برگرد.',
                  fontSize: 13,
                  color: AppColors.gray,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                  lineHeight: 1.7,
                ),
              ),
              const SizedBox(height: 16),
              for (final need in widget.needs) ...[
                _NeedRow(
                  need: need,
                  done: !_missing.contains(need),
                  askConfirm: need.confirmable && _visited.contains(need),
                  onTap: () => _open(need),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        key: const ValueKey('alarm-access-done'),
                        onPressed:
                            ready ? () => Navigator.of(context).pop(true) : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: AppColors.gray2,
                          shape: const StadiumBorder(),
                        ),
                        child: ReText('تموم شد',
                            fontSize: 15,
                            fontWeight: 800,
                            color: ready ? AppColors.white : AppColors.gray),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: TextButton(
                      key: const ValueKey('alarm-access-later'),
                      onPressed: () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.gray1,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                      ),
                      child: const ReText('بعداً',
                          fontSize: 14,
                          fontWeight: 700,
                          color: AppColors.black1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedRow extends StatelessWidget {
  const _NeedRow({
    required this.need,
    required this.done,
    required this.askConfirm,
    required this.onTap,
  });

  final AlarmNeed need;
  final bool done;
  final bool askConfirm;
  final VoidCallback onTap;

  (IconData, String, String) get _copy => switch (need) {
        AlarmNeed.notifications => (
            IconsaxPlusBold.notification,
            'اعلان‌ها',
            'اجازه‌ی اعلان به سایمو',
          ),
        AlarmNeed.ringOnTime => (
            IconsaxPlusBold.clock,
            'آلارم‌ها و یادآوری‌ها',
            'که دقیقاً سر وقت زنگ بزنه',
          ),
        AlarmNeed.lockScreen => (
            IconsaxPlusBold.lock,
            'نمایش روی صفحه قفل',
            'تو «سایر مجوزها» روشنش کن',
          ),
        AlarmNeed.backgroundPopup => (
            IconsaxPlusBold.mobile,
            'نمایش پنجره در پس‌زمینه',
            'تو «سایر مجوزها» روشنش کن',
          ),
        AlarmNeed.battery => (
            IconsaxPlusBold.battery_full,
            'باتری: بدون محدودیت',
            'که گوشی وقتی اپ بسته‌ست یادآوری رو پاک نکنه',
          ),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, title, hint) = _copy;
    return Material(
      color: AppColors.gray1,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('alarm-need-${need.name}'),
        borderRadius: BorderRadius.circular(18),
        onTap: done ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppColors.whiteSec,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon,
                    size: 19, color: done ? AppColors.success : AppColors.black1),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ReText(title,
                        fontSize: 13.5,
                        fontWeight: 800,
                        color: AppColors.black1),
                    const SizedBox(height: 2),
                    ReText(hint,
                        fontSize: 11.5,
                        color: AppColors.gray,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (done)
                const Icon(IconsaxPlusBold.tick_circle,
                    color: AppColors.success, size: 24)
              else
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: askConfirm ? AppColors.black1 : AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: ReText(askConfirm ? 'روشنش کردم' : 'روشن کن',
                      fontSize: 12,
                      fontWeight: 800,
                      color: AppColors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
