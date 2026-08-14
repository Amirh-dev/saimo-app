// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_message.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteMessageData> _$gDeleteMessageDataSerializer =
    _$GDeleteMessageDataSerializer();
Serializer<GDeleteMessageData_deleteMessage>
    _$gDeleteMessageDataDeleteMessageSerializer =
    _$GDeleteMessageData_deleteMessageSerializer();

class _$GDeleteMessageDataSerializer
    implements StructuredSerializer<GDeleteMessageData> {
  @override
  final Iterable<Type> types = const [GDeleteMessageData, _$GDeleteMessageData];
  @override
  final String wireName = 'GDeleteMessageData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteMessageData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'deleteMessage',
      serializers.serialize(object.deleteMessage,
          specifiedType: const FullType(GDeleteMessageData_deleteMessage)),
    ];

    return result;
  }

  @override
  GDeleteMessageData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteMessageDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'deleteMessage':
          result.deleteMessage.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GDeleteMessageData_deleteMessage))!
              as GDeleteMessageData_deleteMessage);
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteMessageData_deleteMessageSerializer
    implements StructuredSerializer<GDeleteMessageData_deleteMessage> {
  @override
  final Iterable<Type> types = const [
    GDeleteMessageData_deleteMessage,
    _$GDeleteMessageData_deleteMessage
  ];
  @override
  final String wireName = 'GDeleteMessageData_deleteMessage';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteMessageData_deleteMessage object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'content',
      serializers.serialize(object.content,
          specifiedType: const FullType(String)),
      'type',
      serializers.serialize(object.type,
          specifiedType: const FullType(_i2.GMessageType)),
      'chatID',
      serializers.serialize(object.chatID,
          specifiedType: const FullType(String)),
      'senderID',
      serializers.serialize(object.senderID,
          specifiedType: const FullType(String)),
      'isDeleted',
      serializers.serialize(object.isDeleted,
          specifiedType: const FullType(bool)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'updatedAt',
      serializers.serialize(object.updatedAt,
          specifiedType: const FullType(_i2.GTime)),
    ];
    Object? value;
    value = object.replyToID;
    if (value != null) {
      result
        ..add('replyToID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.deletedAt;
    if (value != null) {
      result
        ..add('deletedAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    return result;
  }

  @override
  GDeleteMessageData_deleteMessage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteMessageData_deleteMessageBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'content':
          result.content = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GMessageType))!
              as _i2.GMessageType;
          break;
        case 'chatID':
          result.chatID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'senderID':
          result.senderID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'replyToID':
          result.replyToID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'isDeleted':
          result.isDeleted = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'deletedAt':
          result.deletedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'updatedAt':
          result.updatedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteMessageData extends GDeleteMessageData {
  @override
  final String G__typename;
  @override
  final GDeleteMessageData_deleteMessage deleteMessage;

  factory _$GDeleteMessageData(
          [void Function(GDeleteMessageDataBuilder)? updates]) =>
      (GDeleteMessageDataBuilder()..update(updates))._build();

  _$GDeleteMessageData._(
      {required this.G__typename, required this.deleteMessage})
      : super._();
  @override
  GDeleteMessageData rebuild(
          void Function(GDeleteMessageDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteMessageDataBuilder toBuilder() =>
      GDeleteMessageDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteMessageData &&
        G__typename == other.G__typename &&
        deleteMessage == other.deleteMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, deleteMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteMessageData')
          ..add('G__typename', G__typename)
          ..add('deleteMessage', deleteMessage))
        .toString();
  }
}

class GDeleteMessageDataBuilder
    implements Builder<GDeleteMessageData, GDeleteMessageDataBuilder> {
  _$GDeleteMessageData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GDeleteMessageData_deleteMessageBuilder? _deleteMessage;
  GDeleteMessageData_deleteMessageBuilder get deleteMessage =>
      _$this._deleteMessage ??= GDeleteMessageData_deleteMessageBuilder();
  set deleteMessage(GDeleteMessageData_deleteMessageBuilder? deleteMessage) =>
      _$this._deleteMessage = deleteMessage;

  GDeleteMessageDataBuilder() {
    GDeleteMessageData._initializeBuilder(this);
  }

  GDeleteMessageDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _deleteMessage = $v.deleteMessage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteMessageData other) {
    _$v = other as _$GDeleteMessageData;
  }

  @override
  void update(void Function(GDeleteMessageDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteMessageData build() => _build();

  _$GDeleteMessageData _build() {
    _$GDeleteMessageData _$result;
    try {
      _$result = _$v ??
          _$GDeleteMessageData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GDeleteMessageData', 'G__typename'),
            deleteMessage: deleteMessage.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deleteMessage';
        deleteMessage.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDeleteMessageData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GDeleteMessageData_deleteMessage
    extends GDeleteMessageData_deleteMessage {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String content;
  @override
  final _i2.GMessageType type;
  @override
  final String chatID;
  @override
  final String senderID;
  @override
  final String? replyToID;
  @override
  final bool isDeleted;
  @override
  final _i2.GTime? deletedAt;
  @override
  final _i2.GTime createdAt;
  @override
  final _i2.GTime updatedAt;

  factory _$GDeleteMessageData_deleteMessage(
          [void Function(GDeleteMessageData_deleteMessageBuilder)? updates]) =>
      (GDeleteMessageData_deleteMessageBuilder()..update(updates))._build();

  _$GDeleteMessageData_deleteMessage._(
      {required this.G__typename,
      required this.id,
      required this.content,
      required this.type,
      required this.chatID,
      required this.senderID,
      this.replyToID,
      required this.isDeleted,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  GDeleteMessageData_deleteMessage rebuild(
          void Function(GDeleteMessageData_deleteMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteMessageData_deleteMessageBuilder toBuilder() =>
      GDeleteMessageData_deleteMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteMessageData_deleteMessage &&
        G__typename == other.G__typename &&
        id == other.id &&
        content == other.content &&
        type == other.type &&
        chatID == other.chatID &&
        senderID == other.senderID &&
        replyToID == other.replyToID &&
        isDeleted == other.isDeleted &&
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, chatID.hashCode);
    _$hash = $jc(_$hash, senderID.hashCode);
    _$hash = $jc(_$hash, replyToID.hashCode);
    _$hash = $jc(_$hash, isDeleted.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteMessageData_deleteMessage')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('content', content)
          ..add('type', type)
          ..add('chatID', chatID)
          ..add('senderID', senderID)
          ..add('replyToID', replyToID)
          ..add('isDeleted', isDeleted)
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class GDeleteMessageData_deleteMessageBuilder
    implements
        Builder<GDeleteMessageData_deleteMessage,
            GDeleteMessageData_deleteMessageBuilder> {
  _$GDeleteMessageData_deleteMessage? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  _i2.GMessageType? _type;
  _i2.GMessageType? get type => _$this._type;
  set type(_i2.GMessageType? type) => _$this._type = type;

  String? _chatID;
  String? get chatID => _$this._chatID;
  set chatID(String? chatID) => _$this._chatID = chatID;

  String? _senderID;
  String? get senderID => _$this._senderID;
  set senderID(String? senderID) => _$this._senderID = senderID;

  String? _replyToID;
  String? get replyToID => _$this._replyToID;
  set replyToID(String? replyToID) => _$this._replyToID = replyToID;

  bool? _isDeleted;
  bool? get isDeleted => _$this._isDeleted;
  set isDeleted(bool? isDeleted) => _$this._isDeleted = isDeleted;

  _i2.GTimeBuilder? _deletedAt;
  _i2.GTimeBuilder get deletedAt => _$this._deletedAt ??= _i2.GTimeBuilder();
  set deletedAt(_i2.GTimeBuilder? deletedAt) => _$this._deletedAt = deletedAt;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i2.GTimeBuilder? _updatedAt;
  _i2.GTimeBuilder get updatedAt => _$this._updatedAt ??= _i2.GTimeBuilder();
  set updatedAt(_i2.GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  GDeleteMessageData_deleteMessageBuilder() {
    GDeleteMessageData_deleteMessage._initializeBuilder(this);
  }

  GDeleteMessageData_deleteMessageBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _content = $v.content;
      _type = $v.type;
      _chatID = $v.chatID;
      _senderID = $v.senderID;
      _replyToID = $v.replyToID;
      _isDeleted = $v.isDeleted;
      _deletedAt = $v.deletedAt?.toBuilder();
      _createdAt = $v.createdAt.toBuilder();
      _updatedAt = $v.updatedAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteMessageData_deleteMessage other) {
    _$v = other as _$GDeleteMessageData_deleteMessage;
  }

  @override
  void update(void Function(GDeleteMessageData_deleteMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteMessageData_deleteMessage build() => _build();

  _$GDeleteMessageData_deleteMessage _build() {
    _$GDeleteMessageData_deleteMessage _$result;
    try {
      _$result = _$v ??
          _$GDeleteMessageData_deleteMessage._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GDeleteMessageData_deleteMessage', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GDeleteMessageData_deleteMessage', 'id'),
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'GDeleteMessageData_deleteMessage', 'content'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GDeleteMessageData_deleteMessage', 'type'),
            chatID: BuiltValueNullFieldError.checkNotNull(
                chatID, r'GDeleteMessageData_deleteMessage', 'chatID'),
            senderID: BuiltValueNullFieldError.checkNotNull(
                senderID, r'GDeleteMessageData_deleteMessage', 'senderID'),
            replyToID: replyToID,
            isDeleted: BuiltValueNullFieldError.checkNotNull(
                isDeleted, r'GDeleteMessageData_deleteMessage', 'isDeleted'),
            deletedAt: _deletedAt?.build(),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'deletedAt';
        _deletedAt?.build();
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'updatedAt';
        updatedAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDeleteMessageData_deleteMessage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
