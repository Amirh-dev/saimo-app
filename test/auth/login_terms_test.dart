import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/widgets/made_by_credit.dart';
// url_launcher's platform interface, so launches can be recorded.
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

void main() {
  late _FakeUrlLauncher launcher;
  setUp(() => UrlLauncherPlatform.instance = launcher = _FakeUrlLauncher());

  testWidgets('the terms link under login opens the privacy page',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoginTermsNotice())),
    );

    expect(
      find.textContaining('ورود شما به معنای موافقت با', findRichText: true),
      findsOneWidget,
    );

    await tester.tapOnText(find.textRange.ofSubstring('قوانین و مقررات سایمو'));
    await tester.pump();

    expect(launcher.launched, ['https://saimo.app/privacy']);
  });

  testWidgets('the Ravi credit opens the studio website', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Center(child: MadeByCredit()))),
    );

    expect(find.text('تیم راوی'), findsOneWidget);
    await tester.tap(find.byType(MadeByCredit));
    await tester.pump();

    expect(launcher.launched, ['https://ravisite.com']);
  });
}

class _FakeUrlLauncher extends UrlLauncherPlatform {
  final launched = <String>[];

  @override
  LinkDelegate? get linkDelegate => null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    launched.add(url);
    return true;
  }
}
