import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_date_picker.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_widgets.dart';

import 'support/task_fixtures.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

void main() {
  group('RollingNumber', () {
    Future<void> pumpNumber(WidgetTester tester, int value) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: RollingNumber(value: value, fontSize: 18)),
          ),
        ),
      );
    }

    double strip(WidgetTester tester, int position) => tester
        .getTopLeft(find.descendant(
          of: _key('rolling-digit-$position'),
          matching: find.byType(Column),
        ))
        .dy;

    testWidgets('each digit rolls in its own place to the new value',
        (tester) async {
      await pumpNumber(tester, 20);
      final top = tester.getTopLeft(_key('rolling-digit-0')).dy;
      final height = tester.getSize(_key('rolling-digit-0')).height;
      expect(strip(tester, 0), closeTo(top, 0.5));

      await pumpNumber(tester, 23);
      await tester.pump(const Duration(milliseconds: 150));
      final midway = strip(tester, 0);
      expect(midway, lessThan(top));
      expect(midway, greaterThan(top - 3 * height));
      // The tens digit stays where it was.
      expect(strip(tester, 1), closeTo(top - 2 * height, 0.5));

      await tester.pumpAndSettle();
      expect(strip(tester, 0), closeTo(top - 3 * height, 0.5));
    });
  });

  group('plan date picker', () {
    Future<List<Jalali?>> openPicker(
      WidgetTester tester, {
      required Jalali initial,
      Jalali? lastDate,
    }) async {
      final results = <Jalali?>[];
      await tester.binding.setSurfaceSize(const Size(390, 844));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () async => results.add(
                    await showPlanDatePicker(
                      context,
                      initialDate: initial,
                      today: testToday,
                      lastDate: lastDate,
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return results;
    }

    testWidgets('opens on the selected month, marking the day and today',
        (tester) async {
      await openPicker(tester, initial: Jalali(1405, 7, 23));

      expect(
        find.descendant(
            of: _key('calendar-month-title'), matching: find.text('مهر')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: _key('calendar-day-23'), matching: _key('calendar-selected')),
        findsOneWidget,
      );
      expect(
        find.descendant(
            of: _key('calendar-day-20'), matching: _key('calendar-today-dot')),
        findsOneWidget,
      );
    });

    testWidgets('tapping a day picks it', (tester) async {
      final results = await openPicker(tester, initial: Jalali(1405, 7, 23));

      await tester.tap(_key('calendar-day-27'));
      await tester.pumpAndSettle();

      expect(ymd(results.single!), [1405, 7, 27]);
    });

    testWidgets('browses months with the arrows and by swiping',
        (tester) async {
      await openPicker(tester, initial: Jalali(1405, 7, 23));

      await tester.tap(_key('calendar-next'));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
            of: _key('calendar-month-title'), matching: find.text('آبان')),
        findsOneWidget,
      );

      // Later months sit to the left, so dragging left goes back.
      await tester.drag(_key('calendar-pages'), const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
            of: _key('calendar-month-title'), matching: find.text('مهر')),
        findsOneWidget,
      );
    });

    testWidgets('days after the last date cannot be picked', (tester) async {
      final results = await openPicker(
        tester,
        initial: Jalali(1405, 7, 20),
        lastDate: Jalali(1405, 7, 24),
      );

      await tester.tap(_key('calendar-day-27'));
      await tester.pumpAndSettle();

      expect(results, isEmpty);
      expect(_key('calendar-sheet'), findsOneWidget);
    });

    testWidgets('«امروز» picks today', (tester) async {
      final results = await openPicker(tester, initial: Jalali(1405, 8, 5));

      expect(
          find.descendant(
              of: _key('calendar-today'), matching: find.text('برو به امروز')),
          findsOneWidget);
      await tester.tap(_key('calendar-today'));
      await tester.pumpAndSettle();

      expect(ymd(results.single!), [1405, 7, 20]);
    });
  });
}
