// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_login.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GVerifyOTPAndLoginVars> _$gVerifyOTPAndLoginVarsSerializer =
    _$GVerifyOTPAndLoginVarsSerializer();

class _$GVerifyOTPAndLoginVarsSerializer
    implements StructuredSerializer<GVerifyOTPAndLoginVars> {
  @override
  final Iterable<Type> types = const [
    GVerifyOTPAndLoginVars,
    _$GVerifyOTPAndLoginVars
  ];
  @override
  final String wireName = 'GVerifyOTPAndLoginVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GVerifyOTPAndLoginVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GVerifyOTPAndLoginInput)),
    ];

    return result;
  }

  @override
  GVerifyOTPAndLoginVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GVerifyOTPAndLoginVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GVerifyOTPAndLoginInput))!
              as _i1.GVerifyOTPAndLoginInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GVerifyOTPAndLoginVars extends GVerifyOTPAndLoginVars {
  @override
  final _i1.GVerifyOTPAndLoginInput input;

  factory _$GVerifyOTPAndLoginVars(
          [void Function(GVerifyOTPAndLoginVarsBuilder)? updates]) =>
      (GVerifyOTPAndLoginVarsBuilder()..update(updates))._build();

  _$GVerifyOTPAndLoginVars._({required this.input}) : super._();
  @override
  GVerifyOTPAndLoginVars rebuild(
          void Function(GVerifyOTPAndLoginVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GVerifyOTPAndLoginVarsBuilder toBuilder() =>
      GVerifyOTPAndLoginVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GVerifyOTPAndLoginVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GVerifyOTPAndLoginVars')
          ..add('input', input))
        .toString();
  }
}

class GVerifyOTPAndLoginVarsBuilder
    implements Builder<GVerifyOTPAndLoginVars, GVerifyOTPAndLoginVarsBuilder> {
  _$GVerifyOTPAndLoginVars? _$v;

  _i1.GVerifyOTPAndLoginInputBuilder? _input;
  _i1.GVerifyOTPAndLoginInputBuilder get input =>
      _$this._input ??= _i1.GVerifyOTPAndLoginInputBuilder();
  set input(_i1.GVerifyOTPAndLoginInputBuilder? input) => _$this._input = input;

  GVerifyOTPAndLoginVarsBuilder();

  GVerifyOTPAndLoginVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GVerifyOTPAndLoginVars other) {
    _$v = other as _$GVerifyOTPAndLoginVars;
  }

  @override
  void update(void Function(GVerifyOTPAndLoginVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GVerifyOTPAndLoginVars build() => _build();

  _$GVerifyOTPAndLoginVars _build() {
    _$GVerifyOTPAndLoginVars _$result;
    try {
      _$result = _$v ??
          _$GVerifyOTPAndLoginVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GVerifyOTPAndLoginVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
