import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/weekly_plan_controller.dart';

import 'support/task_fixtures.dart';

void main() {
  late FakeTasksApi api;
  late WeeklyPlanController controller;

  setUp(() {
    api = FakeTasksApi(holdSchedules: true);
    controller = WeeklyPlanController(api, today: () => testToday);
  });

  tearDown(() => controller.dispose());

  Future<void> loadWeek(List<Map<String, dynamic>> tasks, {Jalali? of}) async {
    final loading = controller.showWeekOf(of ?? testToday);
    api.respond(tasks, request: api.pendingSchedules.length - 1);
    await loading;
  }

  test('loads the week of the given day', () async {
    final loading = controller.showWeekOf(testToday);
    expect(controller.isLoading, isTrue);

    final request = api.scheduleRequests.single;
    expect(ymd(request.start), [1405, 7, 18]);
    expect(ymd(request.end), [1405, 7, 25]);

    final monday = buildTask(Jalali(1405, 7, 20));
    api.respond([monday]);
    await loading;

    expect(controller.isLoading, isFalse);
    expect(controller.hasData, isTrue);
    expect(controller.plan.taskCount, 1);
    expect(controller.plan.days[2].tasks, [monday]);
  });

  test('keeps the newest week when an older response arrives late', () async {
    final first = controller.showWeekOf(testToday);
    final second = controller.showWeekOf(Jalali(1405, 7, 27));

    api.respond([buildTask(Jalali(1405, 7, 27))], request: 1);
    await second;
    api.respond(
        [buildTask(Jalali(1405, 7, 20)), buildTask(Jalali(1405, 7, 21))]);
    await first;

    expect(ymd(controller.weekStart), [1405, 7, 25]);
    expect(controller.plan.taskCount, 1);
  });

  test('a failed first load reports an error until a retry succeeds', () async {
    final loading = controller.showWeekOf(testToday);
    api.pendingSchedules.single.completeError(Exception('offline'));
    await loading;
    expect(controller.hasError, isTrue);

    final retry = controller.reload();
    api.respond([buildTask(Jalali(1405, 7, 21))], request: 1);
    await retry;
    expect(controller.hasError, isFalse);
    expect(controller.plan.taskCount, 1);
  });

  test('a silent reload keeps showing the week while it loads', () async {
    await loadWeek([buildTask(Jalali(1405, 7, 20))]);

    final reloading = controller.reload(silent: true);
    expect(controller.isLoading, isFalse);
    expect(controller.plan.taskCount, 1);
    api.respond(
        [buildTask(Jalali(1405, 7, 20)), buildTask(Jalali(1405, 7, 21))],
        request: 1);
    await reloading;
    expect(controller.plan.taskCount, 2);
  });

  test('cannot go past the planning horizon', () async {
    await loadWeek(const []);
    expect(controller.canGoForward, isTrue);

    await loadWeek(const [], of: testToday.addDays(77));
    expect(controller.canGoForward, isFalse);
  });

  test('checking a task off shows at once and is saved', () async {
    await loadWeek([buildTask(Jalali(1405, 7, 20), id: 'a')]);
    var notified = 0;
    controller.addListener(() => notified++);

    final saving = controller.setTaskDone(controller.tasks.single, done: true);
    expect(controller.plan.doneCount, 1);
    expect(notified, 1);
    await saving;
    expect(api.doneChanges, [('a', true)]);
  });

  test('a check that fails to save is undone and reported', () async {
    await loadWeek([buildTask(Jalali(1405, 7, 20), id: 'a')]);
    api.doneError = Exception('offline');

    await expectLater(
      controller.setTaskDone(controller.tasks.single, done: true),
      throwsException,
    );
    expect(controller.plan.doneCount, 0);
  });
}
