import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:simo_learn/presentation/widgets/app_page_transitions.dart';
import 'package:simo_learn/utils/extentions.dart';

Finder _key(String value) => find.byKey(ValueKey(value));

/// A tab screen as the app builds them: its own scaffold and bottom bar.
class _TabPage extends StatelessWidget {
  const _TabPage(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => context.to(const Scaffold(body: Text('details'))),
          child: Text('page $index'),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: index,
        onTap: (tab) {
          if (tab != index) context.toTab(_TabPage(tab));
        },
      ),
    );
  }
}

Future<void> _pumpApp(WidgetTester tester, {bool reduceMotion = false}) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(pageTransitionsTheme: kAppPageTransitionsTheme),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: reduceMotion),
        child: child!,
      ),
      home: const _TabPage(0),
    ),
  );
}

double _indicatorX(WidgetTester tester) =>
    tester.getCenter(_key('nav-indicator').last).dx;

/// Opacity of the background layer the outgoing page fades under.
double _coverOpacity(WidgetTester tester) {
  final cover = find.byKey(const ValueKey('page-transition-cover')).last;
  return tester
      .widget<FadeTransition>(
        find.ancestor(of: cover, matching: find.byType(FadeTransition)).first,
      )
      .opacity
      .value;
}

double _opacityOf(WidgetTester tester, Finder target) {
  final fades = find.ancestor(of: target, matching: find.byType(FadeTransition));
  return tester
      .widgetList<FadeTransition>(fades)
      .fold(1.0, (opacity, fade) => opacity * fade.opacity.value);
}

void main() {
  testWidgets('switching tabs glides the active circle to the new tab',
      (tester) async {
    await _pumpApp(tester);
    final home = _indicatorX(tester);
    final tasksTab = tester.getCenter(_key('nav-item-1')).dx;
    expect(home, isNot(closeTo(tasksTab, 1)));

    await tester.tap(_key('nav-item-1'));
    await tester.pump();
    await tester.pump(AppMotion.tab ~/ 2);

    final midway = _indicatorX(tester);
    expect(midway, lessThan(home));
    expect(midway, greaterThan(tasksTab));

    await tester.pumpAndSettle();
    expect(_indicatorX(tester), closeTo(tasksTab, 1));
    expect(find.text('page 1'), findsOneWidget);
    expect(find.text('page 0'), findsNothing);
  });

  testWidgets('the old tab fades out before the new one fades in',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(_key('nav-item-3'));
    await tester.pump();
    await tester.pump(AppMotion.tab * 0.15);
    // First the old screen sinks under the background...
    expect(_opacityOf(tester, find.text('page 3')), 0);
    expect(_coverOpacity(tester), inExclusiveRange(0, 1));

    await tester.pump(AppMotion.tab * 0.5);
    // ...then the new one rises, never both at once.
    expect(_coverOpacity(tester), 1);
    expect(_opacityOf(tester, find.text('page 3')), inExclusiveRange(0, 1));
  });

  testWidgets('the bar shows one icon per tab once it settles', (tester) async {
    await _pumpApp(tester);

    await tester.tap(_key('nav-item-4'));
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: _key('nav-item-4'), matching: find.byType(Icon)),
      findsOneWidget,
    );
  });

  testWidgets('tapping the current tab still reports it', (tester) async {
    int? tapped;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AppBottomNavigationBar(
            currentIndex: 2,
            onTap: (index) => tapped = index,
          ),
        ),
      ),
    );

    await tester.tap(_key('nav-item-2'));
    expect(tapped, 2);
  });

  testWidgets('pushed pages glide in from the reading direction',
      (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('page 0'));
    await tester.pump();
    await tester.pump(AppMotion.push * 0.15);
    final details = find.text('details');
    expect(_opacityOf(tester, details), 0);

    await tester.pump(AppMotion.push * 0.45);
    expect(_opacityOf(tester, details), inExclusiveRange(0, 1));
    final midwayX = tester.getTopLeft(details).dx;

    await tester.pumpAndSettle();
    expect(_opacityOf(tester, details), 1);
    // RTL: forward motion runs left to right, so the page arrives from the left.
    expect(midwayX, lessThan(tester.getTopLeft(details).dx));
  });

  testWidgets('with reduced motion pages change without animating',
      (tester) async {
    await _pumpApp(tester, reduceMotion: true);

    await tester.tap(_key('nav-item-1'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    expect(_opacityOf(tester, find.text('page 1')), 1);
  });
}
