import 'dart:convert';

import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
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
    return _loggedRequest(request).firstWhere(_isResolvedResponse);
  }

  void clearCache() {
    _client.cache.clear();
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

    // Decode the raw bytes as UTF-8 explicitly. `response.body` falls back to
    // Latin-1 when the server omits `charset=utf-8`, which turns Persian text
    // into mojibake (e.g. "تست" -> "ØªØ³Øª").
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map<String, dynamic>) {
      throw const GraphQLRawException('Invalid GraphQL response');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GraphQLRawException(
        graphQLRawErrorMessage(decoded),
      );
    }

    final errors = decoded['errors'];
    if (errors is List && errors.isNotEmpty) {
      throw GraphQLRawException(graphQLRawErrorMessage(decoded));
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
