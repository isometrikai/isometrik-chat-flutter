import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;

class IsmChatBlob {
  /// call function for create blob url with bytes
  static String blobToUrl(Uint8List bytes) => '';

  static Future<Uint8List> blobUrlToBytes(String blobUrl) async => Uint8List(0);

  // call function for create video thumbanil with bytes
  static Future<Uint8List?> getVideoThumbnailBytesWithPackage(
      Uint8List videoBytes) async {
    try {
      print('=== TESTING NEW PACKAGE FUNCTION ===');
      print(
          'Starting thumbnail generation with flutter_video_thumbnail_plus for ${videoBytes.length} bytes');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');

      if (kIsWeb) {
        // Web implementation - use thumbnailDataWeb for direct byte processing
        print('🌐 WEB: Using thumbnailDataWeb for direct byte processing');

        try {
          // Generate thumbnail using package with bytes directly
          final thumbnailData =
              await FlutterVideoThumbnailPlus.thumbnailDataWeb(
            videoBytes: videoBytes,
            quality: 100,
          );

          if (thumbnailData != null && thumbnailData.isNotEmpty) {
            print(
                '✅ SUCCESS: Web thumbnail generated: ${thumbnailData.length} bytes');
            return thumbnailData;
          } else {
            print('❌ FAILED: Web package returned empty data');
            return null;
          }
        } catch (e) {
          print('❌ ERROR: Web package failed: $e');
          print('Stack trace: ${StackTrace.current}');
          return null;
        }
      } else {
        // Mobile implementation - save to temporary file first
        print('📱 MOBILE: Creating temporary file for thumbnail generation');

        try {
          // Create a temporary file
          final tempDir = await Directory.systemTemp.createTemp();
          final tempFile = File(
              '${tempDir.path}/temp_video_${DateTime.now().millisecondsSinceEpoch}.mp4');
          await tempFile.writeAsBytes(videoBytes);
          print('Created temp file: ${tempFile.path}');
          print('Temp file exists: ${await tempFile.exists()}');
          print('Temp file size: ${await tempFile.length()} bytes');

          // Generate thumbnail using the package with file path
          print(
              'Calling FlutterVideoThumbnailPlus.thumbnailData with file path...');
          final thumbnailData = await FlutterVideoThumbnailPlus.thumbnailData(
            video: tempFile.path,
            imageFormat: ImageFormat.jpeg,
            maxHeight: 720,
            maxWidth: 1280,
            quality: 95,
          );

          print('Package returned: ${thumbnailData?.length ?? 0} bytes');

          // Clean up temp file
          await tempFile.delete();
          print('Deleted temp file');

          if (thumbnailData != null && thumbnailData.isNotEmpty) {
            print(
                '✅ SUCCESS: Mobile thumbnail generated: ${thumbnailData.length} bytes');
            return thumbnailData;
          } else {
            print('❌ FAILED: Mobile package returned empty data');
            return null;
          }
        } catch (e) {
          print('❌ ERROR: Mobile package failed: $e');
          print('Stack trace: ${StackTrace.current}');
          return null;
        }
      }
    } catch (e) {
      print('❌ ERROR: Test function failed: $e');
      return null;
    }
  }

  ///generate video thumbnail in web...
  // static Future<Uint8List> generateThumbnail({
  //   required Uint8List videoBytes,
  //   num? quality,
  // }) async =>
  //     Uint8List(0);

  static void fileDownloadWithBytes(
    List<int> bytes, {
    String? downloadName,
  }) {}

  static void fileDownloadWithUrl(String url) {}

  static void permissionCamerAndAudio() async {}

  static Future<String> checkPermission(String value) async => '';

  static void listenTabAndRefesh() {}
  static void listenTabAndRefeshOne() {}

  static void openNewTab(String route) {}
}
