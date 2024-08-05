import 'dart:convert';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:collection/collection.dart';

class BroadcastMemberModel {
  BroadcastMemberModel({
    this.membersCount,
    required this.members,
  });

  factory BroadcastMemberModel.fromMap(Map<String, dynamic> map) =>
      BroadcastMemberModel(
        membersCount: map['membersCount'] as int? ?? 0,
        members: List<BroadcastMember>.from(
          (map['members'] as List).map<BroadcastMember>(
            (x) => BroadcastMember.fromMap(x as Map<String, dynamic>),
          ),
        ),
      );

  factory BroadcastMemberModel.fromJson(String source) =>
      BroadcastMemberModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final int? membersCount;
  final List<BroadcastMember> members;

  BroadcastMemberModel copyWith({
    int? membersCount,
    List<BroadcastMember>? members,
  }) =>
      BroadcastMemberModel(
        membersCount: membersCount ?? this.membersCount,
        members: members ?? this.members,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'membersCount': membersCount,
        'members': members.map((x) => x.toMap()).toList(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'BroadcastMemberModel(membersCount: $membersCount, members: $members)';

  @override
  bool operator ==(covariant BroadcastMemberModel other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.membersCount == membersCount &&
        listEquals(other.members, members);
  }

  @override
  int get hashCode => membersCount.hashCode ^ members.hashCode;
}

class BroadcastMember {
  BroadcastMember({
    this.timestamp,
    this.newConversationTypingEvents,
    this.newConversationReadEvents,
    this.newConversationPushNotificationsEvents,
    required this.newConversationMetadata,
    this.newConversationCustomType,
    this.memberId,
    this.memberInfo,
  });

  factory BroadcastMember.fromMap(Map<String, dynamic> map) => BroadcastMember(
        timestamp: map['timestamp'] as int? ?? 0,
        newConversationTypingEvents:
            map['newConversationTypingEvents'] as bool? ?? false,
        newConversationReadEvents:
            map['newConversationReadEvents'] as bool? ?? false,
        newConversationPushNotificationsEvents:
            map['newConversationPushNotificationsEvents'] as bool? ?? false,
        newConversationMetadata: map['newConversationMetadata'] as dynamic,
        newConversationCustomType:
            map['newConversationCustomType'] as String? ?? '',
        memberId: map['memberId'] as String? ?? '',
        memberInfo: map['memberInfo'] != null
            ? UserDetails.fromMap(map['memberInfo'] as Map<String, dynamic>)
            : null,
      );

  factory BroadcastMember.fromJson(String source) =>
      BroadcastMember.fromMap(json.decode(source) as Map<String, dynamic>);
  final int? timestamp;
  final bool? newConversationTypingEvents;
  final bool? newConversationReadEvents;
  final bool? newConversationPushNotificationsEvents;
  final dynamic newConversationMetadata;
  final String? newConversationCustomType;
  final String? memberId;
  final UserDetails? memberInfo;

  BroadcastMember copyWith({
    int? timestamp,
    bool? newConversationTypingEvents,
    bool? newConversationReadEvents,
    bool? newConversationPushNotificationsEvents,
    dynamic newConversationMetadata,
    String? newConversationCustomType,
    String? memberId,
    UserDetails? memberInfo,
  }) =>
      BroadcastMember(
        timestamp: timestamp ?? this.timestamp,
        newConversationTypingEvents:
            newConversationTypingEvents ?? this.newConversationTypingEvents,
        newConversationReadEvents:
            newConversationReadEvents ?? this.newConversationReadEvents,
        newConversationPushNotificationsEvents:
            newConversationPushNotificationsEvents ??
                this.newConversationPushNotificationsEvents,
        newConversationMetadata:
            newConversationMetadata ?? this.newConversationMetadata,
        newConversationCustomType:
            newConversationCustomType ?? this.newConversationCustomType,
        memberId: memberId ?? this.memberId,
        memberInfo: memberInfo ?? this.memberInfo,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'timestamp': timestamp,
        'newConversationTypingEvents': newConversationTypingEvents,
        'newConversationReadEvents': newConversationReadEvents,
        'newConversationPushNotificationsEvents':
            newConversationPushNotificationsEvents,
        'newConversationMetadata': newConversationMetadata,
        'newConversationCustomType': newConversationCustomType,
        'memberId': memberId,
        'memberInfo': memberInfo?.toMap(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'BroadcastMember(timestamp: $timestamp, newConversationTypingEvents: $newConversationTypingEvents, newConversationReadEvents: $newConversationReadEvents, newConversationPushNotificationsEvents: $newConversationPushNotificationsEvents, newConversationMetadata: $newConversationMetadata, newConversationCustomType: $newConversationCustomType, memberId: $memberId, memberInfo: $memberInfo)';

  @override
  bool operator ==(covariant BroadcastMember other) {
    if (identical(this, other)) return true;

    return other.timestamp == timestamp &&
        other.newConversationTypingEvents == newConversationTypingEvents &&
        other.newConversationReadEvents == newConversationReadEvents &&
        other.newConversationPushNotificationsEvents ==
            newConversationPushNotificationsEvents &&
        other.newConversationMetadata == newConversationMetadata &&
        other.newConversationCustomType == newConversationCustomType &&
        other.memberId == memberId &&
        other.memberInfo == memberInfo;
  }

  @override
  int get hashCode =>
      timestamp.hashCode ^
      newConversationTypingEvents.hashCode ^
      newConversationReadEvents.hashCode ^
      newConversationPushNotificationsEvents.hashCode ^
      newConversationMetadata.hashCode ^
      newConversationCustomType.hashCode ^
      memberId.hashCode ^
      memberInfo.hashCode;
}
