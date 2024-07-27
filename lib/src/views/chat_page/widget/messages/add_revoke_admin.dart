import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAddRevokeAdmin extends StatelessWidget {
  const IsmChatAddRevokeAdmin(
    this.message, {
    this.isAdded = true,
    super.key,
  });

  final IsmChatMessageModel message;
  final bool isAdded;

  // String get _user =>
  //     message.memberId == IsmChatConfig.communicationConfig.userConfig.userId
  //         ? 'you'
  //         : message.memberName!;

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
            '${message.initiator} has ${isAdded ? 'made' : 'removed'} ${message.memberName} a admin of this group'
                .trim(), //'${message.initiator} ${isAdded ? 'added' : 'removed'} $_user ${isAdded ? 'as' : 'as an '} Admin'.trim()

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
