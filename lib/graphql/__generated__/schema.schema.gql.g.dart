// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schema.schema.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const GChatType _$gChatTypeDIRECT = const GChatType._('DIRECT');
const GChatType _$gChatTypeGROUP = const GChatType._('GROUP');

GChatType _$gChatTypeValueOf(String name) {
  switch (name) {
    case 'DIRECT':
      return _$gChatTypeDIRECT;
    case 'GROUP':
      return _$gChatTypeGROUP;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GChatType> _$gChatTypeValues =
    new BuiltSet<GChatType>(const <GChatType>[
  _$gChatTypeDIRECT,
  _$gChatTypeGROUP,
]);

const GMessageType _$gMessageTypeTEXT = const GMessageType._('TEXT');
const GMessageType _$gMessageTypeDUEL_INVITE =
    const GMessageType._('DUEL_INVITE');
const GMessageType _$gMessageTypeSYSTEM = const GMessageType._('SYSTEM');

GMessageType _$gMessageTypeValueOf(String name) {
  switch (name) {
    case 'TEXT':
      return _$gMessageTypeTEXT;
    case 'DUEL_INVITE':
      return _$gMessageTypeDUEL_INVITE;
    case 'SYSTEM':
      return _$gMessageTypeSYSTEM;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GMessageType> _$gMessageTypeValues =
    new BuiltSet<GMessageType>(const <GMessageType>[
  _$gMessageTypeTEXT,
  _$gMessageTypeDUEL_INVITE,
  _$gMessageTypeSYSTEM,
]);

const GFriendshipStatus _$gFriendshipStatusPENDING =
    const GFriendshipStatus._('PENDING');
const GFriendshipStatus _$gFriendshipStatusACCEPTED =
    const GFriendshipStatus._('ACCEPTED');
const GFriendshipStatus _$gFriendshipStatusREJECTED =
    const GFriendshipStatus._('REJECTED');
const GFriendshipStatus _$gFriendshipStatusBLOCKED =
    const GFriendshipStatus._('BLOCKED');

GFriendshipStatus _$gFriendshipStatusValueOf(String name) {
  switch (name) {
    case 'PENDING':
      return _$gFriendshipStatusPENDING;
    case 'ACCEPTED':
      return _$gFriendshipStatusACCEPTED;
    case 'REJECTED':
      return _$gFriendshipStatusREJECTED;
    case 'BLOCKED':
      return _$gFriendshipStatusBLOCKED;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GFriendshipStatus> _$gFriendshipStatusValues =
    new BuiltSet<GFriendshipStatus>(const <GFriendshipStatus>[
  _$gFriendshipStatusPENDING,
  _$gFriendshipStatusACCEPTED,
  _$gFriendshipStatusREJECTED,
  _$gFriendshipStatusBLOCKED,
]);

const GGoalOrderField _$gGoalOrderFieldCREATED_AT =
    const GGoalOrderField._('CREATED_AT');
const GGoalOrderField _$gGoalOrderFieldUPDATED_AT =
    const GGoalOrderField._('UPDATED_AT');

GGoalOrderField _$gGoalOrderFieldValueOf(String name) {
  switch (name) {
    case 'CREATED_AT':
      return _$gGoalOrderFieldCREATED_AT;
    case 'UPDATED_AT':
      return _$gGoalOrderFieldUPDATED_AT;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GGoalOrderField> _$gGoalOrderFieldValues =
    new BuiltSet<GGoalOrderField>(const <GGoalOrderField>[
  _$gGoalOrderFieldCREATED_AT,
  _$gGoalOrderFieldUPDATED_AT,
]);

const GGoalStatus _$gGoalStatusIN_PROGRESS = const GGoalStatus._('IN_PROGRESS');
const GGoalStatus _$gGoalStatusCOMPLETED = const GGoalStatus._('COMPLETED');
const GGoalStatus _$gGoalStatusPAUSED = const GGoalStatus._('PAUSED');
const GGoalStatus _$gGoalStatusARCHIVED = const GGoalStatus._('ARCHIVED');

GGoalStatus _$gGoalStatusValueOf(String name) {
  switch (name) {
    case 'IN_PROGRESS':
      return _$gGoalStatusIN_PROGRESS;
    case 'COMPLETED':
      return _$gGoalStatusCOMPLETED;
    case 'PAUSED':
      return _$gGoalStatusPAUSED;
    case 'ARCHIVED':
      return _$gGoalStatusARCHIVED;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GGoalStatus> _$gGoalStatusValues =
    new BuiltSet<GGoalStatus>(const <GGoalStatus>[
  _$gGoalStatusIN_PROGRESS,
  _$gGoalStatusCOMPLETED,
  _$gGoalStatusPAUSED,
  _$gGoalStatusARCHIVED,
]);

const GOrderDirection _$gOrderDirectionASC = const GOrderDirection._('ASC');
const GOrderDirection _$gOrderDirectionDESC = const GOrderDirection._('DESC');

GOrderDirection _$gOrderDirectionValueOf(String name) {
  switch (name) {
    case 'ASC':
      return _$gOrderDirectionASC;
    case 'DESC':
      return _$gOrderDirectionDESC;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GOrderDirection> _$gOrderDirectionValues =
    new BuiltSet<GOrderDirection>(const <GOrderDirection>[
  _$gOrderDirectionASC,
  _$gOrderDirectionDESC,
]);

const GTaskOrderField _$gTaskOrderFieldCREATED_AT =
    const GTaskOrderField._('CREATED_AT');
const GTaskOrderField _$gTaskOrderFieldUPDATED_AT =
    const GTaskOrderField._('UPDATED_AT');

GTaskOrderField _$gTaskOrderFieldValueOf(String name) {
  switch (name) {
    case 'CREATED_AT':
      return _$gTaskOrderFieldCREATED_AT;
    case 'UPDATED_AT':
      return _$gTaskOrderFieldUPDATED_AT;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GTaskOrderField> _$gTaskOrderFieldValues =
    new BuiltSet<GTaskOrderField>(const <GTaskOrderField>[
  _$gTaskOrderFieldCREATED_AT,
  _$gTaskOrderFieldUPDATED_AT,
]);

const GTaskStatus _$gTaskStatusTODO = const GTaskStatus._('TODO');
const GTaskStatus _$gTaskStatusIN_PROGRESS = const GTaskStatus._('IN_PROGRESS');
const GTaskStatus _$gTaskStatusCOMPLETED = const GTaskStatus._('COMPLETED');
const GTaskStatus _$gTaskStatusCANCELED = const GTaskStatus._('CANCELED');

GTaskStatus _$gTaskStatusValueOf(String name) {
  switch (name) {
    case 'TODO':
      return _$gTaskStatusTODO;
    case 'IN_PROGRESS':
      return _$gTaskStatusIN_PROGRESS;
    case 'COMPLETED':
      return _$gTaskStatusCOMPLETED;
    case 'CANCELED':
      return _$gTaskStatusCANCELED;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GTaskStatus> _$gTaskStatusValues =
    new BuiltSet<GTaskStatus>(const <GTaskStatus>[
  _$gTaskStatusTODO,
  _$gTaskStatusIN_PROGRESS,
  _$gTaskStatusCOMPLETED,
  _$gTaskStatusCANCELED,
]);

const GTaskType _$gTaskTypeNORMAL = const GTaskType._('NORMAL');
const GTaskType _$gTaskTypeTIMED = const GTaskType._('TIMED');

GTaskType _$gTaskTypeValueOf(String name) {
  switch (name) {
    case 'NORMAL':
      return _$gTaskTypeNORMAL;
    case 'TIMED':
      return _$gTaskTypeTIMED;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GTaskType> _$gTaskTypeValues =
    new BuiltSet<GTaskType>(const <GTaskType>[
  _$gTaskTypeNORMAL,
  _$gTaskTypeTIMED,
]);

const GUserOrderField _$gUserOrderFieldCREATED_AT =
    const GUserOrderField._('CREATED_AT');
const GUserOrderField _$gUserOrderFieldUPDATED_AT =
    const GUserOrderField._('UPDATED_AT');

GUserOrderField _$gUserOrderFieldValueOf(String name) {
  switch (name) {
    case 'CREATED_AT':
      return _$gUserOrderFieldCREATED_AT;
    case 'UPDATED_AT':
      return _$gUserOrderFieldUPDATED_AT;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GUserOrderField> _$gUserOrderFieldValues =
    new BuiltSet<GUserOrderField>(const <GUserOrderField>[
  _$gUserOrderFieldCREATED_AT,
  _$gUserOrderFieldUPDATED_AT,
]);

const GUserRole _$gUserRoleUSER = const GUserRole._('USER');
const GUserRole _$gUserRoleADVISOR = const GUserRole._('ADVISOR');
const GUserRole _$gUserRoleADMIN = const GUserRole._('ADMIN');

GUserRole _$gUserRoleValueOf(String name) {
  switch (name) {
    case 'USER':
      return _$gUserRoleUSER;
    case 'ADVISOR':
      return _$gUserRoleADVISOR;
    case 'ADMIN':
      return _$gUserRoleADMIN;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GUserRole> _$gUserRoleValues =
    new BuiltSet<GUserRole>(const <GUserRole>[
  _$gUserRoleUSER,
  _$gUserRoleADVISOR,
  _$gUserRoleADMIN,
]);

const GUserStudyTime _$gUserStudyTimeUNDER_4_HOURS =
    const GUserStudyTime._('UNDER_4_HOURS');
const GUserStudyTime _$gUserStudyTimeBETWEEN_4_AND_7 =
    const GUserStudyTime._('BETWEEN_4_AND_7');
const GUserStudyTime _$gUserStudyTimeOVER_7_HOURS =
    const GUserStudyTime._('OVER_7_HOURS');

GUserStudyTime _$gUserStudyTimeValueOf(String name) {
  switch (name) {
    case 'UNDER_4_HOURS':
      return _$gUserStudyTimeUNDER_4_HOURS;
    case 'BETWEEN_4_AND_7':
      return _$gUserStudyTimeBETWEEN_4_AND_7;
    case 'OVER_7_HOURS':
      return _$gUserStudyTimeOVER_7_HOURS;
    default:
      throw new ArgumentError(name);
  }
}

final BuiltSet<GUserStudyTime> _$gUserStudyTimeValues =
    new BuiltSet<GUserStudyTime>(const <GUserStudyTime>[
  _$gUserStudyTimeUNDER_4_HOURS,
  _$gUserStudyTimeBETWEEN_4_AND_7,
  _$gUserStudyTimeOVER_7_HOURS,
]);

Serializer<GChatType> _$gChatTypeSerializer = new _$GChatTypeSerializer();
Serializer<GMessageType> _$gMessageTypeSerializer =
    new _$GMessageTypeSerializer();
Serializer<GFriendshipStatus> _$gFriendshipStatusSerializer =
    new _$GFriendshipStatusSerializer();
Serializer<GCreateDirectChatInput> _$gCreateDirectChatInputSerializer =
    new _$GCreateDirectChatInputSerializer();
Serializer<GSendMessageInput> _$gSendMessageInputSerializer =
    new _$GSendMessageInputSerializer();
Serializer<GGoalOrderField> _$gGoalOrderFieldSerializer =
    new _$GGoalOrderFieldSerializer();
Serializer<GGoalStatus> _$gGoalStatusSerializer = new _$GGoalStatusSerializer();
Serializer<GOrderDirection> _$gOrderDirectionSerializer =
    new _$GOrderDirectionSerializer();
Serializer<GTaskOrderField> _$gTaskOrderFieldSerializer =
    new _$GTaskOrderFieldSerializer();
Serializer<GTaskStatus> _$gTaskStatusSerializer = new _$GTaskStatusSerializer();
Serializer<GTaskType> _$gTaskTypeSerializer = new _$GTaskTypeSerializer();
Serializer<GUserOrderField> _$gUserOrderFieldSerializer =
    new _$GUserOrderFieldSerializer();
Serializer<GUserRole> _$gUserRoleSerializer = new _$GUserRoleSerializer();
Serializer<GUserStudyTime> _$gUserStudyTimeSerializer =
    new _$GUserStudyTimeSerializer();
Serializer<GCreateGoalInput> _$gCreateGoalInputSerializer =
    new _$GCreateGoalInputSerializer();
Serializer<GCreateTaskInput> _$gCreateTaskInputSerializer =
    new _$GCreateTaskInputSerializer();
Serializer<GGoalOrder> _$gGoalOrderSerializer = new _$GGoalOrderSerializer();
Serializer<GGoalWhereInput> _$gGoalWhereInputSerializer =
    new _$GGoalWhereInputSerializer();
Serializer<GInterestWhereInput> _$gInterestWhereInputSerializer =
    new _$GInterestWhereInputSerializer();
Serializer<GSendOTPInput> _$gSendOTPInputSerializer =
    new _$GSendOTPInputSerializer();
Serializer<GRefreshTokenInput> _$gRefreshTokenInputSerializer =
    new _$GRefreshTokenInputSerializer();
Serializer<GTagWhereInput> _$gTagWhereInputSerializer =
    new _$GTagWhereInputSerializer();
Serializer<GTaskOrder> _$gTaskOrderSerializer = new _$GTaskOrderSerializer();
Serializer<GTaskWhereInput> _$gTaskWhereInputSerializer =
    new _$GTaskWhereInputSerializer();
Serializer<GUpdateGoalInput> _$gUpdateGoalInputSerializer =
    new _$GUpdateGoalInputSerializer();
Serializer<GUpdateProfileInput> _$gUpdateProfileInputSerializer =
    new _$GUpdateProfileInputSerializer();
Serializer<GUpdateTaskInput> _$gUpdateTaskInputSerializer =
    new _$GUpdateTaskInputSerializer();
Serializer<GUserOrder> _$gUserOrderSerializer = new _$GUserOrderSerializer();
Serializer<GUserWhereInput> _$gUserWhereInputSerializer =
    new _$GUserWhereInputSerializer();
Serializer<GVerifyOTPAndLoginInput> _$gVerifyOTPAndLoginInputSerializer =
    new _$GVerifyOTPAndLoginInputSerializer();
Serializer<GVerifyOTPAndRegisterInput> _$gVerifyOTPAndRegisterInputSerializer =
    new _$GVerifyOTPAndRegisterInputSerializer();

class _$GChatTypeSerializer implements PrimitiveSerializer<GChatType> {
  @override
  final Iterable<Type> types = const <Type>[GChatType];
  @override
  final String wireName = 'GChatType';

  @override
  Object serialize(Serializers serializers, GChatType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GChatType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GChatType.valueOf(serialized as String);
}

class _$GMessageTypeSerializer implements PrimitiveSerializer<GMessageType> {
  @override
  final Iterable<Type> types = const <Type>[GMessageType];
  @override
  final String wireName = 'GMessageType';

  @override
  Object serialize(Serializers serializers, GMessageType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GMessageType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GMessageType.valueOf(serialized as String);
}

class _$GFriendshipStatusSerializer
    implements PrimitiveSerializer<GFriendshipStatus> {
  @override
  final Iterable<Type> types = const <Type>[GFriendshipStatus];
  @override
  final String wireName = 'GFriendshipStatus';

  @override
  Object serialize(Serializers serializers, GFriendshipStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GFriendshipStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GFriendshipStatus.valueOf(serialized as String);
}

class _$GCreateDirectChatInputSerializer
    implements StructuredSerializer<GCreateDirectChatInput> {
  @override
  final Iterable<Type> types = const [
    GCreateDirectChatInput,
    _$GCreateDirectChatInput
  ];
  @override
  final String wireName = 'GCreateDirectChatInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateDirectChatInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'targetUserID',
      serializers.serialize(object.targetUserID,
          specifiedType: const FullType(GUUID)),
    ];

    return result;
  }

  @override
  GCreateDirectChatInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GCreateDirectChatInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'targetUserID':
          result.targetUserID.replace(serializers.deserialize(value,
              specifiedType: const FullType(GUUID))! as GUUID);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendMessageInputSerializer
    implements StructuredSerializer<GSendMessageInput> {
  @override
  final Iterable<Type> types = const [GSendMessageInput, _$GSendMessageInput];
  @override
  final String wireName = 'GSendMessageInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendMessageInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'chatID',
      serializers.serialize(object.chatID,
          specifiedType: const FullType(String)),
      'content',
      serializers.serialize(object.content,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.replyToID;
    if (value != null) {
      result
        ..add('replyToID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GSendMessageInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendMessageInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'chatID':
          result.chatID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'content':
          result.content = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'replyToID':
          result.replyToID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GGoalOrderFieldSerializer
    implements PrimitiveSerializer<GGoalOrderField> {
  @override
  final Iterable<Type> types = const <Type>[GGoalOrderField];
  @override
  final String wireName = 'GGoalOrderField';

  @override
  Object serialize(Serializers serializers, GGoalOrderField object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GGoalOrderField deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GGoalOrderField.valueOf(serialized as String);
}

class _$GGoalStatusSerializer implements PrimitiveSerializer<GGoalStatus> {
  @override
  final Iterable<Type> types = const <Type>[GGoalStatus];
  @override
  final String wireName = 'GGoalStatus';

  @override
  Object serialize(Serializers serializers, GGoalStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GGoalStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GGoalStatus.valueOf(serialized as String);
}

class _$GOrderDirectionSerializer
    implements PrimitiveSerializer<GOrderDirection> {
  @override
  final Iterable<Type> types = const <Type>[GOrderDirection];
  @override
  final String wireName = 'GOrderDirection';

  @override
  Object serialize(Serializers serializers, GOrderDirection object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GOrderDirection deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GOrderDirection.valueOf(serialized as String);
}

class _$GTaskOrderFieldSerializer
    implements PrimitiveSerializer<GTaskOrderField> {
  @override
  final Iterable<Type> types = const <Type>[GTaskOrderField];
  @override
  final String wireName = 'GTaskOrderField';

  @override
  Object serialize(Serializers serializers, GTaskOrderField object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskOrderField deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskOrderField.valueOf(serialized as String);
}

class _$GTaskStatusSerializer implements PrimitiveSerializer<GTaskStatus> {
  @override
  final Iterable<Type> types = const <Type>[GTaskStatus];
  @override
  final String wireName = 'GTaskStatus';

  @override
  Object serialize(Serializers serializers, GTaskStatus object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskStatus deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskStatus.valueOf(serialized as String);
}

class _$GTaskTypeSerializer implements PrimitiveSerializer<GTaskType> {
  @override
  final Iterable<Type> types = const <Type>[GTaskType];
  @override
  final String wireName = 'GTaskType';

  @override
  Object serialize(Serializers serializers, GTaskType object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GTaskType deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GTaskType.valueOf(serialized as String);
}

class _$GUserOrderFieldSerializer
    implements PrimitiveSerializer<GUserOrderField> {
  @override
  final Iterable<Type> types = const <Type>[GUserOrderField];
  @override
  final String wireName = 'GUserOrderField';

  @override
  Object serialize(Serializers serializers, GUserOrderField object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GUserOrderField deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GUserOrderField.valueOf(serialized as String);
}

class _$GUserRoleSerializer implements PrimitiveSerializer<GUserRole> {
  @override
  final Iterable<Type> types = const <Type>[GUserRole];
  @override
  final String wireName = 'GUserRole';

  @override
  Object serialize(Serializers serializers, GUserRole object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GUserRole deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GUserRole.valueOf(serialized as String);
}

class _$GUserStudyTimeSerializer
    implements PrimitiveSerializer<GUserStudyTime> {
  @override
  final Iterable<Type> types = const <Type>[GUserStudyTime];
  @override
  final String wireName = 'GUserStudyTime';

  @override
  Object serialize(Serializers serializers, GUserStudyTime object,
          {FullType specifiedType = FullType.unspecified}) =>
      object.name;

  @override
  GUserStudyTime deserialize(Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      GUserStudyTime.valueOf(serialized as String);
}

class _$GCreateGoalInputSerializer
    implements StructuredSerializer<GCreateGoalInput> {
  @override
  final Iterable<Type> types = const [GCreateGoalInput, _$GCreateGoalInput];
  @override
  final String wireName = 'GCreateGoalInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateGoalInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.targetDate;
    if (value != null) {
      result
        ..add('targetDate')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    return result;
  }

  @override
  GCreateGoalInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GCreateGoalInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'targetDate':
          result.targetDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskInputSerializer
    implements StructuredSerializer<GCreateTaskInput> {
  @override
  final Iterable<Type> types = const [GCreateTaskInput, _$GCreateTaskInput];
  @override
  final String wireName = 'GCreateTaskInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateTaskInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'date',
      serializers.serialize(object.date, specifiedType: const FullType(GTime)),
    ];
    Object? value;
    value = object.shortDescription;
    if (value != null) {
      result
        ..add('shortDescription')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.type;
    if (value != null) {
      result
        ..add('type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskType)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.durationM;
    if (value != null) {
      result
        ..add('durationM')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.hasReminder;
    if (value != null) {
      result
        ..add('hasReminder')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.reminderTime;
    if (value != null) {
      result
        ..add('reminderTime')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.recurringDays;
    if (value != null) {
      result
        ..add('recurringDays')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.goalID;
    if (value != null) {
      result
        ..add('goalID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.tagNames;
    if (value != null) {
      result
        ..add('tagNames')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    return result;
  }

  @override
  GCreateTaskInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GCreateTaskInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'shortDescription':
          result.shortDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(GTaskType)) as GTaskType?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'date':
          result.date.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'durationM':
          result.durationM = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'hasReminder':
          result.hasReminder = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'reminderTime':
          result.reminderTime.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'recurringDays':
          result.recurringDays = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'goalID':
          result.goalID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'tagNames':
          result.tagNames.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGoalOrderSerializer implements StructuredSerializer<GGoalOrder> {
  @override
  final Iterable<Type> types = const [GGoalOrder, _$GGoalOrder];
  @override
  final String wireName = 'GGoalOrder';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGoalOrder object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'direction',
      serializers.serialize(object.direction,
          specifiedType: const FullType(GOrderDirection)),
      'field',
      serializers.serialize(object.field,
          specifiedType: const FullType(GGoalOrderField)),
    ];

    return result;
  }

  @override
  GGoalOrder deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGoalOrderBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'direction':
          result.direction = serializers.deserialize(value,
                  specifiedType: const FullType(GOrderDirection))!
              as GOrderDirection;
          break;
        case 'field':
          result.field = serializers.deserialize(value,
                  specifiedType: const FullType(GGoalOrderField))!
              as GGoalOrderField;
          break;
      }
    }

    return result.build();
  }
}

class _$GGoalWhereInputSerializer
    implements StructuredSerializer<GGoalWhereInput> {
  @override
  final Iterable<Type> types = const [GGoalWhereInput, _$GGoalWhereInput];
  @override
  final String wireName = 'GGoalWhereInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGoalWhereInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.not;
    if (value != null) {
      result
        ..add('not')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GGoalWhereInput)));
    }
    value = object.and;
    if (value != null) {
      result
        ..add('and')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalWhereInput)])));
    }
    value = object.or;
    if (value != null) {
      result
        ..add('or')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalWhereInput)])));
    }
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idNEQ;
    if (value != null) {
      result
        ..add('idNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idIn;
    if (value != null) {
      result
        ..add('idIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idNotIn;
    if (value != null) {
      result
        ..add('idNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idGT;
    if (value != null) {
      result
        ..add('idGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idGTE;
    if (value != null) {
      result
        ..add('idGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLT;
    if (value != null) {
      result
        ..add('idLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLTE;
    if (value != null) {
      result
        ..add('idLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('createdAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtNEQ;
    if (value != null) {
      result
        ..add('createdAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtIn;
    if (value != null) {
      result
        ..add('createdAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtNotIn;
    if (value != null) {
      result
        ..add('createdAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtGT;
    if (value != null) {
      result
        ..add('createdAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtGTE;
    if (value != null) {
      result
        ..add('createdAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLT;
    if (value != null) {
      result
        ..add('createdAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLTE;
    if (value != null) {
      result
        ..add('createdAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updatedAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtNEQ;
    if (value != null) {
      result
        ..add('updatedAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtIn;
    if (value != null) {
      result
        ..add('updatedAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtNotIn;
    if (value != null) {
      result
        ..add('updatedAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtGT;
    if (value != null) {
      result
        ..add('updatedAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtGTE;
    if (value != null) {
      result
        ..add('updatedAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLT;
    if (value != null) {
      result
        ..add('updatedAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLTE;
    if (value != null) {
      result
        ..add('updatedAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleNEQ;
    if (value != null) {
      result
        ..add('titleNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleIn;
    if (value != null) {
      result
        ..add('titleIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.titleNotIn;
    if (value != null) {
      result
        ..add('titleNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.titleGT;
    if (value != null) {
      result
        ..add('titleGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleGTE;
    if (value != null) {
      result
        ..add('titleGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleLT;
    if (value != null) {
      result
        ..add('titleLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleLTE;
    if (value != null) {
      result
        ..add('titleLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleContains;
    if (value != null) {
      result
        ..add('titleContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleHasPrefix;
    if (value != null) {
      result
        ..add('titleHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleHasSuffix;
    if (value != null) {
      result
        ..add('titleHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleEqualFold;
    if (value != null) {
      result
        ..add('titleEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleContainsFold;
    if (value != null) {
      result
        ..add('titleContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteNEQ;
    if (value != null) {
      result
        ..add('noteNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteIn;
    if (value != null) {
      result
        ..add('noteIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.noteNotIn;
    if (value != null) {
      result
        ..add('noteNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.noteGT;
    if (value != null) {
      result
        ..add('noteGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteGTE;
    if (value != null) {
      result
        ..add('noteGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteLT;
    if (value != null) {
      result
        ..add('noteLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteLTE;
    if (value != null) {
      result
        ..add('noteLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteContains;
    if (value != null) {
      result
        ..add('noteContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteHasPrefix;
    if (value != null) {
      result
        ..add('noteHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteHasSuffix;
    if (value != null) {
      result
        ..add('noteHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteIsNil;
    if (value != null) {
      result
        ..add('noteIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.noteNotNil;
    if (value != null) {
      result
        ..add('noteNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.noteEqualFold;
    if (value != null) {
      result
        ..add('noteEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteContainsFold;
    if (value != null) {
      result
        ..add('noteContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.targetDate;
    if (value != null) {
      result
        ..add('targetDate')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateNEQ;
    if (value != null) {
      result
        ..add('targetDateNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateIn;
    if (value != null) {
      result
        ..add('targetDateIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.targetDateNotIn;
    if (value != null) {
      result
        ..add('targetDateNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.targetDateGT;
    if (value != null) {
      result
        ..add('targetDateGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateGTE;
    if (value != null) {
      result
        ..add('targetDateGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateLT;
    if (value != null) {
      result
        ..add('targetDateLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateLTE;
    if (value != null) {
      result
        ..add('targetDateLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.targetDateIsNil;
    if (value != null) {
      result
        ..add('targetDateIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.targetDateNotNil;
    if (value != null) {
      result
        ..add('targetDateNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GGoalStatus)));
    }
    value = object.statusNEQ;
    if (value != null) {
      result
        ..add('statusNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GGoalStatus)));
    }
    value = object.statusIn;
    if (value != null) {
      result
        ..add('statusIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalStatus)])));
    }
    value = object.statusNotIn;
    if (value != null) {
      result
        ..add('statusNotIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalStatus)])));
    }
    value = object.hasUser;
    if (value != null) {
      result
        ..add('hasUser')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasUserWith;
    if (value != null) {
      result
        ..add('hasUserWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserWhereInput)])));
    }
    value = object.hasTasks;
    if (value != null) {
      result
        ..add('hasTasks')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasTasksWith;
    if (value != null) {
      result
        ..add('hasTasksWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskWhereInput)])));
    }
    return result;
  }

  @override
  GGoalWhereInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGoalWhereInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'not':
          result.not.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GGoalWhereInput))!
              as GGoalWhereInput);
          break;
        case 'and':
          result.and.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'or':
          result.or.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idNEQ':
          result.idNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idIn':
          result.idIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idNotIn':
          result.idNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idGT':
          result.idGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idGTE':
          result.idGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLT':
          result.idLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLTE':
          result.idLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtNEQ':
          result.createdAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtIn':
          result.createdAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtNotIn':
          result.createdAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtGT':
          result.createdAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtGTE':
          result.createdAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLT':
          result.createdAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLTE':
          result.createdAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAt':
          result.updatedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtNEQ':
          result.updatedAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtIn':
          result.updatedAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtNotIn':
          result.updatedAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtGT':
          result.updatedAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtGTE':
          result.updatedAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLT':
          result.updatedAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLTE':
          result.updatedAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleNEQ':
          result.titleNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleIn':
          result.titleIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'titleNotIn':
          result.titleNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'titleGT':
          result.titleGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleGTE':
          result.titleGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleLT':
          result.titleLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleLTE':
          result.titleLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleContains':
          result.titleContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleHasPrefix':
          result.titleHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleHasSuffix':
          result.titleHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleEqualFold':
          result.titleEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleContainsFold':
          result.titleContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteNEQ':
          result.noteNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteIn':
          result.noteIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'noteNotIn':
          result.noteNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'noteGT':
          result.noteGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteGTE':
          result.noteGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteLT':
          result.noteLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteLTE':
          result.noteLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteContains':
          result.noteContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteHasPrefix':
          result.noteHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteHasSuffix':
          result.noteHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteIsNil':
          result.noteIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'noteNotNil':
          result.noteNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'noteEqualFold':
          result.noteEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteContainsFold':
          result.noteContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'targetDate':
          result.targetDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateNEQ':
          result.targetDateNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateIn':
          result.targetDateIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'targetDateNotIn':
          result.targetDateNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'targetDateGT':
          result.targetDateGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateGTE':
          result.targetDateGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateLT':
          result.targetDateLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateLTE':
          result.targetDateLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'targetDateIsNil':
          result.targetDateIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'targetDateNotNil':
          result.targetDateNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(GGoalStatus)) as GGoalStatus?;
          break;
        case 'statusNEQ':
          result.statusNEQ = serializers.deserialize(value,
              specifiedType: const FullType(GGoalStatus)) as GGoalStatus?;
          break;
        case 'statusIn':
          result.statusIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalStatus)]))!
              as BuiltList<Object?>);
          break;
        case 'statusNotIn':
          result.statusNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalStatus)]))!
              as BuiltList<Object?>);
          break;
        case 'hasUser':
          result.hasUser = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasUserWith':
          result.hasUserWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'hasTasks':
          result.hasTasks = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasTasksWith':
          result.hasTasksWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskWhereInput)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GInterestWhereInputSerializer
    implements StructuredSerializer<GInterestWhereInput> {
  @override
  final Iterable<Type> types = const [
    GInterestWhereInput,
    _$GInterestWhereInput
  ];
  @override
  final String wireName = 'GInterestWhereInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GInterestWhereInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.not;
    if (value != null) {
      result
        ..add('not')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GInterestWhereInput)));
    }
    value = object.and;
    if (value != null) {
      result
        ..add('and')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GInterestWhereInput)])));
    }
    value = object.or;
    if (value != null) {
      result
        ..add('or')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GInterestWhereInput)])));
    }
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idNEQ;
    if (value != null) {
      result
        ..add('idNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idIn;
    if (value != null) {
      result
        ..add('idIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idNotIn;
    if (value != null) {
      result
        ..add('idNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idGT;
    if (value != null) {
      result
        ..add('idGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idGTE;
    if (value != null) {
      result
        ..add('idGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLT;
    if (value != null) {
      result
        ..add('idLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLTE;
    if (value != null) {
      result
        ..add('idLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.name;
    if (value != null) {
      result
        ..add('name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameNEQ;
    if (value != null) {
      result
        ..add('nameNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameIn;
    if (value != null) {
      result
        ..add('nameIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.nameNotIn;
    if (value != null) {
      result
        ..add('nameNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.nameGT;
    if (value != null) {
      result
        ..add('nameGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameGTE;
    if (value != null) {
      result
        ..add('nameGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameLT;
    if (value != null) {
      result
        ..add('nameLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameLTE;
    if (value != null) {
      result
        ..add('nameLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameContains;
    if (value != null) {
      result
        ..add('nameContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameHasPrefix;
    if (value != null) {
      result
        ..add('nameHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameHasSuffix;
    if (value != null) {
      result
        ..add('nameHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameEqualFold;
    if (value != null) {
      result
        ..add('nameEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameContainsFold;
    if (value != null) {
      result
        ..add('nameContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.hasUsers;
    if (value != null) {
      result
        ..add('hasUsers')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasUsersWith;
    if (value != null) {
      result
        ..add('hasUsersWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserWhereInput)])));
    }
    return result;
  }

  @override
  GInterestWhereInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GInterestWhereInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'not':
          result.not.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GInterestWhereInput))!
              as GInterestWhereInput);
          break;
        case 'and':
          result.and.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GInterestWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'or':
          result.or.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GInterestWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idNEQ':
          result.idNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idIn':
          result.idIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idNotIn':
          result.idNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idGT':
          result.idGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idGTE':
          result.idGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLT':
          result.idLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLTE':
          result.idLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameNEQ':
          result.nameNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameIn':
          result.nameIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nameNotIn':
          result.nameNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nameGT':
          result.nameGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameGTE':
          result.nameGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameLT':
          result.nameLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameLTE':
          result.nameLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameContains':
          result.nameContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameHasPrefix':
          result.nameHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameHasSuffix':
          result.nameHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameEqualFold':
          result.nameEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameContainsFold':
          result.nameContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'hasUsers':
          result.hasUsers = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasUsersWith':
          result.hasUsersWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserWhereInput)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendOTPInputSerializer implements StructuredSerializer<GSendOTPInput> {
  @override
  final Iterable<Type> types = const [GSendOTPInput, _$GSendOTPInput];
  @override
  final String wireName = 'GSendOTPInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendOTPInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'phoneNumber',
      serializers.serialize(object.phoneNumber,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GSendOTPInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendOTPInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'phoneNumber':
          result.phoneNumber = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GRefreshTokenInputSerializer
    implements StructuredSerializer<GRefreshTokenInput> {
  @override
  final Iterable<Type> types = const [GRefreshTokenInput, _$GRefreshTokenInput];
  @override
  final String wireName = 'GRefreshTokenInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRefreshTokenInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'refreshToken',
      serializers.serialize(object.refreshToken,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GRefreshTokenInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GRefreshTokenInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'refreshToken':
          result.refreshToken = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GTagWhereInputSerializer
    implements StructuredSerializer<GTagWhereInput> {
  @override
  final Iterable<Type> types = const [GTagWhereInput, _$GTagWhereInput];
  @override
  final String wireName = 'GTagWhereInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTagWhereInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.not;
    if (value != null) {
      result
        ..add('not')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTagWhereInput)));
    }
    value = object.and;
    if (value != null) {
      result
        ..add('and')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTagWhereInput)])));
    }
    value = object.or;
    if (value != null) {
      result
        ..add('or')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTagWhereInput)])));
    }
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idNEQ;
    if (value != null) {
      result
        ..add('idNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idIn;
    if (value != null) {
      result
        ..add('idIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idNotIn;
    if (value != null) {
      result
        ..add('idNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idGT;
    if (value != null) {
      result
        ..add('idGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idGTE;
    if (value != null) {
      result
        ..add('idGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLT;
    if (value != null) {
      result
        ..add('idLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLTE;
    if (value != null) {
      result
        ..add('idLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.name;
    if (value != null) {
      result
        ..add('name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameNEQ;
    if (value != null) {
      result
        ..add('nameNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameIn;
    if (value != null) {
      result
        ..add('nameIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.nameNotIn;
    if (value != null) {
      result
        ..add('nameNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.nameGT;
    if (value != null) {
      result
        ..add('nameGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameGTE;
    if (value != null) {
      result
        ..add('nameGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameLT;
    if (value != null) {
      result
        ..add('nameLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameLTE;
    if (value != null) {
      result
        ..add('nameLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameContains;
    if (value != null) {
      result
        ..add('nameContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameHasPrefix;
    if (value != null) {
      result
        ..add('nameHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameHasSuffix;
    if (value != null) {
      result
        ..add('nameHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameEqualFold;
    if (value != null) {
      result
        ..add('nameEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.nameContainsFold;
    if (value != null) {
      result
        ..add('nameContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.hasTasks;
    if (value != null) {
      result
        ..add('hasTasks')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasTasksWith;
    if (value != null) {
      result
        ..add('hasTasksWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskWhereInput)])));
    }
    return result;
  }

  @override
  GTagWhereInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GTagWhereInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'not':
          result.not.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTagWhereInput))!
              as GTagWhereInput);
          break;
        case 'and':
          result.and.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTagWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'or':
          result.or.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTagWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idNEQ':
          result.idNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idIn':
          result.idIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idNotIn':
          result.idNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idGT':
          result.idGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idGTE':
          result.idGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLT':
          result.idLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLTE':
          result.idLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameNEQ':
          result.nameNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameIn':
          result.nameIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nameNotIn':
          result.nameNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'nameGT':
          result.nameGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameGTE':
          result.nameGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameLT':
          result.nameLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameLTE':
          result.nameLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameContains':
          result.nameContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameHasPrefix':
          result.nameHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameHasSuffix':
          result.nameHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameEqualFold':
          result.nameEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'nameContainsFold':
          result.nameContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'hasTasks':
          result.hasTasks = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasTasksWith':
          result.hasTasksWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskWhereInput)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskOrderSerializer implements StructuredSerializer<GTaskOrder> {
  @override
  final Iterable<Type> types = const [GTaskOrder, _$GTaskOrder];
  @override
  final String wireName = 'GTaskOrder';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskOrder object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'direction',
      serializers.serialize(object.direction,
          specifiedType: const FullType(GOrderDirection)),
      'field',
      serializers.serialize(object.field,
          specifiedType: const FullType(GTaskOrderField)),
    ];

    return result;
  }

  @override
  GTaskOrder deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GTaskOrderBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'direction':
          result.direction = serializers.deserialize(value,
                  specifiedType: const FullType(GOrderDirection))!
              as GOrderDirection;
          break;
        case 'field':
          result.field = serializers.deserialize(value,
                  specifiedType: const FullType(GTaskOrderField))!
              as GTaskOrderField;
          break;
      }
    }

    return result.build();
  }
}

class _$GTaskWhereInputSerializer
    implements StructuredSerializer<GTaskWhereInput> {
  @override
  final Iterable<Type> types = const [GTaskWhereInput, _$GTaskWhereInput];
  @override
  final String wireName = 'GTaskWhereInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GTaskWhereInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.not;
    if (value != null) {
      result
        ..add('not')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskWhereInput)));
    }
    value = object.and;
    if (value != null) {
      result
        ..add('and')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskWhereInput)])));
    }
    value = object.or;
    if (value != null) {
      result
        ..add('or')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskWhereInput)])));
    }
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idNEQ;
    if (value != null) {
      result
        ..add('idNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idIn;
    if (value != null) {
      result
        ..add('idIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idNotIn;
    if (value != null) {
      result
        ..add('idNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idGT;
    if (value != null) {
      result
        ..add('idGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idGTE;
    if (value != null) {
      result
        ..add('idGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLT;
    if (value != null) {
      result
        ..add('idLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLTE;
    if (value != null) {
      result
        ..add('idLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('createdAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtNEQ;
    if (value != null) {
      result
        ..add('createdAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtIn;
    if (value != null) {
      result
        ..add('createdAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtNotIn;
    if (value != null) {
      result
        ..add('createdAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtGT;
    if (value != null) {
      result
        ..add('createdAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtGTE;
    if (value != null) {
      result
        ..add('createdAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLT;
    if (value != null) {
      result
        ..add('createdAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLTE;
    if (value != null) {
      result
        ..add('createdAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updatedAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtNEQ;
    if (value != null) {
      result
        ..add('updatedAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtIn;
    if (value != null) {
      result
        ..add('updatedAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtNotIn;
    if (value != null) {
      result
        ..add('updatedAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtGT;
    if (value != null) {
      result
        ..add('updatedAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtGTE;
    if (value != null) {
      result
        ..add('updatedAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLT;
    if (value != null) {
      result
        ..add('updatedAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLTE;
    if (value != null) {
      result
        ..add('updatedAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleNEQ;
    if (value != null) {
      result
        ..add('titleNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleIn;
    if (value != null) {
      result
        ..add('titleIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.titleNotIn;
    if (value != null) {
      result
        ..add('titleNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.titleGT;
    if (value != null) {
      result
        ..add('titleGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleGTE;
    if (value != null) {
      result
        ..add('titleGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleLT;
    if (value != null) {
      result
        ..add('titleLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleLTE;
    if (value != null) {
      result
        ..add('titleLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleContains;
    if (value != null) {
      result
        ..add('titleContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleHasPrefix;
    if (value != null) {
      result
        ..add('titleHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleHasSuffix;
    if (value != null) {
      result
        ..add('titleHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleEqualFold;
    if (value != null) {
      result
        ..add('titleEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.titleContainsFold;
    if (value != null) {
      result
        ..add('titleContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescription;
    if (value != null) {
      result
        ..add('shortDescription')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionNEQ;
    if (value != null) {
      result
        ..add('shortDescriptionNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionIn;
    if (value != null) {
      result
        ..add('shortDescriptionIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.shortDescriptionNotIn;
    if (value != null) {
      result
        ..add('shortDescriptionNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.shortDescriptionGT;
    if (value != null) {
      result
        ..add('shortDescriptionGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionGTE;
    if (value != null) {
      result
        ..add('shortDescriptionGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionLT;
    if (value != null) {
      result
        ..add('shortDescriptionLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionLTE;
    if (value != null) {
      result
        ..add('shortDescriptionLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionContains;
    if (value != null) {
      result
        ..add('shortDescriptionContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionHasPrefix;
    if (value != null) {
      result
        ..add('shortDescriptionHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionHasSuffix;
    if (value != null) {
      result
        ..add('shortDescriptionHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionIsNil;
    if (value != null) {
      result
        ..add('shortDescriptionIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.shortDescriptionNotNil;
    if (value != null) {
      result
        ..add('shortDescriptionNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.shortDescriptionEqualFold;
    if (value != null) {
      result
        ..add('shortDescriptionEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescriptionContainsFold;
    if (value != null) {
      result
        ..add('shortDescriptionContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteNEQ;
    if (value != null) {
      result
        ..add('noteNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteIn;
    if (value != null) {
      result
        ..add('noteIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.noteNotIn;
    if (value != null) {
      result
        ..add('noteNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.noteGT;
    if (value != null) {
      result
        ..add('noteGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteGTE;
    if (value != null) {
      result
        ..add('noteGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteLT;
    if (value != null) {
      result
        ..add('noteLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteLTE;
    if (value != null) {
      result
        ..add('noteLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteContains;
    if (value != null) {
      result
        ..add('noteContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteHasPrefix;
    if (value != null) {
      result
        ..add('noteHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteHasSuffix;
    if (value != null) {
      result
        ..add('noteHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteIsNil;
    if (value != null) {
      result
        ..add('noteIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.noteNotNil;
    if (value != null) {
      result
        ..add('noteNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.noteEqualFold;
    if (value != null) {
      result
        ..add('noteEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.noteContainsFold;
    if (value != null) {
      result
        ..add('noteContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.type;
    if (value != null) {
      result
        ..add('type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskType)));
    }
    value = object.typeNEQ;
    if (value != null) {
      result
        ..add('typeNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskType)));
    }
    value = object.typeIn;
    if (value != null) {
      result
        ..add('typeIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTaskType)])));
    }
    value = object.typeNotIn;
    if (value != null) {
      result
        ..add('typeNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTaskType)])));
    }
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.dateNEQ;
    if (value != null) {
      result
        ..add('dateNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.dateIn;
    if (value != null) {
      result
        ..add('dateIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.dateNotIn;
    if (value != null) {
      result
        ..add('dateNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.dateGT;
    if (value != null) {
      result
        ..add('dateGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.dateGTE;
    if (value != null) {
      result
        ..add('dateGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.dateLT;
    if (value != null) {
      result
        ..add('dateLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.dateLTE;
    if (value != null) {
      result
        ..add('dateLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.durationM;
    if (value != null) {
      result
        ..add('durationM')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMNEQ;
    if (value != null) {
      result
        ..add('durationMNEQ')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMIn;
    if (value != null) {
      result
        ..add('durationMIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.durationMNotIn;
    if (value != null) {
      result
        ..add('durationMNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.durationMGT;
    if (value != null) {
      result
        ..add('durationMGT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMGTE;
    if (value != null) {
      result
        ..add('durationMGTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMLT;
    if (value != null) {
      result
        ..add('durationMLT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMLTE;
    if (value != null) {
      result
        ..add('durationMLTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.durationMIsNil;
    if (value != null) {
      result
        ..add('durationMIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.durationMNotNil;
    if (value != null) {
      result
        ..add('durationMNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasReminder;
    if (value != null) {
      result
        ..add('hasReminder')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasReminderNEQ;
    if (value != null) {
      result
        ..add('hasReminderNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.reminderTime;
    if (value != null) {
      result
        ..add('reminderTime')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeNEQ;
    if (value != null) {
      result
        ..add('reminderTimeNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeIn;
    if (value != null) {
      result
        ..add('reminderTimeIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.reminderTimeNotIn;
    if (value != null) {
      result
        ..add('reminderTimeNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.reminderTimeGT;
    if (value != null) {
      result
        ..add('reminderTimeGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeGTE;
    if (value != null) {
      result
        ..add('reminderTimeGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeLT;
    if (value != null) {
      result
        ..add('reminderTimeLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeLTE;
    if (value != null) {
      result
        ..add('reminderTimeLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.reminderTimeIsNil;
    if (value != null) {
      result
        ..add('reminderTimeIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.reminderTimeNotNil;
    if (value != null) {
      result
        ..add('reminderTimeNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.recurringDays;
    if (value != null) {
      result
        ..add('recurringDays')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysNEQ;
    if (value != null) {
      result
        ..add('recurringDaysNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysIn;
    if (value != null) {
      result
        ..add('recurringDaysIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.recurringDaysNotIn;
    if (value != null) {
      result
        ..add('recurringDaysNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.recurringDaysGT;
    if (value != null) {
      result
        ..add('recurringDaysGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysGTE;
    if (value != null) {
      result
        ..add('recurringDaysGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysLT;
    if (value != null) {
      result
        ..add('recurringDaysLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysLTE;
    if (value != null) {
      result
        ..add('recurringDaysLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysContains;
    if (value != null) {
      result
        ..add('recurringDaysContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysHasPrefix;
    if (value != null) {
      result
        ..add('recurringDaysHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysHasSuffix;
    if (value != null) {
      result
        ..add('recurringDaysHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysIsNil;
    if (value != null) {
      result
        ..add('recurringDaysIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.recurringDaysNotNil;
    if (value != null) {
      result
        ..add('recurringDaysNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.recurringDaysEqualFold;
    if (value != null) {
      result
        ..add('recurringDaysEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.recurringDaysContainsFold;
    if (value != null) {
      result
        ..add('recurringDaysContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskStatus)));
    }
    value = object.statusNEQ;
    if (value != null) {
      result
        ..add('statusNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskStatus)));
    }
    value = object.statusIn;
    if (value != null) {
      result
        ..add('statusIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskStatus)])));
    }
    value = object.statusNotIn;
    if (value != null) {
      result
        ..add('statusNotIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskStatus)])));
    }
    value = object.hasUser;
    if (value != null) {
      result
        ..add('hasUser')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasUserWith;
    if (value != null) {
      result
        ..add('hasUserWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserWhereInput)])));
    }
    value = object.hasGoal;
    if (value != null) {
      result
        ..add('hasGoal')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasGoalWith;
    if (value != null) {
      result
        ..add('hasGoalWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalWhereInput)])));
    }
    value = object.hasTags;
    if (value != null) {
      result
        ..add('hasTags')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasTagsWith;
    if (value != null) {
      result
        ..add('hasTagsWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTagWhereInput)])));
    }
    return result;
  }

  @override
  GTaskWhereInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GTaskWhereInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'not':
          result.not.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GTaskWhereInput))!
              as GTaskWhereInput);
          break;
        case 'and':
          result.and.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'or':
          result.or.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idNEQ':
          result.idNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idIn':
          result.idIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idNotIn':
          result.idNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idGT':
          result.idGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idGTE':
          result.idGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLT':
          result.idLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLTE':
          result.idLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtNEQ':
          result.createdAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtIn':
          result.createdAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtNotIn':
          result.createdAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtGT':
          result.createdAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtGTE':
          result.createdAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLT':
          result.createdAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLTE':
          result.createdAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAt':
          result.updatedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtNEQ':
          result.updatedAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtIn':
          result.updatedAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtNotIn':
          result.updatedAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtGT':
          result.updatedAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtGTE':
          result.updatedAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLT':
          result.updatedAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLTE':
          result.updatedAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleNEQ':
          result.titleNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleIn':
          result.titleIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'titleNotIn':
          result.titleNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'titleGT':
          result.titleGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleGTE':
          result.titleGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleLT':
          result.titleLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleLTE':
          result.titleLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleContains':
          result.titleContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleHasPrefix':
          result.titleHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleHasSuffix':
          result.titleHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleEqualFold':
          result.titleEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'titleContainsFold':
          result.titleContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescription':
          result.shortDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionNEQ':
          result.shortDescriptionNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionIn':
          result.shortDescriptionIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'shortDescriptionNotIn':
          result.shortDescriptionNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'shortDescriptionGT':
          result.shortDescriptionGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionGTE':
          result.shortDescriptionGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionLT':
          result.shortDescriptionLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionLTE':
          result.shortDescriptionLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionContains':
          result.shortDescriptionContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionHasPrefix':
          result.shortDescriptionHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionHasSuffix':
          result.shortDescriptionHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionIsNil':
          result.shortDescriptionIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'shortDescriptionNotNil':
          result.shortDescriptionNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'shortDescriptionEqualFold':
          result.shortDescriptionEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescriptionContainsFold':
          result.shortDescriptionContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteNEQ':
          result.noteNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteIn':
          result.noteIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'noteNotIn':
          result.noteNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'noteGT':
          result.noteGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteGTE':
          result.noteGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteLT':
          result.noteLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteLTE':
          result.noteLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteContains':
          result.noteContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteHasPrefix':
          result.noteHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteHasSuffix':
          result.noteHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteIsNil':
          result.noteIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'noteNotNil':
          result.noteNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'noteEqualFold':
          result.noteEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'noteContainsFold':
          result.noteContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(GTaskType)) as GTaskType?;
          break;
        case 'typeNEQ':
          result.typeNEQ = serializers.deserialize(value,
              specifiedType: const FullType(GTaskType)) as GTaskType?;
          break;
        case 'typeIn':
          result.typeIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskType)]))!
              as BuiltList<Object?>);
          break;
        case 'typeNotIn':
          result.typeNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskType)]))!
              as BuiltList<Object?>);
          break;
        case 'date':
          result.date.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'dateNEQ':
          result.dateNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'dateIn':
          result.dateIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'dateNotIn':
          result.dateNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'dateGT':
          result.dateGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'dateGTE':
          result.dateGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'dateLT':
          result.dateLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'dateLTE':
          result.dateLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'durationM':
          result.durationM = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMNEQ':
          result.durationMNEQ = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMIn':
          result.durationMIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'durationMNotIn':
          result.durationMNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'durationMGT':
          result.durationMGT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMGTE':
          result.durationMGTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMLT':
          result.durationMLT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMLTE':
          result.durationMLTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'durationMIsNil':
          result.durationMIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'durationMNotNil':
          result.durationMNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasReminder':
          result.hasReminder = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasReminderNEQ':
          result.hasReminderNEQ = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'reminderTime':
          result.reminderTime.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeNEQ':
          result.reminderTimeNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeIn':
          result.reminderTimeIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'reminderTimeNotIn':
          result.reminderTimeNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'reminderTimeGT':
          result.reminderTimeGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeGTE':
          result.reminderTimeGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeLT':
          result.reminderTimeLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeLTE':
          result.reminderTimeLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'reminderTimeIsNil':
          result.reminderTimeIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'reminderTimeNotNil':
          result.reminderTimeNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'recurringDays':
          result.recurringDays = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysNEQ':
          result.recurringDaysNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysIn':
          result.recurringDaysIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'recurringDaysNotIn':
          result.recurringDaysNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'recurringDaysGT':
          result.recurringDaysGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysGTE':
          result.recurringDaysGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysLT':
          result.recurringDaysLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysLTE':
          result.recurringDaysLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysContains':
          result.recurringDaysContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysHasPrefix':
          result.recurringDaysHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysHasSuffix':
          result.recurringDaysHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysIsNil':
          result.recurringDaysIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'recurringDaysNotNil':
          result.recurringDaysNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'recurringDaysEqualFold':
          result.recurringDaysEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'recurringDaysContainsFold':
          result.recurringDaysContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(GTaskStatus)) as GTaskStatus?;
          break;
        case 'statusNEQ':
          result.statusNEQ = serializers.deserialize(value,
              specifiedType: const FullType(GTaskStatus)) as GTaskStatus?;
          break;
        case 'statusIn':
          result.statusIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskStatus)]))!
              as BuiltList<Object?>);
          break;
        case 'statusNotIn':
          result.statusNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskStatus)]))!
              as BuiltList<Object?>);
          break;
        case 'hasUser':
          result.hasUser = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasUserWith':
          result.hasUserWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'hasGoal':
          result.hasGoal = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasGoalWith':
          result.hasGoalWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'hasTags':
          result.hasTags = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasTagsWith':
          result.hasTagsWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTagWhereInput)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateGoalInputSerializer
    implements StructuredSerializer<GUpdateGoalInput> {
  @override
  final Iterable<Type> types = const [GUpdateGoalInput, _$GUpdateGoalInput];
  @override
  final String wireName = 'GUpdateGoalInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUpdateGoalInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.targetDate;
    if (value != null) {
      result
        ..add('targetDate')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GGoalStatus)));
    }
    return result;
  }

  @override
  GUpdateGoalInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GUpdateGoalInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'targetDate':
          result.targetDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(GGoalStatus)) as GGoalStatus?;
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateProfileInputSerializer
    implements StructuredSerializer<GUpdateProfileInput> {
  @override
  final Iterable<Type> types = const [
    GUpdateProfileInput,
    _$GUpdateProfileInput
  ];
  @override
  final String wireName = 'GUpdateProfileInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUpdateProfileInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.fullName;
    if (value != null) {
      result
        ..add('fullName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.birthDate;
    if (value != null) {
      result
        ..add('birthDate')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.studyTime;
    if (value != null) {
      result
        ..add('studyTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserStudyTime)));
    }
    value = object.major;
    if (value != null) {
      result
        ..add('major')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bio;
    if (value != null) {
      result
        ..add('bio')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GUpdateProfileInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GUpdateProfileInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'fullName':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'birthDate':
          result.birthDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'studyTime':
          result.studyTime = serializers.deserialize(value,
              specifiedType: const FullType(GUserStudyTime)) as GUserStudyTime?;
          break;
        case 'major':
          result.major = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bio':
          result.bio = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateTaskInputSerializer
    implements StructuredSerializer<GUpdateTaskInput> {
  @override
  final Iterable<Type> types = const [GUpdateTaskInput, _$GUpdateTaskInput];
  @override
  final String wireName = 'GUpdateTaskInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUpdateTaskInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shortDescription;
    if (value != null) {
      result
        ..add('shortDescription')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.type;
    if (value != null) {
      result
        ..add('type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskType)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.durationM;
    if (value != null) {
      result
        ..add('durationM')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.hasReminder;
    if (value != null) {
      result
        ..add('hasReminder')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.reminderTime;
    if (value != null) {
      result
        ..add('reminderTime')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.recurringDays;
    if (value != null) {
      result
        ..add('recurringDays')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GTaskStatus)));
    }
    value = object.goalID;
    if (value != null) {
      result
        ..add('goalID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.tagNames;
    if (value != null) {
      result
        ..add('tagNames')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    return result;
  }

  @override
  GUpdateTaskInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GUpdateTaskInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shortDescription':
          result.shortDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(GTaskType)) as GTaskType?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'date':
          result.date.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'durationM':
          result.durationM = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'hasReminder':
          result.hasReminder = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'reminderTime':
          result.reminderTime.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'recurringDays':
          result.recurringDays = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(GTaskStatus)) as GTaskStatus?;
          break;
        case 'goalID':
          result.goalID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'tagNames':
          result.tagNames.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GUserOrderSerializer implements StructuredSerializer<GUserOrder> {
  @override
  final Iterable<Type> types = const [GUserOrder, _$GUserOrder];
  @override
  final String wireName = 'GUserOrder';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUserOrder object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'direction',
      serializers.serialize(object.direction,
          specifiedType: const FullType(GOrderDirection)),
      'field',
      serializers.serialize(object.field,
          specifiedType: const FullType(GUserOrderField)),
    ];

    return result;
  }

  @override
  GUserOrder deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GUserOrderBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'direction':
          result.direction = serializers.deserialize(value,
                  specifiedType: const FullType(GOrderDirection))!
              as GOrderDirection;
          break;
        case 'field':
          result.field = serializers.deserialize(value,
                  specifiedType: const FullType(GUserOrderField))!
              as GUserOrderField;
          break;
      }
    }

    return result.build();
  }
}

class _$GUserWhereInputSerializer
    implements StructuredSerializer<GUserWhereInput> {
  @override
  final Iterable<Type> types = const [GUserWhereInput, _$GUserWhereInput];
  @override
  final String wireName = 'GUserWhereInput';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUserWhereInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.not;
    if (value != null) {
      result
        ..add('not')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserWhereInput)));
    }
    value = object.and;
    if (value != null) {
      result
        ..add('and')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserWhereInput)])));
    }
    value = object.or;
    if (value != null) {
      result
        ..add('or')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserWhereInput)])));
    }
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idNEQ;
    if (value != null) {
      result
        ..add('idNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idIn;
    if (value != null) {
      result
        ..add('idIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idNotIn;
    if (value != null) {
      result
        ..add('idNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.idGT;
    if (value != null) {
      result
        ..add('idGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idGTE;
    if (value != null) {
      result
        ..add('idGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLT;
    if (value != null) {
      result
        ..add('idLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.idLTE;
    if (value != null) {
      result
        ..add('idLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('createdAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtNEQ;
    if (value != null) {
      result
        ..add('createdAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtIn;
    if (value != null) {
      result
        ..add('createdAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtNotIn;
    if (value != null) {
      result
        ..add('createdAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.createdAtGT;
    if (value != null) {
      result
        ..add('createdAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtGTE;
    if (value != null) {
      result
        ..add('createdAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLT;
    if (value != null) {
      result
        ..add('createdAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.createdAtLTE;
    if (value != null) {
      result
        ..add('createdAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updatedAt')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtNEQ;
    if (value != null) {
      result
        ..add('updatedAtNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtIn;
    if (value != null) {
      result
        ..add('updatedAtIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtNotIn;
    if (value != null) {
      result
        ..add('updatedAtNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.updatedAtGT;
    if (value != null) {
      result
        ..add('updatedAtGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtGTE;
    if (value != null) {
      result
        ..add('updatedAtGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLT;
    if (value != null) {
      result
        ..add('updatedAtLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.updatedAtLTE;
    if (value != null) {
      result
        ..add('updatedAtLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.phoneNumber;
    if (value != null) {
      result
        ..add('phoneNumber')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberNEQ;
    if (value != null) {
      result
        ..add('phoneNumberNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberIn;
    if (value != null) {
      result
        ..add('phoneNumberIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.phoneNumberNotIn;
    if (value != null) {
      result
        ..add('phoneNumberNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.phoneNumberGT;
    if (value != null) {
      result
        ..add('phoneNumberGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberGTE;
    if (value != null) {
      result
        ..add('phoneNumberGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberLT;
    if (value != null) {
      result
        ..add('phoneNumberLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberLTE;
    if (value != null) {
      result
        ..add('phoneNumberLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberContains;
    if (value != null) {
      result
        ..add('phoneNumberContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberHasPrefix;
    if (value != null) {
      result
        ..add('phoneNumberHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberHasSuffix;
    if (value != null) {
      result
        ..add('phoneNumberHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberEqualFold;
    if (value != null) {
      result
        ..add('phoneNumberEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.phoneNumberContainsFold;
    if (value != null) {
      result
        ..add('phoneNumberContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullName;
    if (value != null) {
      result
        ..add('fullName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameNEQ;
    if (value != null) {
      result
        ..add('fullNameNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameIn;
    if (value != null) {
      result
        ..add('fullNameIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.fullNameNotIn;
    if (value != null) {
      result
        ..add('fullNameNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.fullNameGT;
    if (value != null) {
      result
        ..add('fullNameGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameGTE;
    if (value != null) {
      result
        ..add('fullNameGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameLT;
    if (value != null) {
      result
        ..add('fullNameLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameLTE;
    if (value != null) {
      result
        ..add('fullNameLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameContains;
    if (value != null) {
      result
        ..add('fullNameContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameHasPrefix;
    if (value != null) {
      result
        ..add('fullNameHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameHasSuffix;
    if (value != null) {
      result
        ..add('fullNameHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameIsNil;
    if (value != null) {
      result
        ..add('fullNameIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.fullNameNotNil;
    if (value != null) {
      result
        ..add('fullNameNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.fullNameEqualFold;
    if (value != null) {
      result
        ..add('fullNameEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.fullNameContainsFold;
    if (value != null) {
      result
        ..add('fullNameContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.birthDate;
    if (value != null) {
      result
        ..add('birthDate')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateNEQ;
    if (value != null) {
      result
        ..add('birthDateNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateIn;
    if (value != null) {
      result
        ..add('birthDateIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.birthDateNotIn;
    if (value != null) {
      result
        ..add('birthDateNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GTime)])));
    }
    value = object.birthDateGT;
    if (value != null) {
      result
        ..add('birthDateGT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateGTE;
    if (value != null) {
      result
        ..add('birthDateGTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateLT;
    if (value != null) {
      result
        ..add('birthDateLT')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateLTE;
    if (value != null) {
      result
        ..add('birthDateLTE')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(GTime)));
    }
    value = object.birthDateIsNil;
    if (value != null) {
      result
        ..add('birthDateIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.birthDateNotNil;
    if (value != null) {
      result
        ..add('birthDateNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.studyTime;
    if (value != null) {
      result
        ..add('studyTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserStudyTime)));
    }
    value = object.studyTimeNEQ;
    if (value != null) {
      result
        ..add('studyTimeNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserStudyTime)));
    }
    value = object.studyTimeIn;
    if (value != null) {
      result
        ..add('studyTimeIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserStudyTime)])));
    }
    value = object.studyTimeNotIn;
    if (value != null) {
      result
        ..add('studyTimeNotIn')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GUserStudyTime)])));
    }
    value = object.studyTimeIsNil;
    if (value != null) {
      result
        ..add('studyTimeIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.studyTimeNotNil;
    if (value != null) {
      result
        ..add('studyTimeNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.role;
    if (value != null) {
      result
        ..add('role')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserRole)));
    }
    value = object.roleNEQ;
    if (value != null) {
      result
        ..add('roleNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GUserRole)));
    }
    value = object.roleIn;
    if (value != null) {
      result
        ..add('roleIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GUserRole)])));
    }
    value = object.roleNotIn;
    if (value != null) {
      result
        ..add('roleNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(GUserRole)])));
    }
    value = object.simoCoins;
    if (value != null) {
      result
        ..add('simoCoins')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.simoCoinsNEQ;
    if (value != null) {
      result
        ..add('simoCoinsNEQ')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.simoCoinsIn;
    if (value != null) {
      result
        ..add('simoCoinsIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.simoCoinsNotIn;
    if (value != null) {
      result
        ..add('simoCoinsNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.simoCoinsGT;
    if (value != null) {
      result
        ..add('simoCoinsGT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.simoCoinsGTE;
    if (value != null) {
      result
        ..add('simoCoinsGTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.simoCoinsLT;
    if (value != null) {
      result
        ..add('simoCoinsLT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.simoCoinsLTE;
    if (value != null) {
      result
        ..add('simoCoinsLTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.score;
    if (value != null) {
      result
        ..add('score')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scoreNEQ;
    if (value != null) {
      result
        ..add('scoreNEQ')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scoreIn;
    if (value != null) {
      result
        ..add('scoreIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.scoreNotIn;
    if (value != null) {
      result
        ..add('scoreNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(int)])));
    }
    value = object.scoreGT;
    if (value != null) {
      result
        ..add('scoreGT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scoreGTE;
    if (value != null) {
      result
        ..add('scoreGTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scoreLT;
    if (value != null) {
      result
        ..add('scoreLT')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.scoreLTE;
    if (value != null) {
      result
        ..add('scoreLTE')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.isPremium;
    if (value != null) {
      result
        ..add('isPremium')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.isPremiumNEQ;
    if (value != null) {
      result
        ..add('isPremiumNEQ')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.major;
    if (value != null) {
      result
        ..add('major')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorNEQ;
    if (value != null) {
      result
        ..add('majorNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorIn;
    if (value != null) {
      result
        ..add('majorIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.majorNotIn;
    if (value != null) {
      result
        ..add('majorNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.majorGT;
    if (value != null) {
      result
        ..add('majorGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorGTE;
    if (value != null) {
      result
        ..add('majorGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorLT;
    if (value != null) {
      result
        ..add('majorLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorLTE;
    if (value != null) {
      result
        ..add('majorLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorContains;
    if (value != null) {
      result
        ..add('majorContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorHasPrefix;
    if (value != null) {
      result
        ..add('majorHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorHasSuffix;
    if (value != null) {
      result
        ..add('majorHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorIsNil;
    if (value != null) {
      result
        ..add('majorIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.majorNotNil;
    if (value != null) {
      result
        ..add('majorNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.majorEqualFold;
    if (value != null) {
      result
        ..add('majorEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.majorContainsFold;
    if (value != null) {
      result
        ..add('majorContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bio;
    if (value != null) {
      result
        ..add('bio')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioNEQ;
    if (value != null) {
      result
        ..add('bioNEQ')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioIn;
    if (value != null) {
      result
        ..add('bioIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.bioNotIn;
    if (value != null) {
      result
        ..add('bioNotIn')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(BuiltList, const [const FullType(String)])));
    }
    value = object.bioGT;
    if (value != null) {
      result
        ..add('bioGT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioGTE;
    if (value != null) {
      result
        ..add('bioGTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioLT;
    if (value != null) {
      result
        ..add('bioLT')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioLTE;
    if (value != null) {
      result
        ..add('bioLTE')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioContains;
    if (value != null) {
      result
        ..add('bioContains')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioHasPrefix;
    if (value != null) {
      result
        ..add('bioHasPrefix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioHasSuffix;
    if (value != null) {
      result
        ..add('bioHasSuffix')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioIsNil;
    if (value != null) {
      result
        ..add('bioIsNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.bioNotNil;
    if (value != null) {
      result
        ..add('bioNotNil')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.bioEqualFold;
    if (value != null) {
      result
        ..add('bioEqualFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.bioContainsFold;
    if (value != null) {
      result
        ..add('bioContainsFold')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.hasInterests;
    if (value != null) {
      result
        ..add('hasInterests')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasInterestsWith;
    if (value != null) {
      result
        ..add('hasInterestsWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GInterestWhereInput)])));
    }
    value = object.hasGoals;
    if (value != null) {
      result
        ..add('hasGoals')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasGoalsWith;
    if (value != null) {
      result
        ..add('hasGoalsWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GGoalWhereInput)])));
    }
    value = object.hasTasks;
    if (value != null) {
      result
        ..add('hasTasks')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.hasTasksWith;
    if (value != null) {
      result
        ..add('hasTasksWith')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(
                BuiltList, const [const FullType(GTaskWhereInput)])));
    }
    return result;
  }

  @override
  GUserWhereInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GUserWhereInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'not':
          result.not.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GUserWhereInput))!
              as GUserWhereInput);
          break;
        case 'and':
          result.and.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'or':
          result.or.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idNEQ':
          result.idNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idIn':
          result.idIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idNotIn':
          result.idNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'idGT':
          result.idGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idGTE':
          result.idGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLT':
          result.idLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'idLTE':
          result.idLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtNEQ':
          result.createdAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtIn':
          result.createdAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtNotIn':
          result.createdAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'createdAtGT':
          result.createdAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtGTE':
          result.createdAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLT':
          result.createdAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'createdAtLTE':
          result.createdAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAt':
          result.updatedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtNEQ':
          result.updatedAtNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtIn':
          result.updatedAtIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtNotIn':
          result.updatedAtNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'updatedAtGT':
          result.updatedAtGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtGTE':
          result.updatedAtGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLT':
          result.updatedAtLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'updatedAtLTE':
          result.updatedAtLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'phoneNumber':
          result.phoneNumber = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberNEQ':
          result.phoneNumberNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberIn':
          result.phoneNumberIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'phoneNumberNotIn':
          result.phoneNumberNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'phoneNumberGT':
          result.phoneNumberGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberGTE':
          result.phoneNumberGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberLT':
          result.phoneNumberLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberLTE':
          result.phoneNumberLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberContains':
          result.phoneNumberContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberHasPrefix':
          result.phoneNumberHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberHasSuffix':
          result.phoneNumberHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberEqualFold':
          result.phoneNumberEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'phoneNumberContainsFold':
          result.phoneNumberContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullName':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameNEQ':
          result.fullNameNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameIn':
          result.fullNameIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'fullNameNotIn':
          result.fullNameNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'fullNameGT':
          result.fullNameGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameGTE':
          result.fullNameGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameLT':
          result.fullNameLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameLTE':
          result.fullNameLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameContains':
          result.fullNameContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameHasPrefix':
          result.fullNameHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameHasSuffix':
          result.fullNameHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameIsNil':
          result.fullNameIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'fullNameNotNil':
          result.fullNameNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'fullNameEqualFold':
          result.fullNameEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'fullNameContainsFold':
          result.fullNameContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'birthDate':
          result.birthDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateNEQ':
          result.birthDateNEQ.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateIn':
          result.birthDateIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'birthDateNotIn':
          result.birthDateNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(GTime)]))!
              as BuiltList<Object?>);
          break;
        case 'birthDateGT':
          result.birthDateGT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateGTE':
          result.birthDateGTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateLT':
          result.birthDateLT.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateLTE':
          result.birthDateLTE.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'birthDateIsNil':
          result.birthDateIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'birthDateNotNil':
          result.birthDateNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'studyTime':
          result.studyTime = serializers.deserialize(value,
              specifiedType: const FullType(GUserStudyTime)) as GUserStudyTime?;
          break;
        case 'studyTimeNEQ':
          result.studyTimeNEQ = serializers.deserialize(value,
              specifiedType: const FullType(GUserStudyTime)) as GUserStudyTime?;
          break;
        case 'studyTimeIn':
          result.studyTimeIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserStudyTime)]))!
              as BuiltList<Object?>);
          break;
        case 'studyTimeNotIn':
          result.studyTimeNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserStudyTime)]))!
              as BuiltList<Object?>);
          break;
        case 'studyTimeIsNil':
          result.studyTimeIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'studyTimeNotNil':
          result.studyTimeNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'role':
          result.role = serializers.deserialize(value,
              specifiedType: const FullType(GUserRole)) as GUserRole?;
          break;
        case 'roleNEQ':
          result.roleNEQ = serializers.deserialize(value,
              specifiedType: const FullType(GUserRole)) as GUserRole?;
          break;
        case 'roleIn':
          result.roleIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserRole)]))!
              as BuiltList<Object?>);
          break;
        case 'roleNotIn':
          result.roleNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GUserRole)]))!
              as BuiltList<Object?>);
          break;
        case 'simoCoins':
          result.simoCoins = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'simoCoinsNEQ':
          result.simoCoinsNEQ = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'simoCoinsIn':
          result.simoCoinsIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'simoCoinsNotIn':
          result.simoCoinsNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'simoCoinsGT':
          result.simoCoinsGT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'simoCoinsGTE':
          result.simoCoinsGTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'simoCoinsLT':
          result.simoCoinsLT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'simoCoinsLTE':
          result.simoCoinsLTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'score':
          result.score = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scoreNEQ':
          result.scoreNEQ = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scoreIn':
          result.scoreIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'scoreNotIn':
          result.scoreNotIn.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(BuiltList, const [const FullType(int)]))!
              as BuiltList<Object?>);
          break;
        case 'scoreGT':
          result.scoreGT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scoreGTE':
          result.scoreGTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scoreLT':
          result.scoreLT = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'scoreLTE':
          result.scoreLTE = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'isPremium':
          result.isPremium = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'isPremiumNEQ':
          result.isPremiumNEQ = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'major':
          result.major = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorNEQ':
          result.majorNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorIn':
          result.majorIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'majorNotIn':
          result.majorNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'majorGT':
          result.majorGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorGTE':
          result.majorGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorLT':
          result.majorLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorLTE':
          result.majorLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorContains':
          result.majorContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorHasPrefix':
          result.majorHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorHasSuffix':
          result.majorHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorIsNil':
          result.majorIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'majorNotNil':
          result.majorNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'majorEqualFold':
          result.majorEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'majorContainsFold':
          result.majorContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bio':
          result.bio = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioNEQ':
          result.bioNEQ = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioIn':
          result.bioIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'bioNotIn':
          result.bioNotIn.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
        case 'bioGT':
          result.bioGT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioGTE':
          result.bioGTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioLT':
          result.bioLT = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioLTE':
          result.bioLTE = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioContains':
          result.bioContains = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioHasPrefix':
          result.bioHasPrefix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioHasSuffix':
          result.bioHasSuffix = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioIsNil':
          result.bioIsNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'bioNotNil':
          result.bioNotNil = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'bioEqualFold':
          result.bioEqualFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'bioContainsFold':
          result.bioContainsFold = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'hasInterests':
          result.hasInterests = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasInterestsWith':
          result.hasInterestsWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GInterestWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'hasGoals':
          result.hasGoals = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasGoalsWith':
          result.hasGoalsWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GGoalWhereInput)]))!
              as BuiltList<Object?>);
          break;
        case 'hasTasks':
          result.hasTasks = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'hasTasksWith':
          result.hasTasksWith.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(GTaskWhereInput)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndLoginInputSerializer
    implements StructuredSerializer<GVerifyOTPAndLoginInput> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndLoginInput,
    _$GVerifyOTPAndLoginInput
  ];
  @override
  final String wireName = 'GVerifyOTPAndLoginInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndLoginInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'phoneNumber',
      serializers.serialize(object.phoneNumber,
          specifiedType: const FullType(String)),
      'code',
      serializers.serialize(object.code, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndLoginInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GVerifyOTPAndLoginInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'phoneNumber':
          result.phoneNumber = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'code':
          result.code = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndRegisterInputSerializer
    implements StructuredSerializer<GVerifyOTPAndRegisterInput> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndRegisterInput,
    _$GVerifyOTPAndRegisterInput
  ];
  @override
  final String wireName = 'GVerifyOTPAndRegisterInput';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndRegisterInput object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'phoneNumber',
      serializers.serialize(object.phoneNumber,
          specifiedType: const FullType(String)),
      'code',
      serializers.serialize(object.code, specifiedType: const FullType(String)),
      'fullName',
      serializers.serialize(object.fullName,
          specifiedType: const FullType(String)),
      'birthDate',
      serializers.serialize(object.birthDate,
          specifiedType: const FullType(GTime)),
      'studyTime',
      serializers.serialize(object.studyTime,
          specifiedType: const FullType(GUserStudyTime)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndRegisterInput deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GVerifyOTPAndRegisterInputBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'phoneNumber':
          result.phoneNumber = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'code':
          result.code = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'fullName':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'birthDate':
          result.birthDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(GTime))! as GTime);
          break;
        case 'studyTime':
          result.studyTime = serializers.deserialize(value,
              specifiedType: const FullType(GUserStudyTime))! as GUserStudyTime;
          break;
      }
    }

    return result.build();
  }
}

class _$GCursor extends GCursor {
  @override
  final String value;

  factory _$GCursor([void Function(GCursorBuilder)? updates]) =>
      (new GCursorBuilder()..update(updates))._build();

  _$GCursor._({required this.value}) : super._() {
    BuiltValueNullFieldError.checkNotNull(value, r'GCursor', 'value');
  }

  @override
  GCursor rebuild(void Function(GCursorBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCursorBuilder toBuilder() => new GCursorBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCursor && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCursor')..add('value', value))
        .toString();
  }
}

class GCursorBuilder implements Builder<GCursor, GCursorBuilder> {
  _$GCursor? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GCursorBuilder();

  GCursorBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCursor other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCursor;
  }

  @override
  void update(void Function(GCursorBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCursor build() => _build();

  _$GCursor _build() {
    final _$result = _$v ??
        new _$GCursor._(
            value: BuiltValueNullFieldError.checkNotNull(
                value, r'GCursor', 'value'));
    replace(_$result);
    return _$result;
  }
}

class _$GTime extends GTime {
  @override
  final String value;

  factory _$GTime([void Function(GTimeBuilder)? updates]) =>
      (new GTimeBuilder()..update(updates))._build();

  _$GTime._({required this.value}) : super._() {
    BuiltValueNullFieldError.checkNotNull(value, r'GTime', 'value');
  }

  @override
  GTime rebuild(void Function(GTimeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTimeBuilder toBuilder() => new GTimeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTime && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTime')..add('value', value))
        .toString();
  }
}

class GTimeBuilder implements Builder<GTime, GTimeBuilder> {
  _$GTime? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GTimeBuilder();

  GTimeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTime other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GTime;
  }

  @override
  void update(void Function(GTimeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTime build() => _build();

  _$GTime _build() {
    final _$result = _$v ??
        new _$GTime._(
            value: BuiltValueNullFieldError.checkNotNull(
                value, r'GTime', 'value'));
    replace(_$result);
    return _$result;
  }
}

class _$GUUID extends GUUID {
  @override
  final String value;

  factory _$GUUID([void Function(GUUIDBuilder)? updates]) =>
      (new GUUIDBuilder()..update(updates))._build();

  _$GUUID._({required this.value}) : super._() {
    BuiltValueNullFieldError.checkNotNull(value, r'GUUID', 'value');
  }

  @override
  GUUID rebuild(void Function(GUUIDBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUUIDBuilder toBuilder() => new GUUIDBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUUID && value == other.value;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUUID')..add('value', value))
        .toString();
  }
}

class GUUIDBuilder implements Builder<GUUID, GUUIDBuilder> {
  _$GUUID? _$v;

  String? _value;
  String? get value => _$this._value;
  set value(String? value) => _$this._value = value;

  GUUIDBuilder();

  GUUIDBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _value = $v.value;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUUID other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUUID;
  }

  @override
  void update(void Function(GUUIDBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUUID build() => _build();

  _$GUUID _build() {
    final _$result = _$v ??
        new _$GUUID._(
            value: BuiltValueNullFieldError.checkNotNull(
                value, r'GUUID', 'value'));
    replace(_$result);
    return _$result;
  }
}

class _$GCreateDirectChatInput extends GCreateDirectChatInput {
  @override
  final GUUID targetUserID;

  factory _$GCreateDirectChatInput(
          [void Function(GCreateDirectChatInputBuilder)? updates]) =>
      (new GCreateDirectChatInputBuilder()..update(updates))._build();

  _$GCreateDirectChatInput._({required this.targetUserID}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        targetUserID, r'GCreateDirectChatInput', 'targetUserID');
  }

  @override
  GCreateDirectChatInput rebuild(
          void Function(GCreateDirectChatInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateDirectChatInputBuilder toBuilder() =>
      new GCreateDirectChatInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateDirectChatInput &&
        targetUserID == other.targetUserID;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, targetUserID.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateDirectChatInput')
          ..add('targetUserID', targetUserID))
        .toString();
  }
}

class GCreateDirectChatInputBuilder
    implements Builder<GCreateDirectChatInput, GCreateDirectChatInputBuilder> {
  _$GCreateDirectChatInput? _$v;

  GUUIDBuilder? _targetUserID;
  GUUIDBuilder get targetUserID => _$this._targetUserID ??= new GUUIDBuilder();
  set targetUserID(GUUIDBuilder? targetUserID) =>
      _$this._targetUserID = targetUserID;

  GCreateDirectChatInputBuilder();

  GCreateDirectChatInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _targetUserID = $v.targetUserID.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateDirectChatInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCreateDirectChatInput;
  }

  @override
  void update(void Function(GCreateDirectChatInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateDirectChatInput build() => _build();

  _$GCreateDirectChatInput _build() {
    _$GCreateDirectChatInput _$result;
    try {
      _$result = _$v ??
          new _$GCreateDirectChatInput._(targetUserID: targetUserID.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'targetUserID';
        targetUserID.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GCreateDirectChatInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendMessageInput extends GSendMessageInput {
  @override
  final String chatID;
  @override
  final String content;
  @override
  final String? replyToID;

  factory _$GSendMessageInput(
          [void Function(GSendMessageInputBuilder)? updates]) =>
      (new GSendMessageInputBuilder()..update(updates))._build();

  _$GSendMessageInput._(
      {required this.chatID, required this.content, this.replyToID})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        chatID, r'GSendMessageInput', 'chatID');
    BuiltValueNullFieldError.checkNotNull(
        content, r'GSendMessageInput', 'content');
  }

  @override
  GSendMessageInput rebuild(void Function(GSendMessageInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageInputBuilder toBuilder() =>
      new GSendMessageInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageInput &&
        chatID == other.chatID &&
        content == other.content &&
        replyToID == other.replyToID;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chatID.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, replyToID.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendMessageInput')
          ..add('chatID', chatID)
          ..add('content', content)
          ..add('replyToID', replyToID))
        .toString();
  }
}

class GSendMessageInputBuilder
    implements Builder<GSendMessageInput, GSendMessageInputBuilder> {
  _$GSendMessageInput? _$v;

  String? _chatID;
  String? get chatID => _$this._chatID;
  set chatID(String? chatID) => _$this._chatID = chatID;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _replyToID;
  String? get replyToID => _$this._replyToID;
  set replyToID(String? replyToID) => _$this._replyToID = replyToID;

  GSendMessageInputBuilder();

  GSendMessageInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _chatID = $v.chatID;
      _content = $v.content;
      _replyToID = $v.replyToID;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendMessageInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendMessageInput;
  }

  @override
  void update(void Function(GSendMessageInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageInput build() => _build();

  _$GSendMessageInput _build() {
    final _$result = _$v ??
        new _$GSendMessageInput._(
            chatID: BuiltValueNullFieldError.checkNotNull(
                chatID, r'GSendMessageInput', 'chatID'),
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'GSendMessageInput', 'content'),
            replyToID: replyToID);
    replace(_$result);
    return _$result;
  }
}

class _$GCreateGoalInput extends GCreateGoalInput {
  @override
  final String title;
  @override
  final String? note;
  @override
  final GTime? targetDate;

  factory _$GCreateGoalInput(
          [void Function(GCreateGoalInputBuilder)? updates]) =>
      (new GCreateGoalInputBuilder()..update(updates))._build();

  _$GCreateGoalInput._({required this.title, this.note, this.targetDate})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(title, r'GCreateGoalInput', 'title');
  }

  @override
  GCreateGoalInput rebuild(void Function(GCreateGoalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateGoalInputBuilder toBuilder() =>
      new GCreateGoalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateGoalInput &&
        title == other.title &&
        note == other.note &&
        targetDate == other.targetDate;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, targetDate.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateGoalInput')
          ..add('title', title)
          ..add('note', note)
          ..add('targetDate', targetDate))
        .toString();
  }
}

class GCreateGoalInputBuilder
    implements Builder<GCreateGoalInput, GCreateGoalInputBuilder> {
  _$GCreateGoalInput? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GTimeBuilder? _targetDate;
  GTimeBuilder get targetDate => _$this._targetDate ??= new GTimeBuilder();
  set targetDate(GTimeBuilder? targetDate) => _$this._targetDate = targetDate;

  GCreateGoalInputBuilder();

  GCreateGoalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _note = $v.note;
      _targetDate = $v.targetDate?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateGoalInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCreateGoalInput;
  }

  @override
  void update(void Function(GCreateGoalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateGoalInput build() => _build();

  _$GCreateGoalInput _build() {
    _$GCreateGoalInput _$result;
    try {
      _$result = _$v ??
          new _$GCreateGoalInput._(
              title: BuiltValueNullFieldError.checkNotNull(
                  title, r'GCreateGoalInput', 'title'),
              note: note,
              targetDate: _targetDate?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'targetDate';
        _targetDate?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GCreateGoalInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateTaskInput extends GCreateTaskInput {
  @override
  final String title;
  @override
  final String? shortDescription;
  @override
  final GTaskType? type;
  @override
  final String? note;
  @override
  final GTime date;
  @override
  final int? durationM;
  @override
  final bool? hasReminder;
  @override
  final GTime? reminderTime;
  @override
  final String? recurringDays;
  @override
  final String? goalID;
  @override
  final BuiltList<String>? tagNames;

  factory _$GCreateTaskInput(
          [void Function(GCreateTaskInputBuilder)? updates]) =>
      (new GCreateTaskInputBuilder()..update(updates))._build();

  _$GCreateTaskInput._(
      {required this.title,
      this.shortDescription,
      this.type,
      this.note,
      required this.date,
      this.durationM,
      this.hasReminder,
      this.reminderTime,
      this.recurringDays,
      this.goalID,
      this.tagNames})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(title, r'GCreateTaskInput', 'title');
    BuiltValueNullFieldError.checkNotNull(date, r'GCreateTaskInput', 'date');
  }

  @override
  GCreateTaskInput rebuild(void Function(GCreateTaskInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskInputBuilder toBuilder() =>
      new GCreateTaskInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskInput &&
        title == other.title &&
        shortDescription == other.shortDescription &&
        type == other.type &&
        note == other.note &&
        date == other.date &&
        durationM == other.durationM &&
        hasReminder == other.hasReminder &&
        reminderTime == other.reminderTime &&
        recurringDays == other.recurringDays &&
        goalID == other.goalID &&
        tagNames == other.tagNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, shortDescription.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, durationM.hashCode);
    _$hash = $jc(_$hash, hasReminder.hashCode);
    _$hash = $jc(_$hash, reminderTime.hashCode);
    _$hash = $jc(_$hash, recurringDays.hashCode);
    _$hash = $jc(_$hash, goalID.hashCode);
    _$hash = $jc(_$hash, tagNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskInput')
          ..add('title', title)
          ..add('shortDescription', shortDescription)
          ..add('type', type)
          ..add('note', note)
          ..add('date', date)
          ..add('durationM', durationM)
          ..add('hasReminder', hasReminder)
          ..add('reminderTime', reminderTime)
          ..add('recurringDays', recurringDays)
          ..add('goalID', goalID)
          ..add('tagNames', tagNames))
        .toString();
  }
}

class GCreateTaskInputBuilder
    implements Builder<GCreateTaskInput, GCreateTaskInputBuilder> {
  _$GCreateTaskInput? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _shortDescription;
  String? get shortDescription => _$this._shortDescription;
  set shortDescription(String? shortDescription) =>
      _$this._shortDescription = shortDescription;

  GTaskType? _type;
  GTaskType? get type => _$this._type;
  set type(GTaskType? type) => _$this._type = type;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GTimeBuilder? _date;
  GTimeBuilder get date => _$this._date ??= new GTimeBuilder();
  set date(GTimeBuilder? date) => _$this._date = date;

  int? _durationM;
  int? get durationM => _$this._durationM;
  set durationM(int? durationM) => _$this._durationM = durationM;

  bool? _hasReminder;
  bool? get hasReminder => _$this._hasReminder;
  set hasReminder(bool? hasReminder) => _$this._hasReminder = hasReminder;

  GTimeBuilder? _reminderTime;
  GTimeBuilder get reminderTime => _$this._reminderTime ??= new GTimeBuilder();
  set reminderTime(GTimeBuilder? reminderTime) =>
      _$this._reminderTime = reminderTime;

  String? _recurringDays;
  String? get recurringDays => _$this._recurringDays;
  set recurringDays(String? recurringDays) =>
      _$this._recurringDays = recurringDays;

  String? _goalID;
  String? get goalID => _$this._goalID;
  set goalID(String? goalID) => _$this._goalID = goalID;

  ListBuilder<String>? _tagNames;
  ListBuilder<String> get tagNames =>
      _$this._tagNames ??= new ListBuilder<String>();
  set tagNames(ListBuilder<String>? tagNames) => _$this._tagNames = tagNames;

  GCreateTaskInputBuilder();

  GCreateTaskInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _shortDescription = $v.shortDescription;
      _type = $v.type;
      _note = $v.note;
      _date = $v.date.toBuilder();
      _durationM = $v.durationM;
      _hasReminder = $v.hasReminder;
      _reminderTime = $v.reminderTime?.toBuilder();
      _recurringDays = $v.recurringDays;
      _goalID = $v.goalID;
      _tagNames = $v.tagNames?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCreateTaskInput;
  }

  @override
  void update(void Function(GCreateTaskInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskInput build() => _build();

  _$GCreateTaskInput _build() {
    _$GCreateTaskInput _$result;
    try {
      _$result = _$v ??
          new _$GCreateTaskInput._(
              title: BuiltValueNullFieldError.checkNotNull(
                  title, r'GCreateTaskInput', 'title'),
              shortDescription: shortDescription,
              type: type,
              note: note,
              date: date.build(),
              durationM: durationM,
              hasReminder: hasReminder,
              reminderTime: _reminderTime?.build(),
              recurringDays: recurringDays,
              goalID: goalID,
              tagNames: _tagNames?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'date';
        date.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();

        _$failedField = 'tagNames';
        _tagNames?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GCreateTaskInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGoalOrder extends GGoalOrder {
  @override
  final GOrderDirection direction;
  @override
  final GGoalOrderField field;

  factory _$GGoalOrder([void Function(GGoalOrderBuilder)? updates]) =>
      (new GGoalOrderBuilder()..update(updates))._build();

  _$GGoalOrder._({required this.direction, required this.field}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        direction, r'GGoalOrder', 'direction');
    BuiltValueNullFieldError.checkNotNull(field, r'GGoalOrder', 'field');
  }

  @override
  GGoalOrder rebuild(void Function(GGoalOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGoalOrderBuilder toBuilder() => new GGoalOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGoalOrder &&
        direction == other.direction &&
        field == other.field;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGoalOrder')
          ..add('direction', direction)
          ..add('field', field))
        .toString();
  }
}

class GGoalOrderBuilder implements Builder<GGoalOrder, GGoalOrderBuilder> {
  _$GGoalOrder? _$v;

  GOrderDirection? _direction;
  GOrderDirection? get direction => _$this._direction;
  set direction(GOrderDirection? direction) => _$this._direction = direction;

  GGoalOrderField? _field;
  GGoalOrderField? get field => _$this._field;
  set field(GGoalOrderField? field) => _$this._field = field;

  GGoalOrderBuilder();

  GGoalOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _field = $v.field;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGoalOrder other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGoalOrder;
  }

  @override
  void update(void Function(GGoalOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGoalOrder build() => _build();

  _$GGoalOrder _build() {
    final _$result = _$v ??
        new _$GGoalOrder._(
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'GGoalOrder', 'direction'),
            field: BuiltValueNullFieldError.checkNotNull(
                field, r'GGoalOrder', 'field'));
    replace(_$result);
    return _$result;
  }
}

class _$GGoalWhereInput extends GGoalWhereInput {
  @override
  final GGoalWhereInput? not;
  @override
  final BuiltList<GGoalWhereInput>? and;
  @override
  final BuiltList<GGoalWhereInput>? or;
  @override
  final String? id;
  @override
  final String? idNEQ;
  @override
  final BuiltList<String>? idIn;
  @override
  final BuiltList<String>? idNotIn;
  @override
  final String? idGT;
  @override
  final String? idGTE;
  @override
  final String? idLT;
  @override
  final String? idLTE;
  @override
  final GTime? createdAt;
  @override
  final GTime? createdAtNEQ;
  @override
  final BuiltList<GTime>? createdAtIn;
  @override
  final BuiltList<GTime>? createdAtNotIn;
  @override
  final GTime? createdAtGT;
  @override
  final GTime? createdAtGTE;
  @override
  final GTime? createdAtLT;
  @override
  final GTime? createdAtLTE;
  @override
  final GTime? updatedAt;
  @override
  final GTime? updatedAtNEQ;
  @override
  final BuiltList<GTime>? updatedAtIn;
  @override
  final BuiltList<GTime>? updatedAtNotIn;
  @override
  final GTime? updatedAtGT;
  @override
  final GTime? updatedAtGTE;
  @override
  final GTime? updatedAtLT;
  @override
  final GTime? updatedAtLTE;
  @override
  final String? title;
  @override
  final String? titleNEQ;
  @override
  final BuiltList<String>? titleIn;
  @override
  final BuiltList<String>? titleNotIn;
  @override
  final String? titleGT;
  @override
  final String? titleGTE;
  @override
  final String? titleLT;
  @override
  final String? titleLTE;
  @override
  final String? titleContains;
  @override
  final String? titleHasPrefix;
  @override
  final String? titleHasSuffix;
  @override
  final String? titleEqualFold;
  @override
  final String? titleContainsFold;
  @override
  final String? note;
  @override
  final String? noteNEQ;
  @override
  final BuiltList<String>? noteIn;
  @override
  final BuiltList<String>? noteNotIn;
  @override
  final String? noteGT;
  @override
  final String? noteGTE;
  @override
  final String? noteLT;
  @override
  final String? noteLTE;
  @override
  final String? noteContains;
  @override
  final String? noteHasPrefix;
  @override
  final String? noteHasSuffix;
  @override
  final bool? noteIsNil;
  @override
  final bool? noteNotNil;
  @override
  final String? noteEqualFold;
  @override
  final String? noteContainsFold;
  @override
  final GTime? targetDate;
  @override
  final GTime? targetDateNEQ;
  @override
  final BuiltList<GTime>? targetDateIn;
  @override
  final BuiltList<GTime>? targetDateNotIn;
  @override
  final GTime? targetDateGT;
  @override
  final GTime? targetDateGTE;
  @override
  final GTime? targetDateLT;
  @override
  final GTime? targetDateLTE;
  @override
  final bool? targetDateIsNil;
  @override
  final bool? targetDateNotNil;
  @override
  final GGoalStatus? status;
  @override
  final GGoalStatus? statusNEQ;
  @override
  final BuiltList<GGoalStatus>? statusIn;
  @override
  final BuiltList<GGoalStatus>? statusNotIn;
  @override
  final bool? hasUser;
  @override
  final BuiltList<GUserWhereInput>? hasUserWith;
  @override
  final bool? hasTasks;
  @override
  final BuiltList<GTaskWhereInput>? hasTasksWith;

  factory _$GGoalWhereInput([void Function(GGoalWhereInputBuilder)? updates]) =>
      (new GGoalWhereInputBuilder()..update(updates))._build();

  _$GGoalWhereInput._(
      {this.not,
      this.and,
      this.or,
      this.id,
      this.idNEQ,
      this.idIn,
      this.idNotIn,
      this.idGT,
      this.idGTE,
      this.idLT,
      this.idLTE,
      this.createdAt,
      this.createdAtNEQ,
      this.createdAtIn,
      this.createdAtNotIn,
      this.createdAtGT,
      this.createdAtGTE,
      this.createdAtLT,
      this.createdAtLTE,
      this.updatedAt,
      this.updatedAtNEQ,
      this.updatedAtIn,
      this.updatedAtNotIn,
      this.updatedAtGT,
      this.updatedAtGTE,
      this.updatedAtLT,
      this.updatedAtLTE,
      this.title,
      this.titleNEQ,
      this.titleIn,
      this.titleNotIn,
      this.titleGT,
      this.titleGTE,
      this.titleLT,
      this.titleLTE,
      this.titleContains,
      this.titleHasPrefix,
      this.titleHasSuffix,
      this.titleEqualFold,
      this.titleContainsFold,
      this.note,
      this.noteNEQ,
      this.noteIn,
      this.noteNotIn,
      this.noteGT,
      this.noteGTE,
      this.noteLT,
      this.noteLTE,
      this.noteContains,
      this.noteHasPrefix,
      this.noteHasSuffix,
      this.noteIsNil,
      this.noteNotNil,
      this.noteEqualFold,
      this.noteContainsFold,
      this.targetDate,
      this.targetDateNEQ,
      this.targetDateIn,
      this.targetDateNotIn,
      this.targetDateGT,
      this.targetDateGTE,
      this.targetDateLT,
      this.targetDateLTE,
      this.targetDateIsNil,
      this.targetDateNotNil,
      this.status,
      this.statusNEQ,
      this.statusIn,
      this.statusNotIn,
      this.hasUser,
      this.hasUserWith,
      this.hasTasks,
      this.hasTasksWith})
      : super._();

  @override
  GGoalWhereInput rebuild(void Function(GGoalWhereInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGoalWhereInputBuilder toBuilder() =>
      new GGoalWhereInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGoalWhereInput &&
        not == other.not &&
        and == other.and &&
        or == other.or &&
        id == other.id &&
        idNEQ == other.idNEQ &&
        idIn == other.idIn &&
        idNotIn == other.idNotIn &&
        idGT == other.idGT &&
        idGTE == other.idGTE &&
        idLT == other.idLT &&
        idLTE == other.idLTE &&
        createdAt == other.createdAt &&
        createdAtNEQ == other.createdAtNEQ &&
        createdAtIn == other.createdAtIn &&
        createdAtNotIn == other.createdAtNotIn &&
        createdAtGT == other.createdAtGT &&
        createdAtGTE == other.createdAtGTE &&
        createdAtLT == other.createdAtLT &&
        createdAtLTE == other.createdAtLTE &&
        updatedAt == other.updatedAt &&
        updatedAtNEQ == other.updatedAtNEQ &&
        updatedAtIn == other.updatedAtIn &&
        updatedAtNotIn == other.updatedAtNotIn &&
        updatedAtGT == other.updatedAtGT &&
        updatedAtGTE == other.updatedAtGTE &&
        updatedAtLT == other.updatedAtLT &&
        updatedAtLTE == other.updatedAtLTE &&
        title == other.title &&
        titleNEQ == other.titleNEQ &&
        titleIn == other.titleIn &&
        titleNotIn == other.titleNotIn &&
        titleGT == other.titleGT &&
        titleGTE == other.titleGTE &&
        titleLT == other.titleLT &&
        titleLTE == other.titleLTE &&
        titleContains == other.titleContains &&
        titleHasPrefix == other.titleHasPrefix &&
        titleHasSuffix == other.titleHasSuffix &&
        titleEqualFold == other.titleEqualFold &&
        titleContainsFold == other.titleContainsFold &&
        note == other.note &&
        noteNEQ == other.noteNEQ &&
        noteIn == other.noteIn &&
        noteNotIn == other.noteNotIn &&
        noteGT == other.noteGT &&
        noteGTE == other.noteGTE &&
        noteLT == other.noteLT &&
        noteLTE == other.noteLTE &&
        noteContains == other.noteContains &&
        noteHasPrefix == other.noteHasPrefix &&
        noteHasSuffix == other.noteHasSuffix &&
        noteIsNil == other.noteIsNil &&
        noteNotNil == other.noteNotNil &&
        noteEqualFold == other.noteEqualFold &&
        noteContainsFold == other.noteContainsFold &&
        targetDate == other.targetDate &&
        targetDateNEQ == other.targetDateNEQ &&
        targetDateIn == other.targetDateIn &&
        targetDateNotIn == other.targetDateNotIn &&
        targetDateGT == other.targetDateGT &&
        targetDateGTE == other.targetDateGTE &&
        targetDateLT == other.targetDateLT &&
        targetDateLTE == other.targetDateLTE &&
        targetDateIsNil == other.targetDateIsNil &&
        targetDateNotNil == other.targetDateNotNil &&
        status == other.status &&
        statusNEQ == other.statusNEQ &&
        statusIn == other.statusIn &&
        statusNotIn == other.statusNotIn &&
        hasUser == other.hasUser &&
        hasUserWith == other.hasUserWith &&
        hasTasks == other.hasTasks &&
        hasTasksWith == other.hasTasksWith;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, not.hashCode);
    _$hash = $jc(_$hash, and.hashCode);
    _$hash = $jc(_$hash, or.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idNEQ.hashCode);
    _$hash = $jc(_$hash, idIn.hashCode);
    _$hash = $jc(_$hash, idNotIn.hashCode);
    _$hash = $jc(_$hash, idGT.hashCode);
    _$hash = $jc(_$hash, idGTE.hashCode);
    _$hash = $jc(_$hash, idLT.hashCode);
    _$hash = $jc(_$hash, idLTE.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdAtNEQ.hashCode);
    _$hash = $jc(_$hash, createdAtIn.hashCode);
    _$hash = $jc(_$hash, createdAtNotIn.hashCode);
    _$hash = $jc(_$hash, createdAtGT.hashCode);
    _$hash = $jc(_$hash, createdAtGTE.hashCode);
    _$hash = $jc(_$hash, createdAtLT.hashCode);
    _$hash = $jc(_$hash, createdAtLTE.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedAtNEQ.hashCode);
    _$hash = $jc(_$hash, updatedAtIn.hashCode);
    _$hash = $jc(_$hash, updatedAtNotIn.hashCode);
    _$hash = $jc(_$hash, updatedAtGT.hashCode);
    _$hash = $jc(_$hash, updatedAtGTE.hashCode);
    _$hash = $jc(_$hash, updatedAtLT.hashCode);
    _$hash = $jc(_$hash, updatedAtLTE.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, titleNEQ.hashCode);
    _$hash = $jc(_$hash, titleIn.hashCode);
    _$hash = $jc(_$hash, titleNotIn.hashCode);
    _$hash = $jc(_$hash, titleGT.hashCode);
    _$hash = $jc(_$hash, titleGTE.hashCode);
    _$hash = $jc(_$hash, titleLT.hashCode);
    _$hash = $jc(_$hash, titleLTE.hashCode);
    _$hash = $jc(_$hash, titleContains.hashCode);
    _$hash = $jc(_$hash, titleHasPrefix.hashCode);
    _$hash = $jc(_$hash, titleHasSuffix.hashCode);
    _$hash = $jc(_$hash, titleEqualFold.hashCode);
    _$hash = $jc(_$hash, titleContainsFold.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, noteNEQ.hashCode);
    _$hash = $jc(_$hash, noteIn.hashCode);
    _$hash = $jc(_$hash, noteNotIn.hashCode);
    _$hash = $jc(_$hash, noteGT.hashCode);
    _$hash = $jc(_$hash, noteGTE.hashCode);
    _$hash = $jc(_$hash, noteLT.hashCode);
    _$hash = $jc(_$hash, noteLTE.hashCode);
    _$hash = $jc(_$hash, noteContains.hashCode);
    _$hash = $jc(_$hash, noteHasPrefix.hashCode);
    _$hash = $jc(_$hash, noteHasSuffix.hashCode);
    _$hash = $jc(_$hash, noteIsNil.hashCode);
    _$hash = $jc(_$hash, noteNotNil.hashCode);
    _$hash = $jc(_$hash, noteEqualFold.hashCode);
    _$hash = $jc(_$hash, noteContainsFold.hashCode);
    _$hash = $jc(_$hash, targetDate.hashCode);
    _$hash = $jc(_$hash, targetDateNEQ.hashCode);
    _$hash = $jc(_$hash, targetDateIn.hashCode);
    _$hash = $jc(_$hash, targetDateNotIn.hashCode);
    _$hash = $jc(_$hash, targetDateGT.hashCode);
    _$hash = $jc(_$hash, targetDateGTE.hashCode);
    _$hash = $jc(_$hash, targetDateLT.hashCode);
    _$hash = $jc(_$hash, targetDateLTE.hashCode);
    _$hash = $jc(_$hash, targetDateIsNil.hashCode);
    _$hash = $jc(_$hash, targetDateNotNil.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, statusNEQ.hashCode);
    _$hash = $jc(_$hash, statusIn.hashCode);
    _$hash = $jc(_$hash, statusNotIn.hashCode);
    _$hash = $jc(_$hash, hasUser.hashCode);
    _$hash = $jc(_$hash, hasUserWith.hashCode);
    _$hash = $jc(_$hash, hasTasks.hashCode);
    _$hash = $jc(_$hash, hasTasksWith.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGoalWhereInput')
          ..add('not', not)
          ..add('and', and)
          ..add('or', or)
          ..add('id', id)
          ..add('idNEQ', idNEQ)
          ..add('idIn', idIn)
          ..add('idNotIn', idNotIn)
          ..add('idGT', idGT)
          ..add('idGTE', idGTE)
          ..add('idLT', idLT)
          ..add('idLTE', idLTE)
          ..add('createdAt', createdAt)
          ..add('createdAtNEQ', createdAtNEQ)
          ..add('createdAtIn', createdAtIn)
          ..add('createdAtNotIn', createdAtNotIn)
          ..add('createdAtGT', createdAtGT)
          ..add('createdAtGTE', createdAtGTE)
          ..add('createdAtLT', createdAtLT)
          ..add('createdAtLTE', createdAtLTE)
          ..add('updatedAt', updatedAt)
          ..add('updatedAtNEQ', updatedAtNEQ)
          ..add('updatedAtIn', updatedAtIn)
          ..add('updatedAtNotIn', updatedAtNotIn)
          ..add('updatedAtGT', updatedAtGT)
          ..add('updatedAtGTE', updatedAtGTE)
          ..add('updatedAtLT', updatedAtLT)
          ..add('updatedAtLTE', updatedAtLTE)
          ..add('title', title)
          ..add('titleNEQ', titleNEQ)
          ..add('titleIn', titleIn)
          ..add('titleNotIn', titleNotIn)
          ..add('titleGT', titleGT)
          ..add('titleGTE', titleGTE)
          ..add('titleLT', titleLT)
          ..add('titleLTE', titleLTE)
          ..add('titleContains', titleContains)
          ..add('titleHasPrefix', titleHasPrefix)
          ..add('titleHasSuffix', titleHasSuffix)
          ..add('titleEqualFold', titleEqualFold)
          ..add('titleContainsFold', titleContainsFold)
          ..add('note', note)
          ..add('noteNEQ', noteNEQ)
          ..add('noteIn', noteIn)
          ..add('noteNotIn', noteNotIn)
          ..add('noteGT', noteGT)
          ..add('noteGTE', noteGTE)
          ..add('noteLT', noteLT)
          ..add('noteLTE', noteLTE)
          ..add('noteContains', noteContains)
          ..add('noteHasPrefix', noteHasPrefix)
          ..add('noteHasSuffix', noteHasSuffix)
          ..add('noteIsNil', noteIsNil)
          ..add('noteNotNil', noteNotNil)
          ..add('noteEqualFold', noteEqualFold)
          ..add('noteContainsFold', noteContainsFold)
          ..add('targetDate', targetDate)
          ..add('targetDateNEQ', targetDateNEQ)
          ..add('targetDateIn', targetDateIn)
          ..add('targetDateNotIn', targetDateNotIn)
          ..add('targetDateGT', targetDateGT)
          ..add('targetDateGTE', targetDateGTE)
          ..add('targetDateLT', targetDateLT)
          ..add('targetDateLTE', targetDateLTE)
          ..add('targetDateIsNil', targetDateIsNil)
          ..add('targetDateNotNil', targetDateNotNil)
          ..add('status', status)
          ..add('statusNEQ', statusNEQ)
          ..add('statusIn', statusIn)
          ..add('statusNotIn', statusNotIn)
          ..add('hasUser', hasUser)
          ..add('hasUserWith', hasUserWith)
          ..add('hasTasks', hasTasks)
          ..add('hasTasksWith', hasTasksWith))
        .toString();
  }
}

class GGoalWhereInputBuilder
    implements Builder<GGoalWhereInput, GGoalWhereInputBuilder> {
  _$GGoalWhereInput? _$v;

  GGoalWhereInputBuilder? _not;
  GGoalWhereInputBuilder get not =>
      _$this._not ??= new GGoalWhereInputBuilder();
  set not(GGoalWhereInputBuilder? not) => _$this._not = not;

  ListBuilder<GGoalWhereInput>? _and;
  ListBuilder<GGoalWhereInput> get and =>
      _$this._and ??= new ListBuilder<GGoalWhereInput>();
  set and(ListBuilder<GGoalWhereInput>? and) => _$this._and = and;

  ListBuilder<GGoalWhereInput>? _or;
  ListBuilder<GGoalWhereInput> get or =>
      _$this._or ??= new ListBuilder<GGoalWhereInput>();
  set or(ListBuilder<GGoalWhereInput>? or) => _$this._or = or;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _idNEQ;
  String? get idNEQ => _$this._idNEQ;
  set idNEQ(String? idNEQ) => _$this._idNEQ = idNEQ;

  ListBuilder<String>? _idIn;
  ListBuilder<String> get idIn => _$this._idIn ??= new ListBuilder<String>();
  set idIn(ListBuilder<String>? idIn) => _$this._idIn = idIn;

  ListBuilder<String>? _idNotIn;
  ListBuilder<String> get idNotIn =>
      _$this._idNotIn ??= new ListBuilder<String>();
  set idNotIn(ListBuilder<String>? idNotIn) => _$this._idNotIn = idNotIn;

  String? _idGT;
  String? get idGT => _$this._idGT;
  set idGT(String? idGT) => _$this._idGT = idGT;

  String? _idGTE;
  String? get idGTE => _$this._idGTE;
  set idGTE(String? idGTE) => _$this._idGTE = idGTE;

  String? _idLT;
  String? get idLT => _$this._idLT;
  set idLT(String? idLT) => _$this._idLT = idLT;

  String? _idLTE;
  String? get idLTE => _$this._idLTE;
  set idLTE(String? idLTE) => _$this._idLTE = idLTE;

  GTimeBuilder? _createdAt;
  GTimeBuilder get createdAt => _$this._createdAt ??= new GTimeBuilder();
  set createdAt(GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GTimeBuilder? _createdAtNEQ;
  GTimeBuilder get createdAtNEQ => _$this._createdAtNEQ ??= new GTimeBuilder();
  set createdAtNEQ(GTimeBuilder? createdAtNEQ) =>
      _$this._createdAtNEQ = createdAtNEQ;

  ListBuilder<GTime>? _createdAtIn;
  ListBuilder<GTime> get createdAtIn =>
      _$this._createdAtIn ??= new ListBuilder<GTime>();
  set createdAtIn(ListBuilder<GTime>? createdAtIn) =>
      _$this._createdAtIn = createdAtIn;

  ListBuilder<GTime>? _createdAtNotIn;
  ListBuilder<GTime> get createdAtNotIn =>
      _$this._createdAtNotIn ??= new ListBuilder<GTime>();
  set createdAtNotIn(ListBuilder<GTime>? createdAtNotIn) =>
      _$this._createdAtNotIn = createdAtNotIn;

  GTimeBuilder? _createdAtGT;
  GTimeBuilder get createdAtGT => _$this._createdAtGT ??= new GTimeBuilder();
  set createdAtGT(GTimeBuilder? createdAtGT) =>
      _$this._createdAtGT = createdAtGT;

  GTimeBuilder? _createdAtGTE;
  GTimeBuilder get createdAtGTE => _$this._createdAtGTE ??= new GTimeBuilder();
  set createdAtGTE(GTimeBuilder? createdAtGTE) =>
      _$this._createdAtGTE = createdAtGTE;

  GTimeBuilder? _createdAtLT;
  GTimeBuilder get createdAtLT => _$this._createdAtLT ??= new GTimeBuilder();
  set createdAtLT(GTimeBuilder? createdAtLT) =>
      _$this._createdAtLT = createdAtLT;

  GTimeBuilder? _createdAtLTE;
  GTimeBuilder get createdAtLTE => _$this._createdAtLTE ??= new GTimeBuilder();
  set createdAtLTE(GTimeBuilder? createdAtLTE) =>
      _$this._createdAtLTE = createdAtLTE;

  GTimeBuilder? _updatedAt;
  GTimeBuilder get updatedAt => _$this._updatedAt ??= new GTimeBuilder();
  set updatedAt(GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  GTimeBuilder? _updatedAtNEQ;
  GTimeBuilder get updatedAtNEQ => _$this._updatedAtNEQ ??= new GTimeBuilder();
  set updatedAtNEQ(GTimeBuilder? updatedAtNEQ) =>
      _$this._updatedAtNEQ = updatedAtNEQ;

  ListBuilder<GTime>? _updatedAtIn;
  ListBuilder<GTime> get updatedAtIn =>
      _$this._updatedAtIn ??= new ListBuilder<GTime>();
  set updatedAtIn(ListBuilder<GTime>? updatedAtIn) =>
      _$this._updatedAtIn = updatedAtIn;

  ListBuilder<GTime>? _updatedAtNotIn;
  ListBuilder<GTime> get updatedAtNotIn =>
      _$this._updatedAtNotIn ??= new ListBuilder<GTime>();
  set updatedAtNotIn(ListBuilder<GTime>? updatedAtNotIn) =>
      _$this._updatedAtNotIn = updatedAtNotIn;

  GTimeBuilder? _updatedAtGT;
  GTimeBuilder get updatedAtGT => _$this._updatedAtGT ??= new GTimeBuilder();
  set updatedAtGT(GTimeBuilder? updatedAtGT) =>
      _$this._updatedAtGT = updatedAtGT;

  GTimeBuilder? _updatedAtGTE;
  GTimeBuilder get updatedAtGTE => _$this._updatedAtGTE ??= new GTimeBuilder();
  set updatedAtGTE(GTimeBuilder? updatedAtGTE) =>
      _$this._updatedAtGTE = updatedAtGTE;

  GTimeBuilder? _updatedAtLT;
  GTimeBuilder get updatedAtLT => _$this._updatedAtLT ??= new GTimeBuilder();
  set updatedAtLT(GTimeBuilder? updatedAtLT) =>
      _$this._updatedAtLT = updatedAtLT;

  GTimeBuilder? _updatedAtLTE;
  GTimeBuilder get updatedAtLTE => _$this._updatedAtLTE ??= new GTimeBuilder();
  set updatedAtLTE(GTimeBuilder? updatedAtLTE) =>
      _$this._updatedAtLTE = updatedAtLTE;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _titleNEQ;
  String? get titleNEQ => _$this._titleNEQ;
  set titleNEQ(String? titleNEQ) => _$this._titleNEQ = titleNEQ;

  ListBuilder<String>? _titleIn;
  ListBuilder<String> get titleIn =>
      _$this._titleIn ??= new ListBuilder<String>();
  set titleIn(ListBuilder<String>? titleIn) => _$this._titleIn = titleIn;

  ListBuilder<String>? _titleNotIn;
  ListBuilder<String> get titleNotIn =>
      _$this._titleNotIn ??= new ListBuilder<String>();
  set titleNotIn(ListBuilder<String>? titleNotIn) =>
      _$this._titleNotIn = titleNotIn;

  String? _titleGT;
  String? get titleGT => _$this._titleGT;
  set titleGT(String? titleGT) => _$this._titleGT = titleGT;

  String? _titleGTE;
  String? get titleGTE => _$this._titleGTE;
  set titleGTE(String? titleGTE) => _$this._titleGTE = titleGTE;

  String? _titleLT;
  String? get titleLT => _$this._titleLT;
  set titleLT(String? titleLT) => _$this._titleLT = titleLT;

  String? _titleLTE;
  String? get titleLTE => _$this._titleLTE;
  set titleLTE(String? titleLTE) => _$this._titleLTE = titleLTE;

  String? _titleContains;
  String? get titleContains => _$this._titleContains;
  set titleContains(String? titleContains) =>
      _$this._titleContains = titleContains;

  String? _titleHasPrefix;
  String? get titleHasPrefix => _$this._titleHasPrefix;
  set titleHasPrefix(String? titleHasPrefix) =>
      _$this._titleHasPrefix = titleHasPrefix;

  String? _titleHasSuffix;
  String? get titleHasSuffix => _$this._titleHasSuffix;
  set titleHasSuffix(String? titleHasSuffix) =>
      _$this._titleHasSuffix = titleHasSuffix;

  String? _titleEqualFold;
  String? get titleEqualFold => _$this._titleEqualFold;
  set titleEqualFold(String? titleEqualFold) =>
      _$this._titleEqualFold = titleEqualFold;

  String? _titleContainsFold;
  String? get titleContainsFold => _$this._titleContainsFold;
  set titleContainsFold(String? titleContainsFold) =>
      _$this._titleContainsFold = titleContainsFold;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _noteNEQ;
  String? get noteNEQ => _$this._noteNEQ;
  set noteNEQ(String? noteNEQ) => _$this._noteNEQ = noteNEQ;

  ListBuilder<String>? _noteIn;
  ListBuilder<String> get noteIn =>
      _$this._noteIn ??= new ListBuilder<String>();
  set noteIn(ListBuilder<String>? noteIn) => _$this._noteIn = noteIn;

  ListBuilder<String>? _noteNotIn;
  ListBuilder<String> get noteNotIn =>
      _$this._noteNotIn ??= new ListBuilder<String>();
  set noteNotIn(ListBuilder<String>? noteNotIn) =>
      _$this._noteNotIn = noteNotIn;

  String? _noteGT;
  String? get noteGT => _$this._noteGT;
  set noteGT(String? noteGT) => _$this._noteGT = noteGT;

  String? _noteGTE;
  String? get noteGTE => _$this._noteGTE;
  set noteGTE(String? noteGTE) => _$this._noteGTE = noteGTE;

  String? _noteLT;
  String? get noteLT => _$this._noteLT;
  set noteLT(String? noteLT) => _$this._noteLT = noteLT;

  String? _noteLTE;
  String? get noteLTE => _$this._noteLTE;
  set noteLTE(String? noteLTE) => _$this._noteLTE = noteLTE;

  String? _noteContains;
  String? get noteContains => _$this._noteContains;
  set noteContains(String? noteContains) => _$this._noteContains = noteContains;

  String? _noteHasPrefix;
  String? get noteHasPrefix => _$this._noteHasPrefix;
  set noteHasPrefix(String? noteHasPrefix) =>
      _$this._noteHasPrefix = noteHasPrefix;

  String? _noteHasSuffix;
  String? get noteHasSuffix => _$this._noteHasSuffix;
  set noteHasSuffix(String? noteHasSuffix) =>
      _$this._noteHasSuffix = noteHasSuffix;

  bool? _noteIsNil;
  bool? get noteIsNil => _$this._noteIsNil;
  set noteIsNil(bool? noteIsNil) => _$this._noteIsNil = noteIsNil;

  bool? _noteNotNil;
  bool? get noteNotNil => _$this._noteNotNil;
  set noteNotNil(bool? noteNotNil) => _$this._noteNotNil = noteNotNil;

  String? _noteEqualFold;
  String? get noteEqualFold => _$this._noteEqualFold;
  set noteEqualFold(String? noteEqualFold) =>
      _$this._noteEqualFold = noteEqualFold;

  String? _noteContainsFold;
  String? get noteContainsFold => _$this._noteContainsFold;
  set noteContainsFold(String? noteContainsFold) =>
      _$this._noteContainsFold = noteContainsFold;

  GTimeBuilder? _targetDate;
  GTimeBuilder get targetDate => _$this._targetDate ??= new GTimeBuilder();
  set targetDate(GTimeBuilder? targetDate) => _$this._targetDate = targetDate;

  GTimeBuilder? _targetDateNEQ;
  GTimeBuilder get targetDateNEQ =>
      _$this._targetDateNEQ ??= new GTimeBuilder();
  set targetDateNEQ(GTimeBuilder? targetDateNEQ) =>
      _$this._targetDateNEQ = targetDateNEQ;

  ListBuilder<GTime>? _targetDateIn;
  ListBuilder<GTime> get targetDateIn =>
      _$this._targetDateIn ??= new ListBuilder<GTime>();
  set targetDateIn(ListBuilder<GTime>? targetDateIn) =>
      _$this._targetDateIn = targetDateIn;

  ListBuilder<GTime>? _targetDateNotIn;
  ListBuilder<GTime> get targetDateNotIn =>
      _$this._targetDateNotIn ??= new ListBuilder<GTime>();
  set targetDateNotIn(ListBuilder<GTime>? targetDateNotIn) =>
      _$this._targetDateNotIn = targetDateNotIn;

  GTimeBuilder? _targetDateGT;
  GTimeBuilder get targetDateGT => _$this._targetDateGT ??= new GTimeBuilder();
  set targetDateGT(GTimeBuilder? targetDateGT) =>
      _$this._targetDateGT = targetDateGT;

  GTimeBuilder? _targetDateGTE;
  GTimeBuilder get targetDateGTE =>
      _$this._targetDateGTE ??= new GTimeBuilder();
  set targetDateGTE(GTimeBuilder? targetDateGTE) =>
      _$this._targetDateGTE = targetDateGTE;

  GTimeBuilder? _targetDateLT;
  GTimeBuilder get targetDateLT => _$this._targetDateLT ??= new GTimeBuilder();
  set targetDateLT(GTimeBuilder? targetDateLT) =>
      _$this._targetDateLT = targetDateLT;

  GTimeBuilder? _targetDateLTE;
  GTimeBuilder get targetDateLTE =>
      _$this._targetDateLTE ??= new GTimeBuilder();
  set targetDateLTE(GTimeBuilder? targetDateLTE) =>
      _$this._targetDateLTE = targetDateLTE;

  bool? _targetDateIsNil;
  bool? get targetDateIsNil => _$this._targetDateIsNil;
  set targetDateIsNil(bool? targetDateIsNil) =>
      _$this._targetDateIsNil = targetDateIsNil;

  bool? _targetDateNotNil;
  bool? get targetDateNotNil => _$this._targetDateNotNil;
  set targetDateNotNil(bool? targetDateNotNil) =>
      _$this._targetDateNotNil = targetDateNotNil;

  GGoalStatus? _status;
  GGoalStatus? get status => _$this._status;
  set status(GGoalStatus? status) => _$this._status = status;

  GGoalStatus? _statusNEQ;
  GGoalStatus? get statusNEQ => _$this._statusNEQ;
  set statusNEQ(GGoalStatus? statusNEQ) => _$this._statusNEQ = statusNEQ;

  ListBuilder<GGoalStatus>? _statusIn;
  ListBuilder<GGoalStatus> get statusIn =>
      _$this._statusIn ??= new ListBuilder<GGoalStatus>();
  set statusIn(ListBuilder<GGoalStatus>? statusIn) =>
      _$this._statusIn = statusIn;

  ListBuilder<GGoalStatus>? _statusNotIn;
  ListBuilder<GGoalStatus> get statusNotIn =>
      _$this._statusNotIn ??= new ListBuilder<GGoalStatus>();
  set statusNotIn(ListBuilder<GGoalStatus>? statusNotIn) =>
      _$this._statusNotIn = statusNotIn;

  bool? _hasUser;
  bool? get hasUser => _$this._hasUser;
  set hasUser(bool? hasUser) => _$this._hasUser = hasUser;

  ListBuilder<GUserWhereInput>? _hasUserWith;
  ListBuilder<GUserWhereInput> get hasUserWith =>
      _$this._hasUserWith ??= new ListBuilder<GUserWhereInput>();
  set hasUserWith(ListBuilder<GUserWhereInput>? hasUserWith) =>
      _$this._hasUserWith = hasUserWith;

  bool? _hasTasks;
  bool? get hasTasks => _$this._hasTasks;
  set hasTasks(bool? hasTasks) => _$this._hasTasks = hasTasks;

  ListBuilder<GTaskWhereInput>? _hasTasksWith;
  ListBuilder<GTaskWhereInput> get hasTasksWith =>
      _$this._hasTasksWith ??= new ListBuilder<GTaskWhereInput>();
  set hasTasksWith(ListBuilder<GTaskWhereInput>? hasTasksWith) =>
      _$this._hasTasksWith = hasTasksWith;

  GGoalWhereInputBuilder();

  GGoalWhereInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _not = $v.not?.toBuilder();
      _and = $v.and?.toBuilder();
      _or = $v.or?.toBuilder();
      _id = $v.id;
      _idNEQ = $v.idNEQ;
      _idIn = $v.idIn?.toBuilder();
      _idNotIn = $v.idNotIn?.toBuilder();
      _idGT = $v.idGT;
      _idGTE = $v.idGTE;
      _idLT = $v.idLT;
      _idLTE = $v.idLTE;
      _createdAt = $v.createdAt?.toBuilder();
      _createdAtNEQ = $v.createdAtNEQ?.toBuilder();
      _createdAtIn = $v.createdAtIn?.toBuilder();
      _createdAtNotIn = $v.createdAtNotIn?.toBuilder();
      _createdAtGT = $v.createdAtGT?.toBuilder();
      _createdAtGTE = $v.createdAtGTE?.toBuilder();
      _createdAtLT = $v.createdAtLT?.toBuilder();
      _createdAtLTE = $v.createdAtLTE?.toBuilder();
      _updatedAt = $v.updatedAt?.toBuilder();
      _updatedAtNEQ = $v.updatedAtNEQ?.toBuilder();
      _updatedAtIn = $v.updatedAtIn?.toBuilder();
      _updatedAtNotIn = $v.updatedAtNotIn?.toBuilder();
      _updatedAtGT = $v.updatedAtGT?.toBuilder();
      _updatedAtGTE = $v.updatedAtGTE?.toBuilder();
      _updatedAtLT = $v.updatedAtLT?.toBuilder();
      _updatedAtLTE = $v.updatedAtLTE?.toBuilder();
      _title = $v.title;
      _titleNEQ = $v.titleNEQ;
      _titleIn = $v.titleIn?.toBuilder();
      _titleNotIn = $v.titleNotIn?.toBuilder();
      _titleGT = $v.titleGT;
      _titleGTE = $v.titleGTE;
      _titleLT = $v.titleLT;
      _titleLTE = $v.titleLTE;
      _titleContains = $v.titleContains;
      _titleHasPrefix = $v.titleHasPrefix;
      _titleHasSuffix = $v.titleHasSuffix;
      _titleEqualFold = $v.titleEqualFold;
      _titleContainsFold = $v.titleContainsFold;
      _note = $v.note;
      _noteNEQ = $v.noteNEQ;
      _noteIn = $v.noteIn?.toBuilder();
      _noteNotIn = $v.noteNotIn?.toBuilder();
      _noteGT = $v.noteGT;
      _noteGTE = $v.noteGTE;
      _noteLT = $v.noteLT;
      _noteLTE = $v.noteLTE;
      _noteContains = $v.noteContains;
      _noteHasPrefix = $v.noteHasPrefix;
      _noteHasSuffix = $v.noteHasSuffix;
      _noteIsNil = $v.noteIsNil;
      _noteNotNil = $v.noteNotNil;
      _noteEqualFold = $v.noteEqualFold;
      _noteContainsFold = $v.noteContainsFold;
      _targetDate = $v.targetDate?.toBuilder();
      _targetDateNEQ = $v.targetDateNEQ?.toBuilder();
      _targetDateIn = $v.targetDateIn?.toBuilder();
      _targetDateNotIn = $v.targetDateNotIn?.toBuilder();
      _targetDateGT = $v.targetDateGT?.toBuilder();
      _targetDateGTE = $v.targetDateGTE?.toBuilder();
      _targetDateLT = $v.targetDateLT?.toBuilder();
      _targetDateLTE = $v.targetDateLTE?.toBuilder();
      _targetDateIsNil = $v.targetDateIsNil;
      _targetDateNotNil = $v.targetDateNotNil;
      _status = $v.status;
      _statusNEQ = $v.statusNEQ;
      _statusIn = $v.statusIn?.toBuilder();
      _statusNotIn = $v.statusNotIn?.toBuilder();
      _hasUser = $v.hasUser;
      _hasUserWith = $v.hasUserWith?.toBuilder();
      _hasTasks = $v.hasTasks;
      _hasTasksWith = $v.hasTasksWith?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGoalWhereInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGoalWhereInput;
  }

  @override
  void update(void Function(GGoalWhereInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGoalWhereInput build() => _build();

  _$GGoalWhereInput _build() {
    _$GGoalWhereInput _$result;
    try {
      _$result = _$v ??
          new _$GGoalWhereInput._(
              not: _not?.build(),
              and: _and?.build(),
              or: _or?.build(),
              id: id,
              idNEQ: idNEQ,
              idIn: _idIn?.build(),
              idNotIn: _idNotIn?.build(),
              idGT: idGT,
              idGTE: idGTE,
              idLT: idLT,
              idLTE: idLTE,
              createdAt: _createdAt?.build(),
              createdAtNEQ: _createdAtNEQ?.build(),
              createdAtIn: _createdAtIn?.build(),
              createdAtNotIn: _createdAtNotIn?.build(),
              createdAtGT: _createdAtGT?.build(),
              createdAtGTE: _createdAtGTE?.build(),
              createdAtLT: _createdAtLT?.build(),
              createdAtLTE: _createdAtLTE?.build(),
              updatedAt: _updatedAt?.build(),
              updatedAtNEQ: _updatedAtNEQ?.build(),
              updatedAtIn: _updatedAtIn?.build(),
              updatedAtNotIn: _updatedAtNotIn?.build(),
              updatedAtGT: _updatedAtGT?.build(),
              updatedAtGTE: _updatedAtGTE?.build(),
              updatedAtLT: _updatedAtLT?.build(),
              updatedAtLTE: _updatedAtLTE?.build(),
              title: title,
              titleNEQ: titleNEQ,
              titleIn: _titleIn?.build(),
              titleNotIn: _titleNotIn?.build(),
              titleGT: titleGT,
              titleGTE: titleGTE,
              titleLT: titleLT,
              titleLTE: titleLTE,
              titleContains: titleContains,
              titleHasPrefix: titleHasPrefix,
              titleHasSuffix: titleHasSuffix,
              titleEqualFold: titleEqualFold,
              titleContainsFold: titleContainsFold,
              note: note,
              noteNEQ: noteNEQ,
              noteIn: _noteIn?.build(),
              noteNotIn: _noteNotIn?.build(),
              noteGT: noteGT,
              noteGTE: noteGTE,
              noteLT: noteLT,
              noteLTE: noteLTE,
              noteContains: noteContains,
              noteHasPrefix: noteHasPrefix,
              noteHasSuffix: noteHasSuffix,
              noteIsNil: noteIsNil,
              noteNotNil: noteNotNil,
              noteEqualFold: noteEqualFold,
              noteContainsFold: noteContainsFold,
              targetDate: _targetDate?.build(),
              targetDateNEQ: _targetDateNEQ?.build(),
              targetDateIn: _targetDateIn?.build(),
              targetDateNotIn: _targetDateNotIn?.build(),
              targetDateGT: _targetDateGT?.build(),
              targetDateGTE: _targetDateGTE?.build(),
              targetDateLT: _targetDateLT?.build(),
              targetDateLTE: _targetDateLTE?.build(),
              targetDateIsNil: targetDateIsNil,
              targetDateNotNil: targetDateNotNil,
              status: status,
              statusNEQ: statusNEQ,
              statusIn: _statusIn?.build(),
              statusNotIn: _statusNotIn?.build(),
              hasUser: hasUser,
              hasUserWith: _hasUserWith?.build(),
              hasTasks: hasTasks,
              hasTasksWith: _hasTasksWith?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'not';
        _not?.build();
        _$failedField = 'and';
        _and?.build();
        _$failedField = 'or';
        _or?.build();

        _$failedField = 'idIn';
        _idIn?.build();
        _$failedField = 'idNotIn';
        _idNotIn?.build();

        _$failedField = 'createdAt';
        _createdAt?.build();
        _$failedField = 'createdAtNEQ';
        _createdAtNEQ?.build();
        _$failedField = 'createdAtIn';
        _createdAtIn?.build();
        _$failedField = 'createdAtNotIn';
        _createdAtNotIn?.build();
        _$failedField = 'createdAtGT';
        _createdAtGT?.build();
        _$failedField = 'createdAtGTE';
        _createdAtGTE?.build();
        _$failedField = 'createdAtLT';
        _createdAtLT?.build();
        _$failedField = 'createdAtLTE';
        _createdAtLTE?.build();
        _$failedField = 'updatedAt';
        _updatedAt?.build();
        _$failedField = 'updatedAtNEQ';
        _updatedAtNEQ?.build();
        _$failedField = 'updatedAtIn';
        _updatedAtIn?.build();
        _$failedField = 'updatedAtNotIn';
        _updatedAtNotIn?.build();
        _$failedField = 'updatedAtGT';
        _updatedAtGT?.build();
        _$failedField = 'updatedAtGTE';
        _updatedAtGTE?.build();
        _$failedField = 'updatedAtLT';
        _updatedAtLT?.build();
        _$failedField = 'updatedAtLTE';
        _updatedAtLTE?.build();

        _$failedField = 'titleIn';
        _titleIn?.build();
        _$failedField = 'titleNotIn';
        _titleNotIn?.build();

        _$failedField = 'noteIn';
        _noteIn?.build();
        _$failedField = 'noteNotIn';
        _noteNotIn?.build();

        _$failedField = 'targetDate';
        _targetDate?.build();
        _$failedField = 'targetDateNEQ';
        _targetDateNEQ?.build();
        _$failedField = 'targetDateIn';
        _targetDateIn?.build();
        _$failedField = 'targetDateNotIn';
        _targetDateNotIn?.build();
        _$failedField = 'targetDateGT';
        _targetDateGT?.build();
        _$failedField = 'targetDateGTE';
        _targetDateGTE?.build();
        _$failedField = 'targetDateLT';
        _targetDateLT?.build();
        _$failedField = 'targetDateLTE';
        _targetDateLTE?.build();

        _$failedField = 'statusIn';
        _statusIn?.build();
        _$failedField = 'statusNotIn';
        _statusNotIn?.build();

        _$failedField = 'hasUserWith';
        _hasUserWith?.build();

        _$failedField = 'hasTasksWith';
        _hasTasksWith?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GGoalWhereInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GInterestWhereInput extends GInterestWhereInput {
  @override
  final GInterestWhereInput? not;
  @override
  final BuiltList<GInterestWhereInput>? and;
  @override
  final BuiltList<GInterestWhereInput>? or;
  @override
  final String? id;
  @override
  final String? idNEQ;
  @override
  final BuiltList<String>? idIn;
  @override
  final BuiltList<String>? idNotIn;
  @override
  final String? idGT;
  @override
  final String? idGTE;
  @override
  final String? idLT;
  @override
  final String? idLTE;
  @override
  final String? name;
  @override
  final String? nameNEQ;
  @override
  final BuiltList<String>? nameIn;
  @override
  final BuiltList<String>? nameNotIn;
  @override
  final String? nameGT;
  @override
  final String? nameGTE;
  @override
  final String? nameLT;
  @override
  final String? nameLTE;
  @override
  final String? nameContains;
  @override
  final String? nameHasPrefix;
  @override
  final String? nameHasSuffix;
  @override
  final String? nameEqualFold;
  @override
  final String? nameContainsFold;
  @override
  final bool? hasUsers;
  @override
  final BuiltList<GUserWhereInput>? hasUsersWith;

  factory _$GInterestWhereInput(
          [void Function(GInterestWhereInputBuilder)? updates]) =>
      (new GInterestWhereInputBuilder()..update(updates))._build();

  _$GInterestWhereInput._(
      {this.not,
      this.and,
      this.or,
      this.id,
      this.idNEQ,
      this.idIn,
      this.idNotIn,
      this.idGT,
      this.idGTE,
      this.idLT,
      this.idLTE,
      this.name,
      this.nameNEQ,
      this.nameIn,
      this.nameNotIn,
      this.nameGT,
      this.nameGTE,
      this.nameLT,
      this.nameLTE,
      this.nameContains,
      this.nameHasPrefix,
      this.nameHasSuffix,
      this.nameEqualFold,
      this.nameContainsFold,
      this.hasUsers,
      this.hasUsersWith})
      : super._();

  @override
  GInterestWhereInput rebuild(
          void Function(GInterestWhereInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GInterestWhereInputBuilder toBuilder() =>
      new GInterestWhereInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GInterestWhereInput &&
        not == other.not &&
        and == other.and &&
        or == other.or &&
        id == other.id &&
        idNEQ == other.idNEQ &&
        idIn == other.idIn &&
        idNotIn == other.idNotIn &&
        idGT == other.idGT &&
        idGTE == other.idGTE &&
        idLT == other.idLT &&
        idLTE == other.idLTE &&
        name == other.name &&
        nameNEQ == other.nameNEQ &&
        nameIn == other.nameIn &&
        nameNotIn == other.nameNotIn &&
        nameGT == other.nameGT &&
        nameGTE == other.nameGTE &&
        nameLT == other.nameLT &&
        nameLTE == other.nameLTE &&
        nameContains == other.nameContains &&
        nameHasPrefix == other.nameHasPrefix &&
        nameHasSuffix == other.nameHasSuffix &&
        nameEqualFold == other.nameEqualFold &&
        nameContainsFold == other.nameContainsFold &&
        hasUsers == other.hasUsers &&
        hasUsersWith == other.hasUsersWith;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, not.hashCode);
    _$hash = $jc(_$hash, and.hashCode);
    _$hash = $jc(_$hash, or.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idNEQ.hashCode);
    _$hash = $jc(_$hash, idIn.hashCode);
    _$hash = $jc(_$hash, idNotIn.hashCode);
    _$hash = $jc(_$hash, idGT.hashCode);
    _$hash = $jc(_$hash, idGTE.hashCode);
    _$hash = $jc(_$hash, idLT.hashCode);
    _$hash = $jc(_$hash, idLTE.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameNEQ.hashCode);
    _$hash = $jc(_$hash, nameIn.hashCode);
    _$hash = $jc(_$hash, nameNotIn.hashCode);
    _$hash = $jc(_$hash, nameGT.hashCode);
    _$hash = $jc(_$hash, nameGTE.hashCode);
    _$hash = $jc(_$hash, nameLT.hashCode);
    _$hash = $jc(_$hash, nameLTE.hashCode);
    _$hash = $jc(_$hash, nameContains.hashCode);
    _$hash = $jc(_$hash, nameHasPrefix.hashCode);
    _$hash = $jc(_$hash, nameHasSuffix.hashCode);
    _$hash = $jc(_$hash, nameEqualFold.hashCode);
    _$hash = $jc(_$hash, nameContainsFold.hashCode);
    _$hash = $jc(_$hash, hasUsers.hashCode);
    _$hash = $jc(_$hash, hasUsersWith.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GInterestWhereInput')
          ..add('not', not)
          ..add('and', and)
          ..add('or', or)
          ..add('id', id)
          ..add('idNEQ', idNEQ)
          ..add('idIn', idIn)
          ..add('idNotIn', idNotIn)
          ..add('idGT', idGT)
          ..add('idGTE', idGTE)
          ..add('idLT', idLT)
          ..add('idLTE', idLTE)
          ..add('name', name)
          ..add('nameNEQ', nameNEQ)
          ..add('nameIn', nameIn)
          ..add('nameNotIn', nameNotIn)
          ..add('nameGT', nameGT)
          ..add('nameGTE', nameGTE)
          ..add('nameLT', nameLT)
          ..add('nameLTE', nameLTE)
          ..add('nameContains', nameContains)
          ..add('nameHasPrefix', nameHasPrefix)
          ..add('nameHasSuffix', nameHasSuffix)
          ..add('nameEqualFold', nameEqualFold)
          ..add('nameContainsFold', nameContainsFold)
          ..add('hasUsers', hasUsers)
          ..add('hasUsersWith', hasUsersWith))
        .toString();
  }
}

class GInterestWhereInputBuilder
    implements Builder<GInterestWhereInput, GInterestWhereInputBuilder> {
  _$GInterestWhereInput? _$v;

  GInterestWhereInputBuilder? _not;
  GInterestWhereInputBuilder get not =>
      _$this._not ??= new GInterestWhereInputBuilder();
  set not(GInterestWhereInputBuilder? not) => _$this._not = not;

  ListBuilder<GInterestWhereInput>? _and;
  ListBuilder<GInterestWhereInput> get and =>
      _$this._and ??= new ListBuilder<GInterestWhereInput>();
  set and(ListBuilder<GInterestWhereInput>? and) => _$this._and = and;

  ListBuilder<GInterestWhereInput>? _or;
  ListBuilder<GInterestWhereInput> get or =>
      _$this._or ??= new ListBuilder<GInterestWhereInput>();
  set or(ListBuilder<GInterestWhereInput>? or) => _$this._or = or;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _idNEQ;
  String? get idNEQ => _$this._idNEQ;
  set idNEQ(String? idNEQ) => _$this._idNEQ = idNEQ;

  ListBuilder<String>? _idIn;
  ListBuilder<String> get idIn => _$this._idIn ??= new ListBuilder<String>();
  set idIn(ListBuilder<String>? idIn) => _$this._idIn = idIn;

  ListBuilder<String>? _idNotIn;
  ListBuilder<String> get idNotIn =>
      _$this._idNotIn ??= new ListBuilder<String>();
  set idNotIn(ListBuilder<String>? idNotIn) => _$this._idNotIn = idNotIn;

  String? _idGT;
  String? get idGT => _$this._idGT;
  set idGT(String? idGT) => _$this._idGT = idGT;

  String? _idGTE;
  String? get idGTE => _$this._idGTE;
  set idGTE(String? idGTE) => _$this._idGTE = idGTE;

  String? _idLT;
  String? get idLT => _$this._idLT;
  set idLT(String? idLT) => _$this._idLT = idLT;

  String? _idLTE;
  String? get idLTE => _$this._idLTE;
  set idLTE(String? idLTE) => _$this._idLTE = idLTE;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameNEQ;
  String? get nameNEQ => _$this._nameNEQ;
  set nameNEQ(String? nameNEQ) => _$this._nameNEQ = nameNEQ;

  ListBuilder<String>? _nameIn;
  ListBuilder<String> get nameIn =>
      _$this._nameIn ??= new ListBuilder<String>();
  set nameIn(ListBuilder<String>? nameIn) => _$this._nameIn = nameIn;

  ListBuilder<String>? _nameNotIn;
  ListBuilder<String> get nameNotIn =>
      _$this._nameNotIn ??= new ListBuilder<String>();
  set nameNotIn(ListBuilder<String>? nameNotIn) =>
      _$this._nameNotIn = nameNotIn;

  String? _nameGT;
  String? get nameGT => _$this._nameGT;
  set nameGT(String? nameGT) => _$this._nameGT = nameGT;

  String? _nameGTE;
  String? get nameGTE => _$this._nameGTE;
  set nameGTE(String? nameGTE) => _$this._nameGTE = nameGTE;

  String? _nameLT;
  String? get nameLT => _$this._nameLT;
  set nameLT(String? nameLT) => _$this._nameLT = nameLT;

  String? _nameLTE;
  String? get nameLTE => _$this._nameLTE;
  set nameLTE(String? nameLTE) => _$this._nameLTE = nameLTE;

  String? _nameContains;
  String? get nameContains => _$this._nameContains;
  set nameContains(String? nameContains) => _$this._nameContains = nameContains;

  String? _nameHasPrefix;
  String? get nameHasPrefix => _$this._nameHasPrefix;
  set nameHasPrefix(String? nameHasPrefix) =>
      _$this._nameHasPrefix = nameHasPrefix;

  String? _nameHasSuffix;
  String? get nameHasSuffix => _$this._nameHasSuffix;
  set nameHasSuffix(String? nameHasSuffix) =>
      _$this._nameHasSuffix = nameHasSuffix;

  String? _nameEqualFold;
  String? get nameEqualFold => _$this._nameEqualFold;
  set nameEqualFold(String? nameEqualFold) =>
      _$this._nameEqualFold = nameEqualFold;

  String? _nameContainsFold;
  String? get nameContainsFold => _$this._nameContainsFold;
  set nameContainsFold(String? nameContainsFold) =>
      _$this._nameContainsFold = nameContainsFold;

  bool? _hasUsers;
  bool? get hasUsers => _$this._hasUsers;
  set hasUsers(bool? hasUsers) => _$this._hasUsers = hasUsers;

  ListBuilder<GUserWhereInput>? _hasUsersWith;
  ListBuilder<GUserWhereInput> get hasUsersWith =>
      _$this._hasUsersWith ??= new ListBuilder<GUserWhereInput>();
  set hasUsersWith(ListBuilder<GUserWhereInput>? hasUsersWith) =>
      _$this._hasUsersWith = hasUsersWith;

  GInterestWhereInputBuilder();

  GInterestWhereInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _not = $v.not?.toBuilder();
      _and = $v.and?.toBuilder();
      _or = $v.or?.toBuilder();
      _id = $v.id;
      _idNEQ = $v.idNEQ;
      _idIn = $v.idIn?.toBuilder();
      _idNotIn = $v.idNotIn?.toBuilder();
      _idGT = $v.idGT;
      _idGTE = $v.idGTE;
      _idLT = $v.idLT;
      _idLTE = $v.idLTE;
      _name = $v.name;
      _nameNEQ = $v.nameNEQ;
      _nameIn = $v.nameIn?.toBuilder();
      _nameNotIn = $v.nameNotIn?.toBuilder();
      _nameGT = $v.nameGT;
      _nameGTE = $v.nameGTE;
      _nameLT = $v.nameLT;
      _nameLTE = $v.nameLTE;
      _nameContains = $v.nameContains;
      _nameHasPrefix = $v.nameHasPrefix;
      _nameHasSuffix = $v.nameHasSuffix;
      _nameEqualFold = $v.nameEqualFold;
      _nameContainsFold = $v.nameContainsFold;
      _hasUsers = $v.hasUsers;
      _hasUsersWith = $v.hasUsersWith?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GInterestWhereInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GInterestWhereInput;
  }

  @override
  void update(void Function(GInterestWhereInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GInterestWhereInput build() => _build();

  _$GInterestWhereInput _build() {
    _$GInterestWhereInput _$result;
    try {
      _$result = _$v ??
          new _$GInterestWhereInput._(
              not: _not?.build(),
              and: _and?.build(),
              or: _or?.build(),
              id: id,
              idNEQ: idNEQ,
              idIn: _idIn?.build(),
              idNotIn: _idNotIn?.build(),
              idGT: idGT,
              idGTE: idGTE,
              idLT: idLT,
              idLTE: idLTE,
              name: name,
              nameNEQ: nameNEQ,
              nameIn: _nameIn?.build(),
              nameNotIn: _nameNotIn?.build(),
              nameGT: nameGT,
              nameGTE: nameGTE,
              nameLT: nameLT,
              nameLTE: nameLTE,
              nameContains: nameContains,
              nameHasPrefix: nameHasPrefix,
              nameHasSuffix: nameHasSuffix,
              nameEqualFold: nameEqualFold,
              nameContainsFold: nameContainsFold,
              hasUsers: hasUsers,
              hasUsersWith: _hasUsersWith?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'not';
        _not?.build();
        _$failedField = 'and';
        _and?.build();
        _$failedField = 'or';
        _or?.build();

        _$failedField = 'idIn';
        _idIn?.build();
        _$failedField = 'idNotIn';
        _idNotIn?.build();

        _$failedField = 'nameIn';
        _nameIn?.build();
        _$failedField = 'nameNotIn';
        _nameNotIn?.build();

        _$failedField = 'hasUsersWith';
        _hasUsersWith?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GInterestWhereInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendOTPInput extends GSendOTPInput {
  @override
  final String phoneNumber;

  factory _$GSendOTPInput([void Function(GSendOTPInputBuilder)? updates]) =>
      (new GSendOTPInputBuilder()..update(updates))._build();

  _$GSendOTPInput._({required this.phoneNumber}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        phoneNumber, r'GSendOTPInput', 'phoneNumber');
  }

  @override
  GSendOTPInput rebuild(void Function(GSendOTPInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendOTPInputBuilder toBuilder() => new GSendOTPInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendOTPInput && phoneNumber == other.phoneNumber;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phoneNumber.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendOTPInput')
          ..add('phoneNumber', phoneNumber))
        .toString();
  }
}

class GSendOTPInputBuilder
    implements Builder<GSendOTPInput, GSendOTPInputBuilder> {
  _$GSendOTPInput? _$v;

  String? _phoneNumber;
  String? get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String? phoneNumber) => _$this._phoneNumber = phoneNumber;

  GSendOTPInputBuilder();

  GSendOTPInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phoneNumber = $v.phoneNumber;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendOTPInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendOTPInput;
  }

  @override
  void update(void Function(GSendOTPInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendOTPInput build() => _build();

  _$GSendOTPInput _build() {
    final _$result = _$v ??
        new _$GSendOTPInput._(
            phoneNumber: BuiltValueNullFieldError.checkNotNull(
                phoneNumber, r'GSendOTPInput', 'phoneNumber'));
    replace(_$result);
    return _$result;
  }
}

class _$GRefreshTokenInput extends GRefreshTokenInput {
  @override
  final String refreshToken;

  factory _$GRefreshTokenInput(
          [void Function(GRefreshTokenInputBuilder)? updates]) =>
      (new GRefreshTokenInputBuilder()..update(updates))._build();

  _$GRefreshTokenInput._({required this.refreshToken}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        refreshToken, r'GRefreshTokenInput', 'refreshToken');
  }

  @override
  GRefreshTokenInput rebuild(
          void Function(GRefreshTokenInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRefreshTokenInputBuilder toBuilder() =>
      new GRefreshTokenInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRefreshTokenInput && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRefreshTokenInput')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class GRefreshTokenInputBuilder
    implements Builder<GRefreshTokenInput, GRefreshTokenInputBuilder> {
  _$GRefreshTokenInput? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GRefreshTokenInputBuilder();

  GRefreshTokenInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRefreshTokenInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GRefreshTokenInput;
  }

  @override
  void update(void Function(GRefreshTokenInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRefreshTokenInput build() => _build();

  _$GRefreshTokenInput _build() {
    final _$result = _$v ??
        new _$GRefreshTokenInput._(
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'GRefreshTokenInput', 'refreshToken'));
    replace(_$result);
    return _$result;
  }
}

class _$GTagWhereInput extends GTagWhereInput {
  @override
  final GTagWhereInput? not;
  @override
  final BuiltList<GTagWhereInput>? and;
  @override
  final BuiltList<GTagWhereInput>? or;
  @override
  final String? id;
  @override
  final String? idNEQ;
  @override
  final BuiltList<String>? idIn;
  @override
  final BuiltList<String>? idNotIn;
  @override
  final String? idGT;
  @override
  final String? idGTE;
  @override
  final String? idLT;
  @override
  final String? idLTE;
  @override
  final String? name;
  @override
  final String? nameNEQ;
  @override
  final BuiltList<String>? nameIn;
  @override
  final BuiltList<String>? nameNotIn;
  @override
  final String? nameGT;
  @override
  final String? nameGTE;
  @override
  final String? nameLT;
  @override
  final String? nameLTE;
  @override
  final String? nameContains;
  @override
  final String? nameHasPrefix;
  @override
  final String? nameHasSuffix;
  @override
  final String? nameEqualFold;
  @override
  final String? nameContainsFold;
  @override
  final bool? hasTasks;
  @override
  final BuiltList<GTaskWhereInput>? hasTasksWith;

  factory _$GTagWhereInput([void Function(GTagWhereInputBuilder)? updates]) =>
      (new GTagWhereInputBuilder()..update(updates))._build();

  _$GTagWhereInput._(
      {this.not,
      this.and,
      this.or,
      this.id,
      this.idNEQ,
      this.idIn,
      this.idNotIn,
      this.idGT,
      this.idGTE,
      this.idLT,
      this.idLTE,
      this.name,
      this.nameNEQ,
      this.nameIn,
      this.nameNotIn,
      this.nameGT,
      this.nameGTE,
      this.nameLT,
      this.nameLTE,
      this.nameContains,
      this.nameHasPrefix,
      this.nameHasSuffix,
      this.nameEqualFold,
      this.nameContainsFold,
      this.hasTasks,
      this.hasTasksWith})
      : super._();

  @override
  GTagWhereInput rebuild(void Function(GTagWhereInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTagWhereInputBuilder toBuilder() =>
      new GTagWhereInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTagWhereInput &&
        not == other.not &&
        and == other.and &&
        or == other.or &&
        id == other.id &&
        idNEQ == other.idNEQ &&
        idIn == other.idIn &&
        idNotIn == other.idNotIn &&
        idGT == other.idGT &&
        idGTE == other.idGTE &&
        idLT == other.idLT &&
        idLTE == other.idLTE &&
        name == other.name &&
        nameNEQ == other.nameNEQ &&
        nameIn == other.nameIn &&
        nameNotIn == other.nameNotIn &&
        nameGT == other.nameGT &&
        nameGTE == other.nameGTE &&
        nameLT == other.nameLT &&
        nameLTE == other.nameLTE &&
        nameContains == other.nameContains &&
        nameHasPrefix == other.nameHasPrefix &&
        nameHasSuffix == other.nameHasSuffix &&
        nameEqualFold == other.nameEqualFold &&
        nameContainsFold == other.nameContainsFold &&
        hasTasks == other.hasTasks &&
        hasTasksWith == other.hasTasksWith;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, not.hashCode);
    _$hash = $jc(_$hash, and.hashCode);
    _$hash = $jc(_$hash, or.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idNEQ.hashCode);
    _$hash = $jc(_$hash, idIn.hashCode);
    _$hash = $jc(_$hash, idNotIn.hashCode);
    _$hash = $jc(_$hash, idGT.hashCode);
    _$hash = $jc(_$hash, idGTE.hashCode);
    _$hash = $jc(_$hash, idLT.hashCode);
    _$hash = $jc(_$hash, idLTE.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, nameNEQ.hashCode);
    _$hash = $jc(_$hash, nameIn.hashCode);
    _$hash = $jc(_$hash, nameNotIn.hashCode);
    _$hash = $jc(_$hash, nameGT.hashCode);
    _$hash = $jc(_$hash, nameGTE.hashCode);
    _$hash = $jc(_$hash, nameLT.hashCode);
    _$hash = $jc(_$hash, nameLTE.hashCode);
    _$hash = $jc(_$hash, nameContains.hashCode);
    _$hash = $jc(_$hash, nameHasPrefix.hashCode);
    _$hash = $jc(_$hash, nameHasSuffix.hashCode);
    _$hash = $jc(_$hash, nameEqualFold.hashCode);
    _$hash = $jc(_$hash, nameContainsFold.hashCode);
    _$hash = $jc(_$hash, hasTasks.hashCode);
    _$hash = $jc(_$hash, hasTasksWith.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTagWhereInput')
          ..add('not', not)
          ..add('and', and)
          ..add('or', or)
          ..add('id', id)
          ..add('idNEQ', idNEQ)
          ..add('idIn', idIn)
          ..add('idNotIn', idNotIn)
          ..add('idGT', idGT)
          ..add('idGTE', idGTE)
          ..add('idLT', idLT)
          ..add('idLTE', idLTE)
          ..add('name', name)
          ..add('nameNEQ', nameNEQ)
          ..add('nameIn', nameIn)
          ..add('nameNotIn', nameNotIn)
          ..add('nameGT', nameGT)
          ..add('nameGTE', nameGTE)
          ..add('nameLT', nameLT)
          ..add('nameLTE', nameLTE)
          ..add('nameContains', nameContains)
          ..add('nameHasPrefix', nameHasPrefix)
          ..add('nameHasSuffix', nameHasSuffix)
          ..add('nameEqualFold', nameEqualFold)
          ..add('nameContainsFold', nameContainsFold)
          ..add('hasTasks', hasTasks)
          ..add('hasTasksWith', hasTasksWith))
        .toString();
  }
}

class GTagWhereInputBuilder
    implements Builder<GTagWhereInput, GTagWhereInputBuilder> {
  _$GTagWhereInput? _$v;

  GTagWhereInputBuilder? _not;
  GTagWhereInputBuilder get not => _$this._not ??= new GTagWhereInputBuilder();
  set not(GTagWhereInputBuilder? not) => _$this._not = not;

  ListBuilder<GTagWhereInput>? _and;
  ListBuilder<GTagWhereInput> get and =>
      _$this._and ??= new ListBuilder<GTagWhereInput>();
  set and(ListBuilder<GTagWhereInput>? and) => _$this._and = and;

  ListBuilder<GTagWhereInput>? _or;
  ListBuilder<GTagWhereInput> get or =>
      _$this._or ??= new ListBuilder<GTagWhereInput>();
  set or(ListBuilder<GTagWhereInput>? or) => _$this._or = or;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _idNEQ;
  String? get idNEQ => _$this._idNEQ;
  set idNEQ(String? idNEQ) => _$this._idNEQ = idNEQ;

  ListBuilder<String>? _idIn;
  ListBuilder<String> get idIn => _$this._idIn ??= new ListBuilder<String>();
  set idIn(ListBuilder<String>? idIn) => _$this._idIn = idIn;

  ListBuilder<String>? _idNotIn;
  ListBuilder<String> get idNotIn =>
      _$this._idNotIn ??= new ListBuilder<String>();
  set idNotIn(ListBuilder<String>? idNotIn) => _$this._idNotIn = idNotIn;

  String? _idGT;
  String? get idGT => _$this._idGT;
  set idGT(String? idGT) => _$this._idGT = idGT;

  String? _idGTE;
  String? get idGTE => _$this._idGTE;
  set idGTE(String? idGTE) => _$this._idGTE = idGTE;

  String? _idLT;
  String? get idLT => _$this._idLT;
  set idLT(String? idLT) => _$this._idLT = idLT;

  String? _idLTE;
  String? get idLTE => _$this._idLTE;
  set idLTE(String? idLTE) => _$this._idLTE = idLTE;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _nameNEQ;
  String? get nameNEQ => _$this._nameNEQ;
  set nameNEQ(String? nameNEQ) => _$this._nameNEQ = nameNEQ;

  ListBuilder<String>? _nameIn;
  ListBuilder<String> get nameIn =>
      _$this._nameIn ??= new ListBuilder<String>();
  set nameIn(ListBuilder<String>? nameIn) => _$this._nameIn = nameIn;

  ListBuilder<String>? _nameNotIn;
  ListBuilder<String> get nameNotIn =>
      _$this._nameNotIn ??= new ListBuilder<String>();
  set nameNotIn(ListBuilder<String>? nameNotIn) =>
      _$this._nameNotIn = nameNotIn;

  String? _nameGT;
  String? get nameGT => _$this._nameGT;
  set nameGT(String? nameGT) => _$this._nameGT = nameGT;

  String? _nameGTE;
  String? get nameGTE => _$this._nameGTE;
  set nameGTE(String? nameGTE) => _$this._nameGTE = nameGTE;

  String? _nameLT;
  String? get nameLT => _$this._nameLT;
  set nameLT(String? nameLT) => _$this._nameLT = nameLT;

  String? _nameLTE;
  String? get nameLTE => _$this._nameLTE;
  set nameLTE(String? nameLTE) => _$this._nameLTE = nameLTE;

  String? _nameContains;
  String? get nameContains => _$this._nameContains;
  set nameContains(String? nameContains) => _$this._nameContains = nameContains;

  String? _nameHasPrefix;
  String? get nameHasPrefix => _$this._nameHasPrefix;
  set nameHasPrefix(String? nameHasPrefix) =>
      _$this._nameHasPrefix = nameHasPrefix;

  String? _nameHasSuffix;
  String? get nameHasSuffix => _$this._nameHasSuffix;
  set nameHasSuffix(String? nameHasSuffix) =>
      _$this._nameHasSuffix = nameHasSuffix;

  String? _nameEqualFold;
  String? get nameEqualFold => _$this._nameEqualFold;
  set nameEqualFold(String? nameEqualFold) =>
      _$this._nameEqualFold = nameEqualFold;

  String? _nameContainsFold;
  String? get nameContainsFold => _$this._nameContainsFold;
  set nameContainsFold(String? nameContainsFold) =>
      _$this._nameContainsFold = nameContainsFold;

  bool? _hasTasks;
  bool? get hasTasks => _$this._hasTasks;
  set hasTasks(bool? hasTasks) => _$this._hasTasks = hasTasks;

  ListBuilder<GTaskWhereInput>? _hasTasksWith;
  ListBuilder<GTaskWhereInput> get hasTasksWith =>
      _$this._hasTasksWith ??= new ListBuilder<GTaskWhereInput>();
  set hasTasksWith(ListBuilder<GTaskWhereInput>? hasTasksWith) =>
      _$this._hasTasksWith = hasTasksWith;

  GTagWhereInputBuilder();

  GTagWhereInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _not = $v.not?.toBuilder();
      _and = $v.and?.toBuilder();
      _or = $v.or?.toBuilder();
      _id = $v.id;
      _idNEQ = $v.idNEQ;
      _idIn = $v.idIn?.toBuilder();
      _idNotIn = $v.idNotIn?.toBuilder();
      _idGT = $v.idGT;
      _idGTE = $v.idGTE;
      _idLT = $v.idLT;
      _idLTE = $v.idLTE;
      _name = $v.name;
      _nameNEQ = $v.nameNEQ;
      _nameIn = $v.nameIn?.toBuilder();
      _nameNotIn = $v.nameNotIn?.toBuilder();
      _nameGT = $v.nameGT;
      _nameGTE = $v.nameGTE;
      _nameLT = $v.nameLT;
      _nameLTE = $v.nameLTE;
      _nameContains = $v.nameContains;
      _nameHasPrefix = $v.nameHasPrefix;
      _nameHasSuffix = $v.nameHasSuffix;
      _nameEqualFold = $v.nameEqualFold;
      _nameContainsFold = $v.nameContainsFold;
      _hasTasks = $v.hasTasks;
      _hasTasksWith = $v.hasTasksWith?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTagWhereInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GTagWhereInput;
  }

  @override
  void update(void Function(GTagWhereInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTagWhereInput build() => _build();

  _$GTagWhereInput _build() {
    _$GTagWhereInput _$result;
    try {
      _$result = _$v ??
          new _$GTagWhereInput._(
              not: _not?.build(),
              and: _and?.build(),
              or: _or?.build(),
              id: id,
              idNEQ: idNEQ,
              idIn: _idIn?.build(),
              idNotIn: _idNotIn?.build(),
              idGT: idGT,
              idGTE: idGTE,
              idLT: idLT,
              idLTE: idLTE,
              name: name,
              nameNEQ: nameNEQ,
              nameIn: _nameIn?.build(),
              nameNotIn: _nameNotIn?.build(),
              nameGT: nameGT,
              nameGTE: nameGTE,
              nameLT: nameLT,
              nameLTE: nameLTE,
              nameContains: nameContains,
              nameHasPrefix: nameHasPrefix,
              nameHasSuffix: nameHasSuffix,
              nameEqualFold: nameEqualFold,
              nameContainsFold: nameContainsFold,
              hasTasks: hasTasks,
              hasTasksWith: _hasTasksWith?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'not';
        _not?.build();
        _$failedField = 'and';
        _and?.build();
        _$failedField = 'or';
        _or?.build();

        _$failedField = 'idIn';
        _idIn?.build();
        _$failedField = 'idNotIn';
        _idNotIn?.build();

        _$failedField = 'nameIn';
        _nameIn?.build();
        _$failedField = 'nameNotIn';
        _nameNotIn?.build();

        _$failedField = 'hasTasksWith';
        _hasTasksWith?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GTagWhereInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GTaskOrder extends GTaskOrder {
  @override
  final GOrderDirection direction;
  @override
  final GTaskOrderField field;

  factory _$GTaskOrder([void Function(GTaskOrderBuilder)? updates]) =>
      (new GTaskOrderBuilder()..update(updates))._build();

  _$GTaskOrder._({required this.direction, required this.field}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        direction, r'GTaskOrder', 'direction');
    BuiltValueNullFieldError.checkNotNull(field, r'GTaskOrder', 'field');
  }

  @override
  GTaskOrder rebuild(void Function(GTaskOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskOrderBuilder toBuilder() => new GTaskOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskOrder &&
        direction == other.direction &&
        field == other.field;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskOrder')
          ..add('direction', direction)
          ..add('field', field))
        .toString();
  }
}

class GTaskOrderBuilder implements Builder<GTaskOrder, GTaskOrderBuilder> {
  _$GTaskOrder? _$v;

  GOrderDirection? _direction;
  GOrderDirection? get direction => _$this._direction;
  set direction(GOrderDirection? direction) => _$this._direction = direction;

  GTaskOrderField? _field;
  GTaskOrderField? get field => _$this._field;
  set field(GTaskOrderField? field) => _$this._field = field;

  GTaskOrderBuilder();

  GTaskOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _field = $v.field;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskOrder other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GTaskOrder;
  }

  @override
  void update(void Function(GTaskOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskOrder build() => _build();

  _$GTaskOrder _build() {
    final _$result = _$v ??
        new _$GTaskOrder._(
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'GTaskOrder', 'direction'),
            field: BuiltValueNullFieldError.checkNotNull(
                field, r'GTaskOrder', 'field'));
    replace(_$result);
    return _$result;
  }
}

class _$GTaskWhereInput extends GTaskWhereInput {
  @override
  final GTaskWhereInput? not;
  @override
  final BuiltList<GTaskWhereInput>? and;
  @override
  final BuiltList<GTaskWhereInput>? or;
  @override
  final String? id;
  @override
  final String? idNEQ;
  @override
  final BuiltList<String>? idIn;
  @override
  final BuiltList<String>? idNotIn;
  @override
  final String? idGT;
  @override
  final String? idGTE;
  @override
  final String? idLT;
  @override
  final String? idLTE;
  @override
  final GTime? createdAt;
  @override
  final GTime? createdAtNEQ;
  @override
  final BuiltList<GTime>? createdAtIn;
  @override
  final BuiltList<GTime>? createdAtNotIn;
  @override
  final GTime? createdAtGT;
  @override
  final GTime? createdAtGTE;
  @override
  final GTime? createdAtLT;
  @override
  final GTime? createdAtLTE;
  @override
  final GTime? updatedAt;
  @override
  final GTime? updatedAtNEQ;
  @override
  final BuiltList<GTime>? updatedAtIn;
  @override
  final BuiltList<GTime>? updatedAtNotIn;
  @override
  final GTime? updatedAtGT;
  @override
  final GTime? updatedAtGTE;
  @override
  final GTime? updatedAtLT;
  @override
  final GTime? updatedAtLTE;
  @override
  final String? title;
  @override
  final String? titleNEQ;
  @override
  final BuiltList<String>? titleIn;
  @override
  final BuiltList<String>? titleNotIn;
  @override
  final String? titleGT;
  @override
  final String? titleGTE;
  @override
  final String? titleLT;
  @override
  final String? titleLTE;
  @override
  final String? titleContains;
  @override
  final String? titleHasPrefix;
  @override
  final String? titleHasSuffix;
  @override
  final String? titleEqualFold;
  @override
  final String? titleContainsFold;
  @override
  final String? shortDescription;
  @override
  final String? shortDescriptionNEQ;
  @override
  final BuiltList<String>? shortDescriptionIn;
  @override
  final BuiltList<String>? shortDescriptionNotIn;
  @override
  final String? shortDescriptionGT;
  @override
  final String? shortDescriptionGTE;
  @override
  final String? shortDescriptionLT;
  @override
  final String? shortDescriptionLTE;
  @override
  final String? shortDescriptionContains;
  @override
  final String? shortDescriptionHasPrefix;
  @override
  final String? shortDescriptionHasSuffix;
  @override
  final bool? shortDescriptionIsNil;
  @override
  final bool? shortDescriptionNotNil;
  @override
  final String? shortDescriptionEqualFold;
  @override
  final String? shortDescriptionContainsFold;
  @override
  final String? note;
  @override
  final String? noteNEQ;
  @override
  final BuiltList<String>? noteIn;
  @override
  final BuiltList<String>? noteNotIn;
  @override
  final String? noteGT;
  @override
  final String? noteGTE;
  @override
  final String? noteLT;
  @override
  final String? noteLTE;
  @override
  final String? noteContains;
  @override
  final String? noteHasPrefix;
  @override
  final String? noteHasSuffix;
  @override
  final bool? noteIsNil;
  @override
  final bool? noteNotNil;
  @override
  final String? noteEqualFold;
  @override
  final String? noteContainsFold;
  @override
  final GTaskType? type;
  @override
  final GTaskType? typeNEQ;
  @override
  final BuiltList<GTaskType>? typeIn;
  @override
  final BuiltList<GTaskType>? typeNotIn;
  @override
  final GTime? date;
  @override
  final GTime? dateNEQ;
  @override
  final BuiltList<GTime>? dateIn;
  @override
  final BuiltList<GTime>? dateNotIn;
  @override
  final GTime? dateGT;
  @override
  final GTime? dateGTE;
  @override
  final GTime? dateLT;
  @override
  final GTime? dateLTE;
  @override
  final int? durationM;
  @override
  final int? durationMNEQ;
  @override
  final BuiltList<int>? durationMIn;
  @override
  final BuiltList<int>? durationMNotIn;
  @override
  final int? durationMGT;
  @override
  final int? durationMGTE;
  @override
  final int? durationMLT;
  @override
  final int? durationMLTE;
  @override
  final bool? durationMIsNil;
  @override
  final bool? durationMNotNil;
  @override
  final bool? hasReminder;
  @override
  final bool? hasReminderNEQ;
  @override
  final GTime? reminderTime;
  @override
  final GTime? reminderTimeNEQ;
  @override
  final BuiltList<GTime>? reminderTimeIn;
  @override
  final BuiltList<GTime>? reminderTimeNotIn;
  @override
  final GTime? reminderTimeGT;
  @override
  final GTime? reminderTimeGTE;
  @override
  final GTime? reminderTimeLT;
  @override
  final GTime? reminderTimeLTE;
  @override
  final bool? reminderTimeIsNil;
  @override
  final bool? reminderTimeNotNil;
  @override
  final String? recurringDays;
  @override
  final String? recurringDaysNEQ;
  @override
  final BuiltList<String>? recurringDaysIn;
  @override
  final BuiltList<String>? recurringDaysNotIn;
  @override
  final String? recurringDaysGT;
  @override
  final String? recurringDaysGTE;
  @override
  final String? recurringDaysLT;
  @override
  final String? recurringDaysLTE;
  @override
  final String? recurringDaysContains;
  @override
  final String? recurringDaysHasPrefix;
  @override
  final String? recurringDaysHasSuffix;
  @override
  final bool? recurringDaysIsNil;
  @override
  final bool? recurringDaysNotNil;
  @override
  final String? recurringDaysEqualFold;
  @override
  final String? recurringDaysContainsFold;
  @override
  final GTaskStatus? status;
  @override
  final GTaskStatus? statusNEQ;
  @override
  final BuiltList<GTaskStatus>? statusIn;
  @override
  final BuiltList<GTaskStatus>? statusNotIn;
  @override
  final bool? hasUser;
  @override
  final BuiltList<GUserWhereInput>? hasUserWith;
  @override
  final bool? hasGoal;
  @override
  final BuiltList<GGoalWhereInput>? hasGoalWith;
  @override
  final bool? hasTags;
  @override
  final BuiltList<GTagWhereInput>? hasTagsWith;

  factory _$GTaskWhereInput([void Function(GTaskWhereInputBuilder)? updates]) =>
      (new GTaskWhereInputBuilder()..update(updates))._build();

  _$GTaskWhereInput._(
      {this.not,
      this.and,
      this.or,
      this.id,
      this.idNEQ,
      this.idIn,
      this.idNotIn,
      this.idGT,
      this.idGTE,
      this.idLT,
      this.idLTE,
      this.createdAt,
      this.createdAtNEQ,
      this.createdAtIn,
      this.createdAtNotIn,
      this.createdAtGT,
      this.createdAtGTE,
      this.createdAtLT,
      this.createdAtLTE,
      this.updatedAt,
      this.updatedAtNEQ,
      this.updatedAtIn,
      this.updatedAtNotIn,
      this.updatedAtGT,
      this.updatedAtGTE,
      this.updatedAtLT,
      this.updatedAtLTE,
      this.title,
      this.titleNEQ,
      this.titleIn,
      this.titleNotIn,
      this.titleGT,
      this.titleGTE,
      this.titleLT,
      this.titleLTE,
      this.titleContains,
      this.titleHasPrefix,
      this.titleHasSuffix,
      this.titleEqualFold,
      this.titleContainsFold,
      this.shortDescription,
      this.shortDescriptionNEQ,
      this.shortDescriptionIn,
      this.shortDescriptionNotIn,
      this.shortDescriptionGT,
      this.shortDescriptionGTE,
      this.shortDescriptionLT,
      this.shortDescriptionLTE,
      this.shortDescriptionContains,
      this.shortDescriptionHasPrefix,
      this.shortDescriptionHasSuffix,
      this.shortDescriptionIsNil,
      this.shortDescriptionNotNil,
      this.shortDescriptionEqualFold,
      this.shortDescriptionContainsFold,
      this.note,
      this.noteNEQ,
      this.noteIn,
      this.noteNotIn,
      this.noteGT,
      this.noteGTE,
      this.noteLT,
      this.noteLTE,
      this.noteContains,
      this.noteHasPrefix,
      this.noteHasSuffix,
      this.noteIsNil,
      this.noteNotNil,
      this.noteEqualFold,
      this.noteContainsFold,
      this.type,
      this.typeNEQ,
      this.typeIn,
      this.typeNotIn,
      this.date,
      this.dateNEQ,
      this.dateIn,
      this.dateNotIn,
      this.dateGT,
      this.dateGTE,
      this.dateLT,
      this.dateLTE,
      this.durationM,
      this.durationMNEQ,
      this.durationMIn,
      this.durationMNotIn,
      this.durationMGT,
      this.durationMGTE,
      this.durationMLT,
      this.durationMLTE,
      this.durationMIsNil,
      this.durationMNotNil,
      this.hasReminder,
      this.hasReminderNEQ,
      this.reminderTime,
      this.reminderTimeNEQ,
      this.reminderTimeIn,
      this.reminderTimeNotIn,
      this.reminderTimeGT,
      this.reminderTimeGTE,
      this.reminderTimeLT,
      this.reminderTimeLTE,
      this.reminderTimeIsNil,
      this.reminderTimeNotNil,
      this.recurringDays,
      this.recurringDaysNEQ,
      this.recurringDaysIn,
      this.recurringDaysNotIn,
      this.recurringDaysGT,
      this.recurringDaysGTE,
      this.recurringDaysLT,
      this.recurringDaysLTE,
      this.recurringDaysContains,
      this.recurringDaysHasPrefix,
      this.recurringDaysHasSuffix,
      this.recurringDaysIsNil,
      this.recurringDaysNotNil,
      this.recurringDaysEqualFold,
      this.recurringDaysContainsFold,
      this.status,
      this.statusNEQ,
      this.statusIn,
      this.statusNotIn,
      this.hasUser,
      this.hasUserWith,
      this.hasGoal,
      this.hasGoalWith,
      this.hasTags,
      this.hasTagsWith})
      : super._();

  @override
  GTaskWhereInput rebuild(void Function(GTaskWhereInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GTaskWhereInputBuilder toBuilder() =>
      new GTaskWhereInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GTaskWhereInput &&
        not == other.not &&
        and == other.and &&
        or == other.or &&
        id == other.id &&
        idNEQ == other.idNEQ &&
        idIn == other.idIn &&
        idNotIn == other.idNotIn &&
        idGT == other.idGT &&
        idGTE == other.idGTE &&
        idLT == other.idLT &&
        idLTE == other.idLTE &&
        createdAt == other.createdAt &&
        createdAtNEQ == other.createdAtNEQ &&
        createdAtIn == other.createdAtIn &&
        createdAtNotIn == other.createdAtNotIn &&
        createdAtGT == other.createdAtGT &&
        createdAtGTE == other.createdAtGTE &&
        createdAtLT == other.createdAtLT &&
        createdAtLTE == other.createdAtLTE &&
        updatedAt == other.updatedAt &&
        updatedAtNEQ == other.updatedAtNEQ &&
        updatedAtIn == other.updatedAtIn &&
        updatedAtNotIn == other.updatedAtNotIn &&
        updatedAtGT == other.updatedAtGT &&
        updatedAtGTE == other.updatedAtGTE &&
        updatedAtLT == other.updatedAtLT &&
        updatedAtLTE == other.updatedAtLTE &&
        title == other.title &&
        titleNEQ == other.titleNEQ &&
        titleIn == other.titleIn &&
        titleNotIn == other.titleNotIn &&
        titleGT == other.titleGT &&
        titleGTE == other.titleGTE &&
        titleLT == other.titleLT &&
        titleLTE == other.titleLTE &&
        titleContains == other.titleContains &&
        titleHasPrefix == other.titleHasPrefix &&
        titleHasSuffix == other.titleHasSuffix &&
        titleEqualFold == other.titleEqualFold &&
        titleContainsFold == other.titleContainsFold &&
        shortDescription == other.shortDescription &&
        shortDescriptionNEQ == other.shortDescriptionNEQ &&
        shortDescriptionIn == other.shortDescriptionIn &&
        shortDescriptionNotIn == other.shortDescriptionNotIn &&
        shortDescriptionGT == other.shortDescriptionGT &&
        shortDescriptionGTE == other.shortDescriptionGTE &&
        shortDescriptionLT == other.shortDescriptionLT &&
        shortDescriptionLTE == other.shortDescriptionLTE &&
        shortDescriptionContains == other.shortDescriptionContains &&
        shortDescriptionHasPrefix == other.shortDescriptionHasPrefix &&
        shortDescriptionHasSuffix == other.shortDescriptionHasSuffix &&
        shortDescriptionIsNil == other.shortDescriptionIsNil &&
        shortDescriptionNotNil == other.shortDescriptionNotNil &&
        shortDescriptionEqualFold == other.shortDescriptionEqualFold &&
        shortDescriptionContainsFold == other.shortDescriptionContainsFold &&
        note == other.note &&
        noteNEQ == other.noteNEQ &&
        noteIn == other.noteIn &&
        noteNotIn == other.noteNotIn &&
        noteGT == other.noteGT &&
        noteGTE == other.noteGTE &&
        noteLT == other.noteLT &&
        noteLTE == other.noteLTE &&
        noteContains == other.noteContains &&
        noteHasPrefix == other.noteHasPrefix &&
        noteHasSuffix == other.noteHasSuffix &&
        noteIsNil == other.noteIsNil &&
        noteNotNil == other.noteNotNil &&
        noteEqualFold == other.noteEqualFold &&
        noteContainsFold == other.noteContainsFold &&
        type == other.type &&
        typeNEQ == other.typeNEQ &&
        typeIn == other.typeIn &&
        typeNotIn == other.typeNotIn &&
        date == other.date &&
        dateNEQ == other.dateNEQ &&
        dateIn == other.dateIn &&
        dateNotIn == other.dateNotIn &&
        dateGT == other.dateGT &&
        dateGTE == other.dateGTE &&
        dateLT == other.dateLT &&
        dateLTE == other.dateLTE &&
        durationM == other.durationM &&
        durationMNEQ == other.durationMNEQ &&
        durationMIn == other.durationMIn &&
        durationMNotIn == other.durationMNotIn &&
        durationMGT == other.durationMGT &&
        durationMGTE == other.durationMGTE &&
        durationMLT == other.durationMLT &&
        durationMLTE == other.durationMLTE &&
        durationMIsNil == other.durationMIsNil &&
        durationMNotNil == other.durationMNotNil &&
        hasReminder == other.hasReminder &&
        hasReminderNEQ == other.hasReminderNEQ &&
        reminderTime == other.reminderTime &&
        reminderTimeNEQ == other.reminderTimeNEQ &&
        reminderTimeIn == other.reminderTimeIn &&
        reminderTimeNotIn == other.reminderTimeNotIn &&
        reminderTimeGT == other.reminderTimeGT &&
        reminderTimeGTE == other.reminderTimeGTE &&
        reminderTimeLT == other.reminderTimeLT &&
        reminderTimeLTE == other.reminderTimeLTE &&
        reminderTimeIsNil == other.reminderTimeIsNil &&
        reminderTimeNotNil == other.reminderTimeNotNil &&
        recurringDays == other.recurringDays &&
        recurringDaysNEQ == other.recurringDaysNEQ &&
        recurringDaysIn == other.recurringDaysIn &&
        recurringDaysNotIn == other.recurringDaysNotIn &&
        recurringDaysGT == other.recurringDaysGT &&
        recurringDaysGTE == other.recurringDaysGTE &&
        recurringDaysLT == other.recurringDaysLT &&
        recurringDaysLTE == other.recurringDaysLTE &&
        recurringDaysContains == other.recurringDaysContains &&
        recurringDaysHasPrefix == other.recurringDaysHasPrefix &&
        recurringDaysHasSuffix == other.recurringDaysHasSuffix &&
        recurringDaysIsNil == other.recurringDaysIsNil &&
        recurringDaysNotNil == other.recurringDaysNotNil &&
        recurringDaysEqualFold == other.recurringDaysEqualFold &&
        recurringDaysContainsFold == other.recurringDaysContainsFold &&
        status == other.status &&
        statusNEQ == other.statusNEQ &&
        statusIn == other.statusIn &&
        statusNotIn == other.statusNotIn &&
        hasUser == other.hasUser &&
        hasUserWith == other.hasUserWith &&
        hasGoal == other.hasGoal &&
        hasGoalWith == other.hasGoalWith &&
        hasTags == other.hasTags &&
        hasTagsWith == other.hasTagsWith;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, not.hashCode);
    _$hash = $jc(_$hash, and.hashCode);
    _$hash = $jc(_$hash, or.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idNEQ.hashCode);
    _$hash = $jc(_$hash, idIn.hashCode);
    _$hash = $jc(_$hash, idNotIn.hashCode);
    _$hash = $jc(_$hash, idGT.hashCode);
    _$hash = $jc(_$hash, idGTE.hashCode);
    _$hash = $jc(_$hash, idLT.hashCode);
    _$hash = $jc(_$hash, idLTE.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdAtNEQ.hashCode);
    _$hash = $jc(_$hash, createdAtIn.hashCode);
    _$hash = $jc(_$hash, createdAtNotIn.hashCode);
    _$hash = $jc(_$hash, createdAtGT.hashCode);
    _$hash = $jc(_$hash, createdAtGTE.hashCode);
    _$hash = $jc(_$hash, createdAtLT.hashCode);
    _$hash = $jc(_$hash, createdAtLTE.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedAtNEQ.hashCode);
    _$hash = $jc(_$hash, updatedAtIn.hashCode);
    _$hash = $jc(_$hash, updatedAtNotIn.hashCode);
    _$hash = $jc(_$hash, updatedAtGT.hashCode);
    _$hash = $jc(_$hash, updatedAtGTE.hashCode);
    _$hash = $jc(_$hash, updatedAtLT.hashCode);
    _$hash = $jc(_$hash, updatedAtLTE.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, titleNEQ.hashCode);
    _$hash = $jc(_$hash, titleIn.hashCode);
    _$hash = $jc(_$hash, titleNotIn.hashCode);
    _$hash = $jc(_$hash, titleGT.hashCode);
    _$hash = $jc(_$hash, titleGTE.hashCode);
    _$hash = $jc(_$hash, titleLT.hashCode);
    _$hash = $jc(_$hash, titleLTE.hashCode);
    _$hash = $jc(_$hash, titleContains.hashCode);
    _$hash = $jc(_$hash, titleHasPrefix.hashCode);
    _$hash = $jc(_$hash, titleHasSuffix.hashCode);
    _$hash = $jc(_$hash, titleEqualFold.hashCode);
    _$hash = $jc(_$hash, titleContainsFold.hashCode);
    _$hash = $jc(_$hash, shortDescription.hashCode);
    _$hash = $jc(_$hash, shortDescriptionNEQ.hashCode);
    _$hash = $jc(_$hash, shortDescriptionIn.hashCode);
    _$hash = $jc(_$hash, shortDescriptionNotIn.hashCode);
    _$hash = $jc(_$hash, shortDescriptionGT.hashCode);
    _$hash = $jc(_$hash, shortDescriptionGTE.hashCode);
    _$hash = $jc(_$hash, shortDescriptionLT.hashCode);
    _$hash = $jc(_$hash, shortDescriptionLTE.hashCode);
    _$hash = $jc(_$hash, shortDescriptionContains.hashCode);
    _$hash = $jc(_$hash, shortDescriptionHasPrefix.hashCode);
    _$hash = $jc(_$hash, shortDescriptionHasSuffix.hashCode);
    _$hash = $jc(_$hash, shortDescriptionIsNil.hashCode);
    _$hash = $jc(_$hash, shortDescriptionNotNil.hashCode);
    _$hash = $jc(_$hash, shortDescriptionEqualFold.hashCode);
    _$hash = $jc(_$hash, shortDescriptionContainsFold.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, noteNEQ.hashCode);
    _$hash = $jc(_$hash, noteIn.hashCode);
    _$hash = $jc(_$hash, noteNotIn.hashCode);
    _$hash = $jc(_$hash, noteGT.hashCode);
    _$hash = $jc(_$hash, noteGTE.hashCode);
    _$hash = $jc(_$hash, noteLT.hashCode);
    _$hash = $jc(_$hash, noteLTE.hashCode);
    _$hash = $jc(_$hash, noteContains.hashCode);
    _$hash = $jc(_$hash, noteHasPrefix.hashCode);
    _$hash = $jc(_$hash, noteHasSuffix.hashCode);
    _$hash = $jc(_$hash, noteIsNil.hashCode);
    _$hash = $jc(_$hash, noteNotNil.hashCode);
    _$hash = $jc(_$hash, noteEqualFold.hashCode);
    _$hash = $jc(_$hash, noteContainsFold.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, typeNEQ.hashCode);
    _$hash = $jc(_$hash, typeIn.hashCode);
    _$hash = $jc(_$hash, typeNotIn.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, dateNEQ.hashCode);
    _$hash = $jc(_$hash, dateIn.hashCode);
    _$hash = $jc(_$hash, dateNotIn.hashCode);
    _$hash = $jc(_$hash, dateGT.hashCode);
    _$hash = $jc(_$hash, dateGTE.hashCode);
    _$hash = $jc(_$hash, dateLT.hashCode);
    _$hash = $jc(_$hash, dateLTE.hashCode);
    _$hash = $jc(_$hash, durationM.hashCode);
    _$hash = $jc(_$hash, durationMNEQ.hashCode);
    _$hash = $jc(_$hash, durationMIn.hashCode);
    _$hash = $jc(_$hash, durationMNotIn.hashCode);
    _$hash = $jc(_$hash, durationMGT.hashCode);
    _$hash = $jc(_$hash, durationMGTE.hashCode);
    _$hash = $jc(_$hash, durationMLT.hashCode);
    _$hash = $jc(_$hash, durationMLTE.hashCode);
    _$hash = $jc(_$hash, durationMIsNil.hashCode);
    _$hash = $jc(_$hash, durationMNotNil.hashCode);
    _$hash = $jc(_$hash, hasReminder.hashCode);
    _$hash = $jc(_$hash, hasReminderNEQ.hashCode);
    _$hash = $jc(_$hash, reminderTime.hashCode);
    _$hash = $jc(_$hash, reminderTimeNEQ.hashCode);
    _$hash = $jc(_$hash, reminderTimeIn.hashCode);
    _$hash = $jc(_$hash, reminderTimeNotIn.hashCode);
    _$hash = $jc(_$hash, reminderTimeGT.hashCode);
    _$hash = $jc(_$hash, reminderTimeGTE.hashCode);
    _$hash = $jc(_$hash, reminderTimeLT.hashCode);
    _$hash = $jc(_$hash, reminderTimeLTE.hashCode);
    _$hash = $jc(_$hash, reminderTimeIsNil.hashCode);
    _$hash = $jc(_$hash, reminderTimeNotNil.hashCode);
    _$hash = $jc(_$hash, recurringDays.hashCode);
    _$hash = $jc(_$hash, recurringDaysNEQ.hashCode);
    _$hash = $jc(_$hash, recurringDaysIn.hashCode);
    _$hash = $jc(_$hash, recurringDaysNotIn.hashCode);
    _$hash = $jc(_$hash, recurringDaysGT.hashCode);
    _$hash = $jc(_$hash, recurringDaysGTE.hashCode);
    _$hash = $jc(_$hash, recurringDaysLT.hashCode);
    _$hash = $jc(_$hash, recurringDaysLTE.hashCode);
    _$hash = $jc(_$hash, recurringDaysContains.hashCode);
    _$hash = $jc(_$hash, recurringDaysHasPrefix.hashCode);
    _$hash = $jc(_$hash, recurringDaysHasSuffix.hashCode);
    _$hash = $jc(_$hash, recurringDaysIsNil.hashCode);
    _$hash = $jc(_$hash, recurringDaysNotNil.hashCode);
    _$hash = $jc(_$hash, recurringDaysEqualFold.hashCode);
    _$hash = $jc(_$hash, recurringDaysContainsFold.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, statusNEQ.hashCode);
    _$hash = $jc(_$hash, statusIn.hashCode);
    _$hash = $jc(_$hash, statusNotIn.hashCode);
    _$hash = $jc(_$hash, hasUser.hashCode);
    _$hash = $jc(_$hash, hasUserWith.hashCode);
    _$hash = $jc(_$hash, hasGoal.hashCode);
    _$hash = $jc(_$hash, hasGoalWith.hashCode);
    _$hash = $jc(_$hash, hasTags.hashCode);
    _$hash = $jc(_$hash, hasTagsWith.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GTaskWhereInput')
          ..add('not', not)
          ..add('and', and)
          ..add('or', or)
          ..add('id', id)
          ..add('idNEQ', idNEQ)
          ..add('idIn', idIn)
          ..add('idNotIn', idNotIn)
          ..add('idGT', idGT)
          ..add('idGTE', idGTE)
          ..add('idLT', idLT)
          ..add('idLTE', idLTE)
          ..add('createdAt', createdAt)
          ..add('createdAtNEQ', createdAtNEQ)
          ..add('createdAtIn', createdAtIn)
          ..add('createdAtNotIn', createdAtNotIn)
          ..add('createdAtGT', createdAtGT)
          ..add('createdAtGTE', createdAtGTE)
          ..add('createdAtLT', createdAtLT)
          ..add('createdAtLTE', createdAtLTE)
          ..add('updatedAt', updatedAt)
          ..add('updatedAtNEQ', updatedAtNEQ)
          ..add('updatedAtIn', updatedAtIn)
          ..add('updatedAtNotIn', updatedAtNotIn)
          ..add('updatedAtGT', updatedAtGT)
          ..add('updatedAtGTE', updatedAtGTE)
          ..add('updatedAtLT', updatedAtLT)
          ..add('updatedAtLTE', updatedAtLTE)
          ..add('title', title)
          ..add('titleNEQ', titleNEQ)
          ..add('titleIn', titleIn)
          ..add('titleNotIn', titleNotIn)
          ..add('titleGT', titleGT)
          ..add('titleGTE', titleGTE)
          ..add('titleLT', titleLT)
          ..add('titleLTE', titleLTE)
          ..add('titleContains', titleContains)
          ..add('titleHasPrefix', titleHasPrefix)
          ..add('titleHasSuffix', titleHasSuffix)
          ..add('titleEqualFold', titleEqualFold)
          ..add('titleContainsFold', titleContainsFold)
          ..add('shortDescription', shortDescription)
          ..add('shortDescriptionNEQ', shortDescriptionNEQ)
          ..add('shortDescriptionIn', shortDescriptionIn)
          ..add('shortDescriptionNotIn', shortDescriptionNotIn)
          ..add('shortDescriptionGT', shortDescriptionGT)
          ..add('shortDescriptionGTE', shortDescriptionGTE)
          ..add('shortDescriptionLT', shortDescriptionLT)
          ..add('shortDescriptionLTE', shortDescriptionLTE)
          ..add('shortDescriptionContains', shortDescriptionContains)
          ..add('shortDescriptionHasPrefix', shortDescriptionHasPrefix)
          ..add('shortDescriptionHasSuffix', shortDescriptionHasSuffix)
          ..add('shortDescriptionIsNil', shortDescriptionIsNil)
          ..add('shortDescriptionNotNil', shortDescriptionNotNil)
          ..add('shortDescriptionEqualFold', shortDescriptionEqualFold)
          ..add('shortDescriptionContainsFold', shortDescriptionContainsFold)
          ..add('note', note)
          ..add('noteNEQ', noteNEQ)
          ..add('noteIn', noteIn)
          ..add('noteNotIn', noteNotIn)
          ..add('noteGT', noteGT)
          ..add('noteGTE', noteGTE)
          ..add('noteLT', noteLT)
          ..add('noteLTE', noteLTE)
          ..add('noteContains', noteContains)
          ..add('noteHasPrefix', noteHasPrefix)
          ..add('noteHasSuffix', noteHasSuffix)
          ..add('noteIsNil', noteIsNil)
          ..add('noteNotNil', noteNotNil)
          ..add('noteEqualFold', noteEqualFold)
          ..add('noteContainsFold', noteContainsFold)
          ..add('type', type)
          ..add('typeNEQ', typeNEQ)
          ..add('typeIn', typeIn)
          ..add('typeNotIn', typeNotIn)
          ..add('date', date)
          ..add('dateNEQ', dateNEQ)
          ..add('dateIn', dateIn)
          ..add('dateNotIn', dateNotIn)
          ..add('dateGT', dateGT)
          ..add('dateGTE', dateGTE)
          ..add('dateLT', dateLT)
          ..add('dateLTE', dateLTE)
          ..add('durationM', durationM)
          ..add('durationMNEQ', durationMNEQ)
          ..add('durationMIn', durationMIn)
          ..add('durationMNotIn', durationMNotIn)
          ..add('durationMGT', durationMGT)
          ..add('durationMGTE', durationMGTE)
          ..add('durationMLT', durationMLT)
          ..add('durationMLTE', durationMLTE)
          ..add('durationMIsNil', durationMIsNil)
          ..add('durationMNotNil', durationMNotNil)
          ..add('hasReminder', hasReminder)
          ..add('hasReminderNEQ', hasReminderNEQ)
          ..add('reminderTime', reminderTime)
          ..add('reminderTimeNEQ', reminderTimeNEQ)
          ..add('reminderTimeIn', reminderTimeIn)
          ..add('reminderTimeNotIn', reminderTimeNotIn)
          ..add('reminderTimeGT', reminderTimeGT)
          ..add('reminderTimeGTE', reminderTimeGTE)
          ..add('reminderTimeLT', reminderTimeLT)
          ..add('reminderTimeLTE', reminderTimeLTE)
          ..add('reminderTimeIsNil', reminderTimeIsNil)
          ..add('reminderTimeNotNil', reminderTimeNotNil)
          ..add('recurringDays', recurringDays)
          ..add('recurringDaysNEQ', recurringDaysNEQ)
          ..add('recurringDaysIn', recurringDaysIn)
          ..add('recurringDaysNotIn', recurringDaysNotIn)
          ..add('recurringDaysGT', recurringDaysGT)
          ..add('recurringDaysGTE', recurringDaysGTE)
          ..add('recurringDaysLT', recurringDaysLT)
          ..add('recurringDaysLTE', recurringDaysLTE)
          ..add('recurringDaysContains', recurringDaysContains)
          ..add('recurringDaysHasPrefix', recurringDaysHasPrefix)
          ..add('recurringDaysHasSuffix', recurringDaysHasSuffix)
          ..add('recurringDaysIsNil', recurringDaysIsNil)
          ..add('recurringDaysNotNil', recurringDaysNotNil)
          ..add('recurringDaysEqualFold', recurringDaysEqualFold)
          ..add('recurringDaysContainsFold', recurringDaysContainsFold)
          ..add('status', status)
          ..add('statusNEQ', statusNEQ)
          ..add('statusIn', statusIn)
          ..add('statusNotIn', statusNotIn)
          ..add('hasUser', hasUser)
          ..add('hasUserWith', hasUserWith)
          ..add('hasGoal', hasGoal)
          ..add('hasGoalWith', hasGoalWith)
          ..add('hasTags', hasTags)
          ..add('hasTagsWith', hasTagsWith))
        .toString();
  }
}

class GTaskWhereInputBuilder
    implements Builder<GTaskWhereInput, GTaskWhereInputBuilder> {
  _$GTaskWhereInput? _$v;

  GTaskWhereInputBuilder? _not;
  GTaskWhereInputBuilder get not =>
      _$this._not ??= new GTaskWhereInputBuilder();
  set not(GTaskWhereInputBuilder? not) => _$this._not = not;

  ListBuilder<GTaskWhereInput>? _and;
  ListBuilder<GTaskWhereInput> get and =>
      _$this._and ??= new ListBuilder<GTaskWhereInput>();
  set and(ListBuilder<GTaskWhereInput>? and) => _$this._and = and;

  ListBuilder<GTaskWhereInput>? _or;
  ListBuilder<GTaskWhereInput> get or =>
      _$this._or ??= new ListBuilder<GTaskWhereInput>();
  set or(ListBuilder<GTaskWhereInput>? or) => _$this._or = or;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _idNEQ;
  String? get idNEQ => _$this._idNEQ;
  set idNEQ(String? idNEQ) => _$this._idNEQ = idNEQ;

  ListBuilder<String>? _idIn;
  ListBuilder<String> get idIn => _$this._idIn ??= new ListBuilder<String>();
  set idIn(ListBuilder<String>? idIn) => _$this._idIn = idIn;

  ListBuilder<String>? _idNotIn;
  ListBuilder<String> get idNotIn =>
      _$this._idNotIn ??= new ListBuilder<String>();
  set idNotIn(ListBuilder<String>? idNotIn) => _$this._idNotIn = idNotIn;

  String? _idGT;
  String? get idGT => _$this._idGT;
  set idGT(String? idGT) => _$this._idGT = idGT;

  String? _idGTE;
  String? get idGTE => _$this._idGTE;
  set idGTE(String? idGTE) => _$this._idGTE = idGTE;

  String? _idLT;
  String? get idLT => _$this._idLT;
  set idLT(String? idLT) => _$this._idLT = idLT;

  String? _idLTE;
  String? get idLTE => _$this._idLTE;
  set idLTE(String? idLTE) => _$this._idLTE = idLTE;

  GTimeBuilder? _createdAt;
  GTimeBuilder get createdAt => _$this._createdAt ??= new GTimeBuilder();
  set createdAt(GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GTimeBuilder? _createdAtNEQ;
  GTimeBuilder get createdAtNEQ => _$this._createdAtNEQ ??= new GTimeBuilder();
  set createdAtNEQ(GTimeBuilder? createdAtNEQ) =>
      _$this._createdAtNEQ = createdAtNEQ;

  ListBuilder<GTime>? _createdAtIn;
  ListBuilder<GTime> get createdAtIn =>
      _$this._createdAtIn ??= new ListBuilder<GTime>();
  set createdAtIn(ListBuilder<GTime>? createdAtIn) =>
      _$this._createdAtIn = createdAtIn;

  ListBuilder<GTime>? _createdAtNotIn;
  ListBuilder<GTime> get createdAtNotIn =>
      _$this._createdAtNotIn ??= new ListBuilder<GTime>();
  set createdAtNotIn(ListBuilder<GTime>? createdAtNotIn) =>
      _$this._createdAtNotIn = createdAtNotIn;

  GTimeBuilder? _createdAtGT;
  GTimeBuilder get createdAtGT => _$this._createdAtGT ??= new GTimeBuilder();
  set createdAtGT(GTimeBuilder? createdAtGT) =>
      _$this._createdAtGT = createdAtGT;

  GTimeBuilder? _createdAtGTE;
  GTimeBuilder get createdAtGTE => _$this._createdAtGTE ??= new GTimeBuilder();
  set createdAtGTE(GTimeBuilder? createdAtGTE) =>
      _$this._createdAtGTE = createdAtGTE;

  GTimeBuilder? _createdAtLT;
  GTimeBuilder get createdAtLT => _$this._createdAtLT ??= new GTimeBuilder();
  set createdAtLT(GTimeBuilder? createdAtLT) =>
      _$this._createdAtLT = createdAtLT;

  GTimeBuilder? _createdAtLTE;
  GTimeBuilder get createdAtLTE => _$this._createdAtLTE ??= new GTimeBuilder();
  set createdAtLTE(GTimeBuilder? createdAtLTE) =>
      _$this._createdAtLTE = createdAtLTE;

  GTimeBuilder? _updatedAt;
  GTimeBuilder get updatedAt => _$this._updatedAt ??= new GTimeBuilder();
  set updatedAt(GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  GTimeBuilder? _updatedAtNEQ;
  GTimeBuilder get updatedAtNEQ => _$this._updatedAtNEQ ??= new GTimeBuilder();
  set updatedAtNEQ(GTimeBuilder? updatedAtNEQ) =>
      _$this._updatedAtNEQ = updatedAtNEQ;

  ListBuilder<GTime>? _updatedAtIn;
  ListBuilder<GTime> get updatedAtIn =>
      _$this._updatedAtIn ??= new ListBuilder<GTime>();
  set updatedAtIn(ListBuilder<GTime>? updatedAtIn) =>
      _$this._updatedAtIn = updatedAtIn;

  ListBuilder<GTime>? _updatedAtNotIn;
  ListBuilder<GTime> get updatedAtNotIn =>
      _$this._updatedAtNotIn ??= new ListBuilder<GTime>();
  set updatedAtNotIn(ListBuilder<GTime>? updatedAtNotIn) =>
      _$this._updatedAtNotIn = updatedAtNotIn;

  GTimeBuilder? _updatedAtGT;
  GTimeBuilder get updatedAtGT => _$this._updatedAtGT ??= new GTimeBuilder();
  set updatedAtGT(GTimeBuilder? updatedAtGT) =>
      _$this._updatedAtGT = updatedAtGT;

  GTimeBuilder? _updatedAtGTE;
  GTimeBuilder get updatedAtGTE => _$this._updatedAtGTE ??= new GTimeBuilder();
  set updatedAtGTE(GTimeBuilder? updatedAtGTE) =>
      _$this._updatedAtGTE = updatedAtGTE;

  GTimeBuilder? _updatedAtLT;
  GTimeBuilder get updatedAtLT => _$this._updatedAtLT ??= new GTimeBuilder();
  set updatedAtLT(GTimeBuilder? updatedAtLT) =>
      _$this._updatedAtLT = updatedAtLT;

  GTimeBuilder? _updatedAtLTE;
  GTimeBuilder get updatedAtLTE => _$this._updatedAtLTE ??= new GTimeBuilder();
  set updatedAtLTE(GTimeBuilder? updatedAtLTE) =>
      _$this._updatedAtLTE = updatedAtLTE;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _titleNEQ;
  String? get titleNEQ => _$this._titleNEQ;
  set titleNEQ(String? titleNEQ) => _$this._titleNEQ = titleNEQ;

  ListBuilder<String>? _titleIn;
  ListBuilder<String> get titleIn =>
      _$this._titleIn ??= new ListBuilder<String>();
  set titleIn(ListBuilder<String>? titleIn) => _$this._titleIn = titleIn;

  ListBuilder<String>? _titleNotIn;
  ListBuilder<String> get titleNotIn =>
      _$this._titleNotIn ??= new ListBuilder<String>();
  set titleNotIn(ListBuilder<String>? titleNotIn) =>
      _$this._titleNotIn = titleNotIn;

  String? _titleGT;
  String? get titleGT => _$this._titleGT;
  set titleGT(String? titleGT) => _$this._titleGT = titleGT;

  String? _titleGTE;
  String? get titleGTE => _$this._titleGTE;
  set titleGTE(String? titleGTE) => _$this._titleGTE = titleGTE;

  String? _titleLT;
  String? get titleLT => _$this._titleLT;
  set titleLT(String? titleLT) => _$this._titleLT = titleLT;

  String? _titleLTE;
  String? get titleLTE => _$this._titleLTE;
  set titleLTE(String? titleLTE) => _$this._titleLTE = titleLTE;

  String? _titleContains;
  String? get titleContains => _$this._titleContains;
  set titleContains(String? titleContains) =>
      _$this._titleContains = titleContains;

  String? _titleHasPrefix;
  String? get titleHasPrefix => _$this._titleHasPrefix;
  set titleHasPrefix(String? titleHasPrefix) =>
      _$this._titleHasPrefix = titleHasPrefix;

  String? _titleHasSuffix;
  String? get titleHasSuffix => _$this._titleHasSuffix;
  set titleHasSuffix(String? titleHasSuffix) =>
      _$this._titleHasSuffix = titleHasSuffix;

  String? _titleEqualFold;
  String? get titleEqualFold => _$this._titleEqualFold;
  set titleEqualFold(String? titleEqualFold) =>
      _$this._titleEqualFold = titleEqualFold;

  String? _titleContainsFold;
  String? get titleContainsFold => _$this._titleContainsFold;
  set titleContainsFold(String? titleContainsFold) =>
      _$this._titleContainsFold = titleContainsFold;

  String? _shortDescription;
  String? get shortDescription => _$this._shortDescription;
  set shortDescription(String? shortDescription) =>
      _$this._shortDescription = shortDescription;

  String? _shortDescriptionNEQ;
  String? get shortDescriptionNEQ => _$this._shortDescriptionNEQ;
  set shortDescriptionNEQ(String? shortDescriptionNEQ) =>
      _$this._shortDescriptionNEQ = shortDescriptionNEQ;

  ListBuilder<String>? _shortDescriptionIn;
  ListBuilder<String> get shortDescriptionIn =>
      _$this._shortDescriptionIn ??= new ListBuilder<String>();
  set shortDescriptionIn(ListBuilder<String>? shortDescriptionIn) =>
      _$this._shortDescriptionIn = shortDescriptionIn;

  ListBuilder<String>? _shortDescriptionNotIn;
  ListBuilder<String> get shortDescriptionNotIn =>
      _$this._shortDescriptionNotIn ??= new ListBuilder<String>();
  set shortDescriptionNotIn(ListBuilder<String>? shortDescriptionNotIn) =>
      _$this._shortDescriptionNotIn = shortDescriptionNotIn;

  String? _shortDescriptionGT;
  String? get shortDescriptionGT => _$this._shortDescriptionGT;
  set shortDescriptionGT(String? shortDescriptionGT) =>
      _$this._shortDescriptionGT = shortDescriptionGT;

  String? _shortDescriptionGTE;
  String? get shortDescriptionGTE => _$this._shortDescriptionGTE;
  set shortDescriptionGTE(String? shortDescriptionGTE) =>
      _$this._shortDescriptionGTE = shortDescriptionGTE;

  String? _shortDescriptionLT;
  String? get shortDescriptionLT => _$this._shortDescriptionLT;
  set shortDescriptionLT(String? shortDescriptionLT) =>
      _$this._shortDescriptionLT = shortDescriptionLT;

  String? _shortDescriptionLTE;
  String? get shortDescriptionLTE => _$this._shortDescriptionLTE;
  set shortDescriptionLTE(String? shortDescriptionLTE) =>
      _$this._shortDescriptionLTE = shortDescriptionLTE;

  String? _shortDescriptionContains;
  String? get shortDescriptionContains => _$this._shortDescriptionContains;
  set shortDescriptionContains(String? shortDescriptionContains) =>
      _$this._shortDescriptionContains = shortDescriptionContains;

  String? _shortDescriptionHasPrefix;
  String? get shortDescriptionHasPrefix => _$this._shortDescriptionHasPrefix;
  set shortDescriptionHasPrefix(String? shortDescriptionHasPrefix) =>
      _$this._shortDescriptionHasPrefix = shortDescriptionHasPrefix;

  String? _shortDescriptionHasSuffix;
  String? get shortDescriptionHasSuffix => _$this._shortDescriptionHasSuffix;
  set shortDescriptionHasSuffix(String? shortDescriptionHasSuffix) =>
      _$this._shortDescriptionHasSuffix = shortDescriptionHasSuffix;

  bool? _shortDescriptionIsNil;
  bool? get shortDescriptionIsNil => _$this._shortDescriptionIsNil;
  set shortDescriptionIsNil(bool? shortDescriptionIsNil) =>
      _$this._shortDescriptionIsNil = shortDescriptionIsNil;

  bool? _shortDescriptionNotNil;
  bool? get shortDescriptionNotNil => _$this._shortDescriptionNotNil;
  set shortDescriptionNotNil(bool? shortDescriptionNotNil) =>
      _$this._shortDescriptionNotNil = shortDescriptionNotNil;

  String? _shortDescriptionEqualFold;
  String? get shortDescriptionEqualFold => _$this._shortDescriptionEqualFold;
  set shortDescriptionEqualFold(String? shortDescriptionEqualFold) =>
      _$this._shortDescriptionEqualFold = shortDescriptionEqualFold;

  String? _shortDescriptionContainsFold;
  String? get shortDescriptionContainsFold =>
      _$this._shortDescriptionContainsFold;
  set shortDescriptionContainsFold(String? shortDescriptionContainsFold) =>
      _$this._shortDescriptionContainsFold = shortDescriptionContainsFold;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _noteNEQ;
  String? get noteNEQ => _$this._noteNEQ;
  set noteNEQ(String? noteNEQ) => _$this._noteNEQ = noteNEQ;

  ListBuilder<String>? _noteIn;
  ListBuilder<String> get noteIn =>
      _$this._noteIn ??= new ListBuilder<String>();
  set noteIn(ListBuilder<String>? noteIn) => _$this._noteIn = noteIn;

  ListBuilder<String>? _noteNotIn;
  ListBuilder<String> get noteNotIn =>
      _$this._noteNotIn ??= new ListBuilder<String>();
  set noteNotIn(ListBuilder<String>? noteNotIn) =>
      _$this._noteNotIn = noteNotIn;

  String? _noteGT;
  String? get noteGT => _$this._noteGT;
  set noteGT(String? noteGT) => _$this._noteGT = noteGT;

  String? _noteGTE;
  String? get noteGTE => _$this._noteGTE;
  set noteGTE(String? noteGTE) => _$this._noteGTE = noteGTE;

  String? _noteLT;
  String? get noteLT => _$this._noteLT;
  set noteLT(String? noteLT) => _$this._noteLT = noteLT;

  String? _noteLTE;
  String? get noteLTE => _$this._noteLTE;
  set noteLTE(String? noteLTE) => _$this._noteLTE = noteLTE;

  String? _noteContains;
  String? get noteContains => _$this._noteContains;
  set noteContains(String? noteContains) => _$this._noteContains = noteContains;

  String? _noteHasPrefix;
  String? get noteHasPrefix => _$this._noteHasPrefix;
  set noteHasPrefix(String? noteHasPrefix) =>
      _$this._noteHasPrefix = noteHasPrefix;

  String? _noteHasSuffix;
  String? get noteHasSuffix => _$this._noteHasSuffix;
  set noteHasSuffix(String? noteHasSuffix) =>
      _$this._noteHasSuffix = noteHasSuffix;

  bool? _noteIsNil;
  bool? get noteIsNil => _$this._noteIsNil;
  set noteIsNil(bool? noteIsNil) => _$this._noteIsNil = noteIsNil;

  bool? _noteNotNil;
  bool? get noteNotNil => _$this._noteNotNil;
  set noteNotNil(bool? noteNotNil) => _$this._noteNotNil = noteNotNil;

  String? _noteEqualFold;
  String? get noteEqualFold => _$this._noteEqualFold;
  set noteEqualFold(String? noteEqualFold) =>
      _$this._noteEqualFold = noteEqualFold;

  String? _noteContainsFold;
  String? get noteContainsFold => _$this._noteContainsFold;
  set noteContainsFold(String? noteContainsFold) =>
      _$this._noteContainsFold = noteContainsFold;

  GTaskType? _type;
  GTaskType? get type => _$this._type;
  set type(GTaskType? type) => _$this._type = type;

  GTaskType? _typeNEQ;
  GTaskType? get typeNEQ => _$this._typeNEQ;
  set typeNEQ(GTaskType? typeNEQ) => _$this._typeNEQ = typeNEQ;

  ListBuilder<GTaskType>? _typeIn;
  ListBuilder<GTaskType> get typeIn =>
      _$this._typeIn ??= new ListBuilder<GTaskType>();
  set typeIn(ListBuilder<GTaskType>? typeIn) => _$this._typeIn = typeIn;

  ListBuilder<GTaskType>? _typeNotIn;
  ListBuilder<GTaskType> get typeNotIn =>
      _$this._typeNotIn ??= new ListBuilder<GTaskType>();
  set typeNotIn(ListBuilder<GTaskType>? typeNotIn) =>
      _$this._typeNotIn = typeNotIn;

  GTimeBuilder? _date;
  GTimeBuilder get date => _$this._date ??= new GTimeBuilder();
  set date(GTimeBuilder? date) => _$this._date = date;

  GTimeBuilder? _dateNEQ;
  GTimeBuilder get dateNEQ => _$this._dateNEQ ??= new GTimeBuilder();
  set dateNEQ(GTimeBuilder? dateNEQ) => _$this._dateNEQ = dateNEQ;

  ListBuilder<GTime>? _dateIn;
  ListBuilder<GTime> get dateIn => _$this._dateIn ??= new ListBuilder<GTime>();
  set dateIn(ListBuilder<GTime>? dateIn) => _$this._dateIn = dateIn;

  ListBuilder<GTime>? _dateNotIn;
  ListBuilder<GTime> get dateNotIn =>
      _$this._dateNotIn ??= new ListBuilder<GTime>();
  set dateNotIn(ListBuilder<GTime>? dateNotIn) => _$this._dateNotIn = dateNotIn;

  GTimeBuilder? _dateGT;
  GTimeBuilder get dateGT => _$this._dateGT ??= new GTimeBuilder();
  set dateGT(GTimeBuilder? dateGT) => _$this._dateGT = dateGT;

  GTimeBuilder? _dateGTE;
  GTimeBuilder get dateGTE => _$this._dateGTE ??= new GTimeBuilder();
  set dateGTE(GTimeBuilder? dateGTE) => _$this._dateGTE = dateGTE;

  GTimeBuilder? _dateLT;
  GTimeBuilder get dateLT => _$this._dateLT ??= new GTimeBuilder();
  set dateLT(GTimeBuilder? dateLT) => _$this._dateLT = dateLT;

  GTimeBuilder? _dateLTE;
  GTimeBuilder get dateLTE => _$this._dateLTE ??= new GTimeBuilder();
  set dateLTE(GTimeBuilder? dateLTE) => _$this._dateLTE = dateLTE;

  int? _durationM;
  int? get durationM => _$this._durationM;
  set durationM(int? durationM) => _$this._durationM = durationM;

  int? _durationMNEQ;
  int? get durationMNEQ => _$this._durationMNEQ;
  set durationMNEQ(int? durationMNEQ) => _$this._durationMNEQ = durationMNEQ;

  ListBuilder<int>? _durationMIn;
  ListBuilder<int> get durationMIn =>
      _$this._durationMIn ??= new ListBuilder<int>();
  set durationMIn(ListBuilder<int>? durationMIn) =>
      _$this._durationMIn = durationMIn;

  ListBuilder<int>? _durationMNotIn;
  ListBuilder<int> get durationMNotIn =>
      _$this._durationMNotIn ??= new ListBuilder<int>();
  set durationMNotIn(ListBuilder<int>? durationMNotIn) =>
      _$this._durationMNotIn = durationMNotIn;

  int? _durationMGT;
  int? get durationMGT => _$this._durationMGT;
  set durationMGT(int? durationMGT) => _$this._durationMGT = durationMGT;

  int? _durationMGTE;
  int? get durationMGTE => _$this._durationMGTE;
  set durationMGTE(int? durationMGTE) => _$this._durationMGTE = durationMGTE;

  int? _durationMLT;
  int? get durationMLT => _$this._durationMLT;
  set durationMLT(int? durationMLT) => _$this._durationMLT = durationMLT;

  int? _durationMLTE;
  int? get durationMLTE => _$this._durationMLTE;
  set durationMLTE(int? durationMLTE) => _$this._durationMLTE = durationMLTE;

  bool? _durationMIsNil;
  bool? get durationMIsNil => _$this._durationMIsNil;
  set durationMIsNil(bool? durationMIsNil) =>
      _$this._durationMIsNil = durationMIsNil;

  bool? _durationMNotNil;
  bool? get durationMNotNil => _$this._durationMNotNil;
  set durationMNotNil(bool? durationMNotNil) =>
      _$this._durationMNotNil = durationMNotNil;

  bool? _hasReminder;
  bool? get hasReminder => _$this._hasReminder;
  set hasReminder(bool? hasReminder) => _$this._hasReminder = hasReminder;

  bool? _hasReminderNEQ;
  bool? get hasReminderNEQ => _$this._hasReminderNEQ;
  set hasReminderNEQ(bool? hasReminderNEQ) =>
      _$this._hasReminderNEQ = hasReminderNEQ;

  GTimeBuilder? _reminderTime;
  GTimeBuilder get reminderTime => _$this._reminderTime ??= new GTimeBuilder();
  set reminderTime(GTimeBuilder? reminderTime) =>
      _$this._reminderTime = reminderTime;

  GTimeBuilder? _reminderTimeNEQ;
  GTimeBuilder get reminderTimeNEQ =>
      _$this._reminderTimeNEQ ??= new GTimeBuilder();
  set reminderTimeNEQ(GTimeBuilder? reminderTimeNEQ) =>
      _$this._reminderTimeNEQ = reminderTimeNEQ;

  ListBuilder<GTime>? _reminderTimeIn;
  ListBuilder<GTime> get reminderTimeIn =>
      _$this._reminderTimeIn ??= new ListBuilder<GTime>();
  set reminderTimeIn(ListBuilder<GTime>? reminderTimeIn) =>
      _$this._reminderTimeIn = reminderTimeIn;

  ListBuilder<GTime>? _reminderTimeNotIn;
  ListBuilder<GTime> get reminderTimeNotIn =>
      _$this._reminderTimeNotIn ??= new ListBuilder<GTime>();
  set reminderTimeNotIn(ListBuilder<GTime>? reminderTimeNotIn) =>
      _$this._reminderTimeNotIn = reminderTimeNotIn;

  GTimeBuilder? _reminderTimeGT;
  GTimeBuilder get reminderTimeGT =>
      _$this._reminderTimeGT ??= new GTimeBuilder();
  set reminderTimeGT(GTimeBuilder? reminderTimeGT) =>
      _$this._reminderTimeGT = reminderTimeGT;

  GTimeBuilder? _reminderTimeGTE;
  GTimeBuilder get reminderTimeGTE =>
      _$this._reminderTimeGTE ??= new GTimeBuilder();
  set reminderTimeGTE(GTimeBuilder? reminderTimeGTE) =>
      _$this._reminderTimeGTE = reminderTimeGTE;

  GTimeBuilder? _reminderTimeLT;
  GTimeBuilder get reminderTimeLT =>
      _$this._reminderTimeLT ??= new GTimeBuilder();
  set reminderTimeLT(GTimeBuilder? reminderTimeLT) =>
      _$this._reminderTimeLT = reminderTimeLT;

  GTimeBuilder? _reminderTimeLTE;
  GTimeBuilder get reminderTimeLTE =>
      _$this._reminderTimeLTE ??= new GTimeBuilder();
  set reminderTimeLTE(GTimeBuilder? reminderTimeLTE) =>
      _$this._reminderTimeLTE = reminderTimeLTE;

  bool? _reminderTimeIsNil;
  bool? get reminderTimeIsNil => _$this._reminderTimeIsNil;
  set reminderTimeIsNil(bool? reminderTimeIsNil) =>
      _$this._reminderTimeIsNil = reminderTimeIsNil;

  bool? _reminderTimeNotNil;
  bool? get reminderTimeNotNil => _$this._reminderTimeNotNil;
  set reminderTimeNotNil(bool? reminderTimeNotNil) =>
      _$this._reminderTimeNotNil = reminderTimeNotNil;

  String? _recurringDays;
  String? get recurringDays => _$this._recurringDays;
  set recurringDays(String? recurringDays) =>
      _$this._recurringDays = recurringDays;

  String? _recurringDaysNEQ;
  String? get recurringDaysNEQ => _$this._recurringDaysNEQ;
  set recurringDaysNEQ(String? recurringDaysNEQ) =>
      _$this._recurringDaysNEQ = recurringDaysNEQ;

  ListBuilder<String>? _recurringDaysIn;
  ListBuilder<String> get recurringDaysIn =>
      _$this._recurringDaysIn ??= new ListBuilder<String>();
  set recurringDaysIn(ListBuilder<String>? recurringDaysIn) =>
      _$this._recurringDaysIn = recurringDaysIn;

  ListBuilder<String>? _recurringDaysNotIn;
  ListBuilder<String> get recurringDaysNotIn =>
      _$this._recurringDaysNotIn ??= new ListBuilder<String>();
  set recurringDaysNotIn(ListBuilder<String>? recurringDaysNotIn) =>
      _$this._recurringDaysNotIn = recurringDaysNotIn;

  String? _recurringDaysGT;
  String? get recurringDaysGT => _$this._recurringDaysGT;
  set recurringDaysGT(String? recurringDaysGT) =>
      _$this._recurringDaysGT = recurringDaysGT;

  String? _recurringDaysGTE;
  String? get recurringDaysGTE => _$this._recurringDaysGTE;
  set recurringDaysGTE(String? recurringDaysGTE) =>
      _$this._recurringDaysGTE = recurringDaysGTE;

  String? _recurringDaysLT;
  String? get recurringDaysLT => _$this._recurringDaysLT;
  set recurringDaysLT(String? recurringDaysLT) =>
      _$this._recurringDaysLT = recurringDaysLT;

  String? _recurringDaysLTE;
  String? get recurringDaysLTE => _$this._recurringDaysLTE;
  set recurringDaysLTE(String? recurringDaysLTE) =>
      _$this._recurringDaysLTE = recurringDaysLTE;

  String? _recurringDaysContains;
  String? get recurringDaysContains => _$this._recurringDaysContains;
  set recurringDaysContains(String? recurringDaysContains) =>
      _$this._recurringDaysContains = recurringDaysContains;

  String? _recurringDaysHasPrefix;
  String? get recurringDaysHasPrefix => _$this._recurringDaysHasPrefix;
  set recurringDaysHasPrefix(String? recurringDaysHasPrefix) =>
      _$this._recurringDaysHasPrefix = recurringDaysHasPrefix;

  String? _recurringDaysHasSuffix;
  String? get recurringDaysHasSuffix => _$this._recurringDaysHasSuffix;
  set recurringDaysHasSuffix(String? recurringDaysHasSuffix) =>
      _$this._recurringDaysHasSuffix = recurringDaysHasSuffix;

  bool? _recurringDaysIsNil;
  bool? get recurringDaysIsNil => _$this._recurringDaysIsNil;
  set recurringDaysIsNil(bool? recurringDaysIsNil) =>
      _$this._recurringDaysIsNil = recurringDaysIsNil;

  bool? _recurringDaysNotNil;
  bool? get recurringDaysNotNil => _$this._recurringDaysNotNil;
  set recurringDaysNotNil(bool? recurringDaysNotNil) =>
      _$this._recurringDaysNotNil = recurringDaysNotNil;

  String? _recurringDaysEqualFold;
  String? get recurringDaysEqualFold => _$this._recurringDaysEqualFold;
  set recurringDaysEqualFold(String? recurringDaysEqualFold) =>
      _$this._recurringDaysEqualFold = recurringDaysEqualFold;

  String? _recurringDaysContainsFold;
  String? get recurringDaysContainsFold => _$this._recurringDaysContainsFold;
  set recurringDaysContainsFold(String? recurringDaysContainsFold) =>
      _$this._recurringDaysContainsFold = recurringDaysContainsFold;

  GTaskStatus? _status;
  GTaskStatus? get status => _$this._status;
  set status(GTaskStatus? status) => _$this._status = status;

  GTaskStatus? _statusNEQ;
  GTaskStatus? get statusNEQ => _$this._statusNEQ;
  set statusNEQ(GTaskStatus? statusNEQ) => _$this._statusNEQ = statusNEQ;

  ListBuilder<GTaskStatus>? _statusIn;
  ListBuilder<GTaskStatus> get statusIn =>
      _$this._statusIn ??= new ListBuilder<GTaskStatus>();
  set statusIn(ListBuilder<GTaskStatus>? statusIn) =>
      _$this._statusIn = statusIn;

  ListBuilder<GTaskStatus>? _statusNotIn;
  ListBuilder<GTaskStatus> get statusNotIn =>
      _$this._statusNotIn ??= new ListBuilder<GTaskStatus>();
  set statusNotIn(ListBuilder<GTaskStatus>? statusNotIn) =>
      _$this._statusNotIn = statusNotIn;

  bool? _hasUser;
  bool? get hasUser => _$this._hasUser;
  set hasUser(bool? hasUser) => _$this._hasUser = hasUser;

  ListBuilder<GUserWhereInput>? _hasUserWith;
  ListBuilder<GUserWhereInput> get hasUserWith =>
      _$this._hasUserWith ??= new ListBuilder<GUserWhereInput>();
  set hasUserWith(ListBuilder<GUserWhereInput>? hasUserWith) =>
      _$this._hasUserWith = hasUserWith;

  bool? _hasGoal;
  bool? get hasGoal => _$this._hasGoal;
  set hasGoal(bool? hasGoal) => _$this._hasGoal = hasGoal;

  ListBuilder<GGoalWhereInput>? _hasGoalWith;
  ListBuilder<GGoalWhereInput> get hasGoalWith =>
      _$this._hasGoalWith ??= new ListBuilder<GGoalWhereInput>();
  set hasGoalWith(ListBuilder<GGoalWhereInput>? hasGoalWith) =>
      _$this._hasGoalWith = hasGoalWith;

  bool? _hasTags;
  bool? get hasTags => _$this._hasTags;
  set hasTags(bool? hasTags) => _$this._hasTags = hasTags;

  ListBuilder<GTagWhereInput>? _hasTagsWith;
  ListBuilder<GTagWhereInput> get hasTagsWith =>
      _$this._hasTagsWith ??= new ListBuilder<GTagWhereInput>();
  set hasTagsWith(ListBuilder<GTagWhereInput>? hasTagsWith) =>
      _$this._hasTagsWith = hasTagsWith;

  GTaskWhereInputBuilder();

  GTaskWhereInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _not = $v.not?.toBuilder();
      _and = $v.and?.toBuilder();
      _or = $v.or?.toBuilder();
      _id = $v.id;
      _idNEQ = $v.idNEQ;
      _idIn = $v.idIn?.toBuilder();
      _idNotIn = $v.idNotIn?.toBuilder();
      _idGT = $v.idGT;
      _idGTE = $v.idGTE;
      _idLT = $v.idLT;
      _idLTE = $v.idLTE;
      _createdAt = $v.createdAt?.toBuilder();
      _createdAtNEQ = $v.createdAtNEQ?.toBuilder();
      _createdAtIn = $v.createdAtIn?.toBuilder();
      _createdAtNotIn = $v.createdAtNotIn?.toBuilder();
      _createdAtGT = $v.createdAtGT?.toBuilder();
      _createdAtGTE = $v.createdAtGTE?.toBuilder();
      _createdAtLT = $v.createdAtLT?.toBuilder();
      _createdAtLTE = $v.createdAtLTE?.toBuilder();
      _updatedAt = $v.updatedAt?.toBuilder();
      _updatedAtNEQ = $v.updatedAtNEQ?.toBuilder();
      _updatedAtIn = $v.updatedAtIn?.toBuilder();
      _updatedAtNotIn = $v.updatedAtNotIn?.toBuilder();
      _updatedAtGT = $v.updatedAtGT?.toBuilder();
      _updatedAtGTE = $v.updatedAtGTE?.toBuilder();
      _updatedAtLT = $v.updatedAtLT?.toBuilder();
      _updatedAtLTE = $v.updatedAtLTE?.toBuilder();
      _title = $v.title;
      _titleNEQ = $v.titleNEQ;
      _titleIn = $v.titleIn?.toBuilder();
      _titleNotIn = $v.titleNotIn?.toBuilder();
      _titleGT = $v.titleGT;
      _titleGTE = $v.titleGTE;
      _titleLT = $v.titleLT;
      _titleLTE = $v.titleLTE;
      _titleContains = $v.titleContains;
      _titleHasPrefix = $v.titleHasPrefix;
      _titleHasSuffix = $v.titleHasSuffix;
      _titleEqualFold = $v.titleEqualFold;
      _titleContainsFold = $v.titleContainsFold;
      _shortDescription = $v.shortDescription;
      _shortDescriptionNEQ = $v.shortDescriptionNEQ;
      _shortDescriptionIn = $v.shortDescriptionIn?.toBuilder();
      _shortDescriptionNotIn = $v.shortDescriptionNotIn?.toBuilder();
      _shortDescriptionGT = $v.shortDescriptionGT;
      _shortDescriptionGTE = $v.shortDescriptionGTE;
      _shortDescriptionLT = $v.shortDescriptionLT;
      _shortDescriptionLTE = $v.shortDescriptionLTE;
      _shortDescriptionContains = $v.shortDescriptionContains;
      _shortDescriptionHasPrefix = $v.shortDescriptionHasPrefix;
      _shortDescriptionHasSuffix = $v.shortDescriptionHasSuffix;
      _shortDescriptionIsNil = $v.shortDescriptionIsNil;
      _shortDescriptionNotNil = $v.shortDescriptionNotNil;
      _shortDescriptionEqualFold = $v.shortDescriptionEqualFold;
      _shortDescriptionContainsFold = $v.shortDescriptionContainsFold;
      _note = $v.note;
      _noteNEQ = $v.noteNEQ;
      _noteIn = $v.noteIn?.toBuilder();
      _noteNotIn = $v.noteNotIn?.toBuilder();
      _noteGT = $v.noteGT;
      _noteGTE = $v.noteGTE;
      _noteLT = $v.noteLT;
      _noteLTE = $v.noteLTE;
      _noteContains = $v.noteContains;
      _noteHasPrefix = $v.noteHasPrefix;
      _noteHasSuffix = $v.noteHasSuffix;
      _noteIsNil = $v.noteIsNil;
      _noteNotNil = $v.noteNotNil;
      _noteEqualFold = $v.noteEqualFold;
      _noteContainsFold = $v.noteContainsFold;
      _type = $v.type;
      _typeNEQ = $v.typeNEQ;
      _typeIn = $v.typeIn?.toBuilder();
      _typeNotIn = $v.typeNotIn?.toBuilder();
      _date = $v.date?.toBuilder();
      _dateNEQ = $v.dateNEQ?.toBuilder();
      _dateIn = $v.dateIn?.toBuilder();
      _dateNotIn = $v.dateNotIn?.toBuilder();
      _dateGT = $v.dateGT?.toBuilder();
      _dateGTE = $v.dateGTE?.toBuilder();
      _dateLT = $v.dateLT?.toBuilder();
      _dateLTE = $v.dateLTE?.toBuilder();
      _durationM = $v.durationM;
      _durationMNEQ = $v.durationMNEQ;
      _durationMIn = $v.durationMIn?.toBuilder();
      _durationMNotIn = $v.durationMNotIn?.toBuilder();
      _durationMGT = $v.durationMGT;
      _durationMGTE = $v.durationMGTE;
      _durationMLT = $v.durationMLT;
      _durationMLTE = $v.durationMLTE;
      _durationMIsNil = $v.durationMIsNil;
      _durationMNotNil = $v.durationMNotNil;
      _hasReminder = $v.hasReminder;
      _hasReminderNEQ = $v.hasReminderNEQ;
      _reminderTime = $v.reminderTime?.toBuilder();
      _reminderTimeNEQ = $v.reminderTimeNEQ?.toBuilder();
      _reminderTimeIn = $v.reminderTimeIn?.toBuilder();
      _reminderTimeNotIn = $v.reminderTimeNotIn?.toBuilder();
      _reminderTimeGT = $v.reminderTimeGT?.toBuilder();
      _reminderTimeGTE = $v.reminderTimeGTE?.toBuilder();
      _reminderTimeLT = $v.reminderTimeLT?.toBuilder();
      _reminderTimeLTE = $v.reminderTimeLTE?.toBuilder();
      _reminderTimeIsNil = $v.reminderTimeIsNil;
      _reminderTimeNotNil = $v.reminderTimeNotNil;
      _recurringDays = $v.recurringDays;
      _recurringDaysNEQ = $v.recurringDaysNEQ;
      _recurringDaysIn = $v.recurringDaysIn?.toBuilder();
      _recurringDaysNotIn = $v.recurringDaysNotIn?.toBuilder();
      _recurringDaysGT = $v.recurringDaysGT;
      _recurringDaysGTE = $v.recurringDaysGTE;
      _recurringDaysLT = $v.recurringDaysLT;
      _recurringDaysLTE = $v.recurringDaysLTE;
      _recurringDaysContains = $v.recurringDaysContains;
      _recurringDaysHasPrefix = $v.recurringDaysHasPrefix;
      _recurringDaysHasSuffix = $v.recurringDaysHasSuffix;
      _recurringDaysIsNil = $v.recurringDaysIsNil;
      _recurringDaysNotNil = $v.recurringDaysNotNil;
      _recurringDaysEqualFold = $v.recurringDaysEqualFold;
      _recurringDaysContainsFold = $v.recurringDaysContainsFold;
      _status = $v.status;
      _statusNEQ = $v.statusNEQ;
      _statusIn = $v.statusIn?.toBuilder();
      _statusNotIn = $v.statusNotIn?.toBuilder();
      _hasUser = $v.hasUser;
      _hasUserWith = $v.hasUserWith?.toBuilder();
      _hasGoal = $v.hasGoal;
      _hasGoalWith = $v.hasGoalWith?.toBuilder();
      _hasTags = $v.hasTags;
      _hasTagsWith = $v.hasTagsWith?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GTaskWhereInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GTaskWhereInput;
  }

  @override
  void update(void Function(GTaskWhereInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GTaskWhereInput build() => _build();

  _$GTaskWhereInput _build() {
    _$GTaskWhereInput _$result;
    try {
      _$result = _$v ??
          new _$GTaskWhereInput._(
              not: _not?.build(),
              and: _and?.build(),
              or: _or?.build(),
              id: id,
              idNEQ: idNEQ,
              idIn: _idIn?.build(),
              idNotIn: _idNotIn?.build(),
              idGT: idGT,
              idGTE: idGTE,
              idLT: idLT,
              idLTE: idLTE,
              createdAt: _createdAt?.build(),
              createdAtNEQ: _createdAtNEQ?.build(),
              createdAtIn: _createdAtIn?.build(),
              createdAtNotIn: _createdAtNotIn?.build(),
              createdAtGT: _createdAtGT?.build(),
              createdAtGTE: _createdAtGTE?.build(),
              createdAtLT: _createdAtLT?.build(),
              createdAtLTE: _createdAtLTE?.build(),
              updatedAt: _updatedAt?.build(),
              updatedAtNEQ: _updatedAtNEQ?.build(),
              updatedAtIn: _updatedAtIn?.build(),
              updatedAtNotIn: _updatedAtNotIn?.build(),
              updatedAtGT: _updatedAtGT?.build(),
              updatedAtGTE: _updatedAtGTE?.build(),
              updatedAtLT: _updatedAtLT?.build(),
              updatedAtLTE: _updatedAtLTE?.build(),
              title: title,
              titleNEQ: titleNEQ,
              titleIn: _titleIn?.build(),
              titleNotIn: _titleNotIn?.build(),
              titleGT: titleGT,
              titleGTE: titleGTE,
              titleLT: titleLT,
              titleLTE: titleLTE,
              titleContains: titleContains,
              titleHasPrefix: titleHasPrefix,
              titleHasSuffix: titleHasSuffix,
              titleEqualFold: titleEqualFold,
              titleContainsFold: titleContainsFold,
              shortDescription: shortDescription,
              shortDescriptionNEQ: shortDescriptionNEQ,
              shortDescriptionIn: _shortDescriptionIn?.build(),
              shortDescriptionNotIn: _shortDescriptionNotIn?.build(),
              shortDescriptionGT: shortDescriptionGT,
              shortDescriptionGTE: shortDescriptionGTE,
              shortDescriptionLT: shortDescriptionLT,
              shortDescriptionLTE: shortDescriptionLTE,
              shortDescriptionContains: shortDescriptionContains,
              shortDescriptionHasPrefix: shortDescriptionHasPrefix,
              shortDescriptionHasSuffix: shortDescriptionHasSuffix,
              shortDescriptionIsNil: shortDescriptionIsNil,
              shortDescriptionNotNil: shortDescriptionNotNil,
              shortDescriptionEqualFold: shortDescriptionEqualFold,
              shortDescriptionContainsFold: shortDescriptionContainsFold,
              note: note,
              noteNEQ: noteNEQ,
              noteIn: _noteIn?.build(),
              noteNotIn: _noteNotIn?.build(),
              noteGT: noteGT,
              noteGTE: noteGTE,
              noteLT: noteLT,
              noteLTE: noteLTE,
              noteContains: noteContains,
              noteHasPrefix: noteHasPrefix,
              noteHasSuffix: noteHasSuffix,
              noteIsNil: noteIsNil,
              noteNotNil: noteNotNil,
              noteEqualFold: noteEqualFold,
              noteContainsFold: noteContainsFold,
              type: type,
              typeNEQ: typeNEQ,
              typeIn: _typeIn?.build(),
              typeNotIn: _typeNotIn?.build(),
              date: _date?.build(),
              dateNEQ: _dateNEQ?.build(),
              dateIn: _dateIn?.build(),
              dateNotIn: _dateNotIn?.build(),
              dateGT: _dateGT?.build(),
              dateGTE: _dateGTE?.build(),
              dateLT: _dateLT?.build(),
              dateLTE: _dateLTE?.build(),
              durationM: durationM,
              durationMNEQ: durationMNEQ,
              durationMIn: _durationMIn?.build(),
              durationMNotIn: _durationMNotIn?.build(),
              durationMGT: durationMGT,
              durationMGTE: durationMGTE,
              durationMLT: durationMLT,
              durationMLTE: durationMLTE,
              durationMIsNil: durationMIsNil,
              durationMNotNil: durationMNotNil,
              hasReminder: hasReminder,
              hasReminderNEQ: hasReminderNEQ,
              reminderTime: _reminderTime?.build(),
              reminderTimeNEQ: _reminderTimeNEQ?.build(),
              reminderTimeIn: _reminderTimeIn?.build(),
              reminderTimeNotIn: _reminderTimeNotIn?.build(),
              reminderTimeGT: _reminderTimeGT?.build(),
              reminderTimeGTE: _reminderTimeGTE?.build(),
              reminderTimeLT: _reminderTimeLT?.build(),
              reminderTimeLTE: _reminderTimeLTE?.build(),
              reminderTimeIsNil: reminderTimeIsNil,
              reminderTimeNotNil: reminderTimeNotNil,
              recurringDays: recurringDays,
              recurringDaysNEQ: recurringDaysNEQ,
              recurringDaysIn: _recurringDaysIn?.build(),
              recurringDaysNotIn: _recurringDaysNotIn?.build(),
              recurringDaysGT: recurringDaysGT,
              recurringDaysGTE: recurringDaysGTE,
              recurringDaysLT: recurringDaysLT,
              recurringDaysLTE: recurringDaysLTE,
              recurringDaysContains: recurringDaysContains,
              recurringDaysHasPrefix: recurringDaysHasPrefix,
              recurringDaysHasSuffix: recurringDaysHasSuffix,
              recurringDaysIsNil: recurringDaysIsNil,
              recurringDaysNotNil: recurringDaysNotNil,
              recurringDaysEqualFold: recurringDaysEqualFold,
              recurringDaysContainsFold: recurringDaysContainsFold,
              status: status,
              statusNEQ: statusNEQ,
              statusIn: _statusIn?.build(),
              statusNotIn: _statusNotIn?.build(),
              hasUser: hasUser,
              hasUserWith: _hasUserWith?.build(),
              hasGoal: hasGoal,
              hasGoalWith: _hasGoalWith?.build(),
              hasTags: hasTags,
              hasTagsWith: _hasTagsWith?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'not';
        _not?.build();
        _$failedField = 'and';
        _and?.build();
        _$failedField = 'or';
        _or?.build();

        _$failedField = 'idIn';
        _idIn?.build();
        _$failedField = 'idNotIn';
        _idNotIn?.build();

        _$failedField = 'createdAt';
        _createdAt?.build();
        _$failedField = 'createdAtNEQ';
        _createdAtNEQ?.build();
        _$failedField = 'createdAtIn';
        _createdAtIn?.build();
        _$failedField = 'createdAtNotIn';
        _createdAtNotIn?.build();
        _$failedField = 'createdAtGT';
        _createdAtGT?.build();
        _$failedField = 'createdAtGTE';
        _createdAtGTE?.build();
        _$failedField = 'createdAtLT';
        _createdAtLT?.build();
        _$failedField = 'createdAtLTE';
        _createdAtLTE?.build();
        _$failedField = 'updatedAt';
        _updatedAt?.build();
        _$failedField = 'updatedAtNEQ';
        _updatedAtNEQ?.build();
        _$failedField = 'updatedAtIn';
        _updatedAtIn?.build();
        _$failedField = 'updatedAtNotIn';
        _updatedAtNotIn?.build();
        _$failedField = 'updatedAtGT';
        _updatedAtGT?.build();
        _$failedField = 'updatedAtGTE';
        _updatedAtGTE?.build();
        _$failedField = 'updatedAtLT';
        _updatedAtLT?.build();
        _$failedField = 'updatedAtLTE';
        _updatedAtLTE?.build();

        _$failedField = 'titleIn';
        _titleIn?.build();
        _$failedField = 'titleNotIn';
        _titleNotIn?.build();

        _$failedField = 'shortDescriptionIn';
        _shortDescriptionIn?.build();
        _$failedField = 'shortDescriptionNotIn';
        _shortDescriptionNotIn?.build();

        _$failedField = 'noteIn';
        _noteIn?.build();
        _$failedField = 'noteNotIn';
        _noteNotIn?.build();

        _$failedField = 'typeIn';
        _typeIn?.build();
        _$failedField = 'typeNotIn';
        _typeNotIn?.build();
        _$failedField = 'date';
        _date?.build();
        _$failedField = 'dateNEQ';
        _dateNEQ?.build();
        _$failedField = 'dateIn';
        _dateIn?.build();
        _$failedField = 'dateNotIn';
        _dateNotIn?.build();
        _$failedField = 'dateGT';
        _dateGT?.build();
        _$failedField = 'dateGTE';
        _dateGTE?.build();
        _$failedField = 'dateLT';
        _dateLT?.build();
        _$failedField = 'dateLTE';
        _dateLTE?.build();

        _$failedField = 'durationMIn';
        _durationMIn?.build();
        _$failedField = 'durationMNotIn';
        _durationMNotIn?.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();
        _$failedField = 'reminderTimeNEQ';
        _reminderTimeNEQ?.build();
        _$failedField = 'reminderTimeIn';
        _reminderTimeIn?.build();
        _$failedField = 'reminderTimeNotIn';
        _reminderTimeNotIn?.build();
        _$failedField = 'reminderTimeGT';
        _reminderTimeGT?.build();
        _$failedField = 'reminderTimeGTE';
        _reminderTimeGTE?.build();
        _$failedField = 'reminderTimeLT';
        _reminderTimeLT?.build();
        _$failedField = 'reminderTimeLTE';
        _reminderTimeLTE?.build();

        _$failedField = 'recurringDaysIn';
        _recurringDaysIn?.build();
        _$failedField = 'recurringDaysNotIn';
        _recurringDaysNotIn?.build();

        _$failedField = 'statusIn';
        _statusIn?.build();
        _$failedField = 'statusNotIn';
        _statusNotIn?.build();

        _$failedField = 'hasUserWith';
        _hasUserWith?.build();

        _$failedField = 'hasGoalWith';
        _hasGoalWith?.build();

        _$failedField = 'hasTagsWith';
        _hasTagsWith?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GTaskWhereInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUpdateGoalInput extends GUpdateGoalInput {
  @override
  final String? title;
  @override
  final String? note;
  @override
  final GTime? targetDate;
  @override
  final GGoalStatus? status;

  factory _$GUpdateGoalInput(
          [void Function(GUpdateGoalInputBuilder)? updates]) =>
      (new GUpdateGoalInputBuilder()..update(updates))._build();

  _$GUpdateGoalInput._({this.title, this.note, this.targetDate, this.status})
      : super._();

  @override
  GUpdateGoalInput rebuild(void Function(GUpdateGoalInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateGoalInputBuilder toBuilder() =>
      new GUpdateGoalInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateGoalInput &&
        title == other.title &&
        note == other.note &&
        targetDate == other.targetDate &&
        status == other.status;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, targetDate.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateGoalInput')
          ..add('title', title)
          ..add('note', note)
          ..add('targetDate', targetDate)
          ..add('status', status))
        .toString();
  }
}

class GUpdateGoalInputBuilder
    implements Builder<GUpdateGoalInput, GUpdateGoalInputBuilder> {
  _$GUpdateGoalInput? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GTimeBuilder? _targetDate;
  GTimeBuilder get targetDate => _$this._targetDate ??= new GTimeBuilder();
  set targetDate(GTimeBuilder? targetDate) => _$this._targetDate = targetDate;

  GGoalStatus? _status;
  GGoalStatus? get status => _$this._status;
  set status(GGoalStatus? status) => _$this._status = status;

  GUpdateGoalInputBuilder();

  GUpdateGoalInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _note = $v.note;
      _targetDate = $v.targetDate?.toBuilder();
      _status = $v.status;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateGoalInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUpdateGoalInput;
  }

  @override
  void update(void Function(GUpdateGoalInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateGoalInput build() => _build();

  _$GUpdateGoalInput _build() {
    _$GUpdateGoalInput _$result;
    try {
      _$result = _$v ??
          new _$GUpdateGoalInput._(
              title: title,
              note: note,
              targetDate: _targetDate?.build(),
              status: status);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'targetDate';
        _targetDate?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GUpdateGoalInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUpdateProfileInput extends GUpdateProfileInput {
  @override
  final String? fullName;
  @override
  final GTime? birthDate;
  @override
  final GUserStudyTime? studyTime;
  @override
  final String? major;
  @override
  final String? bio;

  factory _$GUpdateProfileInput(
          [void Function(GUpdateProfileInputBuilder)? updates]) =>
      (new GUpdateProfileInputBuilder()..update(updates))._build();

  _$GUpdateProfileInput._(
      {this.fullName, this.birthDate, this.studyTime, this.major, this.bio})
      : super._();

  @override
  GUpdateProfileInput rebuild(
          void Function(GUpdateProfileInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateProfileInputBuilder toBuilder() =>
      new GUpdateProfileInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateProfileInput &&
        fullName == other.fullName &&
        birthDate == other.birthDate &&
        studyTime == other.studyTime &&
        major == other.major &&
        bio == other.bio;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, studyTime.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateProfileInput')
          ..add('fullName', fullName)
          ..add('birthDate', birthDate)
          ..add('studyTime', studyTime)
          ..add('major', major)
          ..add('bio', bio))
        .toString();
  }
}

class GUpdateProfileInputBuilder
    implements Builder<GUpdateProfileInput, GUpdateProfileInputBuilder> {
  _$GUpdateProfileInput? _$v;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  GTimeBuilder? _birthDate;
  GTimeBuilder get birthDate => _$this._birthDate ??= new GTimeBuilder();
  set birthDate(GTimeBuilder? birthDate) => _$this._birthDate = birthDate;

  GUserStudyTime? _studyTime;
  GUserStudyTime? get studyTime => _$this._studyTime;
  set studyTime(GUserStudyTime? studyTime) => _$this._studyTime = studyTime;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  GUpdateProfileInputBuilder();

  GUpdateProfileInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _fullName = $v.fullName;
      _birthDate = $v.birthDate?.toBuilder();
      _studyTime = $v.studyTime;
      _major = $v.major;
      _bio = $v.bio;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateProfileInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUpdateProfileInput;
  }

  @override
  void update(void Function(GUpdateProfileInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateProfileInput build() => _build();

  _$GUpdateProfileInput _build() {
    _$GUpdateProfileInput _$result;
    try {
      _$result = _$v ??
          new _$GUpdateProfileInput._(
              fullName: fullName,
              birthDate: _birthDate?.build(),
              studyTime: studyTime,
              major: major,
              bio: bio);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'birthDate';
        _birthDate?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GUpdateProfileInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUpdateTaskInput extends GUpdateTaskInput {
  @override
  final String? title;
  @override
  final String? shortDescription;
  @override
  final GTaskType? type;
  @override
  final String? note;
  @override
  final GTime? date;
  @override
  final int? durationM;
  @override
  final bool? hasReminder;
  @override
  final GTime? reminderTime;
  @override
  final String? recurringDays;
  @override
  final GTaskStatus? status;
  @override
  final String? goalID;
  @override
  final BuiltList<String>? tagNames;

  factory _$GUpdateTaskInput(
          [void Function(GUpdateTaskInputBuilder)? updates]) =>
      (new GUpdateTaskInputBuilder()..update(updates))._build();

  _$GUpdateTaskInput._(
      {this.title,
      this.shortDescription,
      this.type,
      this.note,
      this.date,
      this.durationM,
      this.hasReminder,
      this.reminderTime,
      this.recurringDays,
      this.status,
      this.goalID,
      this.tagNames})
      : super._();

  @override
  GUpdateTaskInput rebuild(void Function(GUpdateTaskInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateTaskInputBuilder toBuilder() =>
      new GUpdateTaskInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateTaskInput &&
        title == other.title &&
        shortDescription == other.shortDescription &&
        type == other.type &&
        note == other.note &&
        date == other.date &&
        durationM == other.durationM &&
        hasReminder == other.hasReminder &&
        reminderTime == other.reminderTime &&
        recurringDays == other.recurringDays &&
        status == other.status &&
        goalID == other.goalID &&
        tagNames == other.tagNames;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, shortDescription.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, durationM.hashCode);
    _$hash = $jc(_$hash, hasReminder.hashCode);
    _$hash = $jc(_$hash, reminderTime.hashCode);
    _$hash = $jc(_$hash, recurringDays.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, goalID.hashCode);
    _$hash = $jc(_$hash, tagNames.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateTaskInput')
          ..add('title', title)
          ..add('shortDescription', shortDescription)
          ..add('type', type)
          ..add('note', note)
          ..add('date', date)
          ..add('durationM', durationM)
          ..add('hasReminder', hasReminder)
          ..add('reminderTime', reminderTime)
          ..add('recurringDays', recurringDays)
          ..add('status', status)
          ..add('goalID', goalID)
          ..add('tagNames', tagNames))
        .toString();
  }
}

class GUpdateTaskInputBuilder
    implements Builder<GUpdateTaskInput, GUpdateTaskInputBuilder> {
  _$GUpdateTaskInput? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _shortDescription;
  String? get shortDescription => _$this._shortDescription;
  set shortDescription(String? shortDescription) =>
      _$this._shortDescription = shortDescription;

  GTaskType? _type;
  GTaskType? get type => _$this._type;
  set type(GTaskType? type) => _$this._type = type;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  GTimeBuilder? _date;
  GTimeBuilder get date => _$this._date ??= new GTimeBuilder();
  set date(GTimeBuilder? date) => _$this._date = date;

  int? _durationM;
  int? get durationM => _$this._durationM;
  set durationM(int? durationM) => _$this._durationM = durationM;

  bool? _hasReminder;
  bool? get hasReminder => _$this._hasReminder;
  set hasReminder(bool? hasReminder) => _$this._hasReminder = hasReminder;

  GTimeBuilder? _reminderTime;
  GTimeBuilder get reminderTime => _$this._reminderTime ??= new GTimeBuilder();
  set reminderTime(GTimeBuilder? reminderTime) =>
      _$this._reminderTime = reminderTime;

  String? _recurringDays;
  String? get recurringDays => _$this._recurringDays;
  set recurringDays(String? recurringDays) =>
      _$this._recurringDays = recurringDays;

  GTaskStatus? _status;
  GTaskStatus? get status => _$this._status;
  set status(GTaskStatus? status) => _$this._status = status;

  String? _goalID;
  String? get goalID => _$this._goalID;
  set goalID(String? goalID) => _$this._goalID = goalID;

  ListBuilder<String>? _tagNames;
  ListBuilder<String> get tagNames =>
      _$this._tagNames ??= new ListBuilder<String>();
  set tagNames(ListBuilder<String>? tagNames) => _$this._tagNames = tagNames;

  GUpdateTaskInputBuilder();

  GUpdateTaskInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _shortDescription = $v.shortDescription;
      _type = $v.type;
      _note = $v.note;
      _date = $v.date?.toBuilder();
      _durationM = $v.durationM;
      _hasReminder = $v.hasReminder;
      _reminderTime = $v.reminderTime?.toBuilder();
      _recurringDays = $v.recurringDays;
      _status = $v.status;
      _goalID = $v.goalID;
      _tagNames = $v.tagNames?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateTaskInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUpdateTaskInput;
  }

  @override
  void update(void Function(GUpdateTaskInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateTaskInput build() => _build();

  _$GUpdateTaskInput _build() {
    _$GUpdateTaskInput _$result;
    try {
      _$result = _$v ??
          new _$GUpdateTaskInput._(
              title: title,
              shortDescription: shortDescription,
              type: type,
              note: note,
              date: _date?.build(),
              durationM: durationM,
              hasReminder: hasReminder,
              reminderTime: _reminderTime?.build(),
              recurringDays: recurringDays,
              status: status,
              goalID: goalID,
              tagNames: _tagNames?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'date';
        _date?.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();

        _$failedField = 'tagNames';
        _tagNames?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GUpdateTaskInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUserOrder extends GUserOrder {
  @override
  final GOrderDirection direction;
  @override
  final GUserOrderField field;

  factory _$GUserOrder([void Function(GUserOrderBuilder)? updates]) =>
      (new GUserOrderBuilder()..update(updates))._build();

  _$GUserOrder._({required this.direction, required this.field}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        direction, r'GUserOrder', 'direction');
    BuiltValueNullFieldError.checkNotNull(field, r'GUserOrder', 'field');
  }

  @override
  GUserOrder rebuild(void Function(GUserOrderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUserOrderBuilder toBuilder() => new GUserOrderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUserOrder &&
        direction == other.direction &&
        field == other.field;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, direction.hashCode);
    _$hash = $jc(_$hash, field.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUserOrder')
          ..add('direction', direction)
          ..add('field', field))
        .toString();
  }
}

class GUserOrderBuilder implements Builder<GUserOrder, GUserOrderBuilder> {
  _$GUserOrder? _$v;

  GOrderDirection? _direction;
  GOrderDirection? get direction => _$this._direction;
  set direction(GOrderDirection? direction) => _$this._direction = direction;

  GUserOrderField? _field;
  GUserOrderField? get field => _$this._field;
  set field(GUserOrderField? field) => _$this._field = field;

  GUserOrderBuilder();

  GUserOrderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _direction = $v.direction;
      _field = $v.field;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUserOrder other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUserOrder;
  }

  @override
  void update(void Function(GUserOrderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUserOrder build() => _build();

  _$GUserOrder _build() {
    final _$result = _$v ??
        new _$GUserOrder._(
            direction: BuiltValueNullFieldError.checkNotNull(
                direction, r'GUserOrder', 'direction'),
            field: BuiltValueNullFieldError.checkNotNull(
                field, r'GUserOrder', 'field'));
    replace(_$result);
    return _$result;
  }
}

class _$GUserWhereInput extends GUserWhereInput {
  @override
  final GUserWhereInput? not;
  @override
  final BuiltList<GUserWhereInput>? and;
  @override
  final BuiltList<GUserWhereInput>? or;
  @override
  final String? id;
  @override
  final String? idNEQ;
  @override
  final BuiltList<String>? idIn;
  @override
  final BuiltList<String>? idNotIn;
  @override
  final String? idGT;
  @override
  final String? idGTE;
  @override
  final String? idLT;
  @override
  final String? idLTE;
  @override
  final GTime? createdAt;
  @override
  final GTime? createdAtNEQ;
  @override
  final BuiltList<GTime>? createdAtIn;
  @override
  final BuiltList<GTime>? createdAtNotIn;
  @override
  final GTime? createdAtGT;
  @override
  final GTime? createdAtGTE;
  @override
  final GTime? createdAtLT;
  @override
  final GTime? createdAtLTE;
  @override
  final GTime? updatedAt;
  @override
  final GTime? updatedAtNEQ;
  @override
  final BuiltList<GTime>? updatedAtIn;
  @override
  final BuiltList<GTime>? updatedAtNotIn;
  @override
  final GTime? updatedAtGT;
  @override
  final GTime? updatedAtGTE;
  @override
  final GTime? updatedAtLT;
  @override
  final GTime? updatedAtLTE;
  @override
  final String? phoneNumber;
  @override
  final String? phoneNumberNEQ;
  @override
  final BuiltList<String>? phoneNumberIn;
  @override
  final BuiltList<String>? phoneNumberNotIn;
  @override
  final String? phoneNumberGT;
  @override
  final String? phoneNumberGTE;
  @override
  final String? phoneNumberLT;
  @override
  final String? phoneNumberLTE;
  @override
  final String? phoneNumberContains;
  @override
  final String? phoneNumberHasPrefix;
  @override
  final String? phoneNumberHasSuffix;
  @override
  final String? phoneNumberEqualFold;
  @override
  final String? phoneNumberContainsFold;
  @override
  final String? fullName;
  @override
  final String? fullNameNEQ;
  @override
  final BuiltList<String>? fullNameIn;
  @override
  final BuiltList<String>? fullNameNotIn;
  @override
  final String? fullNameGT;
  @override
  final String? fullNameGTE;
  @override
  final String? fullNameLT;
  @override
  final String? fullNameLTE;
  @override
  final String? fullNameContains;
  @override
  final String? fullNameHasPrefix;
  @override
  final String? fullNameHasSuffix;
  @override
  final bool? fullNameIsNil;
  @override
  final bool? fullNameNotNil;
  @override
  final String? fullNameEqualFold;
  @override
  final String? fullNameContainsFold;
  @override
  final GTime? birthDate;
  @override
  final GTime? birthDateNEQ;
  @override
  final BuiltList<GTime>? birthDateIn;
  @override
  final BuiltList<GTime>? birthDateNotIn;
  @override
  final GTime? birthDateGT;
  @override
  final GTime? birthDateGTE;
  @override
  final GTime? birthDateLT;
  @override
  final GTime? birthDateLTE;
  @override
  final bool? birthDateIsNil;
  @override
  final bool? birthDateNotNil;
  @override
  final GUserStudyTime? studyTime;
  @override
  final GUserStudyTime? studyTimeNEQ;
  @override
  final BuiltList<GUserStudyTime>? studyTimeIn;
  @override
  final BuiltList<GUserStudyTime>? studyTimeNotIn;
  @override
  final bool? studyTimeIsNil;
  @override
  final bool? studyTimeNotNil;
  @override
  final GUserRole? role;
  @override
  final GUserRole? roleNEQ;
  @override
  final BuiltList<GUserRole>? roleIn;
  @override
  final BuiltList<GUserRole>? roleNotIn;
  @override
  final int? simoCoins;
  @override
  final int? simoCoinsNEQ;
  @override
  final BuiltList<int>? simoCoinsIn;
  @override
  final BuiltList<int>? simoCoinsNotIn;
  @override
  final int? simoCoinsGT;
  @override
  final int? simoCoinsGTE;
  @override
  final int? simoCoinsLT;
  @override
  final int? simoCoinsLTE;
  @override
  final int? score;
  @override
  final int? scoreNEQ;
  @override
  final BuiltList<int>? scoreIn;
  @override
  final BuiltList<int>? scoreNotIn;
  @override
  final int? scoreGT;
  @override
  final int? scoreGTE;
  @override
  final int? scoreLT;
  @override
  final int? scoreLTE;
  @override
  final bool? isPremium;
  @override
  final bool? isPremiumNEQ;
  @override
  final String? major;
  @override
  final String? majorNEQ;
  @override
  final BuiltList<String>? majorIn;
  @override
  final BuiltList<String>? majorNotIn;
  @override
  final String? majorGT;
  @override
  final String? majorGTE;
  @override
  final String? majorLT;
  @override
  final String? majorLTE;
  @override
  final String? majorContains;
  @override
  final String? majorHasPrefix;
  @override
  final String? majorHasSuffix;
  @override
  final bool? majorIsNil;
  @override
  final bool? majorNotNil;
  @override
  final String? majorEqualFold;
  @override
  final String? majorContainsFold;
  @override
  final String? bio;
  @override
  final String? bioNEQ;
  @override
  final BuiltList<String>? bioIn;
  @override
  final BuiltList<String>? bioNotIn;
  @override
  final String? bioGT;
  @override
  final String? bioGTE;
  @override
  final String? bioLT;
  @override
  final String? bioLTE;
  @override
  final String? bioContains;
  @override
  final String? bioHasPrefix;
  @override
  final String? bioHasSuffix;
  @override
  final bool? bioIsNil;
  @override
  final bool? bioNotNil;
  @override
  final String? bioEqualFold;
  @override
  final String? bioContainsFold;
  @override
  final bool? hasInterests;
  @override
  final BuiltList<GInterestWhereInput>? hasInterestsWith;
  @override
  final bool? hasGoals;
  @override
  final BuiltList<GGoalWhereInput>? hasGoalsWith;
  @override
  final bool? hasTasks;
  @override
  final BuiltList<GTaskWhereInput>? hasTasksWith;

  factory _$GUserWhereInput([void Function(GUserWhereInputBuilder)? updates]) =>
      (new GUserWhereInputBuilder()..update(updates))._build();

  _$GUserWhereInput._(
      {this.not,
      this.and,
      this.or,
      this.id,
      this.idNEQ,
      this.idIn,
      this.idNotIn,
      this.idGT,
      this.idGTE,
      this.idLT,
      this.idLTE,
      this.createdAt,
      this.createdAtNEQ,
      this.createdAtIn,
      this.createdAtNotIn,
      this.createdAtGT,
      this.createdAtGTE,
      this.createdAtLT,
      this.createdAtLTE,
      this.updatedAt,
      this.updatedAtNEQ,
      this.updatedAtIn,
      this.updatedAtNotIn,
      this.updatedAtGT,
      this.updatedAtGTE,
      this.updatedAtLT,
      this.updatedAtLTE,
      this.phoneNumber,
      this.phoneNumberNEQ,
      this.phoneNumberIn,
      this.phoneNumberNotIn,
      this.phoneNumberGT,
      this.phoneNumberGTE,
      this.phoneNumberLT,
      this.phoneNumberLTE,
      this.phoneNumberContains,
      this.phoneNumberHasPrefix,
      this.phoneNumberHasSuffix,
      this.phoneNumberEqualFold,
      this.phoneNumberContainsFold,
      this.fullName,
      this.fullNameNEQ,
      this.fullNameIn,
      this.fullNameNotIn,
      this.fullNameGT,
      this.fullNameGTE,
      this.fullNameLT,
      this.fullNameLTE,
      this.fullNameContains,
      this.fullNameHasPrefix,
      this.fullNameHasSuffix,
      this.fullNameIsNil,
      this.fullNameNotNil,
      this.fullNameEqualFold,
      this.fullNameContainsFold,
      this.birthDate,
      this.birthDateNEQ,
      this.birthDateIn,
      this.birthDateNotIn,
      this.birthDateGT,
      this.birthDateGTE,
      this.birthDateLT,
      this.birthDateLTE,
      this.birthDateIsNil,
      this.birthDateNotNil,
      this.studyTime,
      this.studyTimeNEQ,
      this.studyTimeIn,
      this.studyTimeNotIn,
      this.studyTimeIsNil,
      this.studyTimeNotNil,
      this.role,
      this.roleNEQ,
      this.roleIn,
      this.roleNotIn,
      this.simoCoins,
      this.simoCoinsNEQ,
      this.simoCoinsIn,
      this.simoCoinsNotIn,
      this.simoCoinsGT,
      this.simoCoinsGTE,
      this.simoCoinsLT,
      this.simoCoinsLTE,
      this.score,
      this.scoreNEQ,
      this.scoreIn,
      this.scoreNotIn,
      this.scoreGT,
      this.scoreGTE,
      this.scoreLT,
      this.scoreLTE,
      this.isPremium,
      this.isPremiumNEQ,
      this.major,
      this.majorNEQ,
      this.majorIn,
      this.majorNotIn,
      this.majorGT,
      this.majorGTE,
      this.majorLT,
      this.majorLTE,
      this.majorContains,
      this.majorHasPrefix,
      this.majorHasSuffix,
      this.majorIsNil,
      this.majorNotNil,
      this.majorEqualFold,
      this.majorContainsFold,
      this.bio,
      this.bioNEQ,
      this.bioIn,
      this.bioNotIn,
      this.bioGT,
      this.bioGTE,
      this.bioLT,
      this.bioLTE,
      this.bioContains,
      this.bioHasPrefix,
      this.bioHasSuffix,
      this.bioIsNil,
      this.bioNotNil,
      this.bioEqualFold,
      this.bioContainsFold,
      this.hasInterests,
      this.hasInterestsWith,
      this.hasGoals,
      this.hasGoalsWith,
      this.hasTasks,
      this.hasTasksWith})
      : super._();

  @override
  GUserWhereInput rebuild(void Function(GUserWhereInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUserWhereInputBuilder toBuilder() =>
      new GUserWhereInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUserWhereInput &&
        not == other.not &&
        and == other.and &&
        or == other.or &&
        id == other.id &&
        idNEQ == other.idNEQ &&
        idIn == other.idIn &&
        idNotIn == other.idNotIn &&
        idGT == other.idGT &&
        idGTE == other.idGTE &&
        idLT == other.idLT &&
        idLTE == other.idLTE &&
        createdAt == other.createdAt &&
        createdAtNEQ == other.createdAtNEQ &&
        createdAtIn == other.createdAtIn &&
        createdAtNotIn == other.createdAtNotIn &&
        createdAtGT == other.createdAtGT &&
        createdAtGTE == other.createdAtGTE &&
        createdAtLT == other.createdAtLT &&
        createdAtLTE == other.createdAtLTE &&
        updatedAt == other.updatedAt &&
        updatedAtNEQ == other.updatedAtNEQ &&
        updatedAtIn == other.updatedAtIn &&
        updatedAtNotIn == other.updatedAtNotIn &&
        updatedAtGT == other.updatedAtGT &&
        updatedAtGTE == other.updatedAtGTE &&
        updatedAtLT == other.updatedAtLT &&
        updatedAtLTE == other.updatedAtLTE &&
        phoneNumber == other.phoneNumber &&
        phoneNumberNEQ == other.phoneNumberNEQ &&
        phoneNumberIn == other.phoneNumberIn &&
        phoneNumberNotIn == other.phoneNumberNotIn &&
        phoneNumberGT == other.phoneNumberGT &&
        phoneNumberGTE == other.phoneNumberGTE &&
        phoneNumberLT == other.phoneNumberLT &&
        phoneNumberLTE == other.phoneNumberLTE &&
        phoneNumberContains == other.phoneNumberContains &&
        phoneNumberHasPrefix == other.phoneNumberHasPrefix &&
        phoneNumberHasSuffix == other.phoneNumberHasSuffix &&
        phoneNumberEqualFold == other.phoneNumberEqualFold &&
        phoneNumberContainsFold == other.phoneNumberContainsFold &&
        fullName == other.fullName &&
        fullNameNEQ == other.fullNameNEQ &&
        fullNameIn == other.fullNameIn &&
        fullNameNotIn == other.fullNameNotIn &&
        fullNameGT == other.fullNameGT &&
        fullNameGTE == other.fullNameGTE &&
        fullNameLT == other.fullNameLT &&
        fullNameLTE == other.fullNameLTE &&
        fullNameContains == other.fullNameContains &&
        fullNameHasPrefix == other.fullNameHasPrefix &&
        fullNameHasSuffix == other.fullNameHasSuffix &&
        fullNameIsNil == other.fullNameIsNil &&
        fullNameNotNil == other.fullNameNotNil &&
        fullNameEqualFold == other.fullNameEqualFold &&
        fullNameContainsFold == other.fullNameContainsFold &&
        birthDate == other.birthDate &&
        birthDateNEQ == other.birthDateNEQ &&
        birthDateIn == other.birthDateIn &&
        birthDateNotIn == other.birthDateNotIn &&
        birthDateGT == other.birthDateGT &&
        birthDateGTE == other.birthDateGTE &&
        birthDateLT == other.birthDateLT &&
        birthDateLTE == other.birthDateLTE &&
        birthDateIsNil == other.birthDateIsNil &&
        birthDateNotNil == other.birthDateNotNil &&
        studyTime == other.studyTime &&
        studyTimeNEQ == other.studyTimeNEQ &&
        studyTimeIn == other.studyTimeIn &&
        studyTimeNotIn == other.studyTimeNotIn &&
        studyTimeIsNil == other.studyTimeIsNil &&
        studyTimeNotNil == other.studyTimeNotNil &&
        role == other.role &&
        roleNEQ == other.roleNEQ &&
        roleIn == other.roleIn &&
        roleNotIn == other.roleNotIn &&
        simoCoins == other.simoCoins &&
        simoCoinsNEQ == other.simoCoinsNEQ &&
        simoCoinsIn == other.simoCoinsIn &&
        simoCoinsNotIn == other.simoCoinsNotIn &&
        simoCoinsGT == other.simoCoinsGT &&
        simoCoinsGTE == other.simoCoinsGTE &&
        simoCoinsLT == other.simoCoinsLT &&
        simoCoinsLTE == other.simoCoinsLTE &&
        score == other.score &&
        scoreNEQ == other.scoreNEQ &&
        scoreIn == other.scoreIn &&
        scoreNotIn == other.scoreNotIn &&
        scoreGT == other.scoreGT &&
        scoreGTE == other.scoreGTE &&
        scoreLT == other.scoreLT &&
        scoreLTE == other.scoreLTE &&
        isPremium == other.isPremium &&
        isPremiumNEQ == other.isPremiumNEQ &&
        major == other.major &&
        majorNEQ == other.majorNEQ &&
        majorIn == other.majorIn &&
        majorNotIn == other.majorNotIn &&
        majorGT == other.majorGT &&
        majorGTE == other.majorGTE &&
        majorLT == other.majorLT &&
        majorLTE == other.majorLTE &&
        majorContains == other.majorContains &&
        majorHasPrefix == other.majorHasPrefix &&
        majorHasSuffix == other.majorHasSuffix &&
        majorIsNil == other.majorIsNil &&
        majorNotNil == other.majorNotNil &&
        majorEqualFold == other.majorEqualFold &&
        majorContainsFold == other.majorContainsFold &&
        bio == other.bio &&
        bioNEQ == other.bioNEQ &&
        bioIn == other.bioIn &&
        bioNotIn == other.bioNotIn &&
        bioGT == other.bioGT &&
        bioGTE == other.bioGTE &&
        bioLT == other.bioLT &&
        bioLTE == other.bioLTE &&
        bioContains == other.bioContains &&
        bioHasPrefix == other.bioHasPrefix &&
        bioHasSuffix == other.bioHasSuffix &&
        bioIsNil == other.bioIsNil &&
        bioNotNil == other.bioNotNil &&
        bioEqualFold == other.bioEqualFold &&
        bioContainsFold == other.bioContainsFold &&
        hasInterests == other.hasInterests &&
        hasInterestsWith == other.hasInterestsWith &&
        hasGoals == other.hasGoals &&
        hasGoalsWith == other.hasGoalsWith &&
        hasTasks == other.hasTasks &&
        hasTasksWith == other.hasTasksWith;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, not.hashCode);
    _$hash = $jc(_$hash, and.hashCode);
    _$hash = $jc(_$hash, or.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, idNEQ.hashCode);
    _$hash = $jc(_$hash, idIn.hashCode);
    _$hash = $jc(_$hash, idNotIn.hashCode);
    _$hash = $jc(_$hash, idGT.hashCode);
    _$hash = $jc(_$hash, idGTE.hashCode);
    _$hash = $jc(_$hash, idLT.hashCode);
    _$hash = $jc(_$hash, idLTE.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, createdAtNEQ.hashCode);
    _$hash = $jc(_$hash, createdAtIn.hashCode);
    _$hash = $jc(_$hash, createdAtNotIn.hashCode);
    _$hash = $jc(_$hash, createdAtGT.hashCode);
    _$hash = $jc(_$hash, createdAtGTE.hashCode);
    _$hash = $jc(_$hash, createdAtLT.hashCode);
    _$hash = $jc(_$hash, createdAtLTE.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, updatedAtNEQ.hashCode);
    _$hash = $jc(_$hash, updatedAtIn.hashCode);
    _$hash = $jc(_$hash, updatedAtNotIn.hashCode);
    _$hash = $jc(_$hash, updatedAtGT.hashCode);
    _$hash = $jc(_$hash, updatedAtGTE.hashCode);
    _$hash = $jc(_$hash, updatedAtLT.hashCode);
    _$hash = $jc(_$hash, updatedAtLTE.hashCode);
    _$hash = $jc(_$hash, phoneNumber.hashCode);
    _$hash = $jc(_$hash, phoneNumberNEQ.hashCode);
    _$hash = $jc(_$hash, phoneNumberIn.hashCode);
    _$hash = $jc(_$hash, phoneNumberNotIn.hashCode);
    _$hash = $jc(_$hash, phoneNumberGT.hashCode);
    _$hash = $jc(_$hash, phoneNumberGTE.hashCode);
    _$hash = $jc(_$hash, phoneNumberLT.hashCode);
    _$hash = $jc(_$hash, phoneNumberLTE.hashCode);
    _$hash = $jc(_$hash, phoneNumberContains.hashCode);
    _$hash = $jc(_$hash, phoneNumberHasPrefix.hashCode);
    _$hash = $jc(_$hash, phoneNumberHasSuffix.hashCode);
    _$hash = $jc(_$hash, phoneNumberEqualFold.hashCode);
    _$hash = $jc(_$hash, phoneNumberContainsFold.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, fullNameNEQ.hashCode);
    _$hash = $jc(_$hash, fullNameIn.hashCode);
    _$hash = $jc(_$hash, fullNameNotIn.hashCode);
    _$hash = $jc(_$hash, fullNameGT.hashCode);
    _$hash = $jc(_$hash, fullNameGTE.hashCode);
    _$hash = $jc(_$hash, fullNameLT.hashCode);
    _$hash = $jc(_$hash, fullNameLTE.hashCode);
    _$hash = $jc(_$hash, fullNameContains.hashCode);
    _$hash = $jc(_$hash, fullNameHasPrefix.hashCode);
    _$hash = $jc(_$hash, fullNameHasSuffix.hashCode);
    _$hash = $jc(_$hash, fullNameIsNil.hashCode);
    _$hash = $jc(_$hash, fullNameNotNil.hashCode);
    _$hash = $jc(_$hash, fullNameEqualFold.hashCode);
    _$hash = $jc(_$hash, fullNameContainsFold.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, birthDateNEQ.hashCode);
    _$hash = $jc(_$hash, birthDateIn.hashCode);
    _$hash = $jc(_$hash, birthDateNotIn.hashCode);
    _$hash = $jc(_$hash, birthDateGT.hashCode);
    _$hash = $jc(_$hash, birthDateGTE.hashCode);
    _$hash = $jc(_$hash, birthDateLT.hashCode);
    _$hash = $jc(_$hash, birthDateLTE.hashCode);
    _$hash = $jc(_$hash, birthDateIsNil.hashCode);
    _$hash = $jc(_$hash, birthDateNotNil.hashCode);
    _$hash = $jc(_$hash, studyTime.hashCode);
    _$hash = $jc(_$hash, studyTimeNEQ.hashCode);
    _$hash = $jc(_$hash, studyTimeIn.hashCode);
    _$hash = $jc(_$hash, studyTimeNotIn.hashCode);
    _$hash = $jc(_$hash, studyTimeIsNil.hashCode);
    _$hash = $jc(_$hash, studyTimeNotNil.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, roleNEQ.hashCode);
    _$hash = $jc(_$hash, roleIn.hashCode);
    _$hash = $jc(_$hash, roleNotIn.hashCode);
    _$hash = $jc(_$hash, simoCoins.hashCode);
    _$hash = $jc(_$hash, simoCoinsNEQ.hashCode);
    _$hash = $jc(_$hash, simoCoinsIn.hashCode);
    _$hash = $jc(_$hash, simoCoinsNotIn.hashCode);
    _$hash = $jc(_$hash, simoCoinsGT.hashCode);
    _$hash = $jc(_$hash, simoCoinsGTE.hashCode);
    _$hash = $jc(_$hash, simoCoinsLT.hashCode);
    _$hash = $jc(_$hash, simoCoinsLTE.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, scoreNEQ.hashCode);
    _$hash = $jc(_$hash, scoreIn.hashCode);
    _$hash = $jc(_$hash, scoreNotIn.hashCode);
    _$hash = $jc(_$hash, scoreGT.hashCode);
    _$hash = $jc(_$hash, scoreGTE.hashCode);
    _$hash = $jc(_$hash, scoreLT.hashCode);
    _$hash = $jc(_$hash, scoreLTE.hashCode);
    _$hash = $jc(_$hash, isPremium.hashCode);
    _$hash = $jc(_$hash, isPremiumNEQ.hashCode);
    _$hash = $jc(_$hash, major.hashCode);
    _$hash = $jc(_$hash, majorNEQ.hashCode);
    _$hash = $jc(_$hash, majorIn.hashCode);
    _$hash = $jc(_$hash, majorNotIn.hashCode);
    _$hash = $jc(_$hash, majorGT.hashCode);
    _$hash = $jc(_$hash, majorGTE.hashCode);
    _$hash = $jc(_$hash, majorLT.hashCode);
    _$hash = $jc(_$hash, majorLTE.hashCode);
    _$hash = $jc(_$hash, majorContains.hashCode);
    _$hash = $jc(_$hash, majorHasPrefix.hashCode);
    _$hash = $jc(_$hash, majorHasSuffix.hashCode);
    _$hash = $jc(_$hash, majorIsNil.hashCode);
    _$hash = $jc(_$hash, majorNotNil.hashCode);
    _$hash = $jc(_$hash, majorEqualFold.hashCode);
    _$hash = $jc(_$hash, majorContainsFold.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, bioNEQ.hashCode);
    _$hash = $jc(_$hash, bioIn.hashCode);
    _$hash = $jc(_$hash, bioNotIn.hashCode);
    _$hash = $jc(_$hash, bioGT.hashCode);
    _$hash = $jc(_$hash, bioGTE.hashCode);
    _$hash = $jc(_$hash, bioLT.hashCode);
    _$hash = $jc(_$hash, bioLTE.hashCode);
    _$hash = $jc(_$hash, bioContains.hashCode);
    _$hash = $jc(_$hash, bioHasPrefix.hashCode);
    _$hash = $jc(_$hash, bioHasSuffix.hashCode);
    _$hash = $jc(_$hash, bioIsNil.hashCode);
    _$hash = $jc(_$hash, bioNotNil.hashCode);
    _$hash = $jc(_$hash, bioEqualFold.hashCode);
    _$hash = $jc(_$hash, bioContainsFold.hashCode);
    _$hash = $jc(_$hash, hasInterests.hashCode);
    _$hash = $jc(_$hash, hasInterestsWith.hashCode);
    _$hash = $jc(_$hash, hasGoals.hashCode);
    _$hash = $jc(_$hash, hasGoalsWith.hashCode);
    _$hash = $jc(_$hash, hasTasks.hashCode);
    _$hash = $jc(_$hash, hasTasksWith.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUserWhereInput')
          ..add('not', not)
          ..add('and', and)
          ..add('or', or)
          ..add('id', id)
          ..add('idNEQ', idNEQ)
          ..add('idIn', idIn)
          ..add('idNotIn', idNotIn)
          ..add('idGT', idGT)
          ..add('idGTE', idGTE)
          ..add('idLT', idLT)
          ..add('idLTE', idLTE)
          ..add('createdAt', createdAt)
          ..add('createdAtNEQ', createdAtNEQ)
          ..add('createdAtIn', createdAtIn)
          ..add('createdAtNotIn', createdAtNotIn)
          ..add('createdAtGT', createdAtGT)
          ..add('createdAtGTE', createdAtGTE)
          ..add('createdAtLT', createdAtLT)
          ..add('createdAtLTE', createdAtLTE)
          ..add('updatedAt', updatedAt)
          ..add('updatedAtNEQ', updatedAtNEQ)
          ..add('updatedAtIn', updatedAtIn)
          ..add('updatedAtNotIn', updatedAtNotIn)
          ..add('updatedAtGT', updatedAtGT)
          ..add('updatedAtGTE', updatedAtGTE)
          ..add('updatedAtLT', updatedAtLT)
          ..add('updatedAtLTE', updatedAtLTE)
          ..add('phoneNumber', phoneNumber)
          ..add('phoneNumberNEQ', phoneNumberNEQ)
          ..add('phoneNumberIn', phoneNumberIn)
          ..add('phoneNumberNotIn', phoneNumberNotIn)
          ..add('phoneNumberGT', phoneNumberGT)
          ..add('phoneNumberGTE', phoneNumberGTE)
          ..add('phoneNumberLT', phoneNumberLT)
          ..add('phoneNumberLTE', phoneNumberLTE)
          ..add('phoneNumberContains', phoneNumberContains)
          ..add('phoneNumberHasPrefix', phoneNumberHasPrefix)
          ..add('phoneNumberHasSuffix', phoneNumberHasSuffix)
          ..add('phoneNumberEqualFold', phoneNumberEqualFold)
          ..add('phoneNumberContainsFold', phoneNumberContainsFold)
          ..add('fullName', fullName)
          ..add('fullNameNEQ', fullNameNEQ)
          ..add('fullNameIn', fullNameIn)
          ..add('fullNameNotIn', fullNameNotIn)
          ..add('fullNameGT', fullNameGT)
          ..add('fullNameGTE', fullNameGTE)
          ..add('fullNameLT', fullNameLT)
          ..add('fullNameLTE', fullNameLTE)
          ..add('fullNameContains', fullNameContains)
          ..add('fullNameHasPrefix', fullNameHasPrefix)
          ..add('fullNameHasSuffix', fullNameHasSuffix)
          ..add('fullNameIsNil', fullNameIsNil)
          ..add('fullNameNotNil', fullNameNotNil)
          ..add('fullNameEqualFold', fullNameEqualFold)
          ..add('fullNameContainsFold', fullNameContainsFold)
          ..add('birthDate', birthDate)
          ..add('birthDateNEQ', birthDateNEQ)
          ..add('birthDateIn', birthDateIn)
          ..add('birthDateNotIn', birthDateNotIn)
          ..add('birthDateGT', birthDateGT)
          ..add('birthDateGTE', birthDateGTE)
          ..add('birthDateLT', birthDateLT)
          ..add('birthDateLTE', birthDateLTE)
          ..add('birthDateIsNil', birthDateIsNil)
          ..add('birthDateNotNil', birthDateNotNil)
          ..add('studyTime', studyTime)
          ..add('studyTimeNEQ', studyTimeNEQ)
          ..add('studyTimeIn', studyTimeIn)
          ..add('studyTimeNotIn', studyTimeNotIn)
          ..add('studyTimeIsNil', studyTimeIsNil)
          ..add('studyTimeNotNil', studyTimeNotNil)
          ..add('role', role)
          ..add('roleNEQ', roleNEQ)
          ..add('roleIn', roleIn)
          ..add('roleNotIn', roleNotIn)
          ..add('simoCoins', simoCoins)
          ..add('simoCoinsNEQ', simoCoinsNEQ)
          ..add('simoCoinsIn', simoCoinsIn)
          ..add('simoCoinsNotIn', simoCoinsNotIn)
          ..add('simoCoinsGT', simoCoinsGT)
          ..add('simoCoinsGTE', simoCoinsGTE)
          ..add('simoCoinsLT', simoCoinsLT)
          ..add('simoCoinsLTE', simoCoinsLTE)
          ..add('score', score)
          ..add('scoreNEQ', scoreNEQ)
          ..add('scoreIn', scoreIn)
          ..add('scoreNotIn', scoreNotIn)
          ..add('scoreGT', scoreGT)
          ..add('scoreGTE', scoreGTE)
          ..add('scoreLT', scoreLT)
          ..add('scoreLTE', scoreLTE)
          ..add('isPremium', isPremium)
          ..add('isPremiumNEQ', isPremiumNEQ)
          ..add('major', major)
          ..add('majorNEQ', majorNEQ)
          ..add('majorIn', majorIn)
          ..add('majorNotIn', majorNotIn)
          ..add('majorGT', majorGT)
          ..add('majorGTE', majorGTE)
          ..add('majorLT', majorLT)
          ..add('majorLTE', majorLTE)
          ..add('majorContains', majorContains)
          ..add('majorHasPrefix', majorHasPrefix)
          ..add('majorHasSuffix', majorHasSuffix)
          ..add('majorIsNil', majorIsNil)
          ..add('majorNotNil', majorNotNil)
          ..add('majorEqualFold', majorEqualFold)
          ..add('majorContainsFold', majorContainsFold)
          ..add('bio', bio)
          ..add('bioNEQ', bioNEQ)
          ..add('bioIn', bioIn)
          ..add('bioNotIn', bioNotIn)
          ..add('bioGT', bioGT)
          ..add('bioGTE', bioGTE)
          ..add('bioLT', bioLT)
          ..add('bioLTE', bioLTE)
          ..add('bioContains', bioContains)
          ..add('bioHasPrefix', bioHasPrefix)
          ..add('bioHasSuffix', bioHasSuffix)
          ..add('bioIsNil', bioIsNil)
          ..add('bioNotNil', bioNotNil)
          ..add('bioEqualFold', bioEqualFold)
          ..add('bioContainsFold', bioContainsFold)
          ..add('hasInterests', hasInterests)
          ..add('hasInterestsWith', hasInterestsWith)
          ..add('hasGoals', hasGoals)
          ..add('hasGoalsWith', hasGoalsWith)
          ..add('hasTasks', hasTasks)
          ..add('hasTasksWith', hasTasksWith))
        .toString();
  }
}

class GUserWhereInputBuilder
    implements Builder<GUserWhereInput, GUserWhereInputBuilder> {
  _$GUserWhereInput? _$v;

  GUserWhereInputBuilder? _not;
  GUserWhereInputBuilder get not =>
      _$this._not ??= new GUserWhereInputBuilder();
  set not(GUserWhereInputBuilder? not) => _$this._not = not;

  ListBuilder<GUserWhereInput>? _and;
  ListBuilder<GUserWhereInput> get and =>
      _$this._and ??= new ListBuilder<GUserWhereInput>();
  set and(ListBuilder<GUserWhereInput>? and) => _$this._and = and;

  ListBuilder<GUserWhereInput>? _or;
  ListBuilder<GUserWhereInput> get or =>
      _$this._or ??= new ListBuilder<GUserWhereInput>();
  set or(ListBuilder<GUserWhereInput>? or) => _$this._or = or;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _idNEQ;
  String? get idNEQ => _$this._idNEQ;
  set idNEQ(String? idNEQ) => _$this._idNEQ = idNEQ;

  ListBuilder<String>? _idIn;
  ListBuilder<String> get idIn => _$this._idIn ??= new ListBuilder<String>();
  set idIn(ListBuilder<String>? idIn) => _$this._idIn = idIn;

  ListBuilder<String>? _idNotIn;
  ListBuilder<String> get idNotIn =>
      _$this._idNotIn ??= new ListBuilder<String>();
  set idNotIn(ListBuilder<String>? idNotIn) => _$this._idNotIn = idNotIn;

  String? _idGT;
  String? get idGT => _$this._idGT;
  set idGT(String? idGT) => _$this._idGT = idGT;

  String? _idGTE;
  String? get idGTE => _$this._idGTE;
  set idGTE(String? idGTE) => _$this._idGTE = idGTE;

  String? _idLT;
  String? get idLT => _$this._idLT;
  set idLT(String? idLT) => _$this._idLT = idLT;

  String? _idLTE;
  String? get idLTE => _$this._idLTE;
  set idLTE(String? idLTE) => _$this._idLTE = idLTE;

  GTimeBuilder? _createdAt;
  GTimeBuilder get createdAt => _$this._createdAt ??= new GTimeBuilder();
  set createdAt(GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GTimeBuilder? _createdAtNEQ;
  GTimeBuilder get createdAtNEQ => _$this._createdAtNEQ ??= new GTimeBuilder();
  set createdAtNEQ(GTimeBuilder? createdAtNEQ) =>
      _$this._createdAtNEQ = createdAtNEQ;

  ListBuilder<GTime>? _createdAtIn;
  ListBuilder<GTime> get createdAtIn =>
      _$this._createdAtIn ??= new ListBuilder<GTime>();
  set createdAtIn(ListBuilder<GTime>? createdAtIn) =>
      _$this._createdAtIn = createdAtIn;

  ListBuilder<GTime>? _createdAtNotIn;
  ListBuilder<GTime> get createdAtNotIn =>
      _$this._createdAtNotIn ??= new ListBuilder<GTime>();
  set createdAtNotIn(ListBuilder<GTime>? createdAtNotIn) =>
      _$this._createdAtNotIn = createdAtNotIn;

  GTimeBuilder? _createdAtGT;
  GTimeBuilder get createdAtGT => _$this._createdAtGT ??= new GTimeBuilder();
  set createdAtGT(GTimeBuilder? createdAtGT) =>
      _$this._createdAtGT = createdAtGT;

  GTimeBuilder? _createdAtGTE;
  GTimeBuilder get createdAtGTE => _$this._createdAtGTE ??= new GTimeBuilder();
  set createdAtGTE(GTimeBuilder? createdAtGTE) =>
      _$this._createdAtGTE = createdAtGTE;

  GTimeBuilder? _createdAtLT;
  GTimeBuilder get createdAtLT => _$this._createdAtLT ??= new GTimeBuilder();
  set createdAtLT(GTimeBuilder? createdAtLT) =>
      _$this._createdAtLT = createdAtLT;

  GTimeBuilder? _createdAtLTE;
  GTimeBuilder get createdAtLTE => _$this._createdAtLTE ??= new GTimeBuilder();
  set createdAtLTE(GTimeBuilder? createdAtLTE) =>
      _$this._createdAtLTE = createdAtLTE;

  GTimeBuilder? _updatedAt;
  GTimeBuilder get updatedAt => _$this._updatedAt ??= new GTimeBuilder();
  set updatedAt(GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  GTimeBuilder? _updatedAtNEQ;
  GTimeBuilder get updatedAtNEQ => _$this._updatedAtNEQ ??= new GTimeBuilder();
  set updatedAtNEQ(GTimeBuilder? updatedAtNEQ) =>
      _$this._updatedAtNEQ = updatedAtNEQ;

  ListBuilder<GTime>? _updatedAtIn;
  ListBuilder<GTime> get updatedAtIn =>
      _$this._updatedAtIn ??= new ListBuilder<GTime>();
  set updatedAtIn(ListBuilder<GTime>? updatedAtIn) =>
      _$this._updatedAtIn = updatedAtIn;

  ListBuilder<GTime>? _updatedAtNotIn;
  ListBuilder<GTime> get updatedAtNotIn =>
      _$this._updatedAtNotIn ??= new ListBuilder<GTime>();
  set updatedAtNotIn(ListBuilder<GTime>? updatedAtNotIn) =>
      _$this._updatedAtNotIn = updatedAtNotIn;

  GTimeBuilder? _updatedAtGT;
  GTimeBuilder get updatedAtGT => _$this._updatedAtGT ??= new GTimeBuilder();
  set updatedAtGT(GTimeBuilder? updatedAtGT) =>
      _$this._updatedAtGT = updatedAtGT;

  GTimeBuilder? _updatedAtGTE;
  GTimeBuilder get updatedAtGTE => _$this._updatedAtGTE ??= new GTimeBuilder();
  set updatedAtGTE(GTimeBuilder? updatedAtGTE) =>
      _$this._updatedAtGTE = updatedAtGTE;

  GTimeBuilder? _updatedAtLT;
  GTimeBuilder get updatedAtLT => _$this._updatedAtLT ??= new GTimeBuilder();
  set updatedAtLT(GTimeBuilder? updatedAtLT) =>
      _$this._updatedAtLT = updatedAtLT;

  GTimeBuilder? _updatedAtLTE;
  GTimeBuilder get updatedAtLTE => _$this._updatedAtLTE ??= new GTimeBuilder();
  set updatedAtLTE(GTimeBuilder? updatedAtLTE) =>
      _$this._updatedAtLTE = updatedAtLTE;

  String? _phoneNumber;
  String? get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String? phoneNumber) => _$this._phoneNumber = phoneNumber;

  String? _phoneNumberNEQ;
  String? get phoneNumberNEQ => _$this._phoneNumberNEQ;
  set phoneNumberNEQ(String? phoneNumberNEQ) =>
      _$this._phoneNumberNEQ = phoneNumberNEQ;

  ListBuilder<String>? _phoneNumberIn;
  ListBuilder<String> get phoneNumberIn =>
      _$this._phoneNumberIn ??= new ListBuilder<String>();
  set phoneNumberIn(ListBuilder<String>? phoneNumberIn) =>
      _$this._phoneNumberIn = phoneNumberIn;

  ListBuilder<String>? _phoneNumberNotIn;
  ListBuilder<String> get phoneNumberNotIn =>
      _$this._phoneNumberNotIn ??= new ListBuilder<String>();
  set phoneNumberNotIn(ListBuilder<String>? phoneNumberNotIn) =>
      _$this._phoneNumberNotIn = phoneNumberNotIn;

  String? _phoneNumberGT;
  String? get phoneNumberGT => _$this._phoneNumberGT;
  set phoneNumberGT(String? phoneNumberGT) =>
      _$this._phoneNumberGT = phoneNumberGT;

  String? _phoneNumberGTE;
  String? get phoneNumberGTE => _$this._phoneNumberGTE;
  set phoneNumberGTE(String? phoneNumberGTE) =>
      _$this._phoneNumberGTE = phoneNumberGTE;

  String? _phoneNumberLT;
  String? get phoneNumberLT => _$this._phoneNumberLT;
  set phoneNumberLT(String? phoneNumberLT) =>
      _$this._phoneNumberLT = phoneNumberLT;

  String? _phoneNumberLTE;
  String? get phoneNumberLTE => _$this._phoneNumberLTE;
  set phoneNumberLTE(String? phoneNumberLTE) =>
      _$this._phoneNumberLTE = phoneNumberLTE;

  String? _phoneNumberContains;
  String? get phoneNumberContains => _$this._phoneNumberContains;
  set phoneNumberContains(String? phoneNumberContains) =>
      _$this._phoneNumberContains = phoneNumberContains;

  String? _phoneNumberHasPrefix;
  String? get phoneNumberHasPrefix => _$this._phoneNumberHasPrefix;
  set phoneNumberHasPrefix(String? phoneNumberHasPrefix) =>
      _$this._phoneNumberHasPrefix = phoneNumberHasPrefix;

  String? _phoneNumberHasSuffix;
  String? get phoneNumberHasSuffix => _$this._phoneNumberHasSuffix;
  set phoneNumberHasSuffix(String? phoneNumberHasSuffix) =>
      _$this._phoneNumberHasSuffix = phoneNumberHasSuffix;

  String? _phoneNumberEqualFold;
  String? get phoneNumberEqualFold => _$this._phoneNumberEqualFold;
  set phoneNumberEqualFold(String? phoneNumberEqualFold) =>
      _$this._phoneNumberEqualFold = phoneNumberEqualFold;

  String? _phoneNumberContainsFold;
  String? get phoneNumberContainsFold => _$this._phoneNumberContainsFold;
  set phoneNumberContainsFold(String? phoneNumberContainsFold) =>
      _$this._phoneNumberContainsFold = phoneNumberContainsFold;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _fullNameNEQ;
  String? get fullNameNEQ => _$this._fullNameNEQ;
  set fullNameNEQ(String? fullNameNEQ) => _$this._fullNameNEQ = fullNameNEQ;

  ListBuilder<String>? _fullNameIn;
  ListBuilder<String> get fullNameIn =>
      _$this._fullNameIn ??= new ListBuilder<String>();
  set fullNameIn(ListBuilder<String>? fullNameIn) =>
      _$this._fullNameIn = fullNameIn;

  ListBuilder<String>? _fullNameNotIn;
  ListBuilder<String> get fullNameNotIn =>
      _$this._fullNameNotIn ??= new ListBuilder<String>();
  set fullNameNotIn(ListBuilder<String>? fullNameNotIn) =>
      _$this._fullNameNotIn = fullNameNotIn;

  String? _fullNameGT;
  String? get fullNameGT => _$this._fullNameGT;
  set fullNameGT(String? fullNameGT) => _$this._fullNameGT = fullNameGT;

  String? _fullNameGTE;
  String? get fullNameGTE => _$this._fullNameGTE;
  set fullNameGTE(String? fullNameGTE) => _$this._fullNameGTE = fullNameGTE;

  String? _fullNameLT;
  String? get fullNameLT => _$this._fullNameLT;
  set fullNameLT(String? fullNameLT) => _$this._fullNameLT = fullNameLT;

  String? _fullNameLTE;
  String? get fullNameLTE => _$this._fullNameLTE;
  set fullNameLTE(String? fullNameLTE) => _$this._fullNameLTE = fullNameLTE;

  String? _fullNameContains;
  String? get fullNameContains => _$this._fullNameContains;
  set fullNameContains(String? fullNameContains) =>
      _$this._fullNameContains = fullNameContains;

  String? _fullNameHasPrefix;
  String? get fullNameHasPrefix => _$this._fullNameHasPrefix;
  set fullNameHasPrefix(String? fullNameHasPrefix) =>
      _$this._fullNameHasPrefix = fullNameHasPrefix;

  String? _fullNameHasSuffix;
  String? get fullNameHasSuffix => _$this._fullNameHasSuffix;
  set fullNameHasSuffix(String? fullNameHasSuffix) =>
      _$this._fullNameHasSuffix = fullNameHasSuffix;

  bool? _fullNameIsNil;
  bool? get fullNameIsNil => _$this._fullNameIsNil;
  set fullNameIsNil(bool? fullNameIsNil) =>
      _$this._fullNameIsNil = fullNameIsNil;

  bool? _fullNameNotNil;
  bool? get fullNameNotNil => _$this._fullNameNotNil;
  set fullNameNotNil(bool? fullNameNotNil) =>
      _$this._fullNameNotNil = fullNameNotNil;

  String? _fullNameEqualFold;
  String? get fullNameEqualFold => _$this._fullNameEqualFold;
  set fullNameEqualFold(String? fullNameEqualFold) =>
      _$this._fullNameEqualFold = fullNameEqualFold;

  String? _fullNameContainsFold;
  String? get fullNameContainsFold => _$this._fullNameContainsFold;
  set fullNameContainsFold(String? fullNameContainsFold) =>
      _$this._fullNameContainsFold = fullNameContainsFold;

  GTimeBuilder? _birthDate;
  GTimeBuilder get birthDate => _$this._birthDate ??= new GTimeBuilder();
  set birthDate(GTimeBuilder? birthDate) => _$this._birthDate = birthDate;

  GTimeBuilder? _birthDateNEQ;
  GTimeBuilder get birthDateNEQ => _$this._birthDateNEQ ??= new GTimeBuilder();
  set birthDateNEQ(GTimeBuilder? birthDateNEQ) =>
      _$this._birthDateNEQ = birthDateNEQ;

  ListBuilder<GTime>? _birthDateIn;
  ListBuilder<GTime> get birthDateIn =>
      _$this._birthDateIn ??= new ListBuilder<GTime>();
  set birthDateIn(ListBuilder<GTime>? birthDateIn) =>
      _$this._birthDateIn = birthDateIn;

  ListBuilder<GTime>? _birthDateNotIn;
  ListBuilder<GTime> get birthDateNotIn =>
      _$this._birthDateNotIn ??= new ListBuilder<GTime>();
  set birthDateNotIn(ListBuilder<GTime>? birthDateNotIn) =>
      _$this._birthDateNotIn = birthDateNotIn;

  GTimeBuilder? _birthDateGT;
  GTimeBuilder get birthDateGT => _$this._birthDateGT ??= new GTimeBuilder();
  set birthDateGT(GTimeBuilder? birthDateGT) =>
      _$this._birthDateGT = birthDateGT;

  GTimeBuilder? _birthDateGTE;
  GTimeBuilder get birthDateGTE => _$this._birthDateGTE ??= new GTimeBuilder();
  set birthDateGTE(GTimeBuilder? birthDateGTE) =>
      _$this._birthDateGTE = birthDateGTE;

  GTimeBuilder? _birthDateLT;
  GTimeBuilder get birthDateLT => _$this._birthDateLT ??= new GTimeBuilder();
  set birthDateLT(GTimeBuilder? birthDateLT) =>
      _$this._birthDateLT = birthDateLT;

  GTimeBuilder? _birthDateLTE;
  GTimeBuilder get birthDateLTE => _$this._birthDateLTE ??= new GTimeBuilder();
  set birthDateLTE(GTimeBuilder? birthDateLTE) =>
      _$this._birthDateLTE = birthDateLTE;

  bool? _birthDateIsNil;
  bool? get birthDateIsNil => _$this._birthDateIsNil;
  set birthDateIsNil(bool? birthDateIsNil) =>
      _$this._birthDateIsNil = birthDateIsNil;

  bool? _birthDateNotNil;
  bool? get birthDateNotNil => _$this._birthDateNotNil;
  set birthDateNotNil(bool? birthDateNotNil) =>
      _$this._birthDateNotNil = birthDateNotNil;

  GUserStudyTime? _studyTime;
  GUserStudyTime? get studyTime => _$this._studyTime;
  set studyTime(GUserStudyTime? studyTime) => _$this._studyTime = studyTime;

  GUserStudyTime? _studyTimeNEQ;
  GUserStudyTime? get studyTimeNEQ => _$this._studyTimeNEQ;
  set studyTimeNEQ(GUserStudyTime? studyTimeNEQ) =>
      _$this._studyTimeNEQ = studyTimeNEQ;

  ListBuilder<GUserStudyTime>? _studyTimeIn;
  ListBuilder<GUserStudyTime> get studyTimeIn =>
      _$this._studyTimeIn ??= new ListBuilder<GUserStudyTime>();
  set studyTimeIn(ListBuilder<GUserStudyTime>? studyTimeIn) =>
      _$this._studyTimeIn = studyTimeIn;

  ListBuilder<GUserStudyTime>? _studyTimeNotIn;
  ListBuilder<GUserStudyTime> get studyTimeNotIn =>
      _$this._studyTimeNotIn ??= new ListBuilder<GUserStudyTime>();
  set studyTimeNotIn(ListBuilder<GUserStudyTime>? studyTimeNotIn) =>
      _$this._studyTimeNotIn = studyTimeNotIn;

  bool? _studyTimeIsNil;
  bool? get studyTimeIsNil => _$this._studyTimeIsNil;
  set studyTimeIsNil(bool? studyTimeIsNil) =>
      _$this._studyTimeIsNil = studyTimeIsNil;

  bool? _studyTimeNotNil;
  bool? get studyTimeNotNil => _$this._studyTimeNotNil;
  set studyTimeNotNil(bool? studyTimeNotNil) =>
      _$this._studyTimeNotNil = studyTimeNotNil;

  GUserRole? _role;
  GUserRole? get role => _$this._role;
  set role(GUserRole? role) => _$this._role = role;

  GUserRole? _roleNEQ;
  GUserRole? get roleNEQ => _$this._roleNEQ;
  set roleNEQ(GUserRole? roleNEQ) => _$this._roleNEQ = roleNEQ;

  ListBuilder<GUserRole>? _roleIn;
  ListBuilder<GUserRole> get roleIn =>
      _$this._roleIn ??= new ListBuilder<GUserRole>();
  set roleIn(ListBuilder<GUserRole>? roleIn) => _$this._roleIn = roleIn;

  ListBuilder<GUserRole>? _roleNotIn;
  ListBuilder<GUserRole> get roleNotIn =>
      _$this._roleNotIn ??= new ListBuilder<GUserRole>();
  set roleNotIn(ListBuilder<GUserRole>? roleNotIn) =>
      _$this._roleNotIn = roleNotIn;

  int? _simoCoins;
  int? get simoCoins => _$this._simoCoins;
  set simoCoins(int? simoCoins) => _$this._simoCoins = simoCoins;

  int? _simoCoinsNEQ;
  int? get simoCoinsNEQ => _$this._simoCoinsNEQ;
  set simoCoinsNEQ(int? simoCoinsNEQ) => _$this._simoCoinsNEQ = simoCoinsNEQ;

  ListBuilder<int>? _simoCoinsIn;
  ListBuilder<int> get simoCoinsIn =>
      _$this._simoCoinsIn ??= new ListBuilder<int>();
  set simoCoinsIn(ListBuilder<int>? simoCoinsIn) =>
      _$this._simoCoinsIn = simoCoinsIn;

  ListBuilder<int>? _simoCoinsNotIn;
  ListBuilder<int> get simoCoinsNotIn =>
      _$this._simoCoinsNotIn ??= new ListBuilder<int>();
  set simoCoinsNotIn(ListBuilder<int>? simoCoinsNotIn) =>
      _$this._simoCoinsNotIn = simoCoinsNotIn;

  int? _simoCoinsGT;
  int? get simoCoinsGT => _$this._simoCoinsGT;
  set simoCoinsGT(int? simoCoinsGT) => _$this._simoCoinsGT = simoCoinsGT;

  int? _simoCoinsGTE;
  int? get simoCoinsGTE => _$this._simoCoinsGTE;
  set simoCoinsGTE(int? simoCoinsGTE) => _$this._simoCoinsGTE = simoCoinsGTE;

  int? _simoCoinsLT;
  int? get simoCoinsLT => _$this._simoCoinsLT;
  set simoCoinsLT(int? simoCoinsLT) => _$this._simoCoinsLT = simoCoinsLT;

  int? _simoCoinsLTE;
  int? get simoCoinsLTE => _$this._simoCoinsLTE;
  set simoCoinsLTE(int? simoCoinsLTE) => _$this._simoCoinsLTE = simoCoinsLTE;

  int? _score;
  int? get score => _$this._score;
  set score(int? score) => _$this._score = score;

  int? _scoreNEQ;
  int? get scoreNEQ => _$this._scoreNEQ;
  set scoreNEQ(int? scoreNEQ) => _$this._scoreNEQ = scoreNEQ;

  ListBuilder<int>? _scoreIn;
  ListBuilder<int> get scoreIn => _$this._scoreIn ??= new ListBuilder<int>();
  set scoreIn(ListBuilder<int>? scoreIn) => _$this._scoreIn = scoreIn;

  ListBuilder<int>? _scoreNotIn;
  ListBuilder<int> get scoreNotIn =>
      _$this._scoreNotIn ??= new ListBuilder<int>();
  set scoreNotIn(ListBuilder<int>? scoreNotIn) =>
      _$this._scoreNotIn = scoreNotIn;

  int? _scoreGT;
  int? get scoreGT => _$this._scoreGT;
  set scoreGT(int? scoreGT) => _$this._scoreGT = scoreGT;

  int? _scoreGTE;
  int? get scoreGTE => _$this._scoreGTE;
  set scoreGTE(int? scoreGTE) => _$this._scoreGTE = scoreGTE;

  int? _scoreLT;
  int? get scoreLT => _$this._scoreLT;
  set scoreLT(int? scoreLT) => _$this._scoreLT = scoreLT;

  int? _scoreLTE;
  int? get scoreLTE => _$this._scoreLTE;
  set scoreLTE(int? scoreLTE) => _$this._scoreLTE = scoreLTE;

  bool? _isPremium;
  bool? get isPremium => _$this._isPremium;
  set isPremium(bool? isPremium) => _$this._isPremium = isPremium;

  bool? _isPremiumNEQ;
  bool? get isPremiumNEQ => _$this._isPremiumNEQ;
  set isPremiumNEQ(bool? isPremiumNEQ) => _$this._isPremiumNEQ = isPremiumNEQ;

  String? _major;
  String? get major => _$this._major;
  set major(String? major) => _$this._major = major;

  String? _majorNEQ;
  String? get majorNEQ => _$this._majorNEQ;
  set majorNEQ(String? majorNEQ) => _$this._majorNEQ = majorNEQ;

  ListBuilder<String>? _majorIn;
  ListBuilder<String> get majorIn =>
      _$this._majorIn ??= new ListBuilder<String>();
  set majorIn(ListBuilder<String>? majorIn) => _$this._majorIn = majorIn;

  ListBuilder<String>? _majorNotIn;
  ListBuilder<String> get majorNotIn =>
      _$this._majorNotIn ??= new ListBuilder<String>();
  set majorNotIn(ListBuilder<String>? majorNotIn) =>
      _$this._majorNotIn = majorNotIn;

  String? _majorGT;
  String? get majorGT => _$this._majorGT;
  set majorGT(String? majorGT) => _$this._majorGT = majorGT;

  String? _majorGTE;
  String? get majorGTE => _$this._majorGTE;
  set majorGTE(String? majorGTE) => _$this._majorGTE = majorGTE;

  String? _majorLT;
  String? get majorLT => _$this._majorLT;
  set majorLT(String? majorLT) => _$this._majorLT = majorLT;

  String? _majorLTE;
  String? get majorLTE => _$this._majorLTE;
  set majorLTE(String? majorLTE) => _$this._majorLTE = majorLTE;

  String? _majorContains;
  String? get majorContains => _$this._majorContains;
  set majorContains(String? majorContains) =>
      _$this._majorContains = majorContains;

  String? _majorHasPrefix;
  String? get majorHasPrefix => _$this._majorHasPrefix;
  set majorHasPrefix(String? majorHasPrefix) =>
      _$this._majorHasPrefix = majorHasPrefix;

  String? _majorHasSuffix;
  String? get majorHasSuffix => _$this._majorHasSuffix;
  set majorHasSuffix(String? majorHasSuffix) =>
      _$this._majorHasSuffix = majorHasSuffix;

  bool? _majorIsNil;
  bool? get majorIsNil => _$this._majorIsNil;
  set majorIsNil(bool? majorIsNil) => _$this._majorIsNil = majorIsNil;

  bool? _majorNotNil;
  bool? get majorNotNil => _$this._majorNotNil;
  set majorNotNil(bool? majorNotNil) => _$this._majorNotNil = majorNotNil;

  String? _majorEqualFold;
  String? get majorEqualFold => _$this._majorEqualFold;
  set majorEqualFold(String? majorEqualFold) =>
      _$this._majorEqualFold = majorEqualFold;

  String? _majorContainsFold;
  String? get majorContainsFold => _$this._majorContainsFold;
  set majorContainsFold(String? majorContainsFold) =>
      _$this._majorContainsFold = majorContainsFold;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _bioNEQ;
  String? get bioNEQ => _$this._bioNEQ;
  set bioNEQ(String? bioNEQ) => _$this._bioNEQ = bioNEQ;

  ListBuilder<String>? _bioIn;
  ListBuilder<String> get bioIn => _$this._bioIn ??= new ListBuilder<String>();
  set bioIn(ListBuilder<String>? bioIn) => _$this._bioIn = bioIn;

  ListBuilder<String>? _bioNotIn;
  ListBuilder<String> get bioNotIn =>
      _$this._bioNotIn ??= new ListBuilder<String>();
  set bioNotIn(ListBuilder<String>? bioNotIn) => _$this._bioNotIn = bioNotIn;

  String? _bioGT;
  String? get bioGT => _$this._bioGT;
  set bioGT(String? bioGT) => _$this._bioGT = bioGT;

  String? _bioGTE;
  String? get bioGTE => _$this._bioGTE;
  set bioGTE(String? bioGTE) => _$this._bioGTE = bioGTE;

  String? _bioLT;
  String? get bioLT => _$this._bioLT;
  set bioLT(String? bioLT) => _$this._bioLT = bioLT;

  String? _bioLTE;
  String? get bioLTE => _$this._bioLTE;
  set bioLTE(String? bioLTE) => _$this._bioLTE = bioLTE;

  String? _bioContains;
  String? get bioContains => _$this._bioContains;
  set bioContains(String? bioContains) => _$this._bioContains = bioContains;

  String? _bioHasPrefix;
  String? get bioHasPrefix => _$this._bioHasPrefix;
  set bioHasPrefix(String? bioHasPrefix) => _$this._bioHasPrefix = bioHasPrefix;

  String? _bioHasSuffix;
  String? get bioHasSuffix => _$this._bioHasSuffix;
  set bioHasSuffix(String? bioHasSuffix) => _$this._bioHasSuffix = bioHasSuffix;

  bool? _bioIsNil;
  bool? get bioIsNil => _$this._bioIsNil;
  set bioIsNil(bool? bioIsNil) => _$this._bioIsNil = bioIsNil;

  bool? _bioNotNil;
  bool? get bioNotNil => _$this._bioNotNil;
  set bioNotNil(bool? bioNotNil) => _$this._bioNotNil = bioNotNil;

  String? _bioEqualFold;
  String? get bioEqualFold => _$this._bioEqualFold;
  set bioEqualFold(String? bioEqualFold) => _$this._bioEqualFold = bioEqualFold;

  String? _bioContainsFold;
  String? get bioContainsFold => _$this._bioContainsFold;
  set bioContainsFold(String? bioContainsFold) =>
      _$this._bioContainsFold = bioContainsFold;

  bool? _hasInterests;
  bool? get hasInterests => _$this._hasInterests;
  set hasInterests(bool? hasInterests) => _$this._hasInterests = hasInterests;

  ListBuilder<GInterestWhereInput>? _hasInterestsWith;
  ListBuilder<GInterestWhereInput> get hasInterestsWith =>
      _$this._hasInterestsWith ??= new ListBuilder<GInterestWhereInput>();
  set hasInterestsWith(ListBuilder<GInterestWhereInput>? hasInterestsWith) =>
      _$this._hasInterestsWith = hasInterestsWith;

  bool? _hasGoals;
  bool? get hasGoals => _$this._hasGoals;
  set hasGoals(bool? hasGoals) => _$this._hasGoals = hasGoals;

  ListBuilder<GGoalWhereInput>? _hasGoalsWith;
  ListBuilder<GGoalWhereInput> get hasGoalsWith =>
      _$this._hasGoalsWith ??= new ListBuilder<GGoalWhereInput>();
  set hasGoalsWith(ListBuilder<GGoalWhereInput>? hasGoalsWith) =>
      _$this._hasGoalsWith = hasGoalsWith;

  bool? _hasTasks;
  bool? get hasTasks => _$this._hasTasks;
  set hasTasks(bool? hasTasks) => _$this._hasTasks = hasTasks;

  ListBuilder<GTaskWhereInput>? _hasTasksWith;
  ListBuilder<GTaskWhereInput> get hasTasksWith =>
      _$this._hasTasksWith ??= new ListBuilder<GTaskWhereInput>();
  set hasTasksWith(ListBuilder<GTaskWhereInput>? hasTasksWith) =>
      _$this._hasTasksWith = hasTasksWith;

  GUserWhereInputBuilder();

  GUserWhereInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _not = $v.not?.toBuilder();
      _and = $v.and?.toBuilder();
      _or = $v.or?.toBuilder();
      _id = $v.id;
      _idNEQ = $v.idNEQ;
      _idIn = $v.idIn?.toBuilder();
      _idNotIn = $v.idNotIn?.toBuilder();
      _idGT = $v.idGT;
      _idGTE = $v.idGTE;
      _idLT = $v.idLT;
      _idLTE = $v.idLTE;
      _createdAt = $v.createdAt?.toBuilder();
      _createdAtNEQ = $v.createdAtNEQ?.toBuilder();
      _createdAtIn = $v.createdAtIn?.toBuilder();
      _createdAtNotIn = $v.createdAtNotIn?.toBuilder();
      _createdAtGT = $v.createdAtGT?.toBuilder();
      _createdAtGTE = $v.createdAtGTE?.toBuilder();
      _createdAtLT = $v.createdAtLT?.toBuilder();
      _createdAtLTE = $v.createdAtLTE?.toBuilder();
      _updatedAt = $v.updatedAt?.toBuilder();
      _updatedAtNEQ = $v.updatedAtNEQ?.toBuilder();
      _updatedAtIn = $v.updatedAtIn?.toBuilder();
      _updatedAtNotIn = $v.updatedAtNotIn?.toBuilder();
      _updatedAtGT = $v.updatedAtGT?.toBuilder();
      _updatedAtGTE = $v.updatedAtGTE?.toBuilder();
      _updatedAtLT = $v.updatedAtLT?.toBuilder();
      _updatedAtLTE = $v.updatedAtLTE?.toBuilder();
      _phoneNumber = $v.phoneNumber;
      _phoneNumberNEQ = $v.phoneNumberNEQ;
      _phoneNumberIn = $v.phoneNumberIn?.toBuilder();
      _phoneNumberNotIn = $v.phoneNumberNotIn?.toBuilder();
      _phoneNumberGT = $v.phoneNumberGT;
      _phoneNumberGTE = $v.phoneNumberGTE;
      _phoneNumberLT = $v.phoneNumberLT;
      _phoneNumberLTE = $v.phoneNumberLTE;
      _phoneNumberContains = $v.phoneNumberContains;
      _phoneNumberHasPrefix = $v.phoneNumberHasPrefix;
      _phoneNumberHasSuffix = $v.phoneNumberHasSuffix;
      _phoneNumberEqualFold = $v.phoneNumberEqualFold;
      _phoneNumberContainsFold = $v.phoneNumberContainsFold;
      _fullName = $v.fullName;
      _fullNameNEQ = $v.fullNameNEQ;
      _fullNameIn = $v.fullNameIn?.toBuilder();
      _fullNameNotIn = $v.fullNameNotIn?.toBuilder();
      _fullNameGT = $v.fullNameGT;
      _fullNameGTE = $v.fullNameGTE;
      _fullNameLT = $v.fullNameLT;
      _fullNameLTE = $v.fullNameLTE;
      _fullNameContains = $v.fullNameContains;
      _fullNameHasPrefix = $v.fullNameHasPrefix;
      _fullNameHasSuffix = $v.fullNameHasSuffix;
      _fullNameIsNil = $v.fullNameIsNil;
      _fullNameNotNil = $v.fullNameNotNil;
      _fullNameEqualFold = $v.fullNameEqualFold;
      _fullNameContainsFold = $v.fullNameContainsFold;
      _birthDate = $v.birthDate?.toBuilder();
      _birthDateNEQ = $v.birthDateNEQ?.toBuilder();
      _birthDateIn = $v.birthDateIn?.toBuilder();
      _birthDateNotIn = $v.birthDateNotIn?.toBuilder();
      _birthDateGT = $v.birthDateGT?.toBuilder();
      _birthDateGTE = $v.birthDateGTE?.toBuilder();
      _birthDateLT = $v.birthDateLT?.toBuilder();
      _birthDateLTE = $v.birthDateLTE?.toBuilder();
      _birthDateIsNil = $v.birthDateIsNil;
      _birthDateNotNil = $v.birthDateNotNil;
      _studyTime = $v.studyTime;
      _studyTimeNEQ = $v.studyTimeNEQ;
      _studyTimeIn = $v.studyTimeIn?.toBuilder();
      _studyTimeNotIn = $v.studyTimeNotIn?.toBuilder();
      _studyTimeIsNil = $v.studyTimeIsNil;
      _studyTimeNotNil = $v.studyTimeNotNil;
      _role = $v.role;
      _roleNEQ = $v.roleNEQ;
      _roleIn = $v.roleIn?.toBuilder();
      _roleNotIn = $v.roleNotIn?.toBuilder();
      _simoCoins = $v.simoCoins;
      _simoCoinsNEQ = $v.simoCoinsNEQ;
      _simoCoinsIn = $v.simoCoinsIn?.toBuilder();
      _simoCoinsNotIn = $v.simoCoinsNotIn?.toBuilder();
      _simoCoinsGT = $v.simoCoinsGT;
      _simoCoinsGTE = $v.simoCoinsGTE;
      _simoCoinsLT = $v.simoCoinsLT;
      _simoCoinsLTE = $v.simoCoinsLTE;
      _score = $v.score;
      _scoreNEQ = $v.scoreNEQ;
      _scoreIn = $v.scoreIn?.toBuilder();
      _scoreNotIn = $v.scoreNotIn?.toBuilder();
      _scoreGT = $v.scoreGT;
      _scoreGTE = $v.scoreGTE;
      _scoreLT = $v.scoreLT;
      _scoreLTE = $v.scoreLTE;
      _isPremium = $v.isPremium;
      _isPremiumNEQ = $v.isPremiumNEQ;
      _major = $v.major;
      _majorNEQ = $v.majorNEQ;
      _majorIn = $v.majorIn?.toBuilder();
      _majorNotIn = $v.majorNotIn?.toBuilder();
      _majorGT = $v.majorGT;
      _majorGTE = $v.majorGTE;
      _majorLT = $v.majorLT;
      _majorLTE = $v.majorLTE;
      _majorContains = $v.majorContains;
      _majorHasPrefix = $v.majorHasPrefix;
      _majorHasSuffix = $v.majorHasSuffix;
      _majorIsNil = $v.majorIsNil;
      _majorNotNil = $v.majorNotNil;
      _majorEqualFold = $v.majorEqualFold;
      _majorContainsFold = $v.majorContainsFold;
      _bio = $v.bio;
      _bioNEQ = $v.bioNEQ;
      _bioIn = $v.bioIn?.toBuilder();
      _bioNotIn = $v.bioNotIn?.toBuilder();
      _bioGT = $v.bioGT;
      _bioGTE = $v.bioGTE;
      _bioLT = $v.bioLT;
      _bioLTE = $v.bioLTE;
      _bioContains = $v.bioContains;
      _bioHasPrefix = $v.bioHasPrefix;
      _bioHasSuffix = $v.bioHasSuffix;
      _bioIsNil = $v.bioIsNil;
      _bioNotNil = $v.bioNotNil;
      _bioEqualFold = $v.bioEqualFold;
      _bioContainsFold = $v.bioContainsFold;
      _hasInterests = $v.hasInterests;
      _hasInterestsWith = $v.hasInterestsWith?.toBuilder();
      _hasGoals = $v.hasGoals;
      _hasGoalsWith = $v.hasGoalsWith?.toBuilder();
      _hasTasks = $v.hasTasks;
      _hasTasksWith = $v.hasTasksWith?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUserWhereInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GUserWhereInput;
  }

  @override
  void update(void Function(GUserWhereInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUserWhereInput build() => _build();

  _$GUserWhereInput _build() {
    _$GUserWhereInput _$result;
    try {
      _$result = _$v ??
          new _$GUserWhereInput._(
              not: _not?.build(),
              and: _and?.build(),
              or: _or?.build(),
              id: id,
              idNEQ: idNEQ,
              idIn: _idIn?.build(),
              idNotIn: _idNotIn?.build(),
              idGT: idGT,
              idGTE: idGTE,
              idLT: idLT,
              idLTE: idLTE,
              createdAt: _createdAt?.build(),
              createdAtNEQ: _createdAtNEQ?.build(),
              createdAtIn: _createdAtIn?.build(),
              createdAtNotIn: _createdAtNotIn?.build(),
              createdAtGT: _createdAtGT?.build(),
              createdAtGTE: _createdAtGTE?.build(),
              createdAtLT: _createdAtLT?.build(),
              createdAtLTE: _createdAtLTE?.build(),
              updatedAt: _updatedAt?.build(),
              updatedAtNEQ: _updatedAtNEQ?.build(),
              updatedAtIn: _updatedAtIn?.build(),
              updatedAtNotIn: _updatedAtNotIn?.build(),
              updatedAtGT: _updatedAtGT?.build(),
              updatedAtGTE: _updatedAtGTE?.build(),
              updatedAtLT: _updatedAtLT?.build(),
              updatedAtLTE: _updatedAtLTE?.build(),
              phoneNumber: phoneNumber,
              phoneNumberNEQ: phoneNumberNEQ,
              phoneNumberIn: _phoneNumberIn?.build(),
              phoneNumberNotIn: _phoneNumberNotIn?.build(),
              phoneNumberGT: phoneNumberGT,
              phoneNumberGTE: phoneNumberGTE,
              phoneNumberLT: phoneNumberLT,
              phoneNumberLTE: phoneNumberLTE,
              phoneNumberContains: phoneNumberContains,
              phoneNumberHasPrefix: phoneNumberHasPrefix,
              phoneNumberHasSuffix: phoneNumberHasSuffix,
              phoneNumberEqualFold: phoneNumberEqualFold,
              phoneNumberContainsFold: phoneNumberContainsFold,
              fullName: fullName,
              fullNameNEQ: fullNameNEQ,
              fullNameIn: _fullNameIn?.build(),
              fullNameNotIn: _fullNameNotIn?.build(),
              fullNameGT: fullNameGT,
              fullNameGTE: fullNameGTE,
              fullNameLT: fullNameLT,
              fullNameLTE: fullNameLTE,
              fullNameContains: fullNameContains,
              fullNameHasPrefix: fullNameHasPrefix,
              fullNameHasSuffix: fullNameHasSuffix,
              fullNameIsNil: fullNameIsNil,
              fullNameNotNil: fullNameNotNil,
              fullNameEqualFold: fullNameEqualFold,
              fullNameContainsFold: fullNameContainsFold,
              birthDate: _birthDate?.build(),
              birthDateNEQ: _birthDateNEQ?.build(),
              birthDateIn: _birthDateIn?.build(),
              birthDateNotIn: _birthDateNotIn?.build(),
              birthDateGT: _birthDateGT?.build(),
              birthDateGTE: _birthDateGTE?.build(),
              birthDateLT: _birthDateLT?.build(),
              birthDateLTE: _birthDateLTE?.build(),
              birthDateIsNil: birthDateIsNil,
              birthDateNotNil: birthDateNotNil,
              studyTime: studyTime,
              studyTimeNEQ: studyTimeNEQ,
              studyTimeIn: _studyTimeIn?.build(),
              studyTimeNotIn: _studyTimeNotIn?.build(),
              studyTimeIsNil: studyTimeIsNil,
              studyTimeNotNil: studyTimeNotNil,
              role: role,
              roleNEQ: roleNEQ,
              roleIn: _roleIn?.build(),
              roleNotIn: _roleNotIn?.build(),
              simoCoins: simoCoins,
              simoCoinsNEQ: simoCoinsNEQ,
              simoCoinsIn: _simoCoinsIn?.build(),
              simoCoinsNotIn: _simoCoinsNotIn?.build(),
              simoCoinsGT: simoCoinsGT,
              simoCoinsGTE: simoCoinsGTE,
              simoCoinsLT: simoCoinsLT,
              simoCoinsLTE: simoCoinsLTE,
              score: score,
              scoreNEQ: scoreNEQ,
              scoreIn: _scoreIn?.build(),
              scoreNotIn: _scoreNotIn?.build(),
              scoreGT: scoreGT,
              scoreGTE: scoreGTE,
              scoreLT: scoreLT,
              scoreLTE: scoreLTE,
              isPremium: isPremium,
              isPremiumNEQ: isPremiumNEQ,
              major: major,
              majorNEQ: majorNEQ,
              majorIn: _majorIn?.build(),
              majorNotIn: _majorNotIn?.build(),
              majorGT: majorGT,
              majorGTE: majorGTE,
              majorLT: majorLT,
              majorLTE: majorLTE,
              majorContains: majorContains,
              majorHasPrefix: majorHasPrefix,
              majorHasSuffix: majorHasSuffix,
              majorIsNil: majorIsNil,
              majorNotNil: majorNotNil,
              majorEqualFold: majorEqualFold,
              majorContainsFold: majorContainsFold,
              bio: bio,
              bioNEQ: bioNEQ,
              bioIn: _bioIn?.build(),
              bioNotIn: _bioNotIn?.build(),
              bioGT: bioGT,
              bioGTE: bioGTE,
              bioLT: bioLT,
              bioLTE: bioLTE,
              bioContains: bioContains,
              bioHasPrefix: bioHasPrefix,
              bioHasSuffix: bioHasSuffix,
              bioIsNil: bioIsNil,
              bioNotNil: bioNotNil,
              bioEqualFold: bioEqualFold,
              bioContainsFold: bioContainsFold,
              hasInterests: hasInterests,
              hasInterestsWith: _hasInterestsWith?.build(),
              hasGoals: hasGoals,
              hasGoalsWith: _hasGoalsWith?.build(),
              hasTasks: hasTasks,
              hasTasksWith: _hasTasksWith?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'not';
        _not?.build();
        _$failedField = 'and';
        _and?.build();
        _$failedField = 'or';
        _or?.build();

        _$failedField = 'idIn';
        _idIn?.build();
        _$failedField = 'idNotIn';
        _idNotIn?.build();

        _$failedField = 'createdAt';
        _createdAt?.build();
        _$failedField = 'createdAtNEQ';
        _createdAtNEQ?.build();
        _$failedField = 'createdAtIn';
        _createdAtIn?.build();
        _$failedField = 'createdAtNotIn';
        _createdAtNotIn?.build();
        _$failedField = 'createdAtGT';
        _createdAtGT?.build();
        _$failedField = 'createdAtGTE';
        _createdAtGTE?.build();
        _$failedField = 'createdAtLT';
        _createdAtLT?.build();
        _$failedField = 'createdAtLTE';
        _createdAtLTE?.build();
        _$failedField = 'updatedAt';
        _updatedAt?.build();
        _$failedField = 'updatedAtNEQ';
        _updatedAtNEQ?.build();
        _$failedField = 'updatedAtIn';
        _updatedAtIn?.build();
        _$failedField = 'updatedAtNotIn';
        _updatedAtNotIn?.build();
        _$failedField = 'updatedAtGT';
        _updatedAtGT?.build();
        _$failedField = 'updatedAtGTE';
        _updatedAtGTE?.build();
        _$failedField = 'updatedAtLT';
        _updatedAtLT?.build();
        _$failedField = 'updatedAtLTE';
        _updatedAtLTE?.build();

        _$failedField = 'phoneNumberIn';
        _phoneNumberIn?.build();
        _$failedField = 'phoneNumberNotIn';
        _phoneNumberNotIn?.build();

        _$failedField = 'fullNameIn';
        _fullNameIn?.build();
        _$failedField = 'fullNameNotIn';
        _fullNameNotIn?.build();

        _$failedField = 'birthDate';
        _birthDate?.build();
        _$failedField = 'birthDateNEQ';
        _birthDateNEQ?.build();
        _$failedField = 'birthDateIn';
        _birthDateIn?.build();
        _$failedField = 'birthDateNotIn';
        _birthDateNotIn?.build();
        _$failedField = 'birthDateGT';
        _birthDateGT?.build();
        _$failedField = 'birthDateGTE';
        _birthDateGTE?.build();
        _$failedField = 'birthDateLT';
        _birthDateLT?.build();
        _$failedField = 'birthDateLTE';
        _birthDateLTE?.build();

        _$failedField = 'studyTimeIn';
        _studyTimeIn?.build();
        _$failedField = 'studyTimeNotIn';
        _studyTimeNotIn?.build();

        _$failedField = 'roleIn';
        _roleIn?.build();
        _$failedField = 'roleNotIn';
        _roleNotIn?.build();

        _$failedField = 'simoCoinsIn';
        _simoCoinsIn?.build();
        _$failedField = 'simoCoinsNotIn';
        _simoCoinsNotIn?.build();

        _$failedField = 'scoreIn';
        _scoreIn?.build();
        _$failedField = 'scoreNotIn';
        _scoreNotIn?.build();

        _$failedField = 'majorIn';
        _majorIn?.build();
        _$failedField = 'majorNotIn';
        _majorNotIn?.build();

        _$failedField = 'bioIn';
        _bioIn?.build();
        _$failedField = 'bioNotIn';
        _bioNotIn?.build();

        _$failedField = 'hasInterestsWith';
        _hasInterestsWith?.build();

        _$failedField = 'hasGoalsWith';
        _hasGoalsWith?.build();

        _$failedField = 'hasTasksWith';
        _hasTasksWith?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GUserWhereInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndLoginInput extends GVerifyOTPAndLoginInput {
  @override
  final String phoneNumber;
  @override
  final String code;

  factory _$GVerifyOTPAndLoginInput(
          [void Function(GVerifyOTPAndLoginInputBuilder)? updates]) =>
      (new GVerifyOTPAndLoginInputBuilder()..update(updates))._build();

  _$GVerifyOTPAndLoginInput._({required this.phoneNumber, required this.code})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        phoneNumber, r'GVerifyOTPAndLoginInput', 'phoneNumber');
    BuiltValueNullFieldError.checkNotNull(
        code, r'GVerifyOTPAndLoginInput', 'code');
  }

  @override
  GVerifyOTPAndLoginInput rebuild(
          void Function(GVerifyOTPAndLoginInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndLoginInputBuilder toBuilder() =>
      new GVerifyOTPAndLoginInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndLoginInput &&
        phoneNumber == other.phoneNumber &&
        code == other.code;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phoneNumber.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndLoginInput')
          ..add('phoneNumber', phoneNumber)
          ..add('code', code))
        .toString();
  }
}

class GVerifyOTPAndLoginInputBuilder
    implements
        Builder<GVerifyOTPAndLoginInput, GVerifyOTPAndLoginInputBuilder> {
  _$GVerifyOTPAndLoginInput? _$v;

  String? _phoneNumber;
  String? get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String? phoneNumber) => _$this._phoneNumber = phoneNumber;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  GVerifyOTPAndLoginInputBuilder();

  GVerifyOTPAndLoginInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phoneNumber = $v.phoneNumber;
      _code = $v.code;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndLoginInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GVerifyOTPAndLoginInput;
  }

  @override
  void update(void Function(GVerifyOTPAndLoginInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndLoginInput build() => _build();

  _$GVerifyOTPAndLoginInput _build() {
    final _$result = _$v ??
        new _$GVerifyOTPAndLoginInput._(
            phoneNumber: BuiltValueNullFieldError.checkNotNull(
                phoneNumber, r'GVerifyOTPAndLoginInput', 'phoneNumber'),
            code: BuiltValueNullFieldError.checkNotNull(
                code, r'GVerifyOTPAndLoginInput', 'code'));
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndRegisterInput extends GVerifyOTPAndRegisterInput {
  @override
  final String phoneNumber;
  @override
  final String code;
  @override
  final String fullName;
  @override
  final GTime birthDate;
  @override
  final GUserStudyTime studyTime;

  factory _$GVerifyOTPAndRegisterInput(
          [void Function(GVerifyOTPAndRegisterInputBuilder)? updates]) =>
      (new GVerifyOTPAndRegisterInputBuilder()..update(updates))._build();

  _$GVerifyOTPAndRegisterInput._(
      {required this.phoneNumber,
      required this.code,
      required this.fullName,
      required this.birthDate,
      required this.studyTime})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        phoneNumber, r'GVerifyOTPAndRegisterInput', 'phoneNumber');
    BuiltValueNullFieldError.checkNotNull(
        code, r'GVerifyOTPAndRegisterInput', 'code');
    BuiltValueNullFieldError.checkNotNull(
        fullName, r'GVerifyOTPAndRegisterInput', 'fullName');
    BuiltValueNullFieldError.checkNotNull(
        birthDate, r'GVerifyOTPAndRegisterInput', 'birthDate');
    BuiltValueNullFieldError.checkNotNull(
        studyTime, r'GVerifyOTPAndRegisterInput', 'studyTime');
  }

  @override
  GVerifyOTPAndRegisterInput rebuild(
          void Function(GVerifyOTPAndRegisterInputBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndRegisterInputBuilder toBuilder() =>
      new GVerifyOTPAndRegisterInputBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndRegisterInput &&
        phoneNumber == other.phoneNumber &&
        code == other.code &&
        fullName == other.fullName &&
        birthDate == other.birthDate &&
        studyTime == other.studyTime;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, phoneNumber.hashCode);
    _$hash = $jc(_$hash, code.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, birthDate.hashCode);
    _$hash = $jc(_$hash, studyTime.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndRegisterInput')
          ..add('phoneNumber', phoneNumber)
          ..add('code', code)
          ..add('fullName', fullName)
          ..add('birthDate', birthDate)
          ..add('studyTime', studyTime))
        .toString();
  }
}

class GVerifyOTPAndRegisterInputBuilder
    implements
        Builder<GVerifyOTPAndRegisterInput, GVerifyOTPAndRegisterInputBuilder> {
  _$GVerifyOTPAndRegisterInput? _$v;

  String? _phoneNumber;
  String? get phoneNumber => _$this._phoneNumber;
  set phoneNumber(String? phoneNumber) => _$this._phoneNumber = phoneNumber;

  String? _code;
  String? get code => _$this._code;
  set code(String? code) => _$this._code = code;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  GTimeBuilder? _birthDate;
  GTimeBuilder get birthDate => _$this._birthDate ??= new GTimeBuilder();
  set birthDate(GTimeBuilder? birthDate) => _$this._birthDate = birthDate;

  GUserStudyTime? _studyTime;
  GUserStudyTime? get studyTime => _$this._studyTime;
  set studyTime(GUserStudyTime? studyTime) => _$this._studyTime = studyTime;

  GVerifyOTPAndRegisterInputBuilder();

  GVerifyOTPAndRegisterInputBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _phoneNumber = $v.phoneNumber;
      _code = $v.code;
      _fullName = $v.fullName;
      _birthDate = $v.birthDate.toBuilder();
      _studyTime = $v.studyTime;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndRegisterInput other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GVerifyOTPAndRegisterInput;
  }

  @override
  void update(void Function(GVerifyOTPAndRegisterInputBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndRegisterInput build() => _build();

  _$GVerifyOTPAndRegisterInput _build() {
    _$GVerifyOTPAndRegisterInput _$result;
    try {
      _$result = _$v ??
          new _$GVerifyOTPAndRegisterInput._(
              phoneNumber: BuiltValueNullFieldError.checkNotNull(
                  phoneNumber, r'GVerifyOTPAndRegisterInput', 'phoneNumber'),
              code: BuiltValueNullFieldError.checkNotNull(
                  code, r'GVerifyOTPAndRegisterInput', 'code'),
              fullName: BuiltValueNullFieldError.checkNotNull(
                  fullName, r'GVerifyOTPAndRegisterInput', 'fullName'),
              birthDate: birthDate.build(),
              studyTime: BuiltValueNullFieldError.checkNotNull(
                  studyTime, r'GVerifyOTPAndRegisterInput', 'studyTime'));
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'birthDate';
        birthDate.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GVerifyOTPAndRegisterInput', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
