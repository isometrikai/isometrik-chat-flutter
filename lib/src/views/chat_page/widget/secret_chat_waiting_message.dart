import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmSecretChatWaitingMessage extends StatelessWidget {
  const IsmSecretChatWaitingMessage({super.key, required this.conversation});

  final IsmChatConversationModel? conversation;

  @override
  Widget build(BuildContext context) => Container(
        color: IsmChatConfig.chatTheme.backgroundColor,
        width: double.maxFinite,
        child: SafeArea(
          child: Padding(
            padding: IsmChatDimens.edgeInsets16,
            child: Container(
              width: double.infinity,
              padding: IsmChatDimens.edgeInsets12,
              decoration: BoxDecoration(
                color: IsmChatColors.primaryColorLight.withOpacity(.1),
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: IsmChatStyles.w500Black12,
                  children: [
                    TextSpan(
                      text: IsmChatStrings.waitingForUserOnline.replaceAll(
                        '%s',
                        conversation?.opponentDetails?.userName.isEmpty ?? true
                            ? IsmChatStrings.opponent
                            : conversation?.opponentDetails?.userName ??
                                IsmChatStrings.opponent,
                      ),
                      style: IsmChatStyles.w600Black12.copyWith(
                        color: IsmChatColors.primaryColorLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
