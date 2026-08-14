// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_register.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPAndRegisterVars> _$gVerifyOTPAndRegisterVarsSerializer =
    _$GVerifyOTPAndRegisterVarsSerializer();

class _$GVerifyOTPAndRegisterVarsSerializer
    implements StructuredSerializer<GVerifyOTPAndRegisterVars> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndRegisterVars,
    _$GVerifyOTPAndRegisterVars
  ];
  @override
  final String wireName = 'GVerifyOTPAndRegisterVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndRegisterVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GVerifyOTPAndRegisterInput)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndRegisterVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPAndRegisterVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(_i1.GVerifyOTPAndRegisterInput))!
              as _i1.GVerifyOTPAndRegisterInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndRegisterVars extends GVerifyOTPAndRegisterVars {
  @override
  final _i1.GVerifyOTPAndRegisterInput input;

  factory _$GVerifyOTPAndRegisterVars(
          [void Function(GVerifyOTPAndRegisterVarsBuilder)? updates]) =>
      (GVerifyOTPAndRegisterVarsBuilder()..update(updates))._build();

  _$GVerifyOTPAndRegisterVars._({required this.input}) : super._();
  @override
  GVerifyOTPAndRegisterVars rebuild(
          void Function(GVerifyOTPAndRegisterVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndRegisterVarsBuilder toBuilder() =>
      GVerifyOTPAndRegisterVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndRegisterVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndRegisterVars')
          ..add('input', input))
        .toString();
  }
}

class GVerifyOTPAndRegisterVarsBuilder
    implements
        Builder<GVerifyOTPAndRegisterVars, GVerifyOTPAndRegisterVarsBuilder> {
  _$GVerifyOTPAndRegisterVars? _$v;

  _i1.GVerifyOTPAndRegisterInputBuilder? _input;
  _i1.GVerifyOTPAndRegisterInputBuilder get input =>
      _$this._input ??= _i1.GVerifyOTPAndRegisterInputBuilder();
  set input(_i1.GVerifyOTPAndRegisterInputBuilder? input) =>
      _$this._input = input;

  GVerifyOTPAndRegisterVarsBuilder();

  GVerifyOTPAndRegisterVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndRegisterVars other) {
    _$v = other as _$GVerifyOTPAndRegisterVars;
  }

  @override
  void update(void Function(GVerifyOTPAndRegisterVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndRegisterVars build() => _build();

  _$GVerifyOTPAndRegisterVars _build() {
    _$GVerifyOTPAndRegisterVars _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPAndRegisterVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPAndRegisterVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
