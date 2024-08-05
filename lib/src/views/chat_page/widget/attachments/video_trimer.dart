import 'dart:io';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_trimmer/video_trimmer.dart';

// Todo refactor code
class IsmVideoTrimmerView extends StatefulWidget {
  const IsmVideoTrimmerView({
    super.key,
    required this.file,
    required this.durationInSeconds,
    this.index,
  });
  final File file;
  final double durationInSeconds;
  final int? index;

  @override
  State<IsmVideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<IsmVideoTrimmerView> {
  final Trimmer trimmer = Trimmer();
  var startValue = 0.0.obs;
  var endValue = 0.0.obs;
  var isPlaying = false.obs;
  var playPausedAction = true;
  var descriptionTEC = TextEditingController();

  @override
  void initState() {
    super.initState();
    endValue = widget.durationInSeconds.obs;

    loadVideo();
  }

  loadVideo() async {
    await trimmer.loadVideo(videoFile: widget.file);
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
          Get.back<File>(result: File(value));
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
              Get.back<File>(result: widget.file);
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
                        Duration(seconds: widget.durationInSeconds.toInt()),
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
