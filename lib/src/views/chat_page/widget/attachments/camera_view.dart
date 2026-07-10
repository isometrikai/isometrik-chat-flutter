import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';

class IsmChatCameraView extends StatefulWidget {
  const IsmChatCameraView({super.key});

  @override
  State<IsmChatCameraView> createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<IsmChatCameraView> {
  final controller = IsmChatUtility.chatPageController;

  Widget _buildCaptureButton({
    required IsmChatPageController controller,
    required bool isMobile,
  }) =>
      GestureDetector(
        onLongPressStart: (_) async {
          if ([FlashMode.always, FlashMode.auto].contains(controller.flashMode)) {
            controller.toggleFlash(FlashMode.torch);
          }

          await controller.cameraController.startVideoRecording();
          controller
            ..startTimer()
            ..isRecording = true;
        },
        onLongPressEnd: (_) async {
          var file = await controller.cameraController.stopVideoRecording();
          controller.areCamerasInitialized = false;
          try {
            await controller.cameraController.dispose();
          } catch (_) {}
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
              int.parse(
                bytes.length.toString(),
              ),
            );
            var thumbnailBytes =
                await IsmChatBlob.getVideoThumbnailBytesWithPackage(
              bytes,
            );
            controller.webMedia.add(
              WebMediaModel(
                dataSize: fileSize,
                isVideo: true,
                platformFile: IsmchPlatformFile(
                  name: '${DateTime.now().millisecondsSinceEpoch}.mp4',
                  bytes: bytes,
                  path: file.path,
                  size: bytes.length,
                  extension: 'mp4',
                  thumbnailBytes: thumbnailBytes,
                ),
              ),
            );
          } else {
            await IsmChatRoute.goToRoute(IsmChatVideoView(
              file: file,
            ));
          }
        },
        onTap: controller.isRecording ? null : controller.takePhoto,
        child: isMobile
            ? Container(
                height: IsmChatDimens.seventy,
                width: IsmChatDimens.seventy,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: IsmChatColors.whiteColor,
                    width: IsmChatDimens.three,
                  ),
                ),
                alignment: Alignment.center,
                child: Container(
                  height: IsmChatDimens.fifty,
                  width: IsmChatDimens.fifty,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.isRecording
                        ? Colors.red
                        : IsmChatColors.whiteColor,
                  ),
                ),
              )
            : Container(
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
      );

  Widget _buildBottomControls(
    BuildContext context,
    IsmChatPageController controller,
  ) {
    final isMobile = !IsmChatResponsive.isWeb(context);

    return Container(
      width: IsmChatDimens.percentWidth(1),
      color: isMobile ? IsmChatColors.blackColor : Colors.transparent,
      padding: isMobile
          ? IsmChatDimens.edgeInsets20_0.copyWith(
              top: IsmChatDimens.sixteen,
              bottom: MediaQuery.paddingOf(context).bottom + IsmChatDimens.ten,
            )
          : IsmChatDimens.edgeInsets20_0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: isMobile
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isMobile)
                IconButton(
                  icon: Icon(
                    controller.flashMode.icon,
                    color: IsmChatColors.whiteColor,
                  ),
                  onPressed: controller.toggleFlash,
                ),
              _buildCaptureButton(
                controller: controller,
                isMobile: isMobile,
              ),
              if (isMobile)
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
          if (!isMobile) IsmChatDimens.boxHeight10,
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Prevent CameraPreview from building with a disposed controller on rebuild.
    controller.areCamerasInitialized = false;
    try {
      controller.cameraController.dispose();
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => MediaQuery.removePadding(
          removeTop: true,
          context: context,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size(
                IsmChatDimens.percentWidth(1),
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
            body: IsmChatResponsive.isWeb(context)
                ? Stack(
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
                            margin:
                                IsmChatDimens.edgeInsetsTop20.copyWith(top: 40),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: IsmChatColors.greenColor,
                              borderRadius:
                                  BorderRadius.circular(IsmChatDimens.five),
                            ),
                            child: Text(
                              controller.myDuration.formatDuration,
                              style: const TextStyle(
                                  color: IsmChatColors.whiteColor),
                            ),
                          ),
                        )
                      ] else ...[
                        Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding:
                                IsmChatDimens.edgeInsetsTop20.copyWith(top: 40),
                            child: IconButton(
                              onPressed: () async {
                                controller.isCameraView = false;
                                controller.areCamerasInitialized = false;
                                try {
                                  await controller.cameraController.dispose();
                                } catch (_) {}
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
                        child: _buildBottomControls(context, controller),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Expanded(
                        child: Stack(
                          fit: StackFit.expand,
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
                                  margin: IsmChatDimens.edgeInsetsTop20
                                      .copyWith(top: 40),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: IsmChatColors.greenColor,
                                    borderRadius: BorderRadius.circular(
                                        IsmChatDimens.five),
                                  ),
                                  child: Text(
                                    controller.myDuration.formatDuration,
                                    style: const TextStyle(
                                        color: IsmChatColors.whiteColor),
                                  ),
                                ),
                              )
                            ] else ...[
                              Align(
                                alignment: Alignment.topLeft,
                                child: Padding(
                                  padding: IsmChatDimens.edgeInsetsTop20
                                      .copyWith(top: 40),
                                  child: IconButton(
                                    onPressed: () {
                                      IsmChatRoute.goBack();
                                    },
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: IsmChatColors.whiteColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      _buildBottomControls(context, controller),
                    ],
                  ),
          ),
        ),
      );
}
