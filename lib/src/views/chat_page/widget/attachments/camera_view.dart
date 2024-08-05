import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_flutter_chat/src/utilities/blob_html.dart';

class IsmChatCameraView extends StatefulWidget {
  const IsmChatCameraView({super.key});

  static const String route = IsmPageRoutes.cameraView;

  @override
  State<IsmChatCameraView> createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<IsmChatCameraView> {
  @override
  void dispose() {
    if (IsmChatResponsive.isWeb(Get.context!)) {
      Get.find<IsmChatPageController>().cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size(
                Get.width,
                IsmChatDimens.zero,
              ),
              child: AppBar(
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: IsmChatColors.blackColor,
                  statusBarBrightness: Brightness.light,
                ),
                backgroundColor: IsmChatColors.blackColor,
                elevation: 0,
              ),
            ),
            backgroundColor: IsmChatColors.blackColor,
            body: Stack(
              alignment: Alignment.center,
              children: [
                Visibility(
                  visible: controller.areCamerasInitialized,
                  replacement: const IsmChatLoadingDialog(),
                  child: CameraPreview(controller.cameraController),
                ),
                if (controller.isRecording) ...[
                  Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: IsmChatDimens.thirty,
                      width: IsmChatDimens.eighty,
                      margin: IsmChatDimens.edgeInsetsTop20.copyWith(top: 40),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: IsmChatColors.greenColor,
                        borderRadius: BorderRadius.circular(IsmChatDimens.five),
                      ),
                      child: Text(
                        controller.myDuration.formatDuration(),
                        style: const TextStyle(color: IsmChatColors.whiteColor),
                      ),
                    ),
                  )
                ] else ...[
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: IsmChatDimens.edgeInsetsTop20.copyWith(top: 40),
                      child: IconButton(
                        onPressed: () {
                          if (IsmChatResponsive.isWeb(context)) {
                            controller.isCameraView = false;
                          } else {
                            Get.back();
                          }
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: IsmChatColors.whiteColor,
                        ),
                      ),
                    ),
                  ),
                ],
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: IsmChatDimens.percentWidth(1),
                    color: Colors.transparent,
                    padding: IsmChatDimens.edgeInsets20_0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: IsmChatResponsive.isWeb(context)
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.spaceBetween,
                          children: [
                            if (!IsmChatResponsive.isWeb(context))
                              IconButton(
                                icon: Icon(
                                  controller.flashMode.icon,
                                  color: IsmChatColors.whiteColor,
                                ),
                                onPressed: controller.toggleFlash,
                              ),
                            GestureDetector(
                              onLongPressStart: (_) async {
                                if ([FlashMode.always, FlashMode.auto]
                                    .contains(controller.flashMode)) {
                                  controller.toggleFlash(FlashMode.torch);
                                }

                                await controller.cameraController
                                    .startVideoRecording();
                                controller.startTimer();
                                controller.isRecording = true;
                              },
                              onLongPressEnd: (_) async {
                                var file = await controller.cameraController
                                    .stopVideoRecording();
                                setState(() {
                                  controller.isRecording = false;
                                  controller.forRecordTimer?.cancel();
                                  controller.myDuration = const Duration();
                                  if (controller.flashMode != FlashMode.off) {
                                    controller.toggleFlash(FlashMode.off);
                                  }
                                  if (!controller.isFrontCameraSelected) {
                                    // Becauase after coming back from edit video screen, the default camera should be front camera
                                    controller.toggleCamera();
                                  }
                                });

                                if (kIsWeb) {
                                  var bytes = await file.readAsBytes();
                                  var fileSize = IsmChatUtility.formatBytes(
                                    int.parse(bytes.length.toString()),
                                  );
                                  var thumbnailBytes =
                                      await IsmChatBlob.getVideoThumbnailBytes(
                                          bytes);
                                  controller.webMedia.add(
                                    WebMediaModel(
                                      dataSize: fileSize,
                                      isVideo: true,
                                      platformFile: IsmchPlatformFile(
                                        name:
                                            '${DateTime.now().millisecondsSinceEpoch}.mp4',
                                        bytes: bytes,
                                        path: file.path,
                                        size: 0,
                                        extension: 'mp4',
                                      ),
                                      thumbnailBytes: thumbnailBytes!,
                                    ),
                                  );
                                } else {
                                  IsmChatRouteManagement.goToVideView(
                                      file: File(file.path));
                                }
                              },
                              onTap: controller.isRecording
                                  ? null
                                  : controller.takePhoto,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: IsmChatColors.whiteColor,
                                    width: IsmChatDimens.two,
                                  ),
                                  shape: BoxShape.circle,
                                  color: controller.isRecording
                                      ? Colors.red
                                      : IsmChatConfig.chatTheme.primaryColor,
                                ),
                                height: IsmChatDimens.sixty,
                                width: IsmChatDimens.sixty,
                              ),
                            ),
                            if (!IsmChatResponsive.isWeb(context))
                              IconButton(
                                icon: const Icon(
                                  Icons.flip_camera_ios,
                                  color: Colors.white,
                                ),
                                onPressed: controller.toggleCamera,
                              ),
                          ],
                        ),
                        IsmChatDimens.boxHeight10,
                        Text(
                          'Hold for Video, Tap for Photo',
                          style: IsmChatStyles.w500White14,
                        ),
                        IsmChatDimens.boxHeight10,
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
}
