import 'package:chat_component_example/controllers/auth/auth_controller.dart';
import 'package:chat_component_example/res/res.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

import '../res/dimens.dart';
import '../widgets/widgets.dart';

/// The view part of the [IsmSignupView], which will be used to
/// show the Signup view page
class SignupView extends StatelessWidget {
  const SignupView({super.key});

  static const String route = AppRoutes.signUp;

  @override
  Widget build(BuildContext context) =>
      GetX<AuthController>(builder: (controller) {
        return SafeArea(
          bottom: false,
          top: false,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              automaticallyImplyLeading: false,
              backgroundColor: AppColors.primaryColorLight,
              title: Text(Strings.signUp,
                  style: const TextStyle(color: AppColors.whiteColor)),
            ),
            body: SingleChildScrollView(
              child: Form(
                key: controller.signFormKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: Center(
                    child: SizedBox(
                      width: ResponsiveExample.isWeb(context)
                          ? Dimens.percentWidth(.3)
                          : null,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                if (IsmChatResponsive.isWeb(context)) {
                                  controller.ismUploadImage(
                                    ImageSource.gallery,
                                  );
                                } else {
                                  Get.bottomSheet<void>(
                                    Container(
                                        padding: const EdgeInsets.all(20),
                                        height: 180,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Get.back<void>();
                                                    controller.ismUploadImage(
                                                        ImageSource.camera);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        // padding: IsmDimens.edgeInsets8,
                                                        decoration: const BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            50)),
                                                            color: Colors
                                                                .blueAccent),
                                                        width: 50,
                                                        height: 50,
                                                        child: const Icon(
                                                          Icons.camera_alt,
                                                          color: Colors.white,
                                                          size: 25,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                        'Camera',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Get.back<void>();
                                                    controller.ismUploadImage(
                                                        ImageSource.gallery);
                                                  },
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        // padding: IsmDimens.edgeInsets8,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50),
                                                            color: Colors
                                                                .purpleAccent),
                                                        width: 50,
                                                        height: 50,
                                                        child: const Icon(
                                                          Icons.photo,
                                                          color: Colors.white,
                                                          size: 25,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      const Text(
                                                        'Gallery',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 20),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                                    elevation: 25,
                                    enableDrag: true,
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(25),
                                        topRight: Radius.circular(25),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Stack(
                                children: [
                                  Tooltip(
                                    message: 'Enter email first',
                                    triggerMode: controller.isEmailValid
                                        ? null
                                        : TooltipTriggerMode.tap,
                                    child: SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        backgroundImage:
                                            controller.profileImage.isEmpty
                                                ? const AssetImage(
                                                        AssetConstants.noImage)
                                                    as ImageProvider
                                                : NetworkImage(controller
                                                    .profileImage
                                                    .toString()),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 0,
                                    child: GetUtils.isEmail(
                                            controller.emailController.text)
                                        ? Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(50),
                                                border: Border.all(
                                                    color: Colors.grey)),
                                            width: 30,
                                            height: 30,
                                            child: const Icon(
                                              Icons.edit,
                                              color: Colors.grey,
                                              size: 15,
                                            ),
                                          )
                                        : const SizedBox.shrink(),
                                  )
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Text(Strings.userName),
                          Dimens.boxHeight8,
                          InputField.userName(
                              controller: controller.userNameController),
                          Dimens.boxHeight16,
                          Text(Strings.email),
                          Dimens.boxHeight8,
                          InputField.email(
                            controller: controller.emailController,
                            onchange: (value) {
                              if (GetUtils.isEmail(value)) {
                                controller.isEmailValid = true;
                              } else {
                                controller.isEmailValid = false;
                              }
                            },
                          ),
                          Dimens.boxHeight16,
                          Text(Strings.password),
                          Dimens.boxHeight8,
                          InputField.password(
                              suffixIcon: IconButton(
                                icon: Icon(!controller.isPassward
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () {
                                  controller.isPassward =
                                      !controller.isPassward;
                                },
                              ),
                              obscureText: controller.isPassward,
                              obscureCharacter: '*',
                              controller: controller.passwordController),
                          Dimens.boxHeight16,
                          Text(Strings.confirmPassword),
                          Dimens.boxHeight8,
                          InputField.confirmPassword(
                              suffixIcon: IconButton(
                                icon: Icon(!controller.isConfirmPasswared
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined),
                                onPressed: () {
                                  controller.isConfirmPasswared =
                                      !controller.isConfirmPasswared;
                                },
                              ),
                              obscureText: controller.isConfirmPasswared,
                              obscureCharacter: '*',
                              validator: (value) {
                                if (controller.passwordController.text ==
                                    value) {
                                  return null;
                                }
                                return 'Should be same with Password';
                              },
                              controller: controller.confirmPasswordController),
                          Dimens.boxHeight32,
                          Button(
                            label: Strings.signUp,
                            onTap: controller.profileImage.isNotEmpty
                                ? controller.validateSignUp
                                : () {
                                    Get.dialog(
                                      AlertDialog(
                                        title: const Text('Alert message...'),
                                        content: const Text(
                                            'All fields must be filled with Profile image'),
                                        actions: [
                                          TextButton(
                                            onPressed: Get.back,
                                            child: const Text(
                                              'Okay',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Center(
                            child: InkWell(
                              onTap: () {
                                controller.passwordController.clear();
                                controller.isPassward = true;
                                Get.back();
                              },
                              child: Text(
                                Strings.login,
                                style: const TextStyle(
                                    color: AppColors.primaryColorLight),
                              ),
                            ),
                          ),
                          Dimens.boxHeight16
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
