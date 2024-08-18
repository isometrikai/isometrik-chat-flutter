import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class NoiseBuilder extends StatelessWidget {
  const NoiseBuilder({
    super.key,
    required this.widget,
    required this.audioConfigurationDone,
    required AnimationController? animationController,
    required this.noise,
  }) : _animationController = animationController;

  final VoiceMessage widget;
  final bool audioConfigurationDone;
  final AnimationController? _animationController;
  final Widget noise;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: IsmChatResponsive.isMobile(context)
            ? IsmChatDimens.hundred
            : IsmChatDimens.oneHundredTwenty,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            noise,
            if (audioConfigurationDone)
              AnimatedBuilder(
                animation: CurvedAnimation(
                    parent: _animationController!, curve: Curves.ease),
                builder: (context, child) => Positioned(
                  left: _animationController.value,
                  child: Container(
                    height: IsmChatDimens.eighty,
                    width: IsmChatDimens.oneHundredTwenty,
                    color: widget.me
                        ? widget.meBgColor.withOpacity(.4)
                        : widget.contactBgColor.withOpacity(.35),
                  ),
                ),
              ),
          ],
        ),
      );
}
