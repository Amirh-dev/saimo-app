import 'package:simo_learn/data/graphql/graphql_repository.dart';

import 'package:simo_learn/graphql/mutations/__generated__/start_timed_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/pause_timed_task.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/complete_timed_task.req.gql.dart';

class TaskTimerRepository {
  final GraphQLRepository graphQLRepository;

  TaskTimerRepository(this.graphQLRepository);

  Future<dynamic> startTimedTask(String id) async {
    final response = await graphQLRepository.requestOnce(
      GStartTimedTaskReq(
        (b) => b..vars.id = id,
      ),
    );

    if (response.hasErrors) {
      throw Exception(
        response.graphqlErrors?.first.message ?? "Start timer failed",
      );
    }

    return response.data?.startTimedTask;
  }

  Future<dynamic> pauseTimedTask(String id) async {
    final response = await graphQLRepository.requestOnce(
      GPauseTimedTaskReq(
        (b) => b..vars.id = id,
      ),
    );

    if (response.hasErrors) {
      throw Exception(
        response.graphqlErrors?.first.message ?? "Pause timer failed",
      );
    }

    return response.data?.pauseTimedTask;
  }

  Future<dynamic> completeTimedTask(String id) async {
    final response = await graphQLRepository.requestOnce(
      GCompleteTimedTaskReq(
        (b) => b..vars.id = id,
      ),
    );

    if (response.hasErrors) {
      throw Exception(
        response.graphqlErrors?.first.message ?? "Complete timer failed",
      );
    }

    return response.data?.completeTimedTask;
  }
}
