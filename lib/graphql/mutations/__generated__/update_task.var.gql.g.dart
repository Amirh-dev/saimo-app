// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GUpdateTaskVars> _$gUpdateTaskVarsSerializer =
    _$GUpdateTaskVarsSerializer();

class _$GUpdateTaskVarsSerializer
    implements StructuredSerializer<GUpdateTaskVars> {
  @override
  final Iterable<Type> types = const [GUpdateTaskVars, _$GUpdateTaskVars];
  @override
  final String wireName = 'GUpdateTaskVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUpdateTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GUpdateTaskInput)),
    ];

    return result;
  }

  @override
  GUpdateTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateTaskVarsBuilder();

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
                  specifiedType: const FullType(_i1.GUpdateTaskInput))!
              as _i1.GUpdateTaskInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateTaskVars extends GUpdateTaskVars {
  @override
  final String id;
  @override
  final _i1.GUpdateTaskInput input;

  factory _$GUpdateTaskVars([void Function(GUpdateTaskVarsBuilder)? updates]) =>
      (GUpdateTaskVarsBuilder()..update(updates))._build();

  _$GUpdateTaskVars._({required this.id, required this.input}) : super._();
  @override
  GUpdateTaskVars rebuild(void Function(GUpdateTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateTaskVarsBuilder toBuilder() => GUpdateTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateTaskVars && id == other.id && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GUpdateTaskVars')
          ..add('id', id)
          ..add('input', input))
        .toString();
  }
}

class GUpdateTaskVarsBuilder
    implements Builder<GUpdateTaskVars, GUpdateTaskVarsBuilder> {
  _$GUpdateTaskVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i1.GUpdateTaskInputBuilder? _input;
  _i1.GUpdateTaskInputBuilder get input =>
      _$this._input ??= _i1.GUpdateTaskInputBuilder();
  set input(_i1.GUpdateTaskInputBuilder? input) => _$this._input = input;

  GUpdateTaskVarsBuilder();

  GUpdateTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateTaskVars other) {
    _$v = other as _$GUpdateTaskVars;
  }

  @override
  void update(void Function(GUpdateTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateTaskVars build() => _build();

  _$GUpdateTaskVars _build() {
    _$GUpdateTaskVars _$result;
    try {
      _$result = _$v ??
          _$GUpdateTaskVars._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GUpdateTaskVars', 'id'),
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateTaskVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
