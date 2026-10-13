import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:simo_learn/presentation/screens/dashboard/index.dart';
import 'package:simo_learn/presentation/screens/goals/index.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/statistics/index.dart';
import 'package:simo_learn/presentation/screens/tasks/index.dart';
import 'package:simo_learn/presentation/widgets/app_exit_guard.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';

/// The five bottom-navigation tabs, kept alive side by side. A tab is built
/// the first time it is opened and then stays, so going back to it shows it
/// as it was instead of loading it again. Tabs that want fresh data on a
/// return use [AppTabRevisit].
class AppTabsShell extends StatefulWidget {
  const AppTabsShell({
    super.key,
    this.initialIndex = 0,
    @visibleForTesting this.tabs = _defaultTabs,
  });

  static const List<Widget> _defaultTabs = [
    DashboardScreen(),
    TasksScreen(),
    GoalScreen(),
    StatisticsScreen(),
    ProfileScreen(),
  ];

  /// The tab pages, in bottom-navigation order.
  final List<Widget> tabs;

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

  /// Back on another tab goes home first; on home it asks to leave.
  bool _handleBack() {
    if (_index == AppTabsShell.home) return false;
    _select(AppTabsShell.home);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AppExitGuard(
      onBack: _handleBack,
      child: _InTabsShell(
        child: IndexedStack(
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
        ),
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
/// without the tab loading from scratch.
mixin AppTabRevisit<T extends StatefulWidget> on State<T> {
  @visibleForTesting
  static Duration revisitGap = const Duration(seconds: 15);

  /// This tab's place in the bottom navigation.
  int get tabIndex;

  /// Brings the tab's data up to date quietly, keeping what is shown.
  void onTabRevisited();

  DateTime _lastRefresh = DateTime.now();

  @override
  void initState() {
    super.initState();
    AppTabsShell.selectedTab.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    AppTabsShell.selectedTab.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted || AppTabsShell.selectedTab.value != tabIndex) return;
    final now = DateTime.now();
    if (now.difference(_lastRefresh) < revisitGap) return;
    _lastRefresh = now;
    onTabRevisited();
  }
}
