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
    token: 'v4.local.YJEpMFqxYZiG32bxXTaLS5Jw7mAoiIV2JFJdoIKqQwupZ_ybphlEl7t89b7F3L1UX5YnWQ2GqL4nuQDDUpLoCBgEa5m41vsOBVHGbmVEmS6UBGcJosYGMV-1CRNdV5j7n_EKk3uZVzWdoiZUMmQPkBOeeHCXG7Kf5Qdmzw24eUZAV4b4NgLxvp6D0089z8eoHw4_l1l8BAzKGlUr-9qmgCFsp_U7kuHxxetAv1leBVkgWlplyjG5ABTMTmCgd-dYcXRRqmS8pwExOyiuv3zctnqDCsVyv7GW7KLbd679PWXSCKIMMRQ', // temp
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