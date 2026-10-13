// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_for_registration.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPForRegistrationVars>
    _$gVerifyOTPForRegistrationVarsSerializer =
    _$GVerifyOTPForRegistrationVarsSerializer();

class _$GVerifyOTPForRegistrationVarsSerializer
    implements StructuredSerializer<GVerifyOTPForRegistrationVars> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPForRegistrationVars,
    _$GVerifyOTPForRegistrationVars
  ];
  @override
  final String wireName = 'GVerifyOTPForRegistrationVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPForRegistrationVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GVerifyOTPInput)),
    ];

    return result;
  }

  @override
  GVerifyOTPForRegistrationVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPForRegistrationVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GVerifyOTPInput))!
              as _i1.GVerifyOTPInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPForRegistrationVars extends GVerifyOTPForRegistrationVars {
  @override
  final _i1.GVerifyOTPInput input;

  factory _$GVerifyOTPForRegistrationVars(
          [void Function(GVerifyOTPForRegistrationVarsBuilder)? updates]) =>
      (GVerifyOTPForRegistrationVarsBuilder()..update(updates))._build();

  _$GVerifyOTPForRegistrationVars._({required this.input}) : super._();
  @override
  GVerifyOTPForRegistrationVars rebuild(
          void Function(GVerifyOTPForRegistrationVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPForRegistrationVarsBuilder toBuilder() =>
      GVerifyOTPForRegistrationVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPForRegistrationVars && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GVerifyOTPForRegistrationVars')
          ..add('input', input))
        .toString();
  }
}

class GVerifyOTPForRegistrationVarsBuilder
    implements
        Builder<GVerifyOTPForRegistrationVars,
            GVerifyOTPForRegistrationVarsBuilder> {
  _$GVerifyOTPForRegistrationVars? _$v;

  _i1.GVerifyOTPInputBuilder? _input;
  _i1.GVerifyOTPInputBuilder get input =>
      _$this._input ??= _i1.GVerifyOTPInputBuilder();
  set input(_i1.GVerifyOTPInputBuilder? input) => _$this._input = input;

  GVerifyOTPForRegistrationVarsBuilder();

  GVerifyOTPForRegistrationVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPForRegistrationVars other) {
    _$v = other as _$GVerifyOTPForRegistrationVars;
  }

  @override
  void update(void Function(GVerifyOTPForRegistrationVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPForRegistrationVars build() => _build();

  _$GVerifyOTPForRegistrationVars _build() {
    _$GVerifyOTPForRegistrationVars _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPForRegistrationVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPForRegistrationVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
