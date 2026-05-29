export 'package:simo_learn/app/app.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simo_learn/app/app.dart';

import 'data/graphql/ferry_client.dart';
import 'data/graphql/graphql_repository.dart';
 import 'features/profile/profile_cubit.dart';

void main() {
  final ferryClient = createFerryClient(
    endpoint: 'https://simo.api.bennito.ir/query',
    token: null, // temp
  );

  final graphQLRepository = GraphQLRepository(
    ferryClient,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: graphQLRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
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