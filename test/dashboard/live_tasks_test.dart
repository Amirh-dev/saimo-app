import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/presentation/screens/dashboard/live_tasks.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

DashboardTaskItem _item(
  String id, {
  int done = 0,
  int max = 60,
  bool isDone = false,
  bool isRunning = false,
  DateTime? timerStartedAt,
}) =>
    DashboardTaskItem(
      id: id,
      title: id,
      percentage: isDone ? 100 : done * 100 / max,
      doneDuration: isDone ? max : done,
      maxDuration: max,
      durationText: '$max',
      elapsedSeconds: done * 60,
      isDone: isDone,
      isRunning: isRunning,
      timerStartedAt: timerStartedAt,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final timer = TaskTimerService.instance;
  tearDown(timer.clear);

  test('a task started anywhere in the app shows as running at once', () async {
    final tasks = [_item('physics', done: 25), _item('chemistry')];
    timer.load(taskId: 'chemistry', totalSeconds: 3600, elapsedSeconds: 600);
    await timer.start();

    final live = liveTodayTasks(tasks, timer);

    expect(live[1].isRunning, isTrue);
    expect(live[1].doneDuration, 10);
    expect(live[0].isRunning, isFalse);
    expect(live[0].doneDuration, 25);
  });

  test('a paused or finished timer is shown as the timer has it', () async {
    final tasks = [_item('physics', done: 5, isRunning: true)];
    timer.load(taskId: 'physics', totalSeconds: 3600, elapsedSeconds: 1800);

    var live = liveTodayTasks(tasks, timer);
    expect(live.single.isRunning, isFalse);
    expect(live.single.isPaused, isTrue);
    expect(live.single.doneDuration, 30);

    timer.load(
      taskId: 'physics',
      totalSeconds: 3600,
      elapsedSeconds: 3600,
      isDone: true,
    );
    live = liveTodayTasks(tasks, timer);
    expect(live.single.isDone, isTrue);
    expect(live.single.percentage, 100);
  });

  test('a timer the server runs keeps counting until this app holds one',
      () async {
    final now = DateTime(2026, 10, 19, 10);
    final tasks = [
      _item('biology',
          done: 10,
          max: 120,
          isRunning: true,
          timerStartedAt: now.subtract(const Duration(minutes: 15))),
    ];

    var live = liveTodayTasks(tasks, timer, now: now);
    expect(live.single.isRunning, isTrue);
    expect(live.single.doneDuration, 25);

    // Another task holds the app's timer, so this one was paused.
    timer.load(taskId: 'other', totalSeconds: 600, elapsedSeconds: 0);
    await timer.start();
    live = liveTodayTasks(tasks, timer, now: now);
    expect(live.single.isRunning, isFalse);
  });

  test('today\'s study grows while a timer runs, from when it was fetched',
      () async {
    final fetchedAt = DateTime.now().subtract(const Duration(minutes: 3));
    final consistency = DashboardConsistency(
      level: 2,
      maxLevel: 5,
      countedToday: false,
      plannedSeconds: 7200,
      progressSeconds: 600,
      studiedSeconds: 600,
      minStudySeconds: 5400,
      targetPercentage: 75,
      remainingSeconds: 4800,
      fraction: 0.1,
      fetchedAt: fetchedAt,
    );
    expect(liveStudiedSeconds(consistency, timer), 600);

    // Started just now: the server had none of it when it answered.
    timer.load(taskId: 'math', totalSeconds: 3600, elapsedSeconds: 0);
    await timer.start();
    expect(liveStudiedSeconds(consistency, timer), inInclusiveRange(600, 602));
  });
}
