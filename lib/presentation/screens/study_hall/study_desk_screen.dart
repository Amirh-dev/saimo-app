import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/study_hall/hall_avatar.dart';
import 'package:simo_learn/features/study_hall/hall_avatar_store.dart';
import 'package:simo_learn/features/study_hall/hall_sounds.dart';
import 'package:simo_learn/features/study_hall/study_hall_api.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/presentation/screens/study_hall/avatar_builder_screen.dart';
import 'package:simo_learn/presentation/screens/study_hall/desk_sheets.dart';
import 'package:simo_learn/presentation/screens/study_hall/desk_tasks_sheet.dart';
import 'package:simo_learn/presentation/screens/study_hall/study_hall_screen.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_repository.dart';
import 'package:simo_learn/presentation/screens/tasks/task_timer_service.dart';
import 'package:simo_learn/presentation/screens/tasks/tasks_api.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/presentation/widgets/re_toast.dart';
import 'package:simo_learn/utils/colors.dart';

const _batterySaverKey = 'hall_battery_saver';
const _breakLength = Duration(minutes: 5);
const _dayBg = Color(0xFFF4EFE8);

/// Day between 06:00 and 18:00 Tehran: the window shows the sun then.
bool hallIsDay(DateTime now) {
  final t = now.toUtc().add(const Duration(hours: 3, minutes: 30));
  return t.hour >= 6 && t.hour < 18;
}

/// «میز کار من», the timer screen (design-previews/study-hall/desk.html).
/// You sit at a desk in front of your window; the things on the desk are the
/// tools: the books are today's tasks, the headphones the sounds (they go on
/// your head while a sound plays), the tea glass a five-minute break and the
/// plant your daily streak. Tap yourself for your look and the items your
/// best day unlocked. Under the desk: the timer with the way to the next
/// سالن, then how many are studying in your building (tap: the building).
/// Opening plays a short camera move from the building into your window;
/// battery saver (header) turns every animation off.
class StudyDeskScreen extends StatefulWidget {
  const StudyDeskScreen({
    super.key,
    required this.task,
    required this.onPop,
    this.mixer,
    this.avatar,
    this.timer,
    this.hallRepository,
    this.tasksApi,
    this.clock,
  });

  final Map<String, dynamic> task;
  final VoidCallback onPop;
  final HallSoundMixer? mixer;

  /// Tests pin a character; the app uses the saved one.
  final HallAvatar? avatar;

  /// Tests pass their own services.
  final TaskTimerService? timer;
  final StudyHallRepository? hallRepository;
  final TasksApi? tasksApi;
  final DateTime Function()? clock;

  @override
  State<StudyDeskScreen> createState() => _StudyDeskScreenState();
}

enum _Stage { ready, running, paused, done }

class _StudyDeskScreenState extends State<StudyDeskScreen> with TickerProviderStateMixin {
  late final TaskTimerService _timer = widget.timer ?? TaskTimerService.instance;
  late final HallSoundMixer _mixer = widget.mixer ?? HallSoundMixer.shared;
  late final StudyHallRepository? _hallRepo = widget.hallRepository ?? _read(StudyHallRepository.new);
  late final TasksApi? _tasksApi = widget.tasksApi ?? _read(GraphQLTasksApi.new);
  final _store = HallAvatarStore.instance;
  late final AnimationController _camera = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));
  late final AnimationController _fx = AnimationController(vsync: this, duration: const Duration(seconds: 2));

  /// The rain's own 60-second clock (see _RainPainter).
  late final AnimationController _rain = AnimationController(vsync: this, duration: const Duration(seconds: 60));

  late Map<String, dynamic> _task = widget.task;
  bool _busy = false;
  bool _saver = false;
  StudyHall? _hall = StudyHallRepository.cached;
  Timer? _hallRefresh, _breakTick, _bannerTimer;

  // Today's study = what the server said + what the timer added since.
  int _todayBase = 0, _elapsedMark = 0;
  int? _shownFloor;
  DateTime? _breakEnds;
  String? _banner, _bannerSub;

  T? _read<T>(T Function(GraphQLRepository) make) {
    try {
      return make(context.read<GraphQLRepository>());
    } catch (_) {
      return null;
    }
  }

  DateTime _now() => (widget.clock ?? DateTime.now)();
  HallAvatar get _avatar => widget.avatar ?? _store.avatar;

  @override
  void initState() {
    super.initState();
    if (widget.timer == null) {
      _timer.bindRepository(TaskTimerRepository(context.read<GraphQLRepository>()));
    }
    _loadTask(_task);
    _timer.timerScreenOpened();
    _timer.addListener(_onTimer);
    _markHall(_hall);
    _mixer.restore(play: true);
    _store.load();
    _start();
    _loadHall();
    _hallRefresh = Timer.periodic(const Duration(minutes: 1), (_) => _loadHall());
  }

  void _loadTask(Map<String, dynamic> task) {
    _timer.load(
      taskId: task['id'] as String,
      totalSeconds: task['durationSeconds'] as int? ?? 2700,
      elapsedSeconds: task['elapsedSeconds'] as int? ?? 0,
      isDone: task['status'] == 'done',
      taskData: task,
    );
  }

  void _markHall(StudyHall? hall) {
    if (hall == null) return;
    _todayBase = hall.todaySeconds;
    _elapsedMark = _timer.elapsedSeconds;
    _shownFloor ??= hall.floorFor(_today);
  }

  int get _today {
    final hall = _hall;
    if (hall == null) return 0;
    return (_todayBase + math.max(0, _timer.elapsedSeconds - _elapsedMark)).clamp(0, hall.capSeconds).toInt();
  }

  Future<void> _loadHall() async {
    final repo = _hallRepo;
    if (repo == null) return;
    try {
      final hall = await repo.load();
      if (!mounted) return;
      setState(() {
        _hall = hall;
        _markHall(hall);
      });
      _onTimer();
      unawaited(_store.syncWith(hall.myAvatar, repo.saveAvatar));
    } catch (_) {
      // The desk works without the hall; its parts just stay hidden.
    }
  }

  /// A new سالن while you study: a short banner (and the plant drinks).
  void _onTimer() {
    final hall = _hall;
    if (hall == null || !mounted) return;
    final floor = hall.floorFor(_today);
    final before = _shownFloor;
    _shownFloor = floor;
    if (before == null || floor <= before) return;
    final f = hall.floors[floor];
    _bannerTimer?.cancel();
    setState(() {
      _banner = f.isRoof ? 'رسیدی پشت‌بوم!' : 'رفتی ${hallFloorName(f)}!';
      _bannerSub = floor == 1 ? 'گلدونت امروز آب خورد' : 'یه برگ دیگه به گلدونت اضافه شد';
    });
    HapticFeedback.mediumImpact();
    _bannerTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) setState(() => _banner = null);
    });
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    _saver = prefs.getBool(_batterySaverKey) ?? false;
    final reduce = MediaQuery.disableAnimationsOf(context);
    setState(() {});
    if (_saver || reduce) {
      _camera.value = 1;
    } else {
      _camera.forward();
      _fx.repeat();
      _rain.repeat();
    }
  }

  @override
  void dispose() {
    _timer.removeListener(_onTimer);
    _timer.timerScreenClosed();
    _hallRefresh?.cancel();
    _breakTick?.cancel();
    _bannerTimer?.cancel();
    _camera.dispose();
    _fx.dispose();
    _rain.dispose();
    super.dispose();
  }

  Future<void> _toggleSaver() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _saver = !_saver);
    await prefs.setBool(_batterySaverKey, _saver);
    if (_saver) {
      _fx.stop();
      _rain.stop();
      _camera.value = 1;
    } else {
      _fx.repeat();
      _rain.repeat();
    }
    if (mounted) {
      showReToast(context, _saver ? 'حالت کم‌مصرف روشن شد؛ صحنه ساکن می‌مونه.' : 'حالت کم‌مصرف خاموش شد.', ReToastType.info);
    }
  }

  _Stage get _stage {
    if (_timer.isCompleted) return _Stage.done;
    if (_timer.isRunning) return _Stage.running;
    return _timer.elapsedSeconds > 0 ? _Stage.paused : _Stage.ready;
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      HapticFeedback.mediumImpact();
      if (_timer.isRunning) {
        await _timer.pause();
      } else {
        final started = await _timer.start();
        if (!started && !_timer.isCompleted && mounted) {
          showReToast(context, 'شروع تایمر ناموفق بود. دوباره امتحان کن.', ReToastType.failed);
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ------------------------------------------------------------ desk things

  Future<void> _openTasks() async {
    final api = _tasksApi;
    if (api == null) return;
    final picked = await showDeskTasksSheet(context, api: api, currentId: _task['id'] as String?, onPlan: _goPlan);
    if (picked == null || !mounted || picked['id'] == _task['id']) return;
    final wasRunning = _timer.isRunning;
    if (wasRunning) await _timer.pause();
    final today = _today;
    setState(() => _task = picked);
    _loadTask(picked);
    _todayBase = today;
    _elapsedMark = _timer.elapsedSeconds;
    if (wasRunning) await _timer.start();
    if (mounted) showReToast(context, 'الان: ${picked['title'] ?? ''}', ReToastType.info);
  }

  /// Adding and planning tasks happens on the tasks tab.
  void _goPlan() {
    if (!AppTabsShell.select(context, AppTabsShell.tasks)) Navigator.of(context).maybePop();
  }

  Future<void> _openBreak() async {
    if (_breakEnds != null) return;
    final go = await showDeskBreakSheet(context);
    if (go != true || !mounted) return;
    if (_timer.isRunning) await _timer.pause();
    setState(() => _breakEnds = _now().add(_breakLength));
    _breakTick?.cancel();
    _breakTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (!_now().isBefore(_breakEnds!)) {
        _endBreak();
      } else {
        setState(() {});
      }
    });
  }

  Future<void> _endBreak() async {
    _breakTick?.cancel();
    setState(() => _breakEnds = null);
    if (!_timer.isCompleted && !_timer.isRunning) await _toggle();
    if (mounted) showReToast(context, 'برگشتی سر درس', ReToastType.info);
  }

  HallPlant? get _plant {
    final hall = _hall;
    return hall == null ? null : HallPlant.of(hall, _today);
  }

  void _openPlant() {
    final hall = _hall, plant = _plant;
    if (hall == null || plant == null) {
      showReToast(context, 'گلدون وقتی ساختمون باز شد پیدا می‌شه.', ReToastType.info);
      return;
    }
    showDeskPlantSheet(context, plant: plant, hall: hall, todaySeconds: _today);
  }

  void _openLook() {
    showDeskLookSheet(
      context,
      avatar: _avatar,
      bestDaySeconds: math.max(_hall?.bestDaySeconds ?? 0, _today),
      onWear: _saveAvatar,
      onBuilder: _openBuilder,
    );
  }

  Future<void> _openBuilder() async {
    final next = await Navigator.of(context).push<HallAvatar>(
      MaterialPageRoute(builder: (_) => AvatarBuilderScreen(initial: _avatar)),
    );
    if (next == null) return;
    await _saveAvatar(next.copyWith(reward: _avatar.reward));
    if (mounted) showReToast(context, 'ظاهرت ذخیره شد.', ReToastType.success);
  }

  Future<void> _saveAvatar(HallAvatar next) async {
    await _store.save(next);
    try {
      await _hallRepo?.saveAvatar(next);
    } catch (_) {
      // Kept on the phone; sent up again next time the hall loads.
    }
  }

  void _openBuilding() {
    final page = StudyHallScreen(avatar: _avatar, repository: _hallRepo);
    if (_saver || MediaQuery.disableAnimationsOf(context)) {
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
      return;
    }
    // The camera pulls back out of your window to the whole building.
    Navigator.of(context).push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 650),
      reverseTransitionDuration: const Duration(milliseconds: 450),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, a, __, child) {
        final curve = CurvedAnimation(parent: a, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: const Interval(0, .55)),
          child: ScaleTransition(
            scale: Tween(begin: 2.6, end: 1.0).animate(curve),
            alignment: const Alignment(0, .1),
            child: child,
          ),
        );
      },
    ));
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final day = hallIsDay(_now());
    return PopScope(
      onPopInvokedWithResult: (_, __) => widget.onPop(),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: day ? _dayBg : hallNight,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: ListenableBuilder(
                  listenable: Listenable.merge([_timer, _mixer, _store]),
                  builder: (context, _) => _body(context, day),
                ),
              ),
              Positioned(
                top: MediaQuery.paddingOf(context).top + 150,
                left: 24,
                right: 24,
                child: IgnorePointer(
                  child: AnimatedScale(
                    scale: _banner == null ? .7 : 1,
                    duration: const Duration(milliseconds: 380),
                    curve: Curves.easeOutBack,
                    child: AnimatedOpacity(
                      opacity: _banner == null ? 0 : 1,
                      duration: const Duration(milliseconds: 260),
                      child: Center(
                        child: Container(
                          key: const ValueKey('desk-banner'),
                          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: const [BoxShadow(color: Color(0x88F14922), blurRadius: 50)],
                          ),
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            ReText(_banner ?? '', fontSize: 20, fontWeight: 1000, color: Colors.white),
                            ReText(_bannerSub ?? '', fontSize: 12, fontWeight: 800, color: Colors.white),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _camera,
                builder: (context, _) => _camera.value >= 1
                    ? const SizedBox.shrink()
                    : Positioned.fill(
                        child: GestureDetector(
                          key: const ValueKey('desk-camera'),
                          onTap: () => _camera.value = 1,
                          child: _CameraIntro(t: _camera.value, avatar: _avatar),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, bool day) {
    final fg = day ? AppColors.black1 : Colors.white;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Row(
            children: [
              _Round(
                key: const ValueKey('desk-back'),
                day: day,
                onTap: () => Navigator.of(context).maybePop(),
                child: Icon(Icons.chevron_left_rounded, color: fg, size: 26),
              ),
              Expanded(child: ReText('میز کار من', fontSize: 17, fontWeight: 1000, color: fg, textAlign: TextAlign.center)),
              _Round(
                key: const ValueKey('desk-saver'),
                day: day,
                onTap: _toggleSaver,
                color: _saver ? AppColors.success : null,
                child: Icon(Icons.battery_saver_rounded, color: _saver ? Colors.white : fg, size: 20),
              ),
              const SizedBox(width: 8),
              _Round(
                key: const ValueKey('desk-building'),
                day: day,
                onTap: _openBuilding,
                child: Icon(Icons.apartment_rounded, color: fg, size: 20),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(builder: (context, box) {
            final sceneH = math.min(box.maxWidth * 372 / 390, math.max(210.0, box.maxHeight - 316));
            return Column(
              children: [
                SizedBox(height: sceneH, width: double.infinity, child: _scene(day)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + MediaQuery.paddingOf(context).bottom),
                    child: Column(children: [_card(day), const SizedBox(height: 12), _hallCard(day)]),
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  bool _on(String id) => _mixer.isOn(hallSounds.firstWhere((s) => s.id == id));

  Widget _scene(bool day) {
    final rain = _on('rain') || _on('thunder');
    final sound = _mixer.onCount > 0;
    final me = _avatar;
    // The headphones go on your head while a sound plays.
    final worn = sound && me.reward != 'goldphones' ? me.copyWith(accessories: {...me.accessories, 'headphones'}) : me;
    final phonesOnHead = sound || me.reward == 'goldphones' || me.accessories.contains('headphones') || me.accessories.contains('catphones');
    final plant = _plant;
    final onBreak = _breakEnds != null;
    const tasksLabel = 'تسک‌ها';
    final wall = day ? const [Color(0xFFF1E3CF), Color(0xFFE6D2B6)] : const [Color(0xFF22203A), Color(0xFF2C2740)];
    Widget label(double x, String text) => Positioned(
          left: x - 45,
          width: 90,
          top: 322,
          child: IgnorePointer(
            child: ReText(text, fontSize: 10.5, fontWeight: 800, color: const Color(0xFFC9A88A), textAlign: TextAlign.center),
          ),
        );
    Widget tap(String key, Rect r, VoidCallback onTap) => Positioned.fromRect(
          rect: r,
          child: GestureDetector(key: ValueKey('desk-obj-$key'), behavior: HitTestBehavior.opaque, onTap: onTap),
        );
    return Container(
      decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: wall)),
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 390,
          height: 372,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: SvgPicture.string(_roomSvg(day: day, rain: rain), fit: BoxFit.fill)),
              if (rain)
                Positioned(
                  left: 98,
                  top: 22,
                  width: 194,
                  height: 170,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _rain,
                      // Battery saver: one still frame, no lightning.
                      builder: (_, __) => CustomPaint(
                          painter: _RainPainter(_saver ? 13 : _rain.value * _RainPainter.loop, day, thunder: _on('thunder') && !_saver)),
                    ),
                  ),
                ),
              // The mirror on the wall changes your look.
              const Positioned(
                left: 8,
                width: 82,
                top: 118,
                child: IgnorePointer(
                  child: ReText('تغییر ظاهر', fontSize: 10.5, fontWeight: 800, color: Color(0xFFC9A88A), textAlign: TextAlign.center),
                ),
              ),
              tap('mirror', const Rect.fromLTWH(14, 40, 70, 96), _openLook),
              // You, behind the desk (tap for your look).
              Positioned(
                left: 118.2,
                top: 68.7,
                width: 153.6,
                height: 220.2,
                child: GestureDetector(
                  key: const ValueKey('desk-me'),
                  onTap: _openLook,
                  child: AnimatedBuilder(
                    animation: _fx,
                    builder: (_, child) => Transform.translate(
                      offset: Offset(0, _saver ? 0 : math.sin(_fx.value * 2 * math.pi) * 1.4),
                      child: child,
                    ),
                    child: SvgPicture.string(hallAvatarSvg(worn), fit: BoxFit.fill),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: SvgPicture.string(
                    _deskSvg(day: day, phonesOnDesk: !phonesOnHead, plant: plant, thirsty: plant != null && !plant.wateredToday),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              if (!_saver)
                Positioned(
                  left: 262,
                  top: 238,
                  width: 30,
                  height: 34,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _fx,
                      builder: (_, __) => CustomPaint(painter: _SteamPainter(_fx.value, day)),
                    ),
                  ),
                ),
              label(60, tasksLabel),
              label(136, 'صدا'),
              label(276, 'استراحت'),
              label(345, 'گلدون'),
              tap('tasks', const Rect.fromLTWH(26, 250, 72, 92), _openTasks),
              tap('sound', const Rect.fromLTWH(104, 262, 64, 80), () => showDeskSoundSheet(context, _mixer)),
              tap('break', const Rect.fromLTWH(248, 240, 56, 102), _openBreak),
              tap('plant', const Rect.fromLTWH(318, 212, 58, 130), _openPlant),
              if (onBreak) ...[
                Positioned.fill(child: IgnorePointer(child: Container(color: Colors.black.withAlpha(107)))),
                Positioned(
                  left: 135,
                  width: 120,
                  top: 338,
                  height: 28,
                  child: IgnorePointer(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(100)),
                      child: const ReText('وقت چای', fontSize: 12, fontWeight: 900, color: Colors.white),
                    ),
                  ),
                ),
              ],
              if (_saver) Positioned.fill(child: IgnorePointer(child: Container(color: const Color(0xFF05060F).withAlpha(day ? 50 : 100)))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(bool day) {
    final fg = day ? AppColors.black1 : Colors.white;
    final muted = day ? const Color(0xFF6B6B73) : const Color(0xFFB9BBCB);
    final stage = _stage;
    final hall = _hall;
    final breakLeft = _breakEnds == null ? null : math.max(0, _breakEnds!.difference(_now()).inSeconds);
    final title = '${_task['title'] ?? ''}';
    final subject = (_task['subject'] as String?)?.trim();

    String big;
    double progress;
    Widget lineStart;
    String lineEnd;
    if (breakLeft != null) {
      big = '${(breakLeft ~/ 60).toString().padLeft(2, '0')}:${(breakLeft % 60).toString().padLeft(2, '0')}';
      progress = 1 - breakLeft / _breakLength.inSeconds;
      lineStart = ReText('استراحت، تایمر درس متوقفه', fontSize: 11.5, fontWeight: 900, color: fg);
      lineEnd = '';
    } else {
      big = _clock(_timer.elapsedSeconds);
      if (hall != null) {
        final today = _today, f = hall.floorFor(today), floor = hall.floors[f];
        final lo = floor.fromMinutes * 60;
        final hi = f + 1 < hall.floors.length ? hall.floors[f + 1].fromMinutes * 60 : null;
        progress = hi == null ? 1 : ((today - lo) / (hi - lo)).clamp(0.0, 1.0);
        lineStart = Row(mainAxisSize: MainAxisSize.min, children: [
          ReText(hallFloorName(floor), key: const ValueKey('desk-floor'), fontSize: 11.5, fontWeight: 1000, color: fg),
          ReText('، امروز ${hallClock(today)}', fontSize: 11.5, fontWeight: 800, color: muted),
        ]);
        lineEnd = hi == null
            ? (floor.isRoof ? 'از این ساختمون جلو زدی!' : 'بالاترین سالن')
            : '${((hi - today) / 60).ceil()} دقیقه تا ${hallFloorName(hall.floors[f + 1])}';
      } else {
        progress = _timer.progress.clamp(0.0, 1.0);
        lineStart = ReText('از ${_timer.totalSeconds ~/ 60} دقیقه', fontSize: 11.5, fontWeight: 800, color: muted);
        lineEnd = '';
      }
    }

    Widget button(String text, {required Key key, required VoidCallback? onTap, bool main = true}) => Expanded(
          child: SizedBox(
            height: 50,
            child: FilledButton(
              key: key,
              onPressed: onTap,
              style: FilledButton.styleFrom(
                backgroundColor: main ? AppColors.primary : (day ? AppColors.black1 : Colors.white.withAlpha(26)),
                disabledBackgroundColor: day ? AppColors.gray2 : Colors.white.withAlpha(12),
                shape: const StadiumBorder(),
              ),
              child: ReText(text, fontSize: 15, fontWeight: 1000, color: Colors.white),
            ),
          ),
        );
    final buttons = <Widget>[
      if (breakLeft != null)
        button('برگرد سر درس', key: const ValueKey('desk-break-end'), onTap: _endBreak)
      else if (stage == _Stage.done)
        button('تسک بعدی', key: const ValueKey('desk-next-task'), onTap: _openTasks)
      else
        // One button: «شروع» in the main colour, «توقف» in a quiet one.
        button(
          stage == _Stage.running ? 'توقف' : 'شروع',
          key: const ValueKey('desk-toggle'),
          onTap: _busy ? null : _toggle,
          main: stage != _Stage.running,
        ),
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: breakLeft != null ? (day ? const Color(0xFFF1EAE2) : const Color(0xFF2B2A2A)) : (day ? Colors.white : const Color(0xFF1F2238)),
        borderRadius: BorderRadius.circular(26),
        boxShadow: day ? const [BoxShadow(color: Color(0x146B4A2A), blurRadius: 24, offset: Offset(0, 6))] : null,
      ),
      child: Column(
        children: [
          InkWell(
            key: const ValueKey('desk-task'),
            onTap: _openTasks,
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 16, color: muted),
                const SizedBox(width: 8),
                Expanded(
                  child: ReText(subject == null || subject.isEmpty ? title : '$subject، $title',
                      fontSize: 12.5, fontWeight: 800, color: muted, maxLines: 1, textAlign: TextAlign.right),
                ),
                ReText('تسک‌ها', fontSize: 11, fontWeight: 800, color: day ? AppColors.gray : const Color(0xFF8B8FB8)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ReText(big, key: const ValueKey('desk-clock'), fontSize: 44, fontWeight: 1000, color: fg, textAlign: TextAlign.center),
          if (stage == _Stage.done && breakLeft == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: ReText('این تسک تموم شد', key: ValueKey('desk-stage'), fontSize: 12.5, fontWeight: 900, color: AppColors.success),
            ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress),
              duration: const Duration(milliseconds: 500),
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: day ? AppColors.gray2 : Colors.white.withAlpha(20),
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(children: [
            lineStart,
            const Spacer(),
            ReText(lineEnd, key: const ValueKey('desk-next'), fontSize: 11.5, fontWeight: 800, color: muted),
          ]),
          const SizedBox(height: 14),
          Row(children: buttons),
        ],
      ),
    );
  }

  Widget _hallCard(bool day) {
    final hall = _hall;
    if (hall == null) return const SizedBox.shrink();
    final fg = day ? AppColors.black1 : Colors.white;
    final f = hall.floors[hall.floorFor(_today)];
    final live = hall.floors.fold<int>(0, (a, x) => a + x.studyingNow);
    final others = math.max(0, f.people - 1);
    return Material(
      color: day ? Colors.white : const Color(0xFF1A1D31),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        key: const ValueKey('desk-people'),
        borderRadius: BorderRadius.circular(22),
        onTap: _openBuilding,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              if (hall.neighbors.isNotEmpty) ...[
                SizedBox(
                  width: 34.0 + 25 * (math.min(4, hall.neighbors.length) - 1),
                  height: 34,
                  child: Stack(children: [
                    for (var i = 0; i < math.min(4, hall.neighbors.length); i++)
                      PositionedDirectional(
                        start: i * 25.0,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(11),
                            gradient: const LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFE7B0), Color(0xFFFFC566)]),
                            border: Border.all(color: day ? Colors.white : const Color(0xFF1A1D31), width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: SvgPicture.string(
                              hallAvatarSvg(hall.neighbors[i].avatar ?? HallAvatar.fallback, viewBox: '-62 -172 124 150'),
                              alignment: Alignment.bottomCenter),
                        ),
                      ),
                  ]),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ReText('$live نفر در ساختمان در حال مطالعه هستند',
                            key: const ValueKey('desk-studying-now'),
                            fontSize: 12.5,
                            fontWeight: 900,
                            color: fg,
                            maxLines: 2,
                            textAlign: TextAlign.right),
                      ),
                    ]),
                    const SizedBox(height: 2),
                    ReText(
                      others == 0 ? 'فعلاً تنهایی توی ${hallFloorName(f)}' : '$others نفر دیگه امروز توی ${hallFloorName(f)} هستن',
                      fontSize: 11,
                      fontWeight: 700,
                      color: day ? AppColors.gray : const Color(0xFF8B8FB8),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: day ? AppColors.gray : const Color(0xFF8B8FB8)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Round extends StatelessWidget {
  const _Round({super.key, required this.onTap, required this.child, required this.day, this.color});
  final VoidCallback onTap;
  final Widget child;
  final bool day;
  final Color? color;

  @override
  Widget build(BuildContext context) => Material(
        color: color ?? (day ? AppColors.black1.withAlpha(14) : Colors.white.withAlpha(20)),
        shape: const CircleBorder(),
        child:
            InkWell(customBorder: const CircleBorder(), onTap: onTap, child: SizedBox(width: 40, height: 40, child: Center(child: child))),
      );
}

String _clock(int s) {
  final h = s ~/ 3600, m = (s % 3600) ~/ 60, sec = s % 60;
  final mm = m.toString().padLeft(2, '0'), ss = sec.toString().padLeft(2, '0');
  return h > 0 ? '$h:$mm:$ss' : '$mm:$ss';
}

// ------------------------------------------------------------------- scene

/// Wall, window (night city or day sky) and the shelf; 390 × 372.
String _roomSvg({required bool day, required bool rain}) {
  final wall = day ? ('#F1E3CF', '#E6D2B6') : ('#22203A', '#2C2740');
  final sky = day ? (rain ? ('#9FAABB', '#C9D0DA') : ('#7FBCEB', '#CFEAFB')) : ('#0E1030', '#2A2C5C');
  final frame = day ? '#A97B55' : '#4A3A2E';
  final g = StringBuffer('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 372">'
      '<defs><linearGradient id="w" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${wall.$1}"/><stop offset="1" stop-color="${wall.$2}"/></linearGradient>'
      '<linearGradient id="s" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${sky.$1}"/><stop offset="1" stop-color="${sky.$2}"/></linearGradient>'
      '<clipPath id="c"><rect x="98" y="22" width="194" height="170" rx="8"/></clipPath></defs>'
      '<rect width="390" height="372" fill="url(#w)"/>'
      '<rect x="90" y="14" width="210" height="186" rx="14" fill="$frame"/>'
      '<g clip-path="url(#c)"><rect x="98" y="22" width="194" height="170" fill="url(#s)"/>');
  if (day) {
    if (!rain) g.write('<circle cx="252" cy="56" r="26" fill="#FFE27A" opacity=".25"/><circle cx="252" cy="56" r="16" fill="#FFE27A"/>');
    final o = rain ? .5 : .9;
    g.write('<ellipse cx="150" cy="60" rx="26" ry="10" fill="#fff" opacity="$o"/><ellipse cx="166" cy="54" rx="16" ry="10" fill="#fff" opacity="$o"/>'
        '<ellipse cx="236" cy="96" rx="20" ry="7" fill="#fff" opacity="$o"/>');
  } else {
    g.write('<circle cx="252" cy="54" r="13" fill="#F4EBD0"/><circle cx="258" cy="50" r="12" fill="#1A1C42"/>');
    for (final (x, y) in const [(118, 42), (146, 34), (204, 48), (226, 32), (176, 60), (276, 84)]) {
      g.write('<circle cx="$x" cy="$y" r="1.3" fill="#fff" opacity=".8"/>');
    }
  }
  const blocks = [(98, 116, 34), (134, 92, 30), (166, 128, 40), (208, 104, 28), (238, 136, 26), (266, 112, 30)];
  for (var i = 0; i < blocks.length; i++) {
    final (x, y, w) = blocks[i];
    final c = day ? (i.isOdd ? '#AEB9CC' : '#C2CCDB') : (i.isOdd ? '#1B1D3D' : '#202247');
    g.write('<rect x="$x" y="$y" width="$w" height="${192 - y}" fill="$c"/>');
    for (var yy = y + 8; yy < 186; yy += 12) {
      for (var xx = x + 5; xx < x + w - 5; xx += 9) {
        if ((xx * 7 + yy * 13) % 5 < 2) {
          g.write('<rect x="$xx" y="$yy" width="4" height="5" rx="1" fill="${day ? '#E8EEF6' : '#FFC566'}" opacity=".85"/>');
        }
      }
    }
  }
  if (rain) g.write('<rect x="98" y="22" width="194" height="170" fill="#9FB4FF" opacity=".07"/>');
  g.write('</g><path d="M195 22 V192 M98 108 H292" stroke="$frame" stroke-width="6"/>'
      '<rect x="84" y="196" width="222" height="10" rx="4" fill="${day ? '#9A6E4A' : '#5A4636'}"/>');
  // A mirror (your look) and a shelf of books.
  final shelf = day ? '#9A6E4A' : '#5A4636';
  g.write('<g transform="translate(49,80)"><ellipse rx="25" ry="33" fill="${day ? '#A97B55' : '#5A4636'}"/>'
      '<ellipse rx="20" ry="28" fill="${day ? '#DCEBF5' : '#3B4270'}"/>'
      '<path d="M-10 -16 Q-4 -24 4 -24" stroke="#fff" stroke-width="3" stroke-linecap="round" fill="none" opacity=".7"/>'
      '<path d="M-12 -6 L-4 -14" stroke="#fff" stroke-width="2" stroke-linecap="round" opacity=".5"/>'
      '<path d="M2 18 l10 -10 l3 3 l-10 10 z" fill="#F14922"/><path d="M2 18 l-3 4 l4 -1z" fill="${day ? '#5A4636' : '#E9E4DA'}"/></g>'
      '<rect x="318" y="92" width="56" height="5" rx="2" fill="$shelf"/><rect x="324" y="68" width="8" height="24" rx="1.5" fill="#C98B7A"/>'
      '<rect x="333" y="72" width="7" height="20" rx="1.5" fill="#6F7C8F"/><rect x="341" y="66" width="9" height="26" rx="1.5" fill="#3F5B4F"/>'
      '<rect x="352" y="76" width="7" height="16" rx="1.5" transform="rotate(-14 352 92)" fill="#E9C46A"/>');
  g.write('</svg>');
  return g.toString();
}

/// The desk and what is on it; 390 × 372, drawn over you.
String _deskSvg({required bool day, required bool phonesOnDesk, required HallPlant? plant, required bool thirsty}) {
  final g = StringBuffer('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 390 372">'
      '<defs><linearGradient id="t" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#C08B5C"/><stop offset="1" stop-color="#A57347"/></linearGradient>'
      '<linearGradient id="f" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#7A5233"/><stop offset="1" stop-color="#5E3E27"/></linearGradient></defs>'
      '<path d="M0 282 H390 V312 H0Z" fill="url(#t)"/><path d="M0 282 H390" stroke="#D9A77A" stroke-width="2"/>'
      '<rect x="0" y="312" width="390" height="60" fill="url(#f)"/><path d="M0 312 H390" stroke="#4E3320" stroke-width="2"/>'
      // Books (today's tasks) with an orange bookmark.
      '<rect x="34" y="286" width="54" height="11" rx="2" fill="#3F5B4F"/><rect x="38" y="275" width="48" height="11" rx="2" fill="#C98B7A"/>'
      '<rect x="32" y="264" width="52" height="11" rx="2" fill="#2E3A59"/><path d="M72 264 v17 l4 -4 l4 4 v-17" fill="#F14922"/>');
  if (phonesOnDesk) {
    g.write('<path d="M120 298 C120 276 152 276 152 298" stroke="#3A3D52" stroke-width="4" fill="none"/>'
        '<rect x="114" y="290" width="11" height="13" rx="5" fill="#E9E6EF"/><rect x="147" y="290" width="11" height="13" rx="5" fill="#E9E6EF"/>');
  } else {
    g.write('<path d="M118 298 h34" stroke="#ffffff" stroke-opacity=".2" stroke-width="2" stroke-dasharray="3 3"/>');
  }
  // Tea glass (the break).
  g.write('<ellipse cx="276" cy="300" rx="17" ry="4" fill="#E9E6EF"/>'
      '<path d="M267 270 Q265 282 269 290 Q271 297 276 297 Q281 297 283 290 Q287 282 285 270 Z" fill="#ffffff" fill-opacity=".16" stroke="#ffffff" stroke-opacity=".45" stroke-width="1.2"/>'
      '<path d="M267.6 276 Q266.4 283 269.4 290 Q271 296 276 296 Q281 296 282.6 290 Q285.6 283 284.4 276 Z" fill="#B5431F" opacity=".9"/>');
  // The plant (your streak).
  final p = deskPlantSvg(plant, pot: false, viewBox: '-45 -100 90 110');
  final inner = p.substring(p.indexOf('>') + 1, p.lastIndexOf('</svg>'));
  g.write('<g transform="translate(345,280)">$inner</g>'
      '<path d="M331 278 H359 L355 300 H335 Z" fill="#C46A45"/><rect x="329" y="275" width="32" height="6" rx="2" fill="#D47B55"/>');
  if (thirsty) g.write('<circle cx="362" cy="268" r="9" fill="#4FA3E0"/><path d="M362 263 q-4 5 0 8 q4 -3 0 -8Z" fill="#fff"/>');
  g.write('<rect x="170" y="346" width="50" height="6" rx="3" fill="#4E3320"/></svg>');
  return g.toString();
}

/// Rain seen through the window, drawn from a 60-second clock so the loop
/// never jumps: every moving part makes a whole number of cycles per loop.
///
/// Outside: two layers of streaks (far: thin, faint, slow; near: longer,
/// brighter, faster) slanted by a wind that slowly gusts, each with a faded
/// tail. On the glass: beads that catch the light, new drops landing, and a
/// few that swell, then run down leaving a fading trail. With thunder the
/// window flashes twice in quick succession a few times a minute.
class _RainPainter extends CustomPainter {
  _RainPainter(this.seconds, this.day, {this.thunder = false});

  /// Time on the rain clock, 0–60.
  final double seconds;
  final bool day;
  final bool thunder;

  static const loop = 60.0;

  /// Stable pseudo-random value in [0, 1) for (a, b).
  static double _rand(int a, int b) {
    var h = (a * 374761393 + b * 668265263) & 0xFFFFFFFF;
    h = ((h ^ (h >> 13)) * 1274126177) & 0xFFFFFFFF;
    h ^= h >> 16;
    return (h & 0xFFFFFF) / 0x1000000;
  }

  /// A period near [wanted] seconds that fits a whole number of times in the loop.
  static double _fit(double wanted) => loop / math.max(1, (loop / wanted).round());

  @override
  void paint(Canvas canvas, Size s) {
    final t = seconds;
    canvas.clipRRect(RRect.fromRectAndRadius(Offset.zero & s, const Radius.circular(8)));
    // Rainy light: the view goes a little grey and flat.
    canvas.drawRect(Offset.zero & s, Paint()..color = (day ? const Color(0xFF6B7A90) : const Color(0xFF0A0C24)).withValues(alpha: day ? .22 : .2));

    if (thunder) _flash(canvas, s, t);

    final wind = .16 + .07 * math.sin(2 * math.pi * t / 30);
    final tint = day ? Colors.white : const Color(0xFFC9D6FF);
    // (count, length, speed px/s, width, alpha)
    const layers = [(46, 7.0, 210.0, .8, .26), (22, 14.0, 380.0, 1.3, .5)];
    for (var l = 0; l < layers.length; l++) {
      final (count, len, speed, width, alpha) = layers[l];
      final head = Paint()
        ..color = tint.withValues(alpha: alpha)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      final tail = Paint()
        ..color = tint.withValues(alpha: alpha * .35)
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round;
      final travel = s.height + len + 30;
      for (var i = 0; i < count; i++) {
        final v = speed * (.85 + _rand(i, l * 7 + 1) * .3);
        final period = _fit(travel / v);
        final phase = (_rand(i, l * 7 + 2) + t / period) % 1;
        final y = -len - 10 + phase * travel;
        // Start wider than the glass so the slant never leaves a gap.
        final x = -20 + _rand(i, l * 7 + 3) * (s.width + 20 + wind * s.height) - wind * y;
        final dx = wind * len, mid = Offset(x + dx * .5, y - len * .5);
        canvas.drawLine(Offset(x + dx, y - len), mid, tail);
        canvas.drawLine(mid, Offset(x, y), head);
      }
    }

    // Faint mist low on the glass.
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0), Colors.white.withValues(alpha: day ? .12 : .06)],
        ).createShader(Offset.zero & s),
    );

    // Beads that stay on the pane.
    for (var i = 0; i < 24; i++) {
      final p = Offset(4 + _rand(i, 91) * (s.width - 8), 4 + _rand(i, 92) * (s.height - 8));
      _bead(canvas, p, .8 + _rand(i, 93) * 1.9, 1);
    }

    // New drops landing: each slot lands once every 5 s at a new place.
    const land = 5.0;
    for (var i = 0; i < 16; i++) {
      final cycle = (t / land).floor(), u = (t % land) / land;
      final at = _rand(i, cycle * 3 + 400) * .6;
      if (u < at) continue;
      final fade = math.min(1.0, (u - at) / .04) * (u > .9 ? (1 - u) / .1 : 1);
      final p = Offset(4 + _rand(i, cycle * 3 + 401) * (s.width - 8), 4 + _rand(i, cycle * 3 + 402) * (s.height - 8));
      _bead(canvas, p, .7 + _rand(i, cycle) * 1.4, fade);
    }

    // Runners: swell for a while, then run down, leaving a trail that fades.
    const runners = [12.0, 15.0, 20.0, 10.0, 30.0];
    for (var i = 0; i < runners.length; i++) {
      final life = runners[i];
      final cycle = (t / life).floor(), u = (t % life) / life;
      final x0 = 8 + _rand(i, cycle + 700) * (s.width - 16), y0 = 6 + _rand(i, cycle + 701) * s.height * .45;
      final seed = _rand(i, cycle + 702) * 10;
      double xAt(double y) => x0 + math.sin((y - y0) / 9 + seed) * 1.6;
      const start = .5, stop = .72;
      final r = 1.6 + math.min(u, start) / start * 1.6;
      if (u < start) {
        _bead(canvas, Offset(x0, y0), r, math.min(1, u / .05));
        continue;
      }
      final run = math.min(1.0, (u - start) / (stop - start));
      final y = y0 + run * run * (s.height - y0 + 12);
      final fade = u < stop ? 1.0 : 1 - (u - stop) / (1 - stop);
      final trail = Path()..moveTo(x0, y0);
      for (var yy = y0; yy <= y; yy += 3) {
        trail.lineTo(xAt(yy), yy);
      }
      canvas.drawPath(
        trail,
        Paint()
          ..color = Colors.white.withValues(alpha: .16 * fade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .7
          ..strokeCap = StrokeCap.round,
      );
      if (u < stop) _bead(canvas, Offset(xAt(y), y), r * .9, 1);
    }
  }

  /// A water bead: clear body, a darker rim on top, light gathered at the
  /// bottom (it acts like a tiny lens) and a sharp highlight.
  void _bead(Canvas canvas, Offset c, double r, double o) {
    if (o <= 0) return;
    canvas.drawCircle(c, r, Paint()..color = Colors.white.withValues(alpha: (day ? .2 : .14) * o));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: .18 * o)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .7,
    );
    canvas.drawCircle(c + Offset(0, r * .35), r * .55, Paint()..color = Colors.white.withValues(alpha: .28 * o));
    canvas.drawCircle(c - Offset(r * .35, r * .4), math.max(.45, r * .28), Paint()..color = Colors.white.withValues(alpha: .85 * o));
  }

  /// Lightning: a bright flicker, a short dark gap, a second weaker one.
  void _flash(Canvas canvas, Size s, double t) {
    const strikes = [7.0, 23.5, 41.0, 52.5];
    var light = 0.0;
    for (final at in strikes) {
      final d = t - at;
      if (d < 0 || d > 1.2) continue;
      if (d < .08) light = math.max(light, d / .08);
      if (d >= .08 && d < .2) light = math.max(light, .25);
      if (d >= .2 && d < 1.2) light = math.max(light, .75 * math.exp(-(d - .2) * 5));
    }
    if (light <= 0) return;
    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: .7 * light), const Color(0xFFDDE4FF).withValues(alpha: .25 * light)],
        ).createShader(Offset.zero & s),
    );
  }

  @override
  bool shouldRepaint(_RainPainter o) => o.seconds != seconds || o.day != day || o.thunder != thunder;
}

class _SteamPainter extends CustomPainter {
  _SteamPainter(this.t, this.day);
  final double t;
  final bool day;

  @override
  void paint(Canvas canvas, Size s) {
    final base = day ? const Color(0xFF9A8A7A) : Colors.white;
    for (var i = 0; i < 3; i++) {
      final phase = (t + i / 3) % 1;
      final paint = Paint()
        ..color = base.withValues(alpha: math.sin(phase * math.pi) * .6)
        ..strokeWidth = 1.6
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      final x = 9.0 + i * 5, y = s.height - 2 - phase * 18;
      canvas.drawPath(
          Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(x - 4, y - 6, x, y - 12),
          paint);
    }
  }

  @override
  bool shouldRepaint(_SteamPainter o) => o.t != t || o.day != day;
}

// ------------------------------------------------------------------- camera

/// The night building; the camera starts wide and flies into your lit window.
class _CameraIntro extends StatelessWidget {
  const _CameraIntro({required this.t, required this.avatar});
  final double t;
  final HallAvatar avatar;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final w = box.maxWidth, h = box.maxHeight;
      // My window sits a little above the middle of the screen.
      final target = Offset(w / 2, h * .42);
      final zoomT = Curves.easeInCubic.transform(((t - .25) / .75).clamp(0.0, 1.0));
      final scale = 1 + zoomT * 13;
      final fade = ((t - .78) / .22).clamp(0.0, 1.0);
      return Opacity(
        opacity: 1 - fade,
        child: Container(
          color: hallNight,
          child: Transform(
            alignment: Alignment.topLeft,
            transform: Matrix4.identity()
              ..translateByDouble(target.dx, target.dy, 0, 1)
              ..scaleByDouble(scale, scale, 1, 1)
              ..translateByDouble(-target.dx, -target.dy, 0, 1),
            child: Stack(
              children: [
                Positioned.fill(
                    child: CustomPaint(
                        painter: _IntroBuildingPainter(target: target, glow: Curves.easeOut.transform((t / .3).clamp(0.0, 1.0))))),
                Positioned(
                  left: target.dx - 15,
                  top: target.dy - 13,
                  width: 30,
                  height: 26,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      color: const Color(0xFFFFD98C),
                      child: SvgPicture.string(hallAvatarSvg(avatar), alignment: Alignment.bottomCenter),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _IntroBuildingPainter extends CustomPainter {
  _IntroBuildingPainter({required this.target, required this.glow});
  final Offset target;
  final double glow;

  @override
  void paint(Canvas canvas, Size s) {
    final r = Offset.zero & s;
    canvas.drawRect(
        r,
        Paint()
          ..shader =
              const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0E1022), Color(0xFF262A4E)])
                  .createShader(r));
    final rnd = math.Random(3);
    for (var i = 0; i < 60; i++) {
      canvas.drawCircle(Offset(rnd.nextDouble() * s.width, rnd.nextDouble() * s.height * .5), rnd.nextDouble() * 1.3 + .3,
          Paint()..color = Colors.white.withValues(alpha: .2 + rnd.nextDouble() * .6));
    }
    final bw = s.width * .62, bx = (s.width - bw) / 2, top = s.height * .14;
    canvas.drawRect(Rect.fromLTWH(bx, top, bw, s.height - top), Paint()..color = const Color(0xFF262940));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(bx - 6, top - 12, bw + 12, 14), const Radius.circular(4)),
        Paint()..color = const Color(0xFF2C2F4A));
    const cw = 30.0, ch = 26.0;
    final cols = ((bw - 16) / (cw + 14)).floor();
    final gap = (bw - cols * cw) / (cols + 1);
    for (var y = top + 18; y < s.height; y += ch + 16) {
      for (var c = 0; c < cols; c++) {
        final x = bx + gap + c * (cw + gap);
        final rect = Rect.fromLTWH(x, y, cw, ch);
        if (rect.contains(target)) continue;
        final lit = rnd.nextDouble() < .7;
        canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            Paint()..color = lit ? const Color(0xFFFFD27A).withValues(alpha: .85) : const Color(0xFF1C1F33));
      }
    }
    canvas.drawCircle(
        target,
        70 * glow,
        Paint()
          ..shader = RadialGradient(colors: [const Color(0xFFF14922).withValues(alpha: .6 * glow), const Color(0x00F14922)])
              .createShader(Rect.fromCircle(center: target, radius: 70)));
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: target, width: 36, height: 32), const Radius.circular(6)),
      Paint()
        ..color = AppColors.primary.withValues(alpha: glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_IntroBuildingPainter o) => o.glow != glow || o.target != target;
}

/// One frame of the window rain at [seconds] on its clock, for screenshots.
@visibleForTesting
Widget hallRainFrame(double seconds, {bool day = false, bool thunder = false}) =>
    CustomPaint(painter: _RainPainter(seconds, day, thunder: thunder));
