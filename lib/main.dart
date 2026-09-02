export 'package:simo_learn/app/app.dart';

import 'package:ferry/ferry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/app/app.dart';
import 'package:simo_learn/core/global/global_data.dart';
import 'package:simo_learn/core/global/global_data_repository.dart';
import 'package:simo_learn/features/statistics/cubit/statistics_cubit.dart';
import 'package:simo_learn/features/statistics/statistics_repository.dart';

import 'data/auth/token_storage.dart';
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

  // await Firebase.initializeApp();
  //
  // FirebaseMessaging.onBackgroundMessage(
  //   firebaseMessagingBackgroundHandler,
  // );
  //
  // await NotificationService.instance.initialize();

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

  globalDataRepository.loadParentTags();

  final tags = GlobalData.instance.parentTags;

  debugPrint(
    "TAGS: $tags",
  );

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
            context.read<Client>(),
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
