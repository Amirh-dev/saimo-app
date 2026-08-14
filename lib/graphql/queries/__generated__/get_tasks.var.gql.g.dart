// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_tasks.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetTasksVars> _$gGetTasksVarsSerializer =
    _$GGetTasksVarsSerializer();

class _$GGetTasksVarsSerializer implements StructuredSerializer<GGetTasksVars> {
  @override
  final Iterable<Type> types = const [GGetTasksVars, _$GGetTasksVars];
  @override
  final String wireName = 'GGetTasksVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetTasksVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTime)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(_i1.GTaskStatus)));
    }
    value = object.goalID;
    if (value != null) {
      result
        ..add('goalID')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.limit;
    if (value != null) {
      result
        ..add('limit')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.offset;
    if (value != null) {
      result
        ..add('offset')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    return result;
  }

  @override
  GGetTasksVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetTasksVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'date':
          result.date.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GTime))! as _i1.GTime);
          break;
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GTaskStatus))
              as _i1.GTaskStatus?;
          break;
        case 'goalID':
          result.goalID = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'limit':
          result.limit = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'offset':
          result.offset = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetTasksVars extends GGetTasksVars {
  @override
  final _i1.GTime? date;
  @override
  final _i1.GTaskStatus? status;
  @override
  final String? goalID;
  @override
  final int? limit;
  @override
  final int? offset;

  factory _$GGetTasksVars([void Function(GGetTasksVarsBuilder)? updates]) =>
      (GGetTasksVarsBuilder()..update(updates))._build();

  _$GGetTasksVars._(
      {this.date, this.status, this.goalID, this.limit, this.offset})
      : super._();
  @override
  GGetTasksVars rebuild(void Function(GGetTasksVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetTasksVarsBuilder toBuilder() => GGetTasksVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetTasksVars &&
        date == other.date &&
        status == other.status &&
        goalID == other.goalID &&
        limit == other.limit &&
        offset == other.offset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, goalID.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, offset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetTasksVars')
          ..add('date', date)
          ..add('status', status)
          ..add('goalID', goalID)
          ..add('limit', limit)
          ..add('offset', offset))
        .toString();
  }
}

class GGetTasksVarsBuilder
    implements Builder<GGetTasksVars, GGetTasksVarsBuilder> {
  _$GGetTasksVars? _$v;

  _i1.GTimeBuilder? _date;
  _i1.GTimeBuilder get date => _$this._date ??= _i1.GTimeBuilder();
  set date(_i1.GTimeBuilder? date) => _$this._date = date;

  _i1.GTaskStatus? _status;
  _i1.GTaskStatus? get status => _$this._status;
  set status(_i1.GTaskStatus? status) => _$this._status = status;

  String? _goalID;
  String? get goalID => _$this._goalID;
  set goalID(String? goalID) => _$this._goalID = goalID;

  int? _limit;
  int? get limit => _$this._limit;
  set limit(int? limit) => _$this._limit = limit;

  int? _offset;
  int? get offset => _$this._offset;
  set offset(int? offset) => _$this._offset = offset;

  GGetTasksVarsBuilder();

  GGetTasksVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date?.toBuilder();
      _status = $v.status;
      _goalID = $v.goalID;
      _limit = $v.limit;
      _offset = $v.offset;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetTasksVars other) {
    _$v = other as _$GGetTasksVars;
  }

  @override
  void update(void Function(GGetTasksVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetTasksVars build() => _build();

  _$GGetTasksVars _build() {
    _$GGetTasksVars _$result;
    try {
      _$result = _$v ??
          _$GGetTasksVars._(
            date: _date?.build(),
            status: status,
            goalID: goalID,
            limit: limit,
            offset: offset,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'date';
        _date?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetTasksVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
