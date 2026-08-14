// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_friends.data.gql.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<GGetFriendsData> _$gGetFriendsDataSerializer =
    _$GGetFriendsDataSerializer();
Serializer<GGetFriendsData_getFriends> _$gGetFriendsDataGetFriendsSerializer =
    _$GGetFriendsData_getFriendsSerializer();
Serializer<GGetFriendsData_getFriends_requester>
    _$gGetFriendsDataGetFriendsRequesterSerializer =
    _$GGetFriendsData_getFriends_requesterSerializer();
Serializer<GGetFriendsData_getFriends_receiver>
    _$gGetFriendsDataGetFriendsReceiverSerializer =
    _$GGetFriendsData_getFriends_receiverSerializer();

class _$GGetFriendsDataSerializer
    implements StructuredSerializer<GGetFriendsData> {
  @override
  final Iterable<Type> types = const [GGetFriendsData, _$GGetFriendsData];
  @override
  final String wireName = 'GGetFriendsData';

  @override
  Iterable<Object?> serialize(Serializers serializers, GGetFriendsData object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'getFriends',
      serializers.serialize(object.getFriends,
          specifiedType: const FullType(
              BuiltList, const [const FullType(GGetFriendsData_getFriends)])),
    ];

    return result;
  }

  @override
  GGetFriendsData deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetFriendsDataBuilder();

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
        case 'getFriends':
          result.getFriends.replace(serializers.deserialize(value,
              specifiedType: const FullType(BuiltList, const [
                const FullType(GGetFriendsData_getFriends)
              ]))! as BuiltList<Object?>);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetFriendsData_getFriendsSerializer
    implements StructuredSerializer<GGetFriendsData_getFriends> {
  @override
  final Iterable<Type> types = const [
    GGetFriendsData_getFriends,
    _$GGetFriendsData_getFriends
  ];
  @override
  final String wireName = 'GGetFriendsData_getFriends';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetFriendsData_getFriends object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'status',
      serializers.serialize(object.status,
          specifiedType: const FullType(_i2.GFriendshipStatus)),
      'requesterID',
      serializers.serialize(object.requesterID,
          specifiedType: const FullType(String)),
      'receiverID',
      serializers.serialize(object.receiverID,
          specifiedType: const FullType(String)),
      'userLowID',
      serializers.serialize(object.userLowID,
          specifiedType: const FullType(_i2.GUUID)),
      'userHighID',
      serializers.serialize(object.userHighID,
          specifiedType: const FullType(_i2.GUUID)),
      'requester',
      serializers.serialize(object.requester,
          specifiedType: const FullType(GGetFriendsData_getFriends_requester)),
      'receiver',
      serializers.serialize(object.receiver,
          specifiedType: const FullType(GGetFriendsData_getFriends_receiver)),
    ];

    return result;
  }

  @override
  GGetFriendsData_getFriends deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetFriendsData_getFriendsBuilder();

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
        case 'status':
          result.status = serializers.deserialize(value,
                  specifiedType: const FullType(_i2.GFriendshipStatus))!
              as _i2.GFriendshipStatus;
          break;
        case 'requesterID':
          result.requesterID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'receiverID':
          result.receiverID = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
        case 'userLowID':
          result.userLowID.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GUUID))! as _i2.GUUID);
          break;
        case 'userHighID':
          result.userHighID.replace(serializers.deserialize(value,
              specifiedType: const FullType(_i2.GUUID))! as _i2.GUUID);
          break;
        case 'requester':
          result.requester.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GGetFriendsData_getFriends_requester))!
              as GGetFriendsData_getFriends_requester);
          break;
        case 'receiver':
          result.receiver.replace(serializers.deserialize(value,
                  specifiedType:
                      const FullType(GGetFriendsData_getFriends_receiver))!
              as GGetFriendsData_getFriends_receiver);
          break;
      }
    }

    return result.build();
  }
}

class _$GGetFriendsData_getFriends_requesterSerializer
    implements StructuredSerializer<GGetFriendsData_getFriends_requester> {
  @override
  final Iterable<Type> types = const [
    GGetFriendsData_getFriends_requester,
    _$GGetFriendsData_getFriends_requester
  ];
  @override
  final String wireName = 'GGetFriendsData_getFriends_requester';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetFriendsData_getFriends_requester object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'username',
      serializers.serialize(object.username,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.fullName;
    if (value != null) {
      result
        ..add('fullName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GGetFriendsData_getFriends_requester deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetFriendsData_getFriends_requesterBuilder();

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
        case 'fullName':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'username':
          result.username = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetFriendsData_getFriends_receiverSerializer
    implements StructuredSerializer<GGetFriendsData_getFriends_receiver> {
  @override
  final Iterable<Type> types = const [
    GGetFriendsData_getFriends_receiver,
    _$GGetFriendsData_getFriends_receiver
  ];
  @override
  final String wireName = 'GGetFriendsData_getFriends_receiver';

  @override
  Iterable<Object?> serialize(
      Serializers serializers, GGetFriendsData_getFriends_receiver object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[
      '__typename',
      serializers.serialize(object.G__typename,
          specifiedType: const FullType(String)),
      'id',
      serializers.serialize(object.id, specifiedType: const FullType(String)),
      'username',
      serializers.serialize(object.username,
          specifiedType: const FullType(String)),
    ];
    Object? value;
    value = object.fullName;
    if (value != null) {
      result
        ..add('fullName')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  GGetFriendsData_getFriends_receiver deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = GGetFriendsData_getFriends_receiverBuilder();

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
        case 'fullName':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'username':
          result.username = serializers.deserialize(value,
              specifiedType: const FullType(String))! as String;
          break;
      }
    }

    return result.build();
  }
}

class _$GGetFriendsData extends GGetFriendsData {
  @override
  final String G__typename;
  @override
  final BuiltList<GGetFriendsData_getFriends> getFriends;

  factory _$GGetFriendsData([void Function(GGetFriendsDataBuilder)? updates]) =>
      (GGetFriendsDataBuilder()..update(updates))._build();

  _$GGetFriendsData._({required this.G__typename, required this.getFriends})
      : super._();
  @override
  GGetFriendsData rebuild(void Function(GGetFriendsDataBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetFriendsDataBuilder toBuilder() => GGetFriendsDataBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetFriendsData &&
        G__typename == other.G__typename &&
        getFriends == other.getFriends;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, getFriends.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetFriendsData')
          ..add('G__typename', G__typename)
          ..add('getFriends', getFriends))
        .toString();
  }
}

class GGetFriendsDataBuilder
    implements Builder<GGetFriendsData, GGetFriendsDataBuilder> {
  _$GGetFriendsData? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  ListBuilder<GGetFriendsData_getFriends>? _getFriends;
  ListBuilder<GGetFriendsData_getFriends> get getFriends =>
      _$this._getFriends ??= ListBuilder<GGetFriendsData_getFriends>();
  set getFriends(ListBuilder<GGetFriendsData_getFriends>? getFriends) =>
      _$this._getFriends = getFriends;

  GGetFriendsDataBuilder() {
    GGetFriendsData._initializeBuilder(this);
  }

  GGetFriendsDataBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _getFriends = $v.getFriends.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetFriendsData other) {
    _$v = other as _$GGetFriendsData;
  }

  @override
  void update(void Function(GGetFriendsDataBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetFriendsData build() => _build();

  _$GGetFriendsData _build() {
    _$GGetFriendsData _$result;
    try {
      _$result = _$v ??
          _$GGetFriendsData._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetFriendsData', 'G__typename'),
            getFriends: getFriends.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'getFriends';
        getFriends.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetFriendsData', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetFriendsData_getFriends extends GGetFriendsData_getFriends {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final _i2.GFriendshipStatus status;
  @override
  final String requesterID;
  @override
  final String receiverID;
  @override
  final _i2.GUUID userLowID;
  @override
  final _i2.GUUID userHighID;
  @override
  final GGetFriendsData_getFriends_requester requester;
  @override
  final GGetFriendsData_getFriends_receiver receiver;

  factory _$GGetFriendsData_getFriends(
          [void Function(GGetFriendsData_getFriendsBuilder)? updates]) =>
      (GGetFriendsData_getFriendsBuilder()..update(updates))._build();

  _$GGetFriendsData_getFriends._(
      {required this.G__typename,
      required this.id,
      required this.status,
      required this.requesterID,
      required this.receiverID,
      required this.userLowID,
      required this.userHighID,
      required this.requester,
      required this.receiver})
      : super._();
  @override
  GGetFriendsData_getFriends rebuild(
          void Function(GGetFriendsData_getFriendsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetFriendsData_getFriendsBuilder toBuilder() =>
      GGetFriendsData_getFriendsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetFriendsData_getFriends &&
        G__typename == other.G__typename &&
        id == other.id &&
        status == other.status &&
        requesterID == other.requesterID &&
        receiverID == other.receiverID &&
        userLowID == other.userLowID &&
        userHighID == other.userHighID &&
        requester == other.requester &&
        receiver == other.receiver;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, requesterID.hashCode);
    _$hash = $jc(_$hash, receiverID.hashCode);
    _$hash = $jc(_$hash, userLowID.hashCode);
    _$hash = $jc(_$hash, userHighID.hashCode);
    _$hash = $jc(_$hash, requester.hashCode);
    _$hash = $jc(_$hash, receiver.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetFriendsData_getFriends')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('status', status)
          ..add('requesterID', requesterID)
          ..add('receiverID', receiverID)
          ..add('userLowID', userLowID)
          ..add('userHighID', userHighID)
          ..add('requester', requester)
          ..add('receiver', receiver))
        .toString();
  }
}

class GGetFriendsData_getFriendsBuilder
    implements
        Builder<GGetFriendsData_getFriends, GGetFriendsData_getFriendsBuilder> {
  _$GGetFriendsData_getFriends? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  _i2.GFriendshipStatus? _status;
  _i2.GFriendshipStatus? get status => _$this._status;
  set status(_i2.GFriendshipStatus? status) => _$this._status = status;

  String? _requesterID;
  String? get requesterID => _$this._requesterID;
  set requesterID(String? requesterID) => _$this._requesterID = requesterID;

  String? _receiverID;
  String? get receiverID => _$this._receiverID;
  set receiverID(String? receiverID) => _$this._receiverID = receiverID;

  _i2.GUUIDBuilder? _userLowID;
  _i2.GUUIDBuilder get userLowID => _$this._userLowID ??= _i2.GUUIDBuilder();
  set userLowID(_i2.GUUIDBuilder? userLowID) => _$this._userLowID = userLowID;

  _i2.GUUIDBuilder? _userHighID;
  _i2.GUUIDBuilder get userHighID => _$this._userHighID ??= _i2.GUUIDBuilder();
  set userHighID(_i2.GUUIDBuilder? userHighID) =>
      _$this._userHighID = userHighID;

  GGetFriendsData_getFriends_requesterBuilder? _requester;
  GGetFriendsData_getFriends_requesterBuilder get requester =>
      _$this._requester ??= GGetFriendsData_getFriends_requesterBuilder();
  set requester(GGetFriendsData_getFriends_requesterBuilder? requester) =>
      _$this._requester = requester;

  GGetFriendsData_getFriends_receiverBuilder? _receiver;
  GGetFriendsData_getFriends_receiverBuilder get receiver =>
      _$this._receiver ??= GGetFriendsData_getFriends_receiverBuilder();
  set receiver(GGetFriendsData_getFriends_receiverBuilder? receiver) =>
      _$this._receiver = receiver;

  GGetFriendsData_getFriendsBuilder() {
    GGetFriendsData_getFriends._initializeBuilder(this);
  }

  GGetFriendsData_getFriendsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _status = $v.status;
      _requesterID = $v.requesterID;
      _receiverID = $v.receiverID;
      _userLowID = $v.userLowID.toBuilder();
      _userHighID = $v.userHighID.toBuilder();
      _requester = $v.requester.toBuilder();
      _receiver = $v.receiver.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetFriendsData_getFriends other) {
    _$v = other as _$GGetFriendsData_getFriends;
  }

  @override
  void update(void Function(GGetFriendsData_getFriendsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetFriendsData_getFriends build() => _build();

  _$GGetFriendsData_getFriends _build() {
    _$GGetFriendsData_getFriends _$result;
    try {
      _$result = _$v ??
          _$GGetFriendsData_getFriends._(
            G__typename: BuiltValueNullFieldError.checkNotNull(
                G__typename, r'GGetFriendsData_getFriends', 'G__typename'),
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'GGetFriendsData_getFriends', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'GGetFriendsData_getFriends', 'status'),
            requesterID: BuiltValueNullFieldError.checkNotNull(
                requesterID, r'GGetFriendsData_getFriends', 'requesterID'),
            receiverID: BuiltValueNullFieldError.checkNotNull(
                receiverID, r'GGetFriendsData_getFriends', 'receiverID'),
            userLowID: userLowID.build(),
            userHighID: userHighID.build(),
            requester: requester.build(),
            receiver: receiver.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'userLowID';
        userLowID.build();
        _$failedField = 'userHighID';
        userHighID.build();
        _$failedField = 'requester';
        requester.build();
        _$failedField = 'receiver';
        receiver.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'GGetFriendsData_getFriends', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

class _$GGetFriendsData_getFriends_requester
    extends GGetFriendsData_getFriends_requester {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String? fullName;
  @override
  final String username;

  factory _$GGetFriendsData_getFriends_requester(
          [void Function(GGetFriendsData_getFriends_requesterBuilder)?
              updates]) =>
      (GGetFriendsData_getFriends_requesterBuilder()..update(updates))._build();

  _$GGetFriendsData_getFriends_requester._(
      {required this.G__typename,
      required this.id,
      this.fullName,
      required this.username})
      : super._();
  @override
  GGetFriendsData_getFriends_requester rebuild(
          void Function(GGetFriendsData_getFriends_requesterBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetFriendsData_getFriends_requesterBuilder toBuilder() =>
      GGetFriendsData_getFriends_requesterBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetFriendsData_getFriends_requester &&
        G__typename == other.G__typename &&
        id == other.id &&
        fullName == other.fullName &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetFriendsData_getFriends_requester')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('fullName', fullName)
          ..add('username', username))
        .toString();
  }
}

class GGetFriendsData_getFriends_requesterBuilder
    implements
        Builder<GGetFriendsData_getFriends_requester,
            GGetFriendsData_getFriends_requesterBuilder> {
  _$GGetFriendsData_getFriends_requester? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GGetFriendsData_getFriends_requesterBuilder() {
    GGetFriendsData_getFriends_requester._initializeBuilder(this);
  }

  GGetFriendsData_getFriends_requesterBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _fullName = $v.fullName;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetFriendsData_getFriends_requester other) {
    _$v = other as _$GGetFriendsData_getFriends_requester;
  }

  @override
  void update(
      void Function(GGetFriendsData_getFriends_requesterBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetFriendsData_getFriends_requester build() => _build();

  _$GGetFriendsData_getFriends_requester _build() {
    final _$result = _$v ??
        _$GGetFriendsData_getFriends_requester._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GGetFriendsData_getFriends_requester', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GGetFriendsData_getFriends_requester', 'id'),
          fullName: fullName,
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'GGetFriendsData_getFriends_requester', 'username'),
        );
    replace(_$result);
    return _$result;
  }
}

class _$GGetFriendsData_getFriends_receiver
    extends GGetFriendsData_getFriends_receiver {
  @override
  final String G__typename;
  @override
  final String id;
  @override
  final String? fullName;
  @override
  final String username;

  factory _$GGetFriendsData_getFriends_receiver(
          [void Function(GGetFriendsData_getFriends_receiverBuilder)?
              updates]) =>
      (GGetFriendsData_getFriends_receiverBuilder()..update(updates))._build();

  _$GGetFriendsData_getFriends_receiver._(
      {required this.G__typename,
      required this.id,
      this.fullName,
      required this.username})
      : super._();
  @override
  GGetFriendsData_getFriends_receiver rebuild(
          void Function(GGetFriendsData_getFriends_receiverBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GGetFriendsData_getFriends_receiverBuilder toBuilder() =>
      GGetFriendsData_getFriends_receiverBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GGetFriendsData_getFriends_receiver &&
        G__typename == other.G__typename &&
        id == other.id &&
        fullName == other.fullName &&
        username == other.username;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, G__typename.hashCode);
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, fullName.hashCode);
    _$hash = $jc(_$hash, username.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GGetFriendsData_getFriends_receiver')
          ..add('G__typename', G__typename)
          ..add('id', id)
          ..add('fullName', fullName)
          ..add('username', username))
        .toString();
  }
}

class GGetFriendsData_getFriends_receiverBuilder
    implements
        Builder<GGetFriendsData_getFriends_receiver,
            GGetFriendsData_getFriends_receiverBuilder> {
  _$GGetFriendsData_getFriends_receiver? _$v;

  String? _G__typename;
  String? get G__typename => _$this._G__typename;
  set G__typename(String? G__typename) => _$this._G__typename = G__typename;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _username;
  String? get username => _$this._username;
  set username(String? username) => _$this._username = username;

  GGetFriendsData_getFriends_receiverBuilder() {
    GGetFriendsData_getFriends_receiver._initializeBuilder(this);
  }

  GGetFriendsData_getFriends_receiverBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _G__typename = $v.G__typename;
      _id = $v.id;
      _fullName = $v.fullName;
      _username = $v.username;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GGetFriendsData_getFriends_receiver other) {
    _$v = other as _$GGetFriendsData_getFriends_receiver;
  }

  @override
  void update(
      void Function(GGetFriendsData_getFriends_receiverBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GGetFriendsData_getFriends_receiver build() => _build();

  _$GGetFriendsData_getFriends_receiver _build() {
    final _$result = _$v ??
        _$GGetFriendsData_getFriends_receiver._(
          G__typename: BuiltValueNullFieldError.checkNotNull(G__typename,
              r'GGetFriendsData_getFriends_receiver', 'G__typename'),
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'GGetFriendsData_getFriends_receiver', 'id'),
          fullName: fullName,
          username: BuiltValueNullFieldError.checkNotNull(
              username, r'GGetFriendsData_getFriends_receiver', 'username'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
