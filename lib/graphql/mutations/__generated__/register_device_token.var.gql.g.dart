// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterDeviceTokenVars> _$gRegisterDeviceTokenVarsSerializer =
    _$GRegisterDeviceTokenVarsSerializer();

class _$GRegisterDeviceTokenVarsSerializer
    implements StructuredSerializer<GRegisterDeviceTokenVars> {
  @override
  final Iterable<Type> types = const [
    GRegisterDeviceTokenVars,
    _$GRegisterDeviceTokenVars
  ];
  @override
  final String wireName = 'GRegisterDeviceTokenVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterDeviceTokenVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'token',
      serializers.serialize(object.token,
          specifiedType: const FullType(String)),
      'platform',
      serializers.serialize(object.platform,
          specifiedType: const FullType(_i1.GDeviceTokenPlatform)),
    ];

    return result;
  }

  @override
  GRegisterDeviceTokenVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterDeviceTokenVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'token':
          result.token = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'platform':
          result.platform = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GDeviceTokenPlatform))!
              as _i1.GDeviceTokenPlatform;
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterDeviceTokenVars extends GRegisterDeviceTokenVars {
  @override
  final String token;
  @override
  final _i1.GDeviceTokenPlatform platform;

  factory _$GRegisterDeviceTokenVars(
          [void Function(GRegisterDeviceTokenVarsBuilder)? updates]) =>
      (GRegisterDeviceTokenVarsBuilder()..update(updates))._build();

  _$GRegisterDeviceTokenVars._({required this.token, required this.platform})
      : super._();
  @override
  GRegisterDeviceTokenVars rebuild(
          void Function(GRegisterDeviceTokenVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterDeviceTokenVarsBuilder toBuilder() =>
      GRegisterDeviceTokenVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterDeviceTokenVars &&
        token == other.token &&
        platform == other.platform;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterDeviceTokenVars')
          ..add('token', token)
          ..add('platform', platform))
        .toString();
  }
}

class GRegisterDeviceTokenVarsBuilder
    implements
        Builder<GRegisterDeviceTokenVars, GRegisterDeviceTokenVarsBuilder> {
  _$GRegisterDeviceTokenVars? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  _i1.GDeviceTokenPlatform? _platform;
  _i1.GDeviceTokenPlatform? get platform => _$this._platform;
  set platform(_i1.GDeviceTokenPlatform? platform) =>
      _$this._platform = platform;

  GRegisterDeviceTokenVarsBuilder();

  GRegisterDeviceTokenVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _platform = $v.platform;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterDeviceTokenVars other) {
    _$v = other as _$GRegisterDeviceTokenVars;
  }

  @override
  void update(void Function(GRegisterDeviceTokenVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterDeviceTokenVars build() => _build();

  _$GRegisterDeviceTokenVars _build() {
    final _$result = _$v ??
        _$GRegisterDeviceTokenVars._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'GRegisterDeviceTokenVars', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'GRegisterDeviceTokenVars', 'platform'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
