// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteTaskData> _$gDeleteTaskDataSerializer =
    _$GDeleteTaskDataSerializer();

class _$GDeleteTaskDataSerializer
    implements StructuredSerializer<GDeleteTaskData> {
  @override
  final Iterable<Type> types = const [GDeleteTaskData, _$GDeleteTaskData];
  @override
  final String wireName = 'GDeleteTaskData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GDeleteTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'deleteTask',
      serializers.serialize(object.deleteTask,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GDeleteTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteTaskDataBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case '__typename':
          result.G__typename = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'deleteTask':
          result.deleteTask = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteTaskData extends GDeleteTaskData {
  @override
  final String G__typename;
  @override
  final bool deleteTask;

  factory _$GDeleteTaskData([void Function(GDeleteTaskDataBuilder)? updates]) =>
      (GDeleteTaskDataBuilder()..update(updates))._build();

  _$GDeleteTaskData._({required this.G__typename, required this.deleteTask})
      : super._();
  @override
  GDeleteTaskData rebuild(void Function(GDeleteTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteTaskDataBuilder toBuilder() => GDeleteTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteTaskData &&
        G__typename == other.G__typename &&
        deleteTask == other.deleteTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, deleteTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteTaskData')
          ..add('G__typename', G__typename)
          ..add('deleteTask', deleteTask))
        .toString();
  }
}

class GDeleteTaskDataBuilder
    implements Builder<GDeleteTaskData, GDeleteTaskDataBuilder> {
  _$GDeleteTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _deleteTask;
  bool? get deleteTask => _$this._deleteTask;
  set deleteTask(bool? deleteTask) => _$this._deleteTask = deleteTask;

  GDeleteTaskDataBuilder() {
    GDeleteTaskData._initializeBuilder(this);
  }

  GDeleteTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _deleteTask = $v.deleteTask;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteTaskData other) {
    _$v = other as _$GDeleteTaskData;
  }

  @override
  void update(void Function(GDeleteTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteTaskData build() => _build();

  _$GDeleteTaskData _build() {
    final _$result = _$v ??
        _$GDeleteTaskData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GDeleteTaskData', 'G__typename'),
          deleteTask: BuiltValueNullFieldError.checkNotNull(
              deleteTask, r'GDeleteTaskData', 'deleteTask'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
