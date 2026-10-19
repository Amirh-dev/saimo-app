import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_state.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

import 'support/dashboards.dart';

void main() {
  test('opens on the running week', () async {
    final repository =
        FakeStatisticsRepository((_, __) async => dashboard(studySeconds: 60));
    final cubit = StatisticsCubit(repository);
    await cubit.load();

    expect(cubit.state.status, StatisticsStatus.success);
    expect(cubit.state.range.period, StatisticsPeriod.week);
    expect(cubit.state.range.isCurrent, isTrue);
    expect(cubit.state.loadedRange, cubit.state.range);
    expect(repository.requests, hasLength(1));
  });

  test('keeps the old numbers on screen while the next week loads', () async {
    final pending = Completer<StatisticsDashboard>();
    var calls = 0;
    final cubit = StatisticsCubit(FakeStatisticsRepository((_, __) {
      calls++;
      return calls == 1 ? Future.value(dashboard(studySeconds: 60)) : pending.future;
    }));
    await cubit.load();

    final going = cubit.shift(-1);
    expect(cubit.state.isLoading, isTrue);
    expect(cubit.state.isStale, isTrue);
    expect(cubit.state.dashboard!.comparison.current.studySeconds, 60);
    expect(cubit.state.direction, -1);

    pending.complete(dashboard(studySeconds: 120));
    await going;
    expect(cubit.state.isStale, isFalse);
    expect(cubit.state.dashboard!.comparison.current.studySeconds, 120);
  });

  test('a late answer for a week already left is dropped', () async {
    final answers = <Completer<StatisticsDashboard>>[];
    final cubit = StatisticsCubit(FakeStatisticsRepository((_, __) {
      final answer = Completer<StatisticsDashboard>();
      answers.add(answer);
      return answer.future;
    }));
    final first = cubit.load();
    final second = cubit.shift(-1);
    final third = cubit.shift(-1);

    // The newest answers first, then the stale ones.
    answers[2].complete(dashboard(studySeconds: 3));
    await third;
    answers[1].complete(dashboard(studySeconds: 2));
    answers[0].complete(dashboard(studySeconds: 1));
    await Future.wait([first, second]);

    expect(cubit.state.dashboard!.comparison.current.studySeconds, 3);
    expect(cubit.state.loadedRange, cubit.state.range);
    expect(cubit.state.range.first,
        StatisticsRange.forPeriod(StatisticsPeriod.week).shift(-2).first);
  });

  test('a single day also fetches its week for the charts', () async {
    final repository = FakeStatisticsRepository(
      (start, end) async => dashboard(
        studySeconds: end.difference(start).inDays > 1 ? 7 : 1,
      ),
    );
    final cubit = StatisticsCubit(repository);
    await cubit.selectPeriod(StatisticsPeriod.today);

    expect(repository.requests, hasLength(2));
    expect(cubit.state.dashboard!.comparison.current.studySeconds, 1);
    expect(cubit.state.chartDashboard!.comparison.current.studySeconds,
        anyOf(1, 7), reason: 'a Saturday is its own week so far');
  });

  test('cannot step past the running range', () async {
    final repository =
        FakeStatisticsRepository((_, __) async => dashboard());
    final cubit = StatisticsCubit(repository);
    await cubit.load();
    await cubit.shift(1);
    expect(repository.requests, hasLength(1));
  });

  test('a failed first load fails; a failed quiet refresh keeps the numbers',
      () async {
    var fail = true;
    final cubit = StatisticsCubit(FakeStatisticsRepository((_, __) async {
      if (fail) throw const StatisticsFailure('boom');
      return dashboard(studySeconds: 5);
    }));
    await cubit.load();
    expect(cubit.state.isFailure, isTrue);
    expect(cubit.state.hasData, isFalse);

    fail = false;
    await cubit.retry();
    expect(cubit.state.status, StatisticsStatus.success);

    fail = true;
    await cubit.refresh(quiet: true);
    expect(cubit.state.status, StatisticsStatus.success);
    expect(cubit.state.dashboard!.comparison.current.studySeconds, 5);

    await cubit.refresh();
    expect(cubit.state.isFailure, isTrue);
    expect(cubit.state.hasData, isTrue, reason: 'kept, with a toast');
  });
}
