// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_login.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPAndLoginData> _$gVerifyOTPAndLoginDataSerializer =
    new _$GVerifyOTPAndLoginDataSerializer();
Serializer<GVerifyOTPAndLoginData_verifyOTPAndLogin>
    _$gVerifyOTPAndLoginDataVerifyOTPAndLoginSerializer =
    new _$GVerifyOTPAndLoginData_verifyOTPAndLoginSerializer();
Serializer<GVerifyOTPAndLoginData_verifyOTPAndLogin_user>
    _$gVerifyOTPAndLoginDataVerifyOTPAndLoginUserSerializer =
    new _$GVerifyOTPAndLoginData_verifyOTPAndLogin_userSerializer();

class _$GVerifyOTPAndLoginDataSerializer
    implements StructuredSerializer<GVerifyOTPAndLoginData> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndLoginData,
    _$GVerifyOTPAndLoginData
  ];
  @override
  final String wireName = 'GVerifyOTPAndLoginData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndLoginData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'verifyOTPAndLogin',
      serializers.serialize(object.verifyOTPAndLogin,
          specifiedType:
              const FullType(GVerifyOTPAndLoginData_verifyOTPAndLogin)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndLoginData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GVerifyOTPAndLoginDataBuilder();

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
        case 'verifyOTPAndLogin':
          result.verifyOTPAndLogin.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GVerifyOTPAndLoginData_verifyOTPAndLogin))!
              as GVerifyOTPAndLoginData_verifyOTPAndLogin);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndLoginData_verifyOTPAndLoginSerializer
    implements StructuredSerializer<GVerifyOTPAndLoginData_verifyOTPAndLogin> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndLoginData_verifyOTPAndLogin,
    _$GVerifyOTPAndLoginData_verifyOTPAndLogin
  ];
  @override
  final String wireName = 'GVerifyOTPAndLoginData_verifyOTPAndLogin';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndLoginData_verifyOTPAndLogin object,
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
          specifiedType:
              const FullType(GVerifyOTPAndLoginData_verifyOTPAndLogin_user)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder();

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
                      GVerifyOTPAndLoginData_verifyOTPAndLogin_user))!
              as GVerifyOTPAndLoginData_verifyOTPAndLogin_user);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndLoginData_verifyOTPAndLogin_userSerializer
    implements
        StructuredSerializer<GVerifyOTPAndLoginData_verifyOTPAndLogin_user> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndLoginData_verifyOTPAndLogin_user,
    _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user
  ];
  @override
  final String wireName = 'GVerifyOTPAndLoginData_verifyOTPAndLogin_user';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GVerifyOTPAndLoginData_verifyOTPAndLogin_user object,
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
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder();

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

class _$GVerifyOTPAndLoginData extends GVerifyOTPAndLoginData {
  @override
  final String G__typename;
  @override
  final GVerifyOTPAndLoginData_verifyOTPAndLogin verifyOTPAndLogin;

  factory _$GVerifyOTPAndLoginData(
          [void Function(GVerifyOTPAndLoginDataBuilder)? updates]) =>
      (new GVerifyOTPAndLoginDataBuilder()..update(updates))._build();

  _$GVerifyOTPAndLoginData._(
      {required this.G__typename, required this.verifyOTPAndLogin})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GVerifyOTPAndLoginData', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        verifyOTPAndLogin, r'GVerifyOTPAndLoginData', 'verifyOTPAndLogin');
  }

  @override
  GVerifyOTPAndLoginData rebuild(
          void Function(GVerifyOTPAndLoginDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndLoginDataBuilder toBuilder() =>
      new GVerifyOTPAndLoginDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndLoginData &&
        G__typename == other.G__typename &&
        verifyOTPAndLogin == other.verifyOTPAndLogin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, verifyOTPAndLogin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndLoginData')
          ..add('G__typename', G__typename)
          ..add('verifyOTPAndLogin', verifyOTPAndLogin))
        .toString();
  }
}

class GVerifyOTPAndLoginDataBuilder
    implements Builder<GVerifyOTPAndLoginData, GVerifyOTPAndLoginDataBuilder> {
  _$GVerifyOTPAndLoginData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder? _verifyOTPAndLogin;
  GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder get verifyOTPAndLogin =>
      _$this._verifyOTPAndLogin ??=
          new GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder();
  set verifyOTPAndLogin(
          GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder? verifyOTPAndLogin) =>
      _$this._verifyOTPAndLogin = verifyOTPAndLogin;

  GVerifyOTPAndLoginDataBuilder() {
    GVerifyOTPAndLoginData._initializeBuilder(this);
  }

  GVerifyOTPAndLoginDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _verifyOTPAndLogin = $v.verifyOTPAndLogin.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndLoginData other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GVerifyOTPAndLoginData;
  }

  @override
  void update(void Function(GVerifyOTPAndLoginDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndLoginData build() => _build();

  _$GVerifyOTPAndLoginData _build() {
    _$GVerifyOTPAndLoginData _$result;
    try {
      _$result = _$v ??
          new _$GVerifyOTPAndLoginData._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GVerifyOTPAndLoginData', 'G__typename'),
              verifyOTPAndLogin: verifyOTPAndLogin.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'verifyOTPAndLogin';
        verifyOTPAndLogin.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GVerifyOTPAndLoginData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndLoginData_verifyOTPAndLogin
    extends GVerifyOTPAndLoginData_verifyOTPAndLogin {
  @override
  final String G__typename;
  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final GVerifyOTPAndLoginData_verifyOTPAndLogin_user user;

  factory _$GVerifyOTPAndLoginData_verifyOTPAndLogin(
          [void Function(GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder)?
              updates]) =>
      (new GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder()..update(updates))
          ._build();

  _$GVerifyOTPAndLoginData_verifyOTPAndLogin._(
      {required this.G__typename,
      required this.accessToken,
      required this.refreshToken,
      required this.user})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(G__typename,
        r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(accessToken,
        r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'accessToken');
    BuiltValueNullFieldError.checkNotNull(refreshToken,
        r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'refreshToken');
    BuiltValueNullFieldError.checkNotNull(
        user, r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'user');
  }

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin rebuild(
          void Function(GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder toBuilder() =>
      new GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndLoginData_verifyOTPAndLogin &&
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
            r'GVerifyOTPAndLoginData_verifyOTPAndLogin')
          ..add('G__typename', G__typename)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken)
          ..add('user', user))
        .toString();
  }
}

class GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder
    implements
        Builder<GVerifyOTPAndLoginData_verifyOTPAndLogin,
            GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder> {
  _$GVerifyOTPAndLoginData_verifyOTPAndLogin? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder? _user;
  GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder get user =>
      _$this._user ??=
          new GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder();
  set user(GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder? user) =>
      _$this._user = user;

  GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder() {
    GVerifyOTPAndLoginData_verifyOTPAndLogin._initializeBuilder(this);
  }

  GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder get _$this {
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
  void replace(GVerifyOTPAndLoginData_verifyOTPAndLogin other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GVerifyOTPAndLoginData_verifyOTPAndLogin;
  }

  @override
  void update(
      void Function(GVerifyOTPAndLoginData_verifyOTPAndLoginBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin build() => _build();

  _$GVerifyOTPAndLoginData_verifyOTPAndLogin _build() {
    _$GVerifyOTPAndLoginData_verifyOTPAndLogin _$result;
    try {
      _$result = _$v ??
          new _$GVerifyOTPAndLoginData_verifyOTPAndLogin._(
              G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                  r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'G__typename'),
              accessToken: BuiltValueNullFieldError.checkNotNull(accessToken,
                  r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'accessToken'),
              refreshToken: BuiltValueNullFieldError.checkNotNull(refreshToken,
                  r'GVerifyOTPAndLoginData_verifyOTPAndLogin', 'refreshToken'),
              user: user.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GVerifyOTPAndLoginData_verifyOTPAndLogin',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user
    extends GVerifyOTPAndLoginData_verifyOTPAndLogin_user {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user(
          [void Function(GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder)?
              updates]) =>
      (new GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder()
            ..update(updates))
          ._build();

  _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user._(
      {required this.G__typename, required this.id})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(G__typename,
        r'GVerifyOTPAndLoginData_verifyOTPAndLogin_user', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GVerifyOTPAndLoginData_verifyOTPAndLogin_user', 'id');
  }

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user rebuild(
          void Function(GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder toBuilder() =>
      new GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndLoginData_verifyOTPAndLogin_user &&
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
            r'GVerifyOTPAndLoginData_verifyOTPAndLogin_user')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder
    implements
        Builder<GVerifyOTPAndLoginData_verifyOTPAndLogin_user,
            GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder> {
  _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder() {
    GVerifyOTPAndLoginData_verifyOTPAndLogin_user._initializeBuilder(this);
  }

  GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndLoginData_verifyOTPAndLogin_user other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user;
  }

  @override
  void update(
      void Function(GVerifyOTPAndLoginData_verifyOTPAndLogin_userBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndLoginData_verifyOTPAndLogin_user build() => _build();

  _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user _build() {
    final _$result = _$v ??
        new _$GVerifyOTPAndLoginData_verifyOTPAndLogin_user._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename,
                r'GVerifyOTPAndLoginData_verifyOTPAndLogin_user',
                'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GVerifyOTPAndLoginData_verifyOTPAndLogin_user', 'id'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
