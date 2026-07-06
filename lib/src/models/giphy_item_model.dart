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
    final images = map['images'] as Map<String, dynamic>? ?? {};
    final preview = _pickImageMap(images, preferStill: true);
    final send = _pickImageMap(images, preferStill: false);
    final sendUrl = send['url'] as String? ?? '';
    final extension = _extensionFromUrl(sendUrl);

    return IsmGiphyItem(
      id: map['id'] as String? ?? '',
      previewUrl: preview['url'] as String? ?? sendUrl,
      sendUrl: sendUrl,
      extension: extension,
      width: int.tryParse(preview['width'] as String? ?? ''),
      height: int.tryParse(preview['height'] as String? ?? ''),
    );
  }

  final String id;
  final String previewUrl;
  final String sendUrl;
  final String extension;
  final int? width;
  final int? height;

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
      final value = images[key];
      if (value is Map<String, dynamic> &&
          (value['url'] as String? ?? '').isNotEmpty) {
        return value;
      }
    }
    for (final value in images.values) {
      if (value is Map<String, dynamic> &&
          (value['url'] as String? ?? '').isNotEmpty) {
        return value;
      }
    }
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
