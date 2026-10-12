import 'package:flutter/foundation.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:simo_learn/presentation/screens/tasks/task_mapping.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/screens/tasks/weekly/week_plan.dart';

/// State of the weekly overview: the shown week and its tasks. Checking a
/// task off happens here; other edits go through the task's details.
class WeeklyPlanController extends ChangeNotifier {
  WeeklyPlanController(this._api, {Jalali Function()? today})
      : _today = today ?? Jalali.now;

  final TasksApi _api;
  final Jalali Function() _today;

  Jalali? _weekStart;
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = false;
  bool _hasData = false;
  bool _loadFailed = false;
  int _loadRequest = 0;
  WeekPlan? _plan;

  Jalali get today => _today();
  Jalali get weekStart => _weekStart ?? weekStartOf(today);
  WeekPlan get plan =>
      _plan ??= WeekPlan.build(weekStart: weekStart, tasks: _tasks, today: today);
  List<Map<String, dynamic>> get tasks => List.unmodifiable(_tasks);

  bool get isLoading => _isLoading;
  bool get hasData => _hasData;

  /// Nothing to show because loading the week failed.
  bool get hasError => _loadFailed && !_hasData;

  /// Ids of tasks whose done state is being saved.
  final Set<String> _savingIds = {};

  bool isSaving(Map<String, dynamic> task) => _savingIds.contains(task['id']);

  /// Shows [tasks] on [day] at once, while the move is saved; the reload
  /// that follows the save settles where they really are.
  void showMoved(Iterable<Map<String, dynamic>> tasks, Jalali day) {
    final ids = {for (final task in tasks) task['id']};
    _tasks = [
      for (final item in _tasks)
        ids.contains(item['id']) ? {...item, 'date': day} : item,
    ];
    _plan = null;
    notifyListeners();
  }

  /// Marks [task] done, or back to do, showing the change at once. On failure
  /// the change is undone and the error rethrown for the caller to report.
  Future<void> setTaskDone(Map<String, dynamic> task, {required bool done}) async {
    final id = task['id'] as String?;
    if (id == null || isTaskDone(task) == done || _savingIds.contains(id)) return;

    void show(String status) {
      _tasks = [
        for (final item in _tasks)
          item['id'] == id ? {...item, 'status': status} : item,
      ];
      _plan = null;
      notifyListeners();
    }

    final previous = task['status'] as String? ?? 'pending';
    _savingIds.add(id);
    show(done ? 'done' : 'pending');
    try {
      await _api.setTaskDone(task, done: done);
    } catch (_) {
      show(previous);
      rethrow;
    } finally {
      _savingIds.remove(id);
    }
  }

  bool get isCurrentWeek => isSameJalaliDay(weekStart, weekStartOf(today));
  bool get canGoForward => isWeekWithinHorizon(weekStart.addDays(7), today);

  Future<void> showWeekOf(Jalali date) {
    final start = weekStartOf(date);
    if (_weekStart != null && isSameJalaliDay(start, _weekStart!)) {
      return reload(silent: _hasData);
    }
    _weekStart = start;
    _tasks = [];
    _hasData = false;
    _loadFailed = false;
    _plan = null;
    return reload();
  }

  /// Fetches the week again; [silent] keeps what is shown while it loads.
  Future<void> reload({bool silent = false}) async {
    final request = ++_loadRequest;
    final start = weekStart;
    if (!silent) {
      _isLoading = true;
      _loadFailed = false;
      notifyListeners();
    }

    try {
      final fetched = await _api.fetchSchedule(start: start, end: start.addDays(7));
      if (request != _loadRequest) return;
      _tasks = [...fetched];
      _hasData = true;
      _loadFailed = false;
    } catch (error) {
      if (request != _loadRequest) return;
      debugPrint('WeeklyPlanController: loading the week failed: $error');
      _loadFailed = true;
    } finally {
      if (request == _loadRequest) {
        _isLoading = false;
        _plan = null;
        notifyListeners();
      }
    }
  }
}
