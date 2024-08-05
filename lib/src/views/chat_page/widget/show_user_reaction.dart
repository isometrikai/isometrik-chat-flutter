import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ImsChatShowUserReaction extends StatefulWidget {
  ImsChatShowUserReaction(
      {super.key,
      required this.reactionType,
      required this.message,
      required this.index})
      : _controller = Get.find<IsmChatPageController>();

  final IsmChatMessageModel message;
  final String reactionType;
  final int index;
  final IsmChatPageController _controller;

  @override
  State<ImsChatShowUserReaction> createState() =>
      _ImsChatShowUserReactionState();
}

class _ImsChatShowUserReactionState extends State<ImsChatShowUserReaction>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late IsmChatEmoji ismChatEmoji;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: (widget.message.reactions?.length ?? 0) + 1, vsync: this);

    _tabController.animateTo(widget.index + 1);

    ismChatEmoji =
        getIsmChatEmoji(reaction: widget.message.reactions![widget.index]);
  }

  IsmChatEmoji getIsmChatEmoji({required MessageReactionModel reaction}) {
    var reactionName = reaction.emojiKey;
    var reactionValue =
        IsmChatEmoji.values.firstWhere((e) => e.value == reactionName);

    return reactionValue;
  }

  List<MessageReactionModel> getAllReaction(
      List<MessageReactionModel> reactions) {
    var allReactions = <MessageReactionModel>[];
    for (var x in reactions) {
      for (var y in x.userIds) {
        allReactions
            .add(MessageReactionModel(emojiKey: x.emojiKey, userIds: [y]));
      }
    }
    return allReactions;
  }

  @override
  Widget build(BuildContext context) {
    var reactionLength = widget.message.reactions?.length ?? 0;
    var allReactions = getAllReaction(widget.message.reactions!);

    return Container(
      color: IsmChatColors.whiteColor,
      height: IsmChatDimens.percentHeight(.38),
      child: ListView(
        shrinkWrap: true,
        children: [
          Container(
            alignment: Alignment.topLeft,
            height: IsmChatDimens.sixty,
            child: TabBar(
                padding: IsmChatDimens.edgeInsets10_05,
                tabAlignment: reactionLength > 3 ? TabAlignment.start : null,
                controller: _tabController,
                isScrollable: reactionLength > 3 ? true : false,
                tabs: [
                  Text(
                    '${IsmChatStrings.all} ${allReactions.length} ',
                    style: IsmChatStyles.w400Black18,
                  ),
                  ...List.generate(reactionLength, (index) {
                    var reactionValue = getIsmChatEmoji(
                        reaction: widget.message.reactions![index]);
                    var reaction = widget._controller.reactions.firstWhere(
                        (e) => e.name == reactionValue.emojiKeyword);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AbsorbPointer(
                          absorbing: true,
                          child: EmojiCell.fromConfig(
                            emojiBoxSize: IsmChatDimens.forty,
                            emoji: reaction,
                            emojiSize: IsmChatDimens.thirty,
                            onEmojiSelected: (_, emoji) {},
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
                        ),
                        IsmChatDimens.boxWidth8,
                        Text(
                          '${widget.message.reactions?[index].userIds.length}',
                          style: IsmChatStyles.w400Black16,
                        )
                      ],
                    );
                  }),
                ]),
          ),
          SizedBox(
            height: IsmChatDimens.percentHeight(.3),
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView.builder(
                  itemCount: allReactions.length,
                  itemBuilder: (context, index) {
                    UserDetails? reactionUser;
                    var showOwnUser = false;
                    var userId = allReactions[index].userIds.first;
                    if (userId ==
                        IsmChatConfig.communicationConfig.userConfig.userId) {
                      showOwnUser = true;
                    }

                    if (widget._controller.conversation!.isGroup!) {
                      reactionUser = widget._controller.conversation?.members
                          ?.firstWhere((e) => e.userId == userId);
                    }

                    var reactionValue =
                        getIsmChatEmoji(reaction: allReactions[index]);
                    var reaction = widget._controller.reactions.firstWhere(
                        (e) => e.name == reactionValue.emojiKeyword);
                    return IsmChatTapHandler(
                      onTap: () async {
                        Get.back();
                        if (showOwnUser) {
                          ismChatEmoji =
                              getIsmChatEmoji(reaction: allReactions[index]);
                          await widget._controller.deleteReacton(
                              reaction: Reaction(
                                  reactionType: ismChatEmoji,
                                  messageId: widget.message.messageId ?? '',
                                  conversationId:
                                      widget.message.conversationId ?? ''));
                        }
                      },
                      child: ListTile(
                        title: Text(showOwnUser
                            ? IsmChatStrings.you
                            : widget._controller.conversation!.isGroup!
                                ? reactionUser?.userName ?? ''
                                : widget._controller.conversation?.chatName ??
                                    ''),
                        trailing: SizedBox(
                          height: IsmChatDimens.thirtyTwo,
                          width: IsmChatDimens.thirtyTwo,
                          child: EmojiCell.fromConfig(
                            emojiBoxSize: 20,
                            emoji: reaction,
                            emojiSize: IsmChatDimens.twenty,
                            onEmojiSelected: (_, emoji) {},
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
                        ),
                        subtitle: showOwnUser
                            ? const Text(IsmChatStrings.removeReaction)
                            : widget._controller.conversation!.isGroup!
                                ? Text(reactionUser?.userIdentifier ?? '')
                                : Text(widget._controller.conversation
                                        ?.opponentDetails?.userIdentifier ??
                                    ''),
                        leading: IsmChatImage.profile(showOwnUser
                            ? IsmChatConfig.communicationConfig.userConfig
                                        .userProfile?.isNotEmpty ==
                                    true
                                ? IsmChatConfig
                                    .communicationConfig.userConfig.userProfile!
                                : Get.find<IsmChatConversationsController>()
                                        .userDetails
                                        ?.userProfileImageUrl ??
                                    ''
                            : widget._controller.conversation!.isGroup!
                                ? reactionUser?.profileUrl ?? ''
                                : widget._controller.conversation?.profileUrl ??
                                    ''),
                      ),
                    );
                  },
                ),
                ...List.generate(
                  reactionLength,
                  (index) => ListView(
                    children: List.generate(
                      widget.message.reactions?[index].userIds.length ?? 0,
                      (indexUserId) {
                        UserDetails? reactionUser;
                        var userId = widget
                            .message.reactions?[index].userIds[indexUserId];
                        if (widget._controller.conversation!.isGroup!) {
                          reactionUser = widget
                              ._controller.conversation?.members
                              ?.firstWhere((e) => e.userId == userId);
                        }

                        var showOwnUser = false;
                        if (userId ==
                            IsmChatConfig
                                .communicationConfig.userConfig.userId) {
                          showOwnUser = true;
                        }

                        return IsmChatTapHandler(
                          onTap: () async {
                            Get.back();
                            if (showOwnUser) {
                              await widget._controller.deleteReacton(
                                  reaction: Reaction(
                                      reactionType: ismChatEmoji,
                                      messageId: widget.message.messageId ?? '',
                                      conversationId:
                                          widget.message.conversationId ?? ''));
                            }
                          },
                          child: ListTile(
                            title: Text(showOwnUser
                                ? IsmChatStrings.you
                                : widget._controller.conversation!.isGroup!
                                    ? reactionUser?.userName ?? ''
                                    : widget._controller.conversation
                                            ?.chatName ??
                                        ''),
                            subtitle: showOwnUser
                                ? const Text(IsmChatStrings.removeReaction)
                                : widget._controller.conversation!.isGroup!
                                    ? Text(reactionUser?.userIdentifier ?? '')
                                    : Text(widget._controller.conversation
                                            ?.opponentDetails?.userIdentifier ??
                                        ''),
                            leading: IsmChatImage.profile(showOwnUser
                                ? IsmChatConfig.communicationConfig.userConfig
                                            .userProfile?.isNotEmpty ==
                                        true
                                    ? IsmChatConfig.communicationConfig
                                        .userConfig.userProfile!
                                    : Get.find<IsmChatConversationsController>()
                                            .userDetails
                                            ?.userProfileImageUrl ??
                                        ''
                                : widget._controller.conversation!.isGroup!
                                    ? reactionUser?.profileUrl ?? ''
                                    : widget._controller.conversation
                                            ?.profileUrl ??
                                        ''),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
