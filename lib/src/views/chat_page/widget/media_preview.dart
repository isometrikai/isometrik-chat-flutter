import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';

/// show the All media Preview view page
class IsmMediaPreview extends StatefulWidget {
  const IsmMediaPreview({
    super.key,
    required this.messageData,
    required this.mediaIndex,
    required this.mediaUserName,
    required this.initiated,
    required this.mediaTime,
  });

  final List<IsmChatMessageModel> messageData;

  final String mediaUserName;

  final bool initiated;

  final int mediaTime;

  final int mediaIndex;

  @override
  State<IsmMediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<IsmMediaPreview> {
  final chatPageController =
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  String mediaTime = '';

  bool initiated = false;

  int mediaIndex = -1;

  PageController? pageController;

  @override
  void initState() {
    initiated = widget.initiated;
    mediaIndex = widget.mediaIndex;
    mediaTime = widget.mediaTime.getTime;
    pageController = PageController(
      initialPage: mediaIndex,
    );
    super.initState();
  }

  @override
  void dispose() {
    pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmChatColors.blackColor,
        appBar: AppBar(
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: IsmChatColors.blackColor,
            statusBarBrightness: Brightness.dark,
          ),
          backgroundColor: IsmChatColors.blackColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                initiated
                    ? IsmChatStrings.you
                    : widget.mediaUserName.toString(),
                style: IsmChatStyles.w400White16,
              ),
              Text(
                mediaTime,
                style: IsmChatStyles.w400White14,
              )
            ],
          ),
          centerTitle: false,
          leading: InkWell(
            child: Icon(
              Icons.adaptive.arrow_back,
              color: IsmChatColors.whiteColor,
            ),
            onTap: () {
              IsmChatRoute.goBack<void>();
            },
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(
                  right: IsmChatDimens.five, top: IsmChatDimens.two),
              child: PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert,
                  color: IsmChatColors.whiteColor,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.share_rounded,
                          color: IsmChatColors.blackColor,
                        ),
                        IsmChatDimens.boxWidth8,
                        const Text(IsmChatStrings.share)
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.save_rounded,
                          color: IsmChatColors.blackColor,
                        ),
                        IsmChatDimens.boxWidth8,
                        const Text(IsmChatStrings.save)
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_rounded,
                          color: IsmChatColors.blackColor,
                        ),
                        IsmChatDimens.boxWidth8,
                        const Text(IsmChatStrings.delete)
                      ],
                    ),
                  ),
                ],
                elevation: 1,
                onSelected: (value) async {
                  if (value == 1) {
                    await chatPageController
                        .shareMedia(widget.messageData[mediaIndex]);
                  } else if (value == 2) {
                    await chatPageController
                        .saveMedia(widget.messageData[mediaIndex]);
                  } else if (value == 3) {
                    await chatPageController.showDialogForMessageDelete(
                        widget.messageData[mediaIndex],
                        fromMediaPrivew: true);
                  }
                },
              ),
            ),
          ],
        ),
        body: SizedBox(
          height: IsmChatDimens.percentHeight(1),
          width: IsmChatDimens.percentWidth(1),
          child: PageView.builder(
            controller: pageController,
            itemBuilder: (BuildContext context, int index) {
              final media = widget.messageData[index];
              var url = media.attachments?.first.mediaUrl ?? '';
              var customType = (media.messageType == IsmChatMessageType.normal)
                  ? media.customType
                  : media.metaData?.replyMessage?.parentMessageMessageType;
              return customType == IsmChatCustomMessageType.image
                  ? PhotoView(
                      imageProvider: url.isValidUrl
                          ? NetworkImage(url) as ImageProvider
                          : kIsWeb
                              ? MemoryImage(url.strigToUnit8List)
                                  as ImageProvider
                              : FileImage(File(url)) as ImageProvider,
                      loadingBuilder: (context, event) =>
                          const IsmChatLoadingDialog(),
                      wantKeepAlive: true,
                    )
                  : VideoViewPage(path: url);
            },
            onPageChanged: (index) {
              final timeStamp = DateTime.fromMillisecondsSinceEpoch(
                  widget.messageData[index].sentAt);
              final time = DateFormat.jm().format(timeStamp);
              final monthDay = DateFormat.MMMd().format(timeStamp);
              setState(
                () {
                  initiated = widget.messageData[index].sentByMe;
                  mediaTime = '$monthDay, $time';
                },
              );
            },
            itemCount: widget.messageData.length,
          ),
        ),
      );
}

class AudioPreview extends StatelessWidget {
  const AudioPreview({super.key, required this.message});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
      tag: IsmChat.i.tag,
      builder: (controller) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.shareMedia(message);
                    },
                    icon: const Icon(
                      Icons.share_rounded,
                      color: IsmChatColors.whiteColor,
                    ),
                    label: Text(
                      IsmChatStrings.share,
                      style: IsmChatStyles.w700White16,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.saveMedia(message);
                    },
                    icon: const Icon(
                      Icons.save_rounded,
                      color: IsmChatColors.whiteColor,
                    ),
                    label: Text(
                      IsmChatStrings.save,
                      style: IsmChatStyles.w700White16,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.showDialogForMessageDelete(message,
                          fromMediaPrivew: true);
                    },
                    icon: const Icon(
                      Icons.delete_rounded,
                      color: IsmChatColors.whiteColor,
                    ),
                    label: Text(
                      IsmChatStrings.delete,
                      style: IsmChatStyles.w700White16,
                    ),
                  )
                ],
              ),
              IsmChatAudioPlayer(
                message: message,
              ),
            ],
          ));
}
