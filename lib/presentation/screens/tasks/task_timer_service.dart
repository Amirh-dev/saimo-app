import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';

/// A single, app-wide owner of the running task timer.
///
/// It owns:
///  - which task is currently loaded ([activeTaskId])
///  - the tick loop ([Timer.periodic])
///  - the remaining / elapsed values
///
/// Screens never own the timer and never call setState from inside a tick.
/// They just listen to this object and rebuild.
class TaskTimerService extends ChangeNotifier {
  TaskTimerService._();

  static final TaskTimerService instance = TaskTimerService._();

  TaskTimerRepository? _repository;
  Timer? _ticker;

  String? _taskId;
  int _totalSeconds = 0;

  /// Seconds already spent on this task *before* the current session.
  int _baseElapsedSeconds = 0;

  /// When the current session started. `null` means the timer is paused.
  ///
  /// We anchor on a wall-clock time instead of counting ticks, so the value
  /// stays correct even if ticks are dropped (app backgrounded, heavy frame,
  /// device sleeping).
  DateTime? _sessionStartedAt;

  bool _isCompleted = false;

  /// The raw task map the timer was loaded from. Kept so the floating banner
  /// can reopen the timer screen, and so we can write progress back into the
  /// list row that the task came from.
  Map<String, dynamic>? _taskData;

  /// True while [TaskTimerScreen] is on top. The floating banner hides itself
  /// in that case, because the full timer UI is already visible.
  bool _isTimerScreenOpen = false;

  /// Set when the user taps the X on the floating banner. Reset whenever a
  /// new task is loaded or started.
  bool _bannerDismissed = false;

  // ---------------------------------------------------------------- getters

  String? get activeTaskId => _taskId;

  bool get isRunning => _sessionStartedAt != null;

  bool get isCompleted => _isCompleted;

  int get totalSeconds => _totalSeconds;

  int get _rawSessionSeconds {
    final startedAt = _sessionStartedAt;
    if (startedAt == null) return 0;
    return DateTime.now().difference(startedAt).inSeconds;
  }

  /// Seconds of the current (uncommitted) session, capped so it can never
  /// overshoot the total duration.
  int get currentSessionSeconds {
    final room = math.max(0, _totalSeconds - _baseElapsedSeconds);
    return math.min(room, _rawSessionSeconds);
  }

  /// Seconds committed before the current session (the solid arc).
  int get solidSeconds => _baseElapsedSeconds.clamp(0, _totalSeconds);

  int get elapsedSeconds => solidSeconds + currentSessionSeconds;

  int get remainingSeconds => math.max(0, _totalSeconds - elapsedSeconds);

  /// True when [taskId] is the task this service currently holds.
  bool isActive(String? taskId) => taskId != null && taskId == _taskId;

  /// True when [taskId] is loaded *and* actually ticking.
  bool isRunningTask(String? taskId) => isActive(taskId) && isRunning;

  bool get hasActiveTask => _taskId != null;

  Map<String, dynamic>? get taskData => _taskData;

  String get taskTitle => (_taskData?['title'] as String?) ?? '';

  bool get isTimerScreenOpen => _isTimerScreenOpen;

  /// Whether the floating timer banner should be on screen right now.
  bool get shouldShowBanner =>
      hasActiveTask && !_isCompleted && !_isTimerScreenOpen && !_bannerDismissed;

  double get progress {
    if (_totalSeconds <= 0) return 0;
    return (elapsedSeconds / _totalSeconds).clamp(0.0, 1.0);
  }

  // ------------------------------------------------------------------ setup

  /// Give the service a repository so it can talk to the API on its own
  /// (it needs this for the auto-complete when the timer reaches zero).
  /// Safe to call from every screen's initState.
  void bindRepository(TaskTimerRepository repository) {
    _repository = repository;
  }

  /// Load a task into the service.
  ///
  /// If the same task is already running, this is a no-op: we must not reset
  /// a live session with stale numbers coming back from the server.
  void load({
    required String taskId,
    required int totalSeconds,
    required int elapsedSeconds,
    bool isDone = false,
    Map<String, dynamic>? taskData,
  }) {
    if (_taskId == taskId && isRunning) {
      // Same task, still ticking: never reset a live session. Just refresh
      // the map reference in case the list rebuilt its rows.
      if (taskData != null) _taskData = taskData;
      return;
    }

    // Switching to a different task while one is running: the previous task
    // must be paused, both in the UI and on the server.
    if (isRunning && _taskId != null && _taskId != taskId) {
      final previousId = _taskId!;
      _commitSession();
      _stopTicker();
      _writeBackToTaskData(status: 'paused');
      unawaited(_pauseOnServer(previousId));
    }

    _stopTicker();

    _taskId = taskId;
    _taskData = taskData;
    _totalSeconds = totalSeconds <= 0 ? 1 : totalSeconds;
    _baseElapsedSeconds = elapsedSeconds.clamp(0, _totalSeconds);
    _sessionStartedAt = null;
    _isCompleted = isDone || _baseElapsedSeconds >= _totalSeconds;
    _bannerDismissed = false;

    _notifySafely();
  }

  // ------------------------------------------------------- screen / banner

  void timerScreenOpened() {
    if (_isTimerScreenOpen) return;
    _isTimerScreenOpen = true;
    _notifySafely();
  }

  void timerScreenClosed() {
    if (!_isTimerScreenOpen) return;
    _isTimerScreenOpen = false;
    _notifySafely();
  }

  /// Hide the floating banner without losing the session.
  void dismissBanner() {
    _bannerDismissed = true;
    _notifySafely();
  }

  // ---------------------------------------------------------------- actions

  Future<void> start() async {
    final id = _taskId;
    if (id == null || isRunning || _isCompleted || remainingSeconds <= 0) return;

    _sessionStartedAt = DateTime.now();
    _bannerDismissed = false;
    _startTicker();
    _writeBackToTaskData(status: 'running');
    _notifySafely();

    try {
      await _repository?.startTimedTask(id);
    } catch (error) {
      debugPrint('TaskTimerService.start failed: $error');
    }
  }

  Future<void> pause() async {
    final id = _taskId;
    if (id == null || !isRunning) return;

    _commitSession();
    _stopTicker();
    _writeBackToTaskData(status: 'paused');
    _notifySafely();

    try {
      await _repository?.pauseTimedTask(id);
    } catch (error) {
      debugPrint('TaskTimerService.pause failed: $error');
    }
  }

  Future<void> complete() async {
    final id = _taskId;
    if (id == null) return;

    _commitSession();
    _stopTicker();
    _isCompleted = true;
    _writeBackToTaskData(status: 'done');
    _notifySafely();

    try {
      await _repository?.completeTimedTask(id);
    } catch (error) {
      debugPrint('TaskTimerService.complete failed: $error');
    }
  }

  /// Forget the current task entirely (e.g. after a successful refresh where
  /// the server already reports the task as done).
  void clear() {
    _stopTicker();
    _taskId = null;
    _totalSeconds = 0;
    _baseElapsedSeconds = 0;
    _sessionStartedAt = null;
    _isCompleted = false;
    _taskData = null;
    _bannerDismissed = false;
    _notifySafely();
  }

  // --------------------------------------------------------------- internal

  /// Notifying while Flutter is in the middle of a build would make any
  /// listener that calls setState throw "setState() called during build".
  /// This happens for real: TaskTimerScreen.initState() -> load() -> notify,
  /// while TasksScreen is still building. So when we are inside the build
  /// phase, we wait for the frame to finish first.
  void _notifySafely() {
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback((_) => notifyListeners());
      return;
    }
    notifyListeners();
  }

  Future<void> _pauseOnServer(String taskId) async {
    try {
      await _repository?.pauseTimedTask(taskId);
    } catch (error) {
      debugPrint('TaskTimerService pause (switch) failed: $error');
    }
  }

  /// Push the current numbers back into the task map the list is rendering,
  /// so a row stays correct even after the service moves on to another task.
  void _writeBackToTaskData({required String status}) {
    final data = _taskData;
    if (data == null) return;
    data['status'] = status;
    data['elapsedSeconds'] = elapsedSeconds;
    data['remainingSeconds'] = remainingSeconds;
  }

  void _commitSession() {
    _baseElapsedSeconds = elapsedSeconds;
    _sessionStartedAt = null;
  }

  void _startTicker() {
    _ticker ??= Timer.periodic(const Duration(seconds: 1), (_) => _onTick());
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }

  void _onTick() {
    if (remainingSeconds <= 0) {
      // Time is up: auto-complete. complete() stops the ticker and notifies.
      complete();
      return;
    }
    notifyListeners();
    // (a tick never happens during build, so a plain notify is fine here)
  }

  @override
  void dispose() {
    // The singleton lives for the whole app; nothing should dispose it.
    _stopTicker();
    super.dispose();
  }
}