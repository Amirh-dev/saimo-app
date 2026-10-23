import 'package:flutter_test/flutter_test.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';

// Monday 20 Mehr 1405 (2026-10-12); its week runs Sat 18 Mehr .. Fri 24 Mehr.
final _today = Jalali(1405, 7, 20);
final _weekStart = Jalali(1405, 7, 18);

int _taskCounter = 0;

/// A task exactly as the screens receive it: an API payload run through the
/// real mapping.
Map<String, dynamic> _task(
  Jalali day, {
  int? timedMinutes,
  bool done = false,
  String status = 'TODO',
  String? subject,
  String? recurrenceId,
}) {
  _taskCounter += 1;
  return plannedTaskFromApi({
    'id': 'task-$_taskCounter',
    'title': 'تسک $_taskCounter',
    'shortDescription': null,
    'note': null,
    'type': timedMinutes == null ? 'NORMAL' : 'TIMED',
    'date': day.toDateTime().toUtc().toIso8601String(),
    'durationM': timedMinutes,
    'hasReminder': false,
    'reminderTime': null,
    'recurringDays': null,
    'recurrenceID': recurrenceId,
    'elapsedSeconds': 0,
    'timerStartedAt': null,
    'status': done ? 'COMPLETED' : status,
    'goal': null,
    'tags': subject == null
            ? const []
            : [
                // The server groups a task under its approved tag's parent.
                {
                  'id': 't-$subject',
                  'name': 'مبحث $subject',
                  'moderationStatus': 'APPROVED',
                  'parent': {'id': 's-$subject', 'name': subject},
                },
              ],
  });
}

List<int> _ymd(Jalali date) => [date.year, date.month, date.day];

void main() {
  group('weekStartOf', () {
    test('returns the Saturday that opens the week', () {
      expect(_ymd(weekStartOf(Jalali(1405, 7, 20))), [1405, 7, 18]); // Mon
      expect(_ymd(weekStartOf(Jalali(1405, 7, 18))), [1405, 7, 18]); // Sat
      expect(_ymd(weekStartOf(Jalali(1405, 7, 24))), [1405, 7, 18]); // Fri
    });

    test('drops the time of day', () {
      final start = weekStartOf(Jalali(1405, 7, 20, 14, 30));
      expect([start.hour, start.minute], [0, 0]);
    });

    test('crosses month boundaries', () {
      expect(_ymd(weekStartOf(Jalali(1405, 7, 30))), [1405, 7, 25]); // Thu
      expect(_ymd(weekStartOf(Jalali(1405, 8, 1))), [1405, 7, 25]); // Fri
    });
  });

  test('lastPlannableDay is the Friday of the last week within the horizon',
      () {
    // The 11th week ahead runs 5..11 Dey; the 12th (from 12 Dey) is out of range.
    expect(_ymd(lastPlannableDay(_today)), [1405, 10, 11]);
    expect(isWeekWithinHorizon(weekStartOf(lastPlannableDay(_today)), _today),
        isTrue);
    expect(
      isWeekWithinHorizon(
          weekStartOf(lastPlannableDay(_today).addDays(1)), _today),
      isFalse,
    );
  });

  test('isWeekWithinHorizon allows 11 weeks ahead but not the 12th', () {
    expect(isWeekWithinHorizon(_weekStart, _today), isTrue);
    expect(isWeekWithinHorizon(_weekStart.addDays(77), _today), isTrue);
    expect(isWeekWithinHorizon(_weekStart.addDays(84), _today), isFalse);
    expect(isWeekWithinHorizon(_weekStart.addDays(-70), _today), isTrue);
  });

  group('WeekPlan.build', () {
    test('groups the week by day and ignores tasks outside it', () {
      final plan = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [
          _task(Jalali(1405, 7, 18), done: true),
          _task(Jalali(1405, 7, 18), timedMinutes: 60),
          _task(Jalali(1405, 7, 20), timedMinutes: 45, done: true),
          _task(Jalali(1405, 7, 20)),
          _task(Jalali(1405, 7, 25), timedMinutes: 90), // next Saturday
        ],
      );

      expect(plan.days, hasLength(7));
      expect(_ymd(plan.days.first.date), [1405, 7, 18]);
      expect(_ymd(plan.days.last.date), [1405, 7, 24]);

      final saturday = plan.days[0];
      expect(saturday.taskCount, 2);
      expect(saturday.doneCount, 1);
      expect(saturday.plannedMinutes, 60);
      expect(saturday.loadMinutes, 80); // 60 timed + 20 for the checklist
      expect(saturday.isPast, isTrue);

      final monday = plan.days[2];
      expect(monday.isToday, isTrue);
      expect(monday.isPast, isFalse);
      expect(monday.doneLoadMinutes, 45);
      expect(monday.loadMinutes, 65);

      expect(plan.days[3].isEmpty, isTrue);
      expect(plan.taskCount, 4);
      expect(plan.doneCount, 2);
      expect(plan.plannedMinutes, 105);
      expect(plan.maxDayLoad, 80);
    });

    test('an empty week reports no tasks', () {
      final plan =
          WeekPlan.build(weekStart: _weekStart, today: _today, tasks: const []);
      expect(plan.isEmpty, isTrue);
      expect(plan.doneRatio, 0);
      expect(plan.hasSubjects, isFalse);
    });

    test('flags an upcoming day much heavier than the rest', () {
      final plan = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [
          _task(Jalali(1405, 7, 20), timedMinutes: 60),
          _task(Jalali(1405, 7, 21), timedMinutes: 180),
          _task(Jalali(1405, 7, 21), timedMinutes: 120),
          _task(Jalali(1405, 7, 22), timedMinutes: 60),
        ],
      );

      expect(plan.days[3].isHeavy, isTrue); // Tuesday: 300 vs 60 on average
      expect(plan.days[2].isHeavy, isFalse);
      expect(plan.days[4].isHeavy, isFalse);
    });

    test('does not flag balanced weeks, single busy days or past days', () {
      final balanced = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [
          _task(Jalali(1405, 7, 20), timedMinutes: 200),
          _task(Jalali(1405, 7, 21), timedMinutes: 210),
          _task(Jalali(1405, 7, 22), timedMinutes: 230),
        ],
      );
      expect(balanced.days.where((day) => day.isHeavy), isEmpty);

      final single = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [_task(Jalali(1405, 7, 21), timedMinutes: 400)],
      );
      expect(single.days.where((day) => day.isHeavy), isEmpty);

      final pastHeavy = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [
          _task(Jalali(1405, 7, 18), timedMinutes: 400),
          _task(Jalali(1405, 7, 21), timedMinutes: 60),
        ],
      );
      expect(pastHeavy.days[0].isHeavy, isFalse);
    });

    test('shares load across the top four subjects and groups the rest', () {
      final plan = WeekPlan.build(
        weekStart: _weekStart,
        today: _today,
        tasks: [
          _task(Jalali(1405, 7, 20), timedMinutes: 120, subject: 'ریاضی'),
          _task(Jalali(1405, 7, 21), timedMinutes: 60, subject: 'فیزیک'),
          _task(Jalali(1405, 7, 21), subject: 'شیمی'),
          _task(Jalali(1405, 7, 22), subject: 'زیست'),
          _task(Jalali(1405, 7, 22), subject: 'ادبیات'),
          _task(Jalali(1405, 7, 23)),
        ],
      );

      expect(plan.hasSubjects, isTrue);
      expect(
        [for (final share in plan.subjects) (share.name, share.loadMinutes)],
        [
          ('ریاضی', 120),
          ('فیزیک', 60),
          ('ادبیات', 20),
          ('زیست', 20),
          (null, 40), // شیمی and the task without a subject
        ],
      );
    });
  });

  group('labels', () {
    test('weekRangeLabel names the month once when the week stays in it', () {
      expect(
          weekRangeLabel(Jalali(1405, 7, 18), today: _today), '۱۸ تا ۲۴ مهر');
      expect(weekRangeLabel(Jalali(1405, 7, 25), today: _today),
          '۲۵ مهر تا ۱ آبان');
    });

    test('weekRangeLabel adds the year outside the current year', () {
      expect(
        weekRangeLabel(Jalali(1406, 1, 7), today: _today),
        '۷ تا ۱۳ فروردین ۱۴۰۶',
      );
      expect(
        weekRangeLabel(Jalali(1405, 12, 29), today: _today),
        '۲۹ اسفند ۱۴۰۵ تا ۶ فروردین ۱۴۰۶',
      );
    });

    test('relativeWeekLabel counts whole weeks from the current one', () {
      expect(relativeWeekLabel(_weekStart, _today), 'این هفته');
      expect(relativeWeekLabel(_weekStart.addDays(7), _today), 'هفته بعد');
      expect(relativeWeekLabel(_weekStart.addDays(-7), _today), 'هفته قبل');
      expect(relativeWeekLabel(_weekStart.addDays(21), _today), '۳ هفته بعد');
      expect(relativeWeekLabel(_weekStart.addDays(-14), _today), '۲ هفته قبل');
    });

    test('dayLabel names the weekday and date', () {
      expect(dayLabel(Jalali(1405, 7, 20)), 'دوشنبه ۲۰ مهر');
      expect(dayLabel(Jalali(1405, 7, 24)), 'جمعه ۲۴ مهر');
    });

    test('formatDuration reads naturally in Persian', () {
      expect(formatDuration(45), '۴۵ دقیقه');
      expect(formatDuration(120), '۲ ساعت');
      expect(formatDuration(105), '۱ ساعت و ۴۵ دقیقه');
    });

    test('formatClock writes hours and minutes', () {
      expect(formatClock(105), '۱:۴۵');
      expect(formatClock(45), '۰:۴۵');
      expect(formatClock(120), '۲:۰۰');
    });

    test('formatHours rounds to the nearest half hour', () {
      expect(formatHours(810), '۱۳٫۵');
      expect(formatHours(780), '۱۳');
      expect(formatHours(95), '۱٫۵');
    });
  });
}
