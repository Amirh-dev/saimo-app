import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/app/app.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/features/auth/cubit/auth_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_cubit.dart';
import 'package:simo_learn/features/dashboard/cubit/dashboard_state.dart';
import 'package:simo_learn/features/dashboard/dashboard_repository.dart';
import 'package:simo_learn/features/profile/profile_cubit.dart';
import 'package:simo_learn/features/profile/profile_repository.dart';
import 'package:simo_learn/presentation/screens/authentication/login/index.dart';
import 'package:simo_learn/presentation/screens/chat/inbox_subscription_client.dart';

void main() {
  testWidgets('logout clears tokens and removes every protected route',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      'dashboard_cache.goals': '[{"id":"goal-1","title":"کنکور"}]',
    });
    final tokenStorage = await TokenStorage.create();
    await tokenStorage.saveTokenPair(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      issuedAt: DateTime.now().toUtc(),
    );

    final graphqlRepository = GraphQLRepository(
      Client(
        link: Link.function(
          (request, [forward]) => const Stream<Response>.empty(),
        ),
      ),
      tokenStorage: tokenStorage,
      logger: GraphQLConsoleLogger(
        endpoint: 'https://example.invalid/graphql',
      ),
    );
    final authCubit = AuthCubit(
      graphQLRepository: graphqlRepository,
      tokenStorage: tokenStorage,
    );
    final profileCubit = ProfileCubit.withRepository(
      ProfileRepository.withRawRequest(({
        required String query,
        Map<String, dynamic> variables = const {},
        bool requiresAuth = true,
      }) async {
        return {
          'getMe': {
            'id': 'user-1',
            'username': 'ali_rezaei',
            'fullName': 'علی رضایی',
            'simoCoins': 36,
            'score': 3,
            'isPremium': true,
          },
        };
      }),
    );
    await profileCubit.getMe();
    final dashboardCubit = DashboardCubit(DashboardRepository(graphqlRepository));
    addTearDown(dashboardCubit.close);
    final inboxClient = InboxSubscriptionClient(
      graphqlRepository: graphqlRepository,
      tokenStorage: tokenStorage,
    );

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: tokenStorage),
          RepositoryProvider.value(value: graphqlRepository),
          RepositoryProvider.value(value: inboxClient),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authCubit),
            BlocProvider.value(value: profileCubit),
            BlocProvider.value(value: dashboardCubit),
          ],
          child: const MyApp(),
        ),
      ),
    );

    final navigator = Navigator.of(
      tester.element(find.byType(CircularProgressIndicator)),
    );
    navigator.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Text('protected screen')),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('protected screen'), findsOneWidget);

    await authCubit.logout();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(navigator.canPop(), isFalse);
    expect(await tokenStorage.getAccessToken(), isNull);
    expect(await tokenStorage.getRefreshToken(), isNull);
    expect(await tokenStorage.getAccessTokenSavedAt(), isNull);
    expect(profileCubit.cachedProfile, isNull);
    expect(profileCubit.state, isA<ProfileInitial>());
    expect(dashboardCubit.state, const DashboardState());
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('dashboard_cache.goals'), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
