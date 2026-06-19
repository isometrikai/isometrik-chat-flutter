import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Composer / message input styling on [IsmChatPageTheme.textFiledTheme].
///
/// Omit for SDK light/dark defaults via [IsmChatThemeResolver.textFieldFromConfig].
/// Pass only the fields you need to override (e.g. [recordingTimerTextStyle]).
class IsmChatTextFiledTheme {
  const IsmChatTextFiledTheme({
    this.inputTextStyle,
    this.decoration,
    this.backgroundColor,
    this.cursorColor,
    this.textfieldInsets,
    this.attchmentColor,
    this.emojiColor,
    this.borderColor,
    this.hintTextStyle,
    this.recordingTimerTextStyle,
  });

  factory IsmChatTextFiledTheme.light() => IsmChatTextFiledTheme(
        inputTextStyle: IsmChatStyles.w400Black12,
        hintTextStyle: IsmChatStyles.w400Black12.copyWith(
          color: IsmChatColors.greyColor,
        ),
        backgroundColor: IsmChatColors.whiteColor,
        cursorColor: IsmChatColors.primaryColorLight,
        attchmentColor: IsmChatColors.primaryColorLight,
        emojiColor: IsmChatColors.primaryColorLight,
        borderColor: IsmChatColors.primaryColorLight,
        recordingTimerTextStyle: IsmChatStyles.w600Black20,
      );

  factory IsmChatTextFiledTheme.dark() => IsmChatTextFiledTheme(
        inputTextStyle: IsmChatStyles.w400White14,
        hintTextStyle: IsmChatStyles.w400White12.copyWith(
          color: IsmChatColors.greyColorLight,
        ),
        backgroundColor: const Color(0xFF353535),
        cursorColor: IsmChatColors.primaryColorDark,
        attchmentColor: IsmChatColors.primaryColorDark,
        emojiColor: IsmChatColors.primaryColorDark,
        borderColor: IsmChatColors.greyColor,
        recordingTimerTextStyle: IsmChatStyles.w600White16.copyWith(
          fontSize: IsmChatDimens.twenty,
        ),
      );

  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final Decoration? decoration;
  final Color? backgroundColor;
  final Color? cursorColor;
  final EdgeInsetsGeometry? textfieldInsets;
  final Color? attchmentColor;
  final Color? emojiColor;
  final Color? borderColor;

  /// Voice-note recording timer in [IsmChatMessageField].
  final TextStyle? recordingTimerTextStyle;
}
