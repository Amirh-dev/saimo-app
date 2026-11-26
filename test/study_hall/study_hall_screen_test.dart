import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/study_hall/buildings_screen.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_hall_screen.dart';

import '../tasks/support/app_fonts.dart';

Map<String, dynamic> _hallJson({
  String building = 'BETWEEN_4_AND_7',
  int today = (4 * 60 + 10) * 60,
  int yesterday = 3 * 3600,
  bool studying = false,
}) {
  final bands = {
    'UNDER_4_HOURS': [0, 60, 120, 180, 240],
    'BETWEEN_4_AND_7': [0, 120, 180, 240, 300, 360, 420, 480],
    'OVER_7_HOURS': [0, 240, 360, 480, 600, 720, 840],
  }[building]!;
  final roof = building != 'OVER_7_HOURS';
  final floors = <Map<String, dynamic>>[];
  for (var i = 0; i < bands.length - 1; i++) {
    floors.add({'index': i, 'isRoof': false, 'fromMinutes': bands[i], 'toMinutes': bands[i + 1], 'people': 40 + i * 13, 'studyingNow': 3 + i});
  }
  if (roof) floors.add({'index': floors.length, 'isRoof': true, 'fromMinutes': bands.last, 'toMinutes': null, 'people': 12, 'studyingNow': 4});
  return {
    'studyHall': {
      'building': building,
      'dayStartedAt': '2026-11-26T01:30:00Z',
      'dayEndsAt': '2026-11-27T01:30:00Z',
      'todaySeconds': today,
      'yesterdaySeconds': yesterday,
      'studyingNow': studying,
      'capSeconds': 14 * 3600,
      'floors': floors,
      'buildings': [
        {'studyTime': 'UNDER_4_HOURS', 'people': 5120},
        {'studyTime': 'BETWEEN_4_AND_7', 'people': 2604},
        {'studyTime': 'OVER_7_HOURS', 'people': 704},
      ],
    },
  };
}

class _Server {
  _Server(this.hall);
  Map<String, dynamic> hall;
  final moves = <String>[];

  late final repo = StudyHallRepository.withRequest(({required String query, Map<String, dynamic> variables = const {}, bool requiresAuth = true}) async {
    if (query.contains('updateProfile')) {
      final to = (variables['input'] as Map)['studyTime'] as String;
      moves.add(to);
      hall = _hallJson(building: to, today: hall['studyHall']['todaySeconds'] as int);
      return {'updateProfile': {'id': 'me', 'studyTime': to}};
    }
    return hall;
  });
}

Widget _app(Widget home) => MaterialApp(
      builder: (context, child) => RepaintBoundary(key: const ValueKey('shot'), child: child),
      home: home,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows today: my floor, its band and the next goal', (tester) async {
    final server = _Server(_hallJson());
    await tester.pumpWidget(_app(StudyHallScreen(repository: server.repo)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hall-floor')), findsOneWidget);
    expect(find.text('سالن ۴'), findsWidgets);
    expect(find.text('۴ تا ۵ ساعت'), findsOneWidget);
    expect(find.text('۵۰ دقیقه تا سالن ۵'), findsOneWidget);
    expect(find.text('دیروز: سالن ۳'), findsOneWidget);
    expect(find.text('ساختمان طلا'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a running timer climbs to the next floor live', (tester) async {
    var now = DateTime(2026, 11, 26, 20);
    final server = _Server(_hallJson(today: (4 * 60 + 58) * 60, studying: true));
    await tester.pumpWidget(_app(StudyHallScreen(repository: server.repo, clock: () => now)));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('hall-floor')).evaluate().single.widget, isA<Widget>());
    expect(find.text('سالن ۴'), findsWidgets);

    now = now.add(const Duration(minutes: 3));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('رفتی سالن ۵!'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('سالن ۵'), findsWidgets);
    expect(find.text('۵ تا ۶ ساعت'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the roof offers the next building and moves there', (tester) async {
    final server = _Server(_hallJson(today: (8 * 60 + 5) * 60));
    await tester.pumpWidget(_app(StudyHallScreen(repository: server.repo)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('از ساختمان طلا جلو زدی!'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('roof-move')));
    await tester.pumpAndSettle();
    expect(server.moves, ['OVER_7_HOURS']);
    expect(find.text('ساختمان الماس'), findsWidgets);
    // 8:05 in the top building is floor 2 (6 to 8 is floor 2, 8 to 10 is 3).
    expect(find.text('سالن ۴'), findsWidgets);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('«فعلاً همین‌جا» stops the question for a week', (tester) async {
    final server = _Server(_hallJson(today: (8 * 60 + 5) * 60));
    await tester.pumpWidget(_app(StudyHallScreen(repository: server.repo)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('roof-stay')));
    await tester.pumpAndSettle();
    expect(server.moves, isEmpty);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('hall_roof_declined_until'), isNotNull);

    await tester.pumpWidget(_app(StudyHallScreen(key: UniqueKey(), repository: server.repo)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('از ساختمان طلا جلو زدی!'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('the buildings page moves once a day', (tester) async {
    final server = _Server(_hallJson());
    final hall = StudyHall.fromJson(server.hall['studyHall'] as Map<String, dynamic>);
    HallBuilding? moved;
    await tester.pumpWidget(_app(Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async => moved = await Navigator.of(context).push<HallBuilding>(
              MaterialPageRoute(builder: (_) => HallBuildingsScreen(hall: hall, repository: server.repo)),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    )));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('تو اینجایی'), findsOneWidget);
    expect(find.text('۷۰۴ نفر امروز'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('hall-building-UNDER_4_HOURS')));
    await tester.pumpAndSettle();
    expect(find.text('بری ساختمان نقره؟'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('move-yes')));
    await tester.pumpAndSettle();
    expect(server.moves, ['UNDER_4_HOURS']);
    expect(moved, HallBuilding.under4);
    expect(await hallMovedToday(hall.dayStartedAt), isTrue);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hall-building-OVER_7_HOURS')));
    await tester.pumpAndSettle();
    expect(find.text('امروز یه بار عوض کردی'), findsOneWidget);
  });

  test('floors follow the bands; the top building has no roof', () {
    final mid = StudyHall.fromJson(_hallJson()['studyHall'] as Map<String, dynamic>);
    expect(mid.hasRoof, isTrue);
    expect(mid.floorFor(0), 0);
    expect(mid.floorFor(7200), 1);
    expect(mid.floorFor(8 * 3600), 7);
    final top = StudyHall.fromJson(_hallJson(building: 'OVER_7_HOURS')['studyHall'] as Map<String, dynamic>);
    expect(top.hasRoof, isFalse);
    expect(top.floorFor(14 * 3600), 5);
    expect(top.floorFor(20 * 3600), 5);
    expect(HallBuilding.top.next, isNull);
  });

  test('every avatar part renders to an SVG string', () {
    for (final hair in hallHairs) {
      for (final eyes in ['sparkle', 'calm', 'happy', 'wink', 'sharp', 'focus']) {
        final svg = hallAvatarSvg(HallAvatar(hair: hair, eyes: eyes, beard: 'beard', accessories: const {'glasses', 'cap', 'earrings'}));
        expect(svg, startsWith('<svg'));
        expect(svg, isNot(contains('null')));
      }
    }
  });

  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  testWidgets('screenshots', skip: shotDir == null, (tester) async {
    await tester.runAsync(loadAppFonts);
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    Future<void> shoot(String name) async {
      final b = tester.renderObject<RenderRepaintBoundary>(find.byKey(const ValueKey('shot')));
      final png = await tester.runAsync(() async {
        final image = await b.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(png!);
    }

    final server = _Server(_hallJson(studying: true));
    await tester.pumpWidget(_app(StudyHallScreen(repository: server.repo)));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await shoot('hall_building');

    await tester.tap(find.byKey(const ValueKey('hall-buildings')));
    await tester.pumpAndSettle();
    await shoot('hall_buildings');
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pumpAndSettle();

    final roof = _Server(_hallJson(today: (8 * 60 + 5) * 60));
    await tester.pumpWidget(_app(StudyHallScreen(key: UniqueKey(), repository: roof.repo)));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 300)));
    await tester.pump();
    await shoot('hall_roof');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
