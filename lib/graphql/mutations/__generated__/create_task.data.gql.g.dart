// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_task.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateTaskData> _$gCreateTaskDataSerializer =
    _$GCreateTaskDataSerializer();
Serializer<GCreateTaskData_createTask> _$gCreateTaskDataCreateTaskSerializer =
    _$GCreateTaskData_createTaskSerializer();
Serializer<GCreateTaskData_createTask_tags>
    _$gCreateTaskDataCreateTaskTagsSerializer =
    _$GCreateTaskData_createTask_tagsSerializer();

class _$GCreateTaskDataSerializer
    implements StructuredSerializer<GCreateTaskData> {
  @override
  final Iterable<Type> types = const [GCreateTaskData, _$GCreateTaskData];
  @override
  final String wireName = 'GCreateTaskData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GCreateTaskData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'createTask',
      serializers.serialize(object.createTask,
          specifiedType: const FullType(GCreateTaskData_createTask)),
    ];

    return result;
  }

  @override
  GCreateTaskData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskDataBuilder();

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
        case 'createTask':
          result.createTask.replace(serializers.deserialize(value,
                  specifiedType: const FullType(GCreateTaskData_createTask))!
              as GCreateTaskData_createTask);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskData_createTaskSerializer
    implements StructuredSerializer<GCreateTaskData_createTask> {
  @override
  final Iterable<Type> types = const [
    GCreateTaskData_createTask,
    _$GCreateTaskData_createTask
  ];
  @override
  final String wireName = 'GCreateTaskData_createTask';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateTaskData_createTask object,
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
    value = object.tags;
    if (value != null) {
      result
        ..add('tags')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(BuiltList,
                const [const FullType(GCreateTaskData_createTask_tags)])));
    }
    return result;
  }

  @override
  GCreateTaskData_createTask deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskData_createTaskBuilder();

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
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTaskStatus))!
              as _i2.GTaskStatus;
          break;
        case 'tags':
          result.tags.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GCreateTaskData_createTask_tags)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateTaskData_createTask_tagsSerializer
    implements StructuredSerializer<GCreateTaskData_createTask_tags> {
  @override
  final Iterable<Type> types = const [
    GCreateTaskData_createTask_tags,
    _$GCreateTaskData_createTask_tags
  ];
  @override
  final String wireName = 'GCreateTaskData_createTask_tags';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateTaskData_createTask_tags object,
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
  GCreateTaskData_createTask_tags deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateTaskData_createTask_tagsBuilder();

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

class _$GCreateTaskData extends GCreateTaskData {
  @override
  final String G__typename;
  @override
  final GCreateTaskData_createTask createTask;

  factory _$GCreateTaskData([void Function(GCreateTaskDataBuilder)? updates]) =>
      (GCreateTaskDataBuilder()..update(updates))._build();

  _$GCreateTaskData._({required this.G__typename, required this.createTask})
      : super._();
  @override
  GCreateTaskData rebuild(void Function(GCreateTaskDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskDataBuilder toBuilder() => GCreateTaskDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskData &&
        G__typename == other.G__typename &&
        createTask == other.createTask;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, createTask.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskData')
          ..add('G__typename', G__typename)
          ..add('createTask', createTask))
        .toString();
  }
}

class GCreateTaskDataBuilder
    implements Builder<GCreateTaskData, GCreateTaskDataBuilder> {
  _$GCreateTaskData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  GCreateTaskData_createTaskBuilder? _createTask;
  GCreateTaskData_createTaskBuilder get createTask =>
      _$this._createTask ??= GCreateTaskData_createTaskBuilder();
  set createTask(GCreateTaskData_createTaskBuilder? createTask) =>
      _$this._createTask = createTask;

  GCreateTaskDataBuilder() {
    GCreateTaskData._initializeBuilder(this);
  }

  GCreateTaskDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _createTask = $v.createTask.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskData other) {
    _$v = other as _$GCreateTaskData;
  }

  @override
  void update(void Function(GCreateTaskDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskData build() => _build();

  _$GCreateTaskData _build() {
    _$GCreateTaskData _$result;
    try {
      _$result = _$v ??
          _$GCreateTaskData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCreateTaskData', 'G__typename'),
            createTask: createTask.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'createTask';
        createTask.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateTaskData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateTaskData_createTask extends GCreateTaskData_createTask {
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
  final _i2.GTaskStatus status;
  @override
  final BuiltList<GCreateTaskData_createTask_tags>? tags;

  factory _$GCreateTaskData_createTask(
          [void Function(GCreateTaskData_createTaskBuilder)? updates]) =>
      (GCreateTaskData_createTaskBuilder()..update(updates))._build();

  _$GCreateTaskData_createTask._(
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
      required this.status,
      this.tags})
      : super._();
  @override
  GCreateTaskData_createTask rebuild(
          void Function(GCreateTaskData_createTaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskData_createTaskBuilder toBuilder() =>
      GCreateTaskData_createTaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskData_createTask &&
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
        status == other.status &&
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
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateTaskData_createTask')
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
          ..add('status', status)
          ..add('tags', tags))
        .toString();
  }
}

class GCreateTaskData_createTaskBuilder
    implements
        Builder<GCreateTaskData_createTask, GCreateTaskData_createTaskBuilder> {
  _$GCreateTaskData_createTask? _$v;

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

  _i2.GTaskStatus? _status;
  _i2.GTaskStatus? get status => _$this._status;
  set status(_i2.GTaskStatus? status) => _$this._status = status;

  ListBuilder<GCreateTaskData_createTask_tags>? _tags;
  ListBuilder<GCreateTaskData_createTask_tags> get tags =>
      _$this._tags ??= ListBuilder<GCreateTaskData_createTask_tags>();
  set tags(ListBuilder<GCreateTaskData_createTask_tags>? tags) =>
      _$this._tags = tags;

  GCreateTaskData_createTaskBuilder() {
    GCreateTaskData_createTask._initializeBuilder(this);
  }

  GCreateTaskData_createTaskBuilder get _$this {
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
      _status = $v.status;
      _tags = $v.tags?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateTaskData_createTask other) {
    _$v = other as _$GCreateTaskData_createTask;
  }

  @override
  void update(void Function(GCreateTaskData_createTaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskData_createTask build() => _build();

  _$GCreateTaskData_createTask _build() {
    _$GCreateTaskData_createTask _$result;
    try {
      _$result = _$v ??
          _$GCreateTaskData_createTask._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GCreateTaskData_createTask', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GCreateTaskData_createTask', 'id'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'GCreateTaskData_createTask', 'title'),
            shortDescription: shortDescription,
            note: note,
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'GCreateTaskData_createTask', 'type'),
            date: date.build(),
            durationM: durationM,
            hasReminder: BuiltValueNullFieldError.checkNotNull(
                hasReminder, r'GCreateTaskData_createTask', 'hasReminder'),
            reminderTime: _reminderTime?.build(),
            recurringDays: recurringDays,
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GCreateTaskData_createTask', 'status'),
            tags: _tags?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'date';
        date.build();

        _$failedField = 'reminderTime';
        _reminderTime?.build();

        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateTaskData_createTask', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GCreateTaskData_createTask_tags
    extends GCreateTaskData_createTask_tags {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;

  factory _$GCreateTaskData_createTask_tags(
          [void Function(GCreateTaskData_createTask_tagsBuilder)? updates]) =>
      (GCreateTaskData_createTask_tagsBuilder()..update(updates))._build();

  _$GCreateTaskData_createTask_tags._(
      {required this.G__typename, required this.id, required this.name})
      : super._();
  @override
  GCreateTaskData_createTask_tags rebuild(
          void Function(GCreateTaskData_createTask_tagsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateTaskData_createTask_tagsBuilder toBuilder() =>
      GCreateTaskData_createTask_tagsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateTaskData_createTask_tags &&
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
    return (newBuiltValueToStringHelper(r'GCreateTaskData_createTask_tags')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name))
        .toString();
  }
}

class GCreateTaskData_createTask_tagsBuilder
    implements
        Builder<GCreateTaskData_createTask_tags,
            GCreateTaskData_createTask_tagsBuilder> {
  _$GCreateTaskData_createTask_tags? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  GCreateTaskData_createTask_tagsBuilder() {
    GCreateTaskData_createTask_tags._initializeBuilder(this);
  }

  GCreateTaskData_createTask_tagsBuilder get _$this {
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
  void replace(GCreateTaskData_createTask_tags other) {
    _$v = other as _$GCreateTaskData_createTask_tags;
  }

  @override
  void update(void Function(GCreateTaskData_createTask_tagsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateTaskData_createTask_tags build() => _build();

  _$GCreateTaskData_createTask_tags _build() {
    final _$result = _$v ??
        _$GCreateTaskData_createTask_tags._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GCreateTaskData_createTask_tags', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GCreateTaskData_createTask_tags', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GCreateTaskData_createTask_tags', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
