import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmchPlatformFile {
  IsmchPlatformFile({
    this.path,
    this.name,
    this.bytes,
    this.size,
    this.extension,
    this.thumbnailBytes,
  });
  String? path;

  String? name;

  Uint8List? bytes;

  int? size;

  String? extension;

  Uint8List? thumbnailBytes;

  IsmchPlatformFile copyWith({
    String? path,
    String? name,
    Uint8List? bytes,
    int? size,
    String? extension,
    Uint8List? thumbnailBytes,
  }) =>
      IsmchPlatformFile(
        path: path ?? this.path,
        name: name ?? this.name,
        bytes: bytes ?? this.bytes,
        size: size ?? this.size,
        extension: extension ?? this.extension,
        thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'path': path,
        'name': name,
        'bytes': bytes,
        'size': size,
        'extension': extension,
        'thumbnailBytes': thumbnailBytes,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmchPlatformFile(path: $path, name: $name, bytes: $bytes, size: $size, extension: $extension, thumbnailBytes: $thumbnailBytes)';

  @override
  bool operator ==(covariant IsmchPlatformFile other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.name == name &&
        other.bytes == bytes &&
        other.size == size &&
        other.thumbnailBytes == thumbnailBytes &&
        other.extension == extension;
  }

  @override
  int get hashCode =>
      path.hashCode ^
      name.hashCode ^
      bytes.hashCode ^
      size.hashCode ^
      thumbnailBytes.hashCode ^
      extension.hashCode;
}
