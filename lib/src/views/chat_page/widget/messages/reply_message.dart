import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatReplyMessage extends StatelessWidget {
  const IsmChatReplyMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReplyMessage(message),
            IsmChatDimens.boxHeight5,
            ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: IsmChatDimens.twentyFour,
                ),
                child: IsmChatMessageWrapperWithMetaData(message)),
          ],
        ),
      );
}

class _ReplyMessage extends StatelessWidget {
  const _ReplyMessage(this.message);

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (controller) {
          var replyingMyMessage = message.sentByMe ==
              (message.metaData?.replyMessage?.parentMessageInitiator ?? false);
          return Material(
            color: Colors.transparent,
            child: IsmChatTapHandler(
              onTap: () {
                controller.scrollToMessage(message.parentMessageId ?? '');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                child: Container(
                  constraints: IsmChatConfig.chatTheme.chatPageTheme
                          ?.messageConstraints?.textConstraints ??
                      BoxConstraints(
                        maxWidth: (IsmChatResponsive.isWeb(context))
                            ? context.width * .25
                            : context.width * .7,
                        minWidth: IsmChatResponsive.isWeb(context)
                            ? context.width * .05
                            : context.width * .2,
                        minHeight: (IsmChatResponsive.isWeb(context))
                            ? context.height * .04
                            : context.height * .05,
                        // maxHeight: (IsmChatResponsive.isWeb(context))
                        //     ? context.height * .3
                        //     : context.height * .7,
                      ),
                  decoration: BoxDecoration(
                    color: (message.sentByMe
                            ? IsmChatColors.whiteColor
                            : IsmChatColors.greyColor)
                        .applyIsmOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: IsmChatDimens.four,
                        height: IsmChatDimens.fifty,
                        child: ColoredBox(
                          color: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.replyMessageTheme !=
                                  null
                              ? replyingMyMessage
                                  ? IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.replyMessageTheme
                                          ?.selfReplayMessage ??
                                      IsmChatColors.yellowColor
                                  : IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.replyMessageTheme
                                          ?.opponentReplayMessage ??
                                      IsmChatColors.blueColor
                              : replyingMyMessage
                                  ? IsmChatColors.yellowColor
                                  : IsmChatColors.blueColor,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: IsmChatDimens.edgeInsets4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Builder(builder: (context) {
                                var name = '';

                                if (controller.conversation?.isGroup ?? false) {
                                  if (replyingMyMessage) {
                                    name = IsmChatStrings.you;
                                  } else {
                                    name = ((controller.conversation?.members ??
                                                        [])
                                                    .firstWhereOrNull(
                                                      (e) =>
                                                          message
                                                              .metaData
                                                              ?.replyMessage
                                                              ?.parentMessageUserId ==
                                                          e.userId,
                                                    )
                                                    ?.userName ??
                                                controller
                                                    .conversation?.chatName ??
                                                '')
                                            .capitalizeFirst ??
                                        '';
                                  }
                                } else {
                                  name = replyingMyMessage
                                      ? IsmChatStrings.you
                                      : controller.conversation?.replyName
                                              .capitalizeFirst ??
                                          '';
                                }

                                return Text(
                                  name,
                                  style: IsmChatStyles.w500Black14.copyWith(
                                    color: IsmChatConfig.chatTheme.chatPageTheme
                                                ?.replyMessageTheme !=
                                            null
                                        ? replyingMyMessage
                                            ? IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.replyMessageTheme
                                                ?.selfReplayMessage
                                            : IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.replyMessageTheme
                                                ?.opponentReplayMessage
                                        : replyingMyMessage
                                            ? IsmChatColors.yellowColor
                                            : IsmChatColors.blueColor,
                                  ),
                                );
                              }),
                              Text(
                                IsmChatUtility.decodeString(message.metaData
                                        ?.replyMessage?.parentMessageBody ??
                                    ''),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: message.style,
                              ),
                            ],
                          ),
                        ),
                      ),
                      IsmChatDimens.boxWidth8,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}
