import 'package:ferry/ferry.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class RawGraphQLLogContext {
  RawGraphQLLogContext({
    required this.requestId,
    required this.operation,
  }) : stopwatch = Stopwatch()..start();

  final String requestId;
  final String operation;
  final Stopwatch stopwatch;
}

class GraphQLConsoleLogger {
  GraphQLConsoleLogger({
    required this.endpoint,
    Logger? logger,
    bool? detailedLogs,
    bool? logSuccessfulOperations,
  })  : _detailedLogs = detailedLogs ?? kDebugMode,
        _logSuccessfulOperations = logSuccessfulOperations ?? !kReleaseMode,
        _logger = logger ??
            Logger(
              // Success traffic is gated below. Keep sanitized errors visible
              // in release application/device logs.
              filter: ProductionFilter(),
              printer: PrettyPrinter(
                methodCount: 0,
                errorMethodCount: 5,
                lineLength: 120,
                colors: true,
                printEmojis: false,
                dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
              ),
            );

  final String endpoint;
  final Logger _logger;
  final bool _detailedLogs;
  final bool _logSuccessfulOperations;
  int _rawRequestSequence = 0;

  void logRequest<TData, TVars>(OperationRequest<TData, TVars> request) {
    if (!_logSuccessfulOperations) return;
    _logger.i({
      'graphql': 'request',
      'operation': request.operation.operationName,
      if (_detailedLogs) 'endpoint': endpoint,
      if (_detailedLogs) 'variables': _toLogValue(request.vars),
    });
  }

  void logResponse<TData, TVars>(
    OperationRequest<TData, TVars> request,
    OperationResponse<TData, TVars> response,
  ) {
    final payload = {
      'graphql': response.hasErrors ? 'error_response' : 'response',
      'operation': request.operation.operationName,
      if (_detailedLogs) 'endpoint': endpoint,
      if (_detailedLogs) 'data': _toLogValue(response.data),
      if (response.graphqlErrors?.isNotEmpty ?? false)
        'graphqlErrors': response.graphqlErrors
            ?.map(
              (error) => {
                if (_detailedLogs) 'message': error.message,
                if (_detailedLogs)
                  'locations': error.locations
                      ?.map((location) => {
                            'line': location.line,
                            'column': location.column,
                          })
                      .toList(),
                if (_detailedLogs) 'path': error.path,
                if (_detailedLogs) 'extensions': error.extensions,
                if (!_detailedLogs && error.extensions?['code'] != null)
                  'code': error.extensions?['code'],
              },
            )
            .toList(),
      if (_detailedLogs && response.linkException != null)
        'linkException': response.linkException.toString(),
      if (!_detailedLogs && response.linkException != null)
        'linkExceptionType': response.linkException.runtimeType.toString(),
    };

    if (response.hasErrors) {
      _logger.e(payload);
    } else if (_logSuccessfulOperations) {
      _logger.d(payload);
    }
  }

  void logException<TData, TVars>(
    OperationRequest<TData, TVars> request,
    Object error,
    StackTrace stackTrace,
  ) {
    _logger.e(
      {
        'graphql': 'exception',
        'operation': request.operation.operationName,
        if (_detailedLogs) 'endpoint': endpoint,
        'errorType': error.runtimeType.toString(),
        if (_detailedLogs) 'error': error.toString(),
      },
      error: _detailedLogs ? error : null,
      stackTrace: _detailedLogs ? stackTrace : null,
    );
  }

  RawGraphQLLogContext startRawRequest({
    required String query,
    required Map<String, dynamic> variables,
    required bool requiresAuth,
    required int attempt,
  }) {
    final context = RawGraphQLLogContext(
      requestId: 'raw-${++_rawRequestSequence}',
      operation: graphQLOperationName(query),
    );
    if (_logSuccessfulOperations) {
      _logger.i({
        'graphql': 'raw_request',
        'requestId': context.requestId,
        'operation': context.operation,
        'attempt': attempt,
        'requiresAuth': requiresAuth,
        if (_detailedLogs) 'endpoint': endpoint,
        if (_detailedLogs) 'variables': _toLogValue(variables),
      });
    }
    return context;
  }

  void logRawResponse(
    RawGraphQLLogContext context, {
    required int statusCode,
    required Object? decodedBody,
  }) {
    context.stopwatch.stop();
    final body = decodedBody is Map ? decodedBody : const <String, dynamic>{};
    final errors = body['errors'];
    final hasErrors = statusCode < 200 ||
        statusCode >= 300 ||
        (errors is List && errors.isNotEmpty);
    final payload = {
      'graphql': hasErrors ? 'raw_error_response' : 'raw_response',
      'requestId': context.requestId,
      'operation': context.operation,
      'statusCode': statusCode,
      'durationMs': context.stopwatch.elapsedMilliseconds,
      if (_detailedLogs) 'data': _toLogValue(body['data']),
      if (_detailedLogs && errors is List) 'graphqlErrors': _toLogValue(errors),
    };

    if (hasErrors) {
      _logger.e(payload);
    } else if (_logSuccessfulOperations) {
      _logger.d(payload);
    }
  }

  void logRawException(
    RawGraphQLLogContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    context.stopwatch.stop();
    _logger.e(
      {
        'graphql': 'raw_exception',
        'requestId': context.requestId,
        'operation': context.operation,
        'durationMs': context.stopwatch.elapsedMilliseconds,
        'errorType': error.runtimeType.toString(),
        if (_detailedLogs) 'error': error.toString(),
      },
      error: _detailedLogs ? error : null,
      stackTrace: _detailedLogs ? stackTrace : null,
    );
  }

  Object? _toLogValue(Object? value) {
    Object? serializableValue = value;

    if (value != null &&
        value is! String &&
        value is! num &&
        value is! bool &&
        value is! Map &&
        value is! Iterable) {
      try {
        final dynamic dynamicValue = value;
        serializableValue = dynamicValue.toJson();
      } catch (_) {
        serializableValue = value.toString();
      }
    }

    return _redactSensitiveFields(serializableValue);
  }

  Object? _redactSensitiveFields(Object? value) {
    if (value is Map) {
      return value.map((key, nestedValue) {
        final fieldName = key.toString();
        if (_sensitiveFieldNames.contains(fieldName.toLowerCase())) {
          final sensitiveValue = nestedValue?.toString() ?? '';
          return MapEntry(
            key,
            '<redacted exists=${sensitiveValue.isNotEmpty} '
            'length=${sensitiveValue.length}>',
          );
        }
        return MapEntry(key, _redactSensitiveFields(nestedValue));
      });
    }

    if (value is Iterable) {
      return value.map(_redactSensitiveFields).toList();
    }

    return value;
  }
}

const _sensitiveFieldNames = {
  'accesstoken',
  'refreshtoken',
  'code',
  'otp',
  'phonenumber',
  'password',
};

String graphQLOperationName(String document) {
  final match = RegExp(
    r'\b(?:query|mutation|subscription)\s+([_A-Za-z][_0-9A-Za-z]*)',
  ).firstMatch(document);
  return match?.group(1) ?? 'AnonymousOperation';
}
