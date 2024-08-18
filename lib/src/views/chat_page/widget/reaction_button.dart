import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ReactionGrid extends StatelessWidget {
  ReactionGrid(this.message, {super.key})
      : _controller = Get.find<IsmChatPageController>();

  final IsmChatMessageModel message;
  final IsmChatPageController _controller;

  @override
  Widget build(BuildContext context) => Material(
        elevation: IsmChatDimens.four,
        borderRadius: BorderRadius.circular(IsmChatDimens.sixteen),
        child: Container(
          alignment: Alignment.center,
          height: IsmChatResponsive.isWeb(context)
              ? IsmChatDimens.seventy
              : IsmChatDimens.hundred + IsmChatDimens.eight,
          width: IsmChatResponsive.isWeb(context)
              ? IsmChatDimens.twoHundredFifty
              : null,
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
            ),
            padding: IsmChatDimens.edgeInsets8_4,
            itemCount: _controller.reactions.length,
            itemBuilder: (_, index) {
              var reaciton = _controller.reactions[index];
              return EmojiCell.fromConfig(
                emojiBoxSize: 20,
                emoji: reaciton,
                emojiSize: IsmChatDimens.twenty,
                onEmojiSelected: (_, emoji) {
                  Get.back();
                  _controller.closeOverlay();
                  _controller.addReacton(
                    reaction: Reaction(
                      reactionType: IsmChatEmoji.fromEmoji(reaciton),
                      messageId: message.messageId ?? '',
                      conversationId: _controller.conversation!.conversationId!,
                    ),
                  );
                },
                config: Config(
                  categoryViewConfig: CategoryViewConfig(
                      indicatorColor: IsmChatConfig.chatTheme.primaryColor!),
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: IsmChatDimens.twentyFour,
                    backgroundColor: IsmChatConfig.chatTheme.backgroundColor!,
                  ),
                ),
              );
            },
          ),
        ),
      );
}
