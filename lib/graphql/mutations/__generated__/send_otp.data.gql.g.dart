// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_otp.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSendOTPData> _$gSendOTPDataSerializer = _$GSendOTPDataSerializer();
Serializer<GSendOTPData_sendOTP> _$gSendOTPDataSendOTPSerializer =
    _$GSendOTPData_sendOTPSerializer();

class _$GSendOTPDataSerializer implements StructuredSerializer<GSendOTPData> {
  @override
  final Iterable<Type> types = const [GSendOTPData, _$GSendOTPData];
  @override
  final String wireName = 'GSendOTPData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendOTPData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'sendOTP',
      serializers.serialize(object.sendOTP,
          specifiedType: const FullType(GSendOTPData_sendOTP)),
    ];

    return result;
  }

  @override
  GSendOTPData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendOTPDataBuilder();

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
        case 'sendOTP':
          result.sendOTP.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GSendOTPData_sendOTP))!
              as GSendOTPData_sendOTP);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendOTPData_sendOTPSerializer
    implements StructuredSerializer<GSendOTPData_sendOTP> {
  @override
  final Iterable<Type> types = const [
    GSendOTPData_sendOTP,
    _$GSendOTPData_sendOTP
  ];
  @override
  final String wireName = 'GSendOTPData_sendOTP';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GSendOTPData_sendOTP object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'success',
      serializers.serialize(object.success,
          specifiedType: const FullType(bool)),
      'message',
      serializers.serialize(object.message,
          specifiedType: const FullType(String)),
      'expiresInSeconds',
      serializers.serialize(object.expiresInSeconds,
          specifiedType: const FullType(int)),
      'isRegistered',
      serializers.serialize(object.isRegistered,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GSendOTPData_sendOTP deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendOTPData_sendOTPBuilder();

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
        case 'success':
          result.success = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'message':
          result.message = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'expiresInSeconds':
          result.expiresInSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'isRegistered':
          result.isRegistered = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GSendOTPData extends GSendOTPData {
  @override
  final String G__typename;
  @override
  final GSendOTPData_sendOTP sendOTP;

  factory _$GSendOTPData([void Function(GSendOTPDataBuilder)? updates]) =>
      (GSendOTPDataBuilder()..update(updates))._build();

  _$GSendOTPData._({required this.G__typename, required this.sendOTP})
      : super._();
  @override
  GSendOTPData rebuild(void Function(GSendOTPDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendOTPDataBuilder toBuilder() => GSendOTPDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendOTPData &&
        G__typename == other.G__typename &&
        sendOTP == other.sendOTP;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, sendOTP.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendOTPData')
          ..add('G__typename', G__typename)
          ..add('sendOTP', sendOTP))
        .toString();
  }
}

class GSendOTPDataBuilder
    implements Builder<GSendOTPData, GSendOTPDataBuilder> {
  _$GSendOTPData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GSendOTPData_sendOTPBuilder? _sendOTP;
  GSendOTPData_sendOTPBuilder get sendOTP =>
      _$this._sendOTP ??= GSendOTPData_sendOTPBuilder();
  set sendOTP(GSendOTPData_sendOTPBuilder? sendOTP) =>
      _$this._sendOTP = sendOTP;

  GSendOTPDataBuilder() {
    GSendOTPData._initializeBuilder(this);
  }

  GSendOTPDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _sendOTP = $v.sendOTP.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendOTPData other) {
    _$v = other as _$GSendOTPData;
  }

  @override
  void update(void Function(GSendOTPDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendOTPData build() => _build();

  _$GSendOTPData _build() {
    _$GSendOTPData _$result;
    try {
      _$result = _$v ??
          _$GSendOTPData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSendOTPData', 'G__typename'),
            sendOTP: sendOTP.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'sendOTP';
        sendOTP.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSendOTPData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GSendOTPData_sendOTP extends GSendOTPData_sendOTP {
  @override
  final String G__typename;
  @override
  final bool success;
  @override
  final String message;
  @override
  final int expiresInSeconds;
  @override
  final bool isRegistered;

  factory _$GSendOTPData_sendOTP(
          [void Function(GSendOTPData_sendOTPBuilder)? updates]) =>
      (GSendOTPData_sendOTPBuilder()..update(updates))._build();

  _$GSendOTPData_sendOTP._(
      {required this.G__typename,
      required this.success,
      required this.message,
      required this.expiresInSeconds,
      required this.isRegistered})
      : super._();
  @override
  GSendOTPData_sendOTP rebuild(
          void Function(GSendOTPData_sendOTPBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendOTPData_sendOTPBuilder toBuilder() =>
      GSendOTPData_sendOTPBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendOTPData_sendOTP &&
        G__typename == other.G__typename &&
        success == other.success &&
        message == other.message &&
        expiresInSeconds == other.expiresInSeconds &&
        isRegistered == other.isRegistered;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, expiresInSeconds.hashCode);
    _$hash = $jc(_$hash, isRegistered.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSendOTPData_sendOTP')
          ..add('G__typename', G__typename)
          ..add('success', success)
          ..add('message', message)
          ..add('expiresInSeconds', expiresInSeconds)
          ..add('isRegistered', isRegistered))
        .toString();
  }
}

class GSendOTPData_sendOTPBuilder
    implements Builder<GSendOTPData_sendOTP, GSendOTPData_sendOTPBuilder> {
  _$GSendOTPData_sendOTP? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  int? _expiresInSeconds;
  int? get expiresInSeconds => _$this._expiresInSeconds;
  set expiresInSeconds(int? expiresInSeconds) =>
      _$this._expiresInSeconds = expiresInSeconds;

  bool? _isRegistered;
  bool? get isRegistered => _$this._isRegistered;
  set isRegistered(bool? isRegistered) => _$this._isRegistered = isRegistered;

  GSendOTPData_sendOTPBuilder() {
    GSendOTPData_sendOTP._initializeBuilder(this);
  }

  GSendOTPData_sendOTPBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _success = $v.success;
      _message = $v.message;
      _expiresInSeconds = $v.expiresInSeconds;
      _isRegistered = $v.isRegistered;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendOTPData_sendOTP other) {
    _$v = other as _$GSendOTPData_sendOTP;
  }

  @override
  void update(void Function(GSendOTPData_sendOTPBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendOTPData_sendOTP build() => _build();

  _$GSendOTPData_sendOTP _build() {
    final _$result = _$v ??
        _$GSendOTPData_sendOTP._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GSendOTPData_sendOTP', 'G__typename'),
          success: BuiltValueNullFieldError.checkNotNull(
              success, r'GSendOTPData_sendOTP', 'success'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'GSendOTPData_sendOTP', 'message'),
          expiresInSeconds: BuiltValueNullFieldError.checkNotNull(
              expiresInSeconds, r'GSendOTPData_sendOTP', 'expiresInSeconds'),
          isRegistered: BuiltValueNullFieldError.checkNotNull(
              isRegistered, r'GSendOTPData_sendOTP', 'isRegistered'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
