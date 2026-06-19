import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/theme/attachment_card_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_center_messgae_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_message_constraints.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_message_focused_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_message_hover_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_message_status_them.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_message_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_replay_messae_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_send_button_them.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_textfiled_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/contact_info_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/group_info_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/media_theme.dart';

/// Chat page styling and optional per-screen theme overrides.
///
/// **SDK defaults (recommended):** omit [mediaTheme], [contactInfoTheme],
/// [groupInfoTheme], and [attachmentCardTheme]. Set [IsmChatConfig.chatLightTheme] /
/// [chatDarkTheme] (or toggle [Get.isDarkMode]) and the SDK picks light/dark UI.
///
/// **Mode only:** set [screenThemeMode] to [Brightness.light] or [Brightness.dark]
/// without passing full screen theme objects.
///
/// **Full customize:** pass e.g. [IsmChatMediaTheme] with your colors.
class IsmChatPageTheme {
  IsmChatPageTheme({
    this.profileImageSize,
    this.messageSelectionColor,
    this.selfMessageTheme,
    this.opponentMessageTheme,
    this.pageDecoration,
    this.backgroundColor,
    this.sendButtonTheme,
    this.textFiledTheme,
    this.centerMessageTheme,
    this.replyMessageTheme,
    this.messageStatusTheme,
    this.messageHoverTheme,
    this.messageConstraints,
    this.searchTextFiledTheme,
    this.messgaeFocusedTheme,
    this.attachmentCardTheme,
    this.contactInfoTheme,
    this.mediaTheme,
    this.groupInfoTheme,
    this.screenThemeMode,
  });

  /// When set and per-screen themes are null, SDK defaults use this brightness.
  /// When null, [Get.isDarkMode] is used.
  final Brightness? screenThemeMode;

  final double? profileImageSize;
  final Color? messageSelectionColor;
  final IsmChatMessageTheme? selfMessageTheme;
  final IsmChatMessageTheme? opponentMessageTheme;

  final Decoration? pageDecoration;
  final Color? backgroundColor;

  final IsmChatSendButtonTheme? sendButtonTheme;

  /// Composer ([IsmChatMessageField]). Null → SDK light/dark via [IsmChatThemeResolver.textFieldFromConfig].
  final IsmChatTextFiledTheme? textFiledTheme;
  final IsmChatTextFiledTheme? searchTextFiledTheme;
  final IsmChatCenterMessageTheme? centerMessageTheme;
  final IsmChatReplyMessageTheme? replyMessageTheme;
  final IsmChatMessageStatusTheme? messageStatusTheme;
  final IsmChatMessageHoverTheme? messageHoverTheme;
  final IsmChatMessageConstraints? messageConstraints;
  final IsmChatFocusedMessageTheme? messgaeFocusedTheme;

  /// Attachment sheet ([IsmChatAttachmentCard]). Null → SDK light/dark default.
  final IsmChatAttachmentCardTheme? attachmentCardTheme;

  /// Shared contacts ([IsmChatContactsInfoView]). Null → SDK light/dark default.
  final IsmChatContactInfoTheme? contactInfoTheme;

  /// Conversation media ([IsmMedia]). Null → SDK light/dark default.
  final IsmChatMediaTheme? mediaTheme;

  /// Group / conversation info ([IsmChatConverstaionInfoView]). Null → SDK default.
  final IsmChatGroupInfoTheme? groupInfoTheme;
}
