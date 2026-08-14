// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_direct_chat.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GCreateDirectChatVars> _$gCreateDirectChatVarsSerializer =
    _$GCreateDirectChatVarsSerializer();

class _$GCreateDirectChatVarsSerializer
    implements StructuredSerializer<GCreateDirectChatVars> {
  @override
  final Iterable<Type> types = const [
    GCreateDirectChatVars,
    _$GCreateDirectChatVars
  ];
  @override
  final String wireName = 'GCreateDirectChatVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GCreateDirectChatVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GCreateDirectChatInput)),
    ];

    return result;
  }

  @override
  GCreateDirectChatVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GCreateDirectChatVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GCreateDirectChatInput))!
              as _i1.GCreateDirectChatInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GCreateDirectChatVars extends GCreateDirectChatVars {
  @override
  final _i1.GCreateDirectChatInput input;

  factory _$GCreateDirectChatVars(
          [void Function(GCreateDirectChatVarsBuilder)? updates]) =>
      (GCreateDirectChatVarsBuilder()..update(updates))._build();

  _$GCreateDirectChatVars._({required this.input}) : super._();
  @override
  GCreateDirectChatVars rebuild(
          void Function(GCreateDirectChatVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GCreateDirectChatVarsBuilder toBuilder() =>
      GCreateDirectChatVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GCreateDirectChatVars && input == other.input;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, input.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GCreateDirectChatVars')
          ..add('input', input))
        .toString();
  }
}

class GCreateDirectChatVarsBuilder
    implements Builder<GCreateDirectChatVars, GCreateDirectChatVarsBuilder> {
  _$GCreateDirectChatVars? _$v;

  _i1.GCreateDirectChatInputBuilder? _input;
  _i1.GCreateDirectChatInputBuilder get input =>
      _$this._input ??= _i1.GCreateDirectChatInputBuilder();
  set input(_i1.GCreateDirectChatInputBuilder? input) => _$this._input = input;

  GCreateDirectChatVarsBuilder();

  GCreateDirectChatVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GCreateDirectChatVars other) {
    _$v = other as _$GCreateDirectChatVars;
  }

  @override
  void update(void Function(GCreateDirectChatVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GCreateDirectChatVars build() => _build();

  _$GCreateDirectChatVars _build() {
    _$GCreateDirectChatVars _$result;
    try {
      _$result = _$v ??
          _$GCreateDirectChatVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GCreateDirectChatVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
