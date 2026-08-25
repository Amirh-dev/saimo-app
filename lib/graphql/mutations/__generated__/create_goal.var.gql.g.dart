// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_goal.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateGoalVars> _$gCreateGoalVarsSerializer =
    _$GCreateGoalVarsSerializer();

class _$GCreateGoalVarsSerializer
    implements StructuredSerializer<GCreateGoalVars> {
  @override
  final Iterable<Type> types = const [GCreateGoalVars, _$GCreateGoalVars];
  @override
  final String wireName = 'GCreateGoalVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateGoalVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GCreateGoalInput)),
    ];

    return result;
  }

  @override
  GCreateGoalVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateGoalVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GCreateGoalInput))!
              as _i1.GCreateGoalInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateGoalVars extends GCreateGoalVars {
  @override
  final _i1.GCreateGoalInput input;

  factory _$GCreateGoalVars([void Function(GCreateGoalVarsBuilder)? updates]) =>
      (GCreateGoalVarsBuilder()..update(updates))._build();

  _$GCreateGoalVars._({required this.input}) : super._();
  @override
  GCreateGoalVars rebuild(void Function(GCreateGoalVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateGoalVarsBuilder toBuilder() => GCreateGoalVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateGoalVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GCreateGoalVars')
          ..add('input', input))
        .toString();
  }
}

class GCreateGoalVarsBuilder
    implements Builder<GCreateGoalVars, GCreateGoalVarsBuilder> {
  _$GCreateGoalVars? _$v;

  _i1.GCreateGoalInputBuilder? _input;
  _i1.GCreateGoalInputBuilder get input =>
      _$this._input ??= _i1.GCreateGoalInputBuilder();
  set input(_i1.GCreateGoalInputBuilder? input) => _$this._input = input;

  GCreateGoalVarsBuilder();

  GCreateGoalVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateGoalVars other) {
    _$v = other as _$GCreateGoalVars;
  }

  @override
  void update(void Function(GCreateGoalVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateGoalVars build() => _build();

  _$GCreateGoalVars _build() {
    _$GCreateGoalVars _$result;
    try {
      _$result = _$v ??
          _$GCreateGoalVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateGoalVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
