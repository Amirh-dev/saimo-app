// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateTaskVars> _$gCreateTaskVarsSerializer =
    _$GCreateTaskVarsSerializer();

class _$GCreateTaskVarsSerializer
    implements StructuredSerializer<GCreateTaskVars> {
  @override
  final Iterable<Type> types = const [GCreateTaskVars, _$GCreateTaskVars];
  @override
  final String wireName = 'GCreateTaskVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GCreateTaskInput)),
    ];

    return result;
  }

  @override
  GCreateTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GCreateTaskInput))!
              as _i1.GCreateTaskInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskVars extends GCreateTaskVars {
  @override
  final _i1.GCreateTaskInput input;

  factory _$GCreateTaskVars([void Function(GCreateTaskVarsBuilder)? updates]) =>
      (GCreateTaskVarsBuilder()..update(updates))._build();

  _$GCreateTaskVars._({required this.input}) : super._();
  @override
  GCreateTaskVars rebuild(void Function(GCreateTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskVarsBuilder toBuilder() => GCreateTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GCreateTaskVars')
          ..add('input', input))
        .toString();
  }
}

class GCreateTaskVarsBuilder
    implements Builder<GCreateTaskVars, GCreateTaskVarsBuilder> {
  _$GCreateTaskVars? _$v;

  _i1.GCreateTaskInputBuilder? _input;
  _i1.GCreateTaskInputBuilder get input =>
      _$this._input ??= _i1.GCreateTaskInputBuilder();
  set input(_i1.GCreateTaskInputBuilder? input) => _$this._input = input;

  GCreateTaskVarsBuilder();

  GCreateTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskVars other) {
    _$v = other as _$GCreateTaskVars;
  }

  @override
  void update(void Function(GCreateTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskVars build() => _build();

  _$GCreateTaskVars _build() {
    _$GCreateTaskVars _$result;
    try {
      _$result = _$v ??
          _$GCreateTaskVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateTaskVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
