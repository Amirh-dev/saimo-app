// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pause_timed_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GPauseTimedTaskData> _$gPauseTimedTaskDataSerializer =
    _$GPauseTimedTaskDataSerializer();
Serializer<GPauseTimedTaskData_pauseTimedTask>
    _$gPauseTimedTaskDataPauseTimedTaskSerializer =
    _$GPauseTimedTaskData_pauseTimedTaskSerializer();

class _$GPauseTimedTaskDataSerializer
    implements StructuredSerializer<GPauseTimedTaskData> {
  @override
  final Iterable<Type> types = const [
    GPauseTimedTaskData,
    _$GPauseTimedTaskData
  ];
  @override
  final String wireName = 'GPauseTimedTaskData';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPauseTimedTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'pauseTimedTask',
      serializers.serialize(object.pauseTimedTask,
          specifiedType: const FullType(GPauseTimedTaskData_pauseTimedTask)),
    ];

    return result;
  }

  @override
  GPauseTimedTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPauseTimedTaskDataBuilder();

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
        case 'pauseTimedTask':
          result.pauseTimedTask.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GPauseTimedTaskData_pauseTimedTask))!
              as GPauseTimedTaskData_pauseTimedTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GPauseTimedTaskData_pauseTimedTaskSerializer
    implements StructuredSerializer<GPauseTimedTaskData_pauseTimedTask> {
  @override
  final Iterable<Type> types = const [
    GPauseTimedTaskData_pauseTimedTask,
    _$GPauseTimedTaskData_pauseTimedTask
  ];
  @override
  final String wireName = 'GPauseTimedTaskData_pauseTimedTask';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GPauseTimedTaskData_pauseTimedTask object,
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
  GPauseTimedTaskData_pauseTimedTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GPauseTimedTaskData_pauseTimedTaskBuilder();

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

class _$GPauseTimedTaskData extends GPauseTimedTaskData {
  @override
  final String G__typename;
  @override
  final GPauseTimedTaskData_pauseTimedTask pauseTimedTask;

  factory _$GPauseTimedTaskData(
          [void Function(GPauseTimedTaskDataBuilder)? updates]) =>
      (GPauseTimedTaskDataBuilder()..update(updates))._build();

  _$GPauseTimedTaskData._(
      {required this.G__typename, required this.pauseTimedTask})
      : super._();
  @override
  GPauseTimedTaskData rebuild(
          void Function(GPauseTimedTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPauseTimedTaskDataBuilder toBuilder() =>
      GPauseTimedTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPauseTimedTaskData &&
        G__typename == other.G__typename &&
        pauseTimedTask == other.pauseTimedTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, pauseTimedTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GPauseTimedTaskData')
          ..add('G__typename', G__typename)
          ..add('pauseTimedTask', pauseTimedTask))
        .toString();
  }
}

class GPauseTimedTaskDataBuilder
    implements Builder<GPauseTimedTaskData, GPauseTimedTaskDataBuilder> {
  _$GPauseTimedTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GPauseTimedTaskData_pauseTimedTaskBuilder? _pauseTimedTask;
  GPauseTimedTaskData_pauseTimedTaskBuilder get pauseTimedTask =>
      _$this._pauseTimedTask ??= GPauseTimedTaskData_pauseTimedTaskBuilder();
  set pauseTimedTask(
          GPauseTimedTaskData_pauseTimedTaskBuilder? pauseTimedTask) =>
      _$this._pauseTimedTask = pauseTimedTask;

  GPauseTimedTaskDataBuilder() {
    GPauseTimedTaskData._initializeBuilder(this);
  }

  GPauseTimedTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _pauseTimedTask = $v.pauseTimedTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GPauseTimedTaskData other) {
    _$v = other as _$GPauseTimedTaskData;
  }

  @override
  void update(void Function(GPauseTimedTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPauseTimedTaskData build() => _build();

  _$GPauseTimedTaskData _build() {
    _$GPauseTimedTaskData _$result;
    try {
      _$result = _$v ??
          _$GPauseTimedTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GPauseTimedTaskData', 'G__typename'),
            pauseTimedTask: pauseTimedTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'pauseTimedTask';
        pauseTimedTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GPauseTimedTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GPauseTimedTaskData_pauseTimedTask
    extends GPauseTimedTaskData_pauseTimedTask {
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

  factory _$GPauseTimedTaskData_pauseTimedTask(
          [void Function(GPauseTimedTaskData_pauseTimedTaskBuilder)?
              updates]) =>
      (GPauseTimedTaskData_pauseTimedTaskBuilder()..update(updates))._build();

  _$GPauseTimedTaskData_pauseTimedTask._(
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
  GPauseTimedTaskData_pauseTimedTask rebuild(
          void Function(GPauseTimedTaskData_pauseTimedTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GPauseTimedTaskData_pauseTimedTaskBuilder toBuilder() =>
      GPauseTimedTaskData_pauseTimedTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GPauseTimedTaskData_pauseTimedTask &&
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
    return (newBuiltValueToStringHelper(r'GPauseTimedTaskData_pauseTimedTask')
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

class GPauseTimedTaskData_pauseTimedTaskBuilder
    implements
        Builder<GPauseTimedTaskData_pauseTimedTask,
            GPauseTimedTaskData_pauseTimedTaskBuilder> {
  _$GPauseTimedTaskData_pauseTimedTask? _$v;

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

  GPauseTimedTaskData_pauseTimedTaskBuilder() {
    GPauseTimedTaskData_pauseTimedTask._initializeBuilder(this);
  }

  GPauseTimedTaskData_pauseTimedTaskBuilder get _$this {
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
  void replace(GPauseTimedTaskData_pauseTimedTask other) {
    _$v = other as _$GPauseTimedTaskData_pauseTimedTask;
  }

  @override
  void update(
      void Function(GPauseTimedTaskData_pauseTimedTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GPauseTimedTaskData_pauseTimedTask build() => _build();

  _$GPauseTimedTaskData_pauseTimedTask _build() {
    _$GPauseTimedTaskData_pauseTimedTask _$result;
    try {
      _$result = _$v ??
          _$GPauseTimedTaskData_pauseTimedTask._(
            G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
                r'GPauseTimedTaskData_pauseTimedTask', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GPauseTimedTaskData_pauseTimedTask', 'id'),
            createdAt: createdAt.build(),
            updatedAt: updatedAt.build(),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GPauseTimedTaskData_pauseTimedTask', 'title'),
            shortDescription: shortDescription,
            note: note,
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GPauseTimedTaskData_pauseTimedTask', 'type'),
            date: date.build(),
            durationM: durationM,
            elapsedSeconds: BuiltValueNullFieldError.checkNotNull(
                elapsedSeconds,
                r'GPauseTimedTaskData_pauseTimedTask',
                'elapsedSeconds'),
            timerStartedAt: _timerStartedAt?.build(),
            completedAt: _completedAt?.build(),
            hasReminder: BuiltValueNullFieldError.checkNotNull(hasReminder,
                r'GPauseTimedTaskData_pauseTimedTask', 'hasReminder'),
            reminderTime: _reminderTime?.build(),
            recurringDays: recurringDays,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GPauseTimedTaskData_pauseTimedTask', 'status'),
            userID: BuiltValueNullFieldError.checkNotNull(
                userID, r'GPauseTimedTaskData_pauseTimedTask', 'userID'),
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
            r'GPauseTimedTaskData_pauseTimedTask', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
