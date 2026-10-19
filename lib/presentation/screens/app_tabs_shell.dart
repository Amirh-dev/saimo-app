import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simo_learn/presentation/screens/consultants/consultant_header_button.dart';
import 'package:simo_learn/presentation/screens/dashboard/index.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/presentation/widgets/re_text.dart';
import 'package:simo_learn/utils/_utils.dart';

/// The five bottom-navigation tabs, kept alive side by side. A tab is built
/// the first time it is opened and then stays, so going back to it shows it
/// as it was instead of loading it again. Tabs that want fresh data on a
/// return use [AppTabRevisit].
///
/// One header sits above every tab: switching tabs changes only its title,
/// while the counselor button stays put. Tab pages show their header with
/// [AppTabHeader], which draws nothing inside the shell.
class AppTabsShell extends StatefulWidget {
  const AppTabsShell({
    super.key,
    this.initialIndex = 0,
    @visibleForTesting this.tabs = _defaultTabs,
    @visibleForTesting this.titles = _defaultTitles,
  });

  static const List<Widget> _defaultTabs = [
    DashboardScreen(),
    TasksScreen(),
    GoalScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  static const List<String> _defaultTitles = [
    'خوش آمدید',
    'تسک‌ها',
    'اهداف',
    'آمــــار',
    'پروفایل',
  ];

  /// The tab pages, in bottom-navigation order.
  final List<Widget> tabs;

  /// Each tab's title in the shared header; null leaves the header out.
  final List<String>? titles;

  final int initialIndex;

  static const int home = 0;

  /// The tab on screen; [AppTabRevisit] listens to it.
  static final ValueNotifier<int> selectedTab = ValueNotifier(home);

  static _AppTabsShellState? _active;

  /// Shows tab [index] in the running shell, closing any pages opened above
  /// it. False when no shell is running.
  static bool select(BuildContext context, int index) {
    final shell = _active;
    if (shell == null || !shell.mounted) return false;
    final route = ModalRoute.of(shell.context);
    if (route != null && !route.isCurrent) {
      Navigator.of(shell.context).popUntil((other) => other == route);
    }
    shell._select(index);
    return true;
  }

  /// Whether [context] sits inside the shell, whose own guard handles the
  /// back button.
  static bool contains(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InTabsShell>() != null;

  @override
  State<AppTabsShell> createState() => _AppTabsShellState();
}

class _AppTabsShellState extends State<AppTabsShell>
    with SingleTickerProviderStateMixin {

  late int _index = widget.initialIndex;
  late final Set<int> _built = {_index};

  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.tab,
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    assert(widget.titles == null || widget.titles!.length == widget.tabs.length);
    AppTabsShell._active = this;
    AppTabsShell.selectedTab.value = _index;
  }

  @override
  void dispose() {
    if (AppTabsShell._active == this) AppTabsShell._active = null;
    _entrance.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index || index < 0 || index >= widget.tabs.length) return;
    setState(() {
      _index = index;
      _built.add(index);
    });
    if (reduceMotion(context)) {
      _entrance.value = 1;
    } else {
      _entrance.forward(from: 0);
    }
    // After this frame, so a revisited tab refreshes once it is on screen.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted && _index == index) AppTabsShell.selectedTab.value = index;
    });
  }

  /// Back first goes back inside the tab on screen (e.g. from a profile
  /// section to the profile); then from another tab to home; on home it asks
  /// to leave.
  bool _handleBack() {
    if (AppTabRevisit._byTab[_index]?.onTabBack() ?? false) return true;
    if (_index == AppTabsShell.home) return false;
    _select(AppTabsShell.home);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final titles = widget.titles;
    Widget tabs = IndexedStack(
      index: _index,
      children: [
        for (var index = 0; index < widget.tabs.length; index++)
          if (_built.contains(index))
            // The same widgets around every tab, so switching never
            // rebuilds one from scratch.
            TickerMode(
              enabled: index == _index,
              child: AppTabTransition(
                animation:
                    index == _index ? _entrance : kAlwaysCompleteAnimation,
                child: widget.tabs[index],
              ),
            )
          else
            const SizedBox.shrink(),
      ],
    );
    if (titles != null) {
      tabs = ColoredBox(
        // What shows behind a tab while it fades in: the white its own top
        // card continues from the header.
        color: AppColors.white,
        child: Column(
          children: [
            _SharedTabHeader(title: titles[_index]),
            Expanded(
              // The header already keeps clear of the status bar.
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: tabs,
              ),
            ),
          ],
        ),
      );
    }
    return AppExitGuard(
      onBack: _handleBack,
      child: _InTabsShell(child: tabs),
    );
  }
}

/// The header above every tab. Only [title] changes between tabs; it
/// crossfades so a switch reads as the same bar with a new name.
class _SharedTabHeader extends StatelessWidget {
  const _SharedTabHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: _TabHeaderRow(
        title: AnimatedSwitcher(
          duration: AppMotion.tab,
          // Fade-through: the old title is gone before the new one rises in,
          // so the two never overlap.
          transitionBuilder: (child, animation) {
            final second = CurvedAnimation(
              parent: animation,
              curve: const Interval(0.5, 1, curve: Curves.easeOut),
            );
            return FadeTransition(
              opacity: second,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.25),
                  end: Offset.zero,
                ).animate(second),
                child: child,
              ),
            );
          },
          layoutBuilder: (current, previous) => Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [...previous, if (current != null) current],
          ),
          child: _TabTitle(title, key: ValueKey(title)),
        ),
      ),
    );
  }
}

/// A tab page's header: its title and the counselor button. Inside
/// [AppTabsShell] the shell's shared header is already above the page, so
/// this draws nothing; a tab opened as a page of its own shows it here.
class AppTabHeader extends StatelessWidget {
  const AppTabHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    if (AppTabsShell.contains(context)) return const SizedBox.shrink();
    return _TabHeaderRow(title: _TabTitle(title));
  }
}

/// The counselor button and the title, laid out as every tab's header.
class _TabHeaderRow extends StatelessWidget {
  const _TabHeaderRow({required this.title});

  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Notifications are not built yet; bring the bell back with them,
        // here for every tab:
        // GestureDetector(
        //   child: SizedBox(
        //     width: 48,
        //     height: 48,
        //     child: SvgPicture.asset('assets/icons/bell.svg').vMargin(11),
        //   ),
        // ),
        const ConsultantHeaderButton(),
        Expanded(child: title),
      ],
    ).tMargin(20).hMargin(16);
  }
}

class _TabTitle extends StatelessWidget {
  const _TabTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ReText(
        title,
        textAlign: TextAlign.start,
        color: AppColors.black1,
        fontSize: 16,
        fontWeight: 1000,
      ),
    );
  }
}

class _InTabsShell extends InheritedWidget {
  const _InTabsShell({required super.child});

  @override
  bool updateShouldNotify(_InTabsShell oldWidget) => false;
}

/// For a tab's state: [onTabRevisited] runs when the user comes back to the
/// tab, at most once every [revisitGap], so data changed elsewhere shows up
/// without the tab loading from scratch. A tab with pages of its own (not
/// routes) can also go back inside itself with [onTabBack], and return to
/// its first page when the user leaves it with [onTabLeft].
mixin AppTabRevisit<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  static Duration revisitGap = const Duration(seconds: 15);

  /// The live tab states, by their place in the bottom navigation.
  static final Map<int, AppTabRevisit> _byTab = {};

  /// This tab's place in the bottom navigation.
  int get tabIndex;

  /// Brings the tab's data up to date quietly, keeping what is shown.
  void onTabRevisited();

  /// The back button, while this tab is on screen. Returns true when the tab
  /// went back inside itself; false lets the shell handle it.
  bool onTabBack() => false;

  /// The user switched to another tab. The tab is off screen by now, so it
  /// can reset itself without a visible jump.
  void onTabLeft() {}

  DateTime _lastRefresh = DateTime.now();
  bool _isSelected = false;
  bool _stale = false;

  /// What the tab shows changed somewhere else; the next return to it
  /// refreshes even within [revisitGap].
  void markStale() => _stale = true;

  @override
  void initState() {
    super.initState();
    _byTab[tabIndex] = this;
    _isSelected = AppTabsShell.selectedTab.value == tabIndex;
    AppTabsShell.selectedTab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    AppTabsShell.selectedTab.removeListener(_onTabChanged);
    if (identical(_byTab[tabIndex], this)) _byTab.remove(tabIndex);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    final selected = AppTabsShell.selectedTab.value == tabIndex;
    final wasSelected = _isSelected;
    _isSelected = selected;
    if (!selected) {
      if (wasSelected) onTabLeft();
      return;
    }
    final now = DateTime.now();
    if (!_stale && now.difference(_lastRefresh) < revisitGap) return;
    _stale = false;
    _lastRefresh = now;
    onTabRevisited();
  }
}
