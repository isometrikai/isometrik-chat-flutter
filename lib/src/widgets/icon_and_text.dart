import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';
import 'package:isometrik_chat_flutter/src/utilities/utilities.dart';

class IsmIconAndText extends StatelessWidget {
  const IsmIconAndText({
    super.key,
    required this.icon,
    required this.text,
  });
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: IsmChatConfig.chatTheme.primaryColor,
          ),
          IsmChatDimens.boxHeight16,
          Text(
            text,
            style: IsmChatStyles.w600Black20.copyWith(
              color: IsmChatConfig.chatTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      );
}
