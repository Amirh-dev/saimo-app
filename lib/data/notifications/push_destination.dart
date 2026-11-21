import 'notification_service.dart';
import 'task_reminder_service.dart';
import 'timer_end_notice.dart';

/// Reminder kinds the server sends inside a reminder push's `kind` field.
/// The push's `type` stays [kPushTypeConsistencyAtRisk] so older builds still
/// open the home tab for it.
const String kReminderPlanEmpty = 'PLAN_EMPTY';
const String kReminderDayCounted = 'DAY_COUNTED';
const String kReminderTimerRunning = 'TIMER_RUNNING';
const String kReminderTimerPaused = 'TIMER_PAUSED';
const String kReminderWeeklySummary = 'WEEKLY_SUMMARY';
const String kReminderComeback = 'COMEBACK';
const String kReminderTasksLeft = 'TASKS_LEFT';
const String kReminderCounselingEnding = 'COUNSELING_ENDING';
const String kReminderCounselingEnded = 'COUNSELING_ENDED';

/// A message from the team (admin panel). Sent with the reminders' type so
/// builds before it open home; it carries announcementID.
const String kPushKindAnnouncement = 'ANNOUNCEMENT';

/// Where tapping a push takes the user.
enum PushDestination {
  chat,
  friends,
  paymentResult,
  home,
  tasks,
  counselors,
  announcements,
  taskAlarm,
}

/// The destination for a tapped push's data.
PushDestination pushDestination(Map<String, String> data) {
  final type = data['type'];
  switch (type) {
    case null || '' || kPushTypeNewMessage:
      return PushDestination.chat;
    case kPushTypeFriendRequest:
      return PushDestination.friends;
    case kPushTypeCounselingPayment:
      return PushDestination.paymentResult;
    case kPushTypeTaskAlarm:
      return PushDestination.taskAlarm;
    case kPushTypeTimerEnd:
      return PushDestination.tasks;
    case kPushTypeConsistencyAtRisk:
      return switch (data['kind']) {
        kReminderPlanEmpty ||
        kReminderTimerRunning ||
        kReminderTimerPaused ||
        kReminderWeeklySummary ||
        kReminderTasksLeft =>
          PushDestination.tasks,
        // Ended, the student picks a counselor again; while it is still
        // running there is nothing to buy yet.
        kReminderCounselingEnded => PushDestination.counselors,
        kPushKindAnnouncement => PushDestination.announcements,
        _ => PushDestination.home,
      };
    default:
      // A kind of push this build does not know yet.
      return PushDestination.home;
  }
}
