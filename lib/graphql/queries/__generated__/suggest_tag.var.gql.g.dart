// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggest_tag.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSuggestTagsVars> _$gSuggestTagsVarsSerializer =
    _$GSuggestTagsVarsSerializer();

class _$GSuggestTagsVarsSerializer
    implements StructuredSerializer<GSuggestTagsVars> {
  @override
  final Iterable<Type> types = const [GSuggestTagsVars, _$GSuggestTagsVars];
  @override
  final String wireName = 'GSuggestTagsVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSuggestTagsVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'title',
      serializers.serialize(object.title,
          specifiedType: const FullType(String)),
    ];

    return result;
  }

  @override
  GSuggestTagsVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSuggestTagsVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GSuggestTagsVars extends GSuggestTagsVars {
  @override
  final String title;

  factory _$GSuggestTagsVars(
          [void Function(GSuggestTagsVarsBuilder)? updates]) =>
      (GSuggestTagsVarsBuilder()..update(updates))._build();

  _$GSuggestTagsVars._({required this.title}) : super._();
  @override
  GSuggestTagsVars rebuild(void Function(GSuggestTagsVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSuggestTagsVarsBuilder toBuilder() =>
      GSuggestTagsVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSuggestTagsVars && title == other.title;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GSuggestTagsVars')
          ..add('title', title))
        .toString();
  }
}

class GSuggestTagsVarsBuilder
    implements Builder<GSuggestTagsVars, GSuggestTagsVarsBuilder> {
  _$GSuggestTagsVars? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  GSuggestTagsVarsBuilder();

  GSuggestTagsVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSuggestTagsVars other) {
    _$v = other as _$GSuggestTagsVars;
  }

  @override
  void update(void Function(GSuggestTagsVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSuggestTagsVars build() => _build();

  _$GSuggestTagsVars _build() {
    final _$result = _$v ??
        _$GSuggestTagsVars._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'GSuggestTagsVars', 'title'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
