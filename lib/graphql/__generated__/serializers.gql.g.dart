// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (new Serializers().toBuilder()
      ..add(FetchPolicy.serializer)
      ..add(GChatType.serializer)
      ..add(GCreateDirectChatData.serializer)
      ..add(GCreateDirectChatData_createDirectChat.serializer)
      ..add(GCreateDirectChatInput.serializer)
      ..add(GCreateDirectChatReq.serializer)
      ..add(GCreateDirectChatVars.serializer)
      ..add(GCreateGoalInput.serializer)
      ..add(GCreateTaskData.serializer)
      ..add(GCreateTaskData_createTask.serializer)
      ..add(GCreateTaskData_createTask_tags.serializer)
      ..add(GCreateTaskInput.serializer)
      ..add(GCreateTaskReq.serializer)
      ..add(GCreateTaskVars.serializer)
      ..add(GCursor.serializer)
      ..add(GDeleteMessageData.serializer)
      ..add(GDeleteMessageData_deleteMessage.serializer)
      ..add(GDeleteMessageReq.serializer)
      ..add(GDeleteMessageVars.serializer)
      ..add(GFriendshipStatus.serializer)
      ..add(GGetChatMessagesData.serializer)
      ..add(GGetChatMessagesData_getChatMessages.serializer)
      ..add(GGetChatMessagesData_getChatMessages_replyTo.serializer)
      ..add(GGetChatMessagesData_getChatMessages_sender.serializer)
      ..add(GGetChatMessagesReq.serializer)
      ..add(GGetChatMessagesVars.serializer)
      ..add(GGetFriendsData.serializer)
      ..add(GGetFriendsData_getFriends.serializer)
      ..add(GGetFriendsData_getFriends_receiver.serializer)
      ..add(GGetFriendsData_getFriends_requester.serializer)
      ..add(GGetFriendsReq.serializer)
      ..add(GGetFriendsVars.serializer)
      ..add(GGetMeData.serializer)
      ..add(GGetMeData_getMe.serializer)
      ..add(GGetMeReq.serializer)
      ..add(GGetMeVars.serializer)
      ..add(GGetTasksData.serializer)
      ..add(GGetTasksData_getTasks.serializer)
      ..add(GGetTasksData_getTasks_goal.serializer)
      ..add(GGetTasksData_getTasks_tags.serializer)
      ..add(GGetTasksReq.serializer)
      ..add(GGetTasksVars.serializer)
      ..add(GGoalOrder.serializer)
      ..add(GGoalOrderField.serializer)
      ..add(GGoalStatus.serializer)
      ..add(GGoalWhereInput.serializer)
      ..add(GInterestWhereInput.serializer)
      ..add(GMessageType.serializer)
      ..add(GOrderDirection.serializer)
      ..add(GRefreshTokenData.serializer)
      ..add(GRefreshTokenData_refreshToken.serializer)
      ..add(GRefreshTokenData_refreshToken_user.serializer)
      ..add(GRefreshTokenInput.serializer)
      ..add(GRefreshTokenReq.serializer)
      ..add(GRefreshTokenVars.serializer)
      ..add(GSendMessageData.serializer)
      ..add(GSendMessageData_sendMessage.serializer)
      ..add(GSendMessageInput.serializer)
      ..add(GSendMessageReq.serializer)
      ..add(GSendMessageVars.serializer)
      ..add(GSendOTPData.serializer)
      ..add(GSendOTPData_sendOTP.serializer)
      ..add(GSendOTPInput.serializer)
      ..add(GSendOTPReq.serializer)
      ..add(GSendOTPVars.serializer)
      ..add(GTagWhereInput.serializer)
      ..add(GTaskOrder.serializer)
      ..add(GTaskOrderField.serializer)
      ..add(GTaskStatus.serializer)
      ..add(GTaskType.serializer)
      ..add(GTaskWhereInput.serializer)
      ..add(GTime.serializer)
      ..add(GUUID.serializer)
      ..add(GUpdateGoalInput.serializer)
      ..add(GUpdateProfileInput.serializer)
      ..add(GUpdateTaskInput.serializer)
      ..add(GUserOrder.serializer)
      ..add(GUserOrderField.serializer)
      ..add(GUserRole.serializer)
      ..add(GUserStudyTime.serializer)
      ..add(GUserWhereInput.serializer)
      ..add(GVerifyOTPAndLoginData.serializer)
      ..add(GVerifyOTPAndLoginData_verifyOTPAndLogin.serializer)
      ..add(GVerifyOTPAndLoginData_verifyOTPAndLogin_user.serializer)
      ..add(GVerifyOTPAndLoginInput.serializer)
      ..add(GVerifyOTPAndLoginReq.serializer)
      ..add(GVerifyOTPAndLoginVars.serializer)
      ..add(GVerifyOTPAndRegisterData.serializer)
      ..add(GVerifyOTPAndRegisterData_verifyOTPAndRegister.serializer)
      ..add(GVerifyOTPAndRegisterData_verifyOTPAndRegister_user.serializer)
      ..add(GVerifyOTPAndRegisterInput.serializer)
      ..add(GVerifyOTPAndRegisterReq.serializer)
      ..add(GVerifyOTPAndRegisterVars.serializer)
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCreateTaskData_createTask_tags)]),
          () => new ListBuilder<GCreateTaskData_createTask_tags>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GGetChatMessagesData_getChatMessages)]),
          () => new ListBuilder<GGetChatMessagesData_getChatMessages>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetFriendsData_getFriends)]),
          () => new ListBuilder<GGetFriendsData_getFriends>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetTasksData_getTasks)]),
          () => new ListBuilder<GGetTasksData_getTasks>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetTasksData_getTasks_tags)]),
          () => new ListBuilder<GGetTasksData_getTasks_tags>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => new ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => new ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalStatus)]),
          () => new ListBuilder<GGoalStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalStatus)]),
          () => new ListBuilder<GGoalStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => new ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => new ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => new ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => new ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => new ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => new ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => new ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => new ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => new ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => new ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskType)]),
          () => new ListBuilder<GTaskType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskType)]),
          () => new ListBuilder<GTaskType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskStatus)]),
          () => new ListBuilder<GTaskStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskStatus)]),
          () => new ListBuilder<GTaskStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => new ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => new ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => new ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => new ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => new ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => new ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserStudyTime)]),
          () => new ListBuilder<GUserStudyTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserStudyTime)]),
          () => new ListBuilder<GUserStudyTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserRole)]),
          () => new ListBuilder<GUserRole>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserRole)]),
          () => new ListBuilder<GUserRole>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => new ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => new ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => new ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => new ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => new ListBuilder<String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
