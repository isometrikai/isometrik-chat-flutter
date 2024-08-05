import 'dart:math' as math;

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class $SingleNoise extends StatelessWidget {
  $SingleNoise({
    super.key,
    required this.color,
  }) : height = 40 * math.Random().nextDouble() + 2;

  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
        margin: EdgeInsets.symmetric(horizontal: IsmChatDimens.one),
        width: IsmChatDimens.two,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IsmChatDimens.fifty),
          color: color,
        ),
      );
}
