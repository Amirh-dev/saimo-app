import 'dart:io';
import 'dart:ui' as ui;

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/support/support_link.dart';
import 'package:simo_learn/presentation/screens/consultants/list_screen.dart';

import '../tasks/support/app_fonts.dart';

/// Answers support queries from [answers]; a missing query throws, like a
/// server that predates it.
class _SupportGraphQL extends GraphQLRepository {
  _SupportGraphQL(TokenStorage storage, this.answers)
      : super(
          Client(
            link: Link.function(
              (request, [forward]) => const Stream<Response>.empty(),
            ),
          ),
          tokenStorage: storage,
          logger:
              GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
        );

  final Map<String, Object?> answers;
  final List<bool> requiresAuthSeen = [];

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    requiresAuthSeen.add(requiresAuth);
    for (final key in const ['supportContacts', 'supportLink']) {
      if (query.contains(key)) {
        if (!answers.containsKey(key)) break;
        return {key: answers[key]};
      }
    }
    if (!query.contains('support') && answers.containsKey('counselors')) {
      return Map<String, dynamic>.from(answers);
    }
    throw const GraphQLRawException('Cannot query field');
  }
}

Future<_SupportGraphQL> _graphql(Map<String, Object?> answers) async {
  SharedPreferences.setMockInitialValues({});
  return _SupportGraphQL(await TokenStorage.create(), answers);
}

void main() {
  group('fetchSupportContacts', () {
    test('reads both usernames without logging in', () async {
      final graphql = await _graphql({
        'supportContacts': {'telegram': 'SaimoSupport', 'bale': '@SaimoBale'},
      });
      final contacts = await fetchSupportContacts(graphql);
      expect(contacts.telegram, 'SaimoSupport');
      expect(contacts.bale, 'SaimoBale');
      expect(graphql.requiresAuthSeen, everyElement(isFalse));
    });

    test('only Bale set hides Telegram', () async {
      final contacts = await fetchSupportContacts(await _graphql({
        'supportContacts': {'telegram': null, 'bale': 'SaimoBale'},
      }));
      expect(contacts.telegram, isNull);
      expect(contacts.bale, 'SaimoBale');
    });

    test('nothing set falls back to the official Telegram', () async {
      final contacts = await fetchSupportContacts(await _graphql({
        'supportContacts': {'telegram': null, 'bale': null},
      }));
      expect(contacts.telegram, kDefaultSupportTelegram);
      expect(contacts.bale, isNull);
    });

    test('an older server answers through its t.me support link', () async {
      final contacts = await fetchSupportContacts(await _graphql({
        'supportLink': 'https://t.me/old_support',
      }));
      expect(contacts.telegram, 'old_support');
      expect(contacts.bale, isNull);
    });
  });

  test('telegramFromLink reads only single-name t.me links', () {
    expect(telegramFromLink('https://t.me/SaimoSupport'), 'SaimoSupport');
    expect(telegramFromLink('https://www.telegram.me/abc_de'), 'abc_de');
    expect(telegramFromLink('https://wa.me/989121234567'), isNull);
    expect(telegramFromLink('https://t.me/c/123/4'), isNull);
    expect(telegramFromLink(null), isNull);
  });

  test('messenger links', () {
    expect(SupportMessenger.telegram.link('SaimoSupport').toString(),
        'https://t.me/SaimoSupport');
    expect(SupportMessenger.bale.link('SaimoBale').toString(),
        'https://ble.ir/SaimoBale');
  });

  testWidgets('the sheet lists only the messengers that are set',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SupportSheet(
          load: () async => const SupportContacts(bale: 'SaimoBale'),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    expect(find.text('بله'), findsOneWidget);
    expect(find.text('تلگرام'), findsNothing);
  });

  final shotDir = Platform.environment['SCREENSHOT_DIR'];
  group('screenshots', skip: shotDir == null, () {
    Future<void> shoot(WidgetTester tester, String name) async {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('shot')),
      );
      final bytes = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        return data!.buffer.asUint8List();
      });
      File('$shotDir/$name.png').writeAsBytesSync(bytes!);
    }

    testWidgets('counselor list and support sheet', (tester) async {
      await tester.runAsync(loadAppFonts);
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final graphql = await tester.runAsync(() => _graphql({
            'supportContacts': {'telegram': 'SaimoSupport', 'bale': 'SaimoBale'},
            'counselors': [
              for (final (name, title, rating) in [
                ('سارا احمدی', 'مشاور تحصیلی کنکور ریاضی', 4.8),
                ('علی محمدی', 'مشاور تحصیلی', 4.5),
                ('مریم کریمی', 'مشاور کنکور و برنامه‌ریز', 0.0),
                ('رضا نوری', 'مشاور کنکور ریاضی', 4.7),
                ('نگار صالحی', 'مشاور تحصیلی', 4.6),
                ('حسین رضایی', 'مشاور کنکور', 0.0),
              ])
                {
                  'id': name,
                  'title': title,
                  'ratingAverage': rating,
                  'ratingCount': rating > 0 ? 12 : 0,
                  'resumeItems': ['ده سال سابقه'],
                  'user': {'fullName': name},
                },
            ],
            'getMe': {'major': null},
          }));
      await tester.pumpWidget(
        RepositoryProvider<GraphQLRepository>.value(
          value: graphql!,
          child: MaterialApp(
            builder: (context, child) =>
                RepaintBoundary(key: const ValueKey('shot'), child: child),
            home: const ConsultantListScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await shoot(tester, 'list');

      final gesture =
          await tester.startGesture(tester.getCenter(find.byType(ListView)));
      await gesture.moveBy(const Offset(0, -260));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await shoot(tester, 'list_scrolling');
      await gesture.up();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('counselor-support')));
      await tester.pumpAndSettle();
      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
      await tester.pumpAndSettle();
      await shoot(tester, 'sheet');
    });
  });
}
