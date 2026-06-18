import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Theme for SDK popups ([IsmChatAlertDialogBox], [IsmChatContextWidget.showDialogContext]).
///
/// Omit on [IsmChatThemeData] to use SDK light/dark defaults via [IsmChatThemeResolver].
/// Pass a full instance only when customizing.
class IsmChatDialogTheme {
  const IsmChatDialogTheme({
    required this.backgroundColor,
    required this.titleTextStyle,
    required this.contentTextStyle,
    required this.actionTextStyle,
    required this.inputTextStyle,
    required this.inputBorderColor,
    required this.inputFocusedBorderColor,
    required this.barrierColor,
    this.insetPadding,
    this.shape,
  });

  factory IsmChatDialogTheme.light() => IsmChatDialogTheme(
        backgroundColor: IsmChatColors.whiteColor,
        titleTextStyle: IsmChatStyles.w600Black16,
        contentTextStyle: IsmChatStyles.w400Grey14,
        actionTextStyle: IsmChatStyles.w400Black14,
        inputTextStyle: IsmChatStyles.w400Black14,
        inputBorderColor: IsmChatColors.greyColorLight,
        inputFocusedBorderColor: IsmChatColors.primaryColorLight,
        barrierColor: Colors.black54,
        insetPadding: IsmChatDimens.edgeInsets16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
      );

  factory IsmChatDialogTheme.dark() => IsmChatDialogTheme(
        backgroundColor: const Color(0xFF353535),
        titleTextStyle: IsmChatStyles.w600White16,
        contentTextStyle: IsmChatStyles.w400White12.copyWith(
          color: IsmChatColors.greyColorLight,
        ),
        actionTextStyle: IsmChatStyles.w400White14,
        inputTextStyle: IsmChatStyles.w400White14,
        inputBorderColor: IsmChatColors.greyColor,
        inputFocusedBorderColor: IsmChatColors.primaryColorDark,
        barrierColor: Colors.black87,
        insetPadding: IsmChatDimens.edgeInsets16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IsmChatDimens.eight),
        ),
      );

  final TextStyle contentTextStyle;
  final TextStyle titleTextStyle;
  final TextStyle actionTextStyle;
  final TextStyle inputTextStyle;
  final Color inputBorderColor;
  final Color inputFocusedBorderColor;
  final Color backgroundColor;
  final Color barrierColor;
  final EdgeInsetsGeometry? insetPadding;
  final ShapeBorder? shape;
}
