// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_goal.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GUpdateGoalVars> _$gUpdateGoalVarsSerializer =
    _$GUpdateGoalVarsSerializer();

class _$GUpdateGoalVarsSerializer
    implements StructuredSerializer<GUpdateGoalVars> {
  @override
  final Iterable<Type> types = const [GUpdateGoalVars, _$GUpdateGoalVars];
  @override
  final String wireName = 'GUpdateGoalVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUpdateGoalVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GUpdateGoalInput)),
    ];

    return result;
  }

  @override
  GUpdateGoalVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateGoalVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GUpdateGoalInput))!
              as _i1.GUpdateGoalInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateGoalVars extends GUpdateGoalVars {
  @override
  final String id;
  @override
  final _i1.GUpdateGoalInput input;

  factory _$GUpdateGoalVars([void Function(GUpdateGoalVarsBuilder)? updates]) =>
      (GUpdateGoalVarsBuilder()..update(updates))._build();

  _$GUpdateGoalVars._({required this.id, required this.input}) : super._();
  @override
  GUpdateGoalVars rebuild(void Function(GUpdateGoalVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateGoalVarsBuilder toBuilder() => GUpdateGoalVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateGoalVars && id == other.id && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateGoalVars')
          ..add('id', id)
          ..add('input', input))
        .toString();
  }
}

class GUpdateGoalVarsBuilder
    implements Builder<GUpdateGoalVars, GUpdateGoalVarsBuilder> {
  _$GUpdateGoalVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i1.GUpdateGoalInputBuilder? _input;
  _i1.GUpdateGoalInputBuilder get input =>
      _$this._input ??= _i1.GUpdateGoalInputBuilder();
  set input(_i1.GUpdateGoalInputBuilder? input) => _$this._input = input;

  GUpdateGoalVarsBuilder();

  GUpdateGoalVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateGoalVars other) {
    _$v = other as _$GUpdateGoalVars;
  }

  @override
  void update(void Function(GUpdateGoalVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateGoalVars build() => _build();

  _$GUpdateGoalVars _build() {
    _$GUpdateGoalVars _$result;
    try {
      _$result = _$v ??
          _$GUpdateGoalVars._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GUpdateGoalVars', 'id'),
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateGoalVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
