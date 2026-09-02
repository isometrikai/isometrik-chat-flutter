import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ImsChatShowUserReaction extends StatefulWidget {
  ImsChatShowUserReaction(
      {super.key,
      required this.reactionType,
      required this.message,
      required this.index})
      : _controller = IsmChatUtility.chatPageController;

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

  UserDetails _currentUserDetails() {
    final userConfig = IsmChatConfig.communicationConfig.userConfig;
    return IsmChatUtility.conversationController.userDetails ??
        UserDetails(
          userId: userConfig.userId,
          userName: userConfig.userName ?? '',
          userProfileImageUrl: userConfig.userProfile ?? '',
          userIdentifier: userConfig.userId,
        );
  }

  UserDetails? _findMemberById(String userId) {
    final members = widget._controller.conversation?.members;
    if (members == null) {
      return null;
    }
    for (final member in members) {
      if (member.userId == userId) {
        return member;
      }
    }
    return null;
  }

  UserDetails _resolveReactionUser(String userId) {
    if (userId == IsmChatConfig.communicationConfig.userConfig.userId) {
      return _currentUserDetails();
    }
    if (widget._controller.conversation?.isGroup ?? false) {
      return _findMemberById(userId) ??
          UserDetails(
            userId: userId,
            userName: '',
            userProfileImageUrl: '',
            userIdentifier: '',
          );
    }
    return widget._controller.conversation?.opponentDetails ??
        UserDetails(
          userId: userId,
          userName: widget._controller.conversation?.chatName ?? '',
          userProfileImageUrl:
              widget._controller.conversation?.profileUrl ?? '',
          userIdentifier: '',
        );
  }

  Widget _buildProfileLeading(BuildContext context, UserDetails user) {
    final acknowledge =
        IsmChatProperties.chatPageProperties.messageInfoAcknowldge;
    return acknowledge?.profileImageBuilder?.call(context, user) ??
        IsmChatImage.profile(
          acknowledge?.profileImageUrl?.call(context, user) ?? user.profileUrl,
          name: user.displayName,
          dimensions: IsmChatDimens.forty,
        );
  }

  Widget _buildUserTitle(
    BuildContext context,
    UserDetails user, {
    required bool showOwnUser,
    required TextStyle style,
  }) {
    if (showOwnUser) {
      return Text(IsmChatStrings.you, style: style);
    }
    final acknowledge =
        IsmChatProperties.chatPageProperties.messageInfoAcknowldge;
    return acknowledge?.titleBuilder?.call(context, user) ??
        Text(
          acknowledge?.title?.call(context, user) ?? user.displayName,
          style: style,
        );
  }

  Widget _buildUserSubtitle(
    UserDetails user, {
    required bool showOwnUser,
    required TextStyle style,
  }) {
    if (showOwnUser) {
      return Text(IsmChatStrings.removeReaction, style: style);
    }
    return Text(user.userName, style: style);
  }

  Widget _buildReactionUserTile({
    required BuildContext context,
    required String userId,
    required MessageReactionModel reactionEntry,
    required IsmChatReactionTheme reactionTheme,
    required Color emojiBackgroundColor,
    required bool showTrailingEmoji,
    required VoidCallback onOwnReactionTap,
  }) {
    final showOwnUser =
        userId == IsmChatConfig.communicationConfig.userConfig.userId;
    final user = _resolveReactionUser(userId);
    final reactionValue = getIsmChatEmoji(reaction: reactionEntry);
    final reaction = widget._controller.reactions
        .firstWhere((e) => e.name == reactionValue.emojiKeyword);

    final tile = ListTile(
      title: _buildUserTitle(
        context,
        user,
        showOwnUser: showOwnUser,
        style: reactionTheme.listTileTitleTextStyle,
      ),
      subtitle: _buildUserSubtitle(
        user,
        showOwnUser: showOwnUser,
        style: reactionTheme.listTileSubtitleTextStyle,
      ),
      leading: _buildProfileLeading(context, user),
      trailing: showTrailingEmoji
          ? SizedBox(
              height: IsmChatDimens.thirtyTwo,
              width: IsmChatDimens.thirtyTwo,
              child: EmojiCell.fromConfig(
                emojiBoxSize: 20,
                emoji: reaction,
                emojiSize: IsmChatDimens.twenty,
                onEmojiSelected: (_, emoji) {},
                config: Config(
                  categoryViewConfig: CategoryViewConfig(
                    indicatorColor: IsmChatConfig.chatTheme.primaryColor!,
                  ),
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: IsmChatDimens.twentyFour,
                    backgroundColor: emojiBackgroundColor,
                  ),
                ),
              ),
            )
          : null,
    );

    if (!showOwnUser) {
      return tile;
    }

    return IsmChatTapHandler(
      onTap: onOwnReactionTap,
      child: tile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final reactionTheme = IsmChatThemeResolver.reactionFromConfig(context);
    var reactionLength = widget.message.reactions?.length ?? 0;
    var allReactions = getAllReaction(widget.message.reactions!);
    final emojiBackgroundColor = reactionTheme.emojiBackgroundColor ??
        IsmChatConfig.chatTheme.backgroundColor!;

    return Container(
      color: reactionTheme.backgroundColor,
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
                indicatorColor: IsmChatConfig.chatTheme.primaryColor,
                labelColor: reactionTheme.tabLabelTextStyle.color,
                unselectedLabelColor: reactionTheme.tabLabelTextStyle.color,
                tabs: [
                  Text(
                    '${IsmChatStrings.all} ${allReactions.length} ',
                    style: reactionTheme.tabLabelTextStyle,
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
                                backgroundColor: emojiBackgroundColor,
                              ),
                            ),
                          ),
                        ),
                        IsmChatDimens.boxWidth8,
                        Text(
                          '${widget.message.reactions?[index].userIds.length}',
                          style: reactionTheme.tabCountTextStyle,
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
                    final userId = allReactions[index].userIds.first;
                    return _buildReactionUserTile(
                      context: context,
                      userId: userId,
                      reactionEntry: allReactions[index],
                      reactionTheme: reactionTheme,
                      emojiBackgroundColor: emojiBackgroundColor,
                      showTrailingEmoji: true,
                      onOwnReactionTap: () async {
                        IsmChatRoute.goBack();
                        ismChatEmoji =
                            getIsmChatEmoji(reaction: allReactions[index]);
                        await widget._controller.deleteReacton(
                          reaction: Reaction(
                            reactionType: ismChatEmoji,
                            messageId: widget.message.messageId ?? '',
                            conversationId: widget.message.conversationId ?? '',
                          ),
                        );
                      },
                    );
                  },
                ),
                ...List.generate(
                  reactionLength,
                  (index) => ListView(
                    children: List.generate(
                      widget.message.reactions?[index].userIds.length ?? 0,
                      (indexUserId) {
                        final userId = widget
                            .message.reactions?[index].userIds[indexUserId];
                        if (userId == null) {
                          return const SizedBox.shrink();
                        }
                        return _buildReactionUserTile(
                          context: context,
                          userId: userId,
                          reactionEntry: widget.message.reactions![index],
                          reactionTheme: reactionTheme,
                          emojiBackgroundColor: emojiBackgroundColor,
                          showTrailingEmoji: false,
                          onOwnReactionTap: () async {
                            IsmChatRoute.goBack();
                            await widget._controller.deleteReacton(
                              reaction: Reaction(
                                reactionType: getIsmChatEmoji(
                                  reaction: widget.message.reactions![index],
                                ),
                                messageId: widget.message.messageId ?? '',
                                conversationId:
                                    widget.message.conversationId ?? '',
                              ),
                            );
                          },
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
