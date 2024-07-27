import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAddRemoveMember extends StatelessWidget {
  const IsmChatAddRemoveMember(
    this.message, {
    this.isAdded = true,
    this.didLeft = false,
    this.didJoin = false,
    super.key,
  });

  final IsmChatMessageModel message;
  final bool isAdded;
  final bool didLeft;
  final bool didJoin;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          decoration: BoxDecoration(
            color: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageThemData
                    ?.backgroundColor ??
                IsmChatConfig.chatTheme.backgroundColor,
            borderRadius: BorderRadius.circular(IsmChatDimens.eight),
          ),
          padding: IsmChatDimens.edgeInsets8_4,
          child: Text(
            didLeft
                ? '${message.userName} has left'
                : '${message.initiator} ${isAdded ? 'added' : 'removed'} ${message.members?.map((e) => e.memberName).join(', ')}',
            textAlign: TextAlign.center,
            style: IsmChatConfig.chatTheme.chatPageTheme?.centerMessageThemData
                    ?.textStyle ??
                IsmChatStyles.w500Black12.copyWith(
                  color: IsmChatConfig.chatTheme.primaryColor,
                ),
          ),
        ),
      );
}
