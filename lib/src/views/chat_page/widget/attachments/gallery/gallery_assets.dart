import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';

class IsmChatGalleryAssetsView extends StatelessWidget {
  IsmChatGalleryAssetsView({
    super.key,
  });

  static const String route = IsmPageRoutes.alleryAssetsView;

  final argument = Get.arguments['fileList'] as List<XFile?>? ?? [];

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.tag,
        initState: (state) {
          state.controller?.listOfAssetsPath.clear();
          state.controller?.selectAssets(argument);
          state.controller?.textEditingController.clear();
        },
        builder: (controller) {
          if (controller.listOfAssetsPath.isNotEmpty) {
            return Scaffold(
              resizeToAvoidBottomInset: true,
              appBar: IsmChatAppBar(
                title: Text(
                  controller.dataSize,
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
                    Get.back<void>();
                    controller.listOfAssetsPath.clear();
                    controller.isVideoVisible = false;
                  },
                ),
                action: [
                  IsmChatConstants.imageExtensions.contains(controller
                          .listOfAssetsPath[controller.assetsIndex]
                          .attachmentModel
                          .mediaUrl!
                          .split('.')
                          .last)
                      ? Row(
                          children: [
                            InkWell(
                              onTap: () async {
                                await controller.cropImage(File(controller
                                        .listOfAssetsPath[
                                            controller.assetsIndex]
                                        .attachmentModel
                                        .mediaUrl ??
                                    ''));
                                controller.listOfAssetsPath[
                                    controller
                                        .assetsIndex] = controller
                                    .listOfAssetsPath[controller.assetsIndex]
                                    .copyWith(
                                  attachmentModel: controller
                                      .listOfAssetsPath[controller.assetsIndex]
                                      .attachmentModel
                                      .copyWith(
                                          mediaUrl: controller.imagePath?.path),
                                );

                                controller.dataSize =
                                    await IsmChatUtility.fileToSize(
                                  File(controller
                                          .listOfAssetsPath[
                                              controller.assetsIndex]
                                          .attachmentModel
                                          .mediaUrl ??
                                      ''),
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
                                var mediaFile = await Get.to<File>(
                                  IsmChatImagePainterWidget(
                                    file: File(
                                      controller
                                              .listOfAssetsPath[
                                                  controller.assetsIndex]
                                              .attachmentModel
                                              .mediaUrl ??
                                          '',
                                    ),
                                  ),
                                );
                                controller.listOfAssetsPath[
                                    controller
                                        .assetsIndex] = controller
                                    .listOfAssetsPath[controller.assetsIndex]
                                    .copyWith(
                                  attachmentModel: controller
                                      .listOfAssetsPath[controller.assetsIndex]
                                      .attachmentModel
                                      .copyWith(mediaUrl: mediaFile?.path),
                                );
                                controller.dataSize =
                                    await IsmChatUtility.fileToSize(
                                  File(controller
                                          .listOfAssetsPath[
                                              controller.assetsIndex]
                                          .attachmentModel
                                          .mediaUrl ??
                                      ''),
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
                                controller.listOfAssetsPath
                                    .removeAt(controller.assetsIndex);
                                if (controller.listOfAssetsPath.isEmpty) {
                                  Get.back<void>();
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
                                var mediaFile = await Get.to<File>(
                                  IsmVideoTrimmerView(
                                    index: controller.assetsIndex,
                                    file: File(
                                      controller
                                              .listOfAssetsPath[
                                                  controller.assetsIndex]
                                              .attachmentModel
                                              .mediaUrl ??
                                          '',
                                    ),
                                    durationInSeconds: 30,
                                  ),
                                );

                                controller.listOfAssetsPath[
                                    controller
                                        .assetsIndex] = controller
                                    .listOfAssetsPath[controller.assetsIndex]
                                    .copyWith(
                                  attachmentModel: controller
                                      .listOfAssetsPath[controller.assetsIndex]
                                      .attachmentModel
                                      .copyWith(mediaUrl: mediaFile?.path),
                                );
                                controller.dataSize =
                                    await IsmChatUtility.fileToSize(
                                  File(controller
                                          .listOfAssetsPath[
                                              controller.assetsIndex]
                                          .attachmentModel
                                          .mediaUrl ??
                                      ''),
                                );
                              },
                              icon: Icon(
                                Icons.content_cut_rounded,
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme?.iconColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                controller.listOfAssetsPath
                                    .removeAt(controller.assetsIndex);
                                controller.assetsIndex =
                                    controller.listOfAssetsPath.length - 1;
                                if (controller.listOfAssetsPath.isEmpty) {
                                  controller.assetsIndex = 0;
                                  Get.back<void>();
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
                  itemCount: controller.listOfAssetsPath.length,
                  itemBuilder: (BuildContext context, int index) {
                    final url = controller
                            .listOfAssetsPath[index].attachmentModel.mediaUrl ??
                        '';
                    return IsmChatConstants.imageExtensions.contains(controller
                            .listOfAssetsPath[index].attachmentModel.mediaUrl!
                            .split('.')
                            .last)
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
                        controller.listOfAssetsPath[value].caption;
                    controller.assetsIndex = value;
                    controller.isVideoVisible = false;
                    controller.dataSize = await IsmChatUtility.fileToSize(
                      File(controller.listOfAssetsPath[controller.assetsIndex]
                              .attachmentModel.mediaUrl ??
                          ''),
                    );
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
                      width: Get.width,
                      alignment: Alignment.center,
                      height: IsmChatDimens.sixty,
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        separatorBuilder: (context, index) =>
                            IsmChatDimens.boxWidth8,
                        itemCount: controller.listOfAssetsPath.length,
                        itemBuilder: (context, index) {
                          var media = controller.listOfAssetsPath[index];
                          return InkWell(
                            onTap: () async {
                              controller.textEditingController.text =
                                  media.caption;
                              controller.assetsIndex = index;
                              controller.isVideoVisible = false;
                              await controller.pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 100),
                                  curve: Curves.linear);
                              controller.dataSize =
                                  await IsmChatUtility.fileToSize(
                                File(controller
                                        .listOfAssetsPath[
                                            controller.assetsIndex]
                                        .attachmentModel
                                        .mediaUrl ??
                                    ''),
                              );
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
                                  child: IsmChatImage(
                                    media.attachmentModel.attachmentType ==
                                            IsmChatMediaType.video
                                        ? media.attachmentModel.thumbnailUrl ??
                                            ''
                                        : media.attachmentModel.mediaUrl ?? '',
                                    isNetworkImage: false,
                                  ),
                                ),
                                if (media.attachmentModel.attachmentType ==
                                    IsmChatMediaType.video)
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
                                controller.listOfAssetsPath[
                                    controller
                                        .assetsIndex] = controller
                                    .listOfAssetsPath[controller.assetsIndex]
                                    .copyWith(
                                  caption: value,
                                );
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
