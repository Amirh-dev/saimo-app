// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetMeData> _$gGetMeDataSerializer = new _$GGetMeDataSerializer();
Serializer<GGetMeData_getMe> _$gGetMeDataGetMeSerializer =
    new _$GGetMeData_getMeSerializer();

class _$GGetMeDataSerializer implements StructuredSerializer<GGetMeData> {
  @override
  final Iterable<Type> types = const [GGetMeData, _$GGetMeData];
  @override
  final String wireName = 'GGetMeData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetMeData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'getMe',
      serializers.serialize(object.getMe,
          specifiedType: const FullType(GGetMeData_getMe)),
    ];

    return result;
  }

  @override
  GGetMeData deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGetMeDataBuilder();

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
        case 'getMe':
          result.getMe.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GGetMeData_getMe))!
              as GGetMeData_getMe);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetMeData_getMeSerializer
    implements StructuredSerializer<GGetMeData_getMe> {
  @override
  final Iterable<Type> types = const [GGetMeData_getMe, _$GGetMeData_getMe];
  @override
  final String wireName = 'GGetMeData_getMe';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetMeData_getMe object,
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
  GGetMeData_getMe deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGetMeData_getMeBuilder();

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

class _$GGetMeData extends GGetMeData {
  @override
  final String G__typename;
  @override
  final GGetMeData_getMe getMe;

  factory _$GGetMeData([void Function(GGetMeDataBuilder)? updates]) =>
      (new GGetMeDataBuilder()..update(updates))._build();

  _$GGetMeData._({required this.G__typename, required this.getMe}) : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GGetMeData', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(getMe, r'GGetMeData', 'getMe');
  }

  @override
  GGetMeData rebuild(void Function(GGetMeDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetMeDataBuilder toBuilder() => new GGetMeDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetMeData &&
        G__typename == other.G__typename &&
        getMe == other.getMe;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, getMe.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetMeData')
          ..add('G__typename', G__typename)
          ..add('getMe', getMe))
        .toString();
  }
}

class GGetMeDataBuilder implements Builder<GGetMeData, GGetMeDataBuilder> {
  _$GGetMeData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GGetMeData_getMeBuilder? _getMe;
  GGetMeData_getMeBuilder get getMe =>
      _$this._getMe ??= new GGetMeData_getMeBuilder();
  set getMe(GGetMeData_getMeBuilder? getMe) => _$this._getMe = getMe;

  GGetMeDataBuilder() {
    GGetMeData._initializeBuilder(this);
  }

  GGetMeDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _getMe = $v.getMe.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetMeData other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGetMeData;
  }

  @override
  void update(void Function(GGetMeDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetMeData build() => _build();

  _$GGetMeData _build() {
    _$GGetMeData _$result;
    try {
      _$result = _$v ??
          new _$GGetMeData._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GGetMeData', 'G__typename'),
              getMe: getMe.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'getMe';
        getMe.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GGetMeData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetMeData_getMe extends GGetMeData_getMe {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GGetMeData_getMe(
          [void Function(GGetMeData_getMeBuilder)? updates]) =>
      (new GGetMeData_getMeBuilder()..update(updates))._build();

  _$GGetMeData_getMe._({required this.G__typename, required this.id})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GGetMeData_getMe', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(id, r'GGetMeData_getMe', 'id');
  }

  @override
  GGetMeData_getMe rebuild(void Function(GGetMeData_getMeBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetMeData_getMeBuilder toBuilder() =>
      new GGetMeData_getMeBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetMeData_getMe &&
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
    return (newBuiltValueToStringHelper(r'GGetMeData_getMe')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GGetMeData_getMeBuilder
    implements Builder<GGetMeData_getMe, GGetMeData_getMeBuilder> {
  _$GGetMeData_getMe? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GGetMeData_getMeBuilder() {
    GGetMeData_getMe._initializeBuilder(this);
  }

  GGetMeData_getMeBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetMeData_getMe other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGetMeData_getMe;
  }

  @override
  void update(void Function(GGetMeData_getMeBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetMeData_getMe build() => _build();

  _$GGetMeData_getMe _build() {
    final _$result = _$v ??
        new _$GGetMeData_getMe._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetMeData_getMe', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetMeData_getMe', 'id'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
