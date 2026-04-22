import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
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
    this.opponentBgColor = Colors.white,
    this.contactFgColor = Colors.grey,
    this.contactCircleColor = Colors.red,
    this.mePlayIconColor = Colors.black,
    this.contactPlayIconColor = Colors.black26,
    this.contactPlayIconBgColor = Colors.grey,
    this.meFgColor = Colors.white,
    this.meProgressOverlayColor,
    this.opponentProgressOverlayColor,
    this.playIcon,
    this.pauseIcon,
    this.loadingIcon,
  });

  final String? audioSrc;

  final Duration? duration;

  final int noiseCount;
  final Color meBgColor,
      meFgColor,
      opponentBgColor,
      contactFgColor,
      contactCircleColor,
      mePlayIconColor,
      contactPlayIconColor,
      contactPlayIconBgColor;
  final bool me;
  final Widget noise;

  /// Optional override for the moving progress overlay color.
  ///
  /// If null, overlay color is derived from bg colors with opacity.
  final Color? meProgressOverlayColor;
  final Color? opponentProgressOverlayColor;

  /// Optional icon widgets for the default circular play/pause button.
  ///
  /// If null, SDK uses default Material icons/spinner.
  final Widget? playIcon;
  final Widget? pauseIcon;
  final Widget? loadingIcon;

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
          remainingTime = _audioDuration?.formatDuration ?? '';
          isPlaying = false;
          break;
        default:
          break;
      }
    });
    _player.onPositionChanged.listen(
      (Duration duration) {
        if (isPlaying) {
          remainingTime = duration.formatDuration;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        width: IsmChatDimens.twoHundred,
        height: IsmChatDimens.seventy,
        decoration: BoxDecoration(
          color: widget.me ? widget.meBgColor : widget.opponentBgColor,
          borderRadius: widget.me
              ? IsmChatConfig.chatTheme.chatPageTheme?.selfMessageTheme
                      ?.borderRadius ??
                  BorderRadius.circular(IsmChatDimens.twelve).copyWith(
                    bottomRight: Radius.circular(IsmChatDimens.four),
                  )
              : IsmChatConfig.chatTheme.chatPageTheme?.opponentMessageTheme
                      ?.borderRadius ??
                  BorderRadius.circular(IsmChatDimens.twelve).copyWith(
                    topLeft: Radius.circular(IsmChatDimens.four),
                  ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmChatTapHandler(
              onTap: () {
                if (audioConfigurationDone) {
                  _changePlayingStatus();
                }
              },
              child: Obx(() {
                final buttonSize = IsmChatResponsive.isMobile(context)
                    ? IsmChatDimens.forty
                    : IsmChatDimens.fifty;
                final hasCustomIcons = widget.playIcon != null ||
                    widget.pauseIcon != null ||
                    widget.loadingIcon != null;

                if (!audioConfigurationDone) {
                  final loading = widget.loadingIcon ??
                      Container(
                        padding: IsmChatDimens.edgeInsets8,
                        width: IsmChatDimens.ten,
                        child: CircularProgressIndicator(
                          strokeWidth: 1,
                          color: widget.me
                              ? widget.meFgColor
                              : widget.contactFgColor,
                        ),
                      );

                  if (hasCustomIcons) {
                    return SizedBox(
                      width: buttonSize,
                      height: buttonSize,
                      child: Center(child: loading),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.me
                          ? widget.meFgColor
                          : widget.contactPlayIconBgColor,
                    ),
                    width: buttonSize,
                    height: buttonSize,
                    child: Center(child: loading),
                  );
                }

                final iconColor = widget.me
                    ? widget.mePlayIconColor
                    : widget.contactPlayIconColor;
                final iconWidget = isPlaying
                    ? (widget.pauseIcon ??
                        Icon(
                          Icons.pause,
                          color: iconColor,
                        ))
                    : (widget.playIcon ??
                        Icon(
                          Icons.play_arrow,
                          color: iconColor,
                        ));

                if (hasCustomIcons) {
                  return SizedBox(
                    width: buttonSize,
                    height: buttonSize,
                    child: Center(child: iconWidget),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.me
                        ? widget.meFgColor
                        : widget.contactPlayIconBgColor,
                  ),
                  width: buttonSize,
                  height: buttonSize,
                  child: Center(child: iconWidget),
                );
              }),
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

  void _stopPlaying() async {
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

    remainingTime = _audioDuration!.formatDuration;
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
