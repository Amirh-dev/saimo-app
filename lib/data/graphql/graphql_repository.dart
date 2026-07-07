import 'dart:async';
import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:gql_http_link/gql_http_link.dart';
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

class AuthRefreshTemporarilyUnavailableException implements Exception {
  const AuthRefreshTemporarilyUnavailableException(this.message);

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
  Future<String?>? _refreshFuture;
  int _authSessionRevision = 0;
  final _sessionExpiredController = StreamController<void>.broadcast();

  Stream<void> get sessionExpired => _sessionExpiredController.stream;

  Stream<OperationResponse<TData, TVars>> request<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    bool requiresAuth = true,
    bool skipAuthRefresh = false,
  }) async* {
    if (requiresAuth && !skipAuthRefresh) {
      final token = await ensureValidAccessToken();
      if (token == null) throw const UnauthorizedException();
    }

    await for (final response in _loggedRequest(request)) {
      if (!requiresAuth ||
          skipAuthRefresh ||
          !_isUnauthorizedResponse(response)) {
        yield response;
        continue;
      }

      final refreshedToken = await ensureValidAccessToken(forceRefresh: true);
      if (refreshedToken == null) {
        yield response;
        return;
      }

      await for (final retryResponse in _loggedRequest(request)) {
        if (_isUnauthorizedResponse(retryResponse)) {
          await _expireSession();
        }
        yield retryResponse;
      }
      return;
    }
  }

  Future<OperationResponse<TData, TVars>> requestOnce<TData, TVars>(
    OperationRequest<TData, TVars> request, {
    bool requiresAuth = true,
    bool skipAuthRefresh = false,
  }) async {
    if (requiresAuth && !skipAuthRefresh) {
      final token = await ensureValidAccessToken();
      if (token == null) throw const UnauthorizedException();
    }

    final response =
        await _loggedRequest(request).firstWhere(_isResolvedResponse);
    if (!requiresAuth ||
        skipAuthRefresh ||
        !_isUnauthorizedResponse(response)) {
      return response;
    }

    final refreshedToken = await ensureValidAccessToken(forceRefresh: true);
    if (refreshedToken == null) return response;

    final retryResponse =
        await _loggedRequest(request).firstWhere(_isResolvedResponse);
    if (_isUnauthorizedResponse(retryResponse)) {
      await _expireSession();
    }
    return retryResponse;
  }

  void clearCache() {
    _client.cache.clear();
  }

  Future<void> clearAuthSession() async {
    _authSessionRevision += 1;
    _refreshFuture = null;
    clearCache();
    await _tokenStorage.clearTokens();
  }

  TData? readCache<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) {
    return _client.cache.readQuery(request);
  }

  void writeCache<TData, TVars>(
    OperationRequest<TData, TVars> request,
    TData data,
  ) {
    _client.cache.writeQuery(request, data);
  }

  Future<Map<String, dynamic>> rawRequest({
    required String query,
    Map<String, dynamic> variables = const {},
    bool requiresAuth = true,
  }) async {
    var token = requiresAuth ? await ensureValidAccessToken() : null;
    if (requiresAuth && token == null) throw const UnauthorizedException();

    for (var attempt = 0; attempt < 2; attempt += 1) {
      final logContext = _logger.startRawRequest(
        query: query,
        variables: variables,
        requiresAuth: requiresAuth,
        attempt: attempt + 1,
      );
      late final http.Response response;
      late final Object? decoded;
      try {
        response = await http.post(
          Uri.parse(_logger.endpoint),
          headers: {
            'Content-Type': 'application/json',
            if (requiresAuth && token != null && token.isNotEmpty)
              'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'query': query,
            'variables': variables,
          }),
        );

        // Decode the raw bytes as UTF-8 explicitly. `response.body` falls
        // back to Latin-1 when the server omits `charset=utf-8`.
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
        _logger.logRawResponse(
          logContext,
          statusCode: response.statusCode,
          decodedBody: decoded,
        );
      } catch (error, stackTrace) {
        _logger.logRawException(logContext, error, stackTrace);
        rethrow;
      }

      if (decoded is! Map<String, dynamic>) {
        throw const GraphQLRawException('Invalid GraphQL response');
      }

      if (requiresAuth &&
          _isUnauthorizedRawResponse(response.statusCode, decoded)) {
        if (attempt == 0) {
          token = await ensureValidAccessToken(forceRefresh: true);
          if (token == null) throw const UnauthorizedException();
          continue;
        }
        await _expireSession();
        throw const UnauthorizedException();
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw GraphQLRawException(graphQLRawErrorMessage(decoded));
      }

      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        throw GraphQLRawException(graphQLRawErrorMessage(decoded));
      }

      final data = decoded['data'];
      if (data is Map<String, dynamic>) return data;
      return const {};
    }

    throw const UnauthorizedException();
  }

  Future<void> ensureFreshToken() async {
    final token = await ensureValidAccessToken();
    if (token == null) throw const UnauthorizedException();
  }

  Future<String?> ensureValidAccessToken({bool forceRefresh = false}) async {
    final accessToken = await _tokenStorage.getAccessToken();
    final refreshToken = await _tokenStorage.getRefreshToken();
    final savedAt = await _tokenStorage.getAccessTokenSavedAt();
    final now = DateTime.now().toUtc();
    final age = savedAt == null ? null : now.difference(savedAt.toUtc());

    if (kDebugMode) {
      debugPrint(
        '[Auth] token age minutes=${age?.inMinutes ?? 'unknown'}',
      );
    }

    final isFresh = accessToken != null &&
        accessToken.isNotEmpty &&
        savedAt != null &&
        age != null &&
        age < const Duration(minutes: 25);
    if (!forceRefresh && isFresh) return accessToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession();
      return null;
    }

    final refreshInFlight = _refreshFuture;
    if (refreshInFlight != null) return refreshInFlight;

    final authSessionRevision = _authSessionRevision;
    late final Future<String?> refreshFuture;
    refreshFuture = _refreshAccessToken(
      refreshToken,
      authSessionRevision: authSessionRevision,
    ).whenComplete(() {
      if (identical(_refreshFuture, refreshFuture)) {
        _refreshFuture = null;
      }
    });
    _refreshFuture = refreshFuture;

    try {
      return await refreshFuture;
    } on AuthRefreshTemporarilyUnavailableException {
      rethrow;
    }
  }

  Future<String?> _refreshAccessToken(
    String savedRefreshToken, {
    required int authSessionRevision,
  }) async {
    if (kDebugMode) {
      debugPrint('[Auth] refreshing token using saved refreshToken');
    }

    final response = await requestOnce(
      GRefreshTokenReq(
        (b) => b.vars.input.refreshToken = savedRefreshToken,
      ),
      requiresAuth: false,
      skipAuthRefresh: true,
    );
    if (authSessionRevision != _authSessionRevision) return null;

    if (response.hasErrors) {
      final message = graphQLResponseErrorMessage(response);
      if (_isUnauthorizedResponse(response) ||
          _isInvalidRefreshMessage(message)) {
        if (kDebugMode) {
          debugPrint('[Auth] refresh failed invalid/expired, clearing tokens');
        }
        await _expireSession();
        return null;
      }
      throw AuthRefreshTemporarilyUnavailableException(message);
    }

    final payload = response.data?.refreshToken;
    if (payload == null ||
        payload.accessToken.isEmpty ||
        payload.refreshToken.isEmpty) {
      await _expireSession();
      return null;
    }

    await _tokenStorage.saveTokenPair(
      accessToken: payload.accessToken,
      refreshToken: payload.refreshToken,
      issuedAt: DateTime.now().toUtc(),
    );
    if (authSessionRevision != _authSessionRevision) return null;
    if (kDebugMode) {
      debugPrint('[Auth] refresh success, saved new token pair');
    }
    return payload.accessToken;
  }

  Future<void> _expireSession() async {
    await clearAuthSession();
    if (!_sessionExpiredController.isClosed) {
      _sessionExpiredController.add(null);
    }
  }

  bool _isUnauthorizedResponse(OperationResponse<dynamic, dynamic> response) {
    final exception = response.linkException;
    if (exception is HttpLinkServerException && exception.statusCode == 401) {
      return true;
    }

    final messages = response.graphqlErrors
            ?.map((error) => error.message)
            .where((message) => message.isNotEmpty)
            .join(' ') ??
        '';
    return _isUnauthorizedMessage(messages);
  }

  bool _isUnauthorizedRawResponse(
    int statusCode,
    Map<String, dynamic> response,
  ) {
    return statusCode == 401 ||
        _isUnauthorizedMessage(graphQLRawErrorMessage(response));
  }

  bool _isUnauthorizedMessage(String message) {
    final normalized = message.toLowerCase();
    return normalized.contains('unauthorized') ||
        normalized.contains('unauthenticated') ||
        normalized.contains('token expired') ||
        normalized.contains('expired token') ||
        normalized.contains('invalid token');
  }

  bool _isInvalidRefreshMessage(String message) {
    final normalized = message.toLowerCase();
    return _isUnauthorizedMessage(message) ||
        (normalized.contains('refresh') &&
            (normalized.contains('invalid') ||
                normalized.contains('expired') ||
                normalized.contains('revoked')));
  }

  Stream<OperationResponse<TData, TVars>> _loggedRequest<TData, TVars>(
    OperationRequest<TData, TVars> request,
  ) async* {
    _logger.logRequest(request);
    var responseIndex = 0;

    try {
      await for (final response in _client.request(request)) {
        responseIndex += 1;
        _logGetChatMessagesResponse(request, response, responseIndex);
        _logger.logResponse(request, response);
        yield response;
      }
    } catch (error, stackTrace) {
      _logger.logException(request, error, stackTrace);
      rethrow;
    }
  }

  void _logGetChatMessagesResponse<TData, TVars>(
    OperationRequest<TData, TVars> request,
    OperationResponse<TData, TVars> response,
    int responseIndex,
  ) {
    if (!kDebugMode || request.operation.operationName != 'GetChatMessages') {
      return;
    }

    final graphqlErrors = response.graphqlErrors
            ?.map((error) => error.message)
            .where((message) => message.isNotEmpty)
            .toList() ??
        const <String>[];
    final errors = [
      ...graphqlErrors,
      if (response.linkException != null) response.linkException.toString(),
    ];

    debugPrint(
      '[ChatFerry][GetChatMessages] '
      'timestamp=${DateTime.now().toUtc().toIso8601String()} '
      'responseIndex=$responseIndex '
      'source=${_ferryDataSourceLabel(response.dataSource)} '
      'chatID=${_getChatID(request.vars)} '
      'messageCount=${_getChatMessageCount(response.data)} '
      'hasData=${response.data != null} '
      'hasErrors=${response.hasErrors} '
      'errors=${errors.isEmpty ? 'none' : errors.join(' | ')}',
    );
  }

  String _ferryDataSourceLabel(DataSource source) {
    return switch (source) {
      DataSource.Cache => 'cache',
      DataSource.Link => 'network',
      DataSource.Optimistic => 'optimistic',
      DataSource.None => 'none',
    };
  }

  String _getChatID(Object? vars) {
    try {
      final dynamic dynamicVars = vars;
      final json = dynamicVars?.toJson();
      if (json is Map) {
        return json['chatID']?.toString() ?? 'unknown';
      }
    } catch (_) {
      // Debug logging must never affect a request.
    }
    return 'unknown';
  }

  int _getChatMessageCount(Object? data) {
    try {
      final dynamic dynamicData = data;
      final messages = dynamicData?.getChatMessages;
      return messages is Iterable ? messages.length : 0;
    } catch (_) {
      // Debug logging must never affect a request.
      return 0;
    }
  }

  bool _isResolvedResponse<TData, TVars>(
    OperationResponse<TData, TVars> response,
  ) {
    return response.data != null || response.hasErrors;
  }
}

String graphQLRawErrorMessage(Map<String, dynamic> response) {
  final errors = response['errors'];
  if (errors is List && errors.isNotEmpty) {
    final message = errors
        .map((error) {
          if (error is Map<String, dynamic>) return error['message'];
          if (error is Map) return error['message'];
          return error;
        })
        .whereType<Object>()
        .map((error) => error.toString().trim())
        .where((message) => message.isNotEmpty)
        .join(', ');
    if (message.isNotEmpty) return message;
  }

  final message = response['message']?.toString().trim();
  return message == null || message.isEmpty
      ? 'GraphQL request failed'
      : message;
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
