// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_timed_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GStartTimedTaskVars> _$gStartTimedTaskVarsSerializer =
    _$GStartTimedTaskVarsSerializer();

class _$GStartTimedTaskVarsSerializer
    implements StructuredSerializer<GStartTimedTaskVars> {
  @override
  final Iterable<Type> types = const [
    GStartTimedTaskVars,
    _$GStartTimedTaskVars
  ];
  @override
  final String wireName = 'GStartTimedTaskVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GStartTimedTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GStartTimedTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GStartTimedTaskVarsBuilder();

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
      }
    }

    return result.build();
  }
}

class _$GStartTimedTaskVars extends GStartTimedTaskVars {
  @override
  final String id;

  factory _$GStartTimedTaskVars(
          [void Function(GStartTimedTaskVarsBuilder)? updates]) =>
      (GStartTimedTaskVarsBuilder()..update(updates))._build();

  _$GStartTimedTaskVars._({required this.id}) : super._();
  @override
  GStartTimedTaskVars rebuild(
          void Function(GStartTimedTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStartTimedTaskVarsBuilder toBuilder() =>
      GStartTimedTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStartTimedTaskVars && id == other.id;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GStartTimedTaskVars')..add('id', id))
        .toString();
  }
}

class GStartTimedTaskVarsBuilder
    implements Builder<GStartTimedTaskVars, GStartTimedTaskVarsBuilder> {
  _$GStartTimedTaskVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GStartTimedTaskVarsBuilder();

  GStartTimedTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GStartTimedTaskVars other) {
    _$v = other as _$GStartTimedTaskVars;
  }

  @override
  void update(void Function(GStartTimedTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GStartTimedTaskVars build() => _build();

  _$GStartTimedTaskVars _build() {
    final _$result = _$v ??
        _$GStartTimedTaskVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GStartTimedTaskVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
