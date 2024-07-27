import 'package:flutter/services.dart';

class IsmChatBlob {
  /// call function for create blob url with bytes
  static String blobToUrl(Uint8List bytes) => '';

  /// call function for create video thumbanil with bytes
  static Future<Uint8List?> getVideoThumbnailBytes(
          Uint8List videoBytes) async =>
      null;

  ///generate video thumbnail in web...
  static Future<Uint8List> generateThumbnail({
    required Uint8List videoBytes,
    num? quality,
  }) async =>
      Uint8List(0);

  static void fileDownloadWithBytes(
    List<int> bytes, {
    String? downloadName,
  }) {}

  static void fileDownloadWithUrl(String url) {}

  static void permissionCamerAndAudio() async {}

  static Future<String> checkPermission(String value) async => '';

  static listenTabAndRefesh() {}
  static listenTabAndRefeshOne() {}

  static openNewTab(String route) {}
}
