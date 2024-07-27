import 'dart:convert';
import 'package:flutter/services.dart';

class IsmchPlatformFile {
  IsmchPlatformFile({
    this.path,
    this.name,
    this.bytes,
    this.size,
    this.extension,
  });
  final String? path;

  final String? name;

  final Uint8List? bytes;

  final int? size;

  final String? extension;

  IsmchPlatformFile copyWith({
    String? path,
    String? name,
    Uint8List? bytes,
    int? size,
    String? extension,
  }) =>
      IsmchPlatformFile(
        path: path ?? this.path,
        name: name ?? this.name,
        bytes: bytes ?? this.bytes,
        size: size ?? this.size,
        extension: extension ?? this.extension,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'path': path,
        'name': name,
        'bytes': bytes,
        'size': size,
        'extension': extension,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmchPlatformFile(path: $path, name: $name, bytes: $bytes, size: $size, extension: $extension)';

  @override
  bool operator ==(covariant IsmchPlatformFile other) {
    if (identical(this, other)) return true;

    return other.path == path &&
        other.name == name &&
        other.bytes == bytes &&
        other.size == size &&
        other.extension == extension;
  }

  @override
  int get hashCode =>
      path.hashCode ^
      name.hashCode ^
      bytes.hashCode ^
      size.hashCode ^
      extension.hashCode;
}
