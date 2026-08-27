/// A normalized Giphy asset used by the GIF/sticker picker.
class IsmGiphyItem {
  const IsmGiphyItem({
    required this.id,
    required this.previewUrl,
    required this.sendUrl,
    required this.extension,
    this.width,
    this.height,
  });

  factory IsmGiphyItem.fromMap(Map<String, dynamic> map) {
    final images = _asStringKeyedMap(map['images']);
    // May be {} when Giphy omits/renames renditions — never assume keys exist.
    final preview = _pickImageMap(images, preferStill: true);
    final send = _pickImageMap(images, preferStill: false);
    final sendUrl = send['url'] as String? ?? '';
    final extension = _extensionFromUrl(sendUrl);

    return IsmGiphyItem(
      id: map['id'] as String? ?? '',
      previewUrl: preview['url'] as String? ?? sendUrl,
      sendUrl: sendUrl,
      extension: extension,
      // Prefer send-rendition size; fall back to preview. Missing keys → null
      // via [_parseDimension] (empty maps do not throw on `[]` in Dart).
      width: _parseDimension(send['width'] ?? preview['width']),
      height: _parseDimension(send['height'] ?? preview['height']),
    );
  }

  final String id;
  final String previewUrl;
  final String sendUrl;
  final String extension;
  final int? width;
  final int? height;

  /// True when this item has a usable CDN URL (filter after parsing from Giphy).
  bool get hasSendableUrl => sendUrl.isNotEmpty;

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

  /// Normalizes JSON maps that may be `Map<dynamic, dynamic>` after decode.
  /// Reuse instead of `as Map<String, dynamic>?` on nested Giphy payloads.
  static Map<String, dynamic> _asStringKeyedMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  static Map<String, dynamic> _pickImageMap(
    Map<String, dynamic> images, {
    required bool preferStill,
  }) {
    const stillKeys = [
      'fixed_height_small_still',
      'preview_gif',
      'downsized_still',
      'fixed_width_still',
    ];
    const animatedKeys = [
      'downsized',
      'fixed_height',
      'fixed_width',
      'original',
    ];
    final keys = preferStill ? stillKeys : animatedKeys;
    for (final key in keys) {
      final candidate = _asStringKeyedMap(images[key]);
      if ((candidate['url'] as String? ?? '').isNotEmpty) {
        return candidate;
      }
    }
    for (final value in images.values) {
      final candidate = _asStringKeyedMap(value);
      if ((candidate['url'] as String? ?? '').isNotEmpty) {
        return candidate;
      }
    }
    // Explicit empty map: callers must null-check url / width / height.
    return {};
  }

  static String _extensionFromUrl(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    final ext = path.split('.').last.toLowerCase();
    if (ext == 'webp' || ext == 'gif' || ext == 'png' || ext == 'jpg') {
      return ext;
    }
    return 'gif';
  }
}
