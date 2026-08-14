// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_device_token.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterDeviceTokenData> _$gRegisterDeviceTokenDataSerializer =
    _$GRegisterDeviceTokenDataSerializer();

class _$GRegisterDeviceTokenDataSerializer
    implements StructuredSerializer<GRegisterDeviceTokenData> {
  @override
  final Iterable<Type> types = const [
    GRegisterDeviceTokenData,
    _$GRegisterDeviceTokenData
  ];
  @override
  final String wireName = 'GRegisterDeviceTokenData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GRegisterDeviceTokenData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'registerDeviceToken',
      serializers.serialize(object.registerDeviceToken,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GRegisterDeviceTokenData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterDeviceTokenDataBuilder();

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
        case 'registerDeviceToken':
          result.registerDeviceToken = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterDeviceTokenData extends GRegisterDeviceTokenData {
  @override
  final String G__typename;
  @override
  final bool registerDeviceToken;

  factory _$GRegisterDeviceTokenData(
          [void Function(GRegisterDeviceTokenDataBuilder)? updates]) =>
      (GRegisterDeviceTokenDataBuilder()..update(updates))._build();

  _$GRegisterDeviceTokenData._(
      {required this.G__typename, required this.registerDeviceToken})
      : super._();
  @override
  GRegisterDeviceTokenData rebuild(
          void Function(GRegisterDeviceTokenDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterDeviceTokenDataBuilder toBuilder() =>
      GRegisterDeviceTokenDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterDeviceTokenData &&
        G__typename == other.G__typename &&
        registerDeviceToken == other.registerDeviceToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, registerDeviceToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GRegisterDeviceTokenData')
          ..add('G__typename', G__typename)
          ..add('registerDeviceToken', registerDeviceToken))
        .toString();
  }
}

class GRegisterDeviceTokenDataBuilder
    implements
        Builder<GRegisterDeviceTokenData, GRegisterDeviceTokenDataBuilder> {
  _$GRegisterDeviceTokenData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _registerDeviceToken;
  bool? get registerDeviceToken => _$this._registerDeviceToken;
  set registerDeviceToken(bool? registerDeviceToken) =>
      _$this._registerDeviceToken = registerDeviceToken;

  GRegisterDeviceTokenDataBuilder() {
    GRegisterDeviceTokenData._initializeBuilder(this);
  }

  GRegisterDeviceTokenDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _registerDeviceToken = $v.registerDeviceToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterDeviceTokenData other) {
    _$v = other as _$GRegisterDeviceTokenData;
  }

  @override
  void update(void Function(GRegisterDeviceTokenDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterDeviceTokenData build() => _build();

  _$GRegisterDeviceTokenData _build() {
    final _$result = _$v ??
        _$GRegisterDeviceTokenData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GRegisterDeviceTokenData', 'G__typename'),
          registerDeviceToken: BuiltValueNullFieldError.checkNotNull(
              registerDeviceToken,
              r'GRegisterDeviceTokenData',
              'registerDeviceToken'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
