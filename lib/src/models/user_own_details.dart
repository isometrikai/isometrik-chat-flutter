import 'dart:convert';

class IsmChatUserOwnDetails {
  IsmChatUserOwnDetails({
    required this.memberId,
    required this.isAdmin,
    required this.isDeleted,
  });

  factory IsmChatUserOwnDetails.fromMap(Map<String, dynamic> map) =>
      IsmChatUserOwnDetails(
        memberId: map['memberId'] as String? ?? '',
        isAdmin: map['isAdmin'] as bool? ?? false,
        isDeleted: map['isDeleted'] as bool? ?? false,
      );

  factory IsmChatUserOwnDetails.fromJson(String source) =>
      IsmChatUserOwnDetails.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String memberId;
  final bool isAdmin;
  final bool isDeleted;

  IsmChatUserOwnDetails copyWith({
    String? memberId,
    bool? isAdmin,
    bool? isDeleted,
  }) =>
      IsmChatUserOwnDetails(
        memberId: memberId ?? this.memberId,
        isAdmin: isAdmin ?? this.isAdmin,
        isDeleted: isDeleted ?? this.isDeleted,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'memberId': memberId,
        'isAdmin': isAdmin,
        'isDeleted': isDeleted,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatUserOwnDetails(memberId: $memberId, isAdmin: $isAdmin, isDeleted: $isDeleted)';

  @override
  bool operator ==(covariant IsmChatUserOwnDetails other) {
    if (identical(this, other)) return true;

    return other.memberId == memberId &&
        other.isAdmin == isAdmin &&
        other.isDeleted == isDeleted;
  }

  @override
  int get hashCode => memberId.hashCode ^ isAdmin.hashCode ^ isDeleted.hashCode;
}
