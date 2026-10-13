import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final timer = TaskTimerService.instance;
  tearDown(timer.clear);

  test('a finished timer announces its task, so a report can be asked for',
      () async {
    final task = <String, dynamic>{'id': 't1', 'title': 'تست ریاضی'};
    timer.load(
        taskId: 't1', totalSeconds: 60, elapsedSeconds: 60, taskData: task);

    final announced = <Map<String, dynamic>>[];
    final subscription = timer.completions.listen(announced.add);
    addTearDown(subscription.cancel);

    expect(await timer.complete(), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(announced, [task]);
  });

  test('completing while a report is being collected stays quiet', () async {
    timer.load(
        taskId: 't2',
        totalSeconds: 60,
        elapsedSeconds: 10,
        taskData: <String, dynamic>{'id': 't2'});

    final announced = <Map<String, dynamic>>[];
    final subscription = timer.completions.listen(announced.add);
    addTearDown(subscription.cancel);

    expect(await timer.complete(announce: false), isTrue);
    await Future<void>.delayed(Duration.zero);
    expect(announced, isEmpty);
  });
}
