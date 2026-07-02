// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/src/utilities/utilities.dart';

class AttachmentModel {
  AttachmentModel({
    this.thumbnailUrl,
    this.size,
    this.name,
    this.mimeType,
    this.mediaUrl,
    this.mediaId,
    this.extension,
    this.latitude,
    this.longitude,
    this.title,
    this.address,
    this.attachmentType,
    this.bytes,
    this.stillUrl,
  });

  factory AttachmentModel.fromMap(Map<String, dynamic> map) => AttachmentModel(
        thumbnailUrl: map['thumbnailUrl'] as String? ?? '',
        size: map['size'].runtimeType == double
            ? int.tryParse(
                (map['size'] as double? ?? 0).toString(),
              )
            : map['size'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        mimeType: map['mimeType'] as String? ?? '',
        mediaUrl: map['mediaUrl'] as String? ?? '',
        mediaId: map['mediaId'] as String? ?? '',
        extension: map['extension'] as String? ?? '',
        latitude: map['latitude'] as double? ?? 0,
        longitude: map['longitude'] as double? ?? 0,
        title: map['title'] as String? ?? '',
        address: map['address'] as String? ?? '',
        stillUrl: map['stillUrl'] as String? ?? '',
        bytes: map['bytes'].runtimeType is String && map['bytes'] != 'null'
            ? (map['bytes'] as String? ?? '[]').strigToUnit8List
            : Uint8List(0),
        attachmentType: map['attachmentType'] == null
            ? IsmChatMediaType.image
            : IsmChatMediaType.fromMap(map['attachmentType'] as int),
      );

  factory AttachmentModel.fromJson(String source) =>
      AttachmentModel.fromMap(json.decode(source) as Map<String, dynamic>);
  String? thumbnailUrl;
  int? size;
  String? name;
  String? mimeType;
  String? mediaUrl;
  String? mediaId;
  String? extension;
  double? latitude;
  double? longitude;
  String? title;
  String? address;
  Uint8List? bytes;
  String? stillUrl;
  final IsmChatMediaType? attachmentType;

  AttachmentModel copyWith({
    String? thumbnailUrl,
    int? size,
    String? name,
    String? mimeType,
    String? mediaUrl,
    String? mediaId,
    String? extension,
    double? latitude,
    double? longitude,
    String? title,
    String? address,
    Uint8List? bytes,
    IsmChatMediaType? attachmentType,
    String? stillUrl,
  }) =>
      AttachmentModel(
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        size: size ?? this.size,
        name: name ?? this.name,
        mimeType: mimeType ?? this.mimeType,
        mediaUrl: mediaUrl ?? this.mediaUrl,
        mediaId: mediaId ?? this.mediaId,
        extension: extension ?? this.extension,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        title: title ?? this.title,
        address: address ?? this.address,
        attachmentType: attachmentType ?? this.attachmentType,
        bytes: bytes ?? this.bytes,
        stillUrl: stillUrl ?? this.stillUrl,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'thumbnailUrl': thumbnailUrl,
        'size': size,
        'name': name,
        'mimeType': mimeType,
        'mediaUrl': mediaUrl,
        'mediaId': mediaId,
        'extension': extension,
        'latitude': latitude,
        'longitude': longitude,
        'title': title,
        'address': address,
        'stillUrl': stillUrl,
        'bytes': bytes.isNullOrEmpty == true ? '' : bytes.toString(),
        'attachmentType': attachmentType?.value,
      }.removeNullValues();

  /// Builds the attachment object expected by the send-message API.
  ///
  /// GIF/sticker messages use the `GifSticker` schema (not the image schema).
  Map<String, dynamic> toOutgoingMap() {
    final type = attachmentType;
    if (type != null && type.usesGifStickerSchema) {
      final url = (mediaUrl?.isNotEmpty == true ? mediaUrl : thumbnailUrl) ?? '';
      final thumb =
          (thumbnailUrl?.isNotEmpty == true ? thumbnailUrl : url) ?? '';
      final still =
          (stillUrl?.isNotEmpty == true ? stillUrl : thumb.isNotEmpty ? thumb : url) ??
              '';
      return {
        'thumbnailUrl': thumb,
        'attachmentSchemaType': 'GifSticker',
        'mediaUrl': url,
        'stillUrl': still,
        'attachmentType': type.value,
        'name': name ?? '',
        'attachmentMessageType': type.gifStickerMessageType,
      };
    }

    final map = toMap();
    map.remove('bytes');
    return map;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AttachmentModel(thumbnailUrl: $thumbnailUrl, size: $size, name: $name, mimeType: $mimeType, mediaUrl: $mediaUrl, mediaId: $mediaId, extension: $extension, latitude: $latitude, longitude: $longitude, title: $title, address: $address, attachmentType: $attachmentType, stillUrl: $stillUrl, bytes: $bytes)';

  @override
  bool operator ==(covariant AttachmentModel other) {
    if (identical(this, other)) return true;

    return other.thumbnailUrl == thumbnailUrl &&
        other.size == size &&
        other.name == name &&
        other.mimeType == mimeType &&
        other.mediaUrl == mediaUrl &&
        other.mediaId == mediaId &&
        other.extension == extension &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.title == title &&
        other.address == address &&
        other.stillUrl == stillUrl &&
        other.bytes == bytes &&
        other.attachmentType == attachmentType;
  }

  @override
  int get hashCode =>
      thumbnailUrl.hashCode ^
      size.hashCode ^
      name.hashCode ^
      mimeType.hashCode ^
      mediaUrl.hashCode ^
      mediaId.hashCode ^
      extension.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      title.hashCode ^
      address.hashCode ^
      stillUrl.hashCode ^
      bytes.hashCode ^
      attachmentType.hashCode;
}
