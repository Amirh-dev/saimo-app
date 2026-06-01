// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRefreshTokenData> _$gRefreshTokenDataSerializer =
    new _$GRefreshTokenDataSerializer();
Serializer<GRefreshTokenData_refreshToken>
    _$gRefreshTokenDataRefreshTokenSerializer =
    new _$GRefreshTokenData_refreshTokenSerializer();
Serializer<GRefreshTokenData_refreshToken_user>
    _$gRefreshTokenDataRefreshTokenUserSerializer =
    new _$GRefreshTokenData_refreshToken_userSerializer();

class _$GRefreshTokenDataSerializer
    implements StructuredSerializer<GRefreshTokenData> {
  @override
  final Iterable<Type> types = const [GRefreshTokenData, _$GRefreshTokenData];
  @override
  final String wireName = 'GRefreshTokenData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GRefreshTokenData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'refreshToken',
      serializers.serialize(object.refreshToken,
          specifiedType: const FullType(GRefreshTokenData_refreshToken)),
    ];

    return result;
  }

  @override
  GRefreshTokenData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GRefreshTokenDataBuilder();

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
        case 'refreshToken':
          result.refreshToken.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GRefreshTokenData_refreshToken))!
              as GRefreshTokenData_refreshToken);
          break;
      }
    }

    return result.build();
  }
}

class _$GRefreshTokenData_refreshTokenSerializer
    implements StructuredSerializer<GRefreshTokenData_refreshToken> {
  @override
  final Iterable<Type> types = const [
    GRefreshTokenData_refreshToken,
    _$GRefreshTokenData_refreshToken
  ];
  @override
  final String wireName = 'GRefreshTokenData_refreshToken';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRefreshTokenData_refreshToken object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'accessToken',
      serializers.serialize(object.accessToken,
          specifiedType: const FullType(String)),
      'user',
      serializers.serialize(object.user,
          specifiedType: const FullType(GRefreshTokenData_refreshToken_user)),
    ];

    return result;
  }

  @override
  GRefreshTokenData_refreshToken deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GRefreshTokenData_refreshTokenBuilder();

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
        case 'user':
          result.user.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GRefreshTokenData_refreshToken_user))!
              as GRefreshTokenData_refreshToken_user);
          break;
      }
    }

    return result.build();
  }
}

class _$GRefreshTokenData_refreshToken_userSerializer
    implements StructuredSerializer<GRefreshTokenData_refreshToken_user> {
  @override
  final Iterable<Type> types = const [
    GRefreshTokenData_refreshToken_user,
    _$GRefreshTokenData_refreshToken_user
  ];
  @override
  final String wireName = 'GRefreshTokenData_refreshToken_user';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRefreshTokenData_refreshToken_user object,
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
  GRefreshTokenData_refreshToken_user deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GRefreshTokenData_refreshToken_userBuilder();

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

class _$GRefreshTokenData extends GRefreshTokenData {
  @override
  final String G__typename;
  @override
  final GRefreshTokenData_refreshToken refreshToken;

  factory _$GRefreshTokenData(
          [void Function(GRefreshTokenDataBuilder)? updates]) =>
      (new GRefreshTokenDataBuilder()..update(updates))._build();

  _$GRefreshTokenData._({required this.G__typename, required this.refreshToken})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GRefreshTokenData', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        refreshToken, r'GRefreshTokenData', 'refreshToken');
  }

  @override
  GRefreshTokenData rebuild(void Function(GRefreshTokenDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRefreshTokenDataBuilder toBuilder() =>
      new GRefreshTokenDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRefreshTokenData &&
        G__typename == other.G__typename &&
        refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRefreshTokenData')
          ..add('G__typename', G__typename)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class GRefreshTokenDataBuilder
    implements Builder<GRefreshTokenData, GRefreshTokenDataBuilder> {
  _$GRefreshTokenData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GRefreshTokenData_refreshTokenBuilder? _refreshToken;
  GRefreshTokenData_refreshTokenBuilder get refreshToken =>
      _$this._refreshToken ??= new GRefreshTokenData_refreshTokenBuilder();
  set refreshToken(GRefreshTokenData_refreshTokenBuilder? refreshToken) =>
      _$this._refreshToken = refreshToken;

  GRefreshTokenDataBuilder() {
    GRefreshTokenData._initializeBuilder(this);
  }

  GRefreshTokenDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _refreshToken = $v.refreshToken.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRefreshTokenData other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GRefreshTokenData;
  }

  @override
  void update(void Function(GRefreshTokenDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRefreshTokenData build() => _build();

  _$GRefreshTokenData _build() {
    _$GRefreshTokenData _$result;
    try {
      _$result = _$v ??
          new _$GRefreshTokenData._(
              G__typename: BuiltValueNullFieldError.checkNotNull(
                  G__typename, r'GRefreshTokenData', 'G__typename'),
              refreshToken: refreshToken.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'refreshToken';
        refreshToken.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GRefreshTokenData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GRefreshTokenData_refreshToken extends GRefreshTokenData_refreshToken {
  @override
  final String G__typename;
  @override
  final String accessToken;
  @override
  final GRefreshTokenData_refreshToken_user user;

  factory _$GRefreshTokenData_refreshToken(
          [void Function(GRefreshTokenData_refreshTokenBuilder)? updates]) =>
      (new GRefreshTokenData_refreshTokenBuilder()..update(updates))._build();

  _$GRefreshTokenData_refreshToken._(
      {required this.G__typename,
      required this.accessToken,
      required this.user})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GRefreshTokenData_refreshToken', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        accessToken, r'GRefreshTokenData_refreshToken', 'accessToken');
    BuiltValueNullFieldError.checkNotNull(
        user, r'GRefreshTokenData_refreshToken', 'user');
  }

  @override
  GRefreshTokenData_refreshToken rebuild(
          void Function(GRefreshTokenData_refreshTokenBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRefreshTokenData_refreshTokenBuilder toBuilder() =>
      new GRefreshTokenData_refreshTokenBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRefreshTokenData_refreshToken &&
        G__typename == other.G__typename &&
        accessToken == other.accessToken &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRefreshTokenData_refreshToken')
          ..add('G__typename', G__typename)
          ..add('accessToken', accessToken)
          ..add('user', user))
        .toString();
  }
}

class GRefreshTokenData_refreshTokenBuilder
    implements
        Builder<GRefreshTokenData_refreshToken,
            GRefreshTokenData_refreshTokenBuilder> {
  _$GRefreshTokenData_refreshToken? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  GRefreshTokenData_refreshToken_userBuilder? _user;
  GRefreshTokenData_refreshToken_userBuilder get user =>
      _$this._user ??= new GRefreshTokenData_refreshToken_userBuilder();
  set user(GRefreshTokenData_refreshToken_userBuilder? user) =>
      _$this._user = user;

  GRefreshTokenData_refreshTokenBuilder() {
    GRefreshTokenData_refreshToken._initializeBuilder(this);
  }

  GRefreshTokenData_refreshTokenBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _accessToken = $v.accessToken;
      _user = $v.user.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRefreshTokenData_refreshToken other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GRefreshTokenData_refreshToken;
  }

  @override
  void update(void Function(GRefreshTokenData_refreshTokenBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRefreshTokenData_refreshToken build() => _build();

  _$GRefreshTokenData_refreshToken _build() {
    _$GRefreshTokenData_refreshToken _$result;
    try {
      _$result = _$v ??
          new _$GRefreshTokenData_refreshToken._(
              G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                  r'GRefreshTokenData_refreshToken', 'G__typename'),
              accessToken: BuiltValueNullFieldError.checkNotNull(accessToken,
                  r'GRefreshTokenData_refreshToken', 'accessToken'),
              user: user.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        user.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GRefreshTokenData_refreshToken', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GRefreshTokenData_refreshToken_user
    extends GRefreshTokenData_refreshToken_user {
  @override
  final String G__typename;
  @override
  final String id;

  factory _$GRefreshTokenData_refreshToken_user(
          [void Function(GRefreshTokenData_refreshToken_userBuilder)?
              updates]) =>
      (new GRefreshTokenData_refreshToken_userBuilder()..update(updates))
          ._build();

  _$GRefreshTokenData_refreshToken_user._(
      {required this.G__typename, required this.id})
      : super._() {
    BuiltValueNullFieldError.checkNotNull(
        G__typename, r'GRefreshTokenData_refreshToken_user', 'G__typename');
    BuiltValueNullFieldError.checkNotNull(
        id, r'GRefreshTokenData_refreshToken_user', 'id');
  }

  @override
  GRefreshTokenData_refreshToken_user rebuild(
          void Function(GRefreshTokenData_refreshToken_userBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRefreshTokenData_refreshToken_userBuilder toBuilder() =>
      new GRefreshTokenData_refreshToken_userBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRefreshTokenData_refreshToken_user &&
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
    return (newBuiltValueToStringHelper(r'GRefreshTokenData_refreshToken_user')
          ..add('G__typename', G__typename)
          ..add('id', id))
        .toString();
  }
}

class GRefreshTokenData_refreshToken_userBuilder
    implements
        Builder<GRefreshTokenData_refreshToken_user,
            GRefreshTokenData_refreshToken_userBuilder> {
  _$GRefreshTokenData_refreshToken_user? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GRefreshTokenData_refreshToken_userBuilder() {
    GRefreshTokenData_refreshToken_user._initializeBuilder(this);
  }

  GRefreshTokenData_refreshToken_userBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRefreshTokenData_refreshToken_user other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GRefreshTokenData_refreshToken_user;
  }

  @override
  void update(
      void Function(GRefreshTokenData_refreshToken_userBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRefreshTokenData_refreshToken_user build() => _build();

  _$GRefreshTokenData_refreshToken_user _build() {
    final _$result = _$v ??
        new _$GRefreshTokenData_refreshToken_user._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GRefreshTokenData_refreshToken_user', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GRefreshTokenData_refreshToken_user', 'id'));
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
