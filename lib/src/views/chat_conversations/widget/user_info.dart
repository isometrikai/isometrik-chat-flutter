import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatUserView extends StatelessWidget {
  IsmChatUserView({super.key, this.signOutTap});

  final VoidCallback? signOutTap;
  static const String route = IsmPageRoutes.userView;

  final FocusNode focusNode = FocusNode();

  void openKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        initState: (state) {
          final controller =
              state.controller ??= Get.find<IsmChatConversationsController>();
          if (controller.profileImage.isEmpty) {
            controller.profileImage = controller.userDetails?.profileUrl ?? '';
          }

          controller.userNameController.text =
              controller.userDetails?.userName ?? '';
          controller.userEmailController.text =
              controller.userDetails?.userIdentifier ?? '';
          controller.isUserNameType = false;
          controller.isUserEmailType = false;
        },
        builder: (controller) => Scaffold(
          backgroundColor: IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            onBack: Get.back,
            title: Text(
              IsmChatStrings.userInfo,
              style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                  IsmChatStyles.w600White18,
            ),
            action: !IsmChatResponsive.isWeb(context)
                ? [
                    TextButton(
                      onPressed: () {
                        signOutTap?.call();
                      },
                      child: Text(
                        IsmChatStrings.signOut,
                        style: IsmChatStyles.w400White14,
                      ),
                    )
                  ]
                : null,
          ),
          resizeToAvoidBottomInset: false,
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                IsmChatDimens.boxHeight16,
                Stack(
                  children: [
                    IsmChatImage.profile(
                      controller.profileImage,
                      dimensions: IsmChatDimens.oneHundredFifty,
                    ),
                    Positioned(
                      bottom: IsmChatDimens.ten,
                      right: IsmChatDimens.ten,
                      child: IsmChatTapHandler(
                        onTap: () {
                          if (IsmChatResponsive.isWeb(context)) {
                            controller.ismUploadImage(ImageSource.gallery);
                          } else {
                            Get.bottomSheet<void>(
                              IsmChatProfilePhotoBottomSheet(
                                onCameraTap: () async {
                                  controller
                                      .updateUserDetails(ImageSource.camera);
                                },
                                onGalleryTap: () async {
                                  controller
                                      .updateUserDetails(ImageSource.gallery);
                                },
                              ),
                              elevation: 0,
                            );
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.grey)),
                          width: IsmChatDimens.thirty,
                          height: IsmChatDimens.thirty,
                          child: Icon(
                            Icons.edit,
                            color: Colors.grey,
                            size: IsmChatDimens.fifteen,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                IsmChatDimens.boxHeight16,
                Container(
                  decoration: BoxDecoration(
                    color: IsmChatConfig.chatTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      IsmChatDimens.ten,
                    ),
                  ),
                  padding: IsmChatDimens.edgeInsets16,
                  margin: IsmChatDimens.edgeInsets20_0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        IsmChatStrings.details,
                        style: IsmChatStyles.w400White16.copyWith(
                          color: IsmChatConfig.chatTheme.primaryColor,
                        ),
                      ),
                      IsmChatDimens.boxHeight10,
                      IsmChatInputField(
                        focusNode: focusNode,
                        readOnly: !controller.isUserNameType,
                        autofocus: true,
                        fillColor: IsmChatConfig.chatTheme.backgroundColor,
                        controller: controller.userNameController,
                        padding: IsmChatDimens.edgeInsets0,
                        style: IsmChatStyles.w600Black16,
                        textInputAction: TextInputAction.done,
                        maxLines: 1,
                        hint: IsmChatStrings.addYourName,
                        hintStyle: IsmChatStyles.w600Black16,
                        onChanged: (value) {},
                        cursorColor: Colors.transparent,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            controller.isUserNameType =
                                !controller.isUserNameType;
                            if (!(MediaQuery.of(context).viewInsets.bottom >
                                0.0)) {
                              openKeyboard(context);
                            } else {}
                            if (controller.userDetails?.userName !=
                                controller.userNameController.text) {
                              await controller.updateUserData(
                                userName: controller.userNameController.text,
                                isloading: true,
                              );
                              await controller.getUserData(
                                isLoading: true,
                              );
                            }
                          },
                          icon: Icon(
                            controller.isUserNameType
                                ? Icons.done_rounded
                                : Icons.edit,
                            color: Colors.grey,
                            size: IsmChatDimens.twenty,
                          ),
                        ),
                      ),
                      IsmChatInputField(
                        focusNode: focusNode,
                        readOnly: !controller.isUserEmailType,
                        autofocus: true,
                        fillColor: IsmChatConfig.chatTheme.backgroundColor,
                        controller: controller.userEmailController,
                        padding: IsmChatDimens.edgeInsets0,
                        style: IsmChatStyles.w600Black16,
                        maxLines: 1,
                        hint: IsmChatStrings.addYourEmail,
                        hintStyle: IsmChatStyles.w600Black16,
                        textInputAction: TextInputAction.done,
                        onChanged: (value) {},
                        cursorColor: Colors.transparent,
                        suffixIcon: IconButton(
                          onPressed: () async {
                            controller.isUserEmailType =
                                !controller.isUserEmailType;
                            if (!(MediaQuery.of(context).viewInsets.bottom >
                                0.0)) {
                              openKeyboard(context);
                            } else {
                              if (controller.userDetails?.userIdentifier !=
                                  controller.userEmailController.text) {
                                await controller.updateUserData(
                                  userIdentifier:
                                      controller.userEmailController.text,
                                  isloading: true,
                                );
                                await controller.getUserData(isLoading: true);
                              }
                            }
                          },
                          icon: Icon(
                            controller.isUserEmailType
                                ? Icons.done_rounded
                                : Icons.edit,
                            color: Colors.grey,
                            size: IsmChatDimens.twenty,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: IsmChatDimens.edgeInsets20
                      .copyWith(bottom: IsmChatDimens.zero),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      IsmChatStrings.blockUser,
                      style: IsmChatStyles.w600Black20,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ),
                if (controller.blockUsers.isEmpty) ...[
                  IsmChatDimens.boxHeight32,
                  const IsmIconAndText(
                    icon: Icons.supervised_user_circle_rounded,
                    text: IsmChatStrings.noBlockedUsers,
                  ),
                ] else ...[
                  SizedBox(
                    height: Get.height,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.blockUsers.length,
                      itemBuilder: (_, index) {
                        var user = controller.blockUsers[index];
                        return ListTile(
                          leading: IsmChatImage.profile(user.profileUrl),
                          title: Text(
                            user.userName,
                          ),
                          subtitle: Text(
                            user.userIdentifier,
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              if (!IsmChatResponsive.isWeb(context)) {
                                controller.unblockUser(
                                  opponentId: user.userId,
                                  isLoading: true,
                                );
                              } else {
                                controller.unblockUserForWeb(user.userId);

                                Get.back();
                              }
                              unawaited(controller.getChatConversations());
                            },
                            child: const Text(
                              IsmChatStrings.unblock,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
}
