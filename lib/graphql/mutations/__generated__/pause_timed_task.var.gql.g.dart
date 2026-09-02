// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pause_timed_task.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPauseTimedTaskVars> _$gPauseTimedTaskVarsSerializer =
    _$GPauseTimedTaskVarsSerializer();

class _$GPauseTimedTaskVarsSerializer
    implements StructuredSerializer<GPauseTimedTaskVars> {
  @override
  final Iterable<Type> types = const [
    GPauseTimedTaskVars,
    _$GPauseTimedTaskVars
  ];
  @override
  final String wireName = 'GPauseTimedTaskVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPauseTimedTaskVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GPauseTimedTaskVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPauseTimedTaskVarsBuilder();

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

class _$GPauseTimedTaskVars extends GPauseTimedTaskVars {
  @override
  final String id;

  factory _$GPauseTimedTaskVars(
          [void Function(GPauseTimedTaskVarsBuilder)? updates]) =>
      (GPauseTimedTaskVarsBuilder()..update(updates))._build();

  _$GPauseTimedTaskVars._({required this.id}) : super._();
  @override
  GPauseTimedTaskVars rebuild(
          void Function(GPauseTimedTaskVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPauseTimedTaskVarsBuilder toBuilder() =>
      GPauseTimedTaskVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPauseTimedTaskVars && id == other.id;
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
    return (newBuiltValueToStringHelper(r'GPauseTimedTaskVars')..add('id', id))
        .toString();
  }
}

class GPauseTimedTaskVarsBuilder
    implements Builder<GPauseTimedTaskVars, GPauseTimedTaskVarsBuilder> {
  _$GPauseTimedTaskVars? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  GPauseTimedTaskVarsBuilder();

  GPauseTimedTaskVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPauseTimedTaskVars other) {
    _$v = other as _$GPauseTimedTaskVars;
  }

  @override
  void update(void Function(GPauseTimedTaskVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPauseTimedTaskVars build() => _build();

  _$GPauseTimedTaskVars _build() {
    final _$result = _$v ??
        _$GPauseTimedTaskVars._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GPauseTimedTaskVars', 'id'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
