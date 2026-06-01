import 'package:ferry/ferry.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Authentication is required']);

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
