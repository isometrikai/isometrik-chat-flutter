import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_video_thumbnail_plus/flutter_video_thumbnail_plus.dart';

class IsmChatBlob {
  /// call function for create blob url with bytes
  static String blobToUrl(Uint8List bytes) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    return url;
  }

  static Future<Uint8List> blobUrlToBytes(String blobUrl) async {
    final request = html.HttpRequest()
      ..open('GET', blobUrl)
      ..responseType = 'arraybuffer';

    final completer = Completer<Uint8List>();

    request.onLoad.listen((_) {
      if (request.status == 200 || request.status == 0) {
        final buffer = request.response as ByteBuffer;
        final bytes = Uint8List.view(buffer);
        completer.complete(bytes);
      } else {
        completer.completeError('Failed to load blob: ${request.statusText}');
      }
    });

    request.onError.listen((_) {
      completer.completeError('Request failed');
    });

    request.send();

    return completer.future;
  }

  /// call function for create video thumbanil with bytes
  // static Future<Uint8List?> getVideoThumbnailBytes(Uint8List videoBytes) async {
  //   final blob = html.Blob([videoBytes], 'video/mp4');
  //   final url = html.Url.createObjectUrlFromBlob(blob);

  //   final videoElement = html.VideoElement()
  //     ..src = url
  //     // ..crossOrigin = 'anonymous'
  //     ..autoplay = false
  //     ..controls = false
  //     ..muted = true
  //     // ..preload = 'metadata'
  //     ..style.display = 'none';

  //   await videoElement.onLoadedMetadata.first;

  //   await videoElement.play();
  //   await Future.delayed(const Duration(seconds: 1));
  //   videoElement.pause();

  //   final canvas = html.CanvasElement(
  //       width: videoElement.videoWidth, height: videoElement.videoHeight);

  //   canvas.context2D
  //     ..drawImageScaled(
  //         videoElement, 0, 0, videoElement.videoWidth, videoElement.videoHeight)
  //     ..getImageData(0, 0, videoElement.videoWidth, videoElement.videoHeight);
  //   // Get the image data as a byte buffer and convert it to a base64 encoded string.

  //   final thumbnailBytes = await canvas.toBlob('image/jpeg');
  //   videoElement.remove();
  //   html.Url.revokeObjectUrl(url);

  //   final reader = html.FileReader()..readAsArrayBuffer(thumbnailBytes);
  //   await reader.onLoadEnd.first;

  //   return Uint8List.fromList(reader.result as List<int>);
  // }

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
  static Future<Uint8List> generateThumbnail({
    required Uint8List videoBytes,
    num? quality,
  }) async {
    var thumbnailBytes = Uint8List(0);
    try {
      final blob = html.Blob([videoBytes], 'video/mp4');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final videoElement = html.VideoElement()
        ..src = url
        ..style.display = 'none';

      await videoElement.play();
      return Future.delayed(
        const Duration(seconds: 1),
        () async {
          videoElement.pause();
          final canvas = html.CanvasElement(
            width: videoElement.videoWidth,
            height: videoElement.videoHeight,
          );
          canvas.context2D.drawImage(videoElement, 0, 0);
          final thumbnailUrl = canvas.toDataUrl('image/jpeg', quality);
          html.Url.revokeObjectUrl(url);

          // Convert data URL to bytes
          final byteString = thumbnailUrl.split(',').last;
          final bytes = base64.decode(byteString);
          thumbnailBytes = Uint8List.fromList(bytes);
          return thumbnailBytes;
        },
      );
    } catch (e) {
      throw Exception('Please Provide Valid Video Bytes as Uint8List: $e');
    }
  }

  static void fileDownloadWithBytes(
    List<int> bytes, {
    String? downloadName,
  }) {
    // Encode our file in base64
    final base64 = base64Encode(bytes);
    // Create the link with the file
    final anchor =
        html.AnchorElement(href: 'data:application/octet-stream;base64,$base64')
          ..target = 'blank';
    // add the name
    if (downloadName != null) {
      anchor.download = downloadName;
    }
    // trigger download
    html.document.body?.append(anchor);
    anchor
      ..click()
      ..remove();
    return;
  }

  static void fileDownloadWithUrl(String url) {
    html.AnchorElement(href: url)
      ..download = url
      ..click();
  }

  static void permissionCamerAndAudio() async {
    await html.window.navigator.getUserMedia(audio: true, video: true);
  }

  static Future<String> checkPermission(String value) async {
    final status =
        await html.window.navigator.permissions?.query({'name': value});
    return status?.state ?? '';
  }

  static void listenTabAndRefesh() =>
      html.window.onBeforeUnload.listen((event) {});

  static void listenTabAndRefeshOne() {
    html.window.onUnload.listen((event) {});
  }
}
