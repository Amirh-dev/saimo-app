import 'dart:async';

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
import 'package:simo_learn/features/profile/profile_cubit.dart';
import 'package:simo_learn/presentation/screens/profile/index.dart';
import 'package:simo_learn/presentation/screens/profile/friendship_models.dart';
import 'package:simo_learn/presentation/widgets/app_bottom_navigation_bar.dart';
import 'package:solar_icons/solar_icons.dart';

void main() {
  testWidgets('profile uses shape-matched shimmer until server data arrives',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _DelayedProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
    );
    await tester.pump();

    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-summary-shimmer')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-account-menu-shimmer')),
      findsOneWidget,
    );
    expect(find.text('علیرضا یوسفی'), findsNothing);
    expect(find.text('علی رضایی'), findsNothing);

    repository.completeProfile();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsNothing,
    );
    expect(find.text('علی رضایی'), findsOneWidget);
  });

  testWidgets('account details opens the reference edit sheet', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
    );
    await tester.pumpAndSettle();

    final accountDetails = find.byKey(
      const ValueKey('open-account-details'),
    );
    await tester.ensureVisible(accountDetails);
    await tester.pumpAndSettle();
    await tester.tap(accountDetails);
    await tester.pumpAndSettle();

    expect(find.text('مشخصات حساب'), findsOneWidget);
    expect(find.text('علی رضایی'), findsWidgets);
    expect(find.text('۰۹۳۸۰۶۱۹۱۹۵'), findsOneWidget);
    expect(find.text('ریاضی فیزیک'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('open-profile-edit-sheet')),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('profile-edit-sheet')),
      findsOneWidget,
    );
    expect(find.text('ویرایش مشخصات'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-phone-number-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-major-field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('profile-birth-date-field')),
      findsOneWidget,
    );

    final firstNameField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const ValueKey('profile-first-name-field')),
        matching: find.byType(TextFormField),
      ),
    );
    final lastNameField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const ValueKey('profile-last-name-field')),
        matching: find.byType(TextFormField),
      ),
    );
    expect(firstNameField.controller?.text, 'علی');
    expect(lastNameField.controller?.text, 'رضایی');
  });

  testWidgets('settings item opens the reference settings panel',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
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
    expect(find.text('نسخه ۱.۰.۱'), findsOneWidget);
    expect(find.text('ذخیره'), findsOneWidget);
    expect(find.text('لغو تغییرات'), findsOneWidget);
  });

  testWidgets('premium account row opens the plans screen', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
    );
    await tester.pumpAndSettle();

    final premium = find.byKey(
      const ValueKey('open-premium-subscription'),
    );
    await tester.ensureVisible(premium);
    await tester.tap(premium);
    await tester.pumpAndSettle();

    expect(find.text('اشتراک ویژه'), findsOneWidget);
    expect(find.text('یک ماهه'), findsOneWidget);
    expect(find.text('شش ماهه'), findsOneWidget);
    expect(find.byKey(const ValueKey('purchase-premium-plan')), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('یک ساله'), findsOneWidget);
  });

  testWidgets('reopening profile reuses the session-cached getMe response',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _ProfileGraphQLRepository(storage);
    final profileCubit = ProfileCubit(repository);
    addTearDown(profileCubit.close);

    Widget buildApp(Widget home) {
      return RepositoryProvider<GraphQLRepository>.value(
        value: repository,
        child: BlocProvider<ProfileCubit>.value(
          value: profileCubit,
          child: MaterialApp(home: home),
        ),
      );
    }

    await tester.pumpWidget(buildApp(const ProfileScreen()));
    await tester.pumpAndSettle();
    expect(repository.getProfileRequestCount, 1);
    expect(find.text('علی رضایی'), findsOneWidget);

    await tester.pumpWidget(buildApp(const SizedBox.shrink()));
    await tester.pump();
    await tester.pumpWidget(buildApp(const ProfileScreen()));
    await tester.pumpAndSettle();

    expect(repository.getProfileRequestCount, 1);
    expect(find.text('علی رضایی'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsNothing,
    );
  });

  testWidgets('pulling down refreshes getMe and replaces the cached profile',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _RefreshableProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
    );
    await tester.pumpAndSettle();
    expect(repository.getProfileRequestCount, 1);
    expect(find.text('علی رضایی'), findsOneWidget);

    repository.delayNextProfile();
    repository.profileFullName = 'پروفایل بروزشده';
    final refreshIndicator = tester.state<RefreshIndicatorState>(
      find.byKey(const ValueKey('profile-pull-to-refresh')),
    );
    unawaited(refreshIndicator.show());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump();

    expect(repository.getProfileRequestCount, 2);
    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsOneWidget,
    );

    repository.completeNextProfile();
    await tester.pumpAndSettle();

    expect(repository.getProfileRequestCount, 2);
    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsNothing,
    );
    expect(find.text('پروفایل بروزشده'), findsOneWidget);
  });

  testWidgets('reselecting the profile tab refreshes getMe and its cache',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    final repository = _RefreshableProfileGraphQLRepository(storage);

    await tester.pumpWidget(
      _profileTestApp(repository, const ProfileScreen()),
    );
    await tester.pumpAndSettle();
    expect(repository.getProfileRequestCount, 1);

    repository.delayNextProfile();
    repository.profileFullName = 'اطلاعات جدید';
    final profileTab = find.descendant(
      of: find.byType(AppBottomNavigationBar),
      matching: find.byIcon(SolarIconsBold.user),
    );
    expect(profileTab, findsOneWidget);
    await tester.tap(
      profileTab,
    );
    await tester.pump();

    expect(repository.getProfileRequestCount, 2);
    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsOneWidget,
    );

    repository.completeNextProfile();
    await tester.pumpAndSettle();

    expect(repository.getProfileRequestCount, 2);
    expect(
      find.byKey(const ValueKey('profile-loading-shimmer')),
      findsNothing,
    );
    expect(find.text('اطلاعات جدید'), findsOneWidget);
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

Widget _profileTestApp(
  GraphQLRepository repository,
  Widget home,
) {
  return RepositoryProvider<GraphQLRepository>.value(
    value: repository,
    child: BlocProvider(
      create: (_) => ProfileCubit(repository),
      child: MaterialApp(home: home),
    ),
  );
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

  int getProfileRequestCount = 0;
  String profileFullName = 'علی رضایی';

  Map<String, dynamic> get profileResponse {
    return {
      'getMe': {
        'id': 'user-1',
        'username': 'ali_rezaei',
        'phoneNumber': '09380619195',
        'fullName': profileFullName,
        'birthDate': '2001-02-03T00:00:00.000Z',
        'studyTime': 'BETWEEN_4_AND_7',
        'major': 'ریاضی فیزیک',
        'simoCoins': 36,
        'score': 3,
        'isPremium': true,
      },
    };
  }

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    if (query.contains('GetProfile')) {
      getProfileRequestCount += 1;
      return profileResponse;
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

class _RefreshableProfileGraphQLRepository extends _ProfileGraphQLRepository {
  _RefreshableProfileGraphQLRepository(super.storage);

  Completer<Map<String, dynamic>>? _nextProfileResponse;

  void delayNextProfile() {
    _nextProfileResponse = Completer<Map<String, dynamic>>();
  }

  void completeNextProfile() {
    final response = _nextProfileResponse;
    if (response == null) return;
    _nextProfileResponse = null;
    response.complete(profileResponse);
  }

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) {
    final response = _nextProfileResponse;
    if (query.contains('GetProfile') && response != null) {
      getProfileRequestCount += 1;
      return response.future;
    }
    return super.rawRequest(
      query: query,
      variables: variables,
      requiresAuth: requiresAuth,
    );
  }
}

class _DelayedProfileGraphQLRepository extends _ProfileGraphQLRepository {
  _DelayedProfileGraphQLRepository(super.storage);

  final Completer<Map<String, dynamic>> _profileResponse = Completer();

  void completeProfile() {
    _profileResponse.complete(
      super.rawRequest(query: 'GetProfile'),
    );
  }

  @override
  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) {
    if (query.contains('GetProfile')) return _profileResponse.future;
    return super.rawRequest(
      query: query,
      variables: variables,
      requiresAuth: requiresAuth,
    );
  }
}
