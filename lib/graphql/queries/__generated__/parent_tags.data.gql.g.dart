// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'parent_tags.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GParentTagsData> _$gParentTagsDataSerializer =
    _$GParentTagsDataSerializer();
Serializer<GParentTagsData_parentTags> _$gParentTagsDataParentTagsSerializer =
    _$GParentTagsData_parentTagsSerializer();

class _$GParentTagsDataSerializer
    implements StructuredSerializer<GParentTagsData> {
  @override
  final Iterable<Type> types = const [GParentTagsData, _$GParentTagsData];
  @override
  final String wireName = 'GParentTagsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GParentTagsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'parentTags',
      serializers.serialize(object.parentTags,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GParentTagsData_parentTags)])),
    ];

    return result;
  }

  @override
  GParentTagsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GParentTagsDataBuilder();

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
        case 'parentTags':
          result.parentTags.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GParentTagsData_parentTags)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GParentTagsData_parentTagsSerializer
    implements StructuredSerializer<GParentTagsData_parentTags> {
  @override
  final Iterable<Type> types = const [
    GParentTagsData_parentTags,
    _$GParentTagsData_parentTags
  ];
  @override
  final String wireName = 'GParentTagsData_parentTags';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GParentTagsData_parentTags object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'name',
      serializers.serialize(object.name, specifiedType: const FullType(String)),
      'kind',
      serializers.serialize(object.kind,
          specifiedType: const FullType(_i2.GTagKind)),
      'moderationStatus',
      serializers.serialize(object.moderationStatus,
          specifiedType: const FullType(_i2.GTagModerationStatus)),
    ];

    return result;
  }

  @override
  GParentTagsData_parentTags deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GParentTagsData_parentTagsBuilder();

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
        case 'kind':
          result.kind = serializers.deserialize(value,
              specifiedType: const FullType(_i2.GTagKind))! as _i2.GTagKind;
          break;
        case 'moderationStatus':
          result.moderationStatus = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GTagModerationStatus))!
              as _i2.GTagModerationStatus;
          break;
      }
    }

    return result.build();
  }
}

class _$GParentTagsData extends GParentTagsData {
  @override
  final String G__typename;
  @override
  final BuiltList<GParentTagsData_parentTags> parentTags;

  factory _$GParentTagsData([void Function(GParentTagsDataBuilder)? updates]) =>
      (GParentTagsDataBuilder()..update(updates))._build();

  _$GParentTagsData._({required this.G__typename, required this.parentTags})
      : super._();
  @override
  GParentTagsData rebuild(void Function(GParentTagsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GParentTagsDataBuilder toBuilder() => GParentTagsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GParentTagsData &&
        G__typename == other.G__typename &&
        parentTags == other.parentTags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, parentTags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GParentTagsData')
          ..add('G__typename', G__typename)
          ..add('parentTags', parentTags))
        .toString();
  }
}

class GParentTagsDataBuilder
    implements Builder<GParentTagsData, GParentTagsDataBuilder> {
  _$GParentTagsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GParentTagsData_parentTags>? _parentTags;
  ListBuilder<GParentTagsData_parentTags> get parentTags =>
      _$this._parentTags ??= ListBuilder<GParentTagsData_parentTags>();
  set parentTags(ListBuilder<GParentTagsData_parentTags>? parentTags) =>
      _$this._parentTags = parentTags;

  GParentTagsDataBuilder() {
    GParentTagsData._initializeBuilder(this);
  }

  GParentTagsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _parentTags = $v.parentTags.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GParentTagsData other) {
    _$v = other as _$GParentTagsData;
  }

  @override
  void update(void Function(GParentTagsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GParentTagsData build() => _build();

  _$GParentTagsData _build() {
    _$GParentTagsData _$result;
    try {
      _$result = _$v ??
          _$GParentTagsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GParentTagsData', 'G__typename'),
            parentTags: parentTags.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'parentTags';
        parentTags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GParentTagsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GParentTagsData_parentTags extends GParentTagsData_parentTags {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String name;
  @override
  final _i2.GTagKind kind;
  @override
  final _i2.GTagModerationStatus moderationStatus;

  factory _$GParentTagsData_parentTags(
          [void Function(GParentTagsData_parentTagsBuilder)? updates]) =>
      (GParentTagsData_parentTagsBuilder()..update(updates))._build();

  _$GParentTagsData_parentTags._(
      {required this.G__typename,
      required this.id,
      required this.name,
      required this.kind,
      required this.moderationStatus})
      : super._();
  @override
  GParentTagsData_parentTags rebuild(
          void Function(GParentTagsData_parentTagsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GParentTagsData_parentTagsBuilder toBuilder() =>
      GParentTagsData_parentTagsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GParentTagsData_parentTags &&
        G__typename == other.G__typename &&
        id == other.id &&
        name == other.name &&
        kind == other.kind &&
        moderationStatus == other.moderationStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, kind.hashCode);
    _$hash = $jc(_$hash, moderationStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GParentTagsData_parentTags')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('name', name)
          ..add('kind', kind)
          ..add('moderationStatus', moderationStatus))
        .toString();
  }
}

class GParentTagsData_parentTagsBuilder
    implements
        Builder<GParentTagsData_parentTags, GParentTagsData_parentTagsBuilder> {
  _$GParentTagsData_parentTags? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  _i2.GTagKind? _kind;
  _i2.GTagKind? get kind => _$this._kind;
  set kind(_i2.GTagKind? kind) => _$this._kind = kind;

  _i2.GTagModerationStatus? _moderationStatus;
  _i2.GTagModerationStatus? get moderationStatus => _$this._moderationStatus;
  set moderationStatus(_i2.GTagModerationStatus? moderationStatus) =>
      _$this._moderationStatus = moderationStatus;

  GParentTagsData_parentTagsBuilder() {
    GParentTagsData_parentTags._initializeBuilder(this);
  }

  GParentTagsData_parentTagsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _name = $v.name;
      _kind = $v.kind;
      _moderationStatus = $v.moderationStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GParentTagsData_parentTags other) {
    _$v = other as _$GParentTagsData_parentTags;
  }

  @override
  void update(void Function(GParentTagsData_parentTagsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GParentTagsData_parentTags build() => _build();

  _$GParentTagsData_parentTags _build() {
    final _$result = _$v ??
        _$GParentTagsData_parentTags._(
          G__typename: BuiltValueNullFieldError.checkNotNull(
              G__typename, r'GParentTagsData_parentTags', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GParentTagsData_parentTags', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'GParentTagsData_parentTags', 'name'),
          kind: BuiltValueNullFieldError.checkNotNull(
              kind, r'GParentTagsData_parentTags', 'kind'),
          moderationStatus: BuiltValueNullFieldError.checkNotNull(
              moderationStatus,
              r'GParentTagsData_parentTags',
              'moderationStatus'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
