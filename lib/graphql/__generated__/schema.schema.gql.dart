// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:gql_code_builder_serializers/gql_code_builder_serializers.dart'
    as _i2;
import 'package:simo_learn/graphql/__generated__/serializers.gql.dart' as _i1;

part 'schema.schema.gql.g.dart';

abstract class GAuthSessionOrder
    implements Built<GAuthSessionOrder, GAuthSessionOrderBuilder> {
  GAuthSessionOrder._();

  factory GAuthSessionOrder(
          [void Function(GAuthSessionOrderBuilder b) updates]) =
      _$GAuthSessionOrder;

  GOrderDirection get direction;
  GAuthSessionOrderField get field;
  static Serializer<GAuthSessionOrder> get serializer =>
      _$gAuthSessionOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAuthSessionOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAuthSessionOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAuthSessionOrder.serializer,
        json,
      );
}

class GAuthSessionOrderField extends EnumClass {
  const GAuthSessionOrderField._(String name) : super(name);

  static const GAuthSessionOrderField CREATED_AT =
      _$gAuthSessionOrderFieldCREATED_AT;

  static const GAuthSessionOrderField UPDATED_AT =
      _$gAuthSessionOrderFieldUPDATED_AT;

  static Serializer<GAuthSessionOrderField> get serializer =>
      _$gAuthSessionOrderFieldSerializer;

  static BuiltSet<GAuthSessionOrderField> get values =>
      _$gAuthSessionOrderFieldValues;

  static GAuthSessionOrderField valueOf(String name) =>
      _$gAuthSessionOrderFieldValueOf(name);
}

abstract class GAuthSessionWhereInput
    implements Built<GAuthSessionWhereInput, GAuthSessionWhereInputBuilder> {
  GAuthSessionWhereInput._();

  factory GAuthSessionWhereInput(
          [void Function(GAuthSessionWhereInputBuilder b) updates]) =
      _$GAuthSessionWhereInput;

  GAuthSessionWhereInput? get not;
  BuiltList<GAuthSessionWhereInput>? get and;
  BuiltList<GAuthSessionWhereInput>? get or;
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
  String? get refreshTokenHash;
  String? get refreshTokenHashNEQ;
  BuiltList<String>? get refreshTokenHashIn;
  BuiltList<String>? get refreshTokenHashNotIn;
  String? get refreshTokenHashGT;
  String? get refreshTokenHashGTE;
  String? get refreshTokenHashLT;
  String? get refreshTokenHashLTE;
  String? get refreshTokenHashContains;
  String? get refreshTokenHashHasPrefix;
  String? get refreshTokenHashHasSuffix;
  String? get refreshTokenHashEqualFold;
  String? get refreshTokenHashContainsFold;
  String? get deviceID;
  String? get deviceIDNEQ;
  BuiltList<String>? get deviceIDIn;
  BuiltList<String>? get deviceIDNotIn;
  String? get deviceIDGT;
  String? get deviceIDGTE;
  String? get deviceIDLT;
  String? get deviceIDLTE;
  String? get deviceIDContains;
  String? get deviceIDHasPrefix;
  String? get deviceIDHasSuffix;
  bool? get deviceIDIsNil;
  bool? get deviceIDNotNil;
  String? get deviceIDEqualFold;
  String? get deviceIDContainsFold;
  String? get deviceName;
  String? get deviceNameNEQ;
  BuiltList<String>? get deviceNameIn;
  BuiltList<String>? get deviceNameNotIn;
  String? get deviceNameGT;
  String? get deviceNameGTE;
  String? get deviceNameLT;
  String? get deviceNameLTE;
  String? get deviceNameContains;
  String? get deviceNameHasPrefix;
  String? get deviceNameHasSuffix;
  bool? get deviceNameIsNil;
  bool? get deviceNameNotNil;
  String? get deviceNameEqualFold;
  String? get deviceNameContainsFold;
  String? get ipAddress;
  String? get ipAddressNEQ;
  BuiltList<String>? get ipAddressIn;
  BuiltList<String>? get ipAddressNotIn;
  String? get ipAddressGT;
  String? get ipAddressGTE;
  String? get ipAddressLT;
  String? get ipAddressLTE;
  String? get ipAddressContains;
  String? get ipAddressHasPrefix;
  String? get ipAddressHasSuffix;
  bool? get ipAddressIsNil;
  bool? get ipAddressNotNil;
  String? get ipAddressEqualFold;
  String? get ipAddressContainsFold;
  String? get userAgent;
  String? get userAgentNEQ;
  BuiltList<String>? get userAgentIn;
  BuiltList<String>? get userAgentNotIn;
  String? get userAgentGT;
  String? get userAgentGTE;
  String? get userAgentLT;
  String? get userAgentLTE;
  String? get userAgentContains;
  String? get userAgentHasPrefix;
  String? get userAgentHasSuffix;
  bool? get userAgentIsNil;
  bool? get userAgentNotNil;
  String? get userAgentEqualFold;
  String? get userAgentContainsFold;
  GTime? get lastUsedAt;
  GTime? get lastUsedAtNEQ;
  BuiltList<GTime>? get lastUsedAtIn;
  BuiltList<GTime>? get lastUsedAtNotIn;
  GTime? get lastUsedAtGT;
  GTime? get lastUsedAtGTE;
  GTime? get lastUsedAtLT;
  GTime? get lastUsedAtLTE;
  bool? get lastUsedAtIsNil;
  bool? get lastUsedAtNotNil;
  GTime? get revokedAt;
  GTime? get revokedAtNEQ;
  BuiltList<GTime>? get revokedAtIn;
  BuiltList<GTime>? get revokedAtNotIn;
  GTime? get revokedAtGT;
  GTime? get revokedAtGTE;
  GTime? get revokedAtLT;
  GTime? get revokedAtLTE;
  bool? get revokedAtIsNil;
  bool? get revokedAtNotNil;
  GTime? get expiresAt;
  GTime? get expiresAtNEQ;
  BuiltList<GTime>? get expiresAtIn;
  BuiltList<GTime>? get expiresAtNotIn;
  GTime? get expiresAtGT;
  GTime? get expiresAtGTE;
  GTime? get expiresAtLT;
  GTime? get expiresAtLTE;
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  static Serializer<GAuthSessionWhereInput> get serializer =>
      _$gAuthSessionWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GAuthSessionWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GAuthSessionWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GAuthSessionWhereInput.serializer,
        json,
      );
}

abstract class GBeginCounselingPaymentInput
    implements
        Built<GBeginCounselingPaymentInput,
            GBeginCounselingPaymentInputBuilder> {
  GBeginCounselingPaymentInput._();

  factory GBeginCounselingPaymentInput(
          [void Function(GBeginCounselingPaymentInputBuilder b) updates]) =
      _$GBeginCounselingPaymentInput;

  String get subscriptionID;
  String get idempotencyKey;
  static Serializer<GBeginCounselingPaymentInput> get serializer =>
      _$gBeginCounselingPaymentInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GBeginCounselingPaymentInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GBeginCounselingPaymentInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GBeginCounselingPaymentInput.serializer,
        json,
      );
}

abstract class GChatOrder implements Built<GChatOrder, GChatOrderBuilder> {
  GChatOrder._();

  factory GChatOrder([void Function(GChatOrderBuilder b) updates]) =
      _$GChatOrder;

  GOrderDirection get direction;
  GChatOrderField get field;
  static Serializer<GChatOrder> get serializer => _$gChatOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GChatOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GChatOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GChatOrder.serializer,
        json,
      );
}

class GChatOrderField extends EnumClass {
  const GChatOrderField._(String name) : super(name);

  static const GChatOrderField CREATED_AT = _$gChatOrderFieldCREATED_AT;

  static const GChatOrderField UPDATED_AT = _$gChatOrderFieldUPDATED_AT;

  static Serializer<GChatOrderField> get serializer =>
      _$gChatOrderFieldSerializer;

  static BuiltSet<GChatOrderField> get values => _$gChatOrderFieldValues;

  static GChatOrderField valueOf(String name) => _$gChatOrderFieldValueOf(name);
}

abstract class GChatParticipantOrder
    implements Built<GChatParticipantOrder, GChatParticipantOrderBuilder> {
  GChatParticipantOrder._();

  factory GChatParticipantOrder(
          [void Function(GChatParticipantOrderBuilder b) updates]) =
      _$GChatParticipantOrder;

  GOrderDirection get direction;
  GChatParticipantOrderField get field;
  static Serializer<GChatParticipantOrder> get serializer =>
      _$gChatParticipantOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GChatParticipantOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GChatParticipantOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GChatParticipantOrder.serializer,
        json,
      );
}

class GChatParticipantOrderField extends EnumClass {
  const GChatParticipantOrderField._(String name) : super(name);

  static const GChatParticipantOrderField CREATED_AT =
      _$gChatParticipantOrderFieldCREATED_AT;

  static const GChatParticipantOrderField UPDATED_AT =
      _$gChatParticipantOrderFieldUPDATED_AT;

  static Serializer<GChatParticipantOrderField> get serializer =>
      _$gChatParticipantOrderFieldSerializer;

  static BuiltSet<GChatParticipantOrderField> get values =>
      _$gChatParticipantOrderFieldValues;

  static GChatParticipantOrderField valueOf(String name) =>
      _$gChatParticipantOrderFieldValueOf(name);
}

abstract class GChatParticipantWhereInput
    implements
        Built<GChatParticipantWhereInput, GChatParticipantWhereInputBuilder> {
  GChatParticipantWhereInput._();

  factory GChatParticipantWhereInput(
          [void Function(GChatParticipantWhereInputBuilder b) updates]) =
      _$GChatParticipantWhereInput;

  GChatParticipantWhereInput? get not;
  BuiltList<GChatParticipantWhereInput>? get and;
  BuiltList<GChatParticipantWhereInput>? get or;
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
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  String? get chatID;
  String? get chatIDNEQ;
  BuiltList<String>? get chatIDIn;
  BuiltList<String>? get chatIDNotIn;
  GTime? get lastReadAt;
  GTime? get lastReadAtNEQ;
  BuiltList<GTime>? get lastReadAtIn;
  BuiltList<GTime>? get lastReadAtNotIn;
  GTime? get lastReadAtGT;
  GTime? get lastReadAtGTE;
  GTime? get lastReadAtLT;
  GTime? get lastReadAtLTE;
  bool? get lastReadAtIsNil;
  bool? get lastReadAtNotNil;
  GTime? get clearedHistoryAt;
  GTime? get clearedHistoryAtNEQ;
  BuiltList<GTime>? get clearedHistoryAtIn;
  BuiltList<GTime>? get clearedHistoryAtNotIn;
  GTime? get clearedHistoryAtGT;
  GTime? get clearedHistoryAtGTE;
  GTime? get clearedHistoryAtLT;
  GTime? get clearedHistoryAtLTE;
  bool? get clearedHistoryAtIsNil;
  bool? get clearedHistoryAtNotNil;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasChat;
  BuiltList<GChatWhereInput>? get hasChatWith;
  static Serializer<GChatParticipantWhereInput> get serializer =>
      _$gChatParticipantWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GChatParticipantWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GChatParticipantWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GChatParticipantWhereInput.serializer,
        json,
      );
}

class GChatType extends EnumClass {
  const GChatType._(String name) : super(name);

  static const GChatType DIRECT = _$gChatTypeDIRECT;

  static const GChatType GROUP = _$gChatTypeGROUP;

  static Serializer<GChatType> get serializer => _$gChatTypeSerializer;

  static BuiltSet<GChatType> get values => _$gChatTypeValues;

  static GChatType valueOf(String name) => _$gChatTypeValueOf(name);
}

abstract class GChatWhereInput
    implements Built<GChatWhereInput, GChatWhereInputBuilder> {
  GChatWhereInput._();

  factory GChatWhereInput([void Function(GChatWhereInputBuilder b) updates]) =
      _$GChatWhereInput;

  GChatWhereInput? get not;
  BuiltList<GChatWhereInput>? get and;
  BuiltList<GChatWhereInput>? get or;
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
  GChatType? get type;
  GChatType? get typeNEQ;
  BuiltList<GChatType>? get typeIn;
  BuiltList<GChatType>? get typeNotIn;
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
  bool? get nameIsNil;
  bool? get nameNotNil;
  String? get nameEqualFold;
  String? get nameContainsFold;
  bool? get hasMessages;
  BuiltList<GMessageWhereInput>? get hasMessagesWith;
  bool? get hasParticipants;
  BuiltList<GChatParticipantWhereInput>? get hasParticipantsWith;
  static Serializer<GChatWhereInput> get serializer =>
      _$gChatWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GChatWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GChatWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GChatWhereInput.serializer,
        json,
      );
}

class GCounselingPaymentAttemptCurrency extends EnumClass {
  const GCounselingPaymentAttemptCurrency._(String name) : super(name);

  static const GCounselingPaymentAttemptCurrency TOMAN =
      _$gCounselingPaymentAttemptCurrencyTOMAN;

  static Serializer<GCounselingPaymentAttemptCurrency> get serializer =>
      _$gCounselingPaymentAttemptCurrencySerializer;

  static BuiltSet<GCounselingPaymentAttemptCurrency> get values =>
      _$gCounselingPaymentAttemptCurrencyValues;

  static GCounselingPaymentAttemptCurrency valueOf(String name) =>
      _$gCounselingPaymentAttemptCurrencyValueOf(name);
}

class GCounselingPaymentAttemptStatus extends EnumClass {
  const GCounselingPaymentAttemptStatus._(String name) : super(name);

  static const GCounselingPaymentAttemptStatus PENDING =
      _$gCounselingPaymentAttemptStatusPENDING;

  static const GCounselingPaymentAttemptStatus SUCCEEDED =
      _$gCounselingPaymentAttemptStatusSUCCEEDED;

  static const GCounselingPaymentAttemptStatus FAILED =
      _$gCounselingPaymentAttemptStatusFAILED;

  static const GCounselingPaymentAttemptStatus EXPIRED =
      _$gCounselingPaymentAttemptStatusEXPIRED;

  static Serializer<GCounselingPaymentAttemptStatus> get serializer =>
      _$gCounselingPaymentAttemptStatusSerializer;

  static BuiltSet<GCounselingPaymentAttemptStatus> get values =>
      _$gCounselingPaymentAttemptStatusValues;

  static GCounselingPaymentAttemptStatus valueOf(String name) =>
      _$gCounselingPaymentAttemptStatusValueOf(name);
}

class GCounselingSubscriptionCancellationReason extends EnumClass {
  const GCounselingSubscriptionCancellationReason._(String name) : super(name);

  static const GCounselingSubscriptionCancellationReason USER_CANCELLED =
      _$gCounselingSubscriptionCancellationReasonUSER_CANCELLED;

  static const GCounselingSubscriptionCancellationReason PAYMENT_TIMEOUT =
      _$gCounselingSubscriptionCancellationReasonPAYMENT_TIMEOUT;

  static Serializer<GCounselingSubscriptionCancellationReason> get serializer =>
      _$gCounselingSubscriptionCancellationReasonSerializer;

  static BuiltSet<GCounselingSubscriptionCancellationReason> get values =>
      _$gCounselingSubscriptionCancellationReasonValues;

  static GCounselingSubscriptionCancellationReason valueOf(String name) =>
      _$gCounselingSubscriptionCancellationReasonValueOf(name);
}

class GCounselingSubscriptionCurrency extends EnumClass {
  const GCounselingSubscriptionCurrency._(String name) : super(name);

  static const GCounselingSubscriptionCurrency TOMAN =
      _$gCounselingSubscriptionCurrencyTOMAN;

  static Serializer<GCounselingSubscriptionCurrency> get serializer =>
      _$gCounselingSubscriptionCurrencySerializer;

  static BuiltSet<GCounselingSubscriptionCurrency> get values =>
      _$gCounselingSubscriptionCurrencyValues;

  static GCounselingSubscriptionCurrency valueOf(String name) =>
      _$gCounselingSubscriptionCurrencyValueOf(name);
}

abstract class GCounselingSubscriptionOrder
    implements
        Built<GCounselingSubscriptionOrder,
            GCounselingSubscriptionOrderBuilder> {
  GCounselingSubscriptionOrder._();

  factory GCounselingSubscriptionOrder(
          [void Function(GCounselingSubscriptionOrderBuilder b) updates]) =
      _$GCounselingSubscriptionOrder;

  GOrderDirection get direction;
  GCounselingSubscriptionOrderField get field;
  static Serializer<GCounselingSubscriptionOrder> get serializer =>
      _$gCounselingSubscriptionOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselingSubscriptionOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselingSubscriptionOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselingSubscriptionOrder.serializer,
        json,
      );
}

class GCounselingSubscriptionOrderField extends EnumClass {
  const GCounselingSubscriptionOrderField._(String name) : super(name);

  static const GCounselingSubscriptionOrderField CREATED_AT =
      _$gCounselingSubscriptionOrderFieldCREATED_AT;

  static const GCounselingSubscriptionOrderField UPDATED_AT =
      _$gCounselingSubscriptionOrderFieldUPDATED_AT;

  static Serializer<GCounselingSubscriptionOrderField> get serializer =>
      _$gCounselingSubscriptionOrderFieldSerializer;

  static BuiltSet<GCounselingSubscriptionOrderField> get values =>
      _$gCounselingSubscriptionOrderFieldValues;

  static GCounselingSubscriptionOrderField valueOf(String name) =>
      _$gCounselingSubscriptionOrderFieldValueOf(name);
}

class GCounselingSubscriptionPlanType extends EnumClass {
  const GCounselingSubscriptionPlanType._(String name) : super(name);

  static const GCounselingSubscriptionPlanType NORMAL =
      _$gCounselingSubscriptionPlanTypeNORMAL;

  static const GCounselingSubscriptionPlanType PROFESSIONAL =
      _$gCounselingSubscriptionPlanTypePROFESSIONAL;

  static const GCounselingSubscriptionPlanType ADVANCED =
      _$gCounselingSubscriptionPlanTypeADVANCED;

  static Serializer<GCounselingSubscriptionPlanType> get serializer =>
      _$gCounselingSubscriptionPlanTypeSerializer;

  static BuiltSet<GCounselingSubscriptionPlanType> get values =>
      _$gCounselingSubscriptionPlanTypeValues;

  static GCounselingSubscriptionPlanType valueOf(String name) =>
      _$gCounselingSubscriptionPlanTypeValueOf(name);
}

class GCounselingSubscriptionStatus extends EnumClass {
  const GCounselingSubscriptionStatus._(String name) : super(name);

  static const GCounselingSubscriptionStatus PENDING =
      _$gCounselingSubscriptionStatusPENDING;

  static const GCounselingSubscriptionStatus ACTIVE =
      _$gCounselingSubscriptionStatusACTIVE;

  static const GCounselingSubscriptionStatus EXPIRED =
      _$gCounselingSubscriptionStatusEXPIRED;

  static const GCounselingSubscriptionStatus CANCELLED =
      _$gCounselingSubscriptionStatusCANCELLED;

  static Serializer<GCounselingSubscriptionStatus> get serializer =>
      _$gCounselingSubscriptionStatusSerializer;

  static BuiltSet<GCounselingSubscriptionStatus> get values =>
      _$gCounselingSubscriptionStatusValues;

  static GCounselingSubscriptionStatus valueOf(String name) =>
      _$gCounselingSubscriptionStatusValueOf(name);
}

abstract class GCounselingSubscriptionWhereInput
    implements
        Built<GCounselingSubscriptionWhereInput,
            GCounselingSubscriptionWhereInputBuilder> {
  GCounselingSubscriptionWhereInput._();

  factory GCounselingSubscriptionWhereInput(
          [void Function(GCounselingSubscriptionWhereInputBuilder b) updates]) =
      _$GCounselingSubscriptionWhereInput;

  GCounselingSubscriptionWhereInput? get not;
  BuiltList<GCounselingSubscriptionWhereInput>? get and;
  BuiltList<GCounselingSubscriptionWhereInput>? get or;
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
  int? get durationMonths;
  int? get durationMonthsNEQ;
  BuiltList<int>? get durationMonthsIn;
  BuiltList<int>? get durationMonthsNotIn;
  int? get durationMonthsGT;
  int? get durationMonthsGTE;
  int? get durationMonthsLT;
  int? get durationMonthsLTE;
  GCounselingSubscriptionPlanType? get planType;
  GCounselingSubscriptionPlanType? get planTypeNEQ;
  BuiltList<GCounselingSubscriptionPlanType>? get planTypeIn;
  BuiltList<GCounselingSubscriptionPlanType>? get planTypeNotIn;
  GCounselingSubscriptionStatus? get status;
  GCounselingSubscriptionStatus? get statusNEQ;
  BuiltList<GCounselingSubscriptionStatus>? get statusIn;
  BuiltList<GCounselingSubscriptionStatus>? get statusNotIn;
  GCounselingSubscriptionCancellationReason? get cancellationReason;
  GCounselingSubscriptionCancellationReason? get cancellationReasonNEQ;
  BuiltList<GCounselingSubscriptionCancellationReason>?
      get cancellationReasonIn;
  BuiltList<GCounselingSubscriptionCancellationReason>?
      get cancellationReasonNotIn;
  bool? get cancellationReasonIsNil;
  bool? get cancellationReasonNotNil;
  int? get cost;
  int? get costNEQ;
  BuiltList<int>? get costIn;
  BuiltList<int>? get costNotIn;
  int? get costGT;
  int? get costGTE;
  int? get costLT;
  int? get costLTE;
  GCounselingSubscriptionCurrency? get currency;
  GCounselingSubscriptionCurrency? get currencyNEQ;
  BuiltList<GCounselingSubscriptionCurrency>? get currencyIn;
  BuiltList<GCounselingSubscriptionCurrency>? get currencyNotIn;
  GTime? get pendingExpiresAt;
  GTime? get pendingExpiresAtNEQ;
  BuiltList<GTime>? get pendingExpiresAtIn;
  BuiltList<GTime>? get pendingExpiresAtNotIn;
  GTime? get pendingExpiresAtGT;
  GTime? get pendingExpiresAtGTE;
  GTime? get pendingExpiresAtLT;
  GTime? get pendingExpiresAtLTE;
  bool? get pendingExpiresAtIsNil;
  bool? get pendingExpiresAtNotNil;
  GTime? get startDate;
  GTime? get startDateNEQ;
  BuiltList<GTime>? get startDateIn;
  BuiltList<GTime>? get startDateNotIn;
  GTime? get startDateGT;
  GTime? get startDateGTE;
  GTime? get startDateLT;
  GTime? get startDateLTE;
  bool? get startDateIsNil;
  bool? get startDateNotNil;
  GTime? get endDate;
  GTime? get endDateNEQ;
  BuiltList<GTime>? get endDateIn;
  BuiltList<GTime>? get endDateNotIn;
  GTime? get endDateGT;
  GTime? get endDateGTE;
  GTime? get endDateLT;
  GTime? get endDateLTE;
  bool? get endDateIsNil;
  bool? get endDateNotNil;
  String? get studentID;
  String? get studentIDNEQ;
  BuiltList<String>? get studentIDIn;
  BuiltList<String>? get studentIDNotIn;
  String? get counselorID;
  String? get counselorIDNEQ;
  BuiltList<String>? get counselorIDIn;
  BuiltList<String>? get counselorIDNotIn;
  bool? get hasReview;
  BuiltList<GCounselorReviewWhereInput>? get hasReviewWith;
  bool? get hasStudent;
  BuiltList<GUserWhereInput>? get hasStudentWith;
  bool? get hasCounselor;
  BuiltList<GCounselorProfileWhereInput>? get hasCounselorWith;
  static Serializer<GCounselingSubscriptionWhereInput> get serializer =>
      _$gCounselingSubscriptionWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselingSubscriptionWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselingSubscriptionWhereInput? fromJson(
          Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselingSubscriptionWhereInput.serializer,
        json,
      );
}

abstract class GCounselorProfileOrder
    implements Built<GCounselorProfileOrder, GCounselorProfileOrderBuilder> {
  GCounselorProfileOrder._();

  factory GCounselorProfileOrder(
          [void Function(GCounselorProfileOrderBuilder b) updates]) =
      _$GCounselorProfileOrder;

  GOrderDirection get direction;
  GCounselorProfileOrderField get field;
  static Serializer<GCounselorProfileOrder> get serializer =>
      _$gCounselorProfileOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselorProfileOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselorProfileOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselorProfileOrder.serializer,
        json,
      );
}

class GCounselorProfileOrderField extends EnumClass {
  const GCounselorProfileOrderField._(String name) : super(name);

  static const GCounselorProfileOrderField CREATED_AT =
      _$gCounselorProfileOrderFieldCREATED_AT;

  static const GCounselorProfileOrderField UPDATED_AT =
      _$gCounselorProfileOrderFieldUPDATED_AT;

  static Serializer<GCounselorProfileOrderField> get serializer =>
      _$gCounselorProfileOrderFieldSerializer;

  static BuiltSet<GCounselorProfileOrderField> get values =>
      _$gCounselorProfileOrderFieldValues;

  static GCounselorProfileOrderField valueOf(String name) =>
      _$gCounselorProfileOrderFieldValueOf(name);
}

abstract class GCounselorProfileWhereInput
    implements
        Built<GCounselorProfileWhereInput, GCounselorProfileWhereInputBuilder> {
  GCounselorProfileWhereInput._();

  factory GCounselorProfileWhereInput(
          [void Function(GCounselorProfileWhereInputBuilder b) updates]) =
      _$GCounselorProfileWhereInput;

  GCounselorProfileWhereInput? get not;
  BuiltList<GCounselorProfileWhereInput>? get and;
  BuiltList<GCounselorProfileWhereInput>? get or;
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
  int? get ratingCount;
  int? get ratingCountNEQ;
  BuiltList<int>? get ratingCountIn;
  BuiltList<int>? get ratingCountNotIn;
  int? get ratingCountGT;
  int? get ratingCountGTE;
  int? get ratingCountLT;
  int? get ratingCountLTE;
  double? get ratingAverage;
  double? get ratingAverageNEQ;
  BuiltList<double>? get ratingAverageIn;
  BuiltList<double>? get ratingAverageNotIn;
  double? get ratingAverageGT;
  double? get ratingAverageGTE;
  double? get ratingAverageLT;
  double? get ratingAverageLTE;
  bool? get ratingAverageIsNil;
  bool? get ratingAverageNotNil;
  bool? get isPublished;
  bool? get isPublishedNEQ;
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasReviews;
  BuiltList<GCounselorReviewWhereInput>? get hasReviewsWith;
  bool? get hasSubscriptions;
  BuiltList<GCounselingSubscriptionWhereInput>? get hasSubscriptionsWith;
  static Serializer<GCounselorProfileWhereInput> get serializer =>
      _$gCounselorProfileWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselorProfileWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselorProfileWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselorProfileWhereInput.serializer,
        json,
      );
}

abstract class GCounselorReviewOrder
    implements Built<GCounselorReviewOrder, GCounselorReviewOrderBuilder> {
  GCounselorReviewOrder._();

  factory GCounselorReviewOrder(
          [void Function(GCounselorReviewOrderBuilder b) updates]) =
      _$GCounselorReviewOrder;

  GOrderDirection get direction;
  GCounselorReviewOrderField get field;
  static Serializer<GCounselorReviewOrder> get serializer =>
      _$gCounselorReviewOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselorReviewOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselorReviewOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselorReviewOrder.serializer,
        json,
      );
}

class GCounselorReviewOrderField extends EnumClass {
  const GCounselorReviewOrderField._(String name) : super(name);

  static const GCounselorReviewOrderField CREATED_AT =
      _$gCounselorReviewOrderFieldCREATED_AT;

  static const GCounselorReviewOrderField UPDATED_AT =
      _$gCounselorReviewOrderFieldUPDATED_AT;

  static Serializer<GCounselorReviewOrderField> get serializer =>
      _$gCounselorReviewOrderFieldSerializer;

  static BuiltSet<GCounselorReviewOrderField> get values =>
      _$gCounselorReviewOrderFieldValues;

  static GCounselorReviewOrderField valueOf(String name) =>
      _$gCounselorReviewOrderFieldValueOf(name);
}

abstract class GCounselorReviewWhereInput
    implements
        Built<GCounselorReviewWhereInput, GCounselorReviewWhereInputBuilder> {
  GCounselorReviewWhereInput._();

  factory GCounselorReviewWhereInput(
          [void Function(GCounselorReviewWhereInputBuilder b) updates]) =
      _$GCounselorReviewWhereInput;

  GCounselorReviewWhereInput? get not;
  BuiltList<GCounselorReviewWhereInput>? get and;
  BuiltList<GCounselorReviewWhereInput>? get or;
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
  int? get score;
  int? get scoreNEQ;
  BuiltList<int>? get scoreIn;
  BuiltList<int>? get scoreNotIn;
  int? get scoreGT;
  int? get scoreGTE;
  int? get scoreLT;
  int? get scoreLTE;
  String? get comment;
  String? get commentNEQ;
  BuiltList<String>? get commentIn;
  BuiltList<String>? get commentNotIn;
  String? get commentGT;
  String? get commentGTE;
  String? get commentLT;
  String? get commentLTE;
  String? get commentContains;
  String? get commentHasPrefix;
  String? get commentHasSuffix;
  bool? get commentIsNil;
  bool? get commentNotNil;
  String? get commentEqualFold;
  String? get commentContainsFold;
  String? get studentID;
  String? get studentIDNEQ;
  BuiltList<String>? get studentIDIn;
  BuiltList<String>? get studentIDNotIn;
  String? get counselorID;
  String? get counselorIDNEQ;
  BuiltList<String>? get counselorIDIn;
  BuiltList<String>? get counselorIDNotIn;
  String? get subscriptionID;
  String? get subscriptionIDNEQ;
  BuiltList<String>? get subscriptionIDIn;
  BuiltList<String>? get subscriptionIDNotIn;
  bool? get subscriptionIDIsNil;
  bool? get subscriptionIDNotNil;
  bool? get hasStudent;
  BuiltList<GUserWhereInput>? get hasStudentWith;
  bool? get hasCounselor;
  BuiltList<GCounselorProfileWhereInput>? get hasCounselorWith;
  bool? get hasSubscription;
  BuiltList<GCounselingSubscriptionWhereInput>? get hasSubscriptionWith;
  static Serializer<GCounselorReviewWhereInput> get serializer =>
      _$gCounselorReviewWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCounselorReviewWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCounselorReviewWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCounselorReviewWhereInput.serializer,
        json,
      );
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateDirectChatInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateDirectChatInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateDirectChatInput.serializer,
        json,
      );
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateGoalInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGoalInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateGoalInput.serializer,
        json,
      );
}

abstract class GCreateGroupChatInput
    implements Built<GCreateGroupChatInput, GCreateGroupChatInputBuilder> {
  GCreateGroupChatInput._();

  factory GCreateGroupChatInput(
          [void Function(GCreateGroupChatInputBuilder b) updates]) =
      _$GCreateGroupChatInput;

  String get name;
  BuiltList<GUUID> get memberIDs;
  static Serializer<GCreateGroupChatInput> get serializer =>
      _$gCreateGroupChatInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateGroupChatInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateGroupChatInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateGroupChatInput.serializer,
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
  String? get subjectTagID;
  static Serializer<GCreateTaskInput> get serializer =>
      _$gCreateTaskInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GCreateTaskInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GCreateTaskInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GCreateTaskInput.serializer,
        json,
      );
}

abstract class GCursor implements Built<GCursor, GCursorBuilder> {
  GCursor._();

  factory GCursor([String? value]) =>
      _$GCursor((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GCursor> get serializer =>
      _i2.DefaultScalarSerializer<GCursor>(
          (Object serialized) => GCursor((serialized as String?)));
}

abstract class GDeviceTokenOrder
    implements Built<GDeviceTokenOrder, GDeviceTokenOrderBuilder> {
  GDeviceTokenOrder._();

  factory GDeviceTokenOrder(
          [void Function(GDeviceTokenOrderBuilder b) updates]) =
      _$GDeviceTokenOrder;

  GOrderDirection get direction;
  GDeviceTokenOrderField get field;
  static Serializer<GDeviceTokenOrder> get serializer =>
      _$gDeviceTokenOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeviceTokenOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeviceTokenOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeviceTokenOrder.serializer,
        json,
      );
}

class GDeviceTokenOrderField extends EnumClass {
  const GDeviceTokenOrderField._(String name) : super(name);

  static const GDeviceTokenOrderField CREATED_AT =
      _$gDeviceTokenOrderFieldCREATED_AT;

  static const GDeviceTokenOrderField UPDATED_AT =
      _$gDeviceTokenOrderFieldUPDATED_AT;

  static Serializer<GDeviceTokenOrderField> get serializer =>
      _$gDeviceTokenOrderFieldSerializer;

  static BuiltSet<GDeviceTokenOrderField> get values =>
      _$gDeviceTokenOrderFieldValues;

  static GDeviceTokenOrderField valueOf(String name) =>
      _$gDeviceTokenOrderFieldValueOf(name);
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

abstract class GDeviceTokenWhereInput
    implements Built<GDeviceTokenWhereInput, GDeviceTokenWhereInputBuilder> {
  GDeviceTokenWhereInput._();

  factory GDeviceTokenWhereInput(
          [void Function(GDeviceTokenWhereInputBuilder b) updates]) =
      _$GDeviceTokenWhereInput;

  GDeviceTokenWhereInput? get not;
  BuiltList<GDeviceTokenWhereInput>? get and;
  BuiltList<GDeviceTokenWhereInput>? get or;
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
  String? get token;
  String? get tokenNEQ;
  BuiltList<String>? get tokenIn;
  BuiltList<String>? get tokenNotIn;
  String? get tokenGT;
  String? get tokenGTE;
  String? get tokenLT;
  String? get tokenLTE;
  String? get tokenContains;
  String? get tokenHasPrefix;
  String? get tokenHasSuffix;
  String? get tokenEqualFold;
  String? get tokenContainsFold;
  GDeviceTokenPlatform? get platform;
  GDeviceTokenPlatform? get platformNEQ;
  BuiltList<GDeviceTokenPlatform>? get platformIn;
  BuiltList<GDeviceTokenPlatform>? get platformNotIn;
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  static Serializer<GDeviceTokenWhereInput> get serializer =>
      _$gDeviceTokenWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GDeviceTokenWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GDeviceTokenWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GDeviceTokenWhereInput.serializer,
        json,
      );
}

abstract class GFriendshipOrder
    implements Built<GFriendshipOrder, GFriendshipOrderBuilder> {
  GFriendshipOrder._();

  factory GFriendshipOrder([void Function(GFriendshipOrderBuilder b) updates]) =
      _$GFriendshipOrder;

  GOrderDirection get direction;
  GFriendshipOrderField get field;
  static Serializer<GFriendshipOrder> get serializer =>
      _$gFriendshipOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFriendshipOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFriendshipOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFriendshipOrder.serializer,
        json,
      );
}

class GFriendshipOrderField extends EnumClass {
  const GFriendshipOrderField._(String name) : super(name);

  static const GFriendshipOrderField CREATED_AT =
      _$gFriendshipOrderFieldCREATED_AT;

  static const GFriendshipOrderField UPDATED_AT =
      _$gFriendshipOrderFieldUPDATED_AT;

  static Serializer<GFriendshipOrderField> get serializer =>
      _$gFriendshipOrderFieldSerializer;

  static BuiltSet<GFriendshipOrderField> get values =>
      _$gFriendshipOrderFieldValues;

  static GFriendshipOrderField valueOf(String name) =>
      _$gFriendshipOrderFieldValueOf(name);
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

abstract class GFriendshipWhereInput
    implements Built<GFriendshipWhereInput, GFriendshipWhereInputBuilder> {
  GFriendshipWhereInput._();

  factory GFriendshipWhereInput(
          [void Function(GFriendshipWhereInputBuilder b) updates]) =
      _$GFriendshipWhereInput;

  GFriendshipWhereInput? get not;
  BuiltList<GFriendshipWhereInput>? get and;
  BuiltList<GFriendshipWhereInput>? get or;
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
  String? get requesterID;
  String? get requesterIDNEQ;
  BuiltList<String>? get requesterIDIn;
  BuiltList<String>? get requesterIDNotIn;
  String? get receiverID;
  String? get receiverIDNEQ;
  BuiltList<String>? get receiverIDIn;
  BuiltList<String>? get receiverIDNotIn;
  GUUID? get userLowID;
  GUUID? get userLowIDNEQ;
  BuiltList<GUUID>? get userLowIDIn;
  BuiltList<GUUID>? get userLowIDNotIn;
  GUUID? get userLowIDGT;
  GUUID? get userLowIDGTE;
  GUUID? get userLowIDLT;
  GUUID? get userLowIDLTE;
  GUUID? get userHighID;
  GUUID? get userHighIDNEQ;
  BuiltList<GUUID>? get userHighIDIn;
  BuiltList<GUUID>? get userHighIDNotIn;
  GUUID? get userHighIDGT;
  GUUID? get userHighIDGTE;
  GUUID? get userHighIDLT;
  GUUID? get userHighIDLTE;
  GFriendshipStatus? get status;
  GFriendshipStatus? get statusNEQ;
  BuiltList<GFriendshipStatus>? get statusIn;
  BuiltList<GFriendshipStatus>? get statusNotIn;
  bool? get hasRequester;
  BuiltList<GUserWhereInput>? get hasRequesterWith;
  bool? get hasReceiver;
  BuiltList<GUserWhereInput>? get hasReceiverWith;
  static Serializer<GFriendshipWhereInput> get serializer =>
      _$gFriendshipWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GFriendshipWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GFriendshipWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GFriendshipWhereInput.serializer,
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGoalOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGoalOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GGoalOrder.serializer,
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
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  static Serializer<GGoalWhereInput> get serializer =>
      _$gGoalWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GGoalWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GGoalWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GInterestWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GInterestWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GInterestWhereInput.serializer,
        json,
      );
}

abstract class GMessageOrder
    implements Built<GMessageOrder, GMessageOrderBuilder> {
  GMessageOrder._();

  factory GMessageOrder([void Function(GMessageOrderBuilder b) updates]) =
      _$GMessageOrder;

  GOrderDirection get direction;
  GMessageOrderField get field;
  static Serializer<GMessageOrder> get serializer => _$gMessageOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GMessageOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMessageOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GMessageOrder.serializer,
        json,
      );
}

class GMessageOrderField extends EnumClass {
  const GMessageOrderField._(String name) : super(name);

  static const GMessageOrderField CREATED_AT = _$gMessageOrderFieldCREATED_AT;

  static const GMessageOrderField UPDATED_AT = _$gMessageOrderFieldUPDATED_AT;

  static Serializer<GMessageOrderField> get serializer =>
      _$gMessageOrderFieldSerializer;

  static BuiltSet<GMessageOrderField> get values => _$gMessageOrderFieldValues;

  static GMessageOrderField valueOf(String name) =>
      _$gMessageOrderFieldValueOf(name);
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

abstract class GMessageWhereInput
    implements Built<GMessageWhereInput, GMessageWhereInputBuilder> {
  GMessageWhereInput._();

  factory GMessageWhereInput(
          [void Function(GMessageWhereInputBuilder b) updates]) =
      _$GMessageWhereInput;

  GMessageWhereInput? get not;
  BuiltList<GMessageWhereInput>? get and;
  BuiltList<GMessageWhereInput>? get or;
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
  String? get content;
  String? get contentNEQ;
  BuiltList<String>? get contentIn;
  BuiltList<String>? get contentNotIn;
  String? get contentGT;
  String? get contentGTE;
  String? get contentLT;
  String? get contentLTE;
  String? get contentContains;
  String? get contentHasPrefix;
  String? get contentHasSuffix;
  String? get contentEqualFold;
  String? get contentContainsFold;
  GMessageType? get type;
  GMessageType? get typeNEQ;
  BuiltList<GMessageType>? get typeIn;
  BuiltList<GMessageType>? get typeNotIn;
  String? get chatID;
  String? get chatIDNEQ;
  BuiltList<String>? get chatIDIn;
  BuiltList<String>? get chatIDNotIn;
  String? get senderID;
  String? get senderIDNEQ;
  BuiltList<String>? get senderIDIn;
  BuiltList<String>? get senderIDNotIn;
  String? get replyToID;
  String? get replyToIDNEQ;
  BuiltList<String>? get replyToIDIn;
  BuiltList<String>? get replyToIDNotIn;
  bool? get replyToIDIsNil;
  bool? get replyToIDNotNil;
  bool? get isDeleted;
  bool? get isDeletedNEQ;
  GTime? get deletedAt;
  GTime? get deletedAtNEQ;
  BuiltList<GTime>? get deletedAtIn;
  BuiltList<GTime>? get deletedAtNotIn;
  GTime? get deletedAtGT;
  GTime? get deletedAtGTE;
  GTime? get deletedAtLT;
  GTime? get deletedAtLTE;
  bool? get deletedAtIsNil;
  bool? get deletedAtNotNil;
  bool? get hasReplyTo;
  BuiltList<GMessageWhereInput>? get hasReplyToWith;
  bool? get hasReplies;
  BuiltList<GMessageWhereInput>? get hasRepliesWith;
  bool? get hasChat;
  BuiltList<GChatWhereInput>? get hasChatWith;
  bool? get hasSender;
  BuiltList<GUserWhereInput>? get hasSenderWith;
  bool? get hasDeletedBy;
  BuiltList<GUserWhereInput>? get hasDeletedByWith;
  static Serializer<GMessageWhereInput> get serializer =>
      _$gMessageWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GMessageWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GMessageWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GMessageWhereInput.serializer,
        json,
      );
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

class GOTPClient extends EnumClass {
  const GOTPClient._(String name) : super(name);

  static const GOTPClient WEB = _$gOTPClientWEB;

  static const GOTPClient ANDROID = _$gOTPClientANDROID;

  static Serializer<GOTPClient> get serializer => _$gOTPClientSerializer;

  static BuiltSet<GOTPClient> get values => _$gOTPClientValues;

  static GOTPClient valueOf(String name) => _$gOTPClientValueOf(name);
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRefreshTokenInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRefreshTokenInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRefreshTokenInput.serializer,
        json,
      );
}

abstract class GRequestCounselingInput
    implements Built<GRequestCounselingInput, GRequestCounselingInputBuilder> {
  GRequestCounselingInput._();

  factory GRequestCounselingInput(
          [void Function(GRequestCounselingInputBuilder b) updates]) =
      _$GRequestCounselingInput;

  String get counselorProfileID;
  int get durationMonths;
  GCounselingSubscriptionPlanType get planType;
  static Serializer<GRequestCounselingInput> get serializer =>
      _$gRequestCounselingInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GRequestCounselingInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GRequestCounselingInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GRequestCounselingInput.serializer,
        json,
      );
}

abstract class GSaveTaskCompletionReportInput
    implements
        Built<GSaveTaskCompletionReportInput,
            GSaveTaskCompletionReportInputBuilder> {
  GSaveTaskCompletionReportInput._();

  factory GSaveTaskCompletionReportInput(
          [void Function(GSaveTaskCompletionReportInputBuilder b) updates]) =
      _$GSaveTaskCompletionReportInput;

  int get performanceRating;
  bool get tookTest;
  int? get totalQuestions;
  int? get correctAnswers;
  static Serializer<GSaveTaskCompletionReportInput> get serializer =>
      _$gSaveTaskCompletionReportInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSaveTaskCompletionReportInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSaveTaskCompletionReportInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSaveTaskCompletionReportInput.serializer,
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendMessageInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendMessageInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendMessageInput.serializer,
        json,
      );
}

abstract class GSendOTPInput
    implements Built<GSendOTPInput, GSendOTPInputBuilder> {
  GSendOTPInput._();

  factory GSendOTPInput([void Function(GSendOTPInputBuilder b) updates]) =
      _$GSendOTPInput;

  String get phoneNumber;
  GOTPClient get client;
  static Serializer<GSendOTPInput> get serializer => _$gSendOTPInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSendOTPInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSendOTPInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSendOTPInput.serializer,
        json,
      );
}

abstract class GStatisticsDashboardInput
    implements
        Built<GStatisticsDashboardInput, GStatisticsDashboardInputBuilder> {
  GStatisticsDashboardInput._();

  factory GStatisticsDashboardInput(
          [void Function(GStatisticsDashboardInputBuilder b) updates]) =
      _$GStatisticsDashboardInput;

  GTime get start;
  GTime get end;
  GTime get previousStart;
  GTime get previousEnd;
  static Serializer<GStatisticsDashboardInput> get serializer =>
      _$gStatisticsDashboardInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GStatisticsDashboardInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GStatisticsDashboardInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GStatisticsDashboardInput.serializer,
        json,
      );
}

abstract class GSubmitCounselorReviewInput
    implements
        Built<GSubmitCounselorReviewInput, GSubmitCounselorReviewInputBuilder> {
  GSubmitCounselorReviewInput._();

  factory GSubmitCounselorReviewInput(
          [void Function(GSubmitCounselorReviewInputBuilder b) updates]) =
      _$GSubmitCounselorReviewInput;

  String get subscriptionID;
  int get score;
  String? get comment;
  static Serializer<GSubmitCounselorReviewInput> get serializer =>
      _$gSubmitCounselorReviewInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GSubmitCounselorReviewInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GSubmitCounselorReviewInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GSubmitCounselorReviewInput.serializer,
        json,
      );
}

abstract class GTagKeywordWhereInput
    implements Built<GTagKeywordWhereInput, GTagKeywordWhereInputBuilder> {
  GTagKeywordWhereInput._();

  factory GTagKeywordWhereInput(
          [void Function(GTagKeywordWhereInputBuilder b) updates]) =
      _$GTagKeywordWhereInput;

  GTagKeywordWhereInput? get not;
  BuiltList<GTagKeywordWhereInput>? get and;
  BuiltList<GTagKeywordWhereInput>? get or;
  String? get id;
  String? get idNEQ;
  BuiltList<String>? get idIn;
  BuiltList<String>? get idNotIn;
  String? get idGT;
  String? get idGTE;
  String? get idLT;
  String? get idLTE;
  String? get term;
  String? get termNEQ;
  BuiltList<String>? get termIn;
  BuiltList<String>? get termNotIn;
  String? get termGT;
  String? get termGTE;
  String? get termLT;
  String? get termLTE;
  String? get termContains;
  String? get termHasPrefix;
  String? get termHasSuffix;
  String? get termEqualFold;
  String? get termContainsFold;
  int? get count;
  int? get countNEQ;
  BuiltList<int>? get countIn;
  BuiltList<int>? get countNotIn;
  int? get countGT;
  int? get countGTE;
  int? get countLT;
  int? get countLTE;
  String? get tagID;
  String? get tagIDNEQ;
  BuiltList<String>? get tagIDIn;
  BuiltList<String>? get tagIDNotIn;
  bool? get hasTag;
  BuiltList<GTagWhereInput>? get hasTagWith;
  static Serializer<GTagKeywordWhereInput> get serializer =>
      _$gTagKeywordWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTagKeywordWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTagKeywordWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTagKeywordWhereInput.serializer,
        json,
      );
}

class GTagKind extends EnumClass {
  const GTagKind._(String name) : super(name);

  static const GTagKind PARENT = _$gTagKindPARENT;

  static const GTagKind CUSTOM = _$gTagKindCUSTOM;

  static Serializer<GTagKind> get serializer => _$gTagKindSerializer;

  static BuiltSet<GTagKind> get values => _$gTagKindValues;

  static GTagKind valueOf(String name) => _$gTagKindValueOf(name);
}

class GTagModerationStatus extends EnumClass {
  const GTagModerationStatus._(String name) : super(name);

  static const GTagModerationStatus PENDING = _$gTagModerationStatusPENDING;

  static const GTagModerationStatus APPROVED = _$gTagModerationStatusAPPROVED;

  static const GTagModerationStatus BLOCKED = _$gTagModerationStatusBLOCKED;

  static Serializer<GTagModerationStatus> get serializer =>
      _$gTagModerationStatusSerializer;

  static BuiltSet<GTagModerationStatus> get values =>
      _$gTagModerationStatusValues;

  static GTagModerationStatus valueOf(String name) =>
      _$gTagModerationStatusValueOf(name);
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
  GTagKind? get kind;
  GTagKind? get kindNEQ;
  BuiltList<GTagKind>? get kindIn;
  BuiltList<GTagKind>? get kindNotIn;
  GTagModerationStatus? get moderationStatus;
  GTagModerationStatus? get moderationStatusNEQ;
  BuiltList<GTagModerationStatus>? get moderationStatusIn;
  BuiltList<GTagModerationStatus>? get moderationStatusNotIn;
  String? get parentID;
  String? get parentIDNEQ;
  BuiltList<String>? get parentIDIn;
  BuiltList<String>? get parentIDNotIn;
  bool? get parentIDIsNil;
  bool? get parentIDNotNil;
  String? get createdByID;
  String? get createdByIDNEQ;
  BuiltList<String>? get createdByIDIn;
  BuiltList<String>? get createdByIDNotIn;
  bool? get createdByIDIsNil;
  bool? get createdByIDNotNil;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  bool? get hasKeywords;
  BuiltList<GTagKeywordWhereInput>? get hasKeywordsWith;
  bool? get hasChildren;
  BuiltList<GTagWhereInput>? get hasChildrenWith;
  bool? get hasParent;
  BuiltList<GTagWhereInput>? get hasParentWith;
  bool? get hasCreatedBy;
  BuiltList<GUserWhereInput>? get hasCreatedByWith;
  bool? get hasSubjectTasks;
  BuiltList<GTaskWhereInput>? get hasSubjectTasksWith;
  static Serializer<GTagWhereInput> get serializer =>
      _$gTagWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTagWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTagWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTagWhereInput.serializer,
        json,
      );
}

abstract class GTaskCompletionReportOrder
    implements
        Built<GTaskCompletionReportOrder, GTaskCompletionReportOrderBuilder> {
  GTaskCompletionReportOrder._();

  factory GTaskCompletionReportOrder(
          [void Function(GTaskCompletionReportOrderBuilder b) updates]) =
      _$GTaskCompletionReportOrder;

  GOrderDirection get direction;
  GTaskCompletionReportOrderField get field;
  static Serializer<GTaskCompletionReportOrder> get serializer =>
      _$gTaskCompletionReportOrderSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskCompletionReportOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskCompletionReportOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskCompletionReportOrder.serializer,
        json,
      );
}

class GTaskCompletionReportOrderField extends EnumClass {
  const GTaskCompletionReportOrderField._(String name) : super(name);

  static const GTaskCompletionReportOrderField CREATED_AT =
      _$gTaskCompletionReportOrderFieldCREATED_AT;

  static const GTaskCompletionReportOrderField UPDATED_AT =
      _$gTaskCompletionReportOrderFieldUPDATED_AT;

  static Serializer<GTaskCompletionReportOrderField> get serializer =>
      _$gTaskCompletionReportOrderFieldSerializer;

  static BuiltSet<GTaskCompletionReportOrderField> get values =>
      _$gTaskCompletionReportOrderFieldValues;

  static GTaskCompletionReportOrderField valueOf(String name) =>
      _$gTaskCompletionReportOrderFieldValueOf(name);
}

abstract class GTaskCompletionReportWhereInput
    implements
        Built<GTaskCompletionReportWhereInput,
            GTaskCompletionReportWhereInputBuilder> {
  GTaskCompletionReportWhereInput._();

  factory GTaskCompletionReportWhereInput(
          [void Function(GTaskCompletionReportWhereInputBuilder b) updates]) =
      _$GTaskCompletionReportWhereInput;

  GTaskCompletionReportWhereInput? get not;
  BuiltList<GTaskCompletionReportWhereInput>? get and;
  BuiltList<GTaskCompletionReportWhereInput>? get or;
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
  int? get performanceRating;
  int? get performanceRatingNEQ;
  BuiltList<int>? get performanceRatingIn;
  BuiltList<int>? get performanceRatingNotIn;
  int? get performanceRatingGT;
  int? get performanceRatingGTE;
  int? get performanceRatingLT;
  int? get performanceRatingLTE;
  bool? get tookTest;
  bool? get tookTestNEQ;
  int? get totalQuestions;
  int? get totalQuestionsNEQ;
  BuiltList<int>? get totalQuestionsIn;
  BuiltList<int>? get totalQuestionsNotIn;
  int? get totalQuestionsGT;
  int? get totalQuestionsGTE;
  int? get totalQuestionsLT;
  int? get totalQuestionsLTE;
  bool? get totalQuestionsIsNil;
  bool? get totalQuestionsNotNil;
  int? get correctAnswers;
  int? get correctAnswersNEQ;
  BuiltList<int>? get correctAnswersIn;
  BuiltList<int>? get correctAnswersNotIn;
  int? get correctAnswersGT;
  int? get correctAnswersGTE;
  int? get correctAnswersLT;
  int? get correctAnswersLTE;
  bool? get correctAnswersIsNil;
  bool? get correctAnswersNotNil;
  String? get taskID;
  String? get taskIDNEQ;
  BuiltList<String>? get taskIDIn;
  BuiltList<String>? get taskIDNotIn;
  bool? get hasTask;
  BuiltList<GTaskWhereInput>? get hasTaskWith;
  static Serializer<GTaskCompletionReportWhereInput> get serializer =>
      _$gTaskCompletionReportWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskCompletionReportWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskCompletionReportWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskCompletionReportWhereInput.serializer,
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskOrder.serializer,
        json,
      );
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

  static const GTaskStatus PAUSED = _$gTaskStatusPAUSED;

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
  int? get elapsedSeconds;
  int? get elapsedSecondsNEQ;
  BuiltList<int>? get elapsedSecondsIn;
  BuiltList<int>? get elapsedSecondsNotIn;
  int? get elapsedSecondsGT;
  int? get elapsedSecondsGTE;
  int? get elapsedSecondsLT;
  int? get elapsedSecondsLTE;
  GTime? get timerStartedAt;
  GTime? get timerStartedAtNEQ;
  BuiltList<GTime>? get timerStartedAtIn;
  BuiltList<GTime>? get timerStartedAtNotIn;
  GTime? get timerStartedAtGT;
  GTime? get timerStartedAtGTE;
  GTime? get timerStartedAtLT;
  GTime? get timerStartedAtLTE;
  bool? get timerStartedAtIsNil;
  bool? get timerStartedAtNotNil;
  GTime? get completedAt;
  GTime? get completedAtNEQ;
  BuiltList<GTime>? get completedAtIn;
  BuiltList<GTime>? get completedAtNotIn;
  GTime? get completedAtGT;
  GTime? get completedAtGTE;
  GTime? get completedAtLT;
  GTime? get completedAtLTE;
  bool? get completedAtIsNil;
  bool? get completedAtNotNil;
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
  String? get userID;
  String? get userIDNEQ;
  BuiltList<String>? get userIDIn;
  BuiltList<String>? get userIDNotIn;
  String? get goalID;
  String? get goalIDNEQ;
  BuiltList<String>? get goalIDIn;
  BuiltList<String>? get goalIDNotIn;
  bool? get goalIDIsNil;
  bool? get goalIDNotNil;
  String? get subjectTagID;
  String? get subjectTagIDNEQ;
  BuiltList<String>? get subjectTagIDIn;
  BuiltList<String>? get subjectTagIDNotIn;
  bool? get subjectTagIDIsNil;
  bool? get subjectTagIDNotNil;
  bool? get hasUser;
  BuiltList<GUserWhereInput>? get hasUserWith;
  bool? get hasGoal;
  BuiltList<GGoalWhereInput>? get hasGoalWith;
  bool? get hasTags;
  BuiltList<GTagWhereInput>? get hasTagsWith;
  bool? get hasSubjectTag;
  BuiltList<GTagWhereInput>? get hasSubjectTagWith;
  bool? get hasCompletionReport;
  BuiltList<GTaskCompletionReportWhereInput>? get hasCompletionReportWith;
  static Serializer<GTaskWhereInput> get serializer =>
      _$gTaskWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GTaskWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GTaskWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GTaskWhereInput.serializer,
        json,
      );
}

abstract class GTime implements Built<GTime, GTimeBuilder> {
  GTime._();

  factory GTime([String? value]) =>
      _$GTime((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GTime> get serializer => _i2.DefaultScalarSerializer<GTime>(
      (Object serialized) => GTime((serialized as String?)));
}

abstract class GUpdateCounselorProfileInput
    implements
        Built<GUpdateCounselorProfileInput,
            GUpdateCounselorProfileInputBuilder> {
  GUpdateCounselorProfileInput._();

  factory GUpdateCounselorProfileInput(
          [void Function(GUpdateCounselorProfileInputBuilder b) updates]) =
      _$GUpdateCounselorProfileInput;

  String? get title;
  BuiltList<String>? get resumeItems;
  bool? get isPublished;
  static Serializer<GUpdateCounselorProfileInput> get serializer =>
      _$gUpdateCounselorProfileInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateCounselorProfileInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateCounselorProfileInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUpdateCounselorProfileInput.serializer,
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateGoalInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateGoalInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateProfileInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateProfileInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
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
  String? get subjectTagID;
  bool? get clearSubjectTag;
  static Serializer<GUpdateTaskInput> get serializer =>
      _$gUpdateTaskInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUpdateTaskInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUpdateTaskInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUserOrder.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUserOrder? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUserOrder.serializer,
        json,
      );
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

  static const GUserRole COUNSELOR = _$gUserRoleCOUNSELOR;

  static const GUserRole ADMIN = _$gUserRoleADMIN;

  static const GUserRole SUPER_ADMIN = _$gUserRoleSUPER_ADMIN;

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
  String? get username;
  String? get usernameNEQ;
  BuiltList<String>? get usernameIn;
  BuiltList<String>? get usernameNotIn;
  String? get usernameGT;
  String? get usernameGTE;
  String? get usernameLT;
  String? get usernameLTE;
  String? get usernameContains;
  String? get usernameHasPrefix;
  String? get usernameHasSuffix;
  String? get usernameEqualFold;
  String? get usernameContainsFold;
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
  String? get avatarURL;
  String? get avatarURLNEQ;
  BuiltList<String>? get avatarURLIn;
  BuiltList<String>? get avatarURLNotIn;
  String? get avatarURLGT;
  String? get avatarURLGTE;
  String? get avatarURLLT;
  String? get avatarURLLTE;
  String? get avatarURLContains;
  String? get avatarURLHasPrefix;
  String? get avatarURLHasSuffix;
  bool? get avatarURLIsNil;
  bool? get avatarURLNotNil;
  String? get avatarURLEqualFold;
  String? get avatarURLContainsFold;
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
  GTime? get lastSeenAt;
  GTime? get lastSeenAtNEQ;
  BuiltList<GTime>? get lastSeenAtIn;
  BuiltList<GTime>? get lastSeenAtNotIn;
  GTime? get lastSeenAtGT;
  GTime? get lastSeenAtGTE;
  GTime? get lastSeenAtLT;
  GTime? get lastSeenAtLTE;
  bool? get lastSeenAtIsNil;
  bool? get lastSeenAtNotNil;
  bool? get hasAuthSessions;
  BuiltList<GAuthSessionWhereInput>? get hasAuthSessionsWith;
  bool? get hasInterests;
  BuiltList<GInterestWhereInput>? get hasInterestsWith;
  bool? get hasGoals;
  BuiltList<GGoalWhereInput>? get hasGoalsWith;
  bool? get hasTasks;
  BuiltList<GTaskWhereInput>? get hasTasksWith;
  bool? get hasChatParticipations;
  BuiltList<GChatParticipantWhereInput>? get hasChatParticipationsWith;
  bool? get hasMessages;
  BuiltList<GMessageWhereInput>? get hasMessagesWith;
  bool? get hasDeletedMessages;
  BuiltList<GMessageWhereInput>? get hasDeletedMessagesWith;
  bool? get hasCounselorProfile;
  BuiltList<GCounselorProfileWhereInput>? get hasCounselorProfileWith;
  bool? get hasCounselorReviewsGiven;
  BuiltList<GCounselorReviewWhereInput>? get hasCounselorReviewsGivenWith;
  bool? get hasCounselingPurchases;
  BuiltList<GCounselingSubscriptionWhereInput>? get hasCounselingPurchasesWith;
  bool? get hasDeviceTokens;
  BuiltList<GDeviceTokenWhereInput>? get hasDeviceTokensWith;
  bool? get hasCreatedTags;
  BuiltList<GTagWhereInput>? get hasCreatedTagsWith;
  static Serializer<GUserWhereInput> get serializer =>
      _$gUserWhereInputSerializer;

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GUserWhereInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GUserWhereInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GUserWhereInput.serializer,
        json,
      );
}

abstract class GUUID implements Built<GUUID, GUUIDBuilder> {
  GUUID._();

  factory GUUID([String? value]) =>
      _$GUUID((b) => value != null ? (b..value = value) : b);

  String get value;
  @BuiltValueSerializer(custom: true)
  static Serializer<GUUID> get serializer => _i2.DefaultScalarSerializer<GUUID>(
      (Object serialized) => GUUID((serialized as String?)));
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndLoginInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndLoginInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
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

  Map<String, dynamic> toJson() => (_i1.serializers.serializeWith(
        GVerifyOTPAndRegisterInput.serializer,
        this,
      ) as Map<String, dynamic>);

  static GVerifyOTPAndRegisterInput? fromJson(Map<String, dynamic> json) =>
      _i1.serializers.deserializeWith(
        GVerifyOTPAndRegisterInput.serializer,
        json,
      );
}

const Map<String, Set<String>> possibleTypesMap = {
  'Node': {
    'AuthSession',
    'Chat',
    'ChatParticipant',
    'CounselingSubscription',
    'CounselorProfile',
    'CounselorReview',
    'DeviceToken',
    'Friendship',
    'Goal',
    'Interest',
    'Message',
    'Tag',
    'TagKeyword',
    'Task',
    'TaskCompletionReport',
    'User',
  },
  'InboxEvent': {
    'NewMessageEvent',
    'MessageDeletedEvent',
    'MessageSeenEvent',
    'UserActivityEvent',
    'FriendRequestEvent',
  },
};
