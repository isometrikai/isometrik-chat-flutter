import 'package:isometrik_chat_flutter/src/res/config/video_compression_config.dart';

class AttachmentConfig {
  AttachmentConfig({
    this.attachmentHight = 130,
    this.attachmentShowperLine = 3,
    this.videoCompression,
  });
  int attachmentHight;
  int attachmentShowperLine;

  /// Optional platform-specific video compression before upload (mobile only).
  ///
  /// When null, compression stays enabled with [IsmChatVideoCompressionQuality.defaultQuality]
  /// on iOS and Android — same as the legacy SDK behavior.
  final VideoCompressionConfig? videoCompression;
}
