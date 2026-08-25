import 'package:ferry/ferry.dart';
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/delete_goal.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/delete_goal.req.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.data.gql.dart';
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.req.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_goals.data.gql.dart';
import 'package:simo_learn/graphql/queries/__generated__/get_goals.req.gql.dart';

typedef Goal = GGetGoalsData_getGoals;

class GoalsFailure implements Exception {
  const GoalsFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class GoalsRepository {
  const GoalsRepository(this._client);

  final Client _client;

  Future<List<Goal>> getGoals() async {
    final request = GGetGoalsReq(
          (b) => b..fetchPolicy = FetchPolicy.NetworkOnly,
    );

    final response = await _client.request(request).first;

    if (response.hasErrors) {
      throw GoalsFailure(_messageOf(response));
    }

    return response.data?.getGoals.toList() ?? <Goal>[];
  }

  Future<GCreateGoalData_createGoal> createGoal({
    required String title,
    String? note,
    DateTime? targetDate,
  }) async {
    final request = GCreateGoalReq(
          (b) => b
        ..vars.input.title = title
        ..vars.input.note = note
        ..vars.input.targetDate.value =
        targetDate?.toUtc().toIso8601String(),
    );

    final response = await _client.request(request).first;

    if (response.hasErrors) {
      throw GoalsFailure(_messageOf(response));
    }

    final goal = response.data?.createGoal;

    if (goal == null) {
      throw const GoalsFailure('هدف ایجاد نشد.');
    }

    return goal;
  }

  Future<GUpdateGoalData_updateGoal> updateGoal({
    required String id,
    required String title,
    String? note,
    DateTime? targetDate,
  }) async {
    final request = GUpdateGoalReq(
          (b) => b
        ..vars.id = id
        ..vars.input.title = title
        ..vars.input.note = note
        ..vars.input.targetDate.value =
        targetDate?.toUtc().toIso8601String(),
    );

    final response = await _client.request(request).first;

    if (response.hasErrors) {
      throw GoalsFailure(_messageOf(response));
    }

    final goal = response.data?.updateGoal;

    if (goal == null) {
      throw const GoalsFailure('ویرایش هدف انجام نشد.');
    }

    return goal;
  }

  Future<bool> deleteGoal(String id) async {
    final request = GDeleteGoalReq(
          (b) => b.vars.id = id,
    );

    final response = await _client.request(request).first;

    if (response.hasErrors) {
      throw GoalsFailure(_messageOf(response));
    }

    final deleted = response.data?.deleteGoal;

    if (deleted == null) {
      throw const GoalsFailure('پاسخ حذف هدف نامعتبر است.');
    }

    return deleted;
  }

  String _messageOf(OperationResponse response) {
    final errors = response.graphqlErrors;

    if (errors != null && errors.isNotEmpty) {
      return errors.first.message;
    }

    if (response.linkException != null) {
      return 'خطا در ارتباط با سرور. اتصال اینترنت را بررسی کنید.';
    }

    return 'خطای ناشناخته';
  }
}