import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class IsmChatUtility {
  const IsmChatUtility._();

  static bool isLoading = false;

  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  static void openKeyboard() =>
      FocusManager.instance.primaryFocus?.requestFocus();

  /// Method for Do Work After Frame Call Back
  static void doLater(VoidCallback? work) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      work?.call();
    });
  }

  /// Show loader
  static void showLoader() async {
    closeLoader();
    isLoading = true;
    await IsmChatContextWidget.showDialogContext(
      content: const IsmChatLoadingDialog(),
      barrierDismissible: false,
    );
  }

  static void closeLoader() {
    if (isLoading) {
      isLoading = false;
      IsmChatRoute.goBack();
    }
  }

  // /// Show loader
  // static void showLoader() async {
  //   var isLoaderOpen = Get.isDialogOpen;
  //   if (isLoaderOpen != null) {
  //     await IsmChatContextWidget.showDialogContext<void>(
  //       const IsmChatLoadingDialog(),
  //       barrierDismissible: false,
  //     );
  //   }
  // }

  // static void closeLoader() {
  //   var isLoaderOpen = Get.isDialogOpen;
  //   if (isLoaderOpen != null) {
  //     IsmChatRoute.goBack()(closeOverlays: false, canPop: true);
  //   }
  // }

  /// Show error dialog from response model
  static Future<void> showInfoDialog(
    IsmChatResponseModel data, {
    bool isSuccess = false,
    String? title,
    String? label,
    VoidCallback? onTap,
  }) async {
    if (Get.isDialogOpen ?? false) {
      return;
    }
    await IsmChatContextWidget.showDialogContext(
      content: const IsmChatAlertDialogBox(
        title: IsmChatStrings.micePermissionBlock,
        cancelLabel: IsmChatStrings.okay,
      ),
    );
  }

  static Future<void> showErrorDialog(String message,
      {void Function()? onCancel}) async {
    await IsmChatContextWidget.showDialogContext(
      content: IsmChatAlertDialogBox(
        title: message,
        cancelLabel: IsmChatStrings.okay,
        onCancel: onCancel,
      ),
    );
  }

  /// Returns true if the internet connection is available.
  static Future<bool> get isNetworkAvailable async {
    final result = await Connectivity().checkConnectivity();
    return result.any((e) => [
          ConnectivityResult.mobile,
          ConnectivityResult.wifi,
          ConnectivityResult.ethernet,
        ].contains(e));
  }

  /// common header for All api
  static Map<String, String> commonHeader() {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': IsmChatConfig.communicationConfig.projectConfig.licenseKey,
      'appSecret': IsmChatConfig.communicationConfig.projectConfig.appSecret,
      'userSecret': IsmChatConfig.communicationConfig.projectConfig.userSecret,
    };

    return header;
  }

  /// Token common Header for All api
  static Map<String, String> tokenCommonHeader() {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': IsmChatConfig.communicationConfig.projectConfig.licenseKey,
      'appSecret': IsmChatConfig.communicationConfig.projectConfig.appSecret,
      'userToken': IsmChatConfig.communicationConfig.userConfig.userToken,
    };

    return header;
  }

  /// Token common Header for All api
  static Map<String, String> accessTokenCommonHeader({
    bool isDefaultContentType = false,
  }) {
    var header = <String, String>{
      'licenseKey': IsmChatConfig.communicationConfig.projectConfig.licenseKey,
      'appSecret': IsmChatConfig.communicationConfig.projectConfig.appSecret,
      'userToken': IsmChatConfig.communicationConfig.userConfig.userToken,
      'Authorization':
          IsmChatConfig.communicationConfig.userConfig.accessToken ?? ''
    };
    if (isDefaultContentType == true) {
      header.addAll({
        'Content-Type': 'application/json',
      });
    }

    return header;
  }

  // /// this is for change encoded string to decode string
  // static String decodeString(String value) {
  //   try {
  //     return utf8.decode(value.runes.toList());
  //   } catch (e) {
  //     return value;
  //   }
  // }

  // /// this is for change decode string to encode string
  // static String encodeString(String value) => utf8.fuse(base64).encode(value);

  static String encryptMessage(String body, String conversationId) {
    if (conversationId.isNotEmpty) {
      final keyBytes = base64Decode('${conversationId}abcdefab');
      final key = encrypt.Key(keyBytes);
      final iv = encrypt.IV.fromSecureRandom(16); // ✅ Must be 16 bytes
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final encrypted = encrypter.encrypt(body, iv: iv);
      return '${iv.base64}:${encrypted.base64}';
    }
    return body;
  }

  static String generateValidHexString(int length) {
    const hexChars = '0123456789abcdef';
    final random = Random.secure();
    return List.generate(length, (_) => hexChars[random.nextInt(16)]).join();
  }

  static String decryptMessage(String body, String conversationId) {
    try {
      if (conversationId.isNotEmpty) {
        final parts = body.split(':');
        final iv = encrypt.IV.fromBase64(parts[0]);
        final encryptedText = parts[1];
        final key = encrypt.Key(base64Decode('${conversationId}abcdefab'));
        final encrypter = encrypt.Encrypter(encrypt.AES(key));
        return encrypter.decrypt64(encryptedText, iv: iv);
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  static void showToast(String message, {int timeOutInSec = 1}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: timeOutInSec,
      backgroundColor: IsmChatConfig.chatTheme.backgroundColor,
      textColor: IsmChatConfig.chatTheme.primaryColor,
      fontSize: IsmChatDimens.sixteen,
    );
  }

  static Future<List<XFile?>> pickMedia(ImageSource source,
      {bool isVideoAndImage = false}) async {
    List<XFile?> result;

    if (isVideoAndImage) {
      result = await ImagePicker().pickMultipleMedia(
        imageQuality: 25,
        requestFullMetadata: true,
      );
    } else {
      result = [
        await ImagePicker().pickImage(
          imageQuality: 25,
          source: source,
        )
      ];
    }

    if (result.isEmpty) {
      return [];
    }
    if (isVideoAndImage) {
      return result;
    }
    var croppedFile = await ImageCropper().cropImage(
      sourcePath: result.first?.path ?? '',
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper'.tr,
          toolbarColor: IsmChatColors.blackColor,
          toolbarWidgetColor: IsmChatColors.whiteColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Cropper',
          cropStyle: CropStyle.circle,
        ),
        WebUiSettings(
          context: IsmChatConfig.kNavigatorKey.currentContext ??
              IsmChatConfig.context,
        ),
      ],
    );

    if (croppedFile != null) {
      return [XFile(croppedFile.path)];
    }
    return [];
  }

  /// Returns text representation of a provided bytes value (e.g. 1kB, 1GB)
  static String formatBytes(int size, [int fractionDigits = 2]) {
    if (size <= 0) return '0 B';
    final multiple = (log(size) / log(1024)).floor();
    return '${(size / pow(1024, multiple)).toStringAsFixed(fractionDigits)} ${[
      'B',
      'KB',
      'MB',
      'GB',
      'TB',
      'PB',
      'EB',
      'ZB',
      'YB'
    ][multiple]}';
  }

  /// Returns data size representation of a provided file
  static Future<String> fileToSize(File file) async {
    Uint8List? bytes;
    try {
      bytes = file.readAsBytesSync();
    } catch (_) {
      bytes = Uint8List.fromList(
          await File.fromUri(Uri.parse(file.path)).readAsBytes());
    }
    var dataSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    return dataSize;
  }

  /// Returns data size representation of a provided file
  static Future<String> bytesToSize(List<int> bytes) async {
    var dataSize = IsmChatUtility.formatBytes(
      int.parse(bytes.length.toString()),
    );
    return dataSize;
  }

  static Future<Uint8List> fetchBytesFromBlobUrl(String blobUrl) async {
    final response = await http.get(Uri.parse(blobUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      return Uint8List(0);
      // throw Exception('Failed to fetch bytes from Blob URL');
    }
  }

  static Future<File> makeDirectoryWithUrl({
    required String urlPath,
    required String fileName,
  }) async {
    File? file;
    String? path;
    if (urlPath.isValidUrl) {
      final url = Uri.parse(urlPath);
      final response = await http.get(url);
      final bytes = response.bodyBytes;
      final documentsDir =
          (await path_provider.getApplicationDocumentsDirectory()).path;
      path = '$documentsDir/$fileName';
      if (!File(path).existsSync()) {
        file = File(path);
        await file.writeAsBytes(bytes);
      }
    } else {
      final documentsDir =
          (await path_provider.getApplicationDocumentsDirectory()).path;
      path = '$documentsDir/$fileName';
      if (!File(path).existsSync()) {
        file = File(path);
        try {
          final bytes = await file.readAsBytes();
          await file.writeAsBytes(bytes);
        } catch (_) {
          return File(urlPath);
        }
      }
    }
    if (file != null) {
      return file;
    }
    return File(path);
  }

  /// call function for permission for local storage
  static Future<bool> requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();

      if (result == PermissionStatus.granted) {
        return true;
      }
    }
    return false;
  }

  static Widget circularProgressBar(
          [Color? backgroundColor, Color? animatedColor, double? value]) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor?.applyIsmOpacity(.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: CircularProgressIndicator(
          value: value,
          backgroundColor: animatedColor,
          valueColor: AlwaysStoppedAnimation(
            backgroundColor?.applyIsmOpacity(.5),
          ),
        ),
      );

  static Future<Uint8List> urlToUint8List(String url) async {
    var response = await http.get(Uri.parse(url));
    final bytes = response.bodyBytes;
    return bytes;
  }

  static void dialNumber(String phoneNumber) async {
    var number = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(number)) {
      await launchUrl(number);
    }
  }

  static void toSMS(String phoneNumber, [String? body]) async {
    Uri? sms;
    if (body != null) {
      sms = Uri.parse('sms:$phoneNumber?body=$body');
    } else {
      sms = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
    }

    if (await canLaunchUrl(sms)) {
      await launchUrl(sms);
    }
  }

  static Future<void> requestForGallery() async {
    final hasAccess = await Gal.hasAccess(toAlbum: true);
    if (hasAccess == false) {
      await Gal.requestAccess(toAlbum: true);
    }
  }

  static Future<Uint8List> getUint8ListFromUrl(
    String url, {
    InternetFileProgress? progress,
    String method = 'GET',
  }) async {
    final completer = Completer<Uint8List>();
    final httpClient = http.Client();
    final request = http.Request(method, Uri.parse(url));
    final response = httpClient.send(request);
    var bytesList = <int>[];
    var receivedLength = 0;
    response.asStream().listen((http.StreamedResponse request) {
      request.stream.listen(
        (List<int> chunk) {
          receivedLength += chunk.length;
          final contentLength = request.contentLength ?? receivedLength;
          progress?.call(receivedLength, contentLength);

          bytesList.addAll(chunk);
        },
        onDone: () {
          final bytes = Uint8List.fromList(bytesList);
          completer.complete(bytes);
        },
        onError: completer.completeError,
      );
    }, onError: completer.completeError);
    return completer.future;
  }

  static Future<void> downloadMediaFromLocalPath({
    required String url,
    bool isVideo = false,
    String? albumName,
  }) async {
    try {
      if (isVideo) {
        await Gal.putVideo(
          url,
          album: albumName ?? 'IsmChat',
        );
      } else {
        await Gal.putImage(
          url,
          album: albumName ?? 'IsmChat',
        );
      }
      IsmChatUtility.showToast('Save your media');
    } on GalException catch (e, st) {
      IsmChatLog.error('error $e stack straas $st');
    }
  }

  static Future<void> downloadMediaFromNetworkPath({
    required String url,
    bool isVideo = false,
    String? albumName,
    required Function(int) downloadProgrees,
  }) async {
    try {
      final path = '${Directory.systemTemp.path}/${basename(url)}';
      var dio = Dio();
      final res = await dio.download(
        url,
        path,
        onReceiveProgress: (count, total) async {
          var percentage = ((count / total) * 100).floor();
          downloadProgrees.call(percentage);
        },
      );
      if (res.statusCode == 200) {
        if (isVideo) {
          await Gal.putVideo(
            path,
            album: albumName ?? 'IsmChat',
          );
        } else {
          await Gal.putImage(
            path,
            album: albumName ?? 'IsmChat',
          );
        }

        IsmChatUtility.showToast('Save your media');
      }
    } on GalException catch (e, st) {
      IsmChatLog.error('error $e stack straas $st');
    }

    // ********** With out package and create folder name and download any files
    //  Directory? directory;
    // if (GetPlatform.isAndroid) {
    //   if (await IsmChatUtility.requestPermission(Permission.storage) &&
    //       // access media location needed for android 10/Q
    //       await IsmChatUtility.requestPermission(
    //           Permission.accessMediaLocation) &&
    //       // manage external storage needed for android 11/R
    //       await IsmChatUtility.requestPermission(
    //         Permission.manageExternalStorage,
    //       )) {
    //     directory = await path_provider.getExternalStorageDirectory();
    //     var newPath = '';
    //     var paths = directory!.path.split('/');
    //     for (var x = 1; x < paths.length; x++) {
    //       var folder = paths[x];
    //       if (folder != 'Android') {
    //         newPath += '/$folder';
    //       } else {
    //         break;
    //       }
    //     }
    //     newPath = '$newPath/ChatApp';
    //     directory = Directory(newPath);
    //   } else {
    //     await openAppSettings();
    //     return;
    //   }
    // } else {
    //   if (await IsmChatUtility.requestPermission(Permission.photos)) {
    //     directory = await path_provider.getTemporaryDirectory();
    //   } else {
    //     await openAppSettings();
    //     return;
    //   }
    // }

    // if (!await directory.exists()) {
    //   await directory.create(recursive: true);
    // }
    // if (await directory.exists()) {
    //   var saveFile =
    //       File('${directory.path}/${message.attachments?.first.name}');

    //   await dio.download(
    //     message.attachments?.first.mediaUrl ?? '',
    //     saveFile.path,
    //   );

    //   if (GetPlatform.isIOS) {
    //     await ImageGallerySaver
    //     saveFile(saveFile.path,
    //         name: message.attachments?.first.name, isReturnPathOfIOS: true);
    //   }
    // }
  }

  static Widget buildSusWidget(String susTag) => Container(
        padding: IsmChatDimens.edgeInsets10_0,
        height: IsmChatDimens.forty,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: susTag != '#'
            ? Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    susTag,
                    textScaler: const TextScaler.linear(1.5),
                    style: IsmChatStyles.w600Black14,
                  ),
                  if (!IsmChatResponsive.isWeb(
                      IsmChatConfig.kNavigatorKey.currentContext ??
                          IsmChatConfig.context))
                    SizedBox(
                        width: IsmChatDimens.percentWidth(.8),
                        child: Divider(
                          height: .0,
                          indent: IsmChatDimens.ten,
                        ))
                ],
              )
            : Text(
                '${IsmChatStrings.inviteToChat} ${IsmChatConfig.communicationConfig.projectConfig.appName}',
                style: IsmChatStyles.w600Black14
                    .copyWith(color: const Color(0xff9E9CAB))),
      );

  static Future<File> convertToJpeg(File file) async {
    var imageBytes = await file.readAsBytes();
    var image = img.decodeImage(imageBytes);
    if (image == null) return file;
    List<int> jpegBytes = img.encodeJpg(image);
    final savedFile = File(
        await getSavePath('${DateTime.now().millisecondsSinceEpoch}.jpeg'));
    await savedFile.writeAsBytes(jpegBytes);
    return savedFile;
    // try {
    //   final decodedWebP = await img.decodeImageFile(file.absolute.path);
    //   if (decodedWebP == null) {
    //     throw Exception('Unable to Decode File');
    //   }
    //   final encodeJpeg = img.encodeJpg(decodedWebP);
    //   final savedFile = File(
    //       await getSavePath('${DateTime.now().millisecondsSinceEpoch}.jpeg'));
    //   await savedFile.writeAsBytes(encodeJpeg);
    //   return savedFile;
    // } catch (e) {
    //   return file;
    // }
  }

  static Future<String> getSavePath(String filename) async {
    final directory = await getTemporaryDirectory();
    return '${directory.path}/$filename';
  }

  static IsmChatConversationsController get conversationController =>
      Get.find<IsmChatConversationsController>(tag: IsmChat.i.chatListPageTag);

  static bool get conversationControllerRegistered =>
      Get.isRegistered<IsmChatConversationsController>(
          tag: IsmChat.i.chatListPageTag);

  static IsmChatPageController get chatPageController =>
      Get.find<IsmChatPageController>(tag: IsmChat.i.chatPageTag);

  static bool get chatPageControllerRegistered =>
      Get.isRegistered<IsmChatPageController>(tag: IsmChat.i.chatPageTag);

  static bool isOnlyEmoji(String text) {
    final emojiRegex = RegExp(
      r'^('
      r'[\u{1F600}-\u{1F64F}]|' // Emoticons
      r'[\u{1F300}-\u{1F5FF}]|' // Symbols & Pictographs
      r'[\u{1F680}-\u{1F6FF}]|' // Transport & Map
      r'[\u{2600}-\u{26FF}]|' // Misc symbols
      r'[\u{2700}-\u{27BF}]|' // Dingbats
      r'[\u{1F1E6}-\u{1F1FF}]|' // Flags
      r'[\u{1F900}-\u{1F9FF}]|' // Supplemental symbols
      r'[\u{1FA70}-\u{1FAFF}]|' // Extended pictographs
      r'[\u{200D}]|' // Zero width joiner
      r'[\u{FE0F}]' // Emoji variation selector
      r')+$',
      unicode: true,
    );
    return emojiRegex.hasMatch(text);
  }
}
