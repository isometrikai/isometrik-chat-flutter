import 'dart:io';

import 'package:camera/camera.dart';
import 'package:easy_video_editor/easy_video_editor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:video_player/video_player.dart';

// Todo refactor code
class IsmVideoTrimmerView extends StatefulWidget {
  const IsmVideoTrimmerView({super.key});

  static const String route = IsmPageRoutes.videoTrimView;

  @override
  State<IsmVideoTrimmerView> createState() => _VideoTrimmerViewState();
}

class _VideoTrimmerViewState extends State<IsmVideoTrimmerView> {
  late VideoPlayerController _controller;
  double startValue = 0.0;
  double endValue = 0.0;
  double maxVideoTrim = 0.0;
  double videoDuration = 0.0;
  var playPausedAction = true;
  bool isShowTrimmer = false;
  int videoRotationIndex = -1;
  final List<File> thumbnails = [];
  var file = XFile('');
  final arguments = Get.arguments as Map<String, dynamic>? ?? {};

  @override
  void initState() {
    super.initState();
    maxVideoTrim = arguments['maxVideoTrim'] as double? ?? 0;
    file = arguments['file'] as XFile? ?? XFile('');
    loadVideo(file.path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
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
      Get.back<XFile>(result: XFile(trimVideo ?? ''));
    }
  }

  void rotateToRight() {
    if (videoRotationIndex == 2) {
      videoRotationIndex = -1;
    } else {
      videoRotationIndex++;
    }
    videoRotate(videoRotationIndex);
  }

  void rotateToLeft() {
    if (videoRotationIndex == -1) {
      videoRotationIndex = 2;
    } else {
      videoRotationIndex--;
    }
    videoRotate(videoRotationIndex);
  }

  void videoRotate(int index) async {
    IsmChatUtility.showLoader();
    var videoPath = '';
    if (index != -1) {
      final editor = VideoEditorBuilder(videoPath: file.path)
          .rotate(degree: RotationDegree.values[index]);
      videoPath = await editor.export() ?? '';
    } else {
      videoPath = file.path;
    }
    await _controller.pause();
    await _controller.dispose();
    file = XFile(videoPath);
    _controller = VideoPlayerController.file(File(videoPath));
    await _controller.initialize();
    await _controller.setLooping(false);
    await _controller.play();
    updateState();
    IsmChatUtility.closeLoader();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmChatColors.blackColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Get.back<XFile>(result: file);
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                  IsmChatColors.whiteColor,
            ),
          ),
          backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          actions: [
            IconButton(
              onPressed: () async {
                isShowTrimmer = !isShowTrimmer;
                updateState();
                await Future.delayed(const Duration(seconds: 1));
                updateState();
              },
              icon: Icon(
                isShowTrimmer ? Icons.close_rounded : Icons.content_cut_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
              ),
            ),
            IconButton(
              onPressed: rotateToRight,
              icon: Icon(
                Icons.rotate_right_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
                size: IsmChatDimens.twentyFive,
              ),
            ),
            IconButton(
              onPressed: rotateToLeft,
              icon: Icon(
                Icons.rotate_left_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
                size: IsmChatDimens.twentyFive,
              ),
            ),
            IconButton(
              onPressed: saveTrimVideo,
              icon: Icon(
                Icons.save_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          height: 100,
          padding:
              IsmChatDimens.edgeInsets20.copyWith(bottom: IsmChatDimens.forty),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (context, VideoPlayerValue value, child) => Text(
                  value.position.formatDuration,
                  style: IsmChatStyles.w600White14,
                ),
              ),
              Expanded(
                child: SizedBox(
                  height: IsmChatDimens.five,
                  child: VideoProgressIndicator(_controller,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                          backgroundColor: IsmChatColors.whiteColor,
                          playedColor: IsmChatColors.greenColor),
                      padding: IsmChatDimens.edgeInsetsHorizontal10),
                ),
              ),
              Text(
                _controller.value.duration.formatDuration,
                style: IsmChatStyles.w600White14,
              )
            ],
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              height: IsmChatDimens.percentHeight(1),
              child: IsmChatTapHandler(
                onTap: () async {
                  if (_controller.value.isPlaying) {
                    await _controller.pause();
                    playPausedAction = true;
                    updateState();
                  } else {
                    await _controller.play();
                    await Future.delayed(const Duration(milliseconds: 500));
                    playPausedAction = false;
                    updateState();
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: playPausedAction ? 1 : 0,
                      child: _controller.value.isPlaying
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
            ),
            Container(
              alignment: Alignment.center,
              padding: IsmChatDimens.edgeInsets20_0,
              height: IsmChatDimens.hundred,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (isShowTrimmer) ...[
                    IsmChatDimens.boxHeight10,
                    Builder(
                      builder: (context) {
                        try {
                          final renderBox =
                              context.findRenderObject() as RenderBox;
                          final size = renderBox.size;
                          return SizedBox(
                            height: IsmChatDimens.forty,
                            width: IsmChatDimens.percentWidth(.8),
                            child: ListView(
                              physics: const NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              children: List.generate(
                                thumbnails.length,
                                (index) => Image.file(
                                  thumbnails[index],
                                  width: size.width / thumbnails.length,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        } catch (_) {
                          return IsmChatDimens.box0;
                        }
                      },
                    )
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        startValue.inSecTimer,
                        style: IsmChatStyles.w400White12,
                      ),
                      Expanded(
                        child: RangeSlider(
                          min: 0,
                          max: videoDuration,
                          values: RangeValues(startValue, endValue),
                          onChanged: (values) {
                            startValue = values.start;
                            endValue = values.end;
                            updateState();
                          },
                        ),
                      ),
                      Text(
                        endValue.inSecTimer,
                        style: IsmChatStyles.w400White12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}
