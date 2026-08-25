// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_goals.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetGoalsData> _$gGetGoalsDataSerializer =
    _$GGetGoalsDataSerializer();
Serializer<GGetGoalsData_getGoals> _$gGetGoalsDataGetGoalsSerializer =
    _$GGetGoalsData_getGoalsSerializer();

class _$GGetGoalsDataSerializer implements StructuredSerializer<GGetGoalsData> {
  @override
  final Iterable<Type> types = const [GGetGoalsData, _$GGetGoalsData];
  @override
  final String wireName = 'GGetGoalsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetGoalsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'getGoals',
      serializers.serialize(object.getGoals,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GGetGoalsData_getGoals)])),
    ];

    return result;
  }

  @override
  GGetGoalsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetGoalsDataBuilder();

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
        case 'getGoals':
          result.getGoals.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GGetGoalsData_getGoals)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetGoalsData_getGoalsSerializer
    implements StructuredSerializer<GGetGoalsData_getGoals> {
  @override
  final Iterable<Type> types = const [
    GGetGoalsData_getGoals,
    _$GGetGoalsData_getGoals
  ];
  @override
  final String wireName = 'GGetGoalsData_getGoals';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetGoalsData_getGoals object,
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
  GGetGoalsData_getGoals deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetGoalsData_getGoalsBuilder();

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

class _$GGetGoalsData extends GGetGoalsData {
  @override
  final String G__typename;
  @override
  final BuiltList<GGetGoalsData_getGoals> getGoals;

  factory _$GGetGoalsData([void Function(GGetGoalsDataBuilder)? updates]) =>
      (GGetGoalsDataBuilder()..update(updates))._build();

  _$GGetGoalsData._({required this.G__typename, required this.getGoals})
      : super._();
  @override
  GGetGoalsData rebuild(void Function(GGetGoalsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetGoalsDataBuilder toBuilder() => GGetGoalsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetGoalsData &&
        G__typename == other.G__typename &&
        getGoals == other.getGoals;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, getGoals.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetGoalsData')
          ..add('G__typename', G__typename)
          ..add('getGoals', getGoals))
        .toString();
  }
}

class GGetGoalsDataBuilder
    implements Builder<GGetGoalsData, GGetGoalsDataBuilder> {
  _$GGetGoalsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GGetGoalsData_getGoals>? _getGoals;
  ListBuilder<GGetGoalsData_getGoals> get getGoals =>
      _$this._getGoals ??= ListBuilder<GGetGoalsData_getGoals>();
  set getGoals(ListBuilder<GGetGoalsData_getGoals>? getGoals) =>
      _$this._getGoals = getGoals;

  GGetGoalsDataBuilder() {
    GGetGoalsData._initializeBuilder(this);
  }

  GGetGoalsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _getGoals = $v.getGoals.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetGoalsData other) {
    _$v = other as _$GGetGoalsData;
  }

  @override
  void update(void Function(GGetGoalsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetGoalsData build() => _build();

  _$GGetGoalsData _build() {
    _$GGetGoalsData _$result;
    try {
      _$result = _$v ??
          _$GGetGoalsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetGoalsData', 'G__typename'),
            getGoals: getGoals.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'getGoals';
        getGoals.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetGoalsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetGoalsData_getGoals extends GGetGoalsData_getGoals {
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

  factory _$GGetGoalsData_getGoals(
          [void Function(GGetGoalsData_getGoalsBuilder)? updates]) =>
      (GGetGoalsData_getGoalsBuilder()..update(updates))._build();

  _$GGetGoalsData_getGoals._(
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
  GGetGoalsData_getGoals rebuild(
          void Function(GGetGoalsData_getGoalsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetGoalsData_getGoalsBuilder toBuilder() =>
      GGetGoalsData_getGoalsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetGoalsData_getGoals &&
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
    return (newBuiltValueToStringHelper(r'GGetGoalsData_getGoals')
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

class GGetGoalsData_getGoalsBuilder
    implements Builder<GGetGoalsData_getGoals, GGetGoalsData_getGoalsBuilder> {
  _$GGetGoalsData_getGoals? _$v;

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

  GGetGoalsData_getGoalsBuilder() {
    GGetGoalsData_getGoals._initializeBuilder(this);
  }

  GGetGoalsData_getGoalsBuilder get _$this {
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
  void replace(GGetGoalsData_getGoals other) {
    _$v = other as _$GGetGoalsData_getGoals;
  }

  @override
  void update(void Function(GGetGoalsData_getGoalsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetGoalsData_getGoals build() => _build();

  _$GGetGoalsData_getGoals _build() {
    _$GGetGoalsData_getGoals _$result;
    try {
      _$result = _$v ??
          _$GGetGoalsData_getGoals._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetGoalsData_getGoals', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetGoalsData_getGoals', 'id'),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GGetGoalsData_getGoals', 'title'),
            note: note,
            targetDate: _targetDate?.build(),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GGetGoalsData_getGoals', 'status'),
            userID: BuiltValueNullFieldError.checkNotNull(
                userID, r'GGetGoalsData_getGoals', 'userID'),
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
            r'GGetGoalsData_getGoals', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
