import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// show the Photo and Video editing view page
class IsmChatImageEditView extends StatelessWidget {
  const IsmChatImageEditView({super.key});

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        initState: (state) {
          state.controller?.textEditingController.clear();
        },
        builder: (controller) {
          final imageBytes = controller.webMedia.first.platformFile.bytes;
          final hasImage = imageBytes != null && imageBytes.isNotEmpty;

          return Scaffold(
            backgroundColor: IsmChatColors.blackColor,
            resizeToAvoidBottomInset: false,
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
                      url: controller.webMedia.first.platformFile.path ?? '',
                    );
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
                      url: controller.webMedia.first.platformFile.path ?? '',
                    );
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
                onPressed: IsmChatRoute.goBack,
              ),
            ),
            body: Stack(
              children: [
                Positioned.fill(
                  child: hasImage
                      ? Image.memory(
                          imageBytes,
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                color: IsmChatColors.whiteColor,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Loading image...',
                                style: TextStyle(
                                  color: IsmChatColors.whiteColor,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: IsmChatDimens.thirty,
                      right: IsmChatDimens.ten,
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                      top: IsmChatDimens.ten,
                    ),
                    color: IsmChatColors.blackColor.withOpacity(0.8),
                    child: Row(
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxHeight: 150.0,
                            ),
                            child: Scrollbar(
                              child: IsmChatInputField(
                                fillColor: IsmChatColors.greyColor,
                                autofocus: false,
                                padding: IsmChatDimens.edgeInsets0,
                                hint: IsmChatStrings.addCaption,
                                hintStyle: IsmChatStyles.w400White16,
                                cursorColor: IsmChatColors.whiteColor,
                                style: IsmChatStyles.w400White16,
                                controller: controller.textEditingController,
                                maxLines: null,
                                minLines: 1,
                                textInputAction: TextInputAction.newline,
                                onChanged: (value) {
                                  controller.webMedia.first.caption = value;
                                },
                              ),
                            ),
                          ),
                        ),
                        IsmChatDimens.boxWidth8,
                        FloatingActionButton(
                          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                          onPressed: () async {
                            if (controller.webMedia.first.dataSize.size()) {
                              IsmChatRoute.goBack();
                              if (await IsmChatProperties.chatPageProperties
                                      .messageAllowedConfig?.isMessgeAllowed
                                      ?.call(context, controller.conversation,
                                          IsmChatCustomMessageType.image) ??
                                  true) {
                                await controller.sendImage(
                                  conversationId:
                                      controller.conversation?.conversationId ??
                                          '',
                                  userId: controller.conversation
                                          ?.opponentDetails?.userId ??
                                      '',
                                  webMediaModel: controller.webMedia.first,
                                );
                              }
                            } else {
                              await IsmChatContextWidget.showDialogContext(
                                content: const IsmChatAlertDialogBox(
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
              ],
            ),
          );
        },
      );
}
