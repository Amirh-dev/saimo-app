// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_chat_messages.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetChatMessagesVars> _$gGetChatMessagesVarsSerializer =
    new _$GGetChatMessagesVarsSerializer();

class _$GGetChatMessagesVarsSerializer
    implements StructuredSerializer<GGetChatMessagesVars> {
  @override
  final Iterable<Type> types = const [
    GGetChatMessagesVars,
    _$GGetChatMessagesVars
  ];
  @override
  final String wireName = 'GGetChatMessagesVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetChatMessagesVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'chatID',
      serializers.serialize(object.chatID,
          specifiedType: const FullType(_i1.GUUID)),
    ];
    Object? value;
    value = object.limit;
    if (value != null) {
      result
        ..add('limit')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.offset;
    if (value != null) {
      result
        ..add('offset')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  GGetChatMessagesVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGetChatMessagesVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'chatID':
          result.chatID.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GUUID))! as _i1.GUUID);
          break;
        case 'limit':
          result.limit = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'offset':
          result.offset = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetChatMessagesVars extends GGetChatMessagesVars {
  @override
  final _i1.GUUID chatID;
  @override
  final int? limit;
  @override
  final int? offset;

  factory _$GGetChatMessagesVars(
          [void Function(GGetChatMessagesVarsBuilder)? updates]) =>
      (new GGetChatMessagesVarsBuilder()..update(updates))._build();

  _$GGetChatMessagesVars._({required this.chatID, this.limit, this.offset})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        chatID, r'GGetChatMessagesVars', 'chatID');
  }

  @override
  GGetChatMessagesVars rebuild(
          void Function(GGetChatMessagesVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetChatMessagesVarsBuilder toBuilder() =>
      new GGetChatMessagesVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetChatMessagesVars &&
        chatID == other.chatID &&
        limit == other.limit &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, chatID.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, offset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetChatMessagesVars')
          ..add('chatID', chatID)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class GGetChatMessagesVarsBuilder
    implements Builder<GGetChatMessagesVars, GGetChatMessagesVarsBuilder> {
  _$GGetChatMessagesVars? _$v;

  _i1.GUUIDBuilder? _chatID;
  _i1.GUUIDBuilder get chatID => _$this._chatID ??= new _i1.GUUIDBuilder();
  set chatID(_i1.GUUIDBuilder? chatID) => _$this._chatID = chatID;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _offset;
  int? get offset => _$this._offset;
  set offset(int? offset) => _$this._offset = offset;

  GGetChatMessagesVarsBuilder();

  GGetChatMessagesVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _chatID = $v.chatID.toBuilder();
      _limit = $v.limit;
      _offset = $v.offset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetChatMessagesVars other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGetChatMessagesVars;
  }

  @override
  void update(void Function(GGetChatMessagesVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetChatMessagesVars build() => _build();

  _$GGetChatMessagesVars _build() {
    _$GGetChatMessagesVars _$result;
    try {
      _$result = _$v ??
          new _$GGetChatMessagesVars._(
              chatID: chatID.build(), limit: limit, offset: offset);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'chatID';
        chatID.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GGetChatMessagesVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
