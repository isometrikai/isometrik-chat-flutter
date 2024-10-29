import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatThemeData with Diagnosticable {
  IsmChatThemeData({
    IsmChatListThemeData? chatListTheme,
    Color? primaryColor,
    Color? verticalDividerColor,
    Color? backgroundColor,
    Color? mentionColor,
    Color? notificationColor,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconThemeData? iconTheme,
    DialogTheme? dialogTheme,
    this.chatPageHeaderTheme,
    this.chatPageTheme,
    this.chatListCardThemData,
    this.cardBackgroundColor,
  })  : primaryColor = primaryColor ?? IsmChatThemeData.light().primaryColor,
        backgroundColor =
            backgroundColor ?? IsmChatThemeData.light().backgroundColor,
        notificationColor =
            notificationColor ?? IsmChatThemeData.light().notificationColor,
        mentionColor = mentionColor ?? IsmChatThemeData.light().mentionColor,
        floatingActionButtonTheme = floatingActionButtonTheme ??
            IsmChatThemeData.light().floatingActionButtonTheme,
        iconTheme = iconTheme ?? IsmChatThemeData.light().iconTheme,
        dialogTheme = dialogTheme ?? IsmChatThemeData.light().dialogTheme,
        chatListTheme = chatListTheme ?? IsmChatThemeData.light().chatListTheme,
        dividerColor = verticalDividerColor ?? primaryColor;

  factory IsmChatThemeData.fallback() => IsmChatThemeData.light();

  factory IsmChatThemeData.light() => IsmChatThemeData(
        chatPageTheme: IsmChatPageThemeData(),
        chatPageHeaderTheme: IsmChatHeaderThemeData(),
        chatListTheme: const IsmChatListThemeData.light(),
        primaryColor: IsmChatColors.primaryColorLight,
        backgroundColor: IsmChatColors.backgroundColorLight,
        mentionColor: IsmChatColors.primaryColorLight,
        notificationColor: IsmChatColors.whiteColor,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: IsmChatColors.primaryColorLight,
          foregroundColor: IsmChatColors.whiteColor,
        ),
        iconTheme: const IconThemeData(
          color: IsmChatColors.primaryColorLight,
        ),
        dialogTheme: const DialogTheme(),
      );

  factory IsmChatThemeData.dark() => IsmChatThemeData(
        chatPageTheme: IsmChatPageThemeData(),
        chatPageHeaderTheme: IsmChatHeaderThemeData(),
        chatListTheme: const IsmChatListThemeData.dark(),
        primaryColor: IsmChatColors.primaryColorDark,
        mentionColor: IsmChatColors.primaryColorDark,
        notificationColor: IsmChatColors.whiteColor,
        backgroundColor: IsmChatColors.backgroundColorDark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: IsmChatColors.primaryColorDark,
          foregroundColor: IsmChatColors.whiteColor,
        ),
        iconTheme: const IconThemeData(
          color: IsmChatColors.primaryColorDark,
        ),
        dialogTheme: const DialogTheme(),
      );

  final Color? primaryColor;

  final Color? dividerColor;

  final Color? backgroundColor;

  final Color? mentionColor;

  final Color? notificationColor;

  final Color? cardBackgroundColor;

  final IsmChatListThemeData? chatListTheme;

  final FloatingActionButtonThemeData? floatingActionButtonTheme;

  final IconThemeData? iconTheme;

  final DialogTheme? dialogTheme;

  final IsmChatPageThemeData? chatPageTheme;

  final IsmChatHeaderThemeData? chatPageHeaderTheme;

  final IsmChatListCardThemData? chatListCardThemData;

  lerp(IsmChatThemeData? theme, double t) {}
}
