import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/feedback/feedback_repository.dart';
import 'package:simo_learn/presentation/screens/profile/feedback_screen.dart';

import '../tasks/support/app_fonts.dart';

class _FakeRepo implements FeedbackRepository {
  final submitted = <(FeedbackKind, String, String?)>[];
  bool fail = false;

  @override
  Future<List<FeedbackCounselor>> myCounselors() async =>
      const [FeedbackCounselor(userId: 'c1', name: 'مریم احمدی')];

  @override
  Future<List<SentFeedback>> myFeedback() async => [
        SentFeedback(
          id: 'f1',
          createdAt: DateTime(2026, 11, 10),
          kind: FeedbackKind.suggestion,
          status: FeedbackStatus.resolved,
          body: 'کاش بشه تسک‌ها رو با رنگ از هم جدا کرد.',
        ),
        SentFeedback(
          id: 'f2',
          createdAt: DateTime(2026, 11, 14),
          kind: FeedbackKind.complaint,
          status: FeedbackStatus.inReview,
          body: 'مشاورم دو روزه جواب پیام‌هام رو نمی‌ده.',
          counselorName: 'مریم احمدی',
        ),
      ];

  @override
  Future<SentFeedback> submit({required FeedbackKind kind, required String body, String? counselorUserId}) async {
    if (fail) throw Exception('offline');
    submitted.add((kind, body, counselorUserId));
    return SentFeedback(id: 'new', createdAt: DateTime(2026, 11, 16), kind: kind, status: FeedbackStatus.open, body: body);
  }
}

Future<void> _shot(WidgetTester tester, String name) async {
  const dir = String.fromEnvironment('SHOT_DIR');
  if (dir.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  });
  File('$dir/$name.png').writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(loadAppFonts);

  Future<_FakeRepo> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 900 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final repo = _FakeRepo();
    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(child: FeedbackScreen(repository: repo)),
    ));
    await tester.pumpAndSettle();
    return repo;
  }

  testWidgets('a complaint can name a counselor and is sent trimmed', (tester) async {
    final repo = await pump(tester);
    expect(find.text('فرستاده‌هات'), findsOneWidget);
    expect(find.text('پیگیری شد'), findsOneWidget);
    // Counselor choice appears only for complaints.
    expect(find.text('درباره‌ی'), findsNothing);
    await _shot(tester, 'feedback-suggestion');

    await tester.tap(find.byKey(const ValueKey('feedback-kind-complaint')));
    await tester.pumpAndSettle();
    expect(find.text('درباره‌ی'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('feedback-about-c1')));
    await tester.enterText(find.byKey(const ValueKey('feedback-body')), '  جلسه‌ی این هفته برگزار نشد  ');
    await tester.pumpAndSettle();
    await _shot(tester, 'feedback-complaint');

    await tester.tap(find.byKey(const ValueKey('feedback-send')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(repo.submitted.single, (FeedbackKind.complaint, 'جلسه‌ی این هفته برگزار نشد', 'c1'));
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });

  testWidgets('a too short text is refused before sending', (tester) async {
    final repo = await pump(tester);
    await tester.enterText(find.byKey(const ValueKey('feedback-body')), 'بد');
    await tester.tap(find.byKey(const ValueKey('feedback-send')));
    await tester.pumpAndSettle();
    expect(find.text('یه کم بیشتر بنویس.'), findsOneWidget);
    expect(repo.submitted, isEmpty);
  });

  testWidgets('a suggestion never carries a counselor', (tester) async {
    final repo = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('feedback-kind-complaint')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('feedback-about-c1')));
    await tester.tap(find.byKey(const ValueKey('feedback-kind-suggestion')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const ValueKey('feedback-body')), 'یه حالت شب اضافه کنید');
    await tester.tap(find.byKey(const ValueKey('feedback-send')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(repo.submitted.single.$3, isNull);
    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
