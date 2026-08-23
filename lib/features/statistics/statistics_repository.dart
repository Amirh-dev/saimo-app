import 'package:ferry/ferry.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.req.gql.dart';

/// Shorter alias for the very long generated name.
typedef StatisticsDashboard = GStatisticsDashboardData_statisticsDashboard;

class StatisticsFailure implements Exception {
  const StatisticsFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class StatisticsRepository {
  const StatisticsRepository(this._client);

  final Client _client;

  Stream<StatisticsDashboard> watchDashboard({
    required DateTime start,
    required DateTime end,
    required DateTime previousStart,
    required DateTime previousEnd,
    FetchPolicy fetchPolicy = FetchPolicy.CacheAndNetwork,
  }) async* {
    final request = GStatisticsDashboardReq(
          (b) => b
        ..fetchPolicy = fetchPolicy
        ..vars.input.start.replace(_time(start))
        ..vars.input.end.replace(_time(end))
        ..vars.input.previousStart.replace(_time(previousStart))
        ..vars.input.previousEnd.replace(_time(previousEnd)),
    );

    await for (final response in _client.request(request)) {
      // First emission of CacheAndNetwork is usually an empty loading frame.
      if (response.loading && response.data == null) continue;

      if (response.hasErrors) {
        throw StatisticsFailure(_messageOf(response));
      }

      final dashboard = response.data?.statisticsDashboard;
      if (dashboard != null) yield dashboard;
    }
  }

  String _messageOf(OperationResponse response) {
    final errors = response.graphqlErrors;
    if (errors != null && errors.isNotEmpty) return errors.first.message;
    if (response.linkException != null) {
      return 'خطا در ارتباط با سرور. اتصال اینترنت را بررسی کنید.';
    }
    return 'خطای ناشناخته';
  }

  // The API wants a fixed Tehran offset, so we format the DateTime as a
  // wall-clock value and append +03:30 instead of using toIso8601String().
  static GTime _time(DateTime wallClock) => GTime(
    '${_pad(wallClock.year, 4)}-${_pad(wallClock.month, 2)}-${_pad(wallClock.day, 2)}'
        'T${_pad(wallClock.hour, 2)}:${_pad(wallClock.minute, 2)}:${_pad(wallClock.second, 2)}'
        '+03:30',
  );

  static String _pad(int value, int width) =>
      value.toString().padLeft(width, '0');
}