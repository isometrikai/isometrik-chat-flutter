import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/colors.dart';
import 'package:isometrik_chat_flutter/src/res/styles.dart';

/// Theme for group / conversation info ([IsmChatConverstaionInfoView]).
///
/// Omit on [IsmChatPageTheme] to use SDK light/dark defaults via [IsmChatThemeResolver].
/// Pass a full instance only when customizing.
class IsmChatGroupInfoTheme {
  const IsmChatGroupInfoTheme({
    required this.scaffoldBackgroundColor,
    required this.surfaceBackgroundColor,
    required this.primaryTitleTextStyle,
    required this.secondaryTextStyle,
    required this.captionTextStyle,
    required this.metaTextStyle,
    required this.sectionTitleTextStyle,
    required this.bodyTextStyle,
    required this.listTileTitleTextStyle,
    required this.listTileSubtitleTextStyle,
    required this.actionIconColor,
    required this.menuIconColor,
    required this.inputTextStyle,
    required this.searchFillColor,
    required this.searchHintTextStyle,
    required this.searchIconColor,
    required this.adminBadgeTextStyle,
    required this.dividerColor,
  });

  factory IsmChatGroupInfoTheme.light() => IsmChatGroupInfoTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorLight,
        surfaceBackgroundColor: IsmChatColors.whiteColor,
        primaryTitleTextStyle: IsmChatStyles.w600Black27,
        secondaryTextStyle: IsmChatStyles.w500GreyLight17,
        captionTextStyle: IsmChatStyles.w400Grey14,
        metaTextStyle: IsmChatStyles.w400Black14,
        sectionTitleTextStyle: IsmChatStyles.w500Black16,
        bodyTextStyle: IsmChatStyles.w400Black16,
        listTileTitleTextStyle: IsmChatStyles.w500Black16,
        listTileSubtitleTextStyle: IsmChatStyles.w400Black12,
        actionIconColor: IsmChatColors.greyColorLight,
        menuIconColor: IsmChatColors.blackColor,
        inputTextStyle: IsmChatStyles.w400Black16,
        searchFillColor: IsmChatColors.whiteColor,
        searchHintTextStyle: IsmChatStyles.w400Grey14,
        searchIconColor: IsmChatColors.primaryColorLight,
        adminBadgeTextStyle: IsmChatStyles.w600Black12,
        dividerColor: IsmChatColors.greyColorLight,
      );

  factory IsmChatGroupInfoTheme.dark() => IsmChatGroupInfoTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorDark,
        surfaceBackgroundColor: const Color(0xFF353535),
        primaryTitleTextStyle: IsmChatStyles.w600White16.copyWith(fontSize: 27),
        secondaryTextStyle: IsmChatStyles.w400White12.copyWith(fontSize: 17),
        captionTextStyle: IsmChatStyles.w400White12,
        metaTextStyle: IsmChatStyles.w400White14,
        sectionTitleTextStyle: IsmChatStyles.w400White16,
        bodyTextStyle: IsmChatStyles.w400White14,
        listTileTitleTextStyle: IsmChatStyles.w400White16,
        listTileSubtitleTextStyle: IsmChatStyles.w400White12,
        actionIconColor: IsmChatColors.greyColorLight,
        menuIconColor: IsmChatColors.whiteColor,
        inputTextStyle: IsmChatStyles.w400White16,
        searchFillColor: const Color(0xFF454545),
        searchHintTextStyle: IsmChatStyles.w400White12.copyWith(
          color: IsmChatColors.greyColorLight,
        ),
        searchIconColor: IsmChatColors.greyColorLight,
        adminBadgeTextStyle: IsmChatStyles.w400White12.copyWith(
          fontWeight: FontWeight.w600,
        ),
        dividerColor: IsmChatColors.greyColor,
      );

  final Color scaffoldBackgroundColor;
  final Color surfaceBackgroundColor;
  final TextStyle primaryTitleTextStyle;
  final TextStyle secondaryTextStyle;
  final TextStyle captionTextStyle;
  final TextStyle metaTextStyle;
  final TextStyle sectionTitleTextStyle;
  final TextStyle bodyTextStyle;
  final TextStyle listTileTitleTextStyle;
  final TextStyle listTileSubtitleTextStyle;
  final Color actionIconColor;
  final Color menuIconColor;
  final TextStyle inputTextStyle;
  final Color searchFillColor;
  final TextStyle searchHintTextStyle;
  final Color searchIconColor;
  final TextStyle adminBadgeTextStyle;
  final Color dividerColor;
}
