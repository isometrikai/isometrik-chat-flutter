import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
import 'package:video_compress/video_compress.dart';

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

  WebMediaModel? webMediaModel;

  final controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  @override
  void initState() {
    super.initState();
    _startInit();
  }

  void _voidConfig(XFile file) async {
    var name = '';
    if (kIsWeb) {
      name = '${DateTime.now().millisecondsSinceEpoch}.png';
    } else {
      name = file.path.split('/').last;
    }
    var bytes = await file.readAsBytes();
    final extension = name.split('.').last;
    var dataSize = IsmChatUtility.formatBytes(bytes.length);
    var platformFile = IsmchPlatformFile(
      name: name,
      size: bytes.length,
      bytes: bytes,
      path: file.path,
      extension: extension,
    );

    var thumbnailBytes = Uint8List(0);
    if (kIsWeb) {
      thumbnailBytes =
          await IsmChatBlob.getVideoThumbnailBytes(bytes) ?? Uint8List(0);
    } else {
      final thumb = await VideoCompress.getByteThumbnail(file.path,
          quality: 50, position: 1);
      thumbnailBytes = thumb ?? Uint8List(0);
    }
    platformFile.thumbnailBytes = thumbnailBytes;
    webMediaModel = WebMediaModel(
      dataSize: dataSize,
      isVideo: true,
      platformFile: platformFile,
    );
    safeUpdate();
  }

  void _startInit() async {
    final argumnet = Get.arguments as Map<String, dynamic>;
    final file = argumnet['file'] as XFile? ?? XFile('');
    _voidConfig(file);
  }

  void safeUpdate() async {
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
            webMediaModel?.dataSize ?? '',
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
                var trimFile = await IsmChatRouteManagement.goToVideoTrimeView(
                  index: 0,
                  file: XFile(
                    webMediaModel?.platformFile.path ?? '',
                  ),
                  maxVideoTrim: 30,
                );

                _voidConfig(trimFile);
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
            VideoViewPage(path: webMediaModel?.platformFile.path ?? ''),
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
                  onChanged: (value) {
                    webMediaModel?.caption = value;
                    safeUpdate();
                  },
                ),
              ),
              IsmChatDimens.boxWidth8,
              FloatingActionButton(
                backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                onPressed: () async {
                  if (webMediaModel?.dataSize.size() ?? false) {
                    Get.back<void>();
                    Get.back<void>();
                    if (await IsmChatProperties.chatPageProperties
                            .messageAllowedConfig?.isMessgeAllowed
                            ?.call(Get.context!, controller.conversation!,
                                IsmChatCustomMessageType.video) ??
                        true) {
                      await controller.sendVideo(
                        webMediaModel: webMediaModel!,
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
