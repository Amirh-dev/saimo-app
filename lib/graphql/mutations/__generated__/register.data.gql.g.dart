// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterData> _$gRegisterDataSerializer =
    _$GRegisterDataSerializer();
Serializer<GRegisterData_register> _$gRegisterDataRegisterSerializer =
    _$GRegisterData_registerSerializer();
Serializer<GRegisterData_register_user> _$gRegisterDataRegisterUserSerializer =
    _$GRegisterData_register_userSerializer();

class _$GRegisterDataSerializer implements StructuredSerializer<GRegisterData> {
  @override
  final Iterable<Type> types = const [GRegisterData, _$GRegisterData];
  @override
  final String wireName = 'GRegisterData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GRegisterData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'register',
      serializers.serialize(object.register,
          specifiedType: const FullType(GRegisterData_register)),
    ];

    return result;
  }

  @override
  GRegisterData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterDataBuilder();

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
        case 'register':
          result.register.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GRegisterData_register))!
              as GRegisterData_register);
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterData_registerSerializer
    implements StructuredSerializer<GRegisterData_register> {
  @override
  final Iterable<Type> types = const [
    GRegisterData_register,
    _$GRegisterData_register
  ];
  @override
  final String wireName = 'GRegisterData_register';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterData_register object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'accessToken',
      serializers.serialize(object.accessToken,
          specifiedType: const FullType(String)),
      'refreshToken',
      serializers.serialize(object.refreshToken,
          specifiedType: const FullType(String)),
      'user',
      serializers.serialize(object.user,
          specifiedType: const FullType(GRegisterData_register_user)),
    ];

    return result;
  }

  @override
  GRegisterData_register deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterData_registerBuilder();

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
        case 'accessToken':
          result.accessToken = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'refreshToken':
          result.refreshToken = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'user':
          result.user.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GRegisterData_register_user))!
              as GRegisterData_register_user);
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterData_register_userSerializer
    implements StructuredSerializer<GRegisterData_register_user> {
  @override
  final Iterable<Type> types = const [
    GRegisterData_register_user,
    _$GRegisterData_register_user
  ];
  @override
  final String wireName = 'GRegisterData_register_user';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterData_register_user object,
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
  GRegisterData_register_user deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterData_register_userBuilder();

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

class _$GRegisterData extends GRegisterData {
  @override
  final String G__typename;
  @override
  final GRegisterData_register register;

  factory _$GRegisterData([void Function(GRegisterDataBuilder)? updates]) =>
      (GRegisterDataBuilder()..update(updates))._build();

  _$GRegisterData._({required this.G__typename, required this.register})
      : super._();
  @override
  GRegisterData rebuild(void Function(GRegisterDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterDataBuilder toBuilder() => GRegisterDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterData &&
        G__typename == other.G__typename &&
        register == other.register;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, register.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterData')
          ..add('G__typename', G__typename)
          ..add('register', register))
        .toString();
  }
}

class GRegisterDataBuilder
    implements Builder<GRegisterData, GRegisterDataBuilder> {
  _$GRegisterData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRegisterData_registerBuilder? _register;
  GRegisterData_registerBuilder get register =>
      _$this._register ??= GRegisterData_registerBuilder();
  set register(GRegisterData_registerBuilder? register) =>
      _$this._register = register;

  GRegisterDataBuilder() {
    GRegisterData._initializeBuilder(this);
  }

  GRegisterDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _register = $v.register.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterData other) {
    _$v = other as _$GRegisterData;
  }

  @override
  void update(void Function(GRegisterDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterData build() => _build();

  _$GRegisterData _build() {
    _$GRegisterData _$result;
    try {
      _$result = _$v ??
          _$GRegisterData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GRegisterData', 'G__typename'),
            register: register.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'register';
        register.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GRegisterData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GRegisterData_register extends GRegisterData_register {
  @override
  final String G__typename;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final GRegisterData_register_user user;

  factory _$GRegisterData_register(
          [void Function(GRegisterData_registerBuilder)? updates]) =>
      (GRegisterData_registerBuilder()..update(updates))._build();

  _$GRegisterData_register._(
      {required this.G__typename,
      required this.accessToken,
      required this.refreshToken,
      required this.user})
      : super._();
  @override
  GRegisterData_register rebuild(
          void Function(GRegisterData_registerBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterData_registerBuilder toBuilder() =>
      GRegisterData_registerBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterData_register &&
        G__typename == other.G__typename &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterData_register')
          ..add('G__typename', G__typename)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user))
        .toString();
  }
}

class GRegisterData_registerBuilder
    implements Builder<GRegisterData_register, GRegisterData_registerBuilder> {
  _$GRegisterData_register? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GRegisterData_register_userBuilder? _user;
  GRegisterData_register_userBuilder get user =>
      _$this._user ??= GRegisterData_register_userBuilder();
  set user(GRegisterData_register_userBuilder? user) => _$this._user = user;

  GRegisterData_registerBuilder() {
    GRegisterData_register._initializeBuilder(this);
  }

  GRegisterData_registerBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterData_register other) {
    _$v = other as _$GRegisterData_register;
  }

  @override
  void update(void Function(GRegisterData_registerBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterData_register build() => _build();

  _$GRegisterData_register _build() {
    _$GRegisterData_register _$result;
    try {
      _$result = _$v ??
          _$GRegisterData_register._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GRegisterData_register', 'G__typename'),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken, r'GRegisterData_register', 'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken, r'GRegisterData_register', 'refreshToken'),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GRegisterData_register', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GRegisterData_register_user extends GRegisterData_register_user {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GRegisterData_register_user(
          [void Function(GRegisterData_register_userBuilder)? updates]) =>
      (GRegisterData_register_userBuilder()..update(updates))._build();

  _$GRegisterData_register_user._({required this.G__typename, required this.id})
      : super._();
  @override
  GRegisterData_register_user rebuild(
          void Function(GRegisterData_register_userBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterData_register_userBuilder toBuilder() =>
      GRegisterData_register_userBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterData_register_user &&
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
    return (newBuiltValueToStringHelper(r'GRegisterData_register_user')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GRegisterData_register_userBuilder
    implements
        Builder<GRegisterData_register_user,
            GRegisterData_register_userBuilder> {
  _$GRegisterData_register_user? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GRegisterData_register_userBuilder() {
    GRegisterData_register_user._initializeBuilder(this);
  }

  GRegisterData_register_userBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterData_register_user other) {
    _$v = other as _$GRegisterData_register_user;
  }

  @override
  void update(void Function(GRegisterData_register_userBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterData_register_user build() => _build();

  _$GRegisterData_register_user _build() {
    final _$result = _$v ??
        _$GRegisterData_register_user._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GRegisterData_register_user', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GRegisterData_register_user', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
