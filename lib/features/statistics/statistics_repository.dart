import 'package:ferry/ferry.dart';
import 'package:simo_learn/data/graphql/graphql_repository.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.req.gql.dart';

typedef StatisticsDashboard =
GStatisticsDashboardData_statisticsDashboard;

class StatisticsFailure implements Exception {
  const StatisticsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class StatisticsRepository {
  const StatisticsRepository(this._graphql);

  final GraphQLRepository _graphql;

  Future<StatisticsDashboard> fetchDashboard({
    required DateTime start,
    required DateTime end,
    required DateTime previousStart,
    required DateTime previousEnd,
    FetchPolicy fetchPolicy = FetchPolicy.NetworkOnly,
  }) async {
    final request = GStatisticsDashboardReq(
          (b) => b
        ..fetchPolicy = fetchPolicy
        ..vars.input.start.replace(_time(start))
        ..vars.input.end.replace(_time(end))
        ..vars.input.previousStart.replace(_time(previousStart))
        ..vars.input.previousEnd.replace(_time(previousEnd)),
    );

    final response = await _graphql.requestOnce(
      request,
    );

    if (response.hasErrors) {
      throw StatisticsFailure(
        _messageOf(response),
      );
    }

    final dashboard = response.data?.statisticsDashboard;

    if (dashboard == null) {
      throw const StatisticsFailure(
        'اطلاعات آمار از سرور دریافت نشد.',
      );
    }

    return dashboard;
  }

  String _messageOf(
      OperationResponse<dynamic, dynamic> response,
      ) {
    final graphqlErrors = response.graphqlErrors;

    if (graphqlErrors != null && graphqlErrors.isNotEmpty) {
      return graphqlErrors
          .map((error) => error.message)
          .where((message) => message.isNotEmpty)
          .join('\n');
    }

    if (response.linkException != null) {
      return 'خطا در ارتباط با سرور. اتصال اینترنت را بررسی کنید.';
    }

    return 'خطای ناشناخته در دریافت آمار.';
  }

  static GTime _time(DateTime wallClock) {
    return GTime(
      '${_pad(wallClock.year, 4)}-'
          '${_pad(wallClock.month, 2)}-'
          '${_pad(wallClock.day, 2)}'
          'T'
          '${_pad(wallClock.hour, 2)}:'
          '${_pad(wallClock.minute, 2)}:'
          '${_pad(wallClock.second, 2)}'
          '+03:30',
    );
  }

  static String _pad(int value, int width) {
    return value.toString().padLeft(width, '0');
  }
}