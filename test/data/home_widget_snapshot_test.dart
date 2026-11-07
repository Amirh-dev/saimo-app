import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/home_widgets/home_widget_snapshot.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';

DashboardTaskItem _task(
  String id, {
  int minutes = 60,
  double percentage = 0,
  int elapsedSeconds = 0,
  bool done = false,
  bool running = false,
  DateTime? startedAt,
}) =>
    DashboardTaskItem(
      id: id,
      title: 'کار $id',
      percentage: percentage,
      doneDuration: 0,
      maxDuration: minutes,
      durationText: '$minutes',
      elapsedSeconds: elapsedSeconds,
      isDone: done,
      isRunning: running,
      timerStartedAt: startedAt,
    );

Map<String, Object?> _row(Map<String, Object?> snapshot, int i) =>
    (snapshot['tasks']! as List)[i] as Map<String, Object?>;

void main() {
  final now = DateTime(2026, 11, 7, 18, 30);

  test('carries the local day and each task as planned and worked', () {
    final snapshot = homeWidgetSnapshot(
      tasks: [
        _task('a', minutes: 30, done: true, percentage: 100),
        _task('b', minutes: 45, percentage: 50),
        _task('c', minutes: 20),
      ],
      timer: const WidgetTimerState(),
      now: now,
    );

    expect(snapshot['day'], '2026-11-07');
    expect(_row(snapshot, 0), {
      'id': 'a',
      'title': 'کار a',
      'plannedSec': 1800,
      'workedSec': 1800,
      'runningSinceMs': null,
      'done': true,
    });
    expect(_row(snapshot, 1)['workedSec'], 1350);
    expect(_row(snapshot, 2)['workedSec'], 0);
  });

  test('the live timer gives its task a start time, not a second count', () {
    final started = now.subtract(const Duration(minutes: 5));
    WidgetTimerState timerAt() => WidgetTimerState(
          activeTaskId: 'b',
          sessionStartedAt: started,
          solidSeconds: 600,
        );

    final snapshot = homeWidgetSnapshot(
      tasks: [_task('b', minutes: 45, percentage: 10)],
      timer: timerAt(),
      now: now,
    );
    final row = _row(snapshot, 0);
    expect(row['workedSec'], 600);
    expect(row['runningSinceMs'], started.millisecondsSinceEpoch);

    // A tick later nothing changed, so nothing new is sent to the widget.
    final later = homeWidgetSnapshot(
      tasks: [_task('b', minutes: 45, percentage: 10)],
      timer: timerAt(),
      now: now.add(const Duration(seconds: 1)),
    );
    expect(later, snapshot);
  });

  test('a paused timer and a finished one stop counting', () {
    final paused = homeWidgetSnapshot(
      tasks: [_task('b', minutes: 45, percentage: 10)],
      timer: const WidgetTimerState(activeTaskId: 'b', solidSeconds: 900),
      now: now,
    );
    expect(_row(paused, 0)['workedSec'], 900);
    expect(_row(paused, 0)['runningSinceMs'], isNull);

    final finished = homeWidgetSnapshot(
      tasks: [_task('b', minutes: 45, percentage: 10)],
      timer: WidgetTimerState(
        activeTaskId: 'b',
        solidSeconds: 2700,
        sessionStartedAt: now,
        isCompleted: true,
      ),
      now: now,
    );
    expect(_row(finished, 0)['done'], isTrue);
    expect(_row(finished, 0)['workedSec'], 2700);
    expect(_row(finished, 0)['runningSinceMs'], isNull);
  });

  test('a task the server saw running counts on from its start', () {
    final started = now.subtract(const Duration(minutes: 3));
    final snapshot = homeWidgetSnapshot(
      tasks: [
        _task('b', percentage: 20, elapsedSeconds: 540, running: true, startedAt: started),
      ],
      timer: const WidgetTimerState(),
      now: now,
    );
    expect(_row(snapshot, 0)['workedSec'], 540);
    expect(_row(snapshot, 0)['runningSinceMs'], started.millisecondsSinceEpoch);
  });

  test('a server-running task is paused once another holds the timer', () {
    final snapshot = homeWidgetSnapshot(
      tasks: [
        _task('a', percentage: 25, elapsedSeconds: 600, running: true, startedAt: now),
        _task('b'),
      ],
      timer: WidgetTimerState(activeTaskId: 'b', sessionStartedAt: now),
      now: now,
    );
    expect(_row(snapshot, 0)['runningSinceMs'], isNull);
    expect(_row(snapshot, 0)['workedSec'], 900);
    expect(_row(snapshot, 1)['runningSinceMs'], now.millisecondsSinceEpoch);
  });

  test('carries the multiplier and the date when the app has them', () {
    final fetched = now.subtract(const Duration(minutes: 2));
    final snapshot = homeWidgetSnapshot(
      tasks: [_task('a')],
      timer: const WidgetTimerState(),
      now: now,
      dateLabel: 'شنبه ۱۶ آبان',
      streak: DashboardConsistency(
        level: 3,
        maxLevel: 5,
        countedToday: false,
        plannedSeconds: 3600,
        progressSeconds: 600,
        studiedSeconds: 600,
        minStudySeconds: 5400,
        targetPercentage: 70,
        remainingSeconds: 2400,
        fraction: 0.3,
        fetchedAt: fetched,
      ),
    );
    expect(snapshot['date'], 'شنبه ۱۶ آبان');
    expect(snapshot['streak'], {
      'level': 3,
      'countedToday': false,
      'hasPlan': true,
      'remainingSec': 2400,
      'fetchedAtMs': fetched.millisecondsSinceEpoch,
    });

    final without = homeWidgetSnapshot(
      tasks: [_task('a')],
      timer: const WidgetTimerState(),
      now: now,
    );
    expect(without['streak'], isNull);
  });

  group('HomeWidgetLink', () {
    test('reads the widget and task links', () {
      expect(HomeWidgetLink.fromLink(Uri.parse('saimo://widget/home'))?.taskId,
          isNull);
      expect(
        HomeWidgetLink.fromLink(Uri.parse('saimo://widget/task?id=t-1'))
            ?.taskId,
        't-1',
      );
      expect(HomeWidgetLink.fromLink(Uri.parse('saimo://widget/task')),
          isNotNull);
      final add = HomeWidgetLink.fromLink(Uri.parse('saimo://widget/add'));
      expect(add?.addTask, isTrue);
      expect(add?.taskId, isNull);
    });

    test('ignores other links', () {
      expect(
        HomeWidgetLink.fromLink(Uri.parse('saimo://payment-result?attemptID=1')),
        isNull,
      );
      expect(HomeWidgetLink.fromLink(Uri.parse('https://saimo.app/widget')),
          isNull);
    });
  });
}
