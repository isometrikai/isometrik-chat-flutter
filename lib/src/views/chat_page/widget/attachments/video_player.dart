import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
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

  final chatPageController = IsmChatUtility.chatPageController;

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
        _controller
          ..addListener(() {
            if (_controller.value.isBuffering == true) {
              updateState();
            } else {
              updateState();
            }
          })
          ..pause();
      });
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  Size _orientedVideoSize(VideoPlayerValue value) {
    final raw = value.size;
    if (raw.width == 0 || raw.height == 0) {
      return const Size(1, 1);
    }
    final isRotated = (value.rotationCorrection ~/ 90).isOdd;
    if (isRotated) {
      return Size(raw.height, raw.width);
    }
    return raw;
  }

  Widget _buildVideoContent() {
    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: IsmChatColors.whiteColor,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = _orientedVideoSize(_controller.value);
        final aspectRatio = size.width / size.height;
        final maxW = constraints.maxWidth;
        final maxH = constraints.maxHeight;

        // Width-first: fill screen width without cropping when possible.
        var width = maxW;
        var height = width / aspectRatio;
        if (height > maxH) {
          height = maxH;
          width = height * aspectRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: VideoPlayer(_controller),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    const progressColors = VideoProgressColors(
      backgroundColor: Color(0x66FFFFFF),
      playedColor: IsmChatColors.greenColor,
      bufferedColor: Color(0x99FFFFFF),
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black54],
          ),
        ),
        child: SafeArea(
          top: false,
          minimum: EdgeInsets.only(bottom: IsmChatDimens.eight),
          child: SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                IsmChatDimens.sixteen,
                IsmChatDimens.sixteen,
                IsmChatDimens.sixteen,
                IsmChatDimens.ten,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) => Text(
                      value.position.formatDuration,
                      style: IsmChatStyles.w600White14,
                    ),
                  ),
                  SizedBox(
                    height: IsmChatDimens.five,
                    width: IsmChatDimens.percentWidth(.6),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: progressColors,
                      padding: IsmChatDimens.edgeInsetsHorizontal10,
                    ),
                  ),
                  ValueListenableBuilder<VideoPlayerValue>(
                    valueListenable: _controller,
                    builder: (context, value, child) => Text(
                      value.duration.formatDuration,
                      style: IsmChatStyles.w600White14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
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
            _controller
              ..addListener(() {
                if (_controller.value.isBuffering == true) {
                  updateState();
                } else {
                  updateState();
                }
              })
              ..pause();
          });
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(() {
        _controller.pause();
      })
      ..dispose();
    chatPageController.isVideoVisible = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: VisibilityDetector(
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
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: _buildVideoContent()),
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    onTap: () {
                      if (_controller.value.isInitialized &&
                          !_controller.value.position.isNegative &&
                          _controller.value.duration > Duration.zero) {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                        updateState();
                      }
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
                if (!widget.showVideoPlaying) _buildControls(),
              ],
            ),
          ),
        ),
      );
}
