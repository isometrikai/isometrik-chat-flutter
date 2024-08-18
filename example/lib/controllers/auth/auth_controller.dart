import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_component_example/res/res.dart';
import 'package:chat_component_example/utilities/utilities.dart';
import 'package:chat_component_example/view_models/view_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class AuthController extends GetxController {
  final AuthViewModel _viewModel;
  AuthController(this._viewModel);

  var loginFormKey = GlobalKey<FormState>();
  var signFormKey = GlobalKey<FormState>();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();
  var userNameController = TextEditingController();
  var confirmPasswordController = TextEditingController();

  void validateLogin() {
    if (loginFormKey.currentState!.validate()) {
      login();
    }
  }

  Future<void> login() async {
    var response = await _viewModel.login(
      userNameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (response.data != null) {
      await AppConfig.getUserData();
      Get.offAllNamed(AppRoutes.chatList);
    } else if (response.statusCode == 401) {
      Get.back();
      await Get.dialog(
        AlertDialog(
          title: const Text('Alert message...'),
          content: const Text('Incorrect userIdentifier or password.'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text(
                'Okay',
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      );
    } else if (response.statusCode == 404) {
      Get.back();
      await Get.dialog(
        AlertDialog(
          title: const Text('Alert message...'),
          content: const Text('User not found.'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text(
                'Okay',
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      );
    }
  }

  void validateSignUp() {
    if (signFormKey.currentState!.validate()) {
      postCreateUser();
    }
  }

  final RxString _profileImage = ''.obs;
  String get profileImage => _profileImage.value;
  set profileImage(String value) {
    _profileImage.value = value;
  }

  final RxBool _isEmailValid = false.obs;
  bool get isEmailValid => _isEmailValid.value;
  set isEmailValid(bool value) {
    _isEmailValid.value = value;
  }

  final RxBool _isPassward = true.obs;
  bool get isPassward => _isPassward.value;
  set isPassward(bool value) {
    _isPassward.value = value;
  }

  final RxBool _isConfirmPasswared = true.obs;
  bool get isConfirmPasswared => _isConfirmPasswared.value;
  set isConfirmPasswared(bool value) {
    _isConfirmPasswared.value = value;
  }

  void ismUploadImage(ImageSource imageSource) async {
    XFile? result;
    if (imageSource == ImageSource.gallery) {
      result =
          await ImagePicker().pickImage(imageQuality: 25, source: imageSource);
    } else {
      result = await ImagePicker().pickImage(
        imageQuality: 25,
        source: imageSource,
      );
    }
    Uint8List? bytes;
    String? extension;
    if (result != null) {
      if (!IsmChatResponsive.isWeb(Get.context!)) {
        var croppedFile = await ImageCropper().cropImage(
          sourcePath: result.path,
          compressQuality: 100,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper'.tr,
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              cropStyle: CropStyle.circle,
            ),
            IOSUiSettings(
              title: 'Cropper',
              cropStyle: CropStyle.circle,
            ),
            WebUiSettings(
              context: Get.context!,
              customDialogBuilder: (cropper, _, __, ___, ____) {
                return Dialog(
                  child: Builder(
                    builder: (context) {
                      return SizedBox(
                        height: 200,
                        width: 200,
                        child: cropper,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        );
        bytes = File(croppedFile!.path).readAsBytesSync();
        extension = result.name.split('.').last;
      } else {
        bytes = await result.readAsBytes();
        extension = 'jpg';
      }

      Utility.showLoader();
      await ismGetPresignedUrl(extension, bytes);
      Get.back();
    }
  }

  Future<void> postCreateUser() async {
    var creatUser = <String, dynamic>{
      'userProfileImageUrl': profileImage,
      'userName': userNameController.text.trim(),
      'userIdentifier': emailController.text.trim(),
      'password': confirmPasswordController.text.trim(),
      'metaData': {'country': 'India'}
    };
    var response =
        await _viewModel.postCreateUser(isLoading: true, createUser: creatUser);
    if (response.data != null) {
      await AppConfig.getUserData();
      Get.offAllNamed(AppRoutes.chatList);
    } else if (response.statusCode == 409) {
      Get.back();
      await Get.dialog(
        AlertDialog(
          title: const Text('Alert message...'),
          content: const Text('This email address has already been registered'),
          actions: [
            TextButton(
              onPressed: Get.back,
              child: const Text(
                'Okay',
                style: TextStyle(fontSize: 15),
              ),
            )
          ],
        ),
      );
    }
  }

  // / get Api for presigned Url.....
  Future<void> ismGetPresignedUrl(
      String mediaExtension, Uint8List bytes) async {
    var response = await _viewModel.ismGetPresignedUrl(
        isLoading: true,
        userIdentifier: emailController.text,
        mediaExtension: mediaExtension);
    if (response != null) {
      Get.back();
      var urlResponse =
          await updatePresignedUrl(response.presignedUrl ?? '', bytes);
      if (urlResponse == 200) {
        profileImage = response.mediaUrl!;
        Get.back();
      }
    }
  }

  /// put Api for updatePresignedUrl...
  Future<int?> updatePresignedUrl(String presignedUrl, Uint8List bytes) async {
    var response = await _viewModel.updatePresignedUrl(
        isLoading: true, presignedUrl: presignedUrl, file: bytes);
    if (response!.errorCode == 200) {
      return response.errorCode;
    } else {
      return 404;
    }
  }
}
