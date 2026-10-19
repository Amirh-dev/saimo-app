import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/dashboard/home_layout.dart';

DashboardTaskItem _item(
  String title, {
  int done = 0,
  int max = 60,
  bool isDone = false,
  bool isRunning = false,
}) =>
    DashboardTaskItem(
      id: title,
      title: title,
      percentage: isDone ? 100 : done * 100 / max,
      doneDuration: isDone ? max : done,
      maxDuration: max,
      durationText: '$max',
      elapsedSeconds: done * 60,
      isDone: isDone,
      isRunning: isRunning,
    );

void main() {
  group('suggestedTaskIndex', () {
    test('a running timer comes first', () {
      expect(
        suggestedTaskIndex([
          _item('paused', done: 50),
          _item('idle'),
          _item('running', done: 5, isRunning: true),
        ]),
        2,
      );
    });

    test('else the paused task with the least left', () {
      expect(
        suggestedTaskIndex([
          _item('done', isDone: true),
          _item('physics', done: 25, max: 60),
          _item('biology', done: 100, max: 120),
          _item('idle'),
        ]),
        2,
      );
    });

    test('else the first not started, and none once all are done', () {
      expect(suggestedTaskIndex([_item('done', isDone: true), _item('a')]), 1);
      expect(suggestedTaskIndex([_item('done', isDone: true)]), isNull);
      expect(suggestedTaskIndex(const []), isNull);
    });
  });

  group('todaySlots', () {
    List<String> kinds(List<TodaySlot> slots) => [
          for (final slot in slots)
            switch (slot.kind) {
              TodaySlotKind.task => 't${slot.index}',
              TodaySlotKind.more => '+${slot.more}',
              TodaySlotKind.add => 'add',
              TodaySlotKind.ghost => 'ghost',
              TodaySlotKind.blank => '-',
            },
        ];

    test('an empty day shows one add column among ghosts', () {
      expect(kinds(todaySlots(0)),
          ['add', 'ghost', 'ghost', 'ghost', 'ghost', 'ghost', 'ghost']);
    });

    test('a short day ends in an add column', () {
      expect(kinds(todaySlots(5)), ['t0', 't1', 't2', 't3', 't4', 'add', '-']);
      expect(kinds(todaySlots(7)), ['t0', 't1', 't2', 't3', 't4', 't5', 't6']);
    });

    test('a long day keeps the suggested task in sight', () {
      expect(kinds(todaySlots(10, suggested: 2)),
          ['t0', 't1', 't2', 't3', 't4', 't5', '+4']);
      expect(kinds(todaySlots(10, suggested: 8)),
          ['t0', 't1', 't2', 't3', 't4', 't8', '+4']);
    });
  });

  test('orderHomeGoals: pinned first, else the nearest deadline ahead', () {
    final today = DateTime(2026, 10, 19);
    final goals = [
      const DashboardGoal(id: 'none', title: 'none'),
      DashboardGoal(id: 'late', title: 'late', targetDate: DateTime(2026, 10, 1)),
      DashboardGoal(id: 'far', title: 'far', targetDate: DateTime(2027, 6, 1)),
      DashboardGoal(id: 'near', title: 'near', targetDate: DateTime(2026, 11, 1)),
    ];
    List<String> ids(List<DashboardGoal> goals) => [for (final g in goals) g.id];

    expect(ids(orderHomeGoals(goals, pinnedId: 'far', today: today)),
        ['far', 'late', 'near', 'none']);
    // The overdue goal is not the main one.
    expect(ids(orderHomeGoals(goals, today: today)),
        ['near', 'late', 'far', 'none']);
  });

  test('DashboardConsistency reads the server answer', () {
    final consistency = DashboardConsistency.fromJson({
      'level': 4,
      'maxLevel': 5,
      'countedToday': true,
      'plannedSeconds': 6000,
      'progressSeconds': 6000,
      'studiedSeconds': 5700,
      'minStudySeconds': 5400,
      'targetPercentage': 90,
      'remainingSeconds': 61,
      'fraction': 1.2,
    });
    expect(consistency.level, 4);
    expect(consistency.countedToday, isTrue);
    expect(consistency.hasPlan, isTrue);
    expect(consistency.targetPercentage, 90);
    expect(consistency.remainingMinutes, 2);
    expect(consistency.fraction, 1);
  });
}
