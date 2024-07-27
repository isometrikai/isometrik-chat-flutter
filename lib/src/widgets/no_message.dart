import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatEmptyView extends StatelessWidget {
  const IsmChatEmptyView({
    super.key,
    required this.text,
    this.icon,
  });

  final Widget? icon;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
            padding: IsmChatDimens.edgeInsets16,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  IsmChatDimens.boxHeight16,
                ],
                Text(
                  text,
                  style: IsmChatStyles.w600Black20.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )

            // const IsmIconAndText(
            //   icon: Icons.chat_outlined,
            //   text: IsmChatStrings.noMessages,
            // ),
            ),
      );
}
