// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i1;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i2;

part 'schema.schema.gql.g.dart';

abstract class GCursor implements Built<GCursor, GCursorBuilder> {
  GCursor._();

  factory GCursor([String? value]) =>
      _$GCursor((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GCursor> get serializer =>
      _i1.DefaultScalarSerializer<GCursor>(
          (Object serialized) => GCursor((serialized as String?)));
}

abstract class GTime implements Built<GTime, GTimeBuilder> {
  GTime._();

  factory GTime([String? value]) =>
      _$GTime((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GTime> get serializer => _i1.DefaultScalarSerializer<GTime>(
      (Object serialized) => GTime((serialized as String?)));
}

abstract class GUUID implements Built<GUUID, GUUIDBuilder> {
  GUUID._();

  factory GUUID([String? value]) =>
      _$GUUID((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GUUID> get serializer => _i1.DefaultScalarSerializer<GUUID>(
      (Object serialized) => GUUID((serialized as String?)));
}

class GDeviceTokenPlatform extends EnumClass {
  const GDeviceTokenPlatform._(String name) : super(name);

  static const GDeviceTokenPlatform ANDROID = _$gDeviceTokenPlatformANDROID;

  static const GDeviceTokenPlatform IOS = _$gDeviceTokenPlatformIOS;

  static const GDeviceTokenPlatform WEB = _$gDeviceTokenPlatformWEB;

  static Serializer<GDeviceTokenPlatform> get serializer =>
      _$gDeviceTokenPlatformSerializer;

  static BuiltSet<GDeviceTokenPlatform> get values =>
      _$gDeviceTokenPlatformValues;

  static GDeviceTokenPlatform valueOf(String name) =>
      _$gDeviceTokenPlatformValueOf(name);
}

class GChatType extends EnumClass {
  const GChatType._(String name) : super(name);

  static const GChatType DIRECT = _$gChatTypeDIRECT;

  static const GChatType GROUP = _$gChatTypeGROUP;

  static Serializer<GChatType> get serializer => _$gChatTypeSerializer;

  static BuiltSet<GChatType> get values => _$gChatTypeValues;

  static GChatType valueOf(String name) => _$gChatTypeValueOf(name);
}

class GMessageType extends EnumClass {
  const GMessageType._(String name) : super(name);

  static const GMessageType TEXT = _$gMessageTypeTEXT;

  static const GMessageType DUEL_INVITE = _$gMessageTypeDUEL_INVITE;

  static const GMessageType SYSTEM = _$gMessageTypeSYSTEM;

  static Serializer<GMessageType> get serializer => _$gMessageTypeSerializer;

  static BuiltSet<GMessageType> get values => _$gMessageTypeValues;

  static GMessageType valueOf(String name) => _$gMessageTypeValueOf(name);
}

class GFriendshipStatus extends EnumClass {
  const GFriendshipStatus._(String name) : super(name);

  static const GFriendshipStatus PENDING = _$gFriendshipStatusPENDING;

  static const GFriendshipStatus ACCEPTED = _$gFriendshipStatusACCEPTED;

  static const GFriendshipStatus REJECTED = _$gFriendshipStatusREJECTED;

  static const GFriendshipStatus BLOCKED = _$gFriendshipStatusBLOCKED;

  static Serializer<GFriendshipStatus> get serializer =>
      _$gFriendshipStatusSerializer;

  static BuiltSet<GFriendshipStatus> get values => _$gFriendshipStatusValues;

  static GFriendshipStatus valueOf(String name) =>
      _$gFriendshipStatusValueOf(name);
}

abstract class GCreateDirectChatInput
    implements Built<GCreateDirectChatInput, GCreateDirectChatInputBuilder> {
  GCreateDirectChatInput._();

  factory GCreateDirectChatInput(
          [void Function(GCreateDirectChatInputBuilder b) updates]) =
      _$GCreateDirectChatInput;

  GUUID get targetUserID;
  static Serializer<GCreateDirectChatInput> get serializer =>
      _$gCreateDirectChatInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateDirectChatInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateDirectChatInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateDirectChatInput.serializer,
        json,
      );
}

abstract class GSendMessageInput
    implements Built<GSendMessageInput, GSendMessageInputBuilder> {
  GSendMessageInput._();

  factory GSendMessageInput(
          [void Function(GSendMessageInputBuilder b) updates]) =
      _$GSendMessageInput;

  String get chatID;
  String get content;
  String? get replyToID;
  static Serializer<GSendMessageInput> get serializer =>
      _$gSendMessageInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GSendMessageInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GSendMessageInput.serializer,
        json,
      );
}

class GGoalOrderField extends EnumClass {
  const GGoalOrderField._(String name) : super(name);

  static const GGoalOrderField CREATED_AT = _$gGoalOrderFieldCREATED_AT;

  static const GGoalOrderField UPDATED_AT = _$gGoalOrderFieldUPDATED_AT;

  static Serializer<GGoalOrderField> get serializer =>
      _$gGoalOrderFieldSerializer;

  static BuiltSet<GGoalOrderField> get values => _$gGoalOrderFieldValues;

  static GGoalOrderField valueOf(String name) => _$gGoalOrderFieldValueOf(name);
}

class GGoalStatus extends EnumClass {
  const GGoalStatus._(String name) : super(name);

  static const GGoalStatus IN_PROGRESS = _$gGoalStatusIN_PROGRESS;

  static const GGoalStatus COMPLETED = _$gGoalStatusCOMPLETED;

  static const GGoalStatus PAUSED = _$gGoalStatusPAUSED;

  static const GGoalStatus ARCHIVED = _$gGoalStatusARCHIVED;

  static Serializer<GGoalStatus> get serializer => _$gGoalStatusSerializer;

  static BuiltSet<GGoalStatus> get values => _$gGoalStatusValues;

  static GGoalStatus valueOf(String name) => _$gGoalStatusValueOf(name);
}

class GOrderDirection extends EnumClass {
  const GOrderDirection._(String name) : super(name);

  static const GOrderDirection ASC = _$gOrderDirectionASC;

  static const GOrderDirection DESC = _$gOrderDirectionDESC;

  static Serializer<GOrderDirection> get serializer =>
      _$gOrderDirectionSerializer;

  static BuiltSet<GOrderDirection> get values => _$gOrderDirectionValues;

  static GOrderDirection valueOf(String name) => _$gOrderDirectionValueOf(name);
}

class GTaskOrderField extends EnumClass {
  const GTaskOrderField._(String name) : super(name);

  static const GTaskOrderField CREATED_AT = _$gTaskOrderFieldCREATED_AT;

  static const GTaskOrderField UPDATED_AT = _$gTaskOrderFieldUPDATED_AT;

  static Serializer<GTaskOrderField> get serializer =>
      _$gTaskOrderFieldSerializer;

  static BuiltSet<GTaskOrderField> get values => _$gTaskOrderFieldValues;

  static GTaskOrderField valueOf(String name) => _$gTaskOrderFieldValueOf(name);
}

class GTaskStatus extends EnumClass {
  const GTaskStatus._(String name) : super(name);

  static const GTaskStatus TODO = _$gTaskStatusTODO;

  static const GTaskStatus IN_PROGRESS = _$gTaskStatusIN_PROGRESS;

  static const GTaskStatus COMPLETED = _$gTaskStatusCOMPLETED;

  static const GTaskStatus CANCELED = _$gTaskStatusCANCELED;

  static Serializer<GTaskStatus> get serializer => _$gTaskStatusSerializer;

  static BuiltSet<GTaskStatus> get values => _$gTaskStatusValues;

  static GTaskStatus valueOf(String name) => _$gTaskStatusValueOf(name);
}

class GTaskType extends EnumClass {
  const GTaskType._(String name) : super(name);

  static const GTaskType NORMAL = _$gTaskTypeNORMAL;

  static const GTaskType TIMED = _$gTaskTypeTIMED;

  static Serializer<GTaskType> get serializer => _$gTaskTypeSerializer;

  static BuiltSet<GTaskType> get values => _$gTaskTypeValues;

  static GTaskType valueOf(String name) => _$gTaskTypeValueOf(name);
}

class GUserOrderField extends EnumClass {
  const GUserOrderField._(String name) : super(name);

  static const GUserOrderField CREATED_AT = _$gUserOrderFieldCREATED_AT;

  static const GUserOrderField UPDATED_AT = _$gUserOrderFieldUPDATED_AT;

  static Serializer<GUserOrderField> get serializer =>
      _$gUserOrderFieldSerializer;

  static BuiltSet<GUserOrderField> get values => _$gUserOrderFieldValues;

  static GUserOrderField valueOf(String name) => _$gUserOrderFieldValueOf(name);
}

class GUserRole extends EnumClass {
  const GUserRole._(String name) : super(name);

  static const GUserRole USER = _$gUserRoleUSER;

  static const GUserRole ADVISOR = _$gUserRoleADVISOR;

  static const GUserRole ADMIN = _$gUserRoleADMIN;

  static Serializer<GUserRole> get serializer => _$gUserRoleSerializer;

  static BuiltSet<GUserRole> get values => _$gUserRoleValues;

  static GUserRole valueOf(String name) => _$gUserRoleValueOf(name);
}

class GUserStudyTime extends EnumClass {
  const GUserStudyTime._(String name) : super(name);

  static const GUserStudyTime UNDER_4_HOURS = _$gUserStudyTimeUNDER_4_HOURS;

  static const GUserStudyTime BETWEEN_4_AND_7 = _$gUserStudyTimeBETWEEN_4_AND_7;

  static const GUserStudyTime OVER_7_HOURS = _$gUserStudyTimeOVER_7_HOURS;

  static Serializer<GUserStudyTime> get serializer =>
      _$gUserStudyTimeSerializer;

  static BuiltSet<GUserStudyTime> get values => _$gUserStudyTimeValues;

  static GUserStudyTime valueOf(String name) => _$gUserStudyTimeValueOf(name);
}

abstract class GCreateGoalInput
    implements Built<GCreateGoalInput, GCreateGoalInputBuilder> {
  GCreateGoalInput._();

  factory GCreateGoalInput([void Function(GCreateGoalInputBuilder b) updates]) =
      _$GCreateGoalInput;

  String get title;
  String? get note;
  GTime? get targetDate;
  static Serializer<GCreateGoalInput> get serializer =>
      _$gCreateGoalInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateGoalInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGoalInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateGoalInput.serializer,
        json,
      );
}

abstract class GCreateTaskInput
    implements Built<GCreateTaskInput, GCreateTaskInputBuilder> {
  GCreateTaskInput._();

  factory GCreateTaskInput([void Function(GCreateTaskInputBuilder b) updates]) =
      _$GCreateTaskInput;

  String get title;
  String? get shortDescription;
  GTaskType? get type;
  String? get note;
  GTime get date;
  int? get durationM;
  bool? get hasReminder;
  GTime? get reminderTime;
  String? get recurringDays;
  String? get goalID;
  BuiltList<String>? get tagNames;
  static Serializer<GCreateTaskInput> get serializer =>
      _$gCreateTaskInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GCreateTaskInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateTaskInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GCreateTaskInput.serializer,
        json,
      );
}

abstract class GGoalOrder implements Built<GGoalOrder, GGoalOrderBuilder> {
  GGoalOrder._();

  factory GGoalOrder([void Function(GGoalOrderBuilder b) updates]) =
      _$GGoalOrder;

  GOrderDirection get direction;
  GGoalOrderField get field;
  static Serializer<GGoalOrder> get serializer => _$gGoalOrderSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GGoalOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGoalOrder? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GGoalOrder.serializer,
        json,
      );
}

abstract class GGoalWhereInput
    implements Built<GGoalWhereInput, GGoalWhereInputBuilder> {
  GGoalWhereInput._();

  factory GGoalWhereInput([void Function(GGoalWhereInputBuilder b) updates]) =
      _$GGoalWhereInput;

  GGoalWhereInput? get not;
  BuiltList<GGoalWhereInput>? get and;
  BuiltList<GGoalWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  GTime? get createdAt;
  GTime? get createdAtNEQ;
  BuiltList<GTime>? get createdAtIn;
  BuiltList<GTime>? get createdAtNotIn;
  GTime? get createdAtGT;
  GTime? get createdAtGTE;
  GTime? get createdAtLT;
  GTime? get createdAtLTE;
  GTime? get updatedAt;
  GTime? get updatedAtNEQ;
  BuiltList<GTime>? get updatedAtIn;
  BuiltList<GTime>? get updatedAtNotIn;
  GTime? get updatedAtGT;
  GTime? get updatedAtGTE;
  GTime? get updatedAtLT;
  GTime? get updatedAtLTE;
  String? get title;
  String? get titleNEQ;
  BuiltList<String>? get titleIn;
  BuiltList<String>? get titleNotIn;
  String? get titleGT;
  String? get titleGTE;
  String? get titleLT;
  String? get titleLTE;
  String? get titleContains;
  String? get titleHasPrefix;
  String? get titleHasSuffix;
  String? get titleEqualFold;
  String? get titleContainsFold;
  String? get note;
  String? get noteNEQ;
  BuiltList<String>? get noteIn;
  BuiltList<String>? get noteNotIn;
  String? get noteGT;
  String? get noteGTE;
  String? get noteLT;
  String? get noteLTE;
  String? get noteContains;
  String? get noteHasPrefix;
  String? get noteHasSuffix;
  bool? get noteIsNil;
  bool? get noteNotNil;
  String? get noteEqualFold;
  String? get noteContainsFold;
  GTime? get targetDate;
  GTime? get targetDateNEQ;
  BuiltList<GTime>? get targetDateIn;
  BuiltList<GTime>? get targetDateNotIn;
  GTime? get targetDateGT;
  GTime? get targetDateGTE;
  GTime? get targetDateLT;
  GTime? get targetDateLTE;
  bool? get targetDateIsNil;
  bool? get targetDateNotNil;
  GGoalStatus? get status;
  GGoalStatus? get statusNEQ;
  BuiltList<GGoalStatus>? get statusIn;
  BuiltList<GGoalStatus>? get statusNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  static Serializer<GGoalWhereInput> get serializer =>
      _$gGoalWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GGoalWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGoalWhereInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GGoalWhereInput.serializer,
        json,
      );
}

abstract class GInterestWhereInput
    implements Built<GInterestWhereInput, GInterestWhereInputBuilder> {
  GInterestWhereInput._();

  factory GInterestWhereInput(
          [void Function(GInterestWhereInputBuilder b) updates]) =
      _$GInterestWhereInput;

  GInterestWhereInput? get not;
  BuiltList<GInterestWhereInput>? get and;
  BuiltList<GInterestWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  String? get name;
  String? get nameNEQ;
  BuiltList<String>? get nameIn;
  BuiltList<String>? get nameNotIn;
  String? get nameGT;
  String? get nameGTE;
  String? get nameLT;
  String? get nameLTE;
  String? get nameContains;
  String? get nameHasPrefix;
  String? get nameHasSuffix;
  String? get nameEqualFold;
  String? get nameContainsFold;
  bool? get hasUsers;
  BuiltList<GUserWhereInput>? get hasUsersWith;
  static Serializer<GInterestWhereInput> get serializer =>
      _$gInterestWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GInterestWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInterestWhereInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GInterestWhereInput.serializer,
        json,
      );
}

abstract class GSendOTPInput
    implements Built<GSendOTPInput, GSendOTPInputBuilder> {
  GSendOTPInput._();

  factory GSendOTPInput([void Function(GSendOTPInputBuilder b) updates]) =
      _$GSendOTPInput;

  String get phoneNumber;
  GDeviceTokenPlatform get client;
  static Serializer<GSendOTPInput> get serializer => _$gSendOTPInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GSendOTPInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GSendOTPInput.serializer,
        json,
      );
}

abstract class GRefreshTokenInput
    implements Built<GRefreshTokenInput, GRefreshTokenInputBuilder> {
  GRefreshTokenInput._();

  factory GRefreshTokenInput(
          [void Function(GRefreshTokenInputBuilder b) updates]) =
      _$GRefreshTokenInput;

  String get refreshToken;
  static Serializer<GRefreshTokenInput> get serializer =>
      _$gRefreshTokenInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GRefreshTokenInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GRefreshTokenInput.serializer,
        json,
      );
}

abstract class GTagWhereInput
    implements Built<GTagWhereInput, GTagWhereInputBuilder> {
  GTagWhereInput._();

  factory GTagWhereInput([void Function(GTagWhereInputBuilder b) updates]) =
      _$GTagWhereInput;

  GTagWhereInput? get not;
  BuiltList<GTagWhereInput>? get and;
  BuiltList<GTagWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  String? get name;
  String? get nameNEQ;
  BuiltList<String>? get nameIn;
  BuiltList<String>? get nameNotIn;
  String? get nameGT;
  String? get nameGTE;
  String? get nameLT;
  String? get nameLTE;
  String? get nameContains;
  String? get nameHasPrefix;
  String? get nameHasSuffix;
  String? get nameEqualFold;
  String? get nameContainsFold;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  static Serializer<GTagWhereInput> get serializer =>
      _$gTagWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GTagWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTagWhereInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GTagWhereInput.serializer,
        json,
      );
}

abstract class GTaskOrder implements Built<GTaskOrder, GTaskOrderBuilder> {
  GTaskOrder._();

  factory GTaskOrder([void Function(GTaskOrderBuilder b) updates]) =
      _$GTaskOrder;

  GOrderDirection get direction;
  GTaskOrderField get field;
  static Serializer<GTaskOrder> get serializer => _$gTaskOrderSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GTaskOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskOrder? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GTaskOrder.serializer,
        json,
      );
}

abstract class GTaskWhereInput
    implements Built<GTaskWhereInput, GTaskWhereInputBuilder> {
  GTaskWhereInput._();

  factory GTaskWhereInput([void Function(GTaskWhereInputBuilder b) updates]) =
      _$GTaskWhereInput;

  GTaskWhereInput? get not;
  BuiltList<GTaskWhereInput>? get and;
  BuiltList<GTaskWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  GTime? get createdAt;
  GTime? get createdAtNEQ;
  BuiltList<GTime>? get createdAtIn;
  BuiltList<GTime>? get createdAtNotIn;
  GTime? get createdAtGT;
  GTime? get createdAtGTE;
  GTime? get createdAtLT;
  GTime? get createdAtLTE;
  GTime? get updatedAt;
  GTime? get updatedAtNEQ;
  BuiltList<GTime>? get updatedAtIn;
  BuiltList<GTime>? get updatedAtNotIn;
  GTime? get updatedAtGT;
  GTime? get updatedAtGTE;
  GTime? get updatedAtLT;
  GTime? get updatedAtLTE;
  String? get title;
  String? get titleNEQ;
  BuiltList<String>? get titleIn;
  BuiltList<String>? get titleNotIn;
  String? get titleGT;
  String? get titleGTE;
  String? get titleLT;
  String? get titleLTE;
  String? get titleContains;
  String? get titleHasPrefix;
  String? get titleHasSuffix;
  String? get titleEqualFold;
  String? get titleContainsFold;
  String? get shortDescription;
  String? get shortDescriptionNEQ;
  BuiltList<String>? get shortDescriptionIn;
  BuiltList<String>? get shortDescriptionNotIn;
  String? get shortDescriptionGT;
  String? get shortDescriptionGTE;
  String? get shortDescriptionLT;
  String? get shortDescriptionLTE;
  String? get shortDescriptionContains;
  String? get shortDescriptionHasPrefix;
  String? get shortDescriptionHasSuffix;
  bool? get shortDescriptionIsNil;
  bool? get shortDescriptionNotNil;
  String? get shortDescriptionEqualFold;
  String? get shortDescriptionContainsFold;
  String? get note;
  String? get noteNEQ;
  BuiltList<String>? get noteIn;
  BuiltList<String>? get noteNotIn;
  String? get noteGT;
  String? get noteGTE;
  String? get noteLT;
  String? get noteLTE;
  String? get noteContains;
  String? get noteHasPrefix;
  String? get noteHasSuffix;
  bool? get noteIsNil;
  bool? get noteNotNil;
  String? get noteEqualFold;
  String? get noteContainsFold;
  GTaskType? get type;
  GTaskType? get typeNEQ;
  BuiltList<GTaskType>? get typeIn;
  BuiltList<GTaskType>? get typeNotIn;
  GTime? get date;
  GTime? get dateNEQ;
  BuiltList<GTime>? get dateIn;
  BuiltList<GTime>? get dateNotIn;
  GTime? get dateGT;
  GTime? get dateGTE;
  GTime? get dateLT;
  GTime? get dateLTE;
  int? get durationM;
  int? get durationMNEQ;
  BuiltList<int>? get durationMIn;
  BuiltList<int>? get durationMNotIn;
  int? get durationMGT;
  int? get durationMGTE;
  int? get durationMLT;
  int? get durationMLTE;
  bool? get durationMIsNil;
  bool? get durationMNotNil;
  bool? get hasReminder;
  bool? get hasReminderNEQ;
  GTime? get reminderTime;
  GTime? get reminderTimeNEQ;
  BuiltList<GTime>? get reminderTimeIn;
  BuiltList<GTime>? get reminderTimeNotIn;
  GTime? get reminderTimeGT;
  GTime? get reminderTimeGTE;
  GTime? get reminderTimeLT;
  GTime? get reminderTimeLTE;
  bool? get reminderTimeIsNil;
  bool? get reminderTimeNotNil;
  String? get recurringDays;
  String? get recurringDaysNEQ;
  BuiltList<String>? get recurringDaysIn;
  BuiltList<String>? get recurringDaysNotIn;
  String? get recurringDaysGT;
  String? get recurringDaysGTE;
  String? get recurringDaysLT;
  String? get recurringDaysLTE;
  String? get recurringDaysContains;
  String? get recurringDaysHasPrefix;
  String? get recurringDaysHasSuffix;
  bool? get recurringDaysIsNil;
  bool? get recurringDaysNotNil;
  String? get recurringDaysEqualFold;
  String? get recurringDaysContainsFold;
  GTaskStatus? get status;
  GTaskStatus? get statusNEQ;
  BuiltList<GTaskStatus>? get statusIn;
  BuiltList<GTaskStatus>? get statusNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasGoal;
  BuiltList<GGoalWhereInput>? get hasGoalWith;
  bool? get hasTags;
  BuiltList<GTagWhereInput>? get hasTagsWith;
  static Serializer<GTaskWhereInput> get serializer =>
      _$gTaskWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GTaskWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskWhereInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GTaskWhereInput.serializer,
        json,
      );
}

abstract class GUpdateGoalInput
    implements Built<GUpdateGoalInput, GUpdateGoalInputBuilder> {
  GUpdateGoalInput._();

  factory GUpdateGoalInput([void Function(GUpdateGoalInputBuilder b) updates]) =
      _$GUpdateGoalInput;

  String? get title;
  String? get note;
  GTime? get targetDate;
  GGoalStatus? get status;
  static Serializer<GUpdateGoalInput> get serializer =>
      _$gUpdateGoalInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateGoalInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateGoalInput.serializer,
        json,
      );
}

abstract class GUpdateProfileInput
    implements Built<GUpdateProfileInput, GUpdateProfileInputBuilder> {
  GUpdateProfileInput._();

  factory GUpdateProfileInput(
          [void Function(GUpdateProfileInputBuilder b) updates]) =
      _$GUpdateProfileInput;

  String? get username;
  String? get fullName;
  GTime? get birthDate;
  GUserStudyTime? get studyTime;
  String? get major;
  String? get bio;
  static Serializer<GUpdateProfileInput> get serializer =>
      _$gUpdateProfileInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateProfileInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateProfileInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateProfileInput.serializer,
        json,
      );
}

abstract class GUpdateTaskInput
    implements Built<GUpdateTaskInput, GUpdateTaskInputBuilder> {
  GUpdateTaskInput._();

  factory GUpdateTaskInput([void Function(GUpdateTaskInputBuilder b) updates]) =
      _$GUpdateTaskInput;

  String? get title;
  String? get shortDescription;
  GTaskType? get type;
  String? get note;
  GTime? get date;
  int? get durationM;
  bool? get hasReminder;
  GTime? get reminderTime;
  String? get recurringDays;
  GTaskStatus? get status;
  String? get goalID;
  BuiltList<String>? get tagNames;
  static Serializer<GUpdateTaskInput> get serializer =>
      _$gUpdateTaskInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUpdateTaskInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUpdateTaskInput.serializer,
        json,
      );
}

abstract class GUserOrder implements Built<GUserOrder, GUserOrderBuilder> {
  GUserOrder._();

  factory GUserOrder([void Function(GUserOrderBuilder b) updates]) =
      _$GUserOrder;

  GOrderDirection get direction;
  GUserOrderField get field;
  static Serializer<GUserOrder> get serializer => _$gUserOrderSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUserOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUserOrder? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUserOrder.serializer,
        json,
      );
}

abstract class GUserWhereInput
    implements Built<GUserWhereInput, GUserWhereInputBuilder> {
  GUserWhereInput._();

  factory GUserWhereInput([void Function(GUserWhereInputBuilder b) updates]) =
      _$GUserWhereInput;

  GUserWhereInput? get not;
  BuiltList<GUserWhereInput>? get and;
  BuiltList<GUserWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  GTime? get createdAt;
  GTime? get createdAtNEQ;
  BuiltList<GTime>? get createdAtIn;
  BuiltList<GTime>? get createdAtNotIn;
  GTime? get createdAtGT;
  GTime? get createdAtGTE;
  GTime? get createdAtLT;
  GTime? get createdAtLTE;
  GTime? get updatedAt;
  GTime? get updatedAtNEQ;
  BuiltList<GTime>? get updatedAtIn;
  BuiltList<GTime>? get updatedAtNotIn;
  GTime? get updatedAtGT;
  GTime? get updatedAtGTE;
  GTime? get updatedAtLT;
  GTime? get updatedAtLTE;
  String? get phoneNumber;
  String? get phoneNumberNEQ;
  BuiltList<String>? get phoneNumberIn;
  BuiltList<String>? get phoneNumberNotIn;
  String? get phoneNumberGT;
  String? get phoneNumberGTE;
  String? get phoneNumberLT;
  String? get phoneNumberLTE;
  String? get phoneNumberContains;
  String? get phoneNumberHasPrefix;
  String? get phoneNumberHasSuffix;
  String? get phoneNumberEqualFold;
  String? get phoneNumberContainsFold;
  String? get fullName;
  String? get fullNameNEQ;
  BuiltList<String>? get fullNameIn;
  BuiltList<String>? get fullNameNotIn;
  String? get fullNameGT;
  String? get fullNameGTE;
  String? get fullNameLT;
  String? get fullNameLTE;
  String? get fullNameContains;
  String? get fullNameHasPrefix;
  String? get fullNameHasSuffix;
  bool? get fullNameIsNil;
  bool? get fullNameNotNil;
  String? get fullNameEqualFold;
  String? get fullNameContainsFold;
  GTime? get birthDate;
  GTime? get birthDateNEQ;
  BuiltList<GTime>? get birthDateIn;
  BuiltList<GTime>? get birthDateNotIn;
  GTime? get birthDateGT;
  GTime? get birthDateGTE;
  GTime? get birthDateLT;
  GTime? get birthDateLTE;
  bool? get birthDateIsNil;
  bool? get birthDateNotNil;
  GUserStudyTime? get studyTime;
  GUserStudyTime? get studyTimeNEQ;
  BuiltList<GUserStudyTime>? get studyTimeIn;
  BuiltList<GUserStudyTime>? get studyTimeNotIn;
  bool? get studyTimeIsNil;
  bool? get studyTimeNotNil;
  GUserRole? get role;
  GUserRole? get roleNEQ;
  BuiltList<GUserRole>? get roleIn;
  BuiltList<GUserRole>? get roleNotIn;
  int? get simoCoins;
  int? get simoCoinsNEQ;
  BuiltList<int>? get simoCoinsIn;
  BuiltList<int>? get simoCoinsNotIn;
  int? get simoCoinsGT;
  int? get simoCoinsGTE;
  int? get simoCoinsLT;
  int? get simoCoinsLTE;
  int? get score;
  int? get scoreNEQ;
  BuiltList<int>? get scoreIn;
  BuiltList<int>? get scoreNotIn;
  int? get scoreGT;
  int? get scoreGTE;
  int? get scoreLT;
  int? get scoreLTE;
  bool? get isPremium;
  bool? get isPremiumNEQ;
  String? get major;
  String? get majorNEQ;
  BuiltList<String>? get majorIn;
  BuiltList<String>? get majorNotIn;
  String? get majorGT;
  String? get majorGTE;
  String? get majorLT;
  String? get majorLTE;
  String? get majorContains;
  String? get majorHasPrefix;
  String? get majorHasSuffix;
  bool? get majorIsNil;
  bool? get majorNotNil;
  String? get majorEqualFold;
  String? get majorContainsFold;
  String? get bio;
  String? get bioNEQ;
  BuiltList<String>? get bioIn;
  BuiltList<String>? get bioNotIn;
  String? get bioGT;
  String? get bioGTE;
  String? get bioLT;
  String? get bioLTE;
  String? get bioContains;
  String? get bioHasPrefix;
  String? get bioHasSuffix;
  bool? get bioIsNil;
  bool? get bioNotNil;
  String? get bioEqualFold;
  String? get bioContainsFold;
  bool? get hasInterests;
  BuiltList<GInterestWhereInput>? get hasInterestsWith;
  bool? get hasGoals;
  BuiltList<GGoalWhereInput>? get hasGoalsWith;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  static Serializer<GUserWhereInput> get serializer =>
      _$gUserWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GUserWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUserWhereInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GUserWhereInput.serializer,
        json,
      );
}

abstract class GVerifyOTPAndLoginInput
    implements Built<GVerifyOTPAndLoginInput, GVerifyOTPAndLoginInputBuilder> {
  GVerifyOTPAndLoginInput._();

  factory GVerifyOTPAndLoginInput(
          [void Function(GVerifyOTPAndLoginInputBuilder b) updates]) =
      _$GVerifyOTPAndLoginInput;

  String get phoneNumber;
  String get code;
  static Serializer<GVerifyOTPAndLoginInput> get serializer =>
      _$gVerifyOTPAndLoginInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GVerifyOTPAndLoginInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GVerifyOTPAndLoginInput.serializer,
        json,
      );
}

abstract class GVerifyOTPAndRegisterInput
    implements
        Built<GVerifyOTPAndRegisterInput, GVerifyOTPAndRegisterInputBuilder> {
  GVerifyOTPAndRegisterInput._();

  factory GVerifyOTPAndRegisterInput(
          [void Function(GVerifyOTPAndRegisterInputBuilder b) updates]) =
      _$GVerifyOTPAndRegisterInput;

  String get phoneNumber;
  String get code;
  String get fullName;
  String get username;
  GTime get birthDate;
  GUserStudyTime get studyTime;
  static Serializer<GVerifyOTPAndRegisterInput> get serializer =>
      _$gVerifyOTPAndRegisterInputSerializer;

  Map<String, dynamic> toJson() => (_i2.serializers.serializeWith(
        GVerifyOTPAndRegisterInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterInput? fromJson(Map<String, dynamic> json) =>
      _i2.serializers.deserializeWith(
        GVerifyOTPAndRegisterInput.serializer,
        json,
      );
}

const Map<String, Set<String>> possibleTypesMap = {
  'Node': {
    'Goal',
    'Interest',
    'Tag',
    'Task',
    'User',
  },
  'InboxEvent': {
    'NewMessageEvent',
    'MessageDeletedEvent',
    'UserActivityEvent',
  },
};
