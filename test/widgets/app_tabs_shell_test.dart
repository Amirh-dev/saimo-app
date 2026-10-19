import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/app_tabs_shell.dart';
import 'package:simo_learn/utils/helpers.dart';

class _Tab extends StatefulWidget {
  const _Tab(this.index, this.log);

  final int index;
  final List<String> log;

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with AppTabRevisit {
  static final Map<int, _TabState> live = {};

  int _taps = 0;

  @override
  int get tabIndex => widget.index;

  @override
  void initState() {
    super.initState();
    live[widget.index] = this;
    widget.log.add('load ${widget.index}');
  }

  @override
  void onTabRevisited() => widget.log.add('refresh ${widget.index}');

  // Taps stand in for pages inside the tab: back undoes one. Tab 2, like
  // the profile, also starts over when left; the others keep their state.
  @override
  bool onTabBack() {
    if (_taps == 0) return false;
    setState(() => _taps--);
    return true;
  }

  @override
  void onTabLeft() {
    widget.log.add('left ${widget.index}');
    if (widget.index == 2) setState(() => _taps = 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('tab ${widget.index} taps $_taps'),
          TextButton(
            onPressed: () => setState(() => _taps++),
            child: Text('tap ${widget.index}'),
          ),
          for (var other = 0; other < 3; other++)
            TextButton(
              onPressed: () => navigateToIndex(context, other, widget.index),
              child: Text('go ${widget.index}->$other'),
            ),
        ],
      ),
    );
  }
}

Future<List<String>> _pumpShell(WidgetTester tester) async {
  final log = <String>[];
  await tester.pumpWidget(
    MaterialApp(
      home: AppTabsShell(
        titles: null,
        tabs: [for (var index = 0; index < 3; index++) _Tab(index, log)],
      ),
    ),
  );
  return log;
}

void main() {
  tearDown(() => AppTabRevisit.revisitGap = const Duration(seconds: 15));

  testWidgets('a tab loads once and keeps its state across switches',
      (tester) async {
    final log = await _pumpShell(tester);
    expect(log, ['load 0']);

    await tester.tap(find.text('tap 0'));
    await tester.pump();
    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    expect(find.text('tab 1 taps 0'), findsOneWidget);

    await tester.tap(find.text('go 1->0'));
    await tester.pumpAndSettle();

    // Home came back as it was, without loading again.
    expect(find.text('tab 0 taps 1'), findsOneWidget);
    expect(
        log.where((entry) => entry.startsWith('load')), ['load 0', 'load 1']);
  });

  testWidgets('a return refreshes quietly, at most once per gap',
      (tester) async {
    final log = await _pumpShell(tester);

    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go 1->0'));
    await tester.pumpAndSettle();
    // Back within the gap: nothing to refresh yet.
    expect(log.where((entry) => entry.startsWith('refresh')), isEmpty);

    AppTabRevisit.revisitGap = Duration.zero;
    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    expect(log.last, 'refresh 1');
  });

  testWidgets('a tab whose data changed elsewhere refreshes on return at once',
      (tester) async {
    final log = await _pumpShell(tester);
    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go 1->0'));
    await tester.pumpAndSettle();

    // Say a task was written from the home while the tasks tab was away.
    _TabState.live[1]!.markStale();
    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    expect(log.last, 'refresh 1');

    // Once refreshed, the gap applies again.
    await tester.tap(find.text('go 1->0'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('go 0->1'));
    await tester.pumpAndSettle();
    expect(log.where((entry) => entry == 'refresh 1'), hasLength(1));
  });

  testWidgets('back on another tab goes home first', (tester) async {
    await _pumpShell(tester);
    await tester.tap(find.text('go 0->2'));
    await tester.pumpAndSettle();
    expect(find.text('tab 2 taps 0'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();

    expect(find.text('tab 0 taps 0'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('back goes back inside the tab before leaving it',
      (tester) async {
    await _pumpShell(tester);
    await tester.tap(find.text('go 0->2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('tap 2'));
    await tester.pump();
    expect(find.text('tab 2 taps 1'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    await navigator.maybePop();
    await tester.pumpAndSettle();
    // Still on the tab, one page back.
    expect(find.text('tab 2 taps 0'), findsOneWidget);

    await navigator.maybePop();
    await tester.pumpAndSettle();
    expect(find.text('tab 0 taps 0'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('a tab left for another starts over when it comes back',
      (tester) async {
    final log = await _pumpShell(tester);
    await tester.tap(find.text('go 0->2'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('tap 2'));
    await tester.pump();

    await tester.tap(find.text('go 2->1'));
    await tester.pumpAndSettle();
    expect(
        log.where((entry) => entry.startsWith('left')), ['left 0', 'left 2']);

    await tester.tap(find.text('go 1->2'));
    await tester.pumpAndSettle();
    expect(find.text('tab 2 taps 0'), findsOneWidget);
  });

  testWidgets('switching from a page above the tabs closes it', (tester) async {
    await _pumpShell(tester);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => navigateToIndex(context, 1, 6),
          child: const Text('to tasks'),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('to tasks'));
    await tester.pumpAndSettle();

    expect(find.text('to tasks'), findsNothing);
    expect(find.text('tab 1 taps 0'), findsOneWidget);
  });
}
