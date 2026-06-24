import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Theme for message reactions ([ImsChatReaction], [ImsChatShowUserReaction]).
///
/// Reuse via [IsmChatConfig.chatTheme.chatPageTheme.reactionTheme] or
/// [IsmChatThemeResolver.reactionFromConfig].
class IsmChatReactionTheme {
  const IsmChatReactionTheme({
    required this.backgroundColor,
    required this.countTextStyle,
    required this.tabLabelTextStyle,
    required this.tabCountTextStyle,
    required this.listTileTitleTextStyle,
    required this.listTileSubtitleTextStyle,
    this.boxShadow,
    this.emojiBackgroundColor,
  });

  factory IsmChatReactionTheme.light() => IsmChatReactionTheme(
        backgroundColor: IsmChatColors.whiteColor,
        countTextStyle: IsmChatStyles.w400Black12,
        tabLabelTextStyle: IsmChatStyles.w400Black18,
        tabCountTextStyle: IsmChatStyles.w400Black16,
        listTileTitleTextStyle: IsmChatStyles.w500Black16,
        listTileSubtitleTextStyle: IsmChatStyles.w400Grey14,
        boxShadow: const [BoxShadow(color: Colors.black26)],
        emojiBackgroundColor: IsmChatColors.backgroundColorLight,
      );

  factory IsmChatReactionTheme.dark() => IsmChatReactionTheme(
        backgroundColor: IsmChatColors.backgroundColorDark,
        countTextStyle: IsmChatStyles.w400White12,
        tabLabelTextStyle: IsmChatStyles.w400White18,
        tabCountTextStyle: IsmChatStyles.w400White16,
        listTileTitleTextStyle: IsmChatStyles.w500White16,
        listTileSubtitleTextStyle: IsmChatStyles.w400White12,
        boxShadow: const [BoxShadow(color: Colors.black45)],
        emojiBackgroundColor: IsmChatColors.blackColor,
      );

  /// Chip / sheet background.
  final Color backgroundColor;

  /// Reaction count on message chips ([ImsChatReaction]).
  final TextStyle countTextStyle;

  /// "All" tab label ([ImsChatShowUserReaction]).
  final TextStyle tabLabelTextStyle;

  /// Emoji tab reaction count ([ImsChatShowUserReaction]).
  final TextStyle tabCountTextStyle;

  /// User name in reaction list ([ImsChatShowUserReaction]).
  final TextStyle listTileTitleTextStyle;

  /// Username / remove-reaction subtitle ([ImsChatShowUserReaction]).
  final TextStyle listTileSubtitleTextStyle;

  final List<BoxShadow>? boxShadow;
  final Color? emojiBackgroundColor;
}
