import 'package:ferry/ferry.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

void main() {
  test('reads the name of a raw mutation, and nothing from a query', () {
    expect(
      GraphQLRepository.mutationNameOf(r'''
mutation PlanUpdateTask($id: ID!, $input: UpdateTaskInput!) {
  updateTask(id: $id, input: $input) { id }
}'''),
      'PlanUpdateTask',
    );
    expect(
      GraphQLRepository.mutationNameOf(
          '# a comment first\n  mutation DeleteTaskWithScope { x }'),
      'DeleteTaskWithScope',
    );
    expect(GraphQLRepository.mutationNameOf('mutation { x }'), '');
    expect(GraphQLRepository.mutationNameOf('query GetTasks { getTasks { id } }'),
        isNull);
    expect(GraphQLRepository.mutationNameOf('{ getMe { id } }'), isNull);
  });

  test('reports the mutations the server accepted, and only those', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'fresh-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc(),
    );
    var refuse = false;
    final link = Link.function((request, [forward]) async* {
      if (refuse) {
        yield const Response(
          errors: [GraphQLError(message: 'refused')],
          response: {},
        );
        return;
      }
      final data = request.operation.operationName == 'GetMe'
          ? <String, dynamic>{
              '__typename': 'Query',
              'getMe': {'__typename': 'User', 'id': 'user-id'},
            }
          : <String, dynamic>{
              '__typename': 'Mutation',
              'refreshToken': {
                '__typename': 'AuthPayload',
                'accessToken': 'a',
                'refreshToken': 'r',
                'user': {'__typename': 'User', 'id': 'user-id'},
              },
            };
      yield Response(data: data, response: data);
    });
    final repository = GraphQLRepository(
      Client(link: link),
      tokenStorage: storage,
      logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
    );
    final names = <String>[];
    final subscription = repository.completedMutations.listen(names.add);
    addTearDown(subscription.cancel);

    final mutation = GRefreshTokenReq(
      (b) => b..vars.input.refreshToken = 'r',
    );
    await repository.requestOnce(mutation, requiresAuth: false);
    await repository.requestOnce(GGetMeReq());
    refuse = true;
    await repository.requestOnce(mutation, requiresAuth: false);
    await pumpEventQueue();

    expect(names, ['RefreshToken']);
  });
}
