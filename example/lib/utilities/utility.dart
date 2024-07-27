import 'package:chat_component_example/res/res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Utility {
  const Utility._();

  static bool isLoaderOpen = Get.isDialogOpen ?? false;

  /// Show loader
  static void showLoader() async {
    if (!isLoaderOpen) {
      await Get.dialog<void>(
        loadingDialog(),
        barrierDismissible: false,
      );
    }
  }

  static Widget loadingDialog() => const Center(
        child: SizedBox(
          height: 60,
          width: 60,
          child: Card(
            color: AppColors.backgroundColorLight,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(
                color: AppColors.primaryColorLight,
              ),
            ),
          ),
        ),
      );

  static void closeLoader() {
    if (isLoaderOpen) {
      Get.back(closeOverlays: true, canPop: false);
    }
  }

  /// common header for All api
  static Map<String, String> commonHeader() {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': Constants.licenseKey,
      'appSecret': Constants.appSecret,
      'userSecret': Constants.userSecret,
    };

    return header;
  }

  /// Token common Header for All api
  static Map<String, String> tokenCommonHeader(String token) {
    var header = <String, String>{
      'Content-Type': 'application/json',
      'licenseKey': Constants.licenseKey,
      'appSecret': Constants.appSecret,
      'userToken': token,
    };
    return header;
  }
}
