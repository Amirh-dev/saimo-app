import 'package:ferry/ferry.dart';
import 'package:simo_learn/data/auth/token_storage.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart';

class AuthRequiredException implements Exception {
  const AuthRequiredException();

  @override
  String toString() => 'Authentication is required';
}

class AuthRefreshException implements Exception {
  const AuthRefreshException(this.message);

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
    OperationRequest<TData, TVars> request,
  ) async* {
    await _refreshBeforeRequestIfNeeded(request);
    yield* _loggedRequest(request);
  }

  Future<OperationResponse<TData, TVars>> requestOnce<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) async {
    await _refreshBeforeRequestIfNeeded(request);
    return _loggedRequest(request).first;
  }

  Future<void> _refreshBeforeRequestIfNeeded<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) async {
    final operationName = request.operation.operationName;
    if (_isPublicAuthOperation(operationName)) return;

    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw const AuthRequiredException();
    }

    if (!await _tokenStorage.shouldRefreshAccessToken()) return;

    _refreshFuture ??= _refreshToken();
    try {
      await _refreshFuture;
    } finally {
      _refreshFuture = null;
    }
  }

  bool _isPublicAuthOperation(String? operationName) {
    return operationName == 'SendOTP' ||
        operationName == 'VerifyOTPAndLogin' ||
        operationName == 'VerifyOTPAndRegister' ||
        operationName == 'RefreshToken';
  }

  Future<void> _refreshToken() async {
    // TODO: Backend stores the refresh token in an HttpOnly cookie. If mobile
    // refresh does not persist across app launches, add cookie-jar support for
    // the HTTP client used by Ferry/gql_http_link.
    final response = await _loggedRequest(GRefreshTokenReq()).first;
    if (response.hasErrors) {
      final message = graphQLResponseErrorMessage(response);
      await _tokenStorage.clear();
      throw AuthRefreshException(message);
    }

    final accessToken = response.data?.refreshToken.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      await _tokenStorage.clear();
      throw const AuthRefreshException('Refresh token failed');
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
