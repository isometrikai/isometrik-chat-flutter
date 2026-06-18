import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/res/theme/attachment_card_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/chat_dialog_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/contact_info_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/group_info_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/media_theme.dart';
import 'package:isometrik_chat_flutter/src/res/theme/profile_theme.dart';
import 'package:isometrik_chat_flutter/src/utilities/config/chat_config.dart';

/// Resolves SDK screen themes: custom override → [Theme.of] / [Get.isDarkMode].
///
/// Do not wrap screens in [Obx] only for theme — [Get.isDarkMode] is not reactive.
/// Pass [BuildContext] to `*FromConfig(context)` so brightness comes from [Theme].
class IsmChatThemeResolver {
  IsmChatThemeResolver._();

  /// [mode] → [screenThemeMode] → [IsmChatConfig.chatBrightness] → [Theme.of] → [Get.isDarkMode].
  static Brightness brightness(BuildContext context, [Brightness? mode]) {
    if (mode != null) return mode;
    final pageMode = IsmChatConfig.chatTheme.chatPageTheme?.screenThemeMode;
    if (pageMode != null) return pageMode;
    final chatBrightness = IsmChatConfig.chatBrightness;
    if (chatBrightness != null) return chatBrightness;
    return Theme.of(context).brightness;
  }

  /// Same source as [IsmChatConfig.chatTheme] (host [chatBrightness] or Get).
  static bool get isSdkDarkMode => IsmChatConfig.isChatDarkMode;

  static IsmChatAttachmentCardTheme attachmentCard(
    BuildContext context, {
    IsmChatAttachmentCardTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatAttachmentCardTheme.dark()
        : IsmChatAttachmentCardTheme.light();
  }

  static IsmChatAttachmentCardTheme attachmentCardFromConfig(
          BuildContext context) =>
      attachmentCard(
        context,
        custom: IsmChatConfig.chatTheme.chatPageTheme?.attachmentCardTheme,
      );

  static IsmChatMediaTheme media(
    BuildContext context, {
    IsmChatMediaTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatMediaTheme.dark()
        : IsmChatMediaTheme.light();
  }

  static IsmChatMediaTheme mediaFromConfig(BuildContext context) =>
      media(context, custom: IsmChatConfig.chatTheme.chatPageTheme?.mediaTheme);

  static IsmChatContactInfoTheme contactInfo(
    BuildContext context, {
    IsmChatContactInfoTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatContactInfoTheme.dark()
        : IsmChatContactInfoTheme.light();
  }

  static IsmChatContactInfoTheme contactInfoFromConfig(BuildContext context) =>
      contactInfo(
        context,
        custom: IsmChatConfig.chatTheme.chatPageTheme?.contactInfoTheme,
      );

  static IsmChatGroupInfoTheme groupInfo(
    BuildContext context, {
    IsmChatGroupInfoTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatGroupInfoTheme.dark()
        : IsmChatGroupInfoTheme.light();
  }

  static IsmChatGroupInfoTheme groupInfoFromConfig(BuildContext context) =>
      groupInfo(
        context,
        custom: IsmChatConfig.chatTheme.chatPageTheme?.groupInfoTheme,
      );

  static IsmChatProfileTheme profile(
    BuildContext context, {
    IsmChatProfileTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatProfileTheme.dark()
        : IsmChatProfileTheme.light();
  }

  static IsmChatProfileTheme profileFromConfig(BuildContext context) =>
      profile(context, custom: IsmChatConfig.chatTheme.profileTheme);

  static IsmChatDialogTheme dialog(
    BuildContext context, {
    IsmChatDialogTheme? custom,
    Brightness? mode,
  }) {
    if (custom != null) return custom;
    return brightness(context, mode) == Brightness.dark
        ? IsmChatDialogTheme.dark()
        : IsmChatDialogTheme.light();
  }

  /// Popups / alerts. Uses [Theme.of] brightness when [IsmChatConfig.chatBrightness] is unset.
  static IsmChatDialogTheme dialogFromConfig(BuildContext context) => dialog(
        context,
        custom: IsmChatConfig.chatTheme.dialogTheme,
      );
}
