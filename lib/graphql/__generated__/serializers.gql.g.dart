// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'serializers.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializers _$serializers = (Serializers().toBuilder()
      ..add(FetchPolicy.serializer)
      ..add(GAuthSessionOrder.serializer)
      ..add(GAuthSessionOrderField.serializer)
      ..add(GAuthSessionWhereInput.serializer)
      ..add(GBeginCounselingPaymentInput.serializer)
      ..add(GChatOrder.serializer)
      ..add(GChatOrderField.serializer)
      ..add(GChatParticipantOrder.serializer)
      ..add(GChatParticipantOrderField.serializer)
      ..add(GChatParticipantWhereInput.serializer)
      ..add(GChatType.serializer)
      ..add(GChatWhereInput.serializer)
      ..add(GCompleteTimedTaskData.serializer)
      ..add(GCompleteTimedTaskData_completeTimedTask.serializer)
      ..add(GCompleteTimedTaskReq.serializer)
      ..add(GCompleteTimedTaskVars.serializer)
      ..add(GCounselingPaymentAttemptCurrency.serializer)
      ..add(GCounselingPaymentAttemptStatus.serializer)
      ..add(GCounselingSubscriptionCancellationReason.serializer)
      ..add(GCounselingSubscriptionCurrency.serializer)
      ..add(GCounselingSubscriptionOrder.serializer)
      ..add(GCounselingSubscriptionOrderField.serializer)
      ..add(GCounselingSubscriptionPlanType.serializer)
      ..add(GCounselingSubscriptionStatus.serializer)
      ..add(GCounselingSubscriptionWhereInput.serializer)
      ..add(GCounselorProfileOrder.serializer)
      ..add(GCounselorProfileOrderField.serializer)
      ..add(GCounselorProfileWhereInput.serializer)
      ..add(GCounselorReviewOrder.serializer)
      ..add(GCounselorReviewOrderField.serializer)
      ..add(GCounselorReviewWhereInput.serializer)
      ..add(GCreateDirectChatData.serializer)
      ..add(GCreateDirectChatData_createDirectChat.serializer)
      ..add(GCreateDirectChatInput.serializer)
      ..add(GCreateDirectChatReq.serializer)
      ..add(GCreateDirectChatVars.serializer)
      ..add(GCreateGoalData.serializer)
      ..add(GCreateGoalData_createGoal.serializer)
      ..add(GCreateGoalInput.serializer)
      ..add(GCreateGoalReq.serializer)
      ..add(GCreateGoalVars.serializer)
      ..add(GCreateGroupChatInput.serializer)
      ..add(GCreateTaskData.serializer)
      ..add(GCreateTaskData_createTask.serializer)
      ..add(GCreateTaskInput.serializer)
      ..add(GCreateTaskReq.serializer)
      ..add(GCreateTaskVars.serializer)
      ..add(GCursor.serializer)
      ..add(GDeleteGoalData.serializer)
      ..add(GDeleteGoalReq.serializer)
      ..add(GDeleteGoalVars.serializer)
      ..add(GDeleteMessageData.serializer)
      ..add(GDeleteMessageData_deleteMessage.serializer)
      ..add(GDeleteMessageReq.serializer)
      ..add(GDeleteMessageVars.serializer)
      ..add(GDeleteTaskData.serializer)
      ..add(GDeleteTaskReq.serializer)
      ..add(GDeleteTaskVars.serializer)
      ..add(GDeviceTokenOrder.serializer)
      ..add(GDeviceTokenOrderField.serializer)
      ..add(GDeviceTokenPlatform.serializer)
      ..add(GDeviceTokenWhereInput.serializer)
      ..add(GFriendshipOrder.serializer)
      ..add(GFriendshipOrderField.serializer)
      ..add(GFriendshipStatus.serializer)
      ..add(GFriendshipWhereInput.serializer)
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
      ..add(GGetGoalsData.serializer)
      ..add(GGetGoalsData_getGoals.serializer)
      ..add(GGetGoalsReq.serializer)
      ..add(GGetGoalsVars.serializer)
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
      ..add(GMessageOrder.serializer)
      ..add(GMessageOrderField.serializer)
      ..add(GMessageType.serializer)
      ..add(GMessageWhereInput.serializer)
      ..add(GOTPClient.serializer)
      ..add(GOrderDirection.serializer)
      ..add(GParentTagsData.serializer)
      ..add(GParentTagsData_parentTags.serializer)
      ..add(GParentTagsReq.serializer)
      ..add(GParentTagsVars.serializer)
      ..add(GPauseTimedTaskData.serializer)
      ..add(GPauseTimedTaskData_pauseTimedTask.serializer)
      ..add(GPauseTimedTaskReq.serializer)
      ..add(GPauseTimedTaskVars.serializer)
      ..add(GRefreshTokenData.serializer)
      ..add(GRefreshTokenData_refreshToken.serializer)
      ..add(GRefreshTokenData_refreshToken_user.serializer)
      ..add(GRefreshTokenInput.serializer)
      ..add(GRefreshTokenReq.serializer)
      ..add(GRefreshTokenVars.serializer)
      ..add(GRegisterDeviceTokenData.serializer)
      ..add(GRegisterDeviceTokenReq.serializer)
      ..add(GRegisterDeviceTokenVars.serializer)
      ..add(GRequestCounselingInput.serializer)
      ..add(GSaveTaskCompletionReportInput.serializer)
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
      ..add(GStartTimedTaskData.serializer)
      ..add(GStartTimedTaskData_startTimedTask.serializer)
      ..add(GStartTimedTaskReq.serializer)
      ..add(GStartTimedTaskVars.serializer)
      ..add(GStatisticsDashboardData.serializer)
      ..add(GStatisticsDashboardData_statisticsDashboard.serializer)
      ..add(GStatisticsDashboardData_statisticsDashboard_comparison.serializer)
      ..add(GStatisticsDashboardData_statisticsDashboard_comparison_current
          .serializer)
      ..add(
          GStatisticsDashboardData_statisticsDashboard_comparison_current_planVsCompleted
              .serializer)
      ..add(GStatisticsDashboardData_statisticsDashboard_comparison_previous
          .serializer)
      ..add(
          GStatisticsDashboardData_statisticsDashboard_dailyBuckets.serializer)
      ..add(GStatisticsDashboardData_statisticsDashboard_subjectBuckets
          .serializer)
      ..add(GStatisticsDashboardInput.serializer)
      ..add(GStatisticsDashboardReq.serializer)
      ..add(GStatisticsDashboardVars.serializer)
      ..add(GSubmitCounselorReviewInput.serializer)
      ..add(GTagKeywordWhereInput.serializer)
      ..add(GTagKind.serializer)
      ..add(GTagModerationStatus.serializer)
      ..add(GTagWhereInput.serializer)
      ..add(GTaskCompletionReportOrder.serializer)
      ..add(GTaskCompletionReportOrderField.serializer)
      ..add(GTaskCompletionReportWhereInput.serializer)
      ..add(GTaskOrder.serializer)
      ..add(GTaskOrderField.serializer)
      ..add(GTaskStatus.serializer)
      ..add(GTaskType.serializer)
      ..add(GTaskWhereInput.serializer)
      ..add(GTime.serializer)
      ..add(GUUID.serializer)
      ..add(GUnregisterDeviceTokenData.serializer)
      ..add(GUnregisterDeviceTokenReq.serializer)
      ..add(GUnregisterDeviceTokenVars.serializer)
      ..add(GUpdateCounselorProfileInput.serializer)
      ..add(GUpdateGoalData.serializer)
      ..add(GUpdateGoalData_updateGoal.serializer)
      ..add(GUpdateGoalInput.serializer)
      ..add(GUpdateGoalReq.serializer)
      ..add(GUpdateGoalVars.serializer)
      ..add(GUpdateProfileInput.serializer)
      ..add(GUpdateTaskData.serializer)
      ..add(GUpdateTaskData_updateTask.serializer)
      ..add(GUpdateTaskInput.serializer)
      ..add(GUpdateTaskReq.serializer)
      ..add(GUpdateTaskVars.serializer)
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
          const FullType(
              BuiltList, const [const FullType(GAuthSessionWhereInput)]),
          () => ListBuilder<GAuthSessionWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GAuthSessionWhereInput)]),
          () => ListBuilder<GAuthSessionWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GChatParticipantWhereInput)]),
          () => ListBuilder<GChatParticipantWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GChatParticipantWhereInput)]),
          () => ListBuilder<GChatParticipantWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatWhereInput)]),
          () => ListBuilder<GChatWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatWhereInput)]),
          () => ListBuilder<GChatWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatWhereInput)]),
          () => ListBuilder<GChatWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatType)]),
          () => ListBuilder<GChatType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatType)]),
          () => ListBuilder<GChatType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GChatParticipantWhereInput)]),
          () => ListBuilder<GChatParticipantWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionWhereInput)]),
          () => ListBuilder<GCounselingSubscriptionWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionWhereInput)]),
          () => ListBuilder<GCounselingSubscriptionWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionPlanType)]),
          () => ListBuilder<GCounselingSubscriptionPlanType>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionPlanType)]),
          () => ListBuilder<GCounselingSubscriptionPlanType>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselingSubscriptionStatus)]),
          () => ListBuilder<GCounselingSubscriptionStatus>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselingSubscriptionStatus)]),
          () => ListBuilder<GCounselingSubscriptionStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GCounselingSubscriptionCancellationReason)
          ]),
          () => ListBuilder<GCounselingSubscriptionCancellationReason>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(GCounselingSubscriptionCancellationReason)
          ]),
          () => ListBuilder<GCounselingSubscriptionCancellationReason>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionCurrency)]),
          () => ListBuilder<GCounselingSubscriptionCurrency>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionCurrency)]),
          () => ListBuilder<GCounselingSubscriptionCurrency>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorReviewWhereInput)]),
          () => ListBuilder<GCounselorReviewWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorProfileWhereInput)]),
          () => ListBuilder<GCounselorProfileWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorProfileWhereInput)]),
          () => ListBuilder<GCounselorProfileWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorProfileWhereInput)]),
          () => ListBuilder<GCounselorProfileWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(double)]),
          () => ListBuilder<double>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(double)]),
          () => ListBuilder<double>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorReviewWhereInput)]),
          () => ListBuilder<GCounselorReviewWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionWhereInput)]),
          () => ListBuilder<GCounselingSubscriptionWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorReviewWhereInput)]),
          () => ListBuilder<GCounselorReviewWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorReviewWhereInput)]),
          () => ListBuilder<GCounselorReviewWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorProfileWhereInput)]),
          () => ListBuilder<GCounselorProfileWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionWhereInput)]),
          () => ListBuilder<GCounselingSubscriptionWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GDeviceTokenWhereInput)]),
          () => ListBuilder<GDeviceTokenWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GDeviceTokenWhereInput)]),
          () => ListBuilder<GDeviceTokenWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GDeviceTokenPlatform)]),
          () => ListBuilder<GDeviceTokenPlatform>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GDeviceTokenPlatform)]),
          () => ListBuilder<GDeviceTokenPlatform>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GFriendshipWhereInput)]),
          () => ListBuilder<GFriendshipWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GFriendshipWhereInput)]),
          () => ListBuilder<GFriendshipWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUUID)]),
          () => ListBuilder<GUUID>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUUID)]),
          () => ListBuilder<GUUID>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUUID)]),
          () => ListBuilder<GUUID>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUUID)]),
          () => ListBuilder<GUUID>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GFriendshipStatus)]),
          () => ListBuilder<GFriendshipStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GFriendshipStatus)]),
          () => ListBuilder<GFriendshipStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GGetChatMessagesData_getChatMessages)]),
          () => ListBuilder<GGetChatMessagesData_getChatMessages>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetFriendsData_getFriends)]),
          () => ListBuilder<GGetFriendsData_getFriends>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetGoalsData_getGoals)]),
          () => ListBuilder<GGetGoalsData_getGoals>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetTasksData_getTasks)]),
          () => ListBuilder<GGetTasksData_getTasks>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GGetTasksData_getTasks_tags)]),
          () => ListBuilder<GGetTasksData_getTasks_tags>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalStatus)]),
          () => ListBuilder<GGoalStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalStatus)]),
          () => ListBuilder<GGoalStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageType)]),
          () => ListBuilder<GMessageType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageType)]),
          () => ListBuilder<GMessageType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GChatWhereInput)]),
          () => ListBuilder<GChatWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GParentTagsData_parentTags)]),
          () => ListBuilder<GParentTagsData_parentTags>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GStatisticsDashboardData_statisticsDashboard_dailyBuckets)
          ]),
          () => ListBuilder<
              GStatisticsDashboardData_statisticsDashboard_dailyBuckets>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [
            const FullType(
                GStatisticsDashboardData_statisticsDashboard_subjectBuckets)
          ]),
          () => ListBuilder<
              GStatisticsDashboardData_statisticsDashboard_subjectBuckets>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTagKeywordWhereInput)]),
          () => ListBuilder<GTagKeywordWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTagKeywordWhereInput)]),
          () => ListBuilder<GTagKeywordWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagKind)]),
          () => ListBuilder<GTagKind>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagKind)]),
          () => ListBuilder<GTagKind>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTagModerationStatus)]),
          () => ListBuilder<GTagModerationStatus>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTagModerationStatus)]),
          () => ListBuilder<GTagModerationStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GTagKeywordWhereInput)]),
          () => ListBuilder<GTagKeywordWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTaskCompletionReportWhereInput)]),
          () => ListBuilder<GTaskCompletionReportWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTaskCompletionReportWhereInput)]),
          () => ListBuilder<GTaskCompletionReportWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskType)]),
          () => ListBuilder<GTaskType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskType)]),
          () => ListBuilder<GTaskType>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskStatus)]),
          () => ListBuilder<GTaskStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskStatus)]),
          () => ListBuilder<GTaskStatus>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GTaskCompletionReportWhereInput)]),
          () => ListBuilder<GTaskCompletionReportWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUUID)]),
          () => ListBuilder<GUUID>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserWhereInput)]),
          () => ListBuilder<GUserWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserStudyTime)]),
          () => ListBuilder<GUserStudyTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserStudyTime)]),
          () => ListBuilder<GUserStudyTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserRole)]),
          () => ListBuilder<GUserRole>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GUserRole)]),
          () => ListBuilder<GUserRole>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(int)]),
          () => ListBuilder<int>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTime)]),
          () => ListBuilder<GTime>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GAuthSessionWhereInput)]),
          () => ListBuilder<GAuthSessionWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GInterestWhereInput)]),
          () => ListBuilder<GInterestWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GGoalWhereInput)]),
          () => ListBuilder<GGoalWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTaskWhereInput)]),
          () => ListBuilder<GTaskWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GChatParticipantWhereInput)]),
          () => ListBuilder<GChatParticipantWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GMessageWhereInput)]),
          () => ListBuilder<GMessageWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorProfileWhereInput)]),
          () => ListBuilder<GCounselorProfileWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GCounselorReviewWhereInput)]),
          () => ListBuilder<GCounselorReviewWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList,
              const [const FullType(GCounselingSubscriptionWhereInput)]),
          () => ListBuilder<GCounselingSubscriptionWhereInput>())
      ..addBuilderFactory(
          const FullType(
              BuiltList, const [const FullType(GDeviceTokenWhereInput)]),
          () => ListBuilder<GDeviceTokenWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(GTagWhereInput)]),
          () => ListBuilder<GTagWhereInput>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>())
      ..addBuilderFactory(
          const FullType(BuiltList, const [const FullType(String)]),
          () => ListBuilder<String>()))
    .build();

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
