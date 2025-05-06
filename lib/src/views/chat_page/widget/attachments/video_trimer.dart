import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:video_trimmer/video_trimmer.dart';

class IsmVideoTrimmerView extends StatefulWidget {
  const IsmVideoTrimmerView({super.key});

  static const String route = IsmPageRoutes.videoTrimView;

  @override
  State<IsmVideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<IsmVideoTrimmerView> {
  final Trimmer trimmer = Trimmer();
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var durationInSeconds = 0.0;
  var isPlaying = false.obs;
  var playPausedAction = true;
  var descriptionTEC = TextEditingController();
  final arguments = Get.arguments as Map<String, dynamic>? ?? {};
  var file = XFile('');

  @override
  void initState() {
    super.initState();
    endValue = (arguments['durationInSeconds'] as double? ?? 0).obs;
    durationInSeconds = endValue.value;
    file = arguments['file'] as XFile? ?? XFile('');
    loadVideo(file.path);
  }

  loadVideo(String url) async {
    await trimmer.loadVideo(videoFile: File(url));
    trimmer.videoPlayerController?.addListener(checkVideo);
  }

  checkVideo() async {
    if (trimmer.videoPlayerController?.value.isPlaying == false) {
      setState(() {
        playPausedAction = true;
      });
    }
  }

  Future<void> saveTrimVideo(double startValue, double endValue) async {
    await trimmer.saveTrimmedVideo(
      startValue: startValue,
      endValue: endValue,
      onSave: (value) {
        if (value != null) {
          Get.back<XFile>(result: XFile(value));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmChatColors.blackColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back<XFile>(result: file);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: IsmChatColors.whiteColor,
            ),
          ),
          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          actions: [
            IconButton(
              onPressed: () async {
                IsmChatUtility.showLoader();
                await saveTrimVideo(startValue.value, endValue.value);
                IsmChatUtility.closeLoader();
              },
              icon: const Icon(
                Icons.save_rounded,
                color: IsmChatColors.whiteColor,
              ),
            )
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            IsmChatTapHandler(
              onTap: () async {
                var playBackState = await trimmer.videoPlaybackControl(
                  startValue: startValue.value,
                  endValue: endValue.value,
                );
                isPlaying.value = playBackState;
                playPausedAction = true;
                setState(() {});
                if (playBackState == false) return;
                await Future<void>.delayed(const Duration(milliseconds: 1000));
                playPausedAction = false;
                setState(() {});
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio:
                        trimmer.videoPlayerController?.value.aspectRatio ?? 0,
                    child: VideoViewer(
                      trimmer: trimmer,
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: playPausedAction ? 1 : 0,
                    child:
                        trimmer.videoPlayerController?.value.isPlaying == true
                            ? Icon(
                                Icons.pause_circle_rounded,
                                color: IsmChatColors.whiteColor,
                                size: IsmChatDimens.sixty,
                              )
                            : Icon(
                                Icons.play_arrow_rounded,
                                color: IsmChatColors.whiteColor,
                                size: IsmChatDimens.sixty,
                              ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: IsmChatDimens.edgeInsetsTop10
                    .copyWith(top: IsmChatDimens.hundred + IsmChatDimens.ten),
                child: SizedBox(
                  width: IsmChatDimens.percentWidth(.95),
                  child: TrimViewer(
                    showDuration: true,
                    durationStyle: DurationStyle.FORMAT_MM_SS,
                    trimmer: trimmer,
                    viewerWidth: IsmChatDimens.percentWidth(.95),
                    maxVideoLength:
                        Duration(seconds: durationInSeconds.toInt()),
                    onChangeStart: (value) {
                      startValue.value = value;
                    },
                    onChangeEnd: (value) {
                      endValue.value = value;
                    },
                    onChangePlaybackState: (value) {
                      isPlaying.value = false;
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      );
}
