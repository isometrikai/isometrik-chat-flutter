import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmSecretChatInviteCard extends StatelessWidget {
  const IsmSecretChatInviteCard({super.key, required this.opponentName});

  final String opponentName;

  @override
  Widget build(BuildContext context) => Container(
        width: IsmChatResponsive.isWeb(context)
            ? IsmChatDimens.percentWidth(.5)
            : IsmChatDimens.percentWidth(.9),
        padding: IsmChatDimens.edgeInsets16,
        decoration: BoxDecoration(
          color: IsmChatColors.whiteColor,
          borderRadius: BorderRadius.circular(IsmChatDimens.twelve),
          boxShadow: [
            BoxShadow(
              color: IsmChatColors.blackColor.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: IsmChatDimens.fifty,
              height: IsmChatDimens.fifty,
              decoration: BoxDecoration(
                color: IsmChatConfig.chatTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: IsmChatColors.whiteColor,
              ),
            ),
            IsmChatDimens.boxHeight16,
            Text(
              IsmChatStrings.secretChatInviteTitle
                  .replaceAll('%s', opponentName),
              textAlign: TextAlign.center,
              style: IsmChatStyles.w600Black16,
            ),
            IsmChatDimens.boxHeight8,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                IsmChatStrings.secretChatsTitle,
                style: IsmChatStyles.w600Black14,
              ),
            ),
            IsmChatDimens.boxHeight8,
            ...[
              IsmChatStrings.secretChatFeature1,
              IsmChatStrings.secretChatFeature2,
              IsmChatStrings.secretChatFeature3,
              IsmChatStrings.secretChatFeature4,
              IsmChatStrings.secretChatFeature5,
              IsmChatStrings.secretChatFeature6,
            ]
                .expand(
                  (e) => [
                    Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            size: 18, color: IsmChatColors.greyColor),
                        IsmChatDimens.boxWidth8,
                        Expanded(
                          child: Text(
                            e,
                            style: IsmChatStyles.w400Grey12,
                          ),
                        ),
                      ],
                    ),
                    IsmChatDimens.boxHeight8,
                  ],
                )
                .toList()
              ..removeLast(),
          ],
        ),
      );
}
