// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart' show StandardJsonPlugin;
import 'package:ferry_exec/ferry_exec.dart';
import 'package:gql_code_builder/src/serializers/operation_serializer.dart'
    show OperationSerializer;
import 'package:simo_learn/graphql/__generated__/schema.schema.gql.dart'
    show
        GChatType,
        GCreateDirectChatInput,
        GCreateGoalInput,
        GCreateTaskInput,
        GCursor,
        GFriendshipStatus,
        GGoalOrder,
        GGoalOrderField,
        GGoalStatus,
        GGoalWhereInput,
        GInterestWhereInput,
        GMessageType,
        GOrderDirection,
        GRefreshTokenInput,
        GSendMessageInput,
        GSendOTPInput,
        GTagWhereInput,
        GTaskOrder,
        GTaskOrderField,
        GTaskStatus,
        GTaskType,
        GTaskWhereInput,
        GTime,
        GUUID,
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
import 'package:simo_learn/graphql/mutations/__generated__/create_task.data.gql.dart'
    show
        GCreateTaskData,
        GCreateTaskData_createTask,
        GCreateTaskData_createTask_tags;
import 'package:simo_learn/graphql/mutations/__generated__/create_task.req.gql.dart'
    show GCreateTaskReq;
import 'package:simo_learn/graphql/mutations/__generated__/create_task.var.gql.dart'
    show GCreateTaskVars;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.data.gql.dart'
    show GDeleteMessageData, GDeleteMessageData_deleteMessage;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.req.gql.dart'
    show GDeleteMessageReq;
import 'package:simo_learn/graphql/mutations/__generated__/delete_message.var.gql.dart'
    show GDeleteMessageVars;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.data.gql.dart'
    show
        GRefreshTokenData,
        GRefreshTokenData_refreshToken,
        GRefreshTokenData_refreshToken_user;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.req.gql.dart'
    show GRefreshTokenReq;
import 'package:simo_learn/graphql/mutations/__generated__/refresh_token.var.gql.dart'
    show GRefreshTokenVars;
import 'package:simo_learn/graphql/mutations/__generated__/send_message.data.gql.dart'
    show
        GSendMessageData,
        GSendMessageData_sendMessage,
        GSendMessageData_sendMessage_replyTo,
        GSendMessageData_sendMessage_sender;
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

part 'serializers.gql.g.dart';

final SerializersBuilder _serializersBuilder = _$serializers.toBuilder()
  ..add(OperationSerializer())
  ..addPlugin(StandardJsonPlugin());
@SerializersFor([
  GChatType,
  GCreateDirectChatData,
  GCreateDirectChatData_createDirectChat,
  GCreateDirectChatInput,
  GCreateDirectChatReq,
  GCreateDirectChatVars,
  GCreateGoalInput,
  GCreateTaskData,
  GCreateTaskData_createTask,
  GCreateTaskData_createTask_tags,
  GCreateTaskInput,
  GCreateTaskReq,
  GCreateTaskVars,
  GCursor,
  GDeleteMessageData,
  GDeleteMessageData_deleteMessage,
  GDeleteMessageReq,
  GDeleteMessageVars,
  GFriendshipStatus,
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
  GMessageType,
  GOrderDirection,
  GRefreshTokenData,
  GRefreshTokenData_refreshToken,
  GRefreshTokenData_refreshToken_user,
  GRefreshTokenInput,
  GRefreshTokenReq,
  GRefreshTokenVars,
  GSendMessageData,
  GSendMessageData_sendMessage,
  GSendMessageData_sendMessage_replyTo,
  GSendMessageData_sendMessage_sender,
  GSendMessageInput,
  GSendMessageReq,
  GSendMessageVars,
  GSendOTPData,
  GSendOTPData_sendOTP,
  GSendOTPInput,
  GSendOTPReq,
  GSendOTPVars,
  GTagWhereInput,
  GTaskOrder,
  GTaskOrderField,
  GTaskStatus,
  GTaskType,
  GTaskWhereInput,
  GTime,
  GUUID,
  GUpdateGoalInput,
  GUpdateProfileInput,
  GUpdateTaskInput,
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
