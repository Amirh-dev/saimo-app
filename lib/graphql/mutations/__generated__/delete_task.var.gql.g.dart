// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteTaskVars> _$gDeleteTaskVarsSerializer =
    _$GDeleteTaskVarsSerializer();

class _$GDeleteTaskVarsSerializer
    implements StructuredSerializer<GDeleteTaskVars> {
  @override
  final Iterable<Type> types = const [GDeleteTaskVars, _$GDeleteTaskVars];
  @override
  final String wireName = 'GDeleteTaskVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GDeleteTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GDeleteTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteTaskVarsBuilder();

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

class _$GDeleteTaskVars extends GDeleteTaskVars {
  @override
  final String id;

  factory _$GDeleteTaskVars([void Function(GDeleteTaskVarsBuilder)? updates]) =>
      (GDeleteTaskVarsBuilder()..update(updates))._build();

  _$GDeleteTaskVars._({required this.id}) : super._();
  @override
  GDeleteTaskVars rebuild(void Function(GDeleteTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteTaskVarsBuilder toBuilder() => GDeleteTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteTaskVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GDeleteTaskVars')..add('id', id))
        .toString();
  }
}

class GDeleteTaskVarsBuilder
    implements Builder<GDeleteTaskVars, GDeleteTaskVarsBuilder> {
  _$GDeleteTaskVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GDeleteTaskVarsBuilder();

  GDeleteTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteTaskVars other) {
    _$v = other as _$GDeleteTaskVars;
  }

  @override
  void update(void Function(GDeleteTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteTaskVars build() => _build();

  _$GDeleteTaskVars _build() {
    final _$result = _$v ??
        _$GDeleteTaskVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GDeleteTaskVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
