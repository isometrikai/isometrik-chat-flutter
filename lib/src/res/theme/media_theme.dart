import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/colors.dart';
import 'package:isometrik_chat_flutter/src/res/styles.dart';

/// Theme for conversation media ([IsmMedia], [IsmDocsView], [IsmLinksView], [IsmMediaView]).
///
/// Omit in app config for SDK light/dark defaults ([IsmChatThemeResolver]).
/// Pass a full instance only when customizing.
class IsmChatMediaTheme {
  const IsmChatMediaTheme({
    required this.scaffoldBackgroundColor,
    required this.appBarBackgroundColor,
    required this.appBarIconColor,
    required this.tabBarContainerColor,
    required this.tabSelectedBackgroundColor,
    required this.tabUnselectedBackgroundColor,
    required this.tabSelectedTextStyle,
    required this.tabUnselectedTextStyle,
    required this.sectionTitleTextStyle,
    required this.docTitleTextStyle,
    required this.docSubtitleTextStyle,
    required this.docTrailingTextStyle,
    required this.emptyStateTextStyle,
    required this.dividerColor,
  });

  factory IsmChatMediaTheme.light() => IsmChatMediaTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorLight,
        appBarBackgroundColor: IsmChatColors.whiteColor,
        appBarIconColor: IsmChatColors.blackColor,
        tabBarContainerColor: IsmChatColors.darkBlueGreyColor,
        tabSelectedBackgroundColor: IsmChatColors.whiteColor,
        tabUnselectedBackgroundColor: IsmChatColors.darkBlueGreyColor,
        tabSelectedTextStyle: IsmChatStyles.w600Black16,
        tabUnselectedTextStyle: IsmChatStyles.w600Black16,
        sectionTitleTextStyle: IsmChatStyles.w400Black14,
        docTitleTextStyle: IsmChatStyles.w400Black14,
        docSubtitleTextStyle: IsmChatStyles.w400Black10,
        docTrailingTextStyle: IsmChatStyles.w400Black12,
        emptyStateTextStyle: IsmChatStyles.w600Black20,
        dividerColor: IsmChatColors.greyColor,
      );

  factory IsmChatMediaTheme.dark() => IsmChatMediaTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorDark,
        appBarBackgroundColor: IsmChatColors.backgroundColorDark,
        appBarIconColor: IsmChatColors.whiteColor,
        tabBarContainerColor: Color(0xFF353535),
        tabSelectedBackgroundColor: IsmChatColors.whiteColor,
        tabUnselectedBackgroundColor: Color(0xFF353535),
        tabSelectedTextStyle: IsmChatStyles.w600Black16,
        tabUnselectedTextStyle: IsmChatStyles.w600White16,
        sectionTitleTextStyle: IsmChatStyles.w400White14,
        docTitleTextStyle: IsmChatStyles.w400White14,
        docSubtitleTextStyle: IsmChatStyles.w400White12,
        docTrailingTextStyle: IsmChatStyles.w400White12,
        emptyStateTextStyle: IsmChatStyles.w600White16,
        dividerColor: IsmChatColors.greyColor,
      );

  final Color scaffoldBackgroundColor;
  final Color appBarBackgroundColor;
  final Color appBarIconColor;
  final Color tabBarContainerColor;
  final Color tabSelectedBackgroundColor;
  final Color tabUnselectedBackgroundColor;
  final TextStyle tabSelectedTextStyle;
  final TextStyle tabUnselectedTextStyle;
  final TextStyle sectionTitleTextStyle;
  final TextStyle docTitleTextStyle;
  final TextStyle docSubtitleTextStyle;
  final TextStyle docTrailingTextStyle;
  final TextStyle emptyStateTextStyle;
  final Color dividerColor;
}
