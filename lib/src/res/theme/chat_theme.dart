import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatThemeData with Diagnosticable {
  IsmChatThemeData({
    IsmChatListTheme? chatListTheme,
    Color? primaryColor,
    Color? dividerColor,
    Color? borderColor,
    Color? backgroundColor,
    Color? mentionColor,
    Color? notificationColor,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconThemeData? iconTheme,
    IsmChatDialogTheme? dialogTheme,
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
        dividerColor = dividerColor ?? primaryColor,
        borderColor = borderColor ?? primaryColor;

  factory IsmChatThemeData.fallback() => IsmChatThemeData.light();

  factory IsmChatThemeData.light() => IsmChatThemeData(
        chatPageTheme: IsmChatPageTheme(),
        chatPageHeaderTheme: IsmChatHeaderTheme(),
        chatListTheme: const IsmChatListTheme.light(),
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
        dialogTheme: IsmChatDialogTheme(),
      );

  factory IsmChatThemeData.dark() => IsmChatThemeData(
        chatPageTheme: IsmChatPageTheme(),
        chatPageHeaderTheme: IsmChatHeaderTheme(),
        chatListTheme: const IsmChatListTheme.dark(),
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
        dialogTheme: IsmChatDialogTheme(),
      );

  final Color? primaryColor;

  final Color? dividerColor;

  final Color? borderColor;

  final Color? backgroundColor;

  final Color? mentionColor;

  final Color? notificationColor;

  final Color? cardBackgroundColor;

  final IsmChatListTheme? chatListTheme;

  final FloatingActionButtonThemeData? floatingActionButtonTheme;

  final IconThemeData? iconTheme;

  final IsmChatDialogTheme? dialogTheme;

  final IsmChatPageTheme? chatPageTheme;

  final IsmChatHeaderTheme? chatPageHeaderTheme;

  final IsmChatListCardTheme? chatListCardThemData;

  lerp(IsmChatThemeData? theme, double t) {}
}
