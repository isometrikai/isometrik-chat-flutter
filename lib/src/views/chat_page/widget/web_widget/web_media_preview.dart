import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class WebMediaPreview extends StatelessWidget {
  const WebMediaPreview({super.key});

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (controller) {
          if (controller.webMedia.isNotEmpty) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(50),
                child: AppBar(
                  elevation: IsmChatDimens.zero,
                  title: Text(
                    controller.webMedia[controller.assetsIndex].dataSize,
                    style: IsmChatStyles.w600Black14,
                  ),
                  centerTitle: true,
                  backgroundColor: IsmChatColors.whiteColor,
                  leading: InkWell(
                    child: const Icon(
                      Icons.clear,
                      color: IsmChatColors.blackColor,
                    ),
                    onTap: () {
                      // IsmChatRoute.goBack<void>();
                      controller.webMedia.clear();
                      controller.isVideoVisible = false;
                      controller.isCameraView = false;
                    },
                  ),
                  actions: [
                    if (controller.isCameraView)
                      TextButton(
                          onPressed: () async {
                            controller.isCameraView = false;
                            controller.webMedia.clear();
                            controller.isVideoVisible = false;
                            controller.isCameraView = false;
                            IsmChatRoute.goBack<void>();

                            await controller.initializeCamera();
                            controller.isCameraView = true;
                          },
                          child: Text(
                            'Retake',
                            style: IsmChatStyles.w600Black14,
                          ))
                  ],
                ),
              ),
              backgroundColor: IsmChatColors.whiteColor,
              body: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IsmChatDimens.boxHeight20,
                      SizedBox(
                        height: IsmChatDimens.percentHeight(
                            IsmChatResponsive.isMobile(context) ? .7 : .5),
                        child: (IsmChatConstants.imageExtensions.contains(
                                controller.webMedia[controller.assetsIndex]
                                    .platformFile.extension))
                            ? Image.memory(
                                controller.webMedia[controller.assetsIndex]
                                    .platformFile.bytes!,
                                fit: BoxFit.contain,
                              )
                            : VideoViewPage(
                                showVideoPlaying: true,
                                path: controller
                                        .webMedia[controller.assetsIndex]
                                        .platformFile
                                        .path ??
                                    '',
                              ),
                      ),
                      IsmChatDimens.boxHeight20,
                      if (!IsmChatResponsive.isMobile(context)) ...[
                        Stack(
                          children: [
                            Container(
                              width: IsmChatDimens.percentWidth(1),
                              alignment: Alignment.center,
                              height: IsmChatDimens.sixty,
                              margin: IsmChatDimens.edgeInsets10,
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const BouncingScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                separatorBuilder: (context, index) =>
                                    IsmChatDimens.boxWidth8,
                                itemCount: controller.webMedia.length,
                                itemBuilder: (context, index) {
                                  var media = controller.webMedia[index];
                                  var isVideo =
                                      IsmChatConstants.videoExtensions.contains(
                                    controller
                                        .webMedia[index].platformFile.extension,
                                  );
                                  return InkWell(
                                    onTap: () async {
                                      controller.assetsIndex = index;
                                      controller.isVideoVisible = false;
                                    },
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Container(
                                          height: IsmChatDimens.sixty,
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(
                                                    IsmChatDimens.ten),
                                              ),
                                              border: controller.assetsIndex ==
                                                      index
                                                  ? Border.all(
                                                      color: IsmChatColors
                                                          .blackColor,
                                                      width: IsmChatDimens.two)
                                                  : null),
                                          width: IsmChatDimens.sixty,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(
                                                  IsmChatDimens.ten),
                                            ),
                                            child: Image.memory(
                                              isVideo
                                                  ? media.platformFile
                                                          .thumbnailBytes ??
                                                      Uint8List(0)
                                                  : media.platformFile.bytes!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        if (isVideo)
                                          Container(
                                            alignment: Alignment.center,
                                            width: IsmChatDimens.thirtyTwo,
                                            height: IsmChatDimens.thirtyTwo,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey),
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.play_arrow,
                                                color: Colors.black),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      ],
                      Padding(
                        padding: IsmChatDimens.edgeInsets20_0,
                        child: Row(
                          children: [
                            Expanded(
                              child: KeyboardListener(
                                focusNode: controller.mediaFocusNode,
                                onKeyEvent: (event) async {
                                  if (event.logicalKey ==
                                      LogicalKeyboardKey.enter) {
                                    if (await IsmChatProperties
                                            .chatPageProperties
                                            .messageAllowedConfig
                                            ?.isMessgeAllowed
                                            ?.call(
                                                context,
                                                controller.conversation!,
                                                IsmChatCustomMessageType
                                                    .image) ??
                                        true) {
                                      controller.sendMediaWeb();
                                    }
                                  }
                                },
                                child: IsmChatInputField(
                                  isShowBorderColor: true,
                                  // fillColor:
                                  //     IsmChatColors.greyColor.applyIsmOpacity(.5),
                                  autofocus: true,
                                  padding: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.textFiledTheme?.textfieldInsets,
                                  contentPadding: IsmChatDimens.edgeInsets20,
                                  hint: IsmChatStrings.addCaption,
                                  hintStyle: IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.textFiledTheme
                                          ?.hintTextStyle ??
                                      IsmChatStyles.w400Black16,
                                  cursorColor: IsmChatColors.blackColor,
                                  style: IsmChatConfig.chatTheme.chatPageTheme
                                          ?.textFiledTheme?.inputTextStyle ??
                                      IsmChatStyles.w400Black16,
                                  controller: controller.textEditingController,
                                  onChanged: (value) {
                                    controller
                                            .webMedia[controller.assetsIndex] =
                                        controller
                                            .webMedia[controller.assetsIndex]
                                            .copyWith(caption: value);
                                  },
                                ),
                              ),
                            ),
                            IsmChatDimens.boxWidth20,
                            IsmChatStartChatFAB(
                              onTap: () async {
                                if (await IsmChatProperties.chatPageProperties
                                        .messageAllowedConfig?.isMessgeAllowed
                                        ?.call(
                                            context,
                                            controller.conversation!,
                                            IsmChatCustomMessageType.image) ??
                                    true) {
                                  controller.sendMediaWeb();
                                }
                              },
                              icon: const Icon(
                                Icons.send,
                                color: IsmChatColors.whiteColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IsmChatDimens.boxHeight20
                    ]),
              ),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      );
}
