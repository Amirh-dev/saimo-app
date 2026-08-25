// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_goal.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateGoalData> _$gCreateGoalDataSerializer =
    _$GCreateGoalDataSerializer();
Serializer<GCreateGoalData_createGoal> _$gCreateGoalDataCreateGoalSerializer =
    _$GCreateGoalData_createGoalSerializer();

class _$GCreateGoalDataSerializer
    implements StructuredSerializer<GCreateGoalData> {
  @override
  final Iterable<Type> types = const [GCreateGoalData, _$GCreateGoalData];
  @override
  final String wireName = 'GCreateGoalData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateGoalData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'createGoal',
      serializers.serialize(object.createGoal,
          specifiedType: const FullType(GCreateGoalData_createGoal)),
    ];

    return result;
  }

  @override
  GCreateGoalData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateGoalDataBuilder();

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
        case 'createGoal':
          result.createGoal.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GCreateGoalData_createGoal))!
              as GCreateGoalData_createGoal);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateGoalData_createGoalSerializer
    implements StructuredSerializer<GCreateGoalData_createGoal> {
  @override
  final Iterable<Type> types = const [
    GCreateGoalData_createGoal,
    _$GCreateGoalData_createGoal
  ];
  @override
  final String wireName = 'GCreateGoalData_createGoal';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateGoalData_createGoal object,
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
  GCreateGoalData_createGoal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateGoalData_createGoalBuilder();

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

class _$GCreateGoalData extends GCreateGoalData {
  @override
  final String G__typename;
  @override
  final GCreateGoalData_createGoal createGoal;

  factory _$GCreateGoalData([void Function(GCreateGoalDataBuilder)? updates]) =>
      (GCreateGoalDataBuilder()..update(updates))._build();

  _$GCreateGoalData._({required this.G__typename, required this.createGoal})
      : super._();
  @override
  GCreateGoalData rebuild(void Function(GCreateGoalDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateGoalDataBuilder toBuilder() => GCreateGoalDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateGoalData &&
        G__typename == other.G__typename &&
        createGoal == other.createGoal;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, createGoal.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateGoalData')
          ..add('G__typename', G__typename)
          ..add('createGoal', createGoal))
        .toString();
  }
}

class GCreateGoalDataBuilder
    implements Builder<GCreateGoalData, GCreateGoalDataBuilder> {
  _$GCreateGoalData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCreateGoalData_createGoalBuilder? _createGoal;
  GCreateGoalData_createGoalBuilder get createGoal =>
      _$this._createGoal ??= GCreateGoalData_createGoalBuilder();
  set createGoal(GCreateGoalData_createGoalBuilder? createGoal) =>
      _$this._createGoal = createGoal;

  GCreateGoalDataBuilder() {
    GCreateGoalData._initializeBuilder(this);
  }

  GCreateGoalDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _createGoal = $v.createGoal.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateGoalData other) {
    _$v = other as _$GCreateGoalData;
  }

  @override
  void update(void Function(GCreateGoalDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateGoalData build() => _build();

  _$GCreateGoalData _build() {
    _$GCreateGoalData _$result;
    try {
      _$result = _$v ??
          _$GCreateGoalData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCreateGoalData', 'G__typename'),
            createGoal: createGoal.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createGoal';
        createGoal.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateGoalData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateGoalData_createGoal extends GCreateGoalData_createGoal {
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

  factory _$GCreateGoalData_createGoal(
          [void Function(GCreateGoalData_createGoalBuilder)? updates]) =>
      (GCreateGoalData_createGoalBuilder()..update(updates))._build();

  _$GCreateGoalData_createGoal._(
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
  GCreateGoalData_createGoal rebuild(
          void Function(GCreateGoalData_createGoalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateGoalData_createGoalBuilder toBuilder() =>
      GCreateGoalData_createGoalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateGoalData_createGoal &&
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
    return (newBuiltValueToStringHelper(r'GCreateGoalData_createGoal')
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

class GCreateGoalData_createGoalBuilder
    implements
        Builder<GCreateGoalData_createGoal, GCreateGoalData_createGoalBuilder> {
  _$GCreateGoalData_createGoal? _$v;

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

  GCreateGoalData_createGoalBuilder() {
    GCreateGoalData_createGoal._initializeBuilder(this);
  }

  GCreateGoalData_createGoalBuilder get _$this {
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
  void replace(GCreateGoalData_createGoal other) {
    _$v = other as _$GCreateGoalData_createGoal;
  }

  @override
  void update(void Function(GCreateGoalData_createGoalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateGoalData_createGoal build() => _build();

  _$GCreateGoalData_createGoal _build() {
    _$GCreateGoalData_createGoal _$result;
    try {
      _$result = _$v ??
          _$GCreateGoalData_createGoal._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCreateGoalData_createGoal', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GCreateGoalData_createGoal', 'id'),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GCreateGoalData_createGoal', 'title'),
            note: note,
            targetDate: _targetDate?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GCreateGoalData_createGoal', 'status'),
            userID: BuiltValueNullFieldError.checkNotNull(
                userID, r'GCreateGoalData_createGoal', 'userID'),
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
            r'GCreateGoalData_createGoal', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
