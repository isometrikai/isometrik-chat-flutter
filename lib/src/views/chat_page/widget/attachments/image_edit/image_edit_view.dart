import 'package:flutter/foundation.dart';
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
              controller.webMedia.first.dataSize,
              style: IsmChatStyles.w600White16,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  controller.cropImage(
                      controller.webMedia.first.platformFile.path ?? '');
                },
                icon: Icon(
                  Icons.crop,
                  size: IsmChatDimens.twenty,
                  color: IsmChatColors.whiteColor,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.paintImage(
                      controller.webMedia.first.platformFile.path ?? '');
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
          body: Image.memory(
            controller.webMedia.first.platformFile.bytes ?? Uint8List(0),
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
                    if (controller.webMedia.first.dataSize.size()) {
                      Get.back<void>();

                      if (await IsmChatProperties.chatPageProperties
                              .messageAllowedConfig?.isMessgeAllowed
                              ?.call(
                                  context,
                                  Get.find<IsmChatPageController>(
                                          tag: IsmChat.i.tag)
                                      .conversation!,
                                  IsmChatCustomMessageType.image) ??
                          true) {
                        await controller.sendImage(
                          caption: controller.textEditingController.text,
                          conversationId:
                              controller.conversation?.conversationId ?? '',
                          userId: controller
                                  .conversation?.opponentDetails?.userId ??
                              '',
                          webMediaModel: controller.webMedia.first,
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
