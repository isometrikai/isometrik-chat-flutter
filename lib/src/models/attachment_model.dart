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
    this.mediaWidth,
    this.mediaHeight,
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
        // Pixel size used to reserve GIF/sticker layout before decode.
        mediaWidth: _parseDimension(map['mediaWidth'] ?? map['width']),
        mediaHeight: _parseDimension(map['mediaHeight'] ?? map['height']),
        // Prefer base64 (see [toMap]); still accepts legacy list-string form.
        bytes: _parseBytes(map['bytes']),
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
  /// Intrinsic width in pixels (e.g. from Giphy). Used for stable GIF layout.
  int? mediaWidth;
  /// Intrinsic height in pixels (e.g. from Giphy). Used for stable GIF layout.
  int? mediaHeight;
  final IsmChatMediaType? attachmentType;

  /// Parses width/height that may arrive as int, double, or string.
  static int? _parseDimension(dynamic value) {
    if (value == null) return null;
    if (value is int) return value > 0 ? value : null;
    if (value is double) return value > 0 ? value.round() : null;
    if (value is String) {
      final parsed = int.tryParse(value);
      return parsed != null && parsed > 0 ? parsed : null;
    }
    return null;
  }

  /// Restores [bytes] from map/JSON.
  ///
  /// Supported forms (reuse this helper — do not re-implement ad hoc):
  /// - base64 string (preferred; written by [toMap])
  /// - legacy `Uint8List.toString()` / JSON array string e.g. `"[1, 2, 3]"`
  /// - raw [Uint8List] or `List<int>`
  static Uint8List _parseBytes(dynamic value) {
    if (value == null || value == '' || value == 'null') {
      return Uint8List(0);
    }
    if (value is Uint8List) {
      return value;
    }
    if (value is List) {
      try {
        return Uint8List.fromList(List<int>.from(value));
      } catch (_) {
        return Uint8List(0);
      }
    }
    if (value is! String) {
      return Uint8List(0);
    }
    final encoded = value.trim();
    if (encoded.isEmpty || encoded == 'null') {
      return Uint8List(0);
    }
    // Legacy path: decimal list from bytes.toString() / jsonEncode(list).
    if (encoded.startsWith('[')) {
      try {
        return encoded.strigToUnit8List;
      } catch (_) {
        return Uint8List(0);
      }
    }
    try {
      return base64Decode(encoded);
    } catch (_) {
      return Uint8List(0);
    }
  }

  /// Serializes [bytes] for map/JSON (base64). Empty/null → `''`.
  ///
  /// Do not use [Uint8List.toString] — it is not a stable wire format and
  /// inflates payload size vs base64.
  static String _encodeBytes(Uint8List? value) {
    if (value == null || value.isEmpty) {
      return '';
    }
    return base64Encode(value);
  }

  /// Aspect ratio for layout; null when dimensions are unknown.
  double? get mediaAspectRatio {
    final w = mediaWidth;
    final h = mediaHeight;
    if (w == null || h == null || w <= 0 || h <= 0) return null;
    return w / h;
  }

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
    int? mediaWidth,
    int? mediaHeight,
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
        mediaWidth: mediaWidth ?? this.mediaWidth,
        mediaHeight: mediaHeight ?? this.mediaHeight,
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
        'mediaWidth': mediaWidth,
        'mediaHeight': mediaHeight,
        // Base64 preserves binary; see [_encodeBytes] / [_parseBytes].
        'bytes': _encodeBytes(bytes),
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
        // Optional — helps receivers reserve the same layout size.
        if (mediaWidth != null) 'mediaWidth': mediaWidth,
        if (mediaHeight != null) 'mediaHeight': mediaHeight,
      };
    }

    final map = toMap();
    map.remove('bytes');
    return map;
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'AttachmentModel(thumbnailUrl: $thumbnailUrl, size: $size, name: $name, mimeType: $mimeType, mediaUrl: $mediaUrl, mediaId: $mediaId, extension: $extension, latitude: $latitude, longitude: $longitude, title: $title, address: $address, attachmentType: $attachmentType, stillUrl: $stillUrl, mediaWidth: $mediaWidth, mediaHeight: $mediaHeight, bytes: $bytes)';

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
        other.mediaWidth == mediaWidth &&
        other.mediaHeight == mediaHeight &&
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
      mediaWidth.hashCode ^
      mediaHeight.hashCode ^
      bytes.hashCode ^
      attachmentType.hashCode;
}
