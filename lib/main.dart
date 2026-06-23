export 'package:simo_learn/app/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/app/app.dart';

import 'data/auth/token_storage.dart';
import 'data/graphql/ferry_client.dart';
import 'data/graphql/graphql_console_logger.dart';
import 'data/graphql/graphql_endpoints.dart';
import 'data/graphql/graphql_repository.dart';
import 'features/auth/cubit/auth_cubit.dart';
import 'features/profile/profile_cubit.dart';
import 'presentation/screens/chat/inbox_subscription_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = await TokenStorage.create();
  final ferryClient = createFerryClient(
    endpoint: GraphQLEndpoints.http,
    tokenStorage: tokenStorage,
  );
  final graphQLLogger = GraphQLConsoleLogger(endpoint: GraphQLEndpoints.http);

  final graphQLRepository = GraphQLRepository(
    ferryClient,
    tokenStorage: tokenStorage,
    logger: graphQLLogger,
  );
  final inboxSubscriptionClient = InboxSubscriptionClient(
    graphqlRepository: graphQLRepository,
    tokenStorage: tokenStorage,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: tokenStorage),
        RepositoryProvider.value(value: graphQLLogger),
        RepositoryProvider.value(value: graphQLRepository),
        RepositoryProvider.value(value: inboxSubscriptionClient),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthCubit(
              graphQLRepository: context.read<GraphQLRepository>(),
              tokenStorage: context.read<TokenStorage>(),
            ),
          ),
          BlocProvider(
            create: (context) => ProfileCubit(
              context.read<GraphQLRepository>(),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
