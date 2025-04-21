import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_compress/video_compress.dart';

class IsmChatGalleryAssetsView extends StatelessWidget {
  const IsmChatGalleryAssetsView({super.key, required this.mediaXFile});

  final List<XFile?> mediaXFile;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.tag,
        initState: (state) {
          state.controller?.selectAssets(mediaXFile);
        },
        builder: (controller) {
          if (controller.webMedia.isNotEmpty) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: IsmChatAppBar(
                title: Text(
                  controller.webMedia[controller.assetsIndex].dataSize,
                  style:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                          IsmChatStyles.w600White14,
                ),
                centerTitle: true,
                leading: InkWell(
                  child: Icon(
                    Icons.clear,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.whiteColor,
                  ),
                  onTap: () {
                    IsmChatRoute.goBack<void>();
                    controller.webMedia.clear();
                    controller.isVideoVisible = false;
                  },
                ),
                action: [
                  IsmChatConstants.imageExtensions.contains(controller
                          .webMedia[controller.assetsIndex]
                          .platformFile
                          .extension)
                      ? Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                await controller.cropImage(
                                  url: controller
                                          .webMedia[controller.assetsIndex]
                                          .platformFile
                                          .path ??
                                      '',
                                  forGalllery: true,
                                  selectedIndex: controller.assetsIndex,
                                );
                              },
                              child: Icon(
                                Icons.crop,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                            IsmChatDimens.boxWidth16,
                            InkWell(
                              onTap: () async {
                                await controller.paintImage(
                                  url: controller
                                          .webMedia[controller.assetsIndex]
                                          .platformFile
                                          .path ??
                                      '',
                                  forGalllery: true,
                                  selectedIndex: controller.assetsIndex,
                                );
                              },
                              child: Icon(
                                Icons.edit,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                            IsmChatDimens.boxWidth16,
                            InkWell(
                              onTap: () {
                                controller.webMedia
                                    .removeAt(controller.assetsIndex);
                                controller.assetsIndex =
                                    controller.webMedia.length - 1;
                                if (controller.webMedia.isEmpty) {
                                  IsmChatRoute.goBack<void>();
                                }
                              },
                              child: Icon(
                                Icons.delete_forever,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            IconButton(
                              onPressed: () async {
                                controller.isVideoVisible = true;
                                var mediaFile =
                                    await IsmChatRoute.goToRoute<XFile>(
                                        IsmVideoTrimmerView(
                                  index: controller.assetsIndex,
                                  file: XFile(
                                    controller.webMedia[controller.assetsIndex]
                                            .platformFile.path ??
                                        '',
                                  ),
                                  maxVideoTrim: 30,
                                ));
                                if (mediaFile == null) return;
                                final thumb = await VideoEditorBuilder(
                                        videoPath: mediaFile.path)
                                    .generateThumbnail(
                                  quality: 50,
                                  positionMs: 1,
                                );
                                final thumbFile = File(thumb ?? '');
                                final thumbnailBytes =
                                    await thumbFile.readAsBytes();
                                var bytes = await mediaFile.readAsBytes();
                                final fileSize = IsmChatUtility.formatBytes(
                                  int.parse(bytes.length.toString()),
                                );
                                controller.webMedia[controller.assetsIndex] =
                                    WebMediaModel(
                                  dataSize: fileSize,
                                  isVideo: true,
                                  platformFile: IsmchPlatformFile(
                                    name: mediaFile.name,
                                    bytes: bytes,
                                    path: mediaFile.path,
                                    size: bytes.length,
                                    extension: mediaFile.mimeType,
                                    thumbnailBytes: thumbnailBytes,
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.video_settings_rounded,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.webMedia
                                    .removeAt(controller.assetsIndex);
                                controller.assetsIndex =
                                    controller.webMedia.length - 1;
                                if (controller.webMedia.isEmpty) {
                                  controller.assetsIndex = 0;
                                  IsmChatRoute.goBack<void>();
                                }
                              },
                              icon: Icon(
                                Icons.delete_forever_rounded,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                          ],
                        ),
                  IsmChatDimens.boxWidth20
                ],
              ),
              backgroundColor: IsmChatColors.blackColor,
              body: SafeArea(
                child: PageView.builder(
                  controller: controller.pageController,
                  itemCount: controller.webMedia.length,
                  itemBuilder: (BuildContext context, int index) {
                    final url =
                        controller.webMedia[index].platformFile.path ?? '';

                    return IsmChatConstants.imageExtensions.contains(
                            controller.webMedia[index].platformFile.extension)
                        ? PhotoView(
                            imageProvider: url.isValidUrl
                                ? NetworkImage(url) as ImageProvider
                                : FileImage(File(url)),
                            loadingBuilder: (context, event) =>
                                const IsmChatLoadingDialog(),
                            wantKeepAlive: true,
                          )
                        : VideoViewPage(
                            path: url,
                            showVideoPlaying: true,
                          );
                  },
                  onPageChanged: (value) async {
                    controller.textEditingController.text =
                        controller.webMedia[value].caption ?? '';
                    controller.assetsIndex = value;
                    controller.isVideoVisible = false;
                  },
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              floatingActionButton: ColoredBox(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IsmChatDimens.boxHeight10,
                    Container(
                      width: IsmChatDimens.percentWidth(1),
                      alignment: Alignment.center,
                      height: IsmChatDimens.sixty,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) =>
                            IsmChatDimens.boxWidth8,
                        itemCount: controller.webMedia.length,
                        itemBuilder: (context, index) {
                          var media = controller.webMedia[index];
                          return InkWell(
                            onTap: () async {
                              controller.textEditingController.text =
                                  media.caption ?? '';
                              controller.assetsIndex = index;
                              controller.isVideoVisible = false;
                              await controller.pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.linear);
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  height: IsmChatDimens.sixty,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(IsmChatDimens.ten)),
                                      border: controller.assetsIndex == index
                                          ? Border.all(
                                              color: Get
                                                  .theme.secondaryHeaderColor,
                                              width: IsmChatDimens.two)
                                          : null),
                                  width: IsmChatDimens.sixty,
                                  child: Builder(
                                      builder: (context) => IsmChatImage(
                                            media.isVideo
                                                ? media
                                                    .platformFile.thumbnailBytes
                                                    .toString()
                                                : media.platformFile.path ?? '',
                                            isNetworkImage:
                                                kIsWeb && media.isVideo
                                                    ? false
                                                    : kIsWeb,
                                            isBytes: media.isVideo,
                                          )),
                                ),
                                if (media.isVideo)
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
                    Padding(
                      padding: IsmChatDimens.edgeInsets10_0,
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
                              onChanged: (value) {
                                controller.webMedia[controller.assetsIndex]
                                    .caption = value;
                              },
                            ),
                          ),
                          IsmChatDimens.boxWidth8,
                          IsmChatStartChatFAB(
                            onTap: () async {
                              controller.sendMedia();
                            },
                            icon: const Icon(
                              Icons.send,
                              color: IsmChatColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
