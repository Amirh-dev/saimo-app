// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_timed_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCompleteTimedTaskData> _$gCompleteTimedTaskDataSerializer =
    _$GCompleteTimedTaskDataSerializer();
Serializer<GCompleteTimedTaskData_completeTimedTask>
    _$gCompleteTimedTaskDataCompleteTimedTaskSerializer =
    _$GCompleteTimedTaskData_completeTimedTaskSerializer();

class _$GCompleteTimedTaskDataSerializer
    implements StructuredSerializer<GCompleteTimedTaskData> {
  @override
  final Iterable<Type> types = const [
    GCompleteTimedTaskData,
    _$GCompleteTimedTaskData
  ];
  @override
  final String wireName = 'GCompleteTimedTaskData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCompleteTimedTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'completeTimedTask',
      serializers.serialize(object.completeTimedTask,
          specifiedType:
              const FullType(GCompleteTimedTaskData_completeTimedTask)),
    ];

    return result;
  }

  @override
  GCompleteTimedTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTimedTaskDataBuilder();

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
        case 'completeTimedTask':
          result.completeTimedTask.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GCompleteTimedTaskData_completeTimedTask))!
              as GCompleteTimedTaskData_completeTimedTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GCompleteTimedTaskData_completeTimedTaskSerializer
    implements StructuredSerializer<GCompleteTimedTaskData_completeTimedTask> {
  @override
  final Iterable<Type> types = const [
    GCompleteTimedTaskData_completeTimedTask,
    _$GCompleteTimedTaskData_completeTimedTask
  ];
  @override
  final String wireName = 'GCompleteTimedTaskData_completeTimedTask';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCompleteTimedTaskData_completeTimedTask object,
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
      'type',
      serializers.serialize(object.type,
          specifiedType: const FullType(_i2.GTaskType)),
      'date',
      serializers.serialize(object.date,
          specifiedType: const FullType(_i2.GTime)),
      'elapsedSeconds',
      serializers.serialize(object.elapsedSeconds,
          specifiedType: const FullType(int)),
      'hasReminder',
      serializers.serialize(object.hasReminder,
          specifiedType: const FullType(bool)),
      'status',
      serializers.serialize(object.status,
          specifiedType: const FullType(_i2.GTaskStatus)),
      'userID',
      serializers.serialize(object.userID,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.shortDescription;
    if (value != null) {
      result
        ..add('shortDescription')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.note;
    if (value != null) {
      result
        ..add('note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.durationM;
    if (value != null) {
      result
        ..add('durationM')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.timerStartedAt;
    if (value != null) {
      result
        ..add('timerStartedAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.completedAt;
    if (value != null) {
      result
        ..add('completedAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.reminderTime;
    if (value != null) {
      result
        ..add('reminderTime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i2.GTime)));
    }
    value = object.recurringDays;
    if (value != null) {
      result
        ..add('recurringDays')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.goalID;
    if (value != null) {
      result
        ..add('goalID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.subjectTagID;
    if (value != null) {
      result
        ..add('subjectTagID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GCompleteTimedTaskData_completeTimedTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCompleteTimedTaskData_completeTimedTaskBuilder();

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
        case 'shortDescription':
          result.shortDescription = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'note':
          result.note = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTaskType))! as _i2.GTaskType;
          break;
        case 'date':
          result.date.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'durationM':
          result.durationM = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'elapsedSeconds':
          result.elapsedSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'timerStartedAt':
          result.timerStartedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'completedAt':
          result.completedAt.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'hasReminder':
          result.hasReminder = serializers.deserialize(value,
              specifiedType: const FullType(bool))! as bool;
          break;
        case 'reminderTime':
          result.reminderTime.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTime))! as _i2.GTime);
          break;
        case 'recurringDays':
          result.recurringDays = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskStatus))!
              as _i2.GTaskStatus;
          break;
        case 'userID':
          result.userID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'goalID':
          result.goalID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'subjectTagID':
          result.subjectTagID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$GCompleteTimedTaskData extends GCompleteTimedTaskData {
  @override
  final String G__typename;
  @override
  final GCompleteTimedTaskData_completeTimedTask completeTimedTask;

  factory _$GCompleteTimedTaskData(
          [void Function(GCompleteTimedTaskDataBuilder)? updates]) =>
      (GCompleteTimedTaskDataBuilder()..update(updates))._build();

  _$GCompleteTimedTaskData._(
      {required this.G__typename, required this.completeTimedTask})
      : super._();
  @override
  GCompleteTimedTaskData rebuild(
          void Function(GCompleteTimedTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTimedTaskDataBuilder toBuilder() =>
      GCompleteTimedTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTimedTaskData &&
        G__typename == other.G__typename &&
        completeTimedTask == other.completeTimedTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, completeTimedTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCompleteTimedTaskData')
          ..add('G__typename', G__typename)
          ..add('completeTimedTask', completeTimedTask))
        .toString();
  }
}

class GCompleteTimedTaskDataBuilder
    implements Builder<GCompleteTimedTaskData, GCompleteTimedTaskDataBuilder> {
  _$GCompleteTimedTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCompleteTimedTaskData_completeTimedTaskBuilder? _completeTimedTask;
  GCompleteTimedTaskData_completeTimedTaskBuilder get completeTimedTask =>
      _$this._completeTimedTask ??=
          GCompleteTimedTaskData_completeTimedTaskBuilder();
  set completeTimedTask(
          GCompleteTimedTaskData_completeTimedTaskBuilder? completeTimedTask) =>
      _$this._completeTimedTask = completeTimedTask;

  GCompleteTimedTaskDataBuilder() {
    GCompleteTimedTaskData._initializeBuilder(this);
  }

  GCompleteTimedTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _completeTimedTask = $v.completeTimedTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCompleteTimedTaskData other) {
    _$v = other as _$GCompleteTimedTaskData;
  }

  @override
  void update(void Function(GCompleteTimedTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTimedTaskData build() => _build();

  _$GCompleteTimedTaskData _build() {
    _$GCompleteTimedTaskData _$result;
    try {
      _$result = _$v ??
          _$GCompleteTimedTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCompleteTimedTaskData', 'G__typename'),
            completeTimedTask: completeTimedTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'completeTimedTask';
        completeTimedTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCompleteTimedTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCompleteTimedTaskData_completeTimedTask
    extends GCompleteTimedTaskData_completeTimedTask {
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
  final String? shortDescription;
  @override
  final String? note;
  @override
  final _i2.GTaskType type;
  @override
  final _i2.GTime date;
  @override
  final int? durationM;
  @override
  final int elapsedSeconds;
  @override
  final _i2.GTime? timerStartedAt;
  @override
  final _i2.GTime? completedAt;
  @override
  final bool hasReminder;
  @override
  final _i2.GTime? reminderTime;
  @override
  final String? recurringDays;
  @override
  final _i2.GTaskStatus status;
  @override
  final String userID;
  @override
  final String? goalID;
  @override
  final String? subjectTagID;

  factory _$GCompleteTimedTaskData_completeTimedTask(
          [void Function(GCompleteTimedTaskData_completeTimedTaskBuilder)?
              updates]) =>
      (GCompleteTimedTaskData_completeTimedTaskBuilder()..update(updates))
          ._build();

  _$GCompleteTimedTaskData_completeTimedTask._(
      {required this.G__typename,
      required this.id,
      required this.createdAt,
      required this.updatedAt,
      required this.title,
      this.shortDescription,
      this.note,
      required this.type,
      required this.date,
      this.durationM,
      required this.elapsedSeconds,
      this.timerStartedAt,
      this.completedAt,
      required this.hasReminder,
      this.reminderTime,
      this.recurringDays,
      required this.status,
      required this.userID,
      this.goalID,
      this.subjectTagID})
      : super._();
  @override
  GCompleteTimedTaskData_completeTimedTask rebuild(
          void Function(GCompleteTimedTaskData_completeTimedTaskBuilder)
              updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCompleteTimedTaskData_completeTimedTaskBuilder toBuilder() =>
      GCompleteTimedTaskData_completeTimedTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCompleteTimedTaskData_completeTimedTask &&
        G__typename == other.G__typename &&
        id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        title == other.title &&
        shortDescription == other.shortDescription &&
        note == other.note &&
        type == other.type &&
        date == other.date &&
        durationM == other.durationM &&
        elapsedSeconds == other.elapsedSeconds &&
        timerStartedAt == other.timerStartedAt &&
        completedAt == other.completedAt &&
        hasReminder == other.hasReminder &&
        reminderTime == other.reminderTime &&
        recurringDays == other.recurringDays &&
        status == other.status &&
        userID == other.userID &&
        goalID == other.goalID &&
        subjectTagID == other.subjectTagID;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, shortDescription.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, durationM.hashCode);
    _$hash = $jc(_$hash, elapsedSeconds.hashCode);
    _$hash = $jc(_$hash, timerStartedAt.hashCode);
    _$hash = $jc(_$hash, completedAt.hashCode);
    _$hash = $jc(_$hash, hasReminder.hashCode);
    _$hash = $jc(_$hash, reminderTime.hashCode);
    _$hash = $jc(_$hash, recurringDays.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, userID.hashCode);
    _$hash = $jc(_$hash, goalID.hashCode);
    _$hash = $jc(_$hash, subjectTagID.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
            r'GCompleteTimedTaskData_completeTimedTask')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('title', title)
          ..add('shortDescription', shortDescription)
          ..add('note', note)
          ..add('type', type)
          ..add('date', date)
          ..add('durationM', durationM)
          ..add('elapsedSeconds', elapsedSeconds)
          ..add('timerStartedAt', timerStartedAt)
          ..add('completedAt', completedAt)
          ..add('hasReminder', hasReminder)
          ..add('reminderTime', reminderTime)
          ..add('recurringDays', recurringDays)
          ..add('status', status)
          ..add('userID', userID)
          ..add('goalID', goalID)
          ..add('subjectTagID', subjectTagID))
        .toString();
  }
}

class GCompleteTimedTaskData_completeTimedTaskBuilder
    implements
        Builder<GCompleteTimedTaskData_completeTimedTask,
            GCompleteTimedTaskData_completeTimedTaskBuilder> {
  _$GCompleteTimedTaskData_completeTimedTask? _$v;

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

  String? _shortDescription;
  String? get shortDescription => _$this._shortDescription;
  set shortDescription(String? shortDescription) =>
      _$this._shortDescription = shortDescription;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  _i2.GTaskType? _type;
  _i2.GTaskType? get type => _$this._type;
  set type(_i2.GTaskType? type) => _$this._type = type;

  _i2.GTimeBuilder? _date;
  _i2.GTimeBuilder get date => _$this._date ??= _i2.GTimeBuilder();
  set date(_i2.GTimeBuilder? date) => _$this._date = date;

  int? _durationM;
  int? get durationM => _$this._durationM;
  set durationM(int? durationM) => _$this._durationM = durationM;

  int? _elapsedSeconds;
  int? get elapsedSeconds => _$this._elapsedSeconds;
  set elapsedSeconds(int? elapsedSeconds) =>
      _$this._elapsedSeconds = elapsedSeconds;

  _i2.GTimeBuilder? _timerStartedAt;
  _i2.GTimeBuilder get timerStartedAt =>
      _$this._timerStartedAt ??= _i2.GTimeBuilder();
  set timerStartedAt(_i2.GTimeBuilder? timerStartedAt) =>
      _$this._timerStartedAt = timerStartedAt;

  _i2.GTimeBuilder? _completedAt;
  _i2.GTimeBuilder get completedAt =>
      _$this._completedAt ??= _i2.GTimeBuilder();
  set completedAt(_i2.GTimeBuilder? completedAt) =>
      _$this._completedAt = completedAt;

  bool? _hasReminder;
  bool? get hasReminder => _$this._hasReminder;
  set hasReminder(bool? hasReminder) => _$this._hasReminder = hasReminder;

  _i2.GTimeBuilder? _reminderTime;
  _i2.GTimeBuilder get reminderTime =>
      _$this._reminderTime ??= _i2.GTimeBuilder();
  set reminderTime(_i2.GTimeBuilder? reminderTime) =>
      _$this._reminderTime = reminderTime;

  String? _recurringDays;
  String? get recurringDays => _$this._recurringDays;
  set recurringDays(String? recurringDays) =>
      _$this._recurringDays = recurringDays;

  _i2.GTaskStatus? _status;
  _i2.GTaskStatus? get status => _$this._status;
  set status(_i2.GTaskStatus? status) => _$this._status = status;

  String? _userID;
  String? get userID => _$this._userID;
  set userID(String? userID) => _$this._userID = userID;

  String? _goalID;
  String? get goalID => _$this._goalID;
  set goalID(String? goalID) => _$this._goalID = goalID;

  String? _subjectTagID;
  String? get subjectTagID => _$this._subjectTagID;
  set subjectTagID(String? subjectTagID) => _$this._subjectTagID = subjectTagID;

  GCompleteTimedTaskData_completeTimedTaskBuilder() {
    GCompleteTimedTaskData_completeTimedTask._initializeBuilder(this);
  }

  GCompleteTimedTaskData_completeTimedTaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _createdAt = $v.createdAt.toBuilder();
      _updatedAt = $v.updatedAt.toBuilder();
      _title = $v.title;
      _shortDescription = $v.shortDescription;
      _note = $v.note;
      _type = $v.type;
      _date = $v.date.toBuilder();
      _durationM = $v.durationM;
      _elapsedSeconds = $v.elapsedSeconds;
      _timerStartedAt = $v.timerStartedAt?.toBuilder();
      _completedAt = $v.completedAt?.toBuilder();
      _hasReminder = $v.hasReminder;
      _reminderTime = $v.reminderTime?.toBuilder();
      _recurringDays = $v.recurringDays;
      _status = $v.status;
      _userID = $v.userID;
      _goalID = $v.goalID;
      _subjectTagID = $v.subjectTagID;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCompleteTimedTaskData_completeTimedTask other) {
    _$v = other as _$GCompleteTimedTaskData_completeTimedTask;
  }

  @override
  void update(
      void Function(GCompleteTimedTaskData_completeTimedTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCompleteTimedTaskData_completeTimedTask build() => _build();

  _$GCompleteTimedTaskData_completeTimedTask _build() {
    _$GCompleteTimedTaskData_completeTimedTask _$result;
    try {
      _$result = _$v ??
          _$GCompleteTimedTaskData_completeTimedTask._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GCompleteTimedTaskData_completeTimedTask', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GCompleteTimedTaskData_completeTimedTask', 'id'),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GCompleteTimedTaskData_completeTimedTask', 'title'),
            shortDescription: shortDescription,
            note: note,
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GCompleteTimedTaskData_completeTimedTask', 'type'),
            date: date.build(),
            durationM: durationM,
            elapsedSeconds: BuiltValueNullFieldError.checkNotNull(
                elapsedSeconds,
                r'GCompleteTimedTaskData_completeTimedTask',
                'elapsedSeconds'),
            timerStartedAt: _timerStartedAt?.build(),
            completedAt: _completedAt?.build(),
            hasReminder: BuiltValueNullFieldError.checkNotNull(hasReminder,
                r'GCompleteTimedTaskData_completeTimedTask', 'hasReminder'),
            reminderTime: _reminderTime?.build(),
            recurringDays: recurringDays,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GCompleteTimedTaskData_completeTimedTask', 'status'),
            userID: BuiltValueNullFieldError.checkNotNull(
                userID, r'GCompleteTimedTaskData_completeTimedTask', 'userID'),
            goalID: goalID,
            subjectTagID: subjectTagID,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createdAt';
        createdAt.build();
        _$failedField = 'updatedAt';
        updatedAt.build();

        _$failedField = 'date';
        date.build();

        _$failedField = 'timerStartedAt';
        _timerStartedAt?.build();
        _$failedField = 'completedAt';
        _completedAt?.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCompleteTimedTaskData_completeTimedTask',
            _$failedField,
            e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
