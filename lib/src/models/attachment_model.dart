import 'dart:convert';

import 'package:isometrik_flutter_chat/src/utilities/utilities.dart';

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
    IsmChatMediaType? attachmentType,
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
        'attachmentType': attachmentType?.value,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AttachmentModel(thumbnailUrl: $thumbnailUrl, size: $size, name: $name, mimeType: $mimeType, mediaUrl: $mediaUrl, mediaId: $mediaId, extension: $extension, latitude: $latitude, longitude: $longitude, title: $title, address: $address, attachmentType: $attachmentType)';

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
      attachmentType.hashCode;
}
