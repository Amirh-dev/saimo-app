// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_goal.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GUpdateGoalData> _$gUpdateGoalDataSerializer =
    _$GUpdateGoalDataSerializer();
Serializer<GUpdateGoalData_updateGoal> _$gUpdateGoalDataUpdateGoalSerializer =
    _$GUpdateGoalData_updateGoalSerializer();

class _$GUpdateGoalDataSerializer
    implements StructuredSerializer<GUpdateGoalData> {
  @override
  final Iterable<Type> types = const [GUpdateGoalData, _$GUpdateGoalData];
  @override
  final String wireName = 'GUpdateGoalData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GUpdateGoalData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'updateGoal',
      serializers.serialize(object.updateGoal,
          specifiedType: const FullType(GUpdateGoalData_updateGoal)),
    ];

    return result;
  }

  @override
  GUpdateGoalData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateGoalDataBuilder();

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
        case 'updateGoal':
          result.updateGoal.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GUpdateGoalData_updateGoal))!
              as GUpdateGoalData_updateGoal);
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateGoalData_updateGoalSerializer
    implements StructuredSerializer<GUpdateGoalData_updateGoal> {
  @override
  final Iterable<Type> types = const [
    GUpdateGoalData_updateGoal,
    _$GUpdateGoalData_updateGoal
  ];
  @override
  final String wireName = 'GUpdateGoalData_updateGoal';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GUpdateGoalData_updateGoal object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'createdAt',
      serializers.serialize(object.createdAt,
          specifiedType: const FullType(_i2.GTime)),
      'updatedAt',
      serializers.serialize(object.updatedAt,
          specifiedType: const FullType(_i2.GTime)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'status',
      serializers.serialize(object.status,
          specifiedType: const FullType(_i2.GGoalStatus)),
      'userID',
      serializers.serialize(object.userID,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.targetDate;
    if (value != null) {
      result
        ..add('targetDate')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    return result;
  }

  @override
  GUpdateGoalData_updateGoal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GUpdateGoalData_updateGoalBuilder();

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
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'createdAt':
          result.createdAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'updatedAt':
          result.updatedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'targetDate':
          result.targetDate.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GGoalStatus))!
              as _i2.GGoalStatus;
          break;
        case 'userID':
          result.userID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GUpdateGoalData extends GUpdateGoalData {
  @override
  final String G__typename;
  @override
  final GUpdateGoalData_updateGoal updateGoal;

  factory _$GUpdateGoalData([void Function(GUpdateGoalDataBuilder)? updates]) =>
      (GUpdateGoalDataBuilder()..update(updates))._build();

  _$GUpdateGoalData._({required this.G__typename, required this.updateGoal})
      : super._();
  @override
  GUpdateGoalData rebuild(void Function(GUpdateGoalDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateGoalDataBuilder toBuilder() => GUpdateGoalDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateGoalData &&
        G__typename == other.G__typename &&
        updateGoal == other.updateGoal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, updateGoal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateGoalData')
          ..add('G__typename', G__typename)
          ..add('updateGoal', updateGoal))
        .toString();
  }
}

class GUpdateGoalDataBuilder
    implements Builder<GUpdateGoalData, GUpdateGoalDataBuilder> {
  _$GUpdateGoalData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GUpdateGoalData_updateGoalBuilder? _updateGoal;
  GUpdateGoalData_updateGoalBuilder get updateGoal =>
      _$this._updateGoal ??= GUpdateGoalData_updateGoalBuilder();
  set updateGoal(GUpdateGoalData_updateGoalBuilder? updateGoal) =>
      _$this._updateGoal = updateGoal;

  GUpdateGoalDataBuilder() {
    GUpdateGoalData._initializeBuilder(this);
  }

  GUpdateGoalDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _updateGoal = $v.updateGoal.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateGoalData other) {
    _$v = other as _$GUpdateGoalData;
  }

  @override
  void update(void Function(GUpdateGoalDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateGoalData build() => _build();

  _$GUpdateGoalData _build() {
    _$GUpdateGoalData _$result;
    try {
      _$result = _$v ??
          _$GUpdateGoalData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GUpdateGoalData', 'G__typename'),
            updateGoal: updateGoal.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'updateGoal';
        updateGoal.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateGoalData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GUpdateGoalData_updateGoal extends GUpdateGoalData_updateGoal {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GTime createdAt;
  @override
  final _i2.GTime updatedAt;
  @override
  final String title;
  @override
  final String? note;
  @override
  final _i2.GTime? targetDate;
  @override
  final _i2.GGoalStatus status;
  @override
  final String userID;

  factory _$GUpdateGoalData_updateGoal(
          [void Function(GUpdateGoalData_updateGoalBuilder)? updates]) =>
      (GUpdateGoalData_updateGoalBuilder()..update(updates))._build();

  _$GUpdateGoalData_updateGoal._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      this.note,
      this.targetDate,
      required this.status,
      required this.userID})
      : super._();
  @override
  GUpdateGoalData_updateGoal rebuild(
          void Function(GUpdateGoalData_updateGoalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GUpdateGoalData_updateGoalBuilder toBuilder() =>
      GUpdateGoalData_updateGoalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GUpdateGoalData_updateGoal &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        title == other.title &&
        note == other.note &&
        targetDate == other.targetDate &&
        status == other.status &&
        userID == other.userID;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, targetDate.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, userID.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GUpdateGoalData_updateGoal')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('title', title)
          ..add('note', note)
          ..add('targetDate', targetDate)
          ..add('status', status)
          ..add('userID', userID))
        .toString();
  }
}

class GUpdateGoalData_updateGoalBuilder
    implements
        Builder<GUpdateGoalData_updateGoal, GUpdateGoalData_updateGoalBuilder> {
  _$GUpdateGoalData_updateGoal? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GTimeBuilder? _createdAt;
  _i2.GTimeBuilder get createdAt => _$this._createdAt ??= _i2.GTimeBuilder();
  set createdAt(_i2.GTimeBuilder? createdAt) => _$this._createdAt = createdAt;

  _i2.GTimeBuilder? _updatedAt;
  _i2.GTimeBuilder get updatedAt => _$this._updatedAt ??= _i2.GTimeBuilder();
  set updatedAt(_i2.GTimeBuilder? updatedAt) => _$this._updatedAt = updatedAt;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  _i2.GTimeBuilder? _targetDate;
  _i2.GTimeBuilder get targetDate => _$this._targetDate ??= _i2.GTimeBuilder();
  set targetDate(_i2.GTimeBuilder? targetDate) =>
      _$this._targetDate = targetDate;

  _i2.GGoalStatus? _status;
  _i2.GGoalStatus? get status => _$this._status;
  set status(_i2.GGoalStatus? status) => _$this._status = status;

  String? _userID;
  String? get userID => _$this._userID;
  set userID(String? userID) => _$this._userID = userID;

  GUpdateGoalData_updateGoalBuilder() {
    GUpdateGoalData_updateGoal._initializeBuilder(this);
  }

  GUpdateGoalData_updateGoalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _updatedAt = $v.updatedAt.toBuilder();
      _title = $v.title;
      _note = $v.note;
      _targetDate = $v.targetDate?.toBuilder();
      _status = $v.status;
      _userID = $v.userID;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GUpdateGoalData_updateGoal other) {
    _$v = other as _$GUpdateGoalData_updateGoal;
  }

  @override
  void update(void Function(GUpdateGoalData_updateGoalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GUpdateGoalData_updateGoal build() => _build();

  _$GUpdateGoalData_updateGoal _build() {
    _$GUpdateGoalData_updateGoal _$result;
    try {
      _$result = _$v ??
          _$GUpdateGoalData_updateGoal._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GUpdateGoalData_updateGoal', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GUpdateGoalData_updateGoal', 'id'),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GUpdateGoalData_updateGoal', 'title'),
            note: note,
            targetDate: _targetDate?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GUpdateGoalData_updateGoal', 'status'),
            userID: BuiltValueNullFieldError.checkNotNull(
                userID, r'GUpdateGoalData_updateGoal', 'userID'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'updatedAt';
        updatedAt.build();

        _$failedField = 'targetDate';
        _targetDate?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GUpdateGoalData_updateGoal', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
