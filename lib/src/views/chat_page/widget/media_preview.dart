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
  final chatPageController = IsmChatUtility.chatPageController;

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
  Widget build(BuildContext context) {
    final mediaTheme = IsmChatThemeResolver.mediaFromConfig(context);
    final dialogTheme = IsmChatThemeResolver.dialogFromConfig(context);
    final headerTheme = IsmChatConfig.chatTheme.chatPageHeaderTheme;
    final isDark = IsmChatThemeResolver.brightness(context) == Brightness.dark;
    final iconColor =
        headerTheme?.iconColor ?? mediaTheme.appBarIconColor;
    final menuLabelStyle = mediaTheme.docTitleTextStyle;

    return Scaffold(
      backgroundColor: mediaTheme.previewBackgroundColor,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarColor: mediaTheme.previewBackgroundColor,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        backgroundColor: mediaTheme.previewBackgroundColor,
        iconTheme: IconThemeData(color: iconColor),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              initiated ? IsmChatStrings.you : widget.mediaUserName.toString(),
              style: mediaTheme.previewTitleTextStyle,
            ),
            Text(
              mediaTime,
              style: mediaTheme.previewSubtitleTextStyle,
            )
          ],
        ),
        centerTitle: false,
        leading: IconButton(
          onPressed: IsmChatRoute.goBack<void>,
          icon: Icon(
            IsmChatResponsive.isWeb(context)
                ? Icons.close_rounded
                : Icons.arrow_back_rounded,
            color: iconColor,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
                right: IsmChatDimens.five, top: IsmChatDimens.two),
            child: PopupMenuButton(
              color: dialogTheme.backgroundColor,
              icon: Icon(
                Icons.more_vert,
                color: iconColor,
              ),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 1,
                  child: Row(
                    children: [
                      Icon(
                        Icons.share_rounded,
                        color: iconColor,
                      ),
                      IsmChatDimens.boxWidth8,
                      Text(
                        IsmChatStrings.share,
                        style: menuLabelStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 2,
                  child: Row(
                    children: [
                      Icon(
                        Icons.save_rounded,
                        color: iconColor,
                      ),
                      IsmChatDimens.boxWidth8,
                      Text(
                        IsmChatStrings.save,
                        style: menuLabelStyle,
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 3,
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_rounded,
                        color: iconColor,
                      ),
                      IsmChatDimens.boxWidth8,
                      Text(
                        IsmChatStrings.delete,
                        style: menuLabelStyle,
                      ),
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
        child: ColoredBox(
          color: mediaTheme.previewBackgroundColor,
          child: PageView.builder(
            controller: pageController,
            itemBuilder: (BuildContext context, int index) {
              final media = widget.messageData[index];
              var url = media.attachments?.first.mediaUrl ?? '';
              var customType = media.messageType == IsmChatMessageType.forward
                  ? media.customType
                  : (media.messageType == IsmChatMessageType.reply
                      ? media.metaData?.replyMessage?.parentMessageMessageType
                      : media.customType);
              return customType == IsmChatCustomMessageType.image
                  ? PhotoView(
                      backgroundDecoration: BoxDecoration(
                        color: mediaTheme.previewBackgroundColor,
                      ),
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
                  : SizedBox.expand(
                      child: VideoViewPage(path: url),
                    );
            },
            onPageChanged: (index) {
              final timeStamp = DateTime.fromMillisecondsSinceEpoch(
                  widget.messageData[index].sentAt);
              final time = DateFormat.jm().format(timeStamp);
              final monthDay = DateFormat.MMMd().format(timeStamp);
              setState(
                () {
                  mediaIndex = index;
                  initiated = widget.messageData[index].sentByMe;
                  mediaTime = '$monthDay, $time';
                },
              );
            },
            itemCount: widget.messageData.length,
          ),
        ),
      ),
    );
  }
}

/// Audio preview dialog (from [IsmMedia] or chat). Uses [IsmChatThemeResolver.mediaFromConfig].
class AudioPreview extends StatelessWidget {
  const AudioPreview({super.key, required this.message});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final mediaTheme = IsmChatThemeResolver.mediaFromConfig(context);
    final actionStyle = mediaTheme.docTitleTextStyle.copyWith(
      fontWeight: FontWeight.w700,
    );
    final actionIconColor = mediaTheme.appBarIconColor;

    return Dialog(
      backgroundColor: mediaTheme.scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(IsmChatDimens.sixteen),
      ),
      insetPadding: IsmChatDimens.edgeInsets16,
      child: GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => Padding(
          padding: IsmChatDimens.edgeInsets16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: IsmChatDimens.four,
                runSpacing: IsmChatDimens.four,
                children: [
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.shareMedia(message);
                    },
                    icon: Icon(
                      Icons.share_rounded,
                      color: actionIconColor,
                    ),
                    label: Text(
                      IsmChatStrings.share,
                      style: actionStyle,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.saveMedia(message);
                    },
                    icon: Icon(
                      Icons.save_rounded,
                      color: actionIconColor,
                    ),
                    label: Text(
                      IsmChatStrings.save,
                      style: actionStyle,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      IsmChatRoute.goBack();
                      await controller.showDialogForMessageDelete(
                        message,
                        fromMediaPrivew: true,
                      );
                    },
                    icon: Icon(
                      Icons.delete_rounded,
                      color: actionIconColor,
                    ),
                    label: Text(
                      IsmChatStrings.delete,
                      style: actionStyle,
                    ),
                  ),
                ],
              ),
              IsmChatDimens.boxHeight10,
              IsmChatAudioPlayer(message: message),
            ],
          ),
        ),
      ),
    );
  }
}
