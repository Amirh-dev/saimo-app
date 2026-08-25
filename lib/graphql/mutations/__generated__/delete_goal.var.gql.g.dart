// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_goal.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteGoalVars> _$gDeleteGoalVarsSerializer =
    _$GDeleteGoalVarsSerializer();

class _$GDeleteGoalVarsSerializer
    implements StructuredSerializer<GDeleteGoalVars> {
  @override
  final Iterable<Type> types = const [GDeleteGoalVars, _$GDeleteGoalVars];
  @override
  final String wireName = 'GDeleteGoalVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GDeleteGoalVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GDeleteGoalVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteGoalVarsBuilder();

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

class _$GDeleteGoalVars extends GDeleteGoalVars {
  @override
  final String id;

  factory _$GDeleteGoalVars([void Function(GDeleteGoalVarsBuilder)? updates]) =>
      (GDeleteGoalVarsBuilder()..update(updates))._build();

  _$GDeleteGoalVars._({required this.id}) : super._();
  @override
  GDeleteGoalVars rebuild(void Function(GDeleteGoalVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteGoalVarsBuilder toBuilder() => GDeleteGoalVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteGoalVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GDeleteGoalVars')..add('id', id))
        .toString();
  }
}

class GDeleteGoalVarsBuilder
    implements Builder<GDeleteGoalVars, GDeleteGoalVarsBuilder> {
  _$GDeleteGoalVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GDeleteGoalVarsBuilder();

  GDeleteGoalVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteGoalVars other) {
    _$v = other as _$GDeleteGoalVars;
  }

  @override
  void update(void Function(GDeleteGoalVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteGoalVars build() => _build();

  _$GDeleteGoalVars _build() {
    final _$result = _$v ??
        _$GDeleteGoalVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GDeleteGoalVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
