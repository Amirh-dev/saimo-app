import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/chat/advisor_widgets.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_repository.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

const _advisor = ActiveCounselor(
  userID: 'advisor-1',
  avatar: 'Assets.profilePlaceholder',
  name: 'علیرضا یوسفی',
  title: 'مشاور تحصیلی کنکور',
);

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.binding.setSurfaceSize(const Size(390, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(body: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('advisorSubscriptionLabel', () {
    final now = DateTime(2026, 10, 12, 15);

    test('names the end date while it is far away', () {
      expect(
        advisorSubscriptionLabel(DateTime(2026, 11, 15), now: now),
        'اشتراک فعال تا ۲۴ آبان ۱۴۰۵',
      );
    });

    test('counts the days in the last two weeks', () {
      expect(advisorSubscriptionLabel(DateTime(2026, 10, 20), now: now), '۸ روز تا پایان اشتراک');
      expect(advisorSubscriptionLabel(DateTime(2026, 10, 12, 23), now: now), 'امروز آخرین روز اشتراک است');
    });

    test('falls back to a plain label without an end date', () {
      expect(advisorSubscriptionLabel(null, now: now), 'اشتراک فعال');
    });

    test('flags a subscription that ends within a week', () {
      expect(advisorSubscriptionEndsSoon(DateTime(2026, 10, 18), now: now), isTrue);
      expect(advisorSubscriptionEndsSoon(DateTime(2026, 10, 30), now: now), isFalse);
      expect(advisorSubscriptionEndsSoon(null, now: now), isFalse);
    });
  });

  testWidgets('without an advisor, the chat explains itself and offers a choice',
      (tester) async {
    var chose = 0;
    await _pump(tester, AdvisorIntroView(onChoose: () => chose++));

    expect(find.text('گفتگو با مشاور'), findsOneWidget);
    await tester.tap(_key('advisor-choose'));
    expect(chose, 1);
  });

  testWidgets('an empty conversation offers starters that send themselves',
      (tester) async {
    final sent = <String>[];
    await _pump(tester, AdvisorWelcome(advisor: _advisor, onStarter: sent.add));

    expect(find.text('علیرضا یوسفی'), findsOneWidget);
    expect(find.text('مشاور تحصیلی کنکور'), findsOneWidget);

    await tester.tap(_key('advisor-starter-1'));
    expect(sent, [kAdvisorStarters[1]]);
  });

  testWidgets('the advisor sheet shows the subscription and other advisors',
      (tester) async {
    var browsed = 0;
    await _pump(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showAdvisorSheet(
            context,
            advisor: const ActiveCounselor(
              userID: 'advisor-1',
              avatar: 'Assets.profilePlaceholder',
              name: 'علیرضا یوسفی',
              title: 'مشاور تحصیلی کنکور',
              endDate: null,
            ),
            onBrowseAdvisors: () => browsed++,
          ),
          child: const Text('open'),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(_key('advisor-sheet'), findsOneWidget);
    expect(find.text('اشتراک فعال'), findsOneWidget);

    await tester.tap(_key('advisor-browse'));
    await tester.pumpAndSettle();
    expect(browsed, 1);
    expect(_key('advisor-sheet'), findsNothing);
  });
}
