import 'package:simo_learn/utils/iran_phone_number.dart';

class FriendshipUser {
  const FriendshipUser({
    required this.id,
    this.fullName,
    this.phoneNumber,
  });

  final String id;
  final String? fullName;
  final String? phoneNumber;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;

    final phone = phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) {
      return maskIranianMobileNumber(phone) ?? 'کاربر سیمو';
    }

    return 'کاربر سیمو';
  }

  factory FriendshipUser.fromJson(Map<String, dynamic> json) {
    return FriendshipUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
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
    this.phoneNumber,
  });

  final String id;
  final String? fullName;
  final String? phoneNumber;

  factory CurrentFriendshipUser.fromJson(Map<String, dynamic> json) {
    return CurrentFriendshipUser(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
    );
  }
}
