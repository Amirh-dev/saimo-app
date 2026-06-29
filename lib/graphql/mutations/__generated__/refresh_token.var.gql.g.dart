// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GRefreshTokenVars> _$gRefreshTokenVarsSerializer =
    new _$GRefreshTokenVarsSerializer();

class _$GRefreshTokenVarsSerializer
    implements StructuredSerializer<GRefreshTokenVars> {
  @override
  final Iterable<Type> types = const [GRefreshTokenVars, _$GRefreshTokenVars];
  @override
  final String wireName = 'GRefreshTokenVars';

  @override
  Iterable<Object?> serialize(Serializers serializers, GRefreshTokenVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GRefreshTokenInput)),
    ];

    return result;
  }

  @override
  GRefreshTokenVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new GRefreshTokenVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GRefreshTokenInput))!
              as _i1.GRefreshTokenInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GRefreshTokenVars extends GRefreshTokenVars {
  @override
  final _i1.GRefreshTokenInput input;

  factory _$GRefreshTokenVars(
          [void Function(GRefreshTokenVarsBuilder)? updates]) =>
      (new GRefreshTokenVarsBuilder()..update(updates))._build();

  _$GRefreshTokenVars._({required this.input}) : super._() {
    BuiltValueNullFieldError.checkNotNull(input, r'GRefreshTokenVars', 'input');
  }

  @override
  GRefreshTokenVars rebuild(void Function(GRefreshTokenVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GRefreshTokenVarsBuilder toBuilder() =>
      new GRefreshTokenVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GRefreshTokenVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GRefreshTokenVars')
          ..add('input', input))
        .toString();
  }
}

class GRefreshTokenVarsBuilder
    implements Builder<GRefreshTokenVars, GRefreshTokenVarsBuilder> {
  _$GRefreshTokenVars? _$v;

  _i1.GRefreshTokenInputBuilder? _input;
  _i1.GRefreshTokenInputBuilder get input =>
      _$this._input ??= new _i1.GRefreshTokenInputBuilder();
  set input(_i1.GRefreshTokenInputBuilder? input) => _$this._input = input;

  GRefreshTokenVarsBuilder();

  GRefreshTokenVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GRefreshTokenVars other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$GRefreshTokenVars;
  }

  @override
  void update(void Function(GRefreshTokenVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GRefreshTokenVars build() => _build();

  _$GRefreshTokenVars _build() {
    _$GRefreshTokenVars _$result;
    try {
      _$result = _$v ?? new _$GRefreshTokenVars._(input: input.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            r'GRefreshTokenVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
