// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_message.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GSendMessageVars> _$gSendMessageVarsSerializer =
    _$GSendMessageVarsSerializer();

class _$GSendMessageVarsSerializer
    implements StructuredSerializer<GSendMessageVars> {
  @override
  final Iterable<Type> types = const [GSendMessageVars, _$GSendMessageVars];
  @override
  final String wireName = 'GSendMessageVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GSendMessageVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GSendMessageInput)),
    ];

    return result;
  }

  @override
  GSendMessageVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GSendMessageVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GSendMessageInput))!
              as _i1.GSendMessageInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GSendMessageVars extends GSendMessageVars {
  @override
  final _i1.GSendMessageInput input;

  factory _$GSendMessageVars(
          [void Function(GSendMessageVarsBuilder)? updates]) =>
      (GSendMessageVarsBuilder()..update(updates))._build();

  _$GSendMessageVars._({required this.input}) : super._();
  @override
  GSendMessageVars rebuild(void Function(GSendMessageVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GSendMessageVarsBuilder toBuilder() =>
      GSendMessageVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GSendMessageVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GSendMessageVars')
          ..add('input', input))
        .toString();
  }
}

class GSendMessageVarsBuilder
    implements Builder<GSendMessageVars, GSendMessageVarsBuilder> {
  _$GSendMessageVars? _$v;

  _i1.GSendMessageInputBuilder? _input;
  _i1.GSendMessageInputBuilder get input =>
      _$this._input ??= _i1.GSendMessageInputBuilder();
  set input(_i1.GSendMessageInputBuilder? input) => _$this._input = input;

  GSendMessageVarsBuilder();

  GSendMessageVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GSendMessageVars other) {
    _$v = other as _$GSendMessageVars;
  }

  @override
  void update(void Function(GSendMessageVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GSendMessageVars build() => _build();

  _$GSendMessageVars _build() {
    _$GSendMessageVars _$result;
    try {
      _$result = _$v ??
          _$GSendMessageVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GSendMessageVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
