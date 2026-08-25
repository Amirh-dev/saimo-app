// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' show StandardJsonPlugin;
import 'package:ferry_exec/ferry_exec.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    show OperationSerializer;
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart'
    show
        GAuthSessionOrder,
        GAuthSessionOrderField,
        GAuthSessionWhereInput,
        GBeginCounselingPaymentInput,
        GChatOrder,
        GChatOrderField,
        GChatParticipantOrder,
        GChatParticipantOrderField,
        GChatParticipantWhereInput,
        GChatType,
        GChatWhereInput,
        GCounselingPaymentAttemptCurrency,
        GCounselingPaymentAttemptStatus,
        GCounselingSubscriptionCancellationReason,
        GCounselingSubscriptionCurrency,
        GCounselingSubscriptionOrder,
        GCounselingSubscriptionOrderField,
        GCounselingSubscriptionPlanType,
        GCounselingSubscriptionStatus,
        GCounselingSubscriptionWhereInput,
        GCounselorProfileOrder,
        GCounselorProfileOrderField,
        GCounselorProfileWhereInput,
        GCounselorReviewOrder,
        GCounselorReviewOrderField,
        GCounselorReviewWhereInput,
        GCreateDirectChatInput,
        GCreateGoalInput,
        GCreateGroupChatInput,
        GCreateTaskInput,
        GCursor,
        GDeviceTokenOrder,
        GDeviceTokenOrderField,
        GDeviceTokenPlatform,
        GDeviceTokenWhereInput,
        GFriendshipOrder,
        GFriendshipOrderField,
        GFriendshipStatus,
        GFriendshipWhereInput,
        GGoalOrder,
        GGoalOrderField,
        GGoalStatus,
        GGoalWhereInput,
        GInterestWhereInput,
        GMessageOrder,
        GMessageOrderField,
        GMessageType,
        GMessageWhereInput,
        GOTPClient,
        GOrderDirection,
        GRefreshTokenInput,
        GRequestCounselingInput,
        GSaveTaskCompletionReportInput,
        GSendMessageInput,
        GSendOTPInput,
        GStatisticsDashboardInput,
        GSubmitCounselorReviewInput,
        GTagKeywordWhereInput,
        GTagKind,
        GTagModerationStatus,
        GTagWhereInput,
        GTaskCompletionReportOrder,
        GTaskCompletionReportOrderField,
        GTaskCompletionReportWhereInput,
        GTaskOrder,
        GTaskOrderField,
        GTaskStatus,
        GTaskType,
        GTaskWhereInput,
        GTime,
        GUUID,
        GUpdateCounselorProfileInput,
        GUpdateGoalInput,
        GUpdateProfileInput,
        GUpdateTaskInput,
        GUserOrder,
        GUserOrderField,
        GUserRole,
        GUserStudyTime,
        GUserWhereInput,
        GVerifyOTPAndLoginInput,
        GVerifyOTPAndRegisterInput;
import 'package:simo_learn/graphql/mutations/__generated__/create_direct_chat.data.gql.dart'
    show GCreateDirectChatData, GCreateDirectChatData_createDirectChat;
import 'package:simo_learn/graphql/mutations/__generated__/create_direct_chat.req.gql.dart'
    show GCreateDirectChatReq;
import 'package:simo_learn/graphql/mutations/__generated__/create_direct_chat.var.gql.dart'
    show GCreateDirectChatVars;
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.data.gql.dart'
    show GCreateGoalData, GCreateGoalData_createGoal;
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.req.gql.dart'
    show GCreateGoalReq;
import 'package:simo_learn/graphql/mutations/__generated__/create_goal.var.gql.dart'
    show GCreateGoalVars;
import 'package:simo_learn/graphql/mutations/__generated__/create_task.data.gql.dart'
    show GCreateTaskData, GCreateTaskData_createTask;
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart'
    show GCreateTaskReq;
import 'package:simo_learn/graphql/mutations/__generated__/create_task.var.gql.dart'
    show GCreateTaskVars;
import 'package:simo_learn/graphql/mutations/__generated__/delete_goal.data.gql.dart'
    show GDeleteGoalData;
import 'package:simo_learn/graphql/mutations/__generated__/delete_goal.req.gql.dart'
    show GDeleteGoalReq;
import 'package:simo_learn/graphql/mutations/__generated__/delete_goal.var.gql.dart'
    show GDeleteGoalVars;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.data.gql.dart'
    show GDeleteMessageData, GDeleteMessageData_deleteMessage;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.req.gql.dart'
    show GDeleteMessageReq;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.var.gql.dart'
    show GDeleteMessageVars;
import 'package:simo_learn/graphql/mutations/__generated__/delete_task.data.gql.dart'
    show GDeleteTaskData;
import 'package:simo_learn/graphql/mutations/__generated__/delete_task.req.gql.dart'
    show GDeleteTaskReq;
import 'package:simo_learn/graphql/mutations/__generated__/delete_task.var.gql.dart'
    show GDeleteTaskVars;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.data.gql.dart'
    show
        GRefreshTokenData,
        GRefreshTokenData_refreshToken,
        GRefreshTokenData_refreshToken_user;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart'
    show GRefreshTokenReq;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.var.gql.dart'
    show GRefreshTokenVars;
import 'package:simo_learn/graphql/mutations/__generated__/register_device_token.data.gql.dart'
    show GRegisterDeviceTokenData;
import 'package:simo_learn/graphql/mutations/__generated__/register_device_token.req.gql.dart'
    show GRegisterDeviceTokenReq;
import 'package:simo_learn/graphql/mutations/__generated__/register_device_token.var.gql.dart'
    show GRegisterDeviceTokenVars;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.data.gql.dart'
    show GSendMessageData, GSendMessageData_sendMessage;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.req.gql.dart'
    show GSendMessageReq;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.var.gql.dart'
    show GSendMessageVars;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.data.gql.dart'
    show GSendOTPData, GSendOTPData_sendOTP;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.req.gql.dart'
    show GSendOTPReq;
import 'package:simo_learn/graphql/mutations/__generated__/send_otp.var.gql.dart'
    show GSendOTPVars;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.data.gql.dart'
    show GUnregisterDeviceTokenData;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.req.gql.dart'
    show GUnregisterDeviceTokenReq;
import 'package:simo_learn/graphql/mutations/__generated__/unregister_device_token.var.gql.dart'
    show GUnregisterDeviceTokenVars;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.data.gql.dart'
    show GUpdateGoalData, GUpdateGoalData_updateGoal;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.req.gql.dart'
    show GUpdateGoalReq;
import 'package:simo_learn/graphql/mutations/__generated__/update_goal.var.gql.dart'
    show GUpdateGoalVars;
import 'package:simo_learn/graphql/mutations/__generated__/update_task.data.gql.dart'
    show GUpdateTaskData, GUpdateTaskData_updateTask;
import 'package:simo_learn/graphql/mutations/__generated__/update_task.req.gql.dart'
    show GUpdateTaskReq;
import 'package:simo_learn/graphql/mutations/__generated__/update_task.var.gql.dart'
    show GUpdateTaskVars;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.data.gql.dart'
    show
        GVerifyOTPAndLoginData,
        GVerifyOTPAndLoginData_verifyOTPAndLogin,
        GVerifyOTPAndLoginData_verifyOTPAndLogin_user;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.req.gql.dart'
    show GVerifyOTPAndLoginReq;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_login.var.gql.dart'
    show GVerifyOTPAndLoginVars;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.data.gql.dart'
    show
        GVerifyOTPAndRegisterData,
        GVerifyOTPAndRegisterData_verifyOTPAndRegister,
        GVerifyOTPAndRegisterData_verifyOTPAndRegister_user;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.req.gql.dart'
    show GVerifyOTPAndRegisterReq;
import 'package:simo_learn/graphql/mutations/__generated__/verify_otp_register.var.gql.dart'
    show GVerifyOTPAndRegisterVars;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.data.gql.dart'
    show
        GGetChatMessagesData,
        GGetChatMessagesData_getChatMessages,
        GGetChatMessagesData_getChatMessages_replyTo,
        GGetChatMessagesData_getChatMessages_sender;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.req.gql.dart'
    show GGetChatMessagesReq;
import 'package:simo_learn/graphql/queries/__generated__/get_chat_messages.var.gql.dart'
    show GGetChatMessagesVars;
import 'package:simo_learn/graphql/queries/__generated__/get_friends.data.gql.dart'
    show
        GGetFriendsData,
        GGetFriendsData_getFriends,
        GGetFriendsData_getFriends_receiver,
        GGetFriendsData_getFriends_requester;
import 'package:simo_learn/graphql/queries/__generated__/get_friends.req.gql.dart'
    show GGetFriendsReq;
import 'package:simo_learn/graphql/queries/__generated__/get_friends.var.gql.dart'
    show GGetFriendsVars;
import 'package:simo_learn/graphql/queries/__generated__/get_goals.data.gql.dart'
    show GGetGoalsData, GGetGoalsData_getGoals;
import 'package:simo_learn/graphql/queries/__generated__/get_goals.req.gql.dart'
    show GGetGoalsReq;
import 'package:simo_learn/graphql/queries/__generated__/get_goals.var.gql.dart'
    show GGetGoalsVars;
import 'package:simo_learn/graphql/queries/__generated__/get_me.data.gql.dart'
    show GGetMeData, GGetMeData_getMe;
import 'package:simo_learn/graphql/queries/__generated__/get_me.req.gql.dart'
    show GGetMeReq;
import 'package:simo_learn/graphql/queries/__generated__/get_me.var.gql.dart'
    show GGetMeVars;
import 'package:simo_learn/graphql/queries/__generated__/get_tasks.data.gql.dart'
    show
        GGetTasksData,
        GGetTasksData_getTasks,
        GGetTasksData_getTasks_goal,
        GGetTasksData_getTasks_tags;
import 'package:simo_learn/graphql/queries/__generated__/get_tasks.req.gql.dart'
    show GGetTasksReq;
import 'package:simo_learn/graphql/queries/__generated__/get_tasks.var.gql.dart'
    show GGetTasksVars;
import 'package:simo_learn/graphql/queries/__generated__/parent_tags.data.gql.dart'
    show GParentTagsData, GParentTagsData_parentTags;
import 'package:simo_learn/graphql/queries/__generated__/parent_tags.req.gql.dart'
    show GParentTagsReq;
import 'package:simo_learn/graphql/queries/__generated__/parent_tags.var.gql.dart'
    show GParentTagsVars;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.data.gql.dart'
    show
        GStatisticsDashboardData,
        GStatisticsDashboardData_statisticsDashboard,
        GStatisticsDashboardData_statisticsDashboard_comparison,
        GStatisticsDashboardData_statisticsDashboard_comparison_current,
        GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted,
        GStatisticsDashboardData_statisticsDashboard_comparison_previous,
        GStatisticsDashboardData_statisticsDashboard_dailyBuckets,
        GStatisticsDashboardData_statisticsDashboard_subjectBuckets;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.req.gql.dart'
    show GStatisticsDashboardReq;
import 'package:simo_learn/graphql/queries/__generated__/statistics_dashboard.var.gql.dart'
    show GStatisticsDashboardVars;

part 'serializers.gql.g.dart';

final SerializersBuilder _serializersBuilder = _$serializers.toBuilder()
  ..add(OperationSerializer())
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GAuthSessionOrder,
  GAuthSessionOrderField,
  GAuthSessionWhereInput,
  GBeginCounselingPaymentInput,
  GChatOrder,
  GChatOrderField,
  GChatParticipantOrder,
  GChatParticipantOrderField,
  GChatParticipantWhereInput,
  GChatType,
  GChatWhereInput,
  GCounselingPaymentAttemptCurrency,
  GCounselingPaymentAttemptStatus,
  GCounselingSubscriptionCancellationReason,
  GCounselingSubscriptionCurrency,
  GCounselingSubscriptionOrder,
  GCounselingSubscriptionOrderField,
  GCounselingSubscriptionPlanType,
  GCounselingSubscriptionStatus,
  GCounselingSubscriptionWhereInput,
  GCounselorProfileOrder,
  GCounselorProfileOrderField,
  GCounselorProfileWhereInput,
  GCounselorReviewOrder,
  GCounselorReviewOrderField,
  GCounselorReviewWhereInput,
  GCreateDirectChatData,
  GCreateDirectChatData_createDirectChat,
  GCreateDirectChatInput,
  GCreateDirectChatReq,
  GCreateDirectChatVars,
  GCreateGoalData,
  GCreateGoalData_createGoal,
  GCreateGoalInput,
  GCreateGoalReq,
  GCreateGoalVars,
  GCreateGroupChatInput,
  GCreateTaskData,
  GCreateTaskData_createTask,
  GCreateTaskInput,
  GCreateTaskReq,
  GCreateTaskVars,
  GCursor,
  GDeleteGoalData,
  GDeleteGoalReq,
  GDeleteGoalVars,
  GDeleteMessageData,
  GDeleteMessageData_deleteMessage,
  GDeleteMessageReq,
  GDeleteMessageVars,
  GDeleteTaskData,
  GDeleteTaskReq,
  GDeleteTaskVars,
  GDeviceTokenOrder,
  GDeviceTokenOrderField,
  GDeviceTokenPlatform,
  GDeviceTokenWhereInput,
  GFriendshipOrder,
  GFriendshipOrderField,
  GFriendshipStatus,
  GFriendshipWhereInput,
  GGetChatMessagesData,
  GGetChatMessagesData_getChatMessages,
  GGetChatMessagesData_getChatMessages_replyTo,
  GGetChatMessagesData_getChatMessages_sender,
  GGetChatMessagesReq,
  GGetChatMessagesVars,
  GGetFriendsData,
  GGetFriendsData_getFriends,
  GGetFriendsData_getFriends_receiver,
  GGetFriendsData_getFriends_requester,
  GGetFriendsReq,
  GGetFriendsVars,
  GGetGoalsData,
  GGetGoalsData_getGoals,
  GGetGoalsReq,
  GGetGoalsVars,
  GGetMeData,
  GGetMeData_getMe,
  GGetMeReq,
  GGetMeVars,
  GGetTasksData,
  GGetTasksData_getTasks,
  GGetTasksData_getTasks_goal,
  GGetTasksData_getTasks_tags,
  GGetTasksReq,
  GGetTasksVars,
  GGoalOrder,
  GGoalOrderField,
  GGoalStatus,
  GGoalWhereInput,
  GInterestWhereInput,
  GMessageOrder,
  GMessageOrderField,
  GMessageType,
  GMessageWhereInput,
  GOTPClient,
  GOrderDirection,
  GParentTagsData,
  GParentTagsData_parentTags,
  GParentTagsReq,
  GParentTagsVars,
  GRefreshTokenData,
  GRefreshTokenData_refreshToken,
  GRefreshTokenData_refreshToken_user,
  GRefreshTokenInput,
  GRefreshTokenReq,
  GRefreshTokenVars,
  GRegisterDeviceTokenData,
  GRegisterDeviceTokenReq,
  GRegisterDeviceTokenVars,
  GRequestCounselingInput,
  GSaveTaskCompletionReportInput,
  GSendMessageData,
  GSendMessageData_sendMessage,
  GSendMessageInput,
  GSendMessageReq,
  GSendMessageVars,
  GSendOTPData,
  GSendOTPData_sendOTP,
  GSendOTPInput,
  GSendOTPReq,
  GSendOTPVars,
  GStatisticsDashboardData,
  GStatisticsDashboardData_statisticsDashboard,
  GStatisticsDashboardData_statisticsDashboard_comparison,
  GStatisticsDashboardData_statisticsDashboard_comparison_current,
  GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted,
  GStatisticsDashboardData_statisticsDashboard_comparison_previous,
  GStatisticsDashboardData_statisticsDashboard_dailyBuckets,
  GStatisticsDashboardData_statisticsDashboard_subjectBuckets,
  GStatisticsDashboardInput,
  GStatisticsDashboardReq,
  GStatisticsDashboardVars,
  GSubmitCounselorReviewInput,
  GTagKeywordWhereInput,
  GTagKind,
  GTagModerationStatus,
  GTagWhereInput,
  GTaskCompletionReportOrder,
  GTaskCompletionReportOrderField,
  GTaskCompletionReportWhereInput,
  GTaskOrder,
  GTaskOrderField,
  GTaskStatus,
  GTaskType,
  GTaskWhereInput,
  GTime,
  GUUID,
  GUnregisterDeviceTokenData,
  GUnregisterDeviceTokenReq,
  GUnregisterDeviceTokenVars,
  GUpdateCounselorProfileInput,
  GUpdateGoalData,
  GUpdateGoalData_updateGoal,
  GUpdateGoalInput,
  GUpdateGoalReq,
  GUpdateGoalVars,
  GUpdateProfileInput,
  GUpdateTaskData,
  GUpdateTaskData_updateTask,
  GUpdateTaskInput,
  GUpdateTaskReq,
  GUpdateTaskVars,
  GUserOrder,
  GUserOrderField,
  GUserRole,
  GUserStudyTime,
  GUserWhereInput,
  GVerifyOTPAndLoginData,
  GVerifyOTPAndLoginData_verifyOTPAndLogin,
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user,
  GVerifyOTPAndLoginInput,
  GVerifyOTPAndLoginReq,
  GVerifyOTPAndLoginVars,
  GVerifyOTPAndRegisterData,
  GVerifyOTPAndRegisterData_verifyOTPAndRegister,
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user,
  GVerifyOTPAndRegisterInput,
  GVerifyOTPAndRegisterReq,
  GVerifyOTPAndRegisterVars,
])
final Serializers serializers = _serializersBuilder.build();
