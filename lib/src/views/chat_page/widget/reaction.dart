import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ImsChatReaction extends StatefulWidget {
  ImsChatReaction({super.key, required this.message})
      : _controller = Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  final IsmChatMessageModel message;
  final IsmChatPageController _controller;

  @override
  State<ImsChatReaction> createState() => _ImsChatReactionState();
}

class _ImsChatReactionState extends State<ImsChatReaction> {
  int reactionLength = 0;
  bool showCount = false;
  @override
  void initState() {
    _checkReactionCount();
    super.initState();
  }

  _checkReactionCount() {
    widget.message.reactions
        ?.removeWhere((e) => e.emojiKey.isNotEmpty && e.userIds.isEmpty);
    reactionLength = widget.message.reactions?.length ?? 0;
    if (reactionLength > 3) {
      showCount = true;
      reactionLength = reactionLength - 2;
    } else {
      showCount = false;
    }
  }

  @override
  void didUpdateWidget(covariant ImsChatReaction oldWidget) {
    _checkReactionCount();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(
              showCount ? 3 : widget.message.reactions?.length ?? 0, (index) {
            var reactionName = widget.message.reactions?[index].emojiKey;
            var reactionValue =
                IsmChatEmoji.values.firstWhere((e) => e.value == reactionName);
            var reaction = widget._controller.reactions
                .firstWhere((e) => e.name == reactionValue.emojiKeyword);
            return InkWell(
              onTap: () {
                widget._controller.showReactionUser(
                    message: widget.message,
                    reactionType: reactionName ?? '',
                    index: 0);
              },
              // behavior: HitTestBehavior.opaque,
              child: Container(
                alignment: Alignment.center,
                margin: IsmChatDimens.edgeInsetsR4,
                width: IsmChatDimens.forty,
                height: IsmChatDimens.twentyFive,
                padding:
                    showCount && index == 2 ? IsmChatDimens.edgeInsets4 : null,
                decoration: BoxDecoration(
                    boxShadow: const [BoxShadow(color: Colors.black)],
                    borderRadius: BorderRadius.all(
                      Radius.circular(IsmChatDimens.fifty),
                    ),
                    color: IsmChatColors.whiteColor),
                child: showCount && index == 2
                    ? Text('+ $reactionLength')
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          EmojiCell.fromConfig(
                            emojiBoxSize: IsmChatDimens.eighteen,
                            emoji: reaction,
                            emojiSize: IsmChatDimens.fifteen,
                            onEmojiSelected: (_, emoji) {
                              widget._controller.showReactionUser(
                                  index: index,
                                  message: widget.message,
                                  reactionType: reactionName ?? '');
                            },
                            config: Config(
                              categoryViewConfig: CategoryViewConfig(
                                  indicatorColor:
                                      IsmChatConfig.chatTheme.primaryColor!),
                              emojiViewConfig: EmojiViewConfig(
                                emojiSizeMax: IsmChatDimens.twentyFour,
                                backgroundColor:
                                    IsmChatConfig.chatTheme.backgroundColor!,
                              ),
                            ),
                          ),
                          Text(
                              '${widget.message.reactions?[index].userIds.length}')
                        ],
                      ),
              ),
            );
          }),
        ),
      );
}
