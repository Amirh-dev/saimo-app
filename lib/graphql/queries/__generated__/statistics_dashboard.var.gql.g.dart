// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'statistics_dashboard.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GStatisticsDashboardVars> _$gStatisticsDashboardVarsSerializer =
    _$GStatisticsDashboardVarsSerializer();

class _$GStatisticsDashboardVarsSerializer
    implements StructuredSerializer<GStatisticsDashboardVars> {
  @override
  final Iterable<Type> types = const [
    GStatisticsDashboardVars,
    _$GStatisticsDashboardVars
  ];
  @override
  final String wireName = 'GStatisticsDashboardVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GStatisticsDashboardVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'input',
      serializers.serialize(object.input,
          specifiedType: const FullType(_i1.GStatisticsDashboardInput)),
    ];

    return result;
  }

  @override
  GStatisticsDashboardVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GStatisticsDashboardVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'input':
          result.input.replace(serializers.deserialize(value,
                  specifiedType: const FullType(_i1.GStatisticsDashboardInput))!
              as _i1.GStatisticsDashboardInput);
          break;
      }
    }

    return result.build();
  }
}

class _$GStatisticsDashboardVars extends GStatisticsDashboardVars {
  @override
  final _i1.GStatisticsDashboardInput input;

  factory _$GStatisticsDashboardVars(
          [void Function(GStatisticsDashboardVarsBuilder)? updates]) =>
      (GStatisticsDashboardVarsBuilder()..update(updates))._build();

  _$GStatisticsDashboardVars._({required this.input}) : super._();
  @override
  GStatisticsDashboardVars rebuild(
          void Function(GStatisticsDashboardVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GStatisticsDashboardVarsBuilder toBuilder() =>
      GStatisticsDashboardVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GStatisticsDashboardVars && input == other.input;
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
    return (newBuiltValueToStringHelper(r'GStatisticsDashboardVars')
          ..add('input', input))
        .toString();
  }
}

class GStatisticsDashboardVarsBuilder
    implements
        Builder<GStatisticsDashboardVars, GStatisticsDashboardVarsBuilder> {
  _$GStatisticsDashboardVars? _$v;

  _i1.GStatisticsDashboardInputBuilder? _input;
  _i1.GStatisticsDashboardInputBuilder get input =>
      _$this._input ??= _i1.GStatisticsDashboardInputBuilder();
  set input(_i1.GStatisticsDashboardInputBuilder? input) =>
      _$this._input = input;

  GStatisticsDashboardVarsBuilder();

  GStatisticsDashboardVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _input = $v.input.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GStatisticsDashboardVars other) {
    _$v = other as _$GStatisticsDashboardVars;
  }

  @override
  void update(void Function(GStatisticsDashboardVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GStatisticsDashboardVars build() => _build();

  _$GStatisticsDashboardVars _build() {
    _$GStatisticsDashboardVars _$result;
    try {
      _$result = _$v ??
          _$GStatisticsDashboardVars._(
            input: input.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'input';
        input.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GStatisticsDashboardVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
