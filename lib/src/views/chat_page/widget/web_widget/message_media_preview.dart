import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
import 'package:photo_view/photo_view.dart';

class IsmWebMessageMediaPreview extends StatefulWidget {
  IsmWebMessageMediaPreview({
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
        _initiated = initiated ??
            (Get.arguments as Map<String, dynamic>?)?['initiated'] ??
            false,
        _mediaUserName = mediaUserName ??
            (Get.arguments as Map<String, dynamic>?)?['mediaUserName'] ??
            '',
        _messageData = messageData ??
            (Get.arguments as Map<String, dynamic>?)?['messageData'] ??
            [];

  final List<IsmChatMessageModel>? _messageData;

  final String? _mediaUserName;

  final bool? _initiated;

  final int? _mediaTime;

  final int? _mediaIndex;

  static const String route = IsmPageRoutes.messageMediaPreivew;

  @override
  State<IsmWebMessageMediaPreview> createState() =>
      _WebMessageMediaPreviewState();
}

class _WebMessageMediaPreviewState extends State<IsmWebMessageMediaPreview> {
  /// Page controller for handing the PageView pages
  PageController pageController = PageController();

  final chatPageController = Get.find<IsmChatPageController>();

  String mediaTime = '';
  String mediaSize = '';

  bool initiated = false;

  @override
  void initState() {
    super.initState();
    startInit();
  }

  startInit() {
    initiated = widget._initiated ?? false;
    chatPageController.assetsIndex = widget._mediaIndex ?? 0;
    final timeStamp =
        DateTime.fromMillisecondsSinceEpoch(widget._mediaTime ?? 0);
    final time = DateFormat.jm().format(timeStamp);
    final monthDay = DateFormat.MMMd().format(timeStamp);
    mediaTime = '$monthDay, $time';
    mediaSize = IsmChatUtility.formatBytes(
      int.parse(
          '${widget._messageData![widget._mediaIndex ?? 0].attachments?.first.size}'),
    );
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
                initiated
                    ? IsmChatStrings.you
                    : widget._mediaUserName.toString(),
                style: IsmChatStyles.w400Black16,
              ),
              Text(
                mediaTime,
                style: IsmChatStyles.w400Black14,
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
                  if (widget._messageData?[chatPageController.assetsIndex]
                          .attachments!.first.mediaUrl!.isValidUrl ??
                      false) {
                    IsmChatBlob.fileDownloadWithUrl(widget
                        ._messageData![chatPageController.assetsIndex]
                        .attachments!
                        .first
                        .mediaUrl!);
                  } else {
                    IsmChatBlob.fileDownloadWithBytes(
                        widget
                                ._messageData?[chatPageController.assetsIndex]
                                .attachments!
                                .first
                                .mediaUrl!
                                .strigToUnit8List ??
                            List.empty(),
                        downloadName:
                            '${widget._messageData?[chatPageController.assetsIndex].attachments!.first.name}.${widget._messageData?[chatPageController.assetsIndex].attachments!.first.extension}');
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
                      widget._messageData![chatPageController.assetsIndex],
                      fromMediaPrivew: true);
                },
                icon: const Icon(Icons.delete_rounded),
              ),
            ),
            IconButton(
              alignment: Alignment.center,
              icon: const Icon(
                Icons.close_rounded,
                color: IsmChatColors.blackColor,
              ),
              onPressed: () {
                Get.back<void>();
              },
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
                    itemBuilder: (
                      BuildContext context,
                      int index,
                    ) {
                      var url = widget._messageData?[index].attachments!.first
                              .mediaUrl ??
                          '';
                      var customType =
                          (widget._messageData?[index].messageType ==
                                  IsmChatMessageType.normal)
                              ? widget._messageData![index].customType
                              : widget._messageData?[index].metaData
                                  ?.replyMessage?.parentMessageMessageType;
                      return customType == IsmChatCustomMessageType.image
                          ? PhotoView(
                              backgroundDecoration: const BoxDecoration(
                                  color: Colors.transparent),
                              imageProvider: url.isValidUrl
                                  ? NetworkImage(url)
                                  : kIsWeb
                                      ? MemoryImage(url.strigToUnit8List)
                                          as ImageProvider
                                      : AssetImage(url),
                              loadingBuilder: (context, event) =>
                                  const IsmChatLoadingDialog(),
                              wantKeepAlive: true,
                            )
                          : VideoViewPage(path: url);
                    },
                    onPageChanged: (index) {
                      initiated = widget._messageData?[index].sentByMe ?? false;
                      mediaTime =
                          widget._messageData?[index].sentAt.deliverTime ?? '';
                      chatPageController.assetsIndex = index;
                      mediaSize = IsmChatUtility.formatBytes(
                        int.parse(
                            '${widget._messageData![index].attachments?.first.size}'),
                      );
                      updateState();
                    },
                    itemCount: widget._messageData?.length ?? 0,
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
                              initiated = widget
                                      ._messageData?[
                                          chatPageController.assetsIndex]
                                      .sentByMe ??
                                  false;
                              mediaTime = widget
                                      ._messageData?[
                                          chatPageController.assetsIndex]
                                      .sentAt
                                      .deliverTime ??
                                  '';
                              updateState();
                              await pageController.animateToPage(
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
                                  (widget._messageData?.length ?? 0) - 1)
                              ? 0
                              : 1,
                          child: IsmChatTapHandler(
                            onTap: () async {
                              chatPageController.assetsIndex++;
                              initiated = widget
                                      ._messageData?[
                                          chatPageController.assetsIndex]
                                      .sentByMe ??
                                  false;
                              mediaTime = widget
                                      ._messageData?[
                                          chatPageController.assetsIndex]
                                      .sentAt
                                      .deliverTime ??
                                  '';
                              updateState();
                              await pageController.animateToPage(
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
              width: Get.width,
              alignment: Alignment.center,
              height: IsmChatDimens.sixty,
              margin: IsmChatDimens.edgeInsets10,
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                separatorBuilder: (context, index) => IsmChatDimens.boxWidth8,
                itemCount: widget._messageData?.length ?? 0,
                itemBuilder: (context, index) {
                  var media = widget._messageData?[index].attachments;
                  var isVideo = IsmChatConstants.videoExtensions.contains(
                    media?.first.extension,
                  );
                  return InkWell(
                    onTap: () async {
                      initiated = widget._messageData?[index].sentByMe ?? false;
                      mediaTime =
                          widget._messageData?[index].sentAt.deliverTime ?? '';

                      chatPageController.assetsIndex = index;
                      chatPageController.isVideoVisible = false;
                      await pageController.animateToPage(index,
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
                                ? media?.first.thumbnailUrl?.isValidUrl == true
                                    ? Image.network(
                                        media?.first.thumbnailUrl ?? '',
                                        fit: BoxFit.cover,
                                      )
                                    : Image.memory(
                                        media?.first.thumbnailUrl!
                                                .strigToUnit8List ??
                                            Uint8List(0),
                                        fit: BoxFit.cover,
                                      )
                                : Image.network(
                                    media?.first.mediaUrl ?? '',
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
