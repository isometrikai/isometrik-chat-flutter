import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

  static void dismissKeyBoard() {
    FocusScope.of(Get.context!).unfocus();
  }

  /// Method for Do Work After Frame Call Back
  static void doLater(VoidCallback? work) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      work?.call();
    });
  }

  /// Show loader
  static void showLoader() async {
    closeLoader();
    await Get.dialog<void>(
      const IsmChatLoadingDialog(),
      barrierDismissible: false,
    );
  }

  static void closeLoader() {
    if (Get.isDialogOpen == true) {
      Get.back(closeOverlays: false, canPop: true);
    }
  }

  // /// Show loader
  // static void showLoader() async {
  //   var isLoaderOpen = Get.isDialogOpen;
  //   if (isLoaderOpen != null) {
  //     await Get.dialog<void>(
  //       const IsmChatLoadingDialog(),
  //       barrierDismissible: false,
  //     );
  //   }
  // }

  // static void closeLoader() {
  //   var isLoaderOpen = Get.isDialogOpen;
  //   if (isLoaderOpen != null) {
  //     Get.back(closeOverlays: false, canPop: true);
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
    await Get.dialog(
      CupertinoAlertDialog(
        title: Text(
          title ?? (isSuccess ? 'Success' : 'Error'),
        ),
        content: Text(
          jsonDecode(data.data)['message'] as String,
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: Get.back,
            isDefaultAction: true,
            child: Text(
              'Okay',
              style: IsmChatStyles.w400Black14,
            ),
          ),
          if (label != null)
            CupertinoDialogAction(
              onPressed: () {
                Get.back();
                onTap?.call();
              },
              isDefaultAction: true,
              child: Text(
                label,
                style: IsmChatStyles.w400Black14,
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> showErrorDialog(String message) async {
    await Get.dialog(
      IsmChatAlertDialogBox(
        title: message,
        cancelLabel: IsmChatStrings.okay,
      ),
    );
  }

  static Future<T?> openFullScreenBottomSheet<T>(
    Widget child, {
    bool isDismissible = false,
    bool ignoreSafeArea = false,
    bool enableDrag = false,
    Color? backgroundColor,
    ShapeBorder? shape,
  }) async =>
      await Get.bottomSheet<T>(
        child,
        isDismissible: isDismissible,
        isScrollControlled: true,
        ignoreSafeArea: ignoreSafeArea,
        enableDrag: enableDrag,
        backgroundColor: backgroundColor,
        shape: shape,
      );

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
    isDefaultContentType = false,
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

  /// this is for change encoded string to decode string
  static String decodeString(String value) {
    try {
      return utf8.decode(value.runes.toList());
    } catch (e) {
      return value;
    }
  }

  /// this is for change decode string to encode string
  static String encodeString(String value) => utf8.fuse(base64).encode(value);

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
          // cropStyle: CropStyle.circle,
        ),
        IOSUiSettings(
          title: 'Cropper',

          // cropStyle: CropStyle.circle,
        )
      ],
    );
    return [XFile(croppedFile!.path)];
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
          color: backgroundColor?.withOpacity(.5),
          borderRadius: BorderRadius.circular(15),
        ),
        child: CircularProgressIndicator(
          value: value,
          backgroundColor: animatedColor,
          valueColor: AlwaysStoppedAnimation(
            backgroundColor?.withOpacity(.5),
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
                  if (!IsmChatResponsive.isWeb(Get.context!))
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
    final decodedWebP = await img.decodeImageFile(file.path);
    if (decodedWebP == null) {
      throw Exception('Unable to Decode File');
    }
    final encodeJpeg = img.encodeJpg(decodedWebP);
    final savedFile = File(
        await getSavePath('${DateTime.now().millisecondsSinceEpoch}.jpeg'));
    await savedFile.writeAsBytes(encodeJpeg);
    return savedFile;
  }

  static Future<String> getSavePath(String filename) async {
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$filename';
  }
}
