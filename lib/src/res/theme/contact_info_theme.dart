import 'package:flutter/material.dart';

import 'package:isometrik_chat_flutter/src/res/colors.dart';

/// Theme for the shared-contact screen ([IsmChatContactsInfoView]).
///
/// Omit in app config for SDK light/dark defaults ([IsmChatThemeResolver]).
/// Pass a full instance only when customizing.
class IsmChatContactInfoTheme {
  const IsmChatContactInfoTheme({
    required this.scaffoldBackgroundColor,
    required this.cardBackgroundColor,
    required this.nameTextStyle,
    required this.identifierTextStyle,
    required this.addButtonBackgroundColor,
    required this.addButtonTextStyle,
    required this.actionIconColor,
    required this.actionLabelTextStyle,
    required this.dividerColor,
  });

  factory IsmChatContactInfoTheme.light() => const IsmChatContactInfoTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorLight,
        cardBackgroundColor: IsmChatColors.whiteColor,
        nameTextStyle: TextStyle(
          color: IsmChatColors.blackColor,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        identifierTextStyle: TextStyle(
          color: IsmChatColors.blackColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        addButtonBackgroundColor: IsmChatColors.primaryColorLight,
        addButtonTextStyle: TextStyle(
          color: IsmChatColors.whiteColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionIconColor: IsmChatColors.primaryColorLight,
        actionLabelTextStyle: TextStyle(
          color: IsmChatColors.blackColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: IsmChatColors.greyColor,
      );

  factory IsmChatContactInfoTheme.dark() => const IsmChatContactInfoTheme(
        scaffoldBackgroundColor: IsmChatColors.backgroundColorDark,
        cardBackgroundColor: Color(0xFF353535),
        nameTextStyle: TextStyle(
          color: IsmChatColors.whiteColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        identifierTextStyle: TextStyle(
          color: IsmChatColors.whiteColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        addButtonBackgroundColor: IsmChatColors.primaryColorDark,
        addButtonTextStyle: TextStyle(
          color: IsmChatColors.whiteColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionIconColor: IsmChatColors.primaryColorDark,
        actionLabelTextStyle: TextStyle(
          color: IsmChatColors.whiteColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        dividerColor: IsmChatColors.greyColor,
      );

  final Color scaffoldBackgroundColor;
  final Color cardBackgroundColor;
  final TextStyle nameTextStyle;
  final TextStyle identifierTextStyle;
  final Color addButtonBackgroundColor;
  final TextStyle addButtonTextStyle;
  final Color actionIconColor;
  final TextStyle actionLabelTextStyle;
  final Color dividerColor;
}
