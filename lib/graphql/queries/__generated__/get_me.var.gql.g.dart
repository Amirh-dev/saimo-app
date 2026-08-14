// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_me.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetMeVars> _$gGetMeVarsSerializer = _$GGetMeVarsSerializer();

class _$GGetMeVarsSerializer implements StructuredSerializer<GGetMeVars> {
  @override
  final Iterable<Type> types = const [GGetMeVars, _$GGetMeVars];
  @override
  final String wireName = 'GGetMeVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetMeVars object,
      {FullType specifiedType = FullType.unspecified}) {
    return <Object?>[];
  }

  @override
  GGetMeVars deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    return GGetMeVarsBuilder().build();
  }
}

class _$GGetMeVars extends GGetMeVars {
  factory _$GGetMeVars([void Function(GGetMeVarsBuilder)? updates]) =>
      (GGetMeVarsBuilder()..update(updates))._build();

  _$GGetMeVars._() : super._();
  @override
  GGetMeVars rebuild(void Function(GGetMeVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetMeVarsBuilder toBuilder() => GGetMeVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetMeVars;
  }

  @override
  int get hashCode {
    return 547541721;
  }

  @override
  String toString() {
    return newBuiltValueToStringHelper(r'GGetMeVars').toString();
  }
}

class GGetMeVarsBuilder implements Builder<GGetMeVars, GGetMeVarsBuilder> {
  _$GGetMeVars? _$v;

  GGetMeVarsBuilder();

  @override
  void replace(GGetMeVars other) {
    _$v = other as _$GGetMeVars;
  }

  @override
  void update(void Function(GGetMeVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetMeVars build() => _build();

  _$GGetMeVars _build() {
    final _$result = _$v ?? _$GGetMeVars._();
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
