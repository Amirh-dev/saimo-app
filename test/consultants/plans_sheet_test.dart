import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/consultants/plans_sheet.dart';

import '../tasks/support/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<Future<ConsultationChoice?>> openSheet(
    WidgetTester tester, {
    List<ConsultationPlan>? plans,
  }) async {
    tester.view.physicalSize = const Size(390 * 3, 900 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    late Future<ConsultationChoice?> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => result = showPlansSheet(
                context,
                counselorName: 'علیرضا یوسفی',
                plans: plans,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('starts on the recommended plan for six months', (tester) async {
    final result = await openSheet(tester);

    expect(find.text('ادامه با پلن حرفه‌ای'), findsOneWidget);
    // Only the selected plan lists what it gives.
    expect(find.text('تحلیل آزمون‌های آزمایشی'), findsOneWidget);
    expect(find.text('برنامه هفتگی شخصی با متد سایمو'), findsNothing);

    await tester.tap(find.text('ادامه با پلن حرفه‌ای'));
    await tester.pumpAndSettle();

    final choice = await result;
    expect(choice!.plan.planType, 'PROFESSIONAL');
    expect(choice.months, 6);
    expect(choice.price.total, 8280000);
    expect(choice.hasGift, isFalse);
  });

  testWidgets('returns the picked plan and duration', (tester) async {
    final result = await openSheet(tester);

    await tester.tap(find.text('پلن پایه'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('۳ ماه'));
    await tester.pumpAndSettle();

    expect(find.text('برنامه هفتگی شخصی با متد سایمو'), findsOneWidget);
    await tester.tap(find.text('ادامه با پلن پایه'));
    await tester.pumpAndSettle();

    final choice = await result;
    expect(choice!.plan.planType, 'NORMAL');
    expect(choice.months, 3);
  });

  testWidgets('the gift banner switches to a year', (tester) async {
    final result = await openSheet(tester);

    await tester.tap(find.textContaining('ثبت‌نام ۱ ساله:'));
    await tester.pumpAndSettle();
    expect(find.textContaining('هدیه ۱ ساله'), findsOneWidget);

    await tester.tap(find.text('ادامه با پلن حرفه‌ای'));
    await tester.pumpAndSettle();

    final choice = await result;
    expect(choice!.months, 12);
    expect(choice.hasGift, isTrue);
  });

  testWidgets('offers only the durations the plans are priced for',
      (tester) async {
    const price = PlanPrice(
      months: 3,
      total: 3000000,
      baseTotal: 3000000,
      discountPercent: 0,
    );
    final plans = [
      kPlans[0].withPrices({3: price}),
      kPlans[1].withPrices({
        3: price,
        6: const PlanPrice(
          months: 6,
          total: 5400000,
          baseTotal: 6000000,
          discountPercent: 10,
        ),
      }),
    ];
    await openSheet(tester, plans: plans);

    expect(find.text('۳ ماه'), findsOneWidget);
    expect(find.text('۶ ماه'), findsOneWidget);
    expect(find.text('۱ سال'), findsNothing);
    // No yearly offer, so no yearly gift to promise.
    expect(find.textContaining('ثبت‌نام ۱ ساله'), findsNothing);
    expect(find.text('پلن پیشرفته'), findsNothing);
  });
}
