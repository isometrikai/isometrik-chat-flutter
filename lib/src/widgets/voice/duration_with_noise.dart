import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class DurationWithNoise extends StatelessWidget {
  const DurationWithNoise({
    super.key,
    required this.widget,
    required this.audioConfigurationDone,
    required AnimationController? animationController,
    required this.remainingTime,
    required this.noise,
  }) : _animationController = animationController;

  final VoiceMessage widget;
  final bool audioConfigurationDone;
  final AnimationController? _animationController;
  final String remainingTime;
  final Widget noise;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          NoiseBuilder(
            widget: widget,
            audioConfigurationDone: audioConfigurationDone,
            animationController: _animationController,
            noise: noise,
          ),
          Text(
            remainingTime,
            style: TextStyle(
              fontSize: IsmChatDimens.ten,
              color: widget.me ? widget.meFgColor : widget.contactFgColor,
            ),
          ),
        ],
      );
}
