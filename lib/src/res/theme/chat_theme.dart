import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    this.chatPageHeaderTheme,
    this.chatPageTheme,
    this.chatListCardThemData,
  })  : primaryColor = primaryColor ?? IsmChatThemeData.light().primaryColor,
        backgroundColor =
            backgroundColor ?? IsmChatThemeData.light().backgroundColor,
        notificationColor =
            notificationColor ?? IsmChatThemeData.light().notificationColor,
        mentionColor = mentionColor ?? IsmChatThemeData.light().mentionColor,
        floatingActionButtonTheme = floatingActionButtonTheme ??
            IsmChatThemeData.light().floatingActionButtonTheme,
        iconTheme = iconTheme ?? IsmChatThemeData.light().iconTheme,
        chatListTheme = chatListTheme ?? IsmChatThemeData.light().chatListTheme,
        dividerColor = verticalDividerColor ?? primaryColor;

  factory IsmChatThemeData.fallback() => IsmChatThemeData.light();

  factory IsmChatThemeData.light() => IsmChatThemeData(
        chatPageTheme: IsmChatPageThemeData(),
        chatPageHeaderTheme: IsmChatHeaderThemeData(),
        chatListTheme: const IsmChatListThemeData.light(),
        primaryColor: IsmChatColors.primaryColorLight,
        backgroundColor: IsmChatColors.backgroundColorLight,
        mentionColor: IsmChatColors.yellowColor,
        notificationColor: IsmChatColors.whiteColor,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: IsmChatColors.primaryColorLight,
          foregroundColor: IsmChatColors.whiteColor,
        ),
        iconTheme: const IconThemeData(
          color: IsmChatColors.primaryColorLight,
        ),
      );

  factory IsmChatThemeData.dark() => IsmChatThemeData(
        chatPageTheme: IsmChatPageThemeData(),
        chatPageHeaderTheme: IsmChatHeaderThemeData(),
        chatListTheme: const IsmChatListThemeData.dark(),
        primaryColor: IsmChatColors.primaryColorDark,
        mentionColor: IsmChatColors.yellowColor,
        notificationColor: IsmChatColors.whiteColor,
        backgroundColor: IsmChatColors.backgroundColorDark,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: IsmChatColors.primaryColorDark,
          foregroundColor: IsmChatColors.whiteColor,
        ),
        iconTheme: const IconThemeData(
          color: IsmChatColors.primaryColorDark,
        ),
      );

  final Color? primaryColor;

  final Color? dividerColor;

  final Color? backgroundColor;

  final Color? mentionColor;

  final Color? notificationColor;

  final IsmChatListThemeData? chatListTheme;

  final FloatingActionButtonThemeData? floatingActionButtonTheme;

  final IconThemeData? iconTheme;

  final IsmChatPageThemeData? chatPageTheme;

  final IsmChatHeaderThemeData? chatPageHeaderTheme;

  final IsmChatListCardThemData? chatListCardThemData;

  lerp(IsmChatThemeData? theme, double t) {}
}
