import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is exposed by Ferry for the in-memory test link.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/profile/friendship_models.dart';

void main() {
  testWidgets('account details shows editable username below birth date',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      RepositoryProvider<GraphQLRepository>.value(
        value: repository,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final accountDetails = find.byKey(
      const ValueKey('open-account-details'),
    );
    await tester.ensureVisible(accountDetails);
    await tester.pumpAndSettle();
    await tester.tap(accountDetails);
    await tester.pumpAndSettle();

    final birthDate = find.byKey(
      const ValueKey('profile-birth-date-field'),
    );
    final username = find.byKey(
      const ValueKey('profile-username-field'),
    );
    expect(birthDate, findsOneWidget);
    expect(username, findsOneWidget);
    expect(
      tester.getTopLeft(username).dy,
      greaterThan(tester.getTopLeft(birthDate).dy),
    );

    final usernameField = tester.widget<TextFormField>(
      find.descendant(
        of: username,
        matching: find.byType(TextFormField),
      ),
    );
    expect(usernameField.controller?.text, 'ali_rezaei');

    await tester.enterText(
      find.descendant(of: username, matching: find.byType(TextFormField)),
      'ali_new',
    );
    expect(usernameField.controller?.text, 'ali_new');
  });

  testWidgets('settings item opens the reference settings panel',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      RepositoryProvider<GraphQLRepository>.value(
        value: repository,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final settings = find.byKey(const ValueKey('open-profile-settings'));
    await tester.ensureVisible(settings);
    await tester.pumpAndSettle();
    await tester.tap(settings);
    await tester.pumpAndSettle();

    expect(find.text('بازگشت به پیش فرض'), findsOneWidget);
    expect(find.text('اعلان ها'), findsOneWidget);
    expect(find.text('اخبار ها'), findsOneWidget);
    expect(find.text('نسخه ۱.۰.۰'), findsOneWidget);
    expect(find.text('ذخیره'), findsOneWidget);
    expect(find.text('لغو تغییرات'), findsOneWidget);
  });

  testWidgets('friend profile renders request and accepted friendship states',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    Future<void> pump(FriendshipRelation? relation) async {
      await tester.pumpWidget(
        RepositoryProvider<GraphQLRepository>.value(
          value: repository,
          child: MaterialApp(
            home: FriendProfileScreen(
              userID: 'friend-1',
              displayName: 'علیرضا یوسفی',
              initialRelation: relation,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pump(null);
    expect(find.text('درخواست دوستی'), findsOneWidget);

    await pump(FriendshipRelation.accepted);
    expect(find.text('لغو دوستی'), findsOneWidget);
  });
}

class _ProfileGraphQLRepository extends GraphQLRepository {
  _ProfileGraphQLRepository(TokenStorage storage)
      : super(
          Client(
            link: Link.function(
              (request, [forward]) => const Stream<Response>.empty(),
            ),
          ),
          tokenStorage: storage,
          logger: GraphQLConsoleLogger(
            endpoint: 'https://example.invalid/graphql',
          ),
        );

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    if (query.contains('GetProfile')) {
      return {
        'getMe': {
          'id': 'user-1',
          'username': 'ali_rezaei',
          'fullName': 'علی رضایی',
          'birthDate': '2001-02-03T00:00:00.000Z',
          'studyTime': 'BETWEEN_4_AND_7',
          'simoCoins': 36,
          'score': 3,
          'isPremium': true,
        },
      };
    }
    if (query.contains('GetUserProfile')) {
      return {
        'node': {
          'id': 'friend-1',
          'username': 'friend_user',
          'fullName': 'علیرضا یوسفی',
          'birthDate': '2001-02-03T00:00:00.000Z',
          'studyTime': 'BETWEEN_4_AND_7',
          'major': 'ریاضی',
          'bio': 'دانش آموز رشته ریاضی',
          'simoCoins': 36,
          'score': 3,
          'isPremium': true,
          'interests': [
            {'id': 'interest-1', 'name': 'ریاضی'},
          ],
        },
      };
    }
    if (query.contains('GetMeForFriends')) {
      return {
        'getMe': {
          'id': 'user-1',
          'username': 'ali_rezaei',
          'fullName': 'علی رضایی',
        },
      };
    }
    return const {};
  }
}
