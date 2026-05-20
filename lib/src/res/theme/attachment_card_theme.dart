import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Theme for the attachment picker ([IsmChatAttachmentCard]).
///
/// Reuse via [IsmChatConfig.chatTheme.chatPageTheme.attachmentCardTheme].
class IsmChatAttachmentCardTheme {
  const IsmChatAttachmentCardTheme({
    required this.backgroundColor,
    required this.labelTextStyle,
  });

  factory IsmChatAttachmentCardTheme.light() => IsmChatAttachmentCardTheme(
        backgroundColor: IsmChatColors.whiteColor,
        labelTextStyle: IsmChatStyles.w400Black14,
      );

  factory IsmChatAttachmentCardTheme.dark() => IsmChatAttachmentCardTheme(
        backgroundColor: IsmChatColors.blackColor,
        labelTextStyle: IsmChatStyles.w400White14,
      );

  final Color backgroundColor;
  final TextStyle labelTextStyle;
}
