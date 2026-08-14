// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_register.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPAndRegisterData> _$gVerifyOTPAndRegisterDataSerializer =
    _$GVerifyOTPAndRegisterDataSerializer();
Serializer<GVerifyOTPAndRegisterData_verifyOTPAndRegister>
    _$gVerifyOTPAndRegisterDataVerifyOTPAndRegisterSerializer =
    _$GVerifyOTPAndRegisterData_verifyOTPAndRegisterSerializer();
Serializer<GVerifyOTPAndRegisterData_verifyOTPAndRegister_user>
    _$gVerifyOTPAndRegisterDataVerifyOTPAndRegisterUserSerializer =
    _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_userSerializer();

class _$GVerifyOTPAndRegisterDataSerializer
    implements StructuredSerializer<GVerifyOTPAndRegisterData> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndRegisterData,
    _$GVerifyOTPAndRegisterData
  ];
  @override
  final String wireName = 'GVerifyOTPAndRegisterData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndRegisterData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'verifyOTPAndRegister',
      serializers.serialize(object.verifyOTPAndRegister,
          specifiedType:
              const FullType(GVerifyOTPAndRegisterData_verifyOTPAndRegister)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndRegisterData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPAndRegisterDataBuilder();

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
        case 'verifyOTPAndRegister':
          result.verifyOTPAndRegister.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GVerifyOTPAndRegisterData_verifyOTPAndRegister))!
              as GVerifyOTPAndRegisterData_verifyOTPAndRegister);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndRegisterData_verifyOTPAndRegisterSerializer
    implements
        StructuredSerializer<GVerifyOTPAndRegisterData_verifyOTPAndRegister> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndRegisterData_verifyOTPAndRegister,
    _$GVerifyOTPAndRegisterData_verifyOTPAndRegister
  ];
  @override
  final String wireName = 'GVerifyOTPAndRegisterData_verifyOTPAndRegister';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GVerifyOTPAndRegisterData_verifyOTPAndRegister object,
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
          specifiedType: const FullType(
              GVerifyOTPAndRegisterData_verifyOTPAndRegister_user)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder();

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
                  specifiedType: const FullType(
                      GVerifyOTPAndRegisterData_verifyOTPAndRegister_user))!
              as GVerifyOTPAndRegisterData_verifyOTPAndRegister_user);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_userSerializer
    implements
        StructuredSerializer<
            GVerifyOTPAndRegisterData_verifyOTPAndRegister_user> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndRegisterData_verifyOTPAndRegister_user,
    _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user
  ];
  @override
  final String wireName = 'GVerifyOTPAndRegisterData_verifyOTPAndRegister_user';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GVerifyOTPAndRegisterData_verifyOTPAndRegister_user object,
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
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder();

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

class _$GVerifyOTPAndRegisterData extends GVerifyOTPAndRegisterData {
  @override
  final String G__typename;
  @override
  final GVerifyOTPAndRegisterData_verifyOTPAndRegister verifyOTPAndRegister;

  factory _$GVerifyOTPAndRegisterData(
          [void Function(GVerifyOTPAndRegisterDataBuilder)? updates]) =>
      (GVerifyOTPAndRegisterDataBuilder()..update(updates))._build();

  _$GVerifyOTPAndRegisterData._(
      {required this.G__typename, required this.verifyOTPAndRegister})
      : super._();
  @override
  GVerifyOTPAndRegisterData rebuild(
          void Function(GVerifyOTPAndRegisterDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndRegisterDataBuilder toBuilder() =>
      GVerifyOTPAndRegisterDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndRegisterData &&
        G__typename == other.G__typename &&
        verifyOTPAndRegister == other.verifyOTPAndRegister;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, verifyOTPAndRegister.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndRegisterData')
          ..add('G__typename', G__typename)
          ..add('verifyOTPAndRegister', verifyOTPAndRegister))
        .toString();
  }
}

class GVerifyOTPAndRegisterDataBuilder
    implements
        Builder<GVerifyOTPAndRegisterData, GVerifyOTPAndRegisterDataBuilder> {
  _$GVerifyOTPAndRegisterData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder? _verifyOTPAndRegister;
  GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder
      get verifyOTPAndRegister => _$this._verifyOTPAndRegister ??=
          GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder();
  set verifyOTPAndRegister(
          GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder?
              verifyOTPAndRegister) =>
      _$this._verifyOTPAndRegister = verifyOTPAndRegister;

  GVerifyOTPAndRegisterDataBuilder() {
    GVerifyOTPAndRegisterData._initializeBuilder(this);
  }

  GVerifyOTPAndRegisterDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _verifyOTPAndRegister = $v.verifyOTPAndRegister.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndRegisterData other) {
    _$v = other as _$GVerifyOTPAndRegisterData;
  }

  @override
  void update(void Function(GVerifyOTPAndRegisterDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndRegisterData build() => _build();

  _$GVerifyOTPAndRegisterData _build() {
    _$GVerifyOTPAndRegisterData _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPAndRegisterData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GVerifyOTPAndRegisterData', 'G__typename'),
            verifyOTPAndRegister: verifyOTPAndRegister.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'verifyOTPAndRegister';
        verifyOTPAndRegister.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPAndRegisterData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndRegisterData_verifyOTPAndRegister
    extends GVerifyOTPAndRegisterData_verifyOTPAndRegister {
  @override
  final String G__typename;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final GVerifyOTPAndRegisterData_verifyOTPAndRegister_user user;

  factory _$GVerifyOTPAndRegisterData_verifyOTPAndRegister(
          [void Function(GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder)?
              updates]) =>
      (GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder()..update(updates))
          ._build();

  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister._(
      {required this.G__typename,
      required this.accessToken,
      required this.refreshToken,
      required this.user})
      : super._();
  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister rebuild(
          void Function(GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder toBuilder() =>
      GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndRegisterData_verifyOTPAndRegister &&
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
    return (newBuiltValueToStringHelper(
            r'GVerifyOTPAndRegisterData_verifyOTPAndRegister')
          ..add('G__typename', G__typename)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user))
        .toString();
  }
}

class GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder
    implements
        Builder<GVerifyOTPAndRegisterData_verifyOTPAndRegister,
            GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder> {
  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder? _user;
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder get user =>
      _$this._user ??=
          GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder();
  set user(GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder? user) =>
      _$this._user = user;

  GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder() {
    GVerifyOTPAndRegisterData_verifyOTPAndRegister._initializeBuilder(this);
  }

  GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder get _$this {
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
  void replace(GVerifyOTPAndRegisterData_verifyOTPAndRegister other) {
    _$v = other as _$GVerifyOTPAndRegisterData_verifyOTPAndRegister;
  }

  @override
  void update(
      void Function(GVerifyOTPAndRegisterData_verifyOTPAndRegisterBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister build() => _build();

  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister _build() {
    _$GVerifyOTPAndRegisterData_verifyOTPAndRegister _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPAndRegisterData_verifyOTPAndRegister._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GVerifyOTPAndRegisterData_verifyOTPAndRegister',
                'G__typename'),
            accessToken: BuiltValueNullFieldError.checkNotNull(
                accessToken,
                r'GVerifyOTPAndRegisterData_verifyOTPAndRegister',
                'accessToken'),
            refreshToken: BuiltValueNullFieldError.checkNotNull(
                refreshToken,
                r'GVerifyOTPAndRegisterData_verifyOTPAndRegister',
                'refreshToken'),
            user: user.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPAndRegisterData_verifyOTPAndRegister',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user
    extends GVerifyOTPAndRegisterData_verifyOTPAndRegister_user {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user(
          [void Function(
                  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder)?
              updates]) =>
      (GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder()
            ..update(updates))
          ._build();

  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user._(
      {required this.G__typename, required this.id})
      : super._();
  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user rebuild(
          void Function(
                  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder toBuilder() =>
      GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndRegisterData_verifyOTPAndRegister_user &&
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
            r'GVerifyOTPAndRegisterData_verifyOTPAndRegister_user')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder
    implements
        Builder<GVerifyOTPAndRegisterData_verifyOTPAndRegister_user,
            GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder> {
  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder() {
    GVerifyOTPAndRegisterData_verifyOTPAndRegister_user._initializeBuilder(
        this);
  }

  GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndRegisterData_verifyOTPAndRegister_user other) {
    _$v = other as _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user;
  }

  @override
  void update(
      void Function(GVerifyOTPAndRegisterData_verifyOTPAndRegister_userBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndRegisterData_verifyOTPAndRegister_user build() => _build();

  _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user _build() {
    final _$result = _$v ??
        _$GVerifyOTPAndRegisterData_verifyOTPAndRegister_user._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVerifyOTPAndRegisterData_verifyOTPAndRegister_user',
              'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GVerifyOTPAndRegisterData_verifyOTPAndRegister_user', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
