import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/plan_sheets.dart';

import 'support/task_fixtures.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

/// Lets the title's tag request go out (after the typing pause) and land.
Future<void> _waitForSuggestions(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

/// Taps a sheet control that may sit below the fold of its scroll view.
Future<void> _tapInSheet(WidgetTester tester, String key) async {
  await tester.ensureVisible(_key(key));
  await tester.pumpAndSettle();
  await tester.tap(_key(key));
}

/// Pumps a button that opens a sheet through [open] when tapped.
Future<void> _pumpOpener(
  WidgetTester tester,
  Future<void> Function(BuildContext context) open,
) async {
  await tester.binding.setSurfaceSize(const Size(390, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
                onPressed: () => open(context), child: const Text('open')),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('quick add sheet', () {
    late List<QuickTaskDraft> drafts;
    late List<QuickTaskDraft> handedOver;

    Future<void> openQuickAdd(
      WidgetTester tester, {
      Jalali? day,
      bool timed = true,
      Future<List<String>> Function(String title)? suggest,
    }) {
      drafts = [];
      handedOver = [];
      return _pumpOpener(
        tester,
        (context) => showQuickAddSheet(
          context,
          initialDay: day ?? testToday,
          today: testToday,
          initialTimed: timed,
          suggestTags: suggest ?? (_) async => const ['ریاضی', 'فیزیک'],
          tagCatalog: const ['ریاضی', 'فیزیک', 'حسابان', 'حسابداری', 'زیست'],
          onSubmit: (draft) async {
            drafts.add(draft);
            return null;
          },
          onMoreOptions: handedOver.add,
        ),
      );
    }

    testWidgets('adds a timed task with a tag and stays open for the next',
        (tester) async {
      await openQuickAdd(tester);

      await tester.enterText(_key('quick-add-title'), 'تست فصل ۲');
      await _waitForSuggestions(tester);
      await tester.tap(_key('quick-add-type-timed'));
      await tester.pumpAndSettle();
      await tester.tap(_key('quick-add-minutes-60'));
      await _tapInSheet(tester, 'quick-add-tag-ریاضی'); // suggested, on: turn off
      await tester.tap(_key('week-day-chip-4'));
      await tester.pump();
      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();

      final draft = drafts.single;
      expect(draft.title, 'تست فصل ۲');
      expect(ymd(draft.day), [1405, 7, 22]);
      expect(draft.timedMinutes, 60);
      expect(draft.tags, ['فیزیک']);

      expect(_key('quick-add-sheet'), findsOneWidget);
      expect(tester.widget<TextField>(_key('quick-add-title')).controller!.text,
          isEmpty);
      expect(find.text('تست فصل ۲'), findsOneWidget); // listed as added
    });

    testWidgets('adds a 45-minute timed task; no tags before they are suggested',
        (tester) async {
      await openQuickAdd(tester);

      expect(find.text('تنظیمات پیشرفته'), findsOneWidget);
      await tester.enterText(_key('quick-add-title'), 'خرید کتاب');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(drafts.single.timedMinutes, 45);
      expect(drafts.single.tags, isEmpty);
      expect(ymd(drafts.single.day), [1405, 7, 20]);
    });

    testWidgets('offers up to two hours, and checklist tasks', (tester) async {
      await openQuickAdd(tester);

      await tester.tap(_key('quick-add-minutes-120'));
      await tester.enterText(_key('quick-add-title'), 'آزمون جامع');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      await tester.tap(_key('quick-add-type-checklist'));
      await tester.pumpAndSettle();
      await tester.enterText(_key('quick-add-title'), 'خرید کتاب');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      expect(drafts.map((draft) => draft.timedMinutes), [120, null]);
    });

    testWidgets('needs a title and cannot pick past days', (tester) async {
      await openQuickAdd(tester);

      await tester.tap(_key('quick-add-submit'));
      await tester.tap(_key('week-day-chip-0')); // Saturday, already past
      await tester.enterText(_key('quick-add-title'), 'مرور');
      await tester.pump();
      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();

      expect(drafts, hasLength(1));
      expect(ymd(drafts.single.day), [1405, 7, 20]);
    });

    testWidgets('browses to later weeks but not earlier ones', (tester) async {
      await openQuickAdd(tester);

      await tester.tap(_key('day-picker-prev'));
      await tester.pump();
      await tester.tap(_key('day-picker-next'));
      await tester.pumpAndSettle();
      await tester.tap(_key('week-day-chip-0'));
      await tester.enterText(_key('quick-add-title'), 'هفته بعد');
      await tester.pump();
      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();

      expect(ymd(drafts.single.day), [1405, 7, 25]);
    });

    testWidgets('advanced settings take over everything chosen so far',
        (tester) async {
      await openQuickAdd(tester, day: Jalali(1405, 7, 23));

      await tester.enterText(_key('quick-add-title'), 'پروژه');
      await _waitForSuggestions(tester);
      await tester.tap(_key('quick-add-minutes-90'));
      await _tapInSheet(tester, 'quick-add-tag-ریاضی'); // suggested, on: turn off
      await tester.pump();
      await tester.tap(_key('quick-add-more'));
      await tester.pumpAndSettle();

      expect(_key('quick-add-sheet'), findsNothing);
      final draft = handedOver.single;
      expect(ymd(draft.day), [1405, 7, 23]);
      expect(draft.title, 'پروژه');
      expect(draft.timedMinutes, 90);
      expect(draft.tags, ['فیزیک']);
    });

    testWidgets('offers the server\'s tags for the title, and custom tags',
        (tester) async {
      final asked = <String>[];
      await openQuickAdd(tester, suggest: (title) async {
        asked.add(title);
        return title.contains('هندسه')
            ? ['هندسه', 'ریاضی']
            : ['فیزیک', 'ریاضی'];
      });

      // No tags at all before a title.
      expect(_key('quick-add-tags-hint'), findsOneWidget);
      expect(_key('quick-add-tag-new'), findsNothing);

      await tester.enterText(_key('quick-add-title'), 'تمرین هندسه');
      await _waitForSuggestions(tester);
      expect(asked, ['تمرین هندسه']); // once, after typing pauses

      // Suggestions come selected; one is turned off, a custom one added.
      await _tapInSheet(tester, 'quick-add-tag-ریاضی');
      await _tapInSheet(tester, 'quick-add-tag-new');
      await tester.pumpAndSettle();
      await tester.enterText(_key('quick-add-tag-input'), 'فصل ۳');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // A new title asks again and selects its tags afresh; the custom tag
      // stays.
      await tester.enterText(_key('quick-add-title'), 'تمرین فیزیک');
      await _waitForSuggestions(tester);
      expect(asked, ['تمرین هندسه', 'تمرین فیزیک']);
      expect(_key('quick-add-tag-هندسه'), findsNothing);

      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();
      expect(drafts.single.tags, ['فیزیک', 'ریاضی', 'فصل ۳']);

      // The next task starts with no tags again.
      expect(_key('quick-add-tags-hint'), findsOneWidget);
    });

    testWidgets('typing a tag offers the known tags that match',
        (tester) async {
      await openQuickAdd(tester);
      await tester.enterText(_key('quick-add-title'), 'مرور');
      await _waitForSuggestions(tester);

      await _tapInSheet(tester, 'quick-add-tag-new');
      await tester.pumpAndSettle();
      await tester.enterText(_key('quick-add-tag-input'), 'حساب');
      await tester.pump();

      expect(_key('quick-add-tag-match-حسابان'), findsOneWidget);
      expect(_key('quick-add-tag-match-حسابداری'), findsOneWidget);
      expect(_key('quick-add-tag-match-زیست'), findsNothing);
      // Already picked (suggested) tags are not offered again.
      await tester.enterText(_key('quick-add-tag-input'), 'ریا');
      await tester.pump();
      expect(_key('quick-add-tag-match-ریاضی'), findsNothing);

      await tester.enterText(_key('quick-add-tag-input'), 'حساب');
      await tester.pump();
      await _tapInSheet(tester, 'quick-add-tag-match-حسابان');
      await tester.pumpAndSettle();
      expect(_key('quick-add-tag-input'), findsNothing);

      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();
      expect(drafts.single.tags, ['ریاضی', 'فیزیک', 'حسابان']);
    });
    testWidgets('a fixed typo keeps the tags the user turned off',
        (tester) async {
      await openQuickAdd(tester);

      await tester.enterText(_key('quick-add-title'), 'تمرن');
      await _waitForSuggestions(tester);
      await _tapInSheet(tester, 'quick-add-tag-ریاضی');
      await tester.enterText(_key('quick-add-title'), 'تمرین');
      await _waitForSuggestions(tester); // same tags come back

      await tester.tap(_key('quick-add-submit'));
      await tester.pumpAndSettle();
      expect(drafts.single.tags, ['فیزیک']);
    });

    testWidgets('timed comes first, and the sheet can start on checklist',
        (tester) async {
      await openQuickAdd(tester, timed: false);

      // RTL: the first option sits on the right.
      expect(
        tester.getCenter(_key('quick-add-type-timed')).dx,
        greaterThan(tester.getCenter(_key('quick-add-type-checklist')).dx),
      );
      expect(_key('quick-add-minutes-45'), findsNothing);
      await tester.enterText(_key('quick-add-title'), 'خرید کتاب');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(drafts.single.isTimed, isFalse);
    });
  });

  testWidgets('move sheet returns the picked day and ignores past ones',
      (tester) async {
    Jalali? picked;
    var closed = false;
    final task = buildTask(Jalali(1405, 7, 21), title: 'جابه‌جایی');
    await _pumpOpener(tester, (context) async {
      picked = await showMoveTaskSheet(context, task: task, today: testToday);
      closed = true;
    });

    expect(find.text('«جابه‌جایی»'), findsOneWidget);
    await tester.tap(_key('week-day-chip-0'));
    await tester.pumpAndSettle();
    expect(closed, isFalse);

    await tester.tap(_key('week-day-chip-5'));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(ymd(picked!), [1405, 7, 23]);
  });
}
