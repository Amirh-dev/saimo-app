export 'package:simo_learn/app/app.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/app/app.dart';
import 'package:simo_learn/data/app_update/app_update_check.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/core/global/global_data_repository.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'data/auth/token_storage.dart';
import 'data/notifications/notification_service.dart';
import 'data/graphql/ferry_client.dart';
import 'data/graphql/graphql_console_logger.dart';
import 'data/graphql/graphql_endpoints.dart';
import 'data/graphql/graphql_repository.dart';

import 'features/auth/cubit/auth_cubit.dart';

import 'features/dashboard/cubit/dashboard_cubit.dart';
import 'features/dashboard/dashboard_repository.dart';

import 'features/profile/profile_cubit.dart';

import 'presentation/screens/chat/inbox_subscription_client.dart';

import 'package:simo_learn/features/goals/cubit/goals_cubit.dart';
import 'package:simo_learn/features/goals/goals_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push setup talks to Google, which can be slow or blocked on some
  // networks, so it runs alongside the first screen instead of before it.
  unawaited(
    NotificationService.instance.initialize(
      initializeFirebase: () => Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      ),
    ),
  );

  final tokenStorage = await TokenStorage.create();

  final ferryClient = createFerryClient(
    endpoint: GraphQLEndpoints.http,
    tokenStorage: tokenStorage,
  );

  final globalDataRepository = GlobalDataRepository(
    ferryClient,
  );

  final graphQLLogger = GraphQLConsoleLogger(
    endpoint: GraphQLEndpoints.http,
  );

  final graphQLRepository = GraphQLRepository(
    ferryClient,
    tokenStorage: tokenStorage,
    logger: graphQLLogger,
  );

  final inboxSubscriptionClient = InboxSubscriptionClient(
    graphqlRepository: graphQLRepository,
    tokenStorage: tokenStorage,
  );

  debugPrint(
    "ACCESS TOKEN: -> "
        "${tokenStorage.currentAccessToken} <-",
  );

  // Public tags are the fallback for title-based tag suggestions, read only
  // once a task form opens. Load them alongside the first screen: awaiting a
  // network call here kept the page blank until it answered.
  unawaited(
    globalDataRepository.loadParentTags().catchError((Object error) {
      debugPrint('Failed loading parent tags: $error');
    }),
  );
  // Admins rename and merge parent tags; reload them once the app is back.
  GlobalData.instance.loadParentTags = globalDataRepository.loadParentTags;
  AppLifecycleListener(onResume: GlobalData.instance.refreshParentTags);

  // Web only: watch for a newer release while this tab stays open.
  AppUpdateCheck.instance.start();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: tokenStorage,
        ),
        RepositoryProvider.value(
          value: graphQLLogger,
        ),
        RepositoryProvider.value(
          value: graphQLRepository,
        ),
        RepositoryProvider.value(
          value: inboxSubscriptionClient,
        ),
        RepositoryProvider.value(
          value: ferryClient,
        ),
        RepositoryProvider.value(
          value: globalDataRepository,
        ),
        RepositoryProvider(
          create: (context) => GoalsRepository(
            context.read<GraphQLRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => DashboardCubit(
              DashboardRepository(
                context.read<GraphQLRepository>(),
              ),
            ),
          ),
          BlocProvider(
            create: (context) => AuthCubit(
              graphQLRepository: context.read<GraphQLRepository>(),
              tokenStorage: context.read<TokenStorage>(),
            )..checkAuthStatus(),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              context.read<GraphQLRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => StatisticsCubit(
              StatisticsRepository(
                context.read<GraphQLRepository>(),
              ),
            ),
          ),
          BlocProvider(
            create: (context) => GoalsCubit(
              context.read<GoalsRepository>(),
            )..loadGoals(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
