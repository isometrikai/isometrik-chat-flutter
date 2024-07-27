import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatReplyMessageModel {
  IsmChatReplyMessageModel({
    this.parentMessageBody,
    this.parentMessageInitiator,
    this.parentMessageUserId,
    this.parentMessageUserName,
    this.parentMessageMessageType,
    this.forMessageType,
    this.parentMessageAttachmentUrl,
  });

  factory IsmChatReplyMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmChatReplyMessageModel(
        parentMessageBody: map['parentMessageBody'] as String? ?? '',
        parentMessageInitiator: map['parentMessageInitiator'] as bool? ?? false,
        parentMessageUserId: map['parentMessageUserId'] as String? ?? '',
        parentMessageUserName: map['parentMessageUserName'] as String? ?? '',
        parentMessageMessageType: map['parentMessageMessageType'] != null
            ? IsmChatCustomMessageType.fromMap(
                map['parentMessageMessageType'] as String)
            : null,
        parentMessageAttachmentUrl:
            map['parentMessageAttachmentUrl'] as String? ?? '',
        forMessageType: map['forMessageType'] != null
            ? IsmChatCustomMessageType.fromMap(map['forMessageType'] as String)
            : null,
      );

  factory IsmChatReplyMessageModel.fromJson(String source) =>
      IsmChatReplyMessageModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? parentMessageBody;
  final bool? parentMessageInitiator;
  final String? parentMessageUserId;
  final String? parentMessageUserName;
  final IsmChatCustomMessageType? parentMessageMessageType;
  final IsmChatCustomMessageType? forMessageType;
  final String? parentMessageAttachmentUrl;

  IsmChatReplyMessageModel copyWith({
    String? parentMessageBody,
    bool? parentMessageInitiator,
    String? parentMessageUserId,
    String? parentMessageUserName,
    IsmChatCustomMessageType? parentMessageMessageType,
    IsmChatCustomMessageType? forMessageType,
    String? parentMessageAttachmentUrl,
  }) =>
      IsmChatReplyMessageModel(
        parentMessageBody: parentMessageBody ?? this.parentMessageBody,
        parentMessageInitiator:
            parentMessageInitiator ?? this.parentMessageInitiator,
        parentMessageUserId: parentMessageUserId ?? this.parentMessageUserId,
        parentMessageUserName:
            parentMessageUserName ?? this.parentMessageUserName,
        parentMessageMessageType:
            parentMessageMessageType ?? this.parentMessageMessageType,
        forMessageType: forMessageType ?? this.forMessageType,
        parentMessageAttachmentUrl:
            parentMessageAttachmentUrl ?? this.parentMessageAttachmentUrl,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'parentMessageBody': parentMessageBody,
        'parentMessageInitiator': parentMessageInitiator,
        'parentMessageUserId': parentMessageUserId,
        'parentMessageUserName': parentMessageUserName,
        'parentMessageMessageType': parentMessageMessageType?.value,
        'forMessageType': forMessageType?.value,
        'parentMessageAttachmentUrl': parentMessageAttachmentUrl,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatReplyMessageModel(parentMessageBody: $parentMessageBody, parentMessageInitiator: $parentMessageInitiator, parentMessageUserId: $parentMessageUserId, parentMessageUserName: $parentMessageUserName, parentMessageMessageType: $parentMessageMessageType, forMessageType: $forMessageType, parentMessageAttachmentUrl: $parentMessageAttachmentUrl)';

  @override
  bool operator ==(covariant IsmChatReplyMessageModel other) {
    if (identical(this, other)) return true;

    return other.parentMessageBody == parentMessageBody &&
        other.parentMessageInitiator == parentMessageInitiator &&
        other.parentMessageUserId == parentMessageUserId &&
        other.parentMessageUserName == parentMessageUserName &&
        other.parentMessageMessageType == parentMessageMessageType &&
        other.forMessageType == forMessageType &&
        other.parentMessageAttachmentUrl == parentMessageAttachmentUrl;
  }

  @override
  int get hashCode =>
      parentMessageBody.hashCode ^
      parentMessageInitiator.hashCode ^
      parentMessageUserId.hashCode ^
      parentMessageUserName.hashCode ^
      parentMessageMessageType.hashCode ^
      forMessageType.hashCode ^
      parentMessageAttachmentUrl.hashCode;
}
