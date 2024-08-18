import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';

/// show the All media Preview view page
class IsmMediaPreview extends StatefulWidget {
  IsmMediaPreview({
    super.key,
    List<IsmChatMessageModel>? messageData,
    int? mediaIndex,
    String? mediaUserName,
    bool? initiated,
    int? mediaTime,
  })  : _mediaIndex = mediaIndex ??
            (Get.arguments as Map<String, dynamic>?)?['mediaIndex'] ??
            0,
        _mediaTime = mediaTime ??
            (Get.arguments as Map<String, dynamic>?)?['mediaTime'] ??
            0,
        _mediaUserName = mediaUserName ??
            (Get.arguments as Map<String, dynamic>?)?['mediaUserName'] ??
            '',
        _messageData = messageData ??
            (Get.arguments as Map<String, dynamic>?)?['messageData'] ??
            [],
        _initiated = initiated ??
            (Get.arguments as Map<String, dynamic>?)?['initiated'] ??
            false;

  final List<IsmChatMessageModel>? _messageData;

  final String? _mediaUserName;

  final bool? _initiated;

  final int? _mediaTime;

  final int? _mediaIndex;

  static const String route = IsmPageRoutes.mediaPreviewView;

  @override
  State<IsmMediaPreview> createState() => _MediaPreviewState();
}

class _MediaPreviewState extends State<IsmMediaPreview> {
  final chatPageController = Get.find<IsmChatPageController>();

  String mediaTime = '';

  bool initiated = false;

  int mediaIndex = -1;

  @override
  void initState() {
    super.initState();
    initiated = widget._initiated ?? false;
    mediaIndex = widget._mediaIndex ?? 0;
    mediaTime = (widget._mediaTime ?? 0).getTime;
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
                    : widget._mediaUserName.toString(),
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
              Get.back<void>();
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
                        .shareMedia(widget._messageData![mediaIndex]);
                  } else if (value == 2) {
                    await chatPageController
                        .saveMedia(widget._messageData![mediaIndex]);
                  } else if (value == 3) {
                    await chatPageController.showDialogForMessageDelete(
                        widget._messageData![mediaIndex],
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
            itemBuilder: (BuildContext context, int index) {
              var url =
                  widget._messageData?[index].attachments?.first.mediaUrl ?? '';
              var customType = (widget._messageData?[index].messageType ==
                      IsmChatMessageType.normal)
                  ? widget._messageData![index].customType
                  : widget._messageData?[index].metaData?.replyMessage
                      ?.parentMessageMessageType;
              return customType == IsmChatCustomMessageType.image
                  ? PhotoView(
                      imageProvider: url.isValidUrl
                          ? NetworkImage(url) as ImageProvider
                          : FileImage(File(url)),
                      loadingBuilder: (context, event) =>
                          const IsmChatLoadingDialog(),
                      wantKeepAlive: true,
                    )
                  : VideoViewPage(path: url);
            },
            onPageChanged: (index) {
              final timeStamp = DateTime.fromMillisecondsSinceEpoch(
                  widget._messageData![index].sentAt);
              final time = DateFormat.jm().format(timeStamp);
              final monthDay = DateFormat.MMMd().format(timeStamp);
              setState(
                () {
                  initiated = widget._messageData![index].sentByMe;
                  mediaTime = '$monthDay, $time';
                },
              );
            },
            itemCount: widget._messageData?.length ?? 0,
          ),
        ),
      );
}

class AudioPreview extends StatelessWidget {
  const AudioPreview({super.key, required this.message});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
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
                      Get.back();
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
                      Get.back();
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
                      Get.back();
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
