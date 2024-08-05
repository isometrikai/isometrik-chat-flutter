import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:just_audio/just_audio.dart' as jsaudio;

class VoiceMessage extends StatefulWidget {
  const VoiceMessage({
    super.key,
    required this.me,
    required this.noise,
    this.audioSrc,
    this.duration,
    this.noiseCount = 27,
    this.meBgColor = Colors.green,
    this.contactBgColor = const Color(0xffffffff),
    this.contactFgColor = Colors.orange,
    this.contactCircleColor = Colors.red,
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.contactPlayIconBgColor = Colors.grey,
    this.meFgColor = const Color(0xffffffff),
    this.decoration,
  });

  final String? audioSrc;

  final Duration? duration;
  final BoxDecoration? decoration;
  final int noiseCount;
  final Color meBgColor,
      meFgColor,
      contactBgColor,
      contactFgColor,
      contactCircleColor,
      mePlayIconColor,
      contactPlayIconColor,
      contactPlayIconBgColor;
  final bool me;
  final Widget noise;

  @override
  VoiceMessageState createState() => VoiceMessageState();
}

class VoiceMessageState extends State<VoiceMessage>
    with SingleTickerProviderStateMixin {
  late StreamSubscription stream;
  final AudioPlayer _player = AudioPlayer();
  final double maxNoiseHeight = 60, noiseWidth = 120;
  Duration? _audioDuration;

  final RxBool _isPlaying = false.obs;
  bool get isPlaying => _isPlaying.value;
  set isPlaying(bool value) => _isPlaying.value = value;

  final RxString _remainingTime = ''.obs;
  String get remainingTime => _remainingTime.value;
  set remainingTime(String value) => _remainingTime.value = value;

  final RxBool _audioConfigurationDone = false.obs;
  bool get audioConfigurationDone => _audioConfigurationDone.value;
  set audioConfigurationDone(bool value) =>
      _audioConfigurationDone.value = value;

  AnimationController? _animationController;

  @override
  void initState() {
    super.initState();
    _setDuration();
    stream = _player.onPlayerStateChanged.listen((event) {
      switch (event) {
        case PlayerState.stopped:
          break;
        case PlayerState.playing:
          isPlaying = true;
          break;
        case PlayerState.paused:
          isPlaying = false;
          break;
        case PlayerState.completed:
          remainingTime = _audioDuration?.formatDuration() ?? '';
          isPlaying = false;
          break;
        default:
          break;
      }
    });
    _player.onPositionChanged.listen(
      (Duration duration) {
        if (isPlaying) {
          remainingTime = duration.formatDuration();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        width: IsmChatDimens.twoHundred,
        height: IsmChatDimens.seventy,
        decoration: widget.decoration,
        color: widget.decoration == null
            ? widget.me
                ? widget.meBgColor
                : widget.contactBgColor
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmChatTapHandler(
              onTap: () {
                if (audioConfigurationDone) {
                  _changePlayingStatus();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.me
                      ? widget.meFgColor
                      : widget.contactPlayIconBgColor,
                ),
                width: IsmChatResponsive.isMobile(context)
                    ? IsmChatDimens.forty
                    : IsmChatDimens.fifty,
                height: IsmChatResponsive.isMobile(context)
                    ? IsmChatDimens.forty
                    : IsmChatDimens.fifty,
                child: Obx(
                  () => !audioConfigurationDone
                      ? Container(
                          padding: IsmChatDimens.edgeInsets8,
                          width: IsmChatDimens.ten,
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            color: widget.me
                                ? widget.meFgColor
                                : widget.contactFgColor,
                          ),
                        )
                      : Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: widget.me
                              ? widget.mePlayIconColor
                              : widget.contactPlayIconColor,
                        ),
                ),
              ),
            ),
            IsmChatDimens.boxWidth14,
            Obx(
              () => DurationWithNoise(
                widget: widget,
                audioConfigurationDone: audioConfigurationDone,
                animationController: _animationController,
                remainingTime: remainingTime,
                noise: widget.noise,
              ),
            ),
          ],
        ),
      );

  void _startPlaying() async {
    IsmChatLog.info(widget.audioSrc);
    try {
      if (!(widget.audioSrc ?? '').isValidUrl) {
        await _player.play(DeviceFileSource(widget.audioSrc ?? ''));
      } else {
        await _player.play(UrlSource(widget.audioSrc ?? ''));
      }
      await _animationController?.forward();
    } catch (e) {
      isPlaying = false;
      setState(() {});
      IsmChatLog.error('Audio paly error $e');
    }
  }

  _stopPlaying() async {
    await _player.pause();
    _animationController?.stop();
  }

  void _setDuration() async {
    if (widget.duration != null) {
      _audioDuration = widget.duration;
    } else {
      _audioDuration =
          await jsaudio.AudioPlayer().setUrl(widget.audioSrc ?? '');
    }
    _animationController = AnimationController(
      vsync: this,
      lowerBound: 0,
      upperBound: noiseWidth,
      duration: _audioDuration,
    );

    _animationController?.addListener(() {
      if (_animationController!.isCompleted) {
        _animationController?.reset();
        isPlaying = false;
        setState(() {});
      }
    });

    remainingTime = _audioDuration!.formatDuration();
    audioConfigurationDone = true;
  }

  void _changePlayingStatus() async {
    isPlaying ? _stopPlaying() : _startPlaying();
    isPlaying = !isPlaying;
  }

  @override
  void dispose() {
    stream.cancel();
    _player.dispose();
    _animationController?.dispose();
    super.dispose();
  }
}
