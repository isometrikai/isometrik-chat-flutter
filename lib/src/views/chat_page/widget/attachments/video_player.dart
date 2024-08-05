import 'dart:io';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_flutter_chat/src/utilities/blob_html.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VideoViewPage extends StatefulWidget {
  const VideoViewPage(
      {super.key, required this.path, this.showVideoPlaying = false});
  final String path;
  final bool showVideoPlaying;

  @override
  VideoViewPageState createState() => VideoViewPageState();
}

class VideoViewPageState extends State<VideoViewPage> with RouteAware {
  late VideoPlayerController _controller;

  final chatPageController = Get.find<IsmChatPageController>();

  String _videoDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes % 60);
    final seconds = twoDigits(duration.inSeconds % 60);

    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  @override
  void initState() {
    super.initState();
    chatPageController.isVideoVisible = true;
    _controller = kIsWeb
        ? VideoPlayerController.networkUrl(
            Uri.parse(
              widget.path.isValidUrl
                  ? widget.path
                  : IsmChatBlob.blobToUrl(widget.path.strigToUnit8List),
            ),
          )
        : widget.path.isValidUrl
            ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
            : VideoPlayerController.file(
                File(widget.path),
              )
      ..setLooping(false)
      ..initialize().then((_) {
        _controller.addListener(() {
          if (_controller.value.isBuffering == true) {
            updateState();
          } else {
            updateState();
          }
        });

        _controller.pause();
      });
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(VideoViewPage oldWidget) {
    if (widget.path != oldWidget.path) {
      IsmChatUtility.doLater(() {
        chatPageController.isVideoVisible = true;
        _controller.pause();
        _controller = kIsWeb
            ? VideoPlayerController.networkUrl(
                Uri.parse(widget.path.isValidUrl
                    ? widget.path
                    : IsmChatBlob.blobToUrl(widget.path.strigToUnit8List)),
              )
            : widget.path.isValidUrl
                ? VideoPlayerController.networkUrl(Uri.parse(widget.path))
                : VideoPlayerController.file(File(widget.path))
          ..initialize().then((_) {
            _controller.addListener(() {
              if (_controller.value.isBuffering == true) {
                updateState();
              } else {
                updateState();
              }
            });

            _controller.pause();
          });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.removeListener(() {
      _controller.pause();
    });
    _controller.dispose();
    chatPageController.isVideoVisible = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.transparent,
        body: VisibilityDetector(
          key: const Key('Video_Player'),
          onVisibilityChanged: (VisibilityInfo info) {
            if (chatPageController.isVideoVisible) {
              if (info.visibleFraction == 0) {
                _controller.pause();
              } else {
                _controller.play();
              }
              updateState();
            }
          },
          child: Stack(
            fit: kIsWeb ? StackFit.loose : StackFit.expand,
            children: [
              _controller.value.isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        // Use the VideoPlayer widget to display the video.
                        child: Stack(children: [
                          VideoPlayer(_controller),
                          if (!widget.showVideoPlaying && kIsWeb)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                padding: IsmChatDimens.edgeInsets20,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    ValueListenableBuilder(
                                      valueListenable: _controller,
                                      builder: (context, VideoPlayerValue value,
                                              child) =>
                                          Text(
                                        _videoDuration(
                                          value.position,
                                        ),
                                        style: IsmChatStyles.w600White14,
                                      ),
                                    ),
                                    Expanded(
                                      child: SizedBox(
                                        height: IsmChatDimens.five,
                                        child: VideoProgressIndicator(
                                            _controller,
                                            allowScrubbing: true,
                                            colors: const VideoProgressColors(
                                                backgroundColor:
                                                    IsmChatColors.whiteColor,
                                                playedColor:
                                                    IsmChatColors.greenColor),
                                            padding: IsmChatDimens
                                                .edgeInsetsHorizontal10),
                                      ),
                                    ),
                                    if (!kIsWeb)
                                      Text(
                                        _videoDuration(
                                            _controller.value.duration),
                                        style: IsmChatStyles.w600White14,
                                      )
                                  ],
                                ),
                              ),
                            )
                        ]),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(
                        color: IsmChatColors.whiteColor,
                      ),
                    ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                    updateState();
                  },
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.black38,
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
              if (!kIsWeb)
                if (!widget.showVideoPlaying)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: IsmChatDimens.edgeInsets20,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _controller,
                              builder:
                                  (context, VideoPlayerValue value, child) =>
                                      Text(
                                        _videoDuration(
                                          value.position,
                                        ),
                                        style: IsmChatStyles.w600White14,
                                      )),
                          SizedBox(
                            height: IsmChatDimens.five,
                            width: IsmChatDimens.percentWidth(.6),
                            child: VideoProgressIndicator(_controller,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                    backgroundColor: IsmChatColors.whiteColor,
                                    playedColor: IsmChatColors.greenColor),
                                padding: IsmChatDimens.edgeInsetsHorizontal10),
                          ),
                          Text(
                            _videoDuration(_controller.value.duration),
                            style: IsmChatStyles.w600White14,
                          )
                        ],
                      ),
                    ),
                  )
            ],
          ),
        ),
      );
}
