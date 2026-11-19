import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/widgets/_widgets.dart';
import 'package:simo_learn/utils/colors.dart';

/// Run when a reminder is turned on: asks for notifications, then explains
/// and asks for exact alarms when Android has not granted them (without it
/// the alarm rings late), then for the lock-screen page.
Future<void> ensureAlarmAccess(BuildContext context) async {
  final reminders = TaskReminderService.instance;
  if (!await reminders.requestPermission()) return;
  if (!await reminders.canRingOnTime()) {
    if (!context.mounted) return;
    final allow = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const AlarmAccessSheet(),
    );
    if (allow != true) return;
    await reminders.requestRingOnTime();
  }
  await reminders.requestFullScreen();
}

class AlarmAccessSheet extends StatelessWidget {
  const AlarmAccessSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
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
              const ReText('یادآوری سر وقت زنگ بزنه؟',
                  fontSize: 17,
                  fontWeight: 900,
                  color: AppColors.black1,
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const SizedBox(
                width: double.infinity,
                child: ReText(
                  'تو صفحه‌ی بعد «آلارم‌ها و یادآوری‌ها» رو برای سایمو روشن کن. بدون اون، یادآوری ممکنه با تأخیر بیاد.',
                  fontSize: 13.5,
                  color: AppColors.gray,
                  textAlign: TextAlign.center,
                  maxLines: null,
                  overflow: TextOverflow.visible,
                  lineHeight: 1.7,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton(
                        key: const ValueKey('alarm-access-allow'),
                        onPressed: () => Navigator.of(context).pop(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                        ),
                        child: const ReText('روشنش کن',
                            fontSize: 15,
                            fontWeight: 800,
                            color: AppColors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    child: TextButton(
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
