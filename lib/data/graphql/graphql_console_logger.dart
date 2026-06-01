import 'package:ferry/ferry.dart';
import 'package:logger/logger.dart';

class GraphQLConsoleLogger {
  GraphQLConsoleLogger({
    required this.endpoint,
    Logger? logger,
  }) : _logger = logger ??
            Logger(
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

  void logRequest<TData, TVars>(OperationRequest<TData, TVars> request) {
    _logger.i({
      'graphql': 'request',
      'endpoint': endpoint,
      'operation': request.operation.operationName,
      'variables': _toLogValue(request.vars),
    });
  }

  void logResponse<TData, TVars>(
    OperationRequest<TData, TVars> request,
    OperationResponse<TData, TVars> response,
  ) {
    final payload = {
      'graphql': response.hasErrors ? 'error_response' : 'response',
      'endpoint': endpoint,
      'operation': request.operation.operationName,
      'data': _toLogValue(response.data),
      if (response.graphqlErrors?.isNotEmpty ?? false)
        'graphqlErrors': response.graphqlErrors
            ?.map(
              (error) => {
                'message': error.message,
                'locations': error.locations
                    ?.map((location) => {
                          'line': location.line,
                          'column': location.column,
                        })
                    .toList(),
                'path': error.path,
                'extensions': error.extensions,
              },
            )
            .toList(),
      if (response.linkException != null)
        'linkException': response.linkException.toString(),
    };

    if (response.hasErrors) {
      _logger.e(payload);
    } else {
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
        'endpoint': endpoint,
        'operation': request.operation.operationName,
        'error': error.toString(),
      },
      error: error,
      stackTrace: stackTrace,
    );
  }

  Object? _toLogValue(Object? value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool ||
        value is Map ||
        value is Iterable) {
      return value;
    }

    try {
      final dynamic dynamicValue = value;
      return dynamicValue.toJson();
    } catch (_) {
      return value.toString();
    }
  }
}
