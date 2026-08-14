// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_chat_messages.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetChatMessagesData> _$gGetChatMessagesDataSerializer =
    _$GGetChatMessagesDataSerializer();
Serializer<GGetChatMessagesData_getChatMessages>
    _$gGetChatMessagesDataGetChatMessagesSerializer =
    _$GGetChatMessagesData_getChatMessagesSerializer();
Serializer<GGetChatMessagesData_getChatMessages_replyTo>
    _$gGetChatMessagesDataGetChatMessagesReplyToSerializer =
    _$GGetChatMessagesData_getChatMessages_replyToSerializer();
Serializer<GGetChatMessagesData_getChatMessages_sender>
    _$gGetChatMessagesDataGetChatMessagesSenderSerializer =
    _$GGetChatMessagesData_getChatMessages_senderSerializer();

class _$GGetChatMessagesDataSerializer
    implements StructuredSerializer<GGetChatMessagesData> {
  @override
  final Iterable<Type> types = const [
    GGetChatMessagesData,
    _$GGetChatMessagesData
  ];
  @override
  final String wireName = 'GGetChatMessagesData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetChatMessagesData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'getChatMessages',
      serializers.serialize(object.getChatMessages,
          specifiedType: const FullType(BuiltList,
              const [const FullType(GGetChatMessagesData_getChatMessages)])),
    ];

    return result;
  }

  @override
  GGetChatMessagesData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetChatMessagesDataBuilder();

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
        case 'getChatMessages':
          result.getChatMessages.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GGetChatMessagesData_getChatMessages)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetChatMessagesData_getChatMessagesSerializer
    implements StructuredSerializer<GGetChatMessagesData_getChatMessages> {
  @override
  final Iterable<Type> types = const [
    GGetChatMessagesData_getChatMessages,
    _$GGetChatMessagesData_getChatMessages
  ];
  @override
  final String wireName = 'GGetChatMessagesData_getChatMessages';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetChatMessagesData_getChatMessages object,
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
      'sender',
      serializers.serialize(object.sender,
          specifiedType:
              const FullType(GGetChatMessagesData_getChatMessages_sender)),
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
    value = object.replyTo;
    if (value != null) {
      result
        ..add('replyTo')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(GGetChatMessagesData_getChatMessages_replyTo)));
    }
    return result;
  }

  @override
  GGetChatMessagesData_getChatMessages deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetChatMessagesData_getChatMessagesBuilder();

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
        case 'replyTo':
          result.replyTo.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GGetChatMessagesData_getChatMessages_replyTo))!
              as GGetChatMessagesData_getChatMessages_replyTo);
          break;
        case 'sender':
          result.sender.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GGetChatMessagesData_getChatMessages_sender))!
              as GGetChatMessagesData_getChatMessages_sender);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetChatMessagesData_getChatMessages_replyToSerializer
    implements
        StructuredSerializer<GGetChatMessagesData_getChatMessages_replyTo> {
  @override
  final Iterable<Type> types = const [
    GGetChatMessagesData_getChatMessages_replyTo,
    _$GGetChatMessagesData_getChatMessages_replyTo
  ];
  @override
  final String wireName = 'GGetChatMessagesData_getChatMessages_replyTo';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GGetChatMessagesData_getChatMessages_replyTo object,
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
      'senderID',
      serializers.serialize(object.senderID,
          specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
    ];

    return result;
  }

  @override
  GGetChatMessagesData_getChatMessages_replyTo deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetChatMessagesData_getChatMessages_replyToBuilder();

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
        case 'senderID':
          result.senderID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetChatMessagesData_getChatMessages_senderSerializer
    implements
        StructuredSerializer<GGetChatMessagesData_getChatMessages_sender> {
  @override
  final Iterable<Type> types = const [
    GGetChatMessagesData_getChatMessages_sender,
    _$GGetChatMessagesData_getChatMessages_sender
  ];
  @override
  final String wireName = 'GGetChatMessagesData_getChatMessages_sender';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GGetChatMessagesData_getChatMessages_sender object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GGetChatMessagesData_getChatMessages_sender deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetChatMessagesData_getChatMessages_senderBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GGetChatMessagesData extends GGetChatMessagesData {
  @override
  final String G__typename;
  @override
  final BuiltList<GGetChatMessagesData_getChatMessages> getChatMessages;

  factory _$GGetChatMessagesData(
          [void Function(GGetChatMessagesDataBuilder)? updates]) =>
      (GGetChatMessagesDataBuilder()..update(updates))._build();

  _$GGetChatMessagesData._(
      {required this.G__typename, required this.getChatMessages})
      : super._();
  @override
  GGetChatMessagesData rebuild(
          void Function(GGetChatMessagesDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetChatMessagesDataBuilder toBuilder() =>
      GGetChatMessagesDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetChatMessagesData &&
        G__typename == other.G__typename &&
        getChatMessages == other.getChatMessages;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, getChatMessages.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetChatMessagesData')
          ..add('G__typename', G__typename)
          ..add('getChatMessages', getChatMessages))
        .toString();
  }
}

class GGetChatMessagesDataBuilder
    implements Builder<GGetChatMessagesData, GGetChatMessagesDataBuilder> {
  _$GGetChatMessagesData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GGetChatMessagesData_getChatMessages>? _getChatMessages;
  ListBuilder<GGetChatMessagesData_getChatMessages> get getChatMessages =>
      _$this._getChatMessages ??=
          ListBuilder<GGetChatMessagesData_getChatMessages>();
  set getChatMessages(
          ListBuilder<GGetChatMessagesData_getChatMessages>? getChatMessages) =>
      _$this._getChatMessages = getChatMessages;

  GGetChatMessagesDataBuilder() {
    GGetChatMessagesData._initializeBuilder(this);
  }

  GGetChatMessagesDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _getChatMessages = $v.getChatMessages.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetChatMessagesData other) {
    _$v = other as _$GGetChatMessagesData;
  }

  @override
  void update(void Function(GGetChatMessagesDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetChatMessagesData build() => _build();

  _$GGetChatMessagesData _build() {
    _$GGetChatMessagesData _$result;
    try {
      _$result = _$v ??
          _$GGetChatMessagesData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetChatMessagesData', 'G__typename'),
            getChatMessages: getChatMessages.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'getChatMessages';
        getChatMessages.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetChatMessagesData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetChatMessagesData_getChatMessages
    extends GGetChatMessagesData_getChatMessages {
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
  @override
  final GGetChatMessagesData_getChatMessages_replyTo? replyTo;
  @override
  final GGetChatMessagesData_getChatMessages_sender sender;

  factory _$GGetChatMessagesData_getChatMessages(
          [void Function(GGetChatMessagesData_getChatMessagesBuilder)?
              updates]) =>
      (GGetChatMessagesData_getChatMessagesBuilder()..update(updates))._build();

  _$GGetChatMessagesData_getChatMessages._(
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
      required this.updatedAt,
      this.replyTo,
      required this.sender})
      : super._();
  @override
  GGetChatMessagesData_getChatMessages rebuild(
          void Function(GGetChatMessagesData_getChatMessagesBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetChatMessagesData_getChatMessagesBuilder toBuilder() =>
      GGetChatMessagesData_getChatMessagesBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetChatMessagesData_getChatMessages &&
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
        updatedAt == other.updatedAt &&
        replyTo == other.replyTo &&
        sender == other.sender;
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
    _$hash = $jc(_$hash, replyTo.hashCode);
    _$hash = $jc(_$hash, sender.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetChatMessagesData_getChatMessages')
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
          ..add('updatedAt', updatedAt)
          ..add('replyTo', replyTo)
          ..add('sender', sender))
        .toString();
  }
}

class GGetChatMessagesData_getChatMessagesBuilder
    implements
        Builder<GGetChatMessagesData_getChatMessages,
            GGetChatMessagesData_getChatMessagesBuilder> {
  _$GGetChatMessagesData_getChatMessages? _$v;

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

  GGetChatMessagesData_getChatMessages_replyToBuilder? _replyTo;
  GGetChatMessagesData_getChatMessages_replyToBuilder get replyTo =>
      _$this._replyTo ??= GGetChatMessagesData_getChatMessages_replyToBuilder();
  set replyTo(GGetChatMessagesData_getChatMessages_replyToBuilder? replyTo) =>
      _$this._replyTo = replyTo;

  GGetChatMessagesData_getChatMessages_senderBuilder? _sender;
  GGetChatMessagesData_getChatMessages_senderBuilder get sender =>
      _$this._sender ??= GGetChatMessagesData_getChatMessages_senderBuilder();
  set sender(GGetChatMessagesData_getChatMessages_senderBuilder? sender) =>
      _$this._sender = sender;

  GGetChatMessagesData_getChatMessagesBuilder() {
    GGetChatMessagesData_getChatMessages._initializeBuilder(this);
  }

  GGetChatMessagesData_getChatMessagesBuilder get _$this {
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
      _replyTo = $v.replyTo?.toBuilder();
      _sender = $v.sender.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetChatMessagesData_getChatMessages other) {
    _$v = other as _$GGetChatMessagesData_getChatMessages;
  }

  @override
  void update(
      void Function(GGetChatMessagesData_getChatMessagesBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetChatMessagesData_getChatMessages build() => _build();

  _$GGetChatMessagesData_getChatMessages _build() {
    _$GGetChatMessagesData_getChatMessages _$result;
    try {
      _$result = _$v ??
          _$GGetChatMessagesData_getChatMessages._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GGetChatMessagesData_getChatMessages', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetChatMessagesData_getChatMessages', 'id'),
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'GGetChatMessagesData_getChatMessages', 'content'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GGetChatMessagesData_getChatMessages', 'type'),
            chatID: BuiltValueNullFieldError.checkNotNull(
                chatID, r'GGetChatMessagesData_getChatMessages', 'chatID'),
            senderID: BuiltValueNullFieldError.checkNotNull(
                senderID, r'GGetChatMessagesData_getChatMessages', 'senderID'),
            replyToID: replyToID,
            isDeleted: BuiltValueNullFieldError.checkNotNull(isDeleted,
                r'GGetChatMessagesData_getChatMessages', 'isDeleted'),
            deletedAt: _deletedAt?.build(),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            replyTo: _replyTo?.build(),
            sender: sender.build(),
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
        _$failedField = 'replyTo';
        _replyTo?.build();
        _$failedField = 'sender';
        sender.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetChatMessagesData_getChatMessages',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetChatMessagesData_getChatMessages_replyTo
    extends GGetChatMessagesData_getChatMessages_replyTo {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String content;
  @override
  final String senderID;
  @override
  final _i2.GTime createdAt;

  factory _$GGetChatMessagesData_getChatMessages_replyTo(
          [void Function(GGetChatMessagesData_getChatMessages_replyToBuilder)?
              updates]) =>
      (GGetChatMessagesData_getChatMessages_replyToBuilder()..update(updates))
          ._build();

  _$GGetChatMessagesData_getChatMessages_replyTo._(
      {required this.G__typename,
      required this.id,
      required this.content,
      required this.senderID,
      required this.createdAt})
      : super._();
  @override
  GGetChatMessagesData_getChatMessages_replyTo rebuild(
          void Function(GGetChatMessagesData_getChatMessages_replyToBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetChatMessagesData_getChatMessages_replyToBuilder toBuilder() =>
      GGetChatMessagesData_getChatMessages_replyToBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetChatMessagesData_getChatMessages_replyTo &&
        G__typename == other.G__typename &&
        id == other.id &&
        content == other.content &&
        senderID == other.senderID &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, senderID.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GGetChatMessagesData_getChatMessages_replyTo')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('content', content)
          ..add('senderID', senderID)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GGetChatMessagesData_getChatMessages_replyToBuilder
    implements
        Builder<GGetChatMessagesData_getChatMessages_replyTo,
            GGetChatMessagesData_getChatMessages_replyToBuilder> {
  _$GGetChatMessagesData_getChatMessages_replyTo? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _senderID;
  String? get senderID => _$this._senderID;
  set senderID(String? senderID) => _$this._senderID = senderID;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GGetChatMessagesData_getChatMessages_replyToBuilder() {
    GGetChatMessagesData_getChatMessages_replyTo._initializeBuilder(this);
  }

  GGetChatMessagesData_getChatMessages_replyToBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _content = $v.content;
      _senderID = $v.senderID;
      _createdAt = $v.createdAt.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetChatMessagesData_getChatMessages_replyTo other) {
    _$v = other as _$GGetChatMessagesData_getChatMessages_replyTo;
  }

  @override
  void update(
      void Function(GGetChatMessagesData_getChatMessages_replyToBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetChatMessagesData_getChatMessages_replyTo build() => _build();

  _$GGetChatMessagesData_getChatMessages_replyTo _build() {
    _$GGetChatMessagesData_getChatMessages_replyTo _$result;
    try {
      _$result = _$v ??
          _$GGetChatMessagesData_getChatMessages_replyTo._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GGetChatMessagesData_getChatMessages_replyTo', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetChatMessagesData_getChatMessages_replyTo', 'id'),
            content: BuiltValueNullFieldError.checkNotNull(content,
                r'GGetChatMessagesData_getChatMessages_replyTo', 'content'),
            senderID: BuiltValueNullFieldError.checkNotNull(senderID,
                r'GGetChatMessagesData_getChatMessages_replyTo', 'senderID'),
            createdAt: createdAt.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetChatMessagesData_getChatMessages_replyTo',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetChatMessagesData_getChatMessages_sender
    extends GGetChatMessagesData_getChatMessages_sender {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GGetChatMessagesData_getChatMessages_sender(
          [void Function(GGetChatMessagesData_getChatMessages_senderBuilder)?
              updates]) =>
      (GGetChatMessagesData_getChatMessages_senderBuilder()..update(updates))
          ._build();

  _$GGetChatMessagesData_getChatMessages_sender._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GGetChatMessagesData_getChatMessages_sender rebuild(
          void Function(GGetChatMessagesData_getChatMessages_senderBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetChatMessagesData_getChatMessages_senderBuilder toBuilder() =>
      GGetChatMessagesData_getChatMessages_senderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetChatMessagesData_getChatMessages_sender &&
        G__typename == other.G__typename &&
        id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GGetChatMessagesData_getChatMessages_sender')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GGetChatMessagesData_getChatMessages_senderBuilder
    implements
        Builder<GGetChatMessagesData_getChatMessages_sender,
            GGetChatMessagesData_getChatMessages_senderBuilder> {
  _$GGetChatMessagesData_getChatMessages_sender? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GGetChatMessagesData_getChatMessages_senderBuilder() {
    GGetChatMessagesData_getChatMessages_sender._initializeBuilder(this);
  }

  GGetChatMessagesData_getChatMessages_senderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetChatMessagesData_getChatMessages_sender other) {
    _$v = other as _$GGetChatMessagesData_getChatMessages_sender;
  }

  @override
  void update(
      void Function(GGetChatMessagesData_getChatMessages_senderBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetChatMessagesData_getChatMessages_sender build() => _build();

  _$GGetChatMessagesData_getChatMessages_sender _build() {
    final _$result = _$v ??
        _$GGetChatMessagesData_getChatMessages_sender._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GGetChatMessagesData_getChatMessages_sender', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GGetChatMessagesData_getChatMessages_sender', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
