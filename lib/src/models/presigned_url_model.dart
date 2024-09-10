import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class PresignedUrlModel {
  factory PresignedUrlModel.fromJson(String source) =>
      PresignedUrlModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory PresignedUrlModel.fromMap(Map<String, dynamic> map) =>
      PresignedUrlModel(
        ttl: map['ttl'] != null ? map['ttl'] as num : null,
        thumbnailUrl:
            map['thumbnailUrl'] != null ? map['thumbnailUrl'] as String : null,
        thumbnailPresignedUrl: map['thumbnailPresignedUrl'] != null
            ? map['thumbnailPresignedUrl'] as String
            : null,
        mediaUrl: map['mediaUrl'] != null ? map['mediaUrl'] as String : null,
        mediaPresignedUrl: map['mediaPresignedUrl'] != null
            ? map['mediaPresignedUrl'] as String
            : null,
        mediaId: map['mediaId'] != null ? map['mediaId'] as String : null,
        presignedUrl:
            map['presignedUrl'] != null ? map['presignedUrl'] as String : null,
        msg: map['msg'] != null ? map['msg'] as String : null,
      );

  PresignedUrlModel({
    this.ttl,
    this.thumbnailUrl,
    this.thumbnailPresignedUrl,
    this.mediaUrl,
    this.mediaPresignedUrl,
    this.mediaId,
    this.presignedUrl,
    this.msg,
  });

  final num? ttl;
  final String? thumbnailUrl;
  final String? thumbnailPresignedUrl;
  final String? mediaUrl;
  final String? mediaPresignedUrl;
  final String? mediaId;
  final String? presignedUrl;
  final String? msg;

  PresignedUrlModel copyWith({
    num? ttl,
    String? thumbnailUrl,
    String? thumbnailPresignedUrl,
    String? mediaUrl,
    String? mediaPresignedUrl,
    String? mediaId,
    String? presignedUrl,
    String? msg,
  }) =>
      PresignedUrlModel(
        ttl: ttl ?? this.ttl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        thumbnailPresignedUrl:
            thumbnailPresignedUrl ?? this.thumbnailPresignedUrl,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        mediaPresignedUrl: mediaPresignedUrl ?? this.mediaPresignedUrl,
        mediaId: mediaId ?? this.mediaId,
        presignedUrl: presignedUrl ?? this.presignedUrl,
        msg: msg ?? this.msg,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ttl': ttl,
        'thumbnailUrl': thumbnailUrl,
        'thumbnailPresignedUrl': thumbnailPresignedUrl,
        'mediaUrl': mediaUrl,
        'mediaPresignedUrl': mediaPresignedUrl,
        'mediaId': mediaId,
        'presignedUrl': presignedUrl,
        'msg': msg,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'PresignedUrlModel(ttl: $ttl, thumbnailUrl: $thumbnailUrl, thumbnailPresignedUrl: $thumbnailPresignedUrl, mediaUrl: $mediaUrl, mediaPresignedUrl: $mediaPresignedUrl, mediaId: $mediaId, presignedUrl: $presignedUrl, msg: $msg)';

  @override
  bool operator ==(covariant PresignedUrlModel other) {
    if (identical(this, other)) return true;

    return other.ttl == ttl &&
        other.thumbnailUrl == thumbnailUrl &&
        other.thumbnailPresignedUrl == thumbnailPresignedUrl &&
        other.mediaUrl == mediaUrl &&
        other.mediaPresignedUrl == mediaPresignedUrl &&
        other.mediaId == mediaId &&
        other.presignedUrl == presignedUrl &&
        other.msg == msg;
  }

  @override
  int get hashCode =>
      ttl.hashCode ^
      thumbnailUrl.hashCode ^
      thumbnailPresignedUrl.hashCode ^
      mediaUrl.hashCode ^
      mediaPresignedUrl.hashCode ^
      mediaId.hashCode ^
      presignedUrl.hashCode ^
      msg.hashCode;
}
