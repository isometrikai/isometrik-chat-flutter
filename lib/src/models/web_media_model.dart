// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:typed_data';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class WebMediaModel {
  final IsmchPlatformFile platformFile;
  final bool isVideo;
  final Uint8List thumbnailBytes;
  final String dataSize;
  final String? caption;
  Duration? duration;
  WebMediaModel({
    required this.platformFile,
    required this.isVideo,
    required this.thumbnailBytes,
    required this.dataSize,
    this.caption,
    this.duration,
  });

  WebMediaModel copyWith({
    IsmchPlatformFile? platformFile,
    bool? isVideo,
    Uint8List? thumbnailBytes,
    String? dataSize,
    String? caption,
    Duration? duration,
  }) =>
      WebMediaModel(
        platformFile: platformFile ?? this.platformFile,
        isVideo: isVideo ?? this.isVideo,
        thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
        dataSize: dataSize ?? this.dataSize,
        caption: caption ?? this.caption,
        duration: duration ?? this.duration,
      );
}
