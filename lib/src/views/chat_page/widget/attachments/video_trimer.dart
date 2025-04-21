import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:video_trimmer/video_trimmer.dart';

class IsmVideoTrimmerView extends StatefulWidget {
  const IsmVideoTrimmerView(
      {super.key,
      required this.maxVideoTrim,
      required this.file,
      required this.index});

  final XFile file;
  final double maxVideoTrim;
  final int index;

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
  bool isShowTrimmer = false;
  int videoRotationIndex = -1;
  final List<File> thumbnails = [];
  var file = XFile('');

  @override
  void initState() {
    super.initState();
    maxVideoTrim = widget.maxVideoTrim;
    file = widget.file;
    loadVideo(file.path);
  }

  loadVideo(String url) async {
    _controller = VideoPlayerController.file(
      File(file.path),
    );
    await _controller.initialize();
    await _controller.setLooping(false);
    await _controller.play();
    generateThumbnails();
    videoDuration = _controller.value.duration.inMilliseconds.toDouble();
    endValue = videoDuration;
    updateState();
  }

  void generateThumbnails() async {
    final count = 10;
    final interval = _controller.value.duration.inSeconds ~/ count;
    thumbnails.clear();

    for (var i = 0; i <= count; i++) {
      final timeMs = (i * interval * 1000).toInt();
      final thumb =
          await VideoEditorBuilder(videoPath: file.path).generateThumbnail(
        positionMs: timeMs,
        quality: 50,
      );
      if (thumb.isNullOrEmpty) continue;
      thumbnails.add(File(thumb ?? ''));
    }
    updateState();
  }

  void saveTrimVideo() async {
    IsmChatUtility.showLoader();
    final editor = VideoEditorBuilder(videoPath: file.path).trim(
      startTimeMs: startValue.toInt(),
      endTimeMs: endValue.toInt(),
    );
    final trimVideo = await editor.export();
    IsmChatUtility.closeLoader();
    if (!trimVideo.isNullOrEmpty) {
      IsmChatRoute.goBack<XFile>(XFile(trimVideo ?? ''));
    }
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
              IsmChatRoute.goBack<XFile>(file);
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
