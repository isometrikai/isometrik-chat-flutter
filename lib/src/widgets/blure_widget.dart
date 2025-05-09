import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class BlurFilter extends StatelessWidget {
  const BlurFilter.widget({
    super.key,
    required this.child,
    this.isBlured = false,
    this.sigmaX = 3,
    this.sigmaY = 3,
  }) : _isWidget = true;

  const BlurFilter({
    super.key,
    required this.child,
    this.isBlured = false,
    this.sigmaX = 10,
    this.sigmaY = 10,
  }) : _isWidget = false;
  final Widget child;
  final bool isBlured;
  final double sigmaX;
  final double sigmaY;
  final bool _isWidget;

  @override
  Widget build(BuildContext context) => !isBlured
      ? child
      : _isWidget
          ? ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
              child: child,
            )
          : Stack(
              alignment: Alignment.center,
              children: [
                child,
                ClipRRect(
                  borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: sigmaX,
                      sigmaY: sigmaY,
                    ),
                    child: Opacity(
                      opacity: 0.01,
                      child: child,
                    ),
                  ),
                ),
                const CircleAvatar(
                  maxRadius: 25,
                  backgroundColor: IsmChatColors.whiteColor,
                  child: Icon(
                    Icons.downloading_outlined,
                    size: 30,
                  ),
                )
              ],
            );
}
