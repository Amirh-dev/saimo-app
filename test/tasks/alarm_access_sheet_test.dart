import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/notifications/active_chat_tracker.dart';
import 'package:simo_learn/data/notifications/task_reminder_service.dart';
import 'package:simo_learn/presentation/screens/tasks/alarm_access_sheet.dart';

void main() {
  late List<AlarmNeed> missing;
  late List<AlarmNeed> opened;
  late bool batteryConfirmed;
  bool? result;

  Future<void> pump(WidgetTester tester, List<AlarmNeed> needs) async {
    missing = [...needs];
    opened = [];
    batteryConfirmed = false;
    result = null;
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () async {
                result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AlarmAccessSheet(
                    needs: needs,
                    check: () async => [...missing],
                    open: (need) async => opened.add(need),
                    confirmBattery: () async {
                      batteryConfirmed = true;
                      missing.remove(AlarmNeed.battery);
                    },
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FilledButton doneButton(WidgetTester tester) => tester
      .widget<FilledButton>(find.byKey(const ValueKey('alarm-access-done')));

  testWidgets('done stays off until every row is on, rechecked on return',
      (tester) async {
    await pump(tester, [AlarmNeed.lockScreen, AlarmNeed.backgroundPopup]);
    expect(doneButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('alarm-need-lockScreen')));
    await tester.pumpAndSettle();
    expect(opened, [AlarmNeed.lockScreen]);

    // The user turns both on in Settings and comes back.
    missing.clear();
    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(doneButton(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const ValueKey('alarm-access-done')));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('after visiting the battery page the user confirms it',
      (tester) async {
    await pump(tester, [AlarmNeed.battery]);
    final row = find.byKey(const ValueKey('alarm-need-battery'));
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(opened, [AlarmNeed.battery]);
    expect(find.text('روشنش کردم'), findsOneWidget);

    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(batteryConfirmed, isTrue);
    expect(doneButton(tester).onPressed, isNotNull);
  });

  testWidgets('later leaves the reminder unset', (tester) async {
    await pump(tester, [AlarmNeed.ringOnTime]);
    await tester.tap(find.byKey(const ValueKey('alarm-access-later')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
  });

  test('a closed chat only clears itself as the open one', () {
    final tracker = ActiveChatTracker.instance;
    tracker.appInForeground = true;
    tracker.openConversation('b');
    tracker.closeConversation('a');
    expect(tracker.shouldNotifyForMessageFrom('b'), isFalse);
    tracker.closeConversation('b');
    expect(tracker.shouldNotifyForMessageFrom('b'), isTrue);
  });
}
