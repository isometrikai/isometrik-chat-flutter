import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
import 'package:photo_view/photo_view.dart';

class IsmWebMessageMediaPreview extends StatefulWidget {
  const IsmWebMessageMediaPreview({super.key, required this.previewData});

  final Map<String, dynamic> previewData;

  @override
  State<IsmWebMessageMediaPreview> createState() =>
      _WebMessageMediaPreviewState();
}

class _WebMessageMediaPreviewState extends State<IsmWebMessageMediaPreview> {
  PageController? pageController;
  final chatPageController = IsmChatUtility.chatPageController;

  String mediaTime = '';
  String mediaSize = '';
  String mediaUserName = '';
  bool initiated = false;
  List<IsmChatMessageModel> messageData = [];

  @override
  void initState() {
    super.initState();
    startInit();
  }

  startInit() {
    messageData = widget.previewData['messageData'] ?? [];
    mediaUserName = widget.previewData['mediaUserName'] ?? '';
    initiated = widget.previewData['initiated'] ?? false;
    chatPageController.assetsIndex = widget.previewData['mediaIndex'] ?? 0;
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(
      widget.previewData['mediaTime'] ?? 0,
    );
    final time = DateFormat.jm().format(timeStamp);
    final monthDay = DateFormat.MMMd().format(timeStamp);
    mediaTime = '$monthDay, $time';
    mediaSize = IsmChatUtility.formatBytes(
      int.parse(
          '${messageData[chatPageController.assetsIndex].attachments?.first.size}'),
    );
    pageController =
        PageController(initialPage: chatPageController.assetsIndex);
    updateState();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          shadowColor: Colors.grey,
          elevation: IsmChatDimens.one,
          leading: const SizedBox.shrink(),
          leadingWidth: IsmChatDimens.zero,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                initiated ? IsmChatStrings.you : mediaUserName,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w400Black16,
              ),
              Text(
                mediaTime,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.subtileStyle ??
                        IsmChatStyles.w400Black14,
              )
            ],
          ),
          centerTitle: true,
          actions: [
            Tooltip(
              message: 'Save media',
              triggerMode: TooltipTriggerMode.tap,
              child: IconButton(
                onPressed: () async {
                  if (messageData[chatPageController.assetsIndex]
                          .attachments
                          ?.first
                          .mediaUrl
                          ?.isValidUrl ??
                      false) {
                    IsmChatBlob.fileDownloadWithUrl(
                        messageData[chatPageController.assetsIndex]
                                .attachments
                                ?.first
                                .mediaUrl ??
                            '');
                  } else {
                    IsmChatBlob.fileDownloadWithBytes(
                        messageData[chatPageController.assetsIndex]
                                .attachments
                                ?.first
                                .mediaUrl
                                ?.strigToUnit8List ??
                            [],
                        downloadName:
                            '${messageData[chatPageController.assetsIndex].attachments!.first.name}.${messageData[chatPageController.assetsIndex].attachments!.first.extension}');
                    IsmChatUtility.showToast('Save your media');
                  }
                },
                icon: const Icon(Icons.save_rounded),
              ),
            ),
            IsmChatDimens.boxWidth8,
            Tooltip(
              message: 'Delete media',
              triggerMode: TooltipTriggerMode.tap,
              child: IconButton(
                onPressed: () async {
                  await chatPageController.showDialogForMessageDelete(
                      messageData[chatPageController.assetsIndex],
                      fromMediaPrivew: true);
                },
                icon: const Icon(Icons.delete_rounded),
              ),
            ),
            const IconButton(
              alignment: Alignment.center,
              icon: Icon(
                Icons.close_rounded,
                color: IsmChatColors.blackColor,
              ),
              onPressed: IsmChatRoute.goBack,
            ),
            IsmChatDimens.boxWidth32
          ],
        ),
        body: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: IsmChatDimens.percentHeight(.75),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: pageController,
                    itemCount: messageData.length,
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      var media = messageData[index];
                      var url = media.attachments?.first.mediaUrl ?? '';
                      var customType =
                          (media.messageType == IsmChatMessageType.normal)
                              ? media.customType
                              : media.metaData?.replyMessage
                                  ?.parentMessageMessageType;
                      return customType == IsmChatCustomMessageType.image
                          ? PhotoView(
                              backgroundDecoration: const BoxDecoration(
                                  color: Colors.transparent),
                              imageProvider: url.isValidUrl
                                  ? NetworkImage(url)
                                  : kIsWeb
                                      ? MemoryImage(url.strigToUnit8List)
                                          as ImageProvider
                                      : FileImage(File(url)),
                              loadingBuilder: (context, event) =>
                                  const IsmChatLoadingDialog(),
                              wantKeepAlive: true,
                            )
                          : VideoViewPage(path: url);
                    },
                    onPageChanged: (index) {
                      var media = messageData[index];
                      initiated = media.sentByMe;
                      mediaTime = media.sentAt.deliverTime;
                      chatPageController.assetsIndex = index;
                      mediaSize = IsmChatUtility.formatBytes(
                        int.parse('${media.attachments?.first.size}'),
                      );
                      updateState();
                    },
                  ),
                  Padding(
                    padding: IsmChatDimens.edgeInsets20_0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Opacity(
                          opacity: chatPageController.assetsIndex != 0 ? 1 : 0,
                          child: IsmChatTapHandler(
                            onTap: () async {
                              chatPageController.assetsIndex--;
                              initiated =
                                  messageData[chatPageController.assetsIndex]
                                      .sentByMe;
                              mediaTime =
                                  messageData[chatPageController.assetsIndex]
                                      .sentAt
                                      .deliverTime;
                              updateState();
                              await pageController?.animateToPage(
                                  chatPageController.assetsIndex,
                                  curve: Curves.linear,
                                  duration: const Duration(milliseconds: 100));
                            },
                            child: Container(
                              padding: IsmChatDimens.edgeInsets5,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(IsmChatDimens.fifty),
                                color: IsmChatColors.whiteColor,
                                border: Border.all(
                                  color: IsmChatColors.blackColor,
                                ),
                              ),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                color: IsmChatColors.blackColor,
                                size: IsmChatDimens.fifty,
                              ),
                            ),
                          ),
                        ),
                        Opacity(
                          opacity: (chatPageController.assetsIndex ==
                                  (messageData.length) - 1)
                              ? 0
                              : 1,
                          child: IsmChatTapHandler(
                            onTap: () async {
                              chatPageController.assetsIndex++;
                              initiated =
                                  messageData[chatPageController.assetsIndex]
                                      .sentByMe;
                              mediaTime =
                                  messageData[chatPageController.assetsIndex]
                                      .sentAt
                                      .deliverTime;
                              updateState();
                              await pageController?.animateToPage(
                                chatPageController.assetsIndex,
                                curve: Curves.linear,
                                duration: const Duration(milliseconds: 100),
                              );
                            },
                            child: Container(
                              padding: IsmChatDimens.edgeInsets5,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(IsmChatDimens.fifty),
                                color: IsmChatColors.whiteColor,
                                border: Border.all(
                                  color: IsmChatColors.blackColor,
                                ),
                              ),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                color: IsmChatColors.blackColor,
                                size: IsmChatDimens.fifty,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Container(
              width: IsmChatDimens.percentWidth(1),
              alignment: Alignment.center,
              height: IsmChatDimens.sixty,
              margin: IsmChatDimens.edgeInsets10,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => IsmChatDimens.boxWidth8,
                itemCount: messageData.length,
                itemBuilder: (context, index) {
                  var media = messageData[index].attachments;
                  var mediaMessage = messageData[index];
                  var isVideo = IsmChatConstants.videoExtensions.contains(
                    media?.first.extension,
                  );
                  return InkWell(
                    onTap: () async {
                      initiated = mediaMessage.sentByMe;
                      mediaTime = mediaMessage.sentAt.deliverTime;
                      chatPageController.assetsIndex = index;
                      chatPageController.isVideoVisible = false;
                      await pageController?.animateToPage(index,
                          curve: Curves.linear,
                          duration: const Duration(milliseconds: 100));
                      updateState();
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          height: IsmChatDimens.sixty,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(IsmChatDimens.ten),
                              ),
                              border: chatPageController.assetsIndex == index
                                  ? Border.all(
                                      color: IsmChatColors.blackColor,
                                      width: IsmChatDimens.two)
                                  : null),
                          width: IsmChatDimens.sixty,
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(
                              Radius.circular(IsmChatDimens.ten),
                            ),
                            child: isVideo
                                ? IsmChatImage(
                                    media?.first.thumbnailUrl ?? '',
                                    isNetworkImage:
                                        media?.first.thumbnailUrl?.isValidUrl ??
                                            false,
                                    isBytes: !(media
                                            ?.first.thumbnailUrl?.isValidUrl ??
                                        false),
                                  )
                                : IsmChatImage(
                                    media?.first.mediaUrl ?? '',
                                    isNetworkImage:
                                        media?.first.mediaUrl?.isValidUrl ??
                                            false,
                                    isBytes:
                                        !(media?.first.mediaUrl?.isValidUrl ??
                                            false),
                                  ),
                          ),
                        ),
                        if (isVideo)
                          Container(
                            alignment: Alignment.center,
                            width: IsmChatDimens.thirtyTwo,
                            height: IsmChatDimens.thirtyTwo,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
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
        ),
      );
}
