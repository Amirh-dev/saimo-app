import 'dart:async';

import 'package:ferry/ferry.dart';
import 'package:flutter_test/flutter_test.dart';
// gql_exec is a transitive test fixture API exposed through Ferry's link stack.
// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart';

void main() {
  test('uses a fresh access token without refreshing', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'fresh-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc(),
    );
    var refreshCalls = 0;
    final repository = _repository(
      storage,
      onRefresh: (request) {
        refreshCalls += 1;
        return _tokenPairResponse();
      },
    );

    expect(await repository.ensureValidAccessToken(), 'fresh-access');
    expect(refreshCalls, 0);
  });

  test('sends the saved refresh token and saves the rotated pair', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'old-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 26)),
    );
    Map<String, dynamic>? refreshVariables;
    final repository = _repository(
      storage,
      onRefresh: (request) {
        refreshVariables = request.variables;
        return _tokenPairResponse();
      },
    );

    expect(await repository.ensureValidAccessToken(), 'new-access');
    expect(
      refreshVariables,
      {
        'input': {'refreshToken': 'saved-refresh'},
      },
    );
    expect(await storage.getAccessToken(), 'new-access');
    expect(await storage.getRefreshToken(), 'new-refresh');
    expect(await storage.getAccessTokenSavedAt(), isNotNull);
  });

  test('shares one refresh between simultaneous token checks', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'old-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 26)),
    );
    var refreshCalls = 0;
    final repository = _repository(
      storage,
      onRefresh: (request) async {
        refreshCalls += 1;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return _tokenPairResponse();
      },
    );

    final tokens = await Future.wait([
      repository.ensureValidAccessToken(),
      repository.ensureValidAccessToken(),
      repository.ensureValidAccessToken(),
    ]);

    expect(tokens, everyElement('new-access'));
    expect(refreshCalls, 1);
  });

  test('refreshes and retries a protected request only once after 401',
      () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'fresh-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc(),
    );
    var protectedCalls = 0;
    var refreshCalls = 0;
    final link = Link.function((request, [forward]) {
      if (request.operation.operationName == 'RefreshToken') {
        refreshCalls += 1;
        return Stream.value(_tokenPairResponse());
      }

      expect(request.operation.operationName, 'GetMe');
      protectedCalls += 1;
      if (protectedCalls == 1) {
        return Stream.value(
          const Response(
            errors: [GraphQLError(message: 'Unauthorized')],
            response: {},
          ),
        );
      }
      final data = <String, dynamic>{
        '__typename': 'Query',
        'getMe': {
          '__typename': 'User',
          'id': 'user-id',
        },
      };
      return Stream.value(Response(data: data, response: data));
    });
    final repository = GraphQLRepository(
      Client(link: link),
      tokenStorage: storage,
      logger: GraphQLConsoleLogger(
        endpoint: 'https://example.invalid/graphql',
      ),
    );

    final response = await repository.requestOnce(
      GGetMeReq((b) => b.fetchPolicy = FetchPolicy.NetworkOnly),
    );

    expect(response.data?.getMe.id, 'user-id');
    expect(protectedCalls, 2);
    expect(refreshCalls, 1);
  });

  test('clears tokens when the saved refresh token is invalid', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'old-access',
      refreshToken: 'invalid-refresh',
      issuedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 26)),
    );
    final repository = _repository(
      storage,
      onRefresh: (request) => const Response(
        errors: [GraphQLError(message: 'Invalid refresh token')],
        response: {},
      ),
    );

    expect(await repository.ensureValidAccessToken(), isNull);
    expect(await storage.getAccessToken(), isNull);
    expect(await storage.getRefreshToken(), isNull);
    expect(await storage.getAccessTokenSavedAt(), isNull);
  });

  test('keeps saved tokens when refresh is temporarily unavailable', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = await TokenStorage.create();
    await storage.saveTokenPair(
      accessToken: 'old-access',
      refreshToken: 'saved-refresh',
      issuedAt: DateTime.now().toUtc().subtract(const Duration(minutes: 26)),
    );
    final repository = _repository(
      storage,
      onRefresh: (request) => const Response(
        errors: [GraphQLError(message: 'Service unavailable')],
        response: {},
      ),
    );

    await expectLater(
      repository.ensureValidAccessToken(),
      throwsA(isA<AuthRefreshTemporarilyUnavailableException>()),
    );
    expect(await storage.getAccessToken(), 'old-access');
    expect(await storage.getRefreshToken(), 'saved-refresh');
    expect(await storage.getAccessTokenSavedAt(), isNotNull);
  });
}

GraphQLRepository _repository(
  TokenStorage storage, {
  required FutureOr<Response> Function(Request request) onRefresh,
}) {
  final link = Link.function((request, [forward]) async* {
    expect(request.operation.operationName, 'RefreshToken');
    yield await onRefresh(request);
  });

  return GraphQLRepository(
    Client(link: link),
    tokenStorage: storage,
    logger: GraphQLConsoleLogger(endpoint: 'https://example.invalid/graphql'),
  );
}

Response _tokenPairResponse() {
  final data = <String, dynamic>{
    '__typename': 'Mutation',
    'refreshToken': {
      '__typename': 'AuthPayload',
      'accessToken': 'new-access',
      'refreshToken': 'new-refresh',
      'user': {
        '__typename': 'User',
        'id': 'user-id',
      },
    },
  };
  return Response(data: data, response: data);
}
