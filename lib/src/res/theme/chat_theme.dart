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
    this.dialogTheme,
    this.chatPageHeaderTheme,
    this.chatPageTheme,
    this.chatListCardThemData,
    this.cardTheme,
    this.profileTheme,
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
        dividerColor = dividerColor ?? primaryColor,
        borderColor = borderColor ?? primaryColor;

  factory IsmChatThemeData.fallback() => IsmChatThemeData.light();

  factory IsmChatThemeData.light() => IsmChatThemeData(
        chatPageTheme: IsmChatPageTheme(),
        chatPageHeaderTheme: IsmChatHeaderTheme.light(),
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
      );

  factory IsmChatThemeData.dark() => IsmChatThemeData(
        chatPageTheme: IsmChatPageTheme(
          opponentMessageTheme: IsmChatMessageTheme(
            textColor: IsmChatColors.whiteColor,
            userNameTextStyle: IsmChatStyles.w400Black10.copyWith(
              color: IsmChatColors.whiteColor,
            ),
          ),
        ),
        chatPageHeaderTheme: IsmChatHeaderTheme.dark(),
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
      );

  final Color? primaryColor;

  final Color? dividerColor;

  final Color? borderColor;

  final Color? backgroundColor;

  final Color? mentionColor;

  final Color? notificationColor;

  final IsmChatCardTheme? cardTheme;

  final IsmChatListTheme? chatListTheme;

  final FloatingActionButtonThemeData? floatingActionButtonTheme;

  final IconThemeData? iconTheme;

  /// Popups / alerts ([IsmChatAlertDialogBox]).
  /// Null → SDK light/dark default via [IsmChatThemeResolver.dialogFromConfig].
  final IsmChatDialogTheme? dialogTheme;

  final IsmChatPageTheme? chatPageTheme;

  final IsmChatHeaderTheme? chatPageHeaderTheme;

  final IsmChatListCardTheme? chatListCardThemData;

  /// Profile / user-info screens ([IsmChatUserView], [IsmChatUserInfo]).
  /// Null → SDK light/dark default via [IsmChatThemeResolver.profileFromConfig].
  final IsmChatProfileTheme? profileTheme;

  // ignore: strict_top_level_inference
  lerp(IsmChatThemeData? theme, double t) {}
}
