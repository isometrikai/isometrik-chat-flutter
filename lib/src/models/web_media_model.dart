import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class WebMediaModel {
  WebMediaModel({
    required this.platformFile,
    required this.isVideo,
    required this.dataSize,
    this.caption,
    this.duration,
  });
  IsmchPlatformFile platformFile;
  bool isVideo;

  String dataSize;
  String? caption;
  Duration? duration;

  WebMediaModel copyWith({
    IsmchPlatformFile? platformFile,
    bool? isVideo,
    String? dataSize,
    String? caption,
    Duration? duration,
  }) =>
      WebMediaModel(
        platformFile: platformFile ?? this.platformFile,
        isVideo: isVideo ?? this.isVideo,
        dataSize: dataSize ?? this.dataSize,
        caption: caption ?? this.caption,
        duration: duration ?? this.duration,
      );
}
