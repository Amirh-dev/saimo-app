// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_friends.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetFriendsVars> _$gGetFriendsVarsSerializer =
    new _$GGetFriendsVarsSerializer();

class _$GGetFriendsVarsSerializer
    implements StructuredSerializer<GGetFriendsVars> {
  @override
  final Iterable<Type> types = const [GGetFriendsVars, _$GGetFriendsVars];
  @override
  final String wireName = 'GGetFriendsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetFriendsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.limit;
    if (value != null) {
      result
        ..add('limit')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.offset;
    if (value != null) {
      result
        ..add('offset')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  GGetFriendsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GGetFriendsVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'limit':
          result.limit = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'offset':
          result.offset = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetFriendsVars extends GGetFriendsVars {
  @override
  final int? limit;
  @override
  final int? offset;

  factory _$GGetFriendsVars([void Function(GGetFriendsVarsBuilder)? updates]) =>
      (new GGetFriendsVarsBuilder()..update(updates))._build();

  _$GGetFriendsVars._({this.limit, this.offset}) : super._();

  @override
  GGetFriendsVars rebuild(void Function(GGetFriendsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetFriendsVarsBuilder toBuilder() =>
      new GGetFriendsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetFriendsVars &&
        limit == other.limit &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, offset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetFriendsVars')
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class GGetFriendsVarsBuilder
    implements Builder<GGetFriendsVars, GGetFriendsVarsBuilder> {
  _$GGetFriendsVars? _$v;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _offset;
  int? get offset => _$this._offset;
  set offset(int? offset) => _$this._offset = offset;

  GGetFriendsVarsBuilder();

  GGetFriendsVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _limit = $v.limit;
      _offset = $v.offset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetFriendsVars other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GGetFriendsVars;
  }

  @override
  void update(void Function(GGetFriendsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetFriendsVars build() => _build();

  _$GGetFriendsVars _build() {
    final _$result =
        _$v ?? new _$GGetFriendsVars._(limit: limit, offset: offset);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
