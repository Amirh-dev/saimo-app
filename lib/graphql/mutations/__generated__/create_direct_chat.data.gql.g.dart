// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_chat.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateDirectChatData> _$gCreateDirectChatDataSerializer =
    new _$GCreateDirectChatDataSerializer();
Serializer<GCreateDirectChatData_createDirectChat>
    _$gCreateDirectChatDataCreateDirectChatSerializer =
    new _$GCreateDirectChatData_createDirectChatSerializer();

class _$GCreateDirectChatDataSerializer
    implements StructuredSerializer<GCreateDirectChatData> {
  @override
  final Iterable<Type> types = const [
    GCreateDirectChatData,
    _$GCreateDirectChatData
  ];
  @override
  final String wireName = 'GCreateDirectChatData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateDirectChatData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'createDirectChat',
      serializers.serialize(object.createDirectChat,
          specifiedType:
              const FullType(GCreateDirectChatData_createDirectChat)),
    ];

    return result;
  }

  @override
  GCreateDirectChatData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GCreateDirectChatDataBuilder();

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
        case 'createDirectChat':
          result.createDirectChat.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GCreateDirectChatData_createDirectChat))!
              as GCreateDirectChatData_createDirectChat);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateDirectChatData_createDirectChatSerializer
    implements StructuredSerializer<GCreateDirectChatData_createDirectChat> {
  @override
  final Iterable<Type> types = const [
    GCreateDirectChatData_createDirectChat,
    _$GCreateDirectChatData_createDirectChat
  ];
  @override
  final String wireName = 'GCreateDirectChatData_createDirectChat';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateDirectChatData_createDirectChat object,
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
  GCreateDirectChatData_createDirectChat deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GCreateDirectChatData_createDirectChatBuilder();

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

class _$GCreateDirectChatData extends GCreateDirectChatData {
  @override
  final String G__typename;
  @override
  final GCreateDirectChatData_createDirectChat createDirectChat;

  factory _$GCreateDirectChatData(
          [void Function(GCreateDirectChatDataBuilder)? updates]) =>
      (new GCreateDirectChatDataBuilder()..update(updates))._build();

  _$GCreateDirectChatData._(
      {required this.G__typename, required this.createDirectChat})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GCreateDirectChatData', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        createDirectChat, r'GCreateDirectChatData', 'createDirectChat');
  }

  @override
  GCreateDirectChatData rebuild(
          void Function(GCreateDirectChatDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateDirectChatDataBuilder toBuilder() =>
      new GCreateDirectChatDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateDirectChatData &&
        G__typename == other.G__typename &&
        createDirectChat == other.createDirectChat;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, createDirectChat.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateDirectChatData')
          ..add('G__typename', G__typename)
          ..add('createDirectChat', createDirectChat))
        .toString();
  }
}

class GCreateDirectChatDataBuilder
    implements Builder<GCreateDirectChatData, GCreateDirectChatDataBuilder> {
  _$GCreateDirectChatData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCreateDirectChatData_createDirectChatBuilder? _createDirectChat;
  GCreateDirectChatData_createDirectChatBuilder get createDirectChat =>
      _$this._createDirectChat ??=
          new GCreateDirectChatData_createDirectChatBuilder();
  set createDirectChat(
          GCreateDirectChatData_createDirectChatBuilder? createDirectChat) =>
      _$this._createDirectChat = createDirectChat;

  GCreateDirectChatDataBuilder() {
    GCreateDirectChatData._initializeBuilder(this);
  }

  GCreateDirectChatDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _createDirectChat = $v.createDirectChat.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateDirectChatData other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCreateDirectChatData;
  }

  @override
  void update(void Function(GCreateDirectChatDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateDirectChatData build() => _build();

  _$GCreateDirectChatData _build() {
    _$GCreateDirectChatData _$result;
    try {
      _$result = _$v ??
          new _$GCreateDirectChatData._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GCreateDirectChatData', 'G__typename'),
              createDirectChat: createDirectChat.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createDirectChat';
        createDirectChat.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GCreateDirectChatData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateDirectChatData_createDirectChat
    extends GCreateDirectChatData_createDirectChat {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GCreateDirectChatData_createDirectChat(
          [void Function(GCreateDirectChatData_createDirectChatBuilder)?
              updates]) =>
      (new GCreateDirectChatData_createDirectChatBuilder()..update(updates))
          ._build();

  _$GCreateDirectChatData_createDirectChat._(
      {required this.G__typename, required this.id})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GCreateDirectChatData_createDirectChat', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GCreateDirectChatData_createDirectChat', 'id');
  }

  @override
  GCreateDirectChatData_createDirectChat rebuild(
          void Function(GCreateDirectChatData_createDirectChatBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateDirectChatData_createDirectChatBuilder toBuilder() =>
      new GCreateDirectChatData_createDirectChatBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateDirectChatData_createDirectChat &&
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
            r'GCreateDirectChatData_createDirectChat')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GCreateDirectChatData_createDirectChatBuilder
    implements
        Builder<GCreateDirectChatData_createDirectChat,
            GCreateDirectChatData_createDirectChatBuilder> {
  _$GCreateDirectChatData_createDirectChat? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GCreateDirectChatData_createDirectChatBuilder() {
    GCreateDirectChatData_createDirectChat._initializeBuilder(this);
  }

  GCreateDirectChatData_createDirectChatBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateDirectChatData_createDirectChat other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GCreateDirectChatData_createDirectChat;
  }

  @override
  void update(
      void Function(GCreateDirectChatData_createDirectChatBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateDirectChatData_createDirectChat build() => _build();

  _$GCreateDirectChatData_createDirectChat _build() {
    final _$result = _$v ??
        new _$GCreateDirectChatData_createDirectChat._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GCreateDirectChatData_createDirectChat', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GCreateDirectChatData_createDirectChat', 'id'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
