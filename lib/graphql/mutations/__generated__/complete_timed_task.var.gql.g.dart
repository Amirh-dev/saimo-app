// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_timed_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCompleteTimedTaskVars> _$gCompleteTimedTaskVarsSerializer =
    _$GCompleteTimedTaskVarsSerializer();

class _$GCompleteTimedTaskVarsSerializer
    implements StructuredSerializer<GCompleteTimedTaskVars> {
  @override
  final Iterable<Type> types = const [
    GCompleteTimedTaskVars,
    _$GCompleteTimedTaskVars
  ];
  @override
  final String wireName = 'GCompleteTimedTaskVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCompleteTimedTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GCompleteTimedTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTimedTaskVarsBuilder();

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

class _$GCompleteTimedTaskVars extends GCompleteTimedTaskVars {
  @override
  final String id;

  factory _$GCompleteTimedTaskVars(
          [void Function(GCompleteTimedTaskVarsBuilder)? updates]) =>
      (GCompleteTimedTaskVarsBuilder()..update(updates))._build();

  _$GCompleteTimedTaskVars._({required this.id}) : super._();
  @override
  GCompleteTimedTaskVars rebuild(
          void Function(GCompleteTimedTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTimedTaskVarsBuilder toBuilder() =>
      GCompleteTimedTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTimedTaskVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GCompleteTimedTaskVars')
          ..add('id', id))
        .toString();
  }
}

class GCompleteTimedTaskVarsBuilder
    implements Builder<GCompleteTimedTaskVars, GCompleteTimedTaskVarsBuilder> {
  _$GCompleteTimedTaskVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GCompleteTimedTaskVarsBuilder();

  GCompleteTimedTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCompleteTimedTaskVars other) {
    _$v = other as _$GCompleteTimedTaskVars;
  }

  @override
  void update(void Function(GCompleteTimedTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTimedTaskVars build() => _build();

  _$GCompleteTimedTaskVars _build() {
    final _$result = _$v ??
        _$GCompleteTimedTaskVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GCompleteTimedTaskVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
