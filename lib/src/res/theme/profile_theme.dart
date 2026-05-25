import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Theme for profile / user-info screens ([IsmChatUserView], [IsmChatUserInfo]).
///
/// Omit [IsmChatThemeData.profileTheme] for SDK light/dark defaults ([IsmChatThemeResolver]).
/// Pass a full instance only when customizing.
class IsmChatProfileTheme {
  const IsmChatProfileTheme({
    required this.scaffoldBackgroundColor,
    required this.cardBackgroundColor,
    required this.sectionTitleStyle,
    required this.primaryTextStyle,
    required this.secondaryTextStyle,
    required this.inputTextStyle,
    required this.inputHintStyle,
    required this.iconColor,
    required this.editButtonBackgroundColor,
    required this.editButtonBorderColor,
    required this.editButtonIconColor,
    required this.listTileTitleStyle,
    required this.listTileSubtitleStyle,
    required this.emptyStateTextStyle,
  });

  factory IsmChatProfileTheme.light() => IsmChatProfileTheme(
        scaffoldBackgroundColor: IsmChatColors.whiteColor,
        cardBackgroundColor: IsmChatColors.backgroundColorLight,
        sectionTitleStyle: IsmChatStyles.w400Black16.copyWith(
          color: IsmChatColors.primaryColorLight,
        ),
        primaryTextStyle: IsmChatStyles.w600Black16,
        secondaryTextStyle: IsmChatStyles.w600Black20,
        inputTextStyle: IsmChatStyles.w600Black16,
        inputHintStyle: IsmChatStyles.w600Black16.copyWith(
          color: IsmChatColors.greyColor,
        ),
        iconColor: IsmChatColors.greyColor,
        editButtonBackgroundColor: IsmChatColors.whiteColor,
        editButtonBorderColor: IsmChatColors.greyColor,
        editButtonIconColor: IsmChatColors.greyColor,
        listTileTitleStyle: IsmChatStyles.w500Black16,
        listTileSubtitleStyle: IsmChatStyles.w400Black12,
        emptyStateTextStyle: IsmChatStyles.w600Black20.copyWith(
          color: IsmChatColors.primaryColorLight,
        ),
      );

  factory IsmChatProfileTheme.dark() => IsmChatProfileTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorDark,
        cardBackgroundColor: const Color(0xFF353535),
        sectionTitleStyle: IsmChatStyles.w400White16.copyWith(
          color: IsmChatColors.primaryColorDark,
        ),
        primaryTextStyle: IsmChatStyles.w400White16,
        secondaryTextStyle: IsmChatStyles.w600White16,
        inputTextStyle: IsmChatStyles.w600White16,
        inputHintStyle: IsmChatStyles.w400White16.copyWith(
          color: IsmChatColors.greyColorLight,
        ),
        iconColor: IsmChatColors.greyColorLight,
        editButtonBackgroundColor: const Color(0xFF454545),
        editButtonBorderColor: IsmChatColors.greyColor,
        editButtonIconColor: IsmChatColors.greyColorLight,
        listTileTitleStyle: IsmChatStyles.w400White16,
        listTileSubtitleStyle: IsmChatStyles.w400White12,
        emptyStateTextStyle: IsmChatStyles.w600White16.copyWith(
          color: IsmChatColors.primaryColorDark,
        ),
      );

  final Color scaffoldBackgroundColor;
  final Color cardBackgroundColor;
  final TextStyle sectionTitleStyle;
  final TextStyle primaryTextStyle;
  final TextStyle secondaryTextStyle;
  final TextStyle inputTextStyle;
  final TextStyle inputHintStyle;
  final Color iconColor;
  final Color editButtonBackgroundColor;
  final Color editButtonBorderColor;
  final Color editButtonIconColor;
  final TextStyle listTileTitleStyle;
  final TextStyle listTileSubtitleStyle;
  final TextStyle emptyStateTextStyle;
}
