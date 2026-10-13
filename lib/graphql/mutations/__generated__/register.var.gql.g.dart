// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRegisterVars> _$gRegisterVarsSerializer =
    _$GRegisterVarsSerializer();

class _$GRegisterVarsSerializer implements StructuredSerializer<GRegisterVars> {
  @override
  final Iterable<Type> types = const [GRegisterVars, _$GRegisterVars];
  @override
  final String wireName = 'GRegisterVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GRegisterVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GRegisterInput)),
    ];

    return result;
  }

  @override
  GRegisterVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GRegisterVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GRegisterInput))!
              as _i1.GRegisterInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GRegisterVars extends GRegisterVars {
  @override
  final _i1.GRegisterInput input;

  factory _$GRegisterVars([void Function(GRegisterVarsBuilder)? updates]) =>
      (GRegisterVarsBuilder()..update(updates))._build();

  _$GRegisterVars._({required this.input}) : super._();
  @override
  GRegisterVars rebuild(void Function(GRegisterVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRegisterVarsBuilder toBuilder() => GRegisterVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRegisterVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GRegisterVars')..add('input', input))
        .toString();
  }
}

class GRegisterVarsBuilder
    implements Builder<GRegisterVars, GRegisterVarsBuilder> {
  _$GRegisterVars? _$v;

  _i1.GRegisterInputBuilder? _input;
  _i1.GRegisterInputBuilder get input =>
      _$this._input ??= _i1.GRegisterInputBuilder();
  set input(_i1.GRegisterInputBuilder? input) => _$this._input = input;

  GRegisterVarsBuilder();

  GRegisterVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRegisterVars other) {
    _$v = other as _$GRegisterVars;
  }

  @override
  void update(void Function(GRegisterVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRegisterVars build() => _build();

  _$GRegisterVars _build() {
    _$GRegisterVars _$result;
    try {
      _$result = _$v ??
          _$GRegisterVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GRegisterVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
