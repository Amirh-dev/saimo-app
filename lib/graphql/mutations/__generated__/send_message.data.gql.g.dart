// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSendMessageData> _$gSendMessageDataSerializer =
    new _$GSendMessageDataSerializer();
Serializer<GSendMessageData_sendMessage>
    _$gSendMessageDataSendMessageSerializer =
    new _$GSendMessageData_sendMessageSerializer();
Serializer<GSendMessageData_sendMessage_replyTo>
    _$gSendMessageDataSendMessageReplyToSerializer =
    new _$GSendMessageData_sendMessage_replyToSerializer();
Serializer<GSendMessageData_sendMessage_sender>
    _$gSendMessageDataSendMessageSenderSerializer =
    new _$GSendMessageData_sendMessage_senderSerializer();

class _$GSendMessageDataSerializer
    implements StructuredSerializer<GSendMessageData> {
  @override
  final Iterable<Type> types = const [GSendMessageData, _$GSendMessageData];
  @override
  final String wireName = 'GSendMessageData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendMessageData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'sendMessage',
      serializers.serialize(object.sendMessage,
          specifiedType: const FullType(GSendMessageData_sendMessage)),
    ];

    return result;
  }

  @override
  GSendMessageData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendMessageDataBuilder();

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
        case 'sendMessage':
          result.sendMessage.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GSendMessageData_sendMessage))!
              as GSendMessageData_sendMessage);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendMessageData_sendMessageSerializer
    implements StructuredSerializer<GSendMessageData_sendMessage> {
  @override
  final Iterable<Type> types = const [
    GSendMessageData_sendMessage,
    _$GSendMessageData_sendMessage
  ];
  @override
  final String wireName = 'GSendMessageData_sendMessage';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendMessageData_sendMessage object,
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
          specifiedType: const FullType(GSendMessageData_sendMessage_sender)),
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
                const FullType(GSendMessageData_sendMessage_replyTo)));
    }
    return result;
  }

  @override
  GSendMessageData_sendMessage deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendMessageData_sendMessageBuilder();

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
                  specifiedType:
                      const FullType(GSendMessageData_sendMessage_replyTo))!
              as GSendMessageData_sendMessage_replyTo);
          break;
        case 'sender':
          result.sender.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GSendMessageData_sendMessage_sender))!
              as GSendMessageData_sendMessage_sender);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendMessageData_sendMessage_replyToSerializer
    implements StructuredSerializer<GSendMessageData_sendMessage_replyTo> {
  @override
  final Iterable<Type> types = const [
    GSendMessageData_sendMessage_replyTo,
    _$GSendMessageData_sendMessage_replyTo
  ];
  @override
  final String wireName = 'GSendMessageData_sendMessage_replyTo';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendMessageData_sendMessage_replyTo object,
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
  GSendMessageData_sendMessage_replyTo deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendMessageData_sendMessage_replyToBuilder();

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

class _$GSendMessageData_sendMessage_senderSerializer
    implements StructuredSerializer<GSendMessageData_sendMessage_sender> {
  @override
  final Iterable<Type> types = const [
    GSendMessageData_sendMessage_sender,
    _$GSendMessageData_sendMessage_sender
  ];
  @override
  final String wireName = 'GSendMessageData_sendMessage_sender';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendMessageData_sendMessage_sender object,
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
  GSendMessageData_sendMessage_sender deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendMessageData_sendMessage_senderBuilder();

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

class _$GSendMessageData extends GSendMessageData {
  @override
  final String G__typename;
  @override
  final GSendMessageData_sendMessage sendMessage;

  factory _$GSendMessageData(
          [void Function(GSendMessageDataBuilder)? updates]) =>
      (new GSendMessageDataBuilder()..update(updates))._build();

  _$GSendMessageData._({required this.G__typename, required this.sendMessage})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GSendMessageData', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        sendMessage, r'GSendMessageData', 'sendMessage');
  }

  @override
  GSendMessageData rebuild(void Function(GSendMessageDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageDataBuilder toBuilder() =>
      new GSendMessageDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageData &&
        G__typename == other.G__typename &&
        sendMessage == other.sendMessage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, sendMessage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendMessageData')
          ..add('G__typename', G__typename)
          ..add('sendMessage', sendMessage))
        .toString();
  }
}

class GSendMessageDataBuilder
    implements Builder<GSendMessageData, GSendMessageDataBuilder> {
  _$GSendMessageData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSendMessageData_sendMessageBuilder? _sendMessage;
  GSendMessageData_sendMessageBuilder get sendMessage =>
      _$this._sendMessage ??= new GSendMessageData_sendMessageBuilder();
  set sendMessage(GSendMessageData_sendMessageBuilder? sendMessage) =>
      _$this._sendMessage = sendMessage;

  GSendMessageDataBuilder() {
    GSendMessageData._initializeBuilder(this);
  }

  GSendMessageDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _sendMessage = $v.sendMessage.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendMessageData other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendMessageData;
  }

  @override
  void update(void Function(GSendMessageDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageData build() => _build();

  _$GSendMessageData _build() {
    _$GSendMessageData _$result;
    try {
      _$result = _$v ??
          new _$GSendMessageData._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GSendMessageData', 'G__typename'),
              sendMessage: sendMessage.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sendMessage';
        sendMessage.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GSendMessageData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendMessageData_sendMessage extends GSendMessageData_sendMessage {
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
  final GSendMessageData_sendMessage_replyTo? replyTo;
  @override
  final GSendMessageData_sendMessage_sender sender;

  factory _$GSendMessageData_sendMessage(
          [void Function(GSendMessageData_sendMessageBuilder)? updates]) =>
      (new GSendMessageData_sendMessageBuilder()..update(updates))._build();

  _$GSendMessageData_sendMessage._(
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
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GSendMessageData_sendMessage', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GSendMessageData_sendMessage', 'id');
    BuiltValueNullFieldError.checkNotNull(
        content, r'GSendMessageData_sendMessage', 'content');
    BuiltValueNullFieldError.checkNotNull(
        type, r'GSendMessageData_sendMessage', 'type');
    BuiltValueNullFieldError.checkNotNull(
        chatID, r'GSendMessageData_sendMessage', 'chatID');
    BuiltValueNullFieldError.checkNotNull(
        senderID, r'GSendMessageData_sendMessage', 'senderID');
    BuiltValueNullFieldError.checkNotNull(
        isDeleted, r'GSendMessageData_sendMessage', 'isDeleted');
    BuiltValueNullFieldError.checkNotNull(
        createdAt, r'GSendMessageData_sendMessage', 'createdAt');
    BuiltValueNullFieldError.checkNotNull(
        updatedAt, r'GSendMessageData_sendMessage', 'updatedAt');
    BuiltValueNullFieldError.checkNotNull(
        sender, r'GSendMessageData_sendMessage', 'sender');
  }

  @override
  GSendMessageData_sendMessage rebuild(
          void Function(GSendMessageData_sendMessageBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageData_sendMessageBuilder toBuilder() =>
      new GSendMessageData_sendMessageBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageData_sendMessage &&
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
    return (newBuiltValueToStringHelper(r'GSendMessageData_sendMessage')
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

class GSendMessageData_sendMessageBuilder
    implements
        Builder<GSendMessageData_sendMessage,
            GSendMessageData_sendMessageBuilder> {
  _$GSendMessageData_sendMessage? _$v;

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
  _i2.GTimeBuilder get deletedAt =>
      _$this._deletedAt ??= new _i2.GTimeBuilder();
  set deletedAt(_i2.GTimeBuilder? deletedAt) => _$this._deletedAt = deletedAt;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt =>
      _$this._createdAt ??= new _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i2.GTimeBuilder? _updatedAt;
  _i2.GTimeBuilder get updatedAt =>
      _$this._updatedAt ??= new _i2.GTimeBuilder();
  set updatedAt(_i2.GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  GSendMessageData_sendMessage_replyToBuilder? _replyTo;
  GSendMessageData_sendMessage_replyToBuilder get replyTo =>
      _$this._replyTo ??= new GSendMessageData_sendMessage_replyToBuilder();
  set replyTo(GSendMessageData_sendMessage_replyToBuilder? replyTo) =>
      _$this._replyTo = replyTo;

  GSendMessageData_sendMessage_senderBuilder? _sender;
  GSendMessageData_sendMessage_senderBuilder get sender =>
      _$this._sender ??= new GSendMessageData_sendMessage_senderBuilder();
  set sender(GSendMessageData_sendMessage_senderBuilder? sender) =>
      _$this._sender = sender;

  GSendMessageData_sendMessageBuilder() {
    GSendMessageData_sendMessage._initializeBuilder(this);
  }

  GSendMessageData_sendMessageBuilder get _$this {
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
  void replace(GSendMessageData_sendMessage other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendMessageData_sendMessage;
  }

  @override
  void update(void Function(GSendMessageData_sendMessageBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageData_sendMessage build() => _build();

  _$GSendMessageData_sendMessage _build() {
    _$GSendMessageData_sendMessage _$result;
    try {
      _$result = _$v ??
          new _$GSendMessageData_sendMessage._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GSendMessageData_sendMessage', 'G__typename'),
              id: BuiltValueNullFieldError.checkNotNull(
                  id, r'GSendMessageData_sendMessage', 'id'),
              content: BuiltValueNullFieldError.checkNotNull(
                  content, r'GSendMessageData_sendMessage', 'content'),
              type: BuiltValueNullFieldError.checkNotNull(
                  type, r'GSendMessageData_sendMessage', 'type'),
              chatID: BuiltValueNullFieldError.checkNotNull(
                  chatID, r'GSendMessageData_sendMessage', 'chatID'),
              senderID: BuiltValueNullFieldError.checkNotNull(
                  senderID, r'GSendMessageData_sendMessage', 'senderID'),
              replyToID: replyToID,
              isDeleted: BuiltValueNullFieldError.checkNotNull(
                  isDeleted, r'GSendMessageData_sendMessage', 'isDeleted'),
              deletedAt: _deletedAt?.build(),
              createdAt: createdAt.build(),
              updatedAt: updatedAt.build(),
              replyTo: _replyTo?.build(),
              sender: sender.build());
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
        throw new BuiltValueNestedFieldError(
            r'GSendMessageData_sendMessage', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendMessageData_sendMessage_replyTo
    extends GSendMessageData_sendMessage_replyTo {
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

  factory _$GSendMessageData_sendMessage_replyTo(
          [void Function(GSendMessageData_sendMessage_replyToBuilder)?
              updates]) =>
      (new GSendMessageData_sendMessage_replyToBuilder()..update(updates))
          ._build();

  _$GSendMessageData_sendMessage_replyTo._(
      {required this.G__typename,
      required this.id,
      required this.content,
      required this.senderID,
      required this.createdAt})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GSendMessageData_sendMessage_replyTo', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GSendMessageData_sendMessage_replyTo', 'id');
    BuiltValueNullFieldError.checkNotNull(
        content, r'GSendMessageData_sendMessage_replyTo', 'content');
    BuiltValueNullFieldError.checkNotNull(
        senderID, r'GSendMessageData_sendMessage_replyTo', 'senderID');
    BuiltValueNullFieldError.checkNotNull(
        createdAt, r'GSendMessageData_sendMessage_replyTo', 'createdAt');
  }

  @override
  GSendMessageData_sendMessage_replyTo rebuild(
          void Function(GSendMessageData_sendMessage_replyToBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageData_sendMessage_replyToBuilder toBuilder() =>
      new GSendMessageData_sendMessage_replyToBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageData_sendMessage_replyTo &&
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
    return (newBuiltValueToStringHelper(r'GSendMessageData_sendMessage_replyTo')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('content', content)
          ..add('senderID', senderID)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class GSendMessageData_sendMessage_replyToBuilder
    implements
        Builder<GSendMessageData_sendMessage_replyTo,
            GSendMessageData_sendMessage_replyToBuilder> {
  _$GSendMessageData_sendMessage_replyTo? _$v;

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
  _i2.GTimeBuilder get createdAt =>
      _$this._createdAt ??= new _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  GSendMessageData_sendMessage_replyToBuilder() {
    GSendMessageData_sendMessage_replyTo._initializeBuilder(this);
  }

  GSendMessageData_sendMessage_replyToBuilder get _$this {
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
  void replace(GSendMessageData_sendMessage_replyTo other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendMessageData_sendMessage_replyTo;
  }

  @override
  void update(
      void Function(GSendMessageData_sendMessage_replyToBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageData_sendMessage_replyTo build() => _build();

  _$GSendMessageData_sendMessage_replyTo _build() {
    _$GSendMessageData_sendMessage_replyTo _$result;
    try {
      _$result = _$v ??
          new _$GSendMessageData_sendMessage_replyTo._(
              G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                  r'GSendMessageData_sendMessage_replyTo', 'G__typename'),
              id: BuiltValueNullFieldError.checkNotNull(
                  id, r'GSendMessageData_sendMessage_replyTo', 'id'),
              content: BuiltValueNullFieldError.checkNotNull(
                  content, r'GSendMessageData_sendMessage_replyTo', 'content'),
              senderID: BuiltValueNullFieldError.checkNotNull(senderID,
                  r'GSendMessageData_sendMessage_replyTo', 'senderID'),
              createdAt: createdAt.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GSendMessageData_sendMessage_replyTo',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendMessageData_sendMessage_sender
    extends GSendMessageData_sendMessage_sender {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GSendMessageData_sendMessage_sender(
          [void Function(GSendMessageData_sendMessage_senderBuilder)?
              updates]) =>
      (new GSendMessageData_sendMessage_senderBuilder()..update(updates))
          ._build();

  _$GSendMessageData_sendMessage_sender._(
      {required this.G__typename, required this.id})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GSendMessageData_sendMessage_sender', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GSendMessageData_sendMessage_sender', 'id');
  }

  @override
  GSendMessageData_sendMessage_sender rebuild(
          void Function(GSendMessageData_sendMessage_senderBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageData_sendMessage_senderBuilder toBuilder() =>
      new GSendMessageData_sendMessage_senderBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageData_sendMessage_sender &&
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
    return (newBuiltValueToStringHelper(r'GSendMessageData_sendMessage_sender')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GSendMessageData_sendMessage_senderBuilder
    implements
        Builder<GSendMessageData_sendMessage_sender,
            GSendMessageData_sendMessage_senderBuilder> {
  _$GSendMessageData_sendMessage_sender? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GSendMessageData_sendMessage_senderBuilder() {
    GSendMessageData_sendMessage_sender._initializeBuilder(this);
  }

  GSendMessageData_sendMessage_senderBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendMessageData_sendMessage_sender other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendMessageData_sendMessage_sender;
  }

  @override
  void update(
      void Function(GSendMessageData_sendMessage_senderBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageData_sendMessage_sender build() => _build();

  _$GSendMessageData_sendMessage_sender _build() {
    final _$result = _$v ??
        new _$GSendMessageData_sendMessage_sender._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GSendMessageData_sendMessage_sender', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GSendMessageData_sendMessage_sender', 'id'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
