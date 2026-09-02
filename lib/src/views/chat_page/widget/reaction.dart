import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ImsChatReaction extends StatefulWidget {
  ImsChatReaction({super.key, required this.message})
      : _controller = IsmChatUtility.chatPageController;

  final IsmChatMessageModel message;
  final IsmChatPageController _controller;

  /// Visible reaction chip row width (for stack layout / hit bounds).
  static double layoutWidth(IsmChatMessageModel message) {
    final reactions = message.reactions
        ?.where((e) => e.emojiKey.isNotEmpty && e.userIds.isNotEmpty)
        .toList();
    if (reactions == null || reactions.isEmpty) {
      return 0;
    }
    final visibleCount = reactions.length > 3 ? 3 : reactions.length;
    return visibleCount *
        (IsmChatDimens.forty + IsmChatDimens.edgeInsetsR4.right);
  }

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

  void _checkReactionCount() {
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
  Widget build(BuildContext context) {
    final reactionTheme = IsmChatThemeResolver.reactionFromConfig(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(
          showCount ? 3 : widget.message.reactions?.length ?? 0, (index) {
        var reactionName = widget.message.reactions?[index].emojiKey;
        var reactionValue =
            IsmChatEmoji.values.firstWhere((e) => e.value == reactionName);
        var reaction = widget._controller.reactions
            .firstWhere((e) => e.name == reactionValue.emojiKeyword);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            widget._controller.showReactionUser(
                message: widget.message,
                reactionType: reactionName ?? '',
                index: index);
          },
          child: Container(
            alignment: Alignment.center,
            margin: IsmChatDimens.edgeInsetsR4,
            width: IsmChatDimens.forty,
            height: IsmChatDimens.twentyFive,
            padding: showCount && index == 2 ? IsmChatDimens.edgeInsets4 : null,
            decoration: BoxDecoration(
                boxShadow: reactionTheme.boxShadow,
                borderRadius: BorderRadius.all(
                  Radius.circular(IsmChatDimens.fifty),
                ),
                color: reactionTheme.backgroundColor),
            child: showCount && index == 2
                ? Text(
                    '+ $reactionLength',
                    textAlign: TextAlign.center,
                    style: reactionTheme.countTextStyle,
                  )
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
                                reactionTheme.emojiBackgroundColor ??
                                    IsmChatConfig.chatTheme.backgroundColor!,
                          ),
                        ),
                      ),
                      Text(
                        '${widget.message.reactions?[index].userIds.length}',
                        textAlign: TextAlign.center,
                        style: reactionTheme.countTextStyle,
                      )
                    ],
                  ),
          ),
        );
      }),
    );
  }
}
