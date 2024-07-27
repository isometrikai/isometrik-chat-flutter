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
                  constraints: BoxConstraints(
                    minHeight: IsmChatDimens.twentyEight,
                  ),
                  decoration: BoxDecoration(
                    color: (message.sentByMe
                            ? IsmChatColors.whiteColor
                            : IsmChatColors.greyColor)
                        .withOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: IsmChatDimens.four,
                        height: IsmChatDimens.fifty,
                        child: ColoredBox(
                          color: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.replyMessageThem !=
                                  null
                              ? replyingMyMessage
                                  ? IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.replyMessageThem
                                          ?.selfReplayMessage ??
                                      IsmChatColors.yellowColor
                                  : IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.replyMessageThem
                                          ?.opponentReplayMessage ??
                                      IsmChatColors.blueColor
                              : replyingMyMessage
                                  ? IsmChatColors.yellowColor
                                  : IsmChatColors.blueColor,
                        ),
                      ),
                      Padding(
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
                                  name =
                                      ((controller.conversation?.members ?? [])
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
                                              ?.replyMessageThem !=
                                          null
                                      ? replyingMyMessage
                                          ? IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.replyMessageThem
                                              ?.selfReplayMessage
                                          : IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.replyMessageThem
                                              ?.opponentReplayMessage
                                      : replyingMyMessage
                                          ? IsmChatColors.yellowColor
                                          : IsmChatColors.blueColor,
                                ),
                              );
                            }),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: IsmChatDimens.percentWidth(.5),
                              ),
                              child: Text(
                                IsmChatUtility.decodeString(message.metaData
                                        ?.replyMessage?.parentMessageBody ??
                                    ''),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: message.style,
                              ),
                            ),
                          ],
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
