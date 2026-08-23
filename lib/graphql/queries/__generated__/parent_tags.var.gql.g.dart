// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_tags.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GParentTagsVars> _$gParentTagsVarsSerializer =
    _$GParentTagsVarsSerializer();

class _$GParentTagsVarsSerializer
    implements StructuredSerializer<GParentTagsVars> {
  @override
  final Iterable<Type> types = const [GParentTagsVars, _$GParentTagsVars];
  @override
  final String wireName = 'GParentTagsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GParentTagsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GParentTagsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GParentTagsVarsBuilder().build();
  }
}

class _$GParentTagsVars extends GParentTagsVars {
  factory _$GParentTagsVars([void Function(GParentTagsVarsBuilder)? updates]) =>
      (GParentTagsVarsBuilder()..update(updates))._build();

  _$GParentTagsVars._() : super._();
  @override
  GParentTagsVars rebuild(void Function(GParentTagsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GParentTagsVarsBuilder toBuilder() => GParentTagsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GParentTagsVars;
  }

  @override
  int get hashCode {
    return 380415913;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GParentTagsVars').toString();
  }
}

class GParentTagsVarsBuilder
    implements Builder<GParentTagsVars, GParentTagsVarsBuilder> {
  _$GParentTagsVars? _$v;

  GParentTagsVarsBuilder();

  @override
  void replace(GParentTagsVars other) {
    _$v = other as _$GParentTagsVars;
  }

  @override
  void update(void Function(GParentTagsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GParentTagsVars build() => _build();

  _$GParentTagsVars _build() {
    final _$result = _$v ?? _$GParentTagsVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
