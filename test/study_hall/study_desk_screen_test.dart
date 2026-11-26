import 'dart:io';
import 'dart:ui' as ui;

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/study_hall/hall_avatar_store.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_desk_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';

import '../tasks/support/app_fonts.dart';

class _FakeTimerRepository extends TaskTimerRepository {
  _FakeTimerRepository(super.graphQLRepository);
  final calls = <String>[];
  @override
  Future<dynamic> startTimedTask(String id) async => calls.add('start $id');
  @override
  Future<dynamic> pauseTimedTask(String id) async => calls.add('pause $id');
  @override
  Future<dynamic> completeTimedTask(String id) async => calls.add('complete $id');
}

class _FakeTasks implements TasksApi {
  final tasks = <Map<String, dynamic>>[
    _task(),
    _task(id: 't2', title: 'استوکیومتری', subject: 'شیمی', minutes: 40),
    _task(id: 't3', title: 'تست مشتق', subject: 'ریاضی', minutes: 60, elapsed: 3600, status: 'done'),
  ];
  final added = <String>[];

  @override
  Future<List<Map<String, dynamic>>> fetchSchedule({required Jalali start, required Jalali end}) async => [...tasks];

  @override
  Future<Map<String, dynamic>> createQuickTask(QuickTaskDraft draft) async {
    added.add('${draft.title} ${draft.timedMinutes}');
    final t = _task(id: 't${tasks.length + 1}', title: draft.title, minutes: draft.timedMinutes ?? 30);
    tasks.add(t);
    return t;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Silent implements HallSoundPlayer {
  @override
  Future<void> start(HallSound sound, double volume) async {}
  @override
  Future<void> setVolume(HallSound sound, double volume) async {}
  @override
  Future<void> stop(HallSound sound) async {}
  @override
  Future<void> dispose() async {}
}

Map<String, dynamic> _task({
  String id = 't1',
  String title = 'فصل ۳ حرکت‌شناسی',
  String subject = 'فیزیک',
  int minutes = 120,
  int elapsed = 0,
  String status = 'pending',
}) =>
    {
      'id': id,
      'title': title,
      'type': 'TIMED',
      'subject': subject,
      'tags': [subject],
      'durationSeconds': minutes * 60,
      'elapsedSeconds': elapsed,
      'status': status,
    };

Map<String, dynamic> _hall({int today = (4 * 60 + 10) * 60}) => {
      'studyHall': {
        'building': 'BETWEEN_4_AND_7',
        'dayStartedAt': '2026-11-26T01:30:00Z',
        'dayEndsAt': '2026-11-27T01:30:00Z',
        'todaySeconds': today,
        'yesterdaySeconds': 3 * 3600,
        'studyingNow': true,
        'capSeconds': 14 * 3600,
        'floors': [
          for (final (i, from, to) in const [(0, 0, 120), (1, 120, 180), (2, 180, 240), (3, 240, 300), (4, 300, 360), (5, 360, 420), (6, 420, 480)])
            {'index': i, 'isRoof': false, 'fromMinutes': from, 'toMinutes': to, 'people': 20 + i, 'studyingNow': 5},
          {'index': 7, 'isRoof': true, 'fromMinutes': 480, 'toMinutes': null, 'people': 4, 'studyingNow': 1},
        ],
        'buildings': [
          {'studyTime': 'UNDER_4_HOURS', 'people': 10},
          {'studyTime': 'BETWEEN_4_AND_7', 'people': 30},
          {'studyTime': 'OVER_7_HOURS', 'people': 5},
        ],
        'studyingNowTotal': 241,
        'myAvatar': null,
        'bestDaySeconds': 5 * 3600,
        // Two waterings this week: +2 (3 h) yesterday, +1 (2:30) before.
        'recentDays': [for (var i = 0; i < 27; i++) 0, 9000, 0, 3 * 3600],
        'neighbors': [
          {'userID': 'u1', 'name': 'سارا', 'avatar': '{"boy":false,"hair":"long","hairColor":5}', 'todaySeconds': 4 * 3600 + 30 * 60, 'studyingNow': true},
          {'userID': 'u2', 'name': 'امیر', 'avatar': null, 'todaySeconds': 4 * 3600 + 5 * 60, 'studyingNow': false},
        ],
      },
    };

/// 22:00 Tehran (night) and 10:00 Tehran (day).
final _night = DateTime.utc(2026, 11, 26, 18, 30);
final _day = DateTime.utc(2026, 11, 26, 6, 30);

void main() {
  setUpAll(loadAppFonts);
  final timer = TaskTimerService.instance;
  tearDown(timer.clear);
  tearDown(() {
    HallAvatarStore.instance.reset();
    StudyHallRepository.cached = null;
  });
  final saved = <String>[];
  var today = (4 * 60 + 10) * 60;
  final hallRepo = StudyHallRepository.withRequest(({required String query, Map<String, dynamic> variables = const {}, bool requiresAuth = true}) async {
    if (query.contains('setHallAvatar')) {
      saved.add(variables['avatar'] as String);
      return {'setHallAvatar': true};
    }
    if (query.contains('studyHallFloor')) {
      return {
        'studyHallFloor': [
          {'userID': 'f1', 'name': 'نگار', 'avatar': '{"boy":false,"hair":"bob"}', 'todaySeconds': 3 * 3600 + 20 * 60, 'studyingNow': true},
          {'userID': 'f2', 'name': 'رضا', 'avatar': null, 'todaySeconds': 3 * 3600 + 5 * 60, 'studyingNow': false},
        ],
      };
    }
    return _hall(today: today);
  });

  Future<(_FakeTimerRepository, HallSoundMixer, _FakeTasks)> open(WidgetTester tester,
      {bool saver = false, int elapsed = 0, DateTime? clock, Size size = const Size(390, 844)}) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({'hall_battery_saver': saver});
    final graphQL = GraphQLRepository(
      Client(link: Link.function((request, [forward]) => const Stream<Response>.empty())),
      tokenStorage: await TokenStorage.create(),
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    );
    final fake = _FakeTimerRepository(graphQL);
    timer.bindRepository(fake);
    final mixer = HallSoundMixer(player: _Silent());
    final tasks = _FakeTasks();
    final at = clock ?? _night;
    await tester.pumpWidget(MaterialApp(
      builder: (context, child) => RepaintBoundary(key: const ValueKey('shot'), child: child),
      home: StudyDeskScreen(
        task: _task(elapsed: elapsed),
        onPop: () {},
        mixer: mixer,
        timer: timer,
        hallRepository: hallRepo,
        tasksApi: tasks,
        clock: () => at,
      ),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    return (fake, mixer, tasks);
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
  }

  Future<void> close(WidgetTester tester) async {
    // A running timer ticks; stop it so no periodic timer is left behind.
    timer.clear();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('the camera flies in, then the desk is ready', (tester) async {
    await open(tester);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('desk-camera')), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.byKey(const ValueKey('desk-camera')), findsNothing);
    expect(find.text('میز کار من'), findsOneWidget);
    expect(find.text('شروع'), findsOneWidget);
    expect(find.text('تموم'), findsNothing);
    expect(find.text('تغییر ظاهر'), findsOneWidget);
    await close(tester);
  });

  testWidgets('tapping the camera skips it', (tester) async {
    await open(tester);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const ValueKey('desk-camera')));
    await tester.pump();
    expect(find.byKey(const ValueKey('desk-camera')), findsNothing);
    await close(tester);
  });

  testWidgets('one button: شروع, then توقف', (tester) async {
    final (fake, _, _) = await open(tester, saver: true, elapsed: 600);
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(fake.calls, ['start t1']);
    expect(find.text('توقف'), findsOneWidget);
    expect(find.text('تموم'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(fake.calls, ['start t1', 'pause t1']);
    expect(find.text('شروع'), findsOneWidget);
    await close(tester);
  });

  testWidgets('battery saver skips the camera and is remembered', (tester) async {
    await open(tester, saver: true);
    expect(find.byKey(const ValueKey('desk-camera')), findsNothing);
    await tester.tap(find.byKey(const ValueKey('desk-saver')));
    await tester.pump(const Duration(milliseconds: 300));
    expect((await SharedPreferences.getInstance()).getBool('hall_battery_saver'), isFalse);
    await close(tester);
  });

  testWidgets('the card shows the سالن, the way up and the building', (tester) async {
    await open(tester, saver: true);
    expect(find.text('سالن ۴'), findsOneWidget);
    expect(find.text('۵۰ دقیقه تا سالن ۵'), findsOneWidget);
    // 5 studying on each of seven سالن plus one on the roof.
    expect(find.text('۳۶ نفر در ساختمان در حال مطالعه هستند'), findsOneWidget);
    expect(find.text('۲۲ نفر دیگه امروز توی سالن ۴ هستن'), findsOneWidget);
    await close(tester);
  });

  testWidgets('the headphones open the sounds', (tester) async {
    await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-obj-sound')));
    await settle(tester);
    expect(find.text('صداها'), findsOneWidget);
    expect(find.text('بارون'), findsOneWidget);
    await close(tester);
  });

  testWidgets('the books list today and switch the timer to another task', (tester) async {
    final (fake, _, _) = await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('desk-obj-tasks')));
    await settle(tester);
    expect(find.text('تسک‌های امروز'), findsOneWidget);
    expect(find.text('۱ از ۳'), findsOneWidget);
    expect(find.text('الان'), findsOneWidget);
    expect(find.text('تموم‌شده‌ها'), findsOneWidget);
    // 1 h done (the finished task) of 3:40 planned.
    expect(find.text('۲۷٪'), findsOneWidget);
    expect(find.byKey(const ValueKey('desk-go-tasks')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('desk-task-t2')));
    await settle(tester);
    // Was running: pause the old task, start the new one.
    expect(fake.calls, ['start t1', 'pause t1', 'start t2']);
    expect(find.text('شیمی، استوکیومتری'), findsOneWidget);
    await close(tester);
  });

  testWidgets('the tea glass pauses for a break and comes back', (tester) async {
    final (fake, _, _) = await open(tester, saver: true, elapsed: 60);
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('desk-obj-break')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('desk-break-start')));
    await settle(tester);
    expect(fake.calls, ['start t1', 'pause t1']);
    expect(find.text('وقت چای'), findsOneWidget);
    expect(find.text('۰۵:۰۰'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('desk-break-end')));
    await settle(tester);
    expect(fake.calls, ['start t1', 'pause t1', 'start t1']);
    expect(find.text('توقف'), findsOneWidget);
    await close(tester);
  });

  testWidgets('the plant counts leaves by سالن', (tester) async {
    await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-obj-plant')));
    await settle(tester);
    // Yesterday 3 h (+2), three days ago 2:30 (+1), today 4:10 (+3).
    expect(find.text('۶ برگ'), findsOneWidget);
    expect(find.text('امروز آب خورد'), findsOneWidget);
    await close(tester);
  });

  testWidgets('your best day unlocks items; wearing one saves it', (tester) async {
    saved.clear();
    await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-me')));
    await settle(tester);
    expect(find.text('۵:۰۰'), findsOneWidget);
    expect(find.text('بیشترین ساعتی که یه روز خوندی. با رکورد ۶ ساعت «هدفون طلایی» باز می‌شه.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('look-item-gradcap')));
    await settle(tester);
    expect(HallAvatarStore.instance.avatar.reward, '');
    await tester.tap(find.byKey(const ValueKey('look-item-scarf')));
    await settle(tester);
    expect(HallAvatarStore.instance.avatar.reward, 'scarf');
    expect(saved.last, contains('"reward":"scarf"'));
    // The builder keeps the item.
    await tester.tap(find.byKey(const ValueKey('look-builder')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('builder-girl')));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('builder-save')));
    await settle(tester);
    expect(HallAvatarStore.instance.avatar.boy, isFalse);
    expect(HallAvatarStore.instance.avatar.reward, 'scarf');
    await close(tester);
  });

  testWidgets('the mirror opens your look', (tester) async {
    await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-obj-mirror')));
    await settle(tester);
    expect(find.text('رکورد تو'), findsOneWidget);
    await close(tester);
  });

  testWidgets('crossing into the next سالن shows a banner', (tester) async {
    today = 5 * 3600 - 1;
    addTearDown(() => today = (4 * 60 + 10) * 60);
    await open(tester, saver: true, elapsed: 60);
    expect(find.text('سالن ۴'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await tester.pump(const Duration(milliseconds: 100));
    // The timer counts real seconds.
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 2300)));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('رفتی سالن ۵!'), findsOneWidget);
    await close(tester);
  });

  testWidgets('the people card opens the building; a سالن lists its people', (tester) async {
    await open(tester, saver: true);
    await tester.tap(find.byKey(const ValueKey('desk-people')));
    await settle(tester);
    expect(find.text('ساختمان طلا'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('hall-floor-2')));
    await settle(tester);
    expect(find.text('نگار'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('floor-person-f1')));
    await settle(tester);
    expect(find.text('امروز ۳:۲۰ خونده'), findsOneWidget);
    expect(find.text('الان داره می‌خونه'), findsOneWidget);
    await close(tester);
  });

  testWidgets('a small phone still fits the desk and the card', (tester) async {
    await open(tester, saver: true, size: const Size(360, 640));
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('desk-toggle')), findsOneWidget);
    await close(tester);
  });

  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  testWidgets('screenshots', skip: shotDir == null, (tester) async {
    Future<void> shoot(String name) async {
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
      await tester.pump(const Duration(milliseconds: 100));
      final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
      final png = await tester.runAsync(() async {
        final image = await b.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(png!);
    }

    Future<void> dismiss() async {
      await tester.tapAt(const Offset(20, 240));
      await settle(tester);
    }

    var (_, mixer, _) = await open(tester, elapsed: 18 * 60);
    await tester.pump(const Duration(milliseconds: 700));
    await shoot('desk2_camera');
    await tester.pump(const Duration(seconds: 2));
    await mixer.toggle(hallSounds.firstWhere((s) => s.id == 'rain'));
    await tester.tap(find.byKey(const ValueKey('desk-toggle')));
    await settle(tester);
    await shoot('desk2_night_running');
    await tester.tap(find.byKey(const ValueKey('desk-obj-tasks')));
    await settle(tester);
    await shoot('desk2_tasks');
    await dismiss();
    await tester.tap(find.byKey(const ValueKey('desk-obj-plant')));
    await settle(tester);
    await shoot('desk2_plant');
    await dismiss();
    await tester.tap(find.byKey(const ValueKey('desk-me')));
    await settle(tester);
    await shoot('desk2_look');
    await dismiss();
    await tester.tap(find.byKey(const ValueKey('desk-obj-break')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('desk-break-start')));
    await settle(tester);
    await shoot('desk2_break');
    await tester.tap(find.byKey(const ValueKey('desk-break-end')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('desk-people')));
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 80));
    }
    await shoot('desk2_building');
    await tester.tap(find.byKey(const ValueKey('hall-floor-3')));
    await settle(tester);
    await shoot('desk2_floor');
    await close(tester);

    (_, mixer, _) = await open(tester, elapsed: 18 * 60, clock: _day);
    await tester.pump(const Duration(seconds: 2));
    await shoot('desk2_day');
    await close(tester);
  });
}
