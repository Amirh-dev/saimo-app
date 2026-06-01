// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_otp.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSendOTPVars> _$gSendOTPVarsSerializer =
    new _$GSendOTPVarsSerializer();

class _$GSendOTPVarsSerializer implements StructuredSerializer<GSendOTPVars> {
  @override
  final Iterable<Type> types = const [GSendOTPVars, _$GSendOTPVars];
  @override
  final String wireName = 'GSendOTPVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendOTPVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GSendOTPInput)),
    ];

    return result;
  }

  @override
  GSendOTPVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GSendOTPVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GSendOTPInput))!
              as _i1.GSendOTPInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendOTPVars extends GSendOTPVars {
  @override
  final _i1.GSendOTPInput input;

  factory _$GSendOTPVars([void Function(GSendOTPVarsBuilder)? updates]) =>
      (new GSendOTPVarsBuilder()..update(updates))._build();

  _$GSendOTPVars._({required this.input}) : super._() {
    BuiltValueNullFieldError.checkNotNull(input, r'GSendOTPVars', 'input');
  }

  @override
  GSendOTPVars rebuild(void Function(GSendOTPVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendOTPVarsBuilder toBuilder() => new GSendOTPVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendOTPVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GSendOTPVars')..add('input', input))
        .toString();
  }
}

class GSendOTPVarsBuilder
    implements Builder<GSendOTPVars, GSendOTPVarsBuilder> {
  _$GSendOTPVars? _$v;

  _i1.GSendOTPInputBuilder? _input;
  _i1.GSendOTPInputBuilder get input =>
      _$this._input ??= new _i1.GSendOTPInputBuilder();
  set input(_i1.GSendOTPInputBuilder? input) => _$this._input = input;

  GSendOTPVarsBuilder();

  GSendOTPVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendOTPVars other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GSendOTPVars;
  }

  @override
  void update(void Function(GSendOTPVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendOTPVars build() => _build();

  _$GSendOTPVars _build() {
    _$GSendOTPVars _$result;
    try {
      _$result = _$v ?? new _$GSendOTPVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GSendOTPVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
