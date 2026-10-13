// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_for_registration.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPForRegistrationData>
    _$gVerifyOTPForRegistrationDataSerializer =
    _$GVerifyOTPForRegistrationDataSerializer();
Serializer<GVerifyOTPForRegistrationData_verifyOTPForRegistration>
    _$gVerifyOTPForRegistrationDataVerifyOTPForRegistrationSerializer =
    _$GVerifyOTPForRegistrationData_verifyOTPForRegistrationSerializer();

class _$GVerifyOTPForRegistrationDataSerializer
    implements StructuredSerializer<GVerifyOTPForRegistrationData> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPForRegistrationData,
    _$GVerifyOTPForRegistrationData
  ];
  @override
  final String wireName = 'GVerifyOTPForRegistrationData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPForRegistrationData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'verifyOTPForRegistration',
      serializers.serialize(object.verifyOTPForRegistration,
          specifiedType: const FullType(
              GVerifyOTPForRegistrationData_verifyOTPForRegistration)),
    ];

    return result;
  }

  @override
  GVerifyOTPForRegistrationData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPForRegistrationDataBuilder();

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
        case 'verifyOTPForRegistration':
          result.verifyOTPForRegistration.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      GVerifyOTPForRegistrationData_verifyOTPForRegistration))!
              as GVerifyOTPForRegistrationData_verifyOTPForRegistration);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPForRegistrationData_verifyOTPForRegistrationSerializer
    implements
        StructuredSerializer<
            GVerifyOTPForRegistrationData_verifyOTPForRegistration> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPForRegistrationData_verifyOTPForRegistration,
    _$GVerifyOTPForRegistrationData_verifyOTPForRegistration
  ];
  @override
  final String wireName =
      'GVerifyOTPForRegistrationData_verifyOTPForRegistration';

  @override
  Iterable<Object?> serialize(Serializers serializers,
      GVerifyOTPForRegistrationData_verifyOTPForRegistration object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'registrationToken',
      serializers.serialize(object.registrationToken,
          specifiedType: const FullType(String)),
      'expiresInSeconds',
      serializers.serialize(object.expiresInSeconds,
          specifiedType: const FullType(int)),
    ];

    return result;
  }

  @override
  GVerifyOTPForRegistrationData_verifyOTPForRegistration deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result =
        GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder();

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
        case 'registrationToken':
          result.registrationToken = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'expiresInSeconds':
          result.expiresInSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPForRegistrationData extends GVerifyOTPForRegistrationData {
  @override
  final String G__typename;
  @override
  final GVerifyOTPForRegistrationData_verifyOTPForRegistration
      verifyOTPForRegistration;

  factory _$GVerifyOTPForRegistrationData(
          [void Function(GVerifyOTPForRegistrationDataBuilder)? updates]) =>
      (GVerifyOTPForRegistrationDataBuilder()..update(updates))._build();

  _$GVerifyOTPForRegistrationData._(
      {required this.G__typename, required this.verifyOTPForRegistration})
      : super._();
  @override
  GVerifyOTPForRegistrationData rebuild(
          void Function(GVerifyOTPForRegistrationDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPForRegistrationDataBuilder toBuilder() =>
      GVerifyOTPForRegistrationDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPForRegistrationData &&
        G__typename == other.G__typename &&
        verifyOTPForRegistration == other.verifyOTPForRegistration;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, verifyOTPForRegistration.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPForRegistrationData')
          ..add('G__typename', G__typename)
          ..add('verifyOTPForRegistration', verifyOTPForRegistration))
        .toString();
  }
}

class GVerifyOTPForRegistrationDataBuilder
    implements
        Builder<GVerifyOTPForRegistrationData,
            GVerifyOTPForRegistrationDataBuilder> {
  _$GVerifyOTPForRegistrationData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder?
      _verifyOTPForRegistration;
  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder
      get verifyOTPForRegistration => _$this._verifyOTPForRegistration ??=
          GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder();
  set verifyOTPForRegistration(
          GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder?
              verifyOTPForRegistration) =>
      _$this._verifyOTPForRegistration = verifyOTPForRegistration;

  GVerifyOTPForRegistrationDataBuilder() {
    GVerifyOTPForRegistrationData._initializeBuilder(this);
  }

  GVerifyOTPForRegistrationDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _verifyOTPForRegistration = $v.verifyOTPForRegistration.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPForRegistrationData other) {
    _$v = other as _$GVerifyOTPForRegistrationData;
  }

  @override
  void update(void Function(GVerifyOTPForRegistrationDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPForRegistrationData build() => _build();

  _$GVerifyOTPForRegistrationData _build() {
    _$GVerifyOTPForRegistrationData _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPForRegistrationData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GVerifyOTPForRegistrationData', 'G__typename'),
            verifyOTPForRegistration: verifyOTPForRegistration.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'verifyOTPForRegistration';
        verifyOTPForRegistration.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPForRegistrationData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GVerifyOTPForRegistrationData_verifyOTPForRegistration
    extends GVerifyOTPForRegistrationData_verifyOTPForRegistration {
  @override
  final String G__typename;
  @override
  final String registrationToken;
  @override
  final int expiresInSeconds;

  factory _$GVerifyOTPForRegistrationData_verifyOTPForRegistration(
          [void Function(
                  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder)?
              updates]) =>
      (GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder()
            ..update(updates))
          ._build();

  _$GVerifyOTPForRegistrationData_verifyOTPForRegistration._(
      {required this.G__typename,
      required this.registrationToken,
      required this.expiresInSeconds})
      : super._();
  @override
  GVerifyOTPForRegistrationData_verifyOTPForRegistration rebuild(
          void Function(
                  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder toBuilder() =>
      GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder()
        ..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPForRegistrationData_verifyOTPForRegistration &&
        G__typename == other.G__typename &&
        registrationToken == other.registrationToken &&
        expiresInSeconds == other.expiresInSeconds;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, registrationToken.hashCode);
    _$hash = $jc(_$hash, expiresInSeconds.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GVerifyOTPForRegistrationData_verifyOTPForRegistration')
          ..add('G__typename', G__typename)
          ..add('registrationToken', registrationToken)
          ..add('expiresInSeconds', expiresInSeconds))
        .toString();
  }
}

class GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder
    implements
        Builder<GVerifyOTPForRegistrationData_verifyOTPForRegistration,
            GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder> {
  _$GVerifyOTPForRegistrationData_verifyOTPForRegistration? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _registrationToken;
  String? get registrationToken => _$this._registrationToken;
  set registrationToken(String? registrationToken) =>
      _$this._registrationToken = registrationToken;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder() {
    GVerifyOTPForRegistrationData_verifyOTPForRegistration._initializeBuilder(
        this);
  }

  GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _registrationToken = $v.registrationToken;
      _expiresInSeconds = $v.expiresInSeconds;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPForRegistrationData_verifyOTPForRegistration other) {
    _$v = other as _$GVerifyOTPForRegistrationData_verifyOTPForRegistration;
  }

  @override
  void update(
      void Function(
              GVerifyOTPForRegistrationData_verifyOTPForRegistrationBuilder)?
          updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPForRegistrationData_verifyOTPForRegistration build() => _build();

  _$GVerifyOTPForRegistrationData_verifyOTPForRegistration _build() {
    final _$result = _$v ??
        _$GVerifyOTPForRegistrationData_verifyOTPForRegistration._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename,
              r'GVerifyOTPForRegistrationData_verifyOTPForRegistration',
              'G__typename'),
          registrationToken: BuiltValueNullFieldError.checkNotNull(
              registrationToken,
              r'GVerifyOTPForRegistrationData_verifyOTPForRegistration',
              'registrationToken'),
          expiresInSeconds: BuiltValueNullFieldError.checkNotNull(
              expiresInSeconds,
              r'GVerifyOTPForRegistrationData_verifyOTPForRegistration',
              'expiresInSeconds'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
