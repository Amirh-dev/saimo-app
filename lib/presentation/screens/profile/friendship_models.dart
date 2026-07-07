class FriendshipUser {
  const FriendshipUser({
    required this.id,
    this.fullName,
    this.username,
  });

  final String id;
  final String? fullName;
  final String? username;

  bool get hasFullName => fullName?.trim().isNotEmpty == true;

  String? get usernameLabel {
    final normalizedUsername = username?.trim();
    return normalizedUsername == null || normalizedUsername.isEmpty
        ? null
        : '@$normalizedUsername';
  }

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final normalizedUsername = usernameLabel;
    if (normalizedUsername != null) return normalizedUsername;

    return 'کاربر سیمو';
  }

  factory FriendshipUser.fromJson(Map<String, dynamic> json) {
    return FriendshipUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      username: json['username']?.toString(),
    );
  }
}

enum FriendshipRelation {
  accepted,
  incomingPending,
  outgoingPending,
}

class FriendshipItem {
  const FriendshipItem({
    required this.id,
    required this.status,
    required this.requesterID,
    required this.receiverID,
    required this.targetUser,
    required this.relation,
    this.isExpanded = false,
  });

  final String id;
  final String status;
  final String requesterID;
  final String receiverID;
  final FriendshipUser targetUser;
  final FriendshipRelation relation;
  final bool isExpanded;

  String get targetUserID => targetUser.id;

  FriendshipItem copyWith({
    bool? isExpanded,
  }) {
    return FriendshipItem(
      id: id,
      status: status,
      requesterID: requesterID,
      receiverID: receiverID,
      targetUser: targetUser,
      relation: relation,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }

  factory FriendshipItem.fromJson(
    Map<String, dynamic> json, {
    required String currentUserID,
  }) {
    final requesterID = json['requesterID']?.toString() ?? '';
    final receiverID = json['receiverID']?.toString() ?? '';
    final requesterJson = json['requester'];
    final receiverJson = json['receiver'];
    final requester = requesterJson is Map<String, dynamic>
        ? FriendshipUser.fromJson(requesterJson)
        : FriendshipUser(id: requesterID);
    final receiver = receiverJson is Map<String, dynamic>
        ? FriendshipUser.fromJson(receiverJson)
        : FriendshipUser(id: receiverID);
    final targetUser = currentUserID == requesterID ? receiver : requester;
    final status = json['status']?.toString() ?? '';
    final normalizedStatus = status.toUpperCase();

    final relation = normalizedStatus == 'ACCEPTED'
        ? FriendshipRelation.accepted
        : requesterID == currentUserID
            ? FriendshipRelation.outgoingPending
            : FriendshipRelation.incomingPending;

    return FriendshipItem(
      id: json['id']?.toString() ?? targetUser.id,
      status: normalizedStatus,
      requesterID: requesterID,
      receiverID: receiverID,
      targetUser: targetUser,
      relation: relation,
    );
  }
}

class CurrentFriendshipUser {
  const CurrentFriendshipUser({
    required this.id,
    this.fullName,
    this.username,
  });

  final String id;
  final String? fullName;
  final String? username;

  factory CurrentFriendshipUser.fromJson(Map<String, dynamic> json) {
    return CurrentFriendshipUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      username: json['username']?.toString(),
    );
  }
}

class UsernameSearchUser {
  const UsernameSearchUser({
    required this.id,
    required this.username,
    this.fullName,
  });

  final String id;
  final String username;
  final String? fullName;

  String get displayName {
    final name = fullName?.trim();
    return name == null || name.isEmpty ? 'کاربر سیمو' : name;
  }

  factory UsernameSearchUser.fromJson(Map<String, dynamic> json) {
    return UsernameSearchUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
    );
  }
}
