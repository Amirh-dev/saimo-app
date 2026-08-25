// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_goal.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteGoalData> _$gDeleteGoalDataSerializer =
    _$GDeleteGoalDataSerializer();

class _$GDeleteGoalDataSerializer
    implements StructuredSerializer<GDeleteGoalData> {
  @override
  final Iterable<Type> types = const [GDeleteGoalData, _$GDeleteGoalData];
  @override
  final String wireName = 'GDeleteGoalData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GDeleteGoalData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'deleteGoal',
      serializers.serialize(object.deleteGoal,
          specifiedType: const FullType(bool)),
    ];

    return result;
  }

  @override
  GDeleteGoalData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteGoalDataBuilder();

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
        case 'deleteGoal':
          result.deleteGoal = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteGoalData extends GDeleteGoalData {
  @override
  final String G__typename;
  @override
  final bool deleteGoal;

  factory _$GDeleteGoalData([void Function(GDeleteGoalDataBuilder)? updates]) =>
      (GDeleteGoalDataBuilder()..update(updates))._build();

  _$GDeleteGoalData._({required this.G__typename, required this.deleteGoal})
      : super._();
  @override
  GDeleteGoalData rebuild(void Function(GDeleteGoalDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteGoalDataBuilder toBuilder() => GDeleteGoalDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteGoalData &&
        G__typename == other.G__typename &&
        deleteGoal == other.deleteGoal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, deleteGoal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteGoalData')
          ..add('G__typename', G__typename)
          ..add('deleteGoal', deleteGoal))
        .toString();
  }
}

class GDeleteGoalDataBuilder
    implements Builder<GDeleteGoalData, GDeleteGoalDataBuilder> {
  _$GDeleteGoalData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  bool? _deleteGoal;
  bool? get deleteGoal => _$this._deleteGoal;
  set deleteGoal(bool? deleteGoal) => _$this._deleteGoal = deleteGoal;

  GDeleteGoalDataBuilder() {
    GDeleteGoalData._initializeBuilder(this);
  }

  GDeleteGoalDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _deleteGoal = $v.deleteGoal;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteGoalData other) {
    _$v = other as _$GDeleteGoalData;
  }

  @override
  void update(void Function(GDeleteGoalDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteGoalData build() => _build();

  _$GDeleteGoalData _build() {
    final _$result = _$v ??
        _$GDeleteGoalData._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GDeleteGoalData', 'G__typename'),
          deleteGoal: BuiltValueNullFieldError.checkNotNull(
              deleteGoal, r'GDeleteGoalData', 'deleteGoal'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
