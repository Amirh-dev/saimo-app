// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggest_tag.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSuggestTagsData> _$gSuggestTagsDataSerializer =
    _$GSuggestTagsDataSerializer();

class _$GSuggestTagsDataSerializer
    implements StructuredSerializer<GSuggestTagsData> {
  @override
  final Iterable<Type> types = const [GSuggestTagsData, _$GSuggestTagsData];
  @override
  final String wireName = 'GSuggestTagsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSuggestTagsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'suggestTags',
      serializers.serialize(object.suggestTags,
          specifiedType:
              const FullType(BuiltList, const [const FullType(String)])),
    ];

    return result;
  }

  @override
  GSuggestTagsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSuggestTagsDataBuilder();

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
        case 'suggestTags':
          result.suggestTags.replace(serializers.deserialize(value,
                  specifiedType: const FullType(
                      BuiltList, const [const FullType(String)]))!
              as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GSuggestTagsData extends GSuggestTagsData {
  @override
  final String G__typename;
  @override
  final BuiltList<String> suggestTags;

  factory _$GSuggestTagsData(
          [void Function(GSuggestTagsDataBuilder)? updates]) =>
      (GSuggestTagsDataBuilder()..update(updates))._build();

  _$GSuggestTagsData._({required this.G__typename, required this.suggestTags})
      : super._();
  @override
  GSuggestTagsData rebuild(void Function(GSuggestTagsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSuggestTagsDataBuilder toBuilder() =>
      GSuggestTagsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSuggestTagsData &&
        G__typename == other.G__typename &&
        suggestTags == other.suggestTags;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, suggestTags.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSuggestTagsData')
          ..add('G__typename', G__typename)
          ..add('suggestTags', suggestTags))
        .toString();
  }
}

class GSuggestTagsDataBuilder
    implements Builder<GSuggestTagsData, GSuggestTagsDataBuilder> {
  _$GSuggestTagsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<String>? _suggestTags;
  ListBuilder<String> get suggestTags =>
      _$this._suggestTags ??= ListBuilder<String>();
  set suggestTags(ListBuilder<String>? suggestTags) =>
      _$this._suggestTags = suggestTags;

  GSuggestTagsDataBuilder() {
    GSuggestTagsData._initializeBuilder(this);
  }

  GSuggestTagsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _suggestTags = $v.suggestTags.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSuggestTagsData other) {
    _$v = other as _$GSuggestTagsData;
  }

  @override
  void update(void Function(GSuggestTagsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSuggestTagsData build() => _build();

  _$GSuggestTagsData _build() {
    _$GSuggestTagsData _$result;
    try {
      _$result = _$v ??
          _$GSuggestTagsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GSuggestTagsData', 'G__typename'),
            suggestTags: suggestTags.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'suggestTags';
        suggestTags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSuggestTagsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
