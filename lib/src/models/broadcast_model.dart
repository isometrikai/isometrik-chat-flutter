// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class BroadcastModel {
  BroadcastModel({
    required this.sendPushForNewConversationCreated,
    this.searchableTags,
    this.membersCount,
    required this.hideNewConversationsForSender,
    this.groupcastTitle,
    this.groupcastImageUrl,
    this.groupcastId,
    this.executionPending,
    required this.customType,
    this.createdBy,
    this.createdAt,
    this.metaData,
  });

  factory BroadcastModel.fromMap(Map<String, dynamic> map) => BroadcastModel(
        sendPushForNewConversationCreated:
            map['sendPushForNewConversationCreated'] as dynamic,
        searchableTags: map['searchableTags'] != null
            ? List<String>.from(map['searchableTags'] as List)
            : null,
        membersCount: map['membersCount'] as int? ?? 0,
        hideNewConversationsForSender:
            map['hideNewConversationsForSender'] as dynamic,
        groupcastTitle: map['groupcastTitle'] as String? ?? '',
        groupcastImageUrl: map['groupcastImageUrl'] as String? ?? '',
        groupcastId: map['groupcastId'] as String? ?? '',
        executionPending: map['executionPending'] as bool? ?? false,
        customType: map['customType'] as dynamic,
        createdBy: map['createdBy'] as String? ?? '',
        createdAt: map['createdAt'] as int? ?? 0,
        metaData: map['metaData'] != null
            ? BroadcastMetadata.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
      );

  factory BroadcastModel.fromJson(String source) =>
      BroadcastModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final dynamic sendPushForNewConversationCreated;
  final List<String>? searchableTags;
  final int? membersCount;
  final dynamic hideNewConversationsForSender;
  final String? groupcastTitle;
  final String? groupcastImageUrl;
  final String? groupcastId;
  final bool? executionPending;
  final dynamic customType;
  final String? createdBy;
  final int? createdAt;
  final BroadcastMetadata? metaData;

  BroadcastModel copyWith({
    dynamic sendPushForNewConversationCreated,
    List<String>? searchableTags,
    int? membersCount,
    dynamic hideNewConversationsForSender,
    String? groupcastTitle,
    String? groupcastImageUrl,
    String? groupcastId,
    bool? executionPending,
    dynamic customType,
    String? createdBy,
    int? createdAt,
    BroadcastMetadata? metaData,
  }) =>
      BroadcastModel(
        sendPushForNewConversationCreated: sendPushForNewConversationCreated ??
            this.sendPushForNewConversationCreated,
        searchableTags: searchableTags ?? this.searchableTags,
        membersCount: membersCount ?? this.membersCount,
        hideNewConversationsForSender:
            hideNewConversationsForSender ?? this.hideNewConversationsForSender,
        groupcastTitle: groupcastTitle ?? this.groupcastTitle,
        groupcastImageUrl: groupcastImageUrl ?? this.groupcastImageUrl,
        groupcastId: groupcastId ?? this.groupcastId,
        executionPending: executionPending ?? this.executionPending,
        customType: customType ?? this.customType,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
        metaData: metaData ?? this.metaData,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'sendPushForNewConversationCreated': sendPushForNewConversationCreated,
        'searchableTags': searchableTags,
        'membersCount': membersCount,
        'hideNewConversationsForSender': hideNewConversationsForSender,
        'groupcastTitle': groupcastTitle,
        'groupcastImageUrl': groupcastImageUrl,
        'groupcastId': groupcastId,
        'executionPending': executionPending,
        'customType': customType,
        'createdBy': createdBy,
        'createdAt': createdAt,
        'metaData': metaData?.toMap(),
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'BroadcastModel(sendPushForNewConversationCreated: $sendPushForNewConversationCreated, searchableTags: $searchableTags, membersCount: $membersCount, hideNewConversationsForSender: $hideNewConversationsForSender, groupcastTitle: $groupcastTitle, groupcastImageUrl: $groupcastImageUrl, groupcastId: $groupcastId, executionPending: $executionPending, customType: $customType, createdBy: $createdBy, createdAt: $createdAt, metaData: $metaData)';

  @override
  bool operator ==(covariant BroadcastModel other) {
    if (identical(this, other)) return true;

    return other.sendPushForNewConversationCreated ==
            sendPushForNewConversationCreated &&
        listEquals(other.searchableTags, searchableTags) &&
        other.membersCount == membersCount &&
        other.hideNewConversationsForSender == hideNewConversationsForSender &&
        other.groupcastTitle == groupcastTitle &&
        other.groupcastImageUrl == groupcastImageUrl &&
        other.groupcastId == groupcastId &&
        other.executionPending == executionPending &&
        other.customType == customType &&
        other.createdBy == createdBy &&
        other.createdAt == createdAt &&
        other.metaData == metaData;
  }

  @override
  int get hashCode =>
      sendPushForNewConversationCreated.hashCode ^
      searchableTags.hashCode ^
      membersCount.hashCode ^
      hideNewConversationsForSender.hashCode ^
      groupcastTitle.hashCode ^
      groupcastImageUrl.hashCode ^
      groupcastId.hashCode ^
      executionPending.hashCode ^
      customType.hashCode ^
      createdBy.hashCode ^
      createdAt.hashCode ^
      metaData.hashCode;
}

class MembersDetail {
  MembersDetail({
    this.memberName,
    this.memberId,
  });

  factory MembersDetail.fromMap(Map<String, dynamic> map) => MembersDetail(
        memberName: map['memberName'] as String? ?? '',
        memberId: map['memberId'] as String? ?? '',
      );

  factory MembersDetail.fromJson(String source) =>
      MembersDetail.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? memberName;
  final String? memberId;

  MembersDetail copyWith({
    String? memberName,
    String? memberId,
  }) =>
      MembersDetail(
        memberName: memberName ?? this.memberName,
        memberId: memberId ?? this.memberId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'memberName': memberName,
        'memberId': memberId,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MembersDetail(memberName: $memberName, memberId: $memberId)';

  @override
  bool operator ==(covariant MembersDetail other) {
    if (identical(this, other)) return true;

    return other.memberName == memberName && other.memberId == memberId;
  }

  @override
  int get hashCode => memberName.hashCode ^ memberId.hashCode;
}

class BroadcastMetadata {
  final List<MembersDetail>? membersDetail;
  BroadcastMetadata({
    this.membersDetail,
  });

  BroadcastMetadata copyWith({
    List<MembersDetail>? membersDetail,
  }) =>
      BroadcastMetadata(
        membersDetail: membersDetail ?? this.membersDetail,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'membersDetail': membersDetail?.map((x) => x.toMap()).toList(),
      }.removeNullValues();

  factory BroadcastMetadata.fromMap(Map<String, dynamic> map) =>
      BroadcastMetadata(
        membersDetail: map['membersDetail'] != null
            ? List<MembersDetail>.from(
                (map['membersDetail'] as List).map<MembersDetail?>(
                  (x) => MembersDetail.fromMap(x as Map<String, dynamic>),
                ),
              )
            : null,
      );

  String toJson() => json.encode(toMap());

  factory BroadcastMetadata.fromJson(String source) =>
      BroadcastMetadata.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'BroadcastMetadata(membersDetail: $membersDetail)';

  @override
  bool operator ==(covariant BroadcastMetadata other) {
    if (identical(this, other)) return true;

    return listEquals(other.membersDetail, membersDetail);
  }

  @override
  int get hashCode => membersDetail.hashCode;
}
