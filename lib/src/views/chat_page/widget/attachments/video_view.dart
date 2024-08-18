import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// show the Video editing view page
class IsmChatVideoView extends StatefulWidget {
  const IsmChatVideoView({
    super.key,
  });

  static const String route = IsmPageRoutes.videoView;
  @override
  State<IsmChatVideoView> createState() => _IsmChatVideoViewState();
}

class _IsmChatVideoViewState extends State<IsmChatVideoView> {
  TextEditingController textEditingController = TextEditingController();
  File? videoFile;
  String dataSize = '';

  final controller = Get.find<IsmChatPageController>();

  @override
  void initState() {
    super.initState();
    final argumnet = Get.arguments as Map<String, dynamic>;
    videoFile = argumnet['file'] as File;
    setSize();
  }

  void setSize() async {
    dataSize = await IsmChatUtility.fileToSize(videoFile!);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            dataSize,
            style: IsmChatStyles.w600White16,
          ),
          leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: IsmChatColors.whiteColor,
            ),
          ),
          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          actions: [
            IconButton(
              onPressed: () async {
                var trimFile = await Get.to<File>(
                  IsmVideoTrimmerView(
                      file: videoFile ?? File(''), durationInSeconds: 30),
                );
                videoFile = trimFile;
                dataSize = await IsmChatUtility.fileToSize(videoFile!);
                setState(() {});
              },
              icon: const Icon(
                Icons.content_cut_rounded,
                color: IsmChatColors.whiteColor,
              ),
            )
          ],
        ),
        body: SafeArea(
            child: Stack(
          fit: StackFit.expand,
          children: [
            VideoViewPage(path: videoFile!.path),
          ],
        )),
        floatingActionButton: Padding(
          padding: IsmChatDimens.edgeInsetsBottom50
              .copyWith(left: IsmChatDimens.thirty),
          child: Row(
            mainAxisSize: MainAxisSize.min,
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
                  controller: textEditingController,
                  onChanged: (value) {},
                ),
              ),
              IsmChatDimens.boxWidth8,
              FloatingActionButton(
                backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                onPressed: () async {
                  if (dataSize.size()) {
                    Get.back<void>();
                    Get.back<void>();

                    if (await IsmChatProperties.chatPageProperties
                            .messageAllowedConfig?.isMessgeAllowed
                            ?.call(Get.context!, controller.conversation!) ??
                        true) {
                      await controller.sendVideo(
                        caption: textEditingController.text,
                        file: videoFile,
                        conversationId:
                            controller.conversation?.conversationId ?? '',
                        userId:
                            controller.conversation?.opponentDetails?.userId ??
                                '',
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
      );
}
