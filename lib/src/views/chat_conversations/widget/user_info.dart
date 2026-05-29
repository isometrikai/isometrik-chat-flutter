import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Current user's profile screen (name, email, blocked users list).
///
/// Colors from [IsmChatThemeResolver.profileFromConfig]; omit [profileTheme] for SDK defaults.
class IsmChatUserView extends StatelessWidget {
  IsmChatUserView({super.key, this.signOutTap});

  final VoidCallback? signOutTap;

  final FocusNode focusNode = FocusNode();

  void openKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    final profileTheme = IsmChatThemeResolver.profileFromConfig(context);

    return GetX<IsmChatConversationsController>(
      tag: IsmChat.i.chatListPageTag,
      initState: (state) {
        final controller =
            state.controller ??= IsmChatUtility.conversationController;
        if (controller.profileImage.isEmpty) {
          controller.profileImage = controller.userDetails?.profileUrl ?? '';
        }

        controller
          ..userNameController.text = controller.userDetails?.userName ?? ''
          ..userEmailController.text =
              controller.userDetails?.userIdentifier ?? ''
          ..isUserNameType = false
          ..isUserEmailType = false;

        if (controller.blockUsers.isEmpty) {
          unawaited(controller.getBlockUser());
        }
      },
      builder: (controller) => Scaffold(
        backgroundColor: profileTheme.scaffoldBackgroundColor,
        appBar: IsmChatAppBar(
          onBack: IsmChatRoute.goBack,
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor,
          title: Text(
            IsmChatStrings.userInfo,
            style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                IsmChatStyles.w600White18,
          ),
          action: !IsmChatResponsive.isWeb(context)
              ? [
                  TextButton(
                    onPressed: signOutTap,
                    child: Text(
                      IsmChatStrings.signOut,
                      style: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.titleStyle ??
                          IsmChatStyles.w400White14,
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
                          IsmChatContextWidget.showBottomsheetContext<void>(
                            content: IsmChatProfilePhotoBottomSheet(
                              onCameraTap: () async {
                                controller
                                    .updateUserDetails(ImageSource.camera);
                              },
                              onGalleryTap: () async {
                                controller
                                    .updateUserDetails(ImageSource.gallery);
                              },
                            ),
                            isDismissible: true,
                            backgroundColor: IsmChatColors.transparent,
                          );
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: profileTheme.editButtonBackgroundColor,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: profileTheme.editButtonBorderColor,
                          ),
                        ),
                        width: IsmChatDimens.thirty,
                        height: IsmChatDimens.thirty,
                        child: Icon(
                          Icons.edit,
                          color: profileTheme.editButtonIconColor,
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
                  color: profileTheme.cardBackgroundColor,
                  borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                ),
                padding: IsmChatDimens.edgeInsets16,
                margin: IsmChatDimens.edgeInsets20_0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      IsmChatStrings.details,
                      style: profileTheme.sectionTitleStyle,
                    ),
                    IsmChatDimens.boxHeight10,
                    IsmChatInputField(
                      focusNode: focusNode,
                      readOnly: !controller.isUserNameType,
                      autofocus: true,
                      fillColor: profileTheme.cardBackgroundColor,
                      controller: controller.userNameController,
                      padding: IsmChatDimens.edgeInsets0,
                      style: profileTheme.inputTextStyle,
                      textInputAction: TextInputAction.done,
                      maxLines: 1,
                      hint: IsmChatStrings.addYourName,
                      hintStyle: profileTheme.inputHintStyle,
                      onChanged: (value) {},
                      cursorColor: controller.isUserNameType
                          ? IsmChatConfig.chatTheme.primaryColor
                          : Colors.transparent,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          controller.isUserNameType =
                              !controller.isUserNameType;
                          if (MediaQuery.of(context).viewInsets.bottom <= 0) {
                            openKeyboard(context);
                          }
                          if (controller.userDetails?.userName !=
                              controller.userNameController.text) {
                            await controller.updateUserData(
                              userName: controller.userNameController.text,
                              isloading: true,
                            );
                            await controller.getUserData(isLoading: true);
                          }
                        },
                        icon: Icon(
                          controller.isUserNameType
                              ? Icons.done_rounded
                              : Icons.edit,
                          color: profileTheme.iconColor,
                          size: IsmChatDimens.twenty,
                        ),
                      ),
                    ),
                    IsmChatInputField(
                      focusNode: focusNode,
                      readOnly: !controller.isUserEmailType,
                      autofocus: true,
                      fillColor: profileTheme.cardBackgroundColor,
                      controller: controller.userEmailController,
                      padding: IsmChatDimens.edgeInsets0,
                      style: profileTheme.inputTextStyle,
                      maxLines: 1,
                      hint: IsmChatStrings.addYourEmail,
                      hintStyle: profileTheme.inputHintStyle,
                      textInputAction: TextInputAction.done,
                      onChanged: (value) {},
                      cursorColor: controller.isUserEmailType
                          ? IsmChatConfig.chatTheme.primaryColor
                          : Colors.transparent,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          controller.isUserEmailType =
                              !controller.isUserEmailType;
                          if (MediaQuery.of(context).viewInsets.bottom <= 0) {
                            openKeyboard(context);
                          } else if (controller.userDetails?.userIdentifier !=
                              controller.userEmailController.text) {
                            await controller.updateUserData(
                              userIdentifier:
                                  controller.userEmailController.text,
                              isloading: true,
                            );
                            await controller.getUserData(isLoading: true);
                          }
                        },
                        icon: Icon(
                          controller.isUserEmailType
                              ? Icons.done_rounded
                              : Icons.edit,
                          color: profileTheme.iconColor,
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
                    style: profileTheme.secondaryTextStyle,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
              if (controller.blockUsers.isEmpty) ...[
                IsmChatDimens.boxHeight32,
                IsmIconAndText(
                  icon: Icons.supervised_user_circle_rounded,
                  text: IsmChatStrings.noBlockedUsers,
                  iconColor: IsmChatConfig.chatTheme.primaryColor,
                  textStyle: profileTheme.emptyStateTextStyle,
                ),
              ] else ...[
                SizedBox(
                  height: IsmChatDimens.percentHeight(1),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.blockUsers.length,
                    itemBuilder: (_, index) {
                      final user = controller.blockUsers[index];
                      return ListTile(
                        leading: IsmChatImage.profile(user.profileUrl),
                        title: Text(
                          user.userName,
                          style: profileTheme.listTileTitleStyle,
                        ),
                        subtitle: Text(
                          user.userIdentifier,
                          style: profileTheme.listTileSubtitleStyle,
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
                              IsmChatRoute.goBack();
                            }
                            unawaited(controller.getChatConversations());
                          },
                          child: const Text(IsmChatStrings.unblock),
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
}
