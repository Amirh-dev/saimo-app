// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_tasks.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetTasksData> _$gGetTasksDataSerializer =
    _$GGetTasksDataSerializer();
Serializer<GGetTasksData_getTasks> _$gGetTasksDataGetTasksSerializer =
    _$GGetTasksData_getTasksSerializer();
Serializer<GGetTasksData_getTasks_goal> _$gGetTasksDataGetTasksGoalSerializer =
    _$GGetTasksData_getTasks_goalSerializer();
Serializer<GGetTasksData_getTasks_tags> _$gGetTasksDataGetTasksTagsSerializer =
    _$GGetTasksData_getTasks_tagsSerializer();

class _$GGetTasksDataSerializer implements StructuredSerializer<GGetTasksData> {
  @override
  final Iterable<Type> types = const [GGetTasksData, _$GGetTasksData];
  @override
  final String wireName = 'GGetTasksData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetTasksData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'getTasks',
      serializers.serialize(object.getTasks,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GGetTasksData_getTasks)])),
    ];

    return result;
  }

  @override
  GGetTasksData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetTasksDataBuilder();

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
        case 'getTasks':
          result.getTasks.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GGetTasksData_getTasks)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetTasksData_getTasksSerializer
    implements StructuredSerializer<GGetTasksData_getTasks> {
  @override
  final Iterable<Type> types = const [
    GGetTasksData_getTasks,
    _$GGetTasksData_getTasks
  ];
  @override
  final String wireName = 'GGetTasksData_getTasks';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetTasksData_getTasks object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
      'type',
      serializers.serialize(object.type,
          specifiedType: const FullType(_i2.GTaskType)),
      'date',
      serializers.serialize(object.date,
          specifiedType: const FullType(_i2.GTime)),
      'hasReminder',
      serializers.serialize(object.hasReminder,
          specifiedType: const FullType(bool)),
      'elapsedSeconds',
      serializers.serialize(object.elapsedSeconds,
          specifiedType: const FullType(int)),
      'status',
      serializers.serialize(object.status,
          specifiedType: const FullType(_i2.GTaskStatus)),
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
    value = object.goal;
    if (value != null) {
      result
        ..add('goal')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(GGetTasksData_getTasks_goal)));
    }
    value = object.tags;
    if (value != null) {
      result
        ..add('tags')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(BuiltList,
                const [const FullType(GGetTasksData_getTasks_tags)])));
    }
    return result;
  }

  @override
  GGetTasksData_getTasks deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetTasksData_getTasksBuilder();

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
        case 'elapsedSeconds':
          result.elapsedSeconds = serializers.deserialize(value,
              specifiedType: const FullType(int))! as int;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskStatus))!
              as _i2.GTaskStatus;
          break;
        case 'goal':
          result.goal.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GGetTasksData_getTasks_goal))!
              as GGetTasksData_getTasks_goal);
          break;
        case 'tags':
          result.tags.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GGetTasksData_getTasks_tags)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetTasksData_getTasks_goalSerializer
    implements StructuredSerializer<GGetTasksData_getTasks_goal> {
  @override
  final Iterable<Type> types = const [
    GGetTasksData_getTasks_goal,
    _$GGetTasksData_getTasks_goal
  ];
  @override
  final String wireName = 'GGetTasksData_getTasks_goal';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetTasksData_getTasks_goal object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GGetTasksData_getTasks_goal deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetTasksData_getTasks_goalBuilder();

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
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetTasksData_getTasks_tagsSerializer
    implements StructuredSerializer<GGetTasksData_getTasks_tags> {
  @override
  final Iterable<Type> types = const [
    GGetTasksData_getTasks_tags,
    _$GGetTasksData_getTasks_tags
  ];
  @override
  final String wireName = 'GGetTasksData_getTasks_tags';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetTasksData_getTasks_tags object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GGetTasksData_getTasks_tags deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetTasksData_getTasks_tagsBuilder();

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
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetTasksData extends GGetTasksData {
  @override
  final String G__typename;
  @override
  final BuiltList<GGetTasksData_getTasks> getTasks;

  factory _$GGetTasksData([void Function(GGetTasksDataBuilder)? updates]) =>
      (GGetTasksDataBuilder()..update(updates))._build();

  _$GGetTasksData._({required this.G__typename, required this.getTasks})
      : super._();
  @override
  GGetTasksData rebuild(void Function(GGetTasksDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetTasksDataBuilder toBuilder() => GGetTasksDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetTasksData &&
        G__typename == other.G__typename &&
        getTasks == other.getTasks;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, getTasks.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetTasksData')
          ..add('G__typename', G__typename)
          ..add('getTasks', getTasks))
        .toString();
  }
}

class GGetTasksDataBuilder
    implements Builder<GGetTasksData, GGetTasksDataBuilder> {
  _$GGetTasksData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GGetTasksData_getTasks>? _getTasks;
  ListBuilder<GGetTasksData_getTasks> get getTasks =>
      _$this._getTasks ??= ListBuilder<GGetTasksData_getTasks>();
  set getTasks(ListBuilder<GGetTasksData_getTasks>? getTasks) =>
      _$this._getTasks = getTasks;

  GGetTasksDataBuilder() {
    GGetTasksData._initializeBuilder(this);
  }

  GGetTasksDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _getTasks = $v.getTasks.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetTasksData other) {
    _$v = other as _$GGetTasksData;
  }

  @override
  void update(void Function(GGetTasksDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetTasksData build() => _build();

  _$GGetTasksData _build() {
    _$GGetTasksData _$result;
    try {
      _$result = _$v ??
          _$GGetTasksData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetTasksData', 'G__typename'),
            getTasks: getTasks.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'getTasks';
        getTasks.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetTasksData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetTasksData_getTasks extends GGetTasksData_getTasks {
  @override
  final String G__typename;
  @override
  final String id;
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
  final bool hasReminder;
  @override
  final _i2.GTime? reminderTime;
  @override
  final String? recurringDays;
  @override
  final int elapsedSeconds;
  @override
  final _i2.GTaskStatus status;
  @override
  final GGetTasksData_getTasks_goal? goal;
  @override
  final BuiltList<GGetTasksData_getTasks_tags>? tags;

  factory _$GGetTasksData_getTasks(
          [void Function(GGetTasksData_getTasksBuilder)? updates]) =>
      (GGetTasksData_getTasksBuilder()..update(updates))._build();

  _$GGetTasksData_getTasks._(
      {required this.G__typename,
      required this.id,
      required this.title,
      this.shortDescription,
      this.note,
      required this.type,
      required this.date,
      this.durationM,
      required this.hasReminder,
      this.reminderTime,
      this.recurringDays,
      required this.elapsedSeconds,
      required this.status,
      this.goal,
      this.tags})
      : super._();
  @override
  GGetTasksData_getTasks rebuild(
          void Function(GGetTasksData_getTasksBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetTasksData_getTasksBuilder toBuilder() =>
      GGetTasksData_getTasksBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetTasksData_getTasks &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title &&
        shortDescription == other.shortDescription &&
        note == other.note &&
        type == other.type &&
        date == other.date &&
        durationM == other.durationM &&
        hasReminder == other.hasReminder &&
        reminderTime == other.reminderTime &&
        recurringDays == other.recurringDays &&
        elapsedSeconds == other.elapsedSeconds &&
        status == other.status &&
        goal == other.goal &&
        tags == other.tags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, shortDescription.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, durationM.hashCode);
    _$hash = $jc(_$hash, hasReminder.hashCode);
    _$hash = $jc(_$hash, reminderTime.hashCode);
    _$hash = $jc(_$hash, recurringDays.hashCode);
    _$hash = $jc(_$hash, elapsedSeconds.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, goal.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetTasksData_getTasks')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title)
          ..add('shortDescription', shortDescription)
          ..add('note', note)
          ..add('type', type)
          ..add('date', date)
          ..add('durationM', durationM)
          ..add('hasReminder', hasReminder)
          ..add('reminderTime', reminderTime)
          ..add('recurringDays', recurringDays)
          ..add('elapsedSeconds', elapsedSeconds)
          ..add('status', status)
          ..add('goal', goal)
          ..add('tags', tags))
        .toString();
  }
}

class GGetTasksData_getTasksBuilder
    implements Builder<GGetTasksData_getTasks, GGetTasksData_getTasksBuilder> {
  _$GGetTasksData_getTasks? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  int? _elapsedSeconds;
  int? get elapsedSeconds => _$this._elapsedSeconds;
  set elapsedSeconds(int? elapsedSeconds) =>
      _$this._elapsedSeconds = elapsedSeconds;

  _i2.GTaskStatus? _status;
  _i2.GTaskStatus? get status => _$this._status;
  set status(_i2.GTaskStatus? status) => _$this._status = status;

  GGetTasksData_getTasks_goalBuilder? _goal;
  GGetTasksData_getTasks_goalBuilder get goal =>
      _$this._goal ??= GGetTasksData_getTasks_goalBuilder();
  set goal(GGetTasksData_getTasks_goalBuilder? goal) => _$this._goal = goal;

  ListBuilder<GGetTasksData_getTasks_tags>? _tags;
  ListBuilder<GGetTasksData_getTasks_tags> get tags =>
      _$this._tags ??= ListBuilder<GGetTasksData_getTasks_tags>();
  set tags(ListBuilder<GGetTasksData_getTasks_tags>? tags) =>
      _$this._tags = tags;

  GGetTasksData_getTasksBuilder() {
    GGetTasksData_getTasks._initializeBuilder(this);
  }

  GGetTasksData_getTasksBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _shortDescription = $v.shortDescription;
      _note = $v.note;
      _type = $v.type;
      _date = $v.date.toBuilder();
      _durationM = $v.durationM;
      _hasReminder = $v.hasReminder;
      _reminderTime = $v.reminderTime?.toBuilder();
      _recurringDays = $v.recurringDays;
      _elapsedSeconds = $v.elapsedSeconds;
      _status = $v.status;
      _goal = $v.goal?.toBuilder();
      _tags = $v.tags?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetTasksData_getTasks other) {
    _$v = other as _$GGetTasksData_getTasks;
  }

  @override
  void update(void Function(GGetTasksData_getTasksBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetTasksData_getTasks build() => _build();

  _$GGetTasksData_getTasks _build() {
    _$GGetTasksData_getTasks _$result;
    try {
      _$result = _$v ??
          _$GGetTasksData_getTasks._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetTasksData_getTasks', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetTasksData_getTasks', 'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GGetTasksData_getTasks', 'title'),
            shortDescription: shortDescription,
            note: note,
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GGetTasksData_getTasks', 'type'),
            date: date.build(),
            durationM: durationM,
            hasReminder: BuiltValueNullFieldError.checkNotNull(
                hasReminder, r'GGetTasksData_getTasks', 'hasReminder'),
            reminderTime: _reminderTime?.build(),
            recurringDays: recurringDays,
            elapsedSeconds: BuiltValueNullFieldError.checkNotNull(
                elapsedSeconds, r'GGetTasksData_getTasks', 'elapsedSeconds'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GGetTasksData_getTasks', 'status'),
            goal: _goal?.build(),
            tags: _tags?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'date';
        date.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();

        _$failedField = 'goal';
        _goal?.build();
        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetTasksData_getTasks', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetTasksData_getTasks_goal extends GGetTasksData_getTasks_goal {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String title;

  factory _$GGetTasksData_getTasks_goal(
          [void Function(GGetTasksData_getTasks_goalBuilder)? updates]) =>
      (GGetTasksData_getTasks_goalBuilder()..update(updates))._build();

  _$GGetTasksData_getTasks_goal._(
      {required this.G__typename, required this.id, required this.title})
      : super._();
  @override
  GGetTasksData_getTasks_goal rebuild(
          void Function(GGetTasksData_getTasks_goalBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetTasksData_getTasks_goalBuilder toBuilder() =>
      GGetTasksData_getTasks_goalBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetTasksData_getTasks_goal &&
        G__typename == other.G__typename &&
        id == other.id &&
        title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetTasksData_getTasks_goal')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('title', title))
        .toString();
  }
}

class GGetTasksData_getTasks_goalBuilder
    implements
        Builder<GGetTasksData_getTasks_goal,
            GGetTasksData_getTasks_goalBuilder> {
  _$GGetTasksData_getTasks_goal? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GGetTasksData_getTasks_goalBuilder() {
    GGetTasksData_getTasks_goal._initializeBuilder(this);
  }

  GGetTasksData_getTasks_goalBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetTasksData_getTasks_goal other) {
    _$v = other as _$GGetTasksData_getTasks_goal;
  }

  @override
  void update(void Function(GGetTasksData_getTasks_goalBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetTasksData_getTasks_goal build() => _build();

  _$GGetTasksData_getTasks_goal _build() {
    final _$result = _$v ??
        _$GGetTasksData_getTasks_goal._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GGetTasksData_getTasks_goal', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GGetTasksData_getTasks_goal', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GGetTasksData_getTasks_goal', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GGetTasksData_getTasks_tags extends GGetTasksData_getTasks_tags {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;

  factory _$GGetTasksData_getTasks_tags(
          [void Function(GGetTasksData_getTasks_tagsBuilder)? updates]) =>
      (GGetTasksData_getTasks_tagsBuilder()..update(updates))._build();

  _$GGetTasksData_getTasks_tags._(
      {required this.G__typename, required this.id, required this.name})
      : super._();
  @override
  GGetTasksData_getTasks_tags rebuild(
          void Function(GGetTasksData_getTasks_tagsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetTasksData_getTasks_tagsBuilder toBuilder() =>
      GGetTasksData_getTasks_tagsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetTasksData_getTasks_tags &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetTasksData_getTasks_tags')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class GGetTasksData_getTasks_tagsBuilder
    implements
        Builder<GGetTasksData_getTasks_tags,
            GGetTasksData_getTasks_tagsBuilder> {
  _$GGetTasksData_getTasks_tags? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GGetTasksData_getTasks_tagsBuilder() {
    GGetTasksData_getTasks_tags._initializeBuilder(this);
  }

  GGetTasksData_getTasks_tagsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetTasksData_getTasks_tags other) {
    _$v = other as _$GGetTasksData_getTasks_tags;
  }

  @override
  void update(void Function(GGetTasksData_getTasks_tagsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetTasksData_getTasks_tags build() => _build();

  _$GGetTasksData_getTasks_tags _build() {
    final _$result = _$v ??
        _$GGetTasksData_getTasks_tags._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GGetTasksData_getTasks_tags', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GGetTasksData_getTasks_tags', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GGetTasksData_getTasks_tags', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
