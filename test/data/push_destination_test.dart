import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/notifications/notification_service.dart';
import 'package:simo_learn/data/notifications/push_destination.dart';

void main() {
  group('pushDestination', () {
    test('chat messages, with or without a type, open the chat', () {
      expect(pushDestination({}), PushDestination.chat);
      expect(pushDestination({'type': ''}), PushDestination.chat);
      expect(
          pushDestination({'type': kPushTypeNewMessage}), PushDestination.chat);
    });

    test('friend requests and payment results keep their screens', () {
      expect(pushDestination({'type': kPushTypeFriendRequest}),
          PushDestination.friends);
      expect(pushDestination({'type': kPushTypeCounselingPayment}),
          PushDestination.paymentResult);
    });

    test('reminders about the plan or a timer open the tasks tab', () {
      for (final kind in [
        kReminderPlanEmpty,
        kReminderTimerRunning,
        kReminderTimerPaused,
        kReminderWeeklySummary,
        kReminderTasksLeft,
      ]) {
        expect(
          pushDestination({'type': kPushTypeConsistencyAtRisk, 'kind': kind}),
          PushDestination.tasks,
          reason: kind,
        );
      }
    });

    test('multiplier and comeback reminders open home', () {
      for (final kind in [
        null,
        'CONSISTENCY_AT_RISK',
        kReminderDayCounted,
        kReminderComeback,
        kReminderCounselingEnding
      ]) {
        expect(
          pushDestination({
            'type': kPushTypeConsistencyAtRisk,
            if (kind != null) 'kind': kind,
          }),
          PushDestination.home,
          reason: '$kind',
        );
      }
    });

    test('an ended subscription opens the counselor list', () {
      expect(
        pushDestination({
          'type': kPushTypeConsistencyAtRisk,
          'kind': kReminderCounselingEnded
        }),
        PushDestination.counselors,
      );
    });

    test('an unknown type opens home, not the chat', () {
      expect(pushDestination({'type': 'SOMETHING_NEW'}), PushDestination.home);
    });
  });

  group('generalNotificationKey', () {
    test('keeps the old keys for pushes without a kind', () {
      expect(
          generalNotificationKey(
              {'type': kPushTypeFriendRequest, 'friendshipID': 'f1'}),
          'FRIEND_REQUEST:f1');
      expect(generalNotificationKey({'type': kPushTypeConsistencyAtRisk}),
          'CONSISTENCY_AT_RISK:');
    });

    test('separates reminders by kind and by task', () {
      final a = generalNotificationKey({
        'type': kPushTypeConsistencyAtRisk,
        'kind': kReminderTimerPaused,
        'taskID': 't1'
      });
      final b = generalNotificationKey({
        'type': kPushTypeConsistencyAtRisk,
        'kind': kReminderTimerPaused,
        'taskID': 't2'
      });
      final c = generalNotificationKey(
          {'type': kPushTypeConsistencyAtRisk, 'kind': kReminderPlanEmpty});
      expect({a, b, c}.length, 3);
    });
  });
}
