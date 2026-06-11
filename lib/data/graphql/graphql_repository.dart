import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:http/http.dart' as http;
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Authentication is required']);

  final String message;

  @override
  String toString() => message;
}

class GraphQLRawException implements Exception {
  const GraphQLRawException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GraphQLRepository {
  GraphQLRepository(
    this._client, {
    required TokenStorage tokenStorage,
    required GraphQLConsoleLogger logger,
  })  : _tokenStorage = tokenStorage,
        _logger = logger;

  final Client _client;
  final TokenStorage _tokenStorage;
  final GraphQLConsoleLogger _logger;
  Future<void>? _refreshFuture;

  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    bool requiresAuth = true,
    bool skipAuthRefresh = false,
  }) async* {
    if (requiresAuth && !skipAuthRefresh) {
      await ensureFreshToken();
    }
    yield* _loggedRequest(request);
  }

  Future<OperationResponse<TData, TVars>> requestOnce<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    bool requiresAuth = true,
    bool skipAuthRefresh = false,
  }) async {
    if (requiresAuth && !skipAuthRefresh) {
      await ensureFreshToken();
    }
    return _loggedRequest(request).first;
  }

  void clearCache() {
    _client.cache.clear();
  }

  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    if (requiresAuth) {
      await ensureFreshToken();
    }

    final token = _tokenStorage.currentAccessToken;
    final response = await http.post(
      Uri.parse(_logger.endpoint),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const GraphQLRawException('Invalid GraphQL response');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GraphQLRawException(
        decoded['message']?.toString() ?? 'GraphQL request failed',
      );
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      final message = errors
          .map((error) {
            if (error is Map<String, dynamic>) return error['message'];
            return error;
          })
          .whereType<Object>()
          .map((error) => error.toString())
          .where((message) => message.isNotEmpty)
          .join(', ');
      throw GraphQLRawException(
        message.isEmpty ? 'GraphQL request failed' : message,
      );
    }

    final data = decoded['data'];
    if (data is Map<String, dynamic>) return data;
    return const {};
  }

  Future<void> ensureFreshToken() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const UnauthorizedException();
    }

    if (!await _tokenStorage.shouldRefreshAccessToken()) return;

    _refreshFuture ??= _refreshToken();
    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _refreshToken() async {
    // TODO: Backend stores the refresh token in an HttpOnly cookie. If mobile
    // refresh does not persist across app launches, add cookie-jar support for
    // the HTTP client used by Ferry/gql_http_link.
    final response = await requestOnce(
      GRefreshTokenReq(),
      requiresAuth: false,
      skipAuthRefresh: true,
    );
    if (response.hasErrors) {
      final message = graphQLResponseErrorMessage(response);
      await _tokenStorage.clear();
      throw UnauthorizedException(message);
    }

    final accessToken = response.data?.refreshToken.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStorage.clear();
      throw const UnauthorizedException('Refresh token failed');
    }

    await _tokenStorage.saveAccessToken(accessToken);
  }

  Stream<OperationResponse<TData, TVars>> _loggedRequest<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) async* {
    _logger.logRequest(request);

    try {
      await for (final response in _client.request(request)) {
        _logger.logResponse(request, response);
        yield response;
      }
    } catch (error, stackTrace) {
      _logger.logException(request, error, stackTrace);
      rethrow;
    }
  }
}

String graphQLResponseErrorMessage(
    OperationResponse<dynamic, dynamic> response) {
  final graphqlMessage = response.graphqlErrors
          ?.map((error) => error.message)
          .where((message) => message.isNotEmpty)
          .join(', ') ??
      '';
  if (graphqlMessage.isNotEmpty) return graphqlMessage;

  final linkMessage = response.linkException?.toString() ?? '';
  if (linkMessage.isNotEmpty) return linkMessage;

  return 'Unknown GraphQL error';
}
