// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_message.var.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GDeleteMessageVars> _$gDeleteMessageVarsSerializer =
    _$GDeleteMessageVarsSerializer();

class _$GDeleteMessageVarsSerializer
    implements StructuredSerializer<GDeleteMessageVars> {
  @override
  final Iterable<Type> types = const [GDeleteMessageVars, _$GDeleteMessageVars];
  @override
  final String wireName = 'GDeleteMessageVars';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GDeleteMessageVars object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      'messageID',
      serializers.serialize(object.messageID,
          specifiedType: const FullType(_i1.GUUID)),
    ];

    return result;
  }

  @override
  GDeleteMessageVars deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GDeleteMessageVarsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current! as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'messageID':
          result.messageID.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i1.GUUID))! as _i1.GUUID);
          break;
      }
    }

    return result.build();
  }
}

class _$GDeleteMessageVars extends GDeleteMessageVars {
  @override
  final _i1.GUUID messageID;

  factory _$GDeleteMessageVars(
          [void Function(GDeleteMessageVarsBuilder)? updates]) =>
      (GDeleteMessageVarsBuilder()..update(updates))._build();

  _$GDeleteMessageVars._({required this.messageID}) : super._();
  @override
  GDeleteMessageVars rebuild(
          void Function(GDeleteMessageVarsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GDeleteMessageVarsBuilder toBuilder() =>
      GDeleteMessageVarsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GDeleteMessageVars && messageID == other.messageID;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, messageID.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GDeleteMessageVars')
          ..add('messageID', messageID))
        .toString();
  }
}

class GDeleteMessageVarsBuilder
    implements Builder<GDeleteMessageVars, GDeleteMessageVarsBuilder> {
  _$GDeleteMessageVars? _$v;

  _i1.GUUIDBuilder? _messageID;
  _i1.GUUIDBuilder get messageID => _$this._messageID ??= _i1.GUUIDBuilder();
  set messageID(_i1.GUUIDBuilder? messageID) => _$this._messageID = messageID;

  GDeleteMessageVarsBuilder();

  GDeleteMessageVarsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _messageID = $v.messageID.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GDeleteMessageVars other) {
    _$v = other as _$GDeleteMessageVars;
  }

  @override
  void update(void Function(GDeleteMessageVarsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GDeleteMessageVars build() => _build();

  _$GDeleteMessageVars _build() {
    _$GDeleteMessageVars _$result;
    try {
      _$result = _$v ??
          _$GDeleteMessageVars._(
            messageID: messageID.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'messageID';
        messageID.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GDeleteMessageVars', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
