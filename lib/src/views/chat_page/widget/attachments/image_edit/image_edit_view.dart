import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// show the Photo and Video editing view page
class IsmChatImageEditView extends StatelessWidget {
  const IsmChatImageEditView({super.key});

  static const String route = IsmPageRoutes.eidtMedia;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.tag,
        initState: (state) {
          state.controller?.textEditingController.clear();
        },
        builder: (controller) => Scaffold(
          backgroundColor: IsmChatColors.blackColor,
          appBar: AppBar(
            backgroundColor: IsmChatConfig.chatTheme.primaryColor,
            title: Text(
              controller.fileSize,
              style: IsmChatStyles.w600White16,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () async {
                  await controller.cropImage(controller.imagePath ?? File(''));
                },
                icon: Icon(
                  Icons.crop,
                  size: IsmChatDimens.twenty,
                  color: IsmChatColors.whiteColor,
                ),
              ),
              IconButton(
                onPressed: () async {
                  controller.imagePath =
                      await Get.to<File>(IsmChatImagePainterWidget(
                    file: controller.imagePath!,
                  ));
                  controller.fileSize = await IsmChatUtility.fileToSize(
                      controller.imagePath ?? File(''));
                },
                icon: Icon(
                  Icons.edit,
                  size: IsmChatDimens.twenty,
                  color: IsmChatColors.whiteColor,
                ),
              ),
            ],
            leading: IconButton(
              icon: Icon(
                Icons.clear,
                size: IsmChatDimens.twenty,
                color: IsmChatColors.whiteColor,
              ),
              onPressed: () {
                Get.back<void>();
                Get.back<void>();
              },
            ),
          ),
          body: Image.file(
            controller.imagePath ?? File(''),
            fit: BoxFit.contain,
            height: IsmChatDimens.percentHeight(1),
            width: IsmChatDimens.percentWidth(1),
            alignment: Alignment.center,
          ),
          floatingActionButton: Padding(
            padding: IsmChatDimens.edgeInsetsLeft10
                .copyWith(left: IsmChatDimens.thirty),
            child: Row(
              children: [
                Expanded(
                  child: IsmChatInputField(
                    fillColor: IsmChatColors.greyColor,
                    autofocus: false,
                    padding: IsmChatDimens.edgeInsets0,
                    hint: IsmChatStrings.addCaption,
                    hintStyle: IsmChatStyles.w400White16,
                    cursorColor: IsmChatColors.whiteColor,
                    style: IsmChatStyles.w400White16,
                    controller: controller.textEditingController,
                    onChanged: (value) {},
                  ),
                ),
                IsmChatDimens.boxWidth8,
                FloatingActionButton(
                  backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                  onPressed: () async {
                    if (controller.fileSize.size()) {
                      Get.back<void>();
                      Get.back<void>();
                      if (await IsmChatProperties.chatPageProperties
                              .messageAllowedConfig?.isMessgeAllowed
                              ?.call(
                                  context,
                                  Get.find<IsmChatPageController>(
                                          tag: IsmChat.i.tag)
                                      .conversation!) ??
                          true) {
                        await controller.sendImage(
                          caption: controller.textEditingController.text,
                          conversationId:
                              controller.conversation?.conversationId ?? '',
                          userId: controller
                                  .conversation?.opponentDetails?.userId ??
                              '',
                          imagePath: controller.imagePath,
                        );
                      }
                    } else {
                      await Get.dialog(
                        const IsmChatAlertDialogBox(
                          title: IsmChatStrings.youCanNotSend,
                          cancelLabel: IsmChatStrings.okay,
                        ),
                      );
                    }
                  },
                  child: const Icon(
                    Icons.send,
                    color: IsmChatColors.whiteColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
