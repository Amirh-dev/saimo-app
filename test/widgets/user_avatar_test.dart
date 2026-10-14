import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simo_learn/presentation/widgets/user_avatar.dart';

import '../tasks/support/app_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  Future<void> pump(WidgetTester tester, Widget avatar) => tester.pumpWidget(
        MaterialApp(home: Scaffold(body: Center(child: avatar))),
      );

  Finder placeholder() => find.byKey(const ValueKey('user-avatar-placeholder'));

  test('the initial is the first letter of the name', () {
    expect(UserAvatarPlaceholder.initialOf('  سارا محمدی'), 'س');
    expect(UserAvatarPlaceholder.initialOf('Ali'), 'A');
    expect(UserAvatarPlaceholder.initialOf('   '), isNull);
    expect(UserAvatarPlaceholder.initialOf(null), isNull);
  });

  testWidgets('without a picture, the initial stands in', (tester) async {
    await pump(tester, const UserAvatar(imageUrl: null, name: 'سارا', size: 56));

    expect(placeholder(), findsOneWidget);
    expect(find.text('س'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('without a name either, a person glyph stands in',
      (tester) async {
    await pump(tester, const UserAvatar(imageUrl: '', size: 56));

    expect(placeholder(), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('a picture that is not a web address is not loaded',
      (tester) async {
    // Old data held this literal instead of an image path.
    await pump(
      tester,
      const UserAvatar(imageUrl: 'Assets.profilePlaceholder', size: 46),
    );

    expect(placeholder(), findsOneWidget);
  });

  testWidgets('a web picture is loaded', (tester) async {
    await pump(
      tester,
      const UserAvatar(imageUrl: 'https://cdn.example/a.jpg', name: 'سارا', size: 56),
    );

    expect(find.byType(Image), findsOneWidget);
  });
}
