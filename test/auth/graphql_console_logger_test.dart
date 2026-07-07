import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:simo_learn/data/graphql/graphql_console_logger.dart';

void main() {
  test('extracts operation names from raw GraphQL documents', () {
    expect(
      graphQLOperationName('query SuggestUsername { ping }'),
      'SuggestUsername',
    );
    expect(
      graphQLOperationName('mutation UpdateProfile { ping }'),
      'UpdateProfile',
    );
    expect(graphQLOperationName('{ ping }'), 'AnonymousOperation');
  });

  test('raw debug logs correlate requests and redact credentials', () {
    final output = _MemoryLogOutput();
    final logger = _logger(output, detailedLogs: true);
    final context = logger.startRawRequest(
      query: 'query CheckUsernameAvailability { ping }',
      variables: {
        'username': 'ali',
        'phoneNumber': '09123456789',
        'code': '123456',
      },
      requiresAuth: false,
      attempt: 1,
    );

    logger.logRawResponse(
      context,
      statusCode: 200,
      decodedBody: {
        'data': {
          'checkUsernameAvailability': {
            'available': true,
            'accessToken': 'secret-token',
          },
        },
      },
    );

    final logs = output.text;
    expect(logs, contains('raw_request'));
    expect(logs, contains('raw_response'));
    expect(logs, contains('CheckUsernameAvailability'));
    expect(logs, contains('raw-1'));
    expect(logs, contains('ali'));
    expect(logs, isNot(contains('09123456789')));
    expect(logs, isNot(contains('123456')));
    expect(logs, isNot(contains('secret-token')));
  });

  test('production-style logs omit variables and response data', () {
    final output = _MemoryLogOutput();
    final logger = _logger(output, detailedLogs: false);
    final context = logger.startRawRequest(
      query: 'query SuggestUsername { ping }',
      variables: {'fullName': 'علی رضایی'},
      requiresAuth: false,
      attempt: 1,
    );

    logger.logRawResponse(
      context,
      statusCode: 200,
      decodedBody: {
        'data': {
          'suggestUsername': {'username': 'ali_rezaei'},
        },
      },
    );

    expect(output.text, contains('SuggestUsername'));
    expect(output.text, isNot(contains('علی رضایی')));
    expect(output.text, isNot(contains('ali_rezaei')));
  });
}

GraphQLConsoleLogger _logger(
  _MemoryLogOutput output, {
  required bool detailedLogs,
}) {
  return GraphQLConsoleLogger(
    endpoint: 'https://example.invalid/graphql',
    detailedLogs: detailedLogs,
    logSuccessfulOperations: true,
    logger: Logger(
      filter: _AlwaysLogFilter(),
      printer: SimplePrinter(colors: false),
      output: output,
    ),
  );
}

class _AlwaysLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => true;
}

class _MemoryLogOutput extends LogOutput {
  final events = <OutputEvent>[];

  String get text => events.expand((event) => event.lines).join('\n');

  @override
  void output(OutputEvent event) => events.add(event);
}
