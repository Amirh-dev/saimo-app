import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/data/notifications/push_destination.dart';
import 'package:simo_learn/data/notifications/timer_end_notice.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';

class _FakePlatform implements TimerEndPlatform {
  final calls = <String>[];
  int prepared = 0;

  @override
  void prepare() => prepared++;
  DateTime? at;
  String? title;
  String? body;

  @override
  Future<void> schedule(DateTime at, String title, String body) async {
    calls.add('schedule');
    this.at = at;
    this.title = title;
    this.body = body;
  }

  @override
  Future<void> cancel() async => calls.add('cancel');

  @override
  Future<void> chime() async => calls.add('chime');
}

Future<void> _settle() => Future<void>.delayed(Duration.zero);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final timer = TaskTimerService.instance;
  late _FakePlatform platform;
  late TimerEndNotice notice;

  setUp(() {
    platform = _FakePlatform();
    notice = TimerEndNotice(timer, platform)..attach();
  });

  tearDown(() {
    notice.detach();
    timer.clear();
  });

  /// A 60-second timer for 't1' running since [startedAt].
  void run(DateTime startedAt) => timer.resumeRunning(
        taskId: 't1',
        totalSeconds: 60 * 45,
        elapsedSeconds: 0,
        startedAt: startedAt,
        taskData: <String, dynamic>{'id': 't1', 'title': 'ریاضی – فصل ۳'},
      );

  test('the app open: no notification is scheduled', () async {
    run(DateTime.now());
    await _settle();
    expect(platform.calls, isEmpty);
  });

  test('leaving the app schedules the notice for the end time, once',
      () async {
    final started = DateTime.now().subtract(const Duration(minutes: 5));
    run(started);
    notice.setForeground(false);
    timer.notifyListeners(); // a tick
    timer.notifyListeners();
    await _settle();

    expect(platform.calls, ['schedule']);
    expect(platform.at, started.add(const Duration(minutes: 45)));
    expect(platform.title, 'تسکت رو به پایان رسوندی ✅');
    expect(platform.body, '۴۵ دقیقه · ریاضی – فصل ۳');
  });

  test('coming back takes the notice back', () async {
    run(DateTime.now());
    notice.setForeground(false);
    notice.setForeground(true);
    await _settle();
    expect(platform.calls, ['schedule', 'cancel']);
  });

  test('pausing in the background takes the notice back', () async {
    run(DateTime.now());
    notice.setForeground(false);
    await timer.pause();
    await _settle();
    expect(platform.calls, ['schedule', 'cancel']);
  });

  test('a timer that ran out in the background keeps its notice', () async {
    run(DateTime.now().subtract(const Duration(minutes: 45)));
    notice.setForeground(false);
    await timer.complete();
    await _settle();
    expect(platform.calls, ['schedule']);

    notice.setForeground(true);
    await _settle();
    expect(platform.calls, ['schedule', 'cancel']);
  });

  test('running out with the app open plays the chime', () async {
    // Ends half a second from now; the next tick finds it done.
    run(DateTime.now().subtract(const Duration(minutes: 45) -
        const Duration(milliseconds: 500)));
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    expect(timer.isCompleted, isTrue);
    expect(platform.calls, ['chime']);
  });

  test('a time-up noticed late (it already rang outside) stays quiet',
      () async {
    run(DateTime.now().subtract(const Duration(minutes: 46)));
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    expect(timer.isCompleted, isTrue);
    expect(platform.calls, isEmpty);
  });

  test('starting a timer gets the platform ready once (browser permission)',
      () async {
    run(DateTime.now());
    timer.notifyListeners(); // a tick
    await timer.pause();
    expect(platform.prepared, 1);
  });

  test('the body leads with the minutes; no title, minutes only', () {
    expect(timerEndBody(minutes: 25, taskTitle: ' '), '۲۵ دقیقه');
    expect(timerEndBody(minutes: 90, taskTitle: 'زیست'), '۹۰ دقیقه · زیست');
  });

  test('tapping the notice opens the tasks tab', () {
    expect(pushDestination({'type': kPushTypeTimerEnd}), PushDestination.tasks);
  });
}
