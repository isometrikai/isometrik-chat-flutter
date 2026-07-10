/// Platform-specific video compression settings applied before upload on mobile.
///
/// Web uploads are unchanged (no client-side compression).
///
/// Defaults match the previous SDK behavior: compression enabled with
/// [IsmChatVideoCompressionQuality.defaultQuality] on iOS and Android.
class VideoCompressionConfig {
  const VideoCompressionConfig({
    this.ios = const IsmChatVideoCompressionSettings(),
    this.android = const IsmChatVideoCompressionSettings(),
  });

  final IsmChatVideoCompressionSettings ios;
  final IsmChatVideoCompressionSettings android;
}

/// Per-platform video compression behavior.
class IsmChatVideoCompressionSettings {
  const IsmChatVideoCompressionSettings({
    this.enabled = true,
    this.quality = IsmChatVideoCompressionQuality.defaultQuality,
  });

  /// When `false`, the original video file is uploaded without compression.
  final bool enabled;

  /// Compression preset used when [enabled] is `true`.
  final IsmChatVideoCompressionQuality quality;
}

/// SDK-facing compression presets (maps to `video_compress` internally).
enum IsmChatVideoCompressionQuality {
  defaultQuality,
  lowQuality,
  mediumQuality,
  highestQuality,
  res640x480,
  res960x540,
  res1280x720,
  res1920x1080,
}
