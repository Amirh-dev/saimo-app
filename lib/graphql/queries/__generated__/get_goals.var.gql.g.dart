// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_goals.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetGoalsVars> _$gGetGoalsVarsSerializer =
    _$GGetGoalsVarsSerializer();

class _$GGetGoalsVarsSerializer implements StructuredSerializer<GGetGoalsVars> {
  @override
  final Iterable<Type> types = const [GGetGoalsVars, _$GGetGoalsVars];
  @override
  final String wireName = 'GGetGoalsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetGoalsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GGetGoalsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GGetGoalsVarsBuilder().build();
  }
}

class _$GGetGoalsVars extends GGetGoalsVars {
  factory _$GGetGoalsVars([void Function(GGetGoalsVarsBuilder)? updates]) =>
      (GGetGoalsVarsBuilder()..update(updates))._build();

  _$GGetGoalsVars._() : super._();
  @override
  GGetGoalsVars rebuild(void Function(GGetGoalsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetGoalsVarsBuilder toBuilder() => GGetGoalsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetGoalsVars;
  }

  @override
  int get hashCode {
    return 287798683;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GGetGoalsVars').toString();
  }
}

class GGetGoalsVarsBuilder
    implements Builder<GGetGoalsVars, GGetGoalsVarsBuilder> {
  _$GGetGoalsVars? _$v;

  GGetGoalsVarsBuilder();

  @override
  void replace(GGetGoalsVars other) {
    _$v = other as _$GGetGoalsVars;
  }

  @override
  void update(void Function(GGetGoalsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetGoalsVars build() => _build();

  _$GGetGoalsVars _build() {
    final _$result = _$v ?? _$GGetGoalsVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
