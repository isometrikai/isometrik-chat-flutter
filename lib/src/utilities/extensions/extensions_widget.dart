/// Widget and UI-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on Flutter widgets and UI-related enums
/// for common UI operations like unfocus gestures, icons, etc.
library;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for Scaffold to add unfocus gesture detector.
extension ScaffoldExtenstion on Scaffold {
  /// Wraps the scaffold with a GestureDetector that unfocuses when tapped.
  Widget withUnfocusGestureDetctor(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: this,
      );
}

/// Extension for FlashMode to get corresponding icon.
extension FlashIcon on FlashMode {
  /// Returns the icon data for the current flash mode.
  IconData get icon {
    switch (this) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on_rounded;
    }
  }
}

/// Extension for IsmChatCustomMessageType to check if it can be copied.
extension ChildWidget on IsmChatCustomMessageType {
  /// Returns true if this message type can be copied.
  bool get canCopy => [
        IsmChatCustomMessageType.text,
        IsmChatCustomMessageType.link,
        IsmChatCustomMessageType.location,
        IsmChatCustomMessageType.reply,
      ].contains(this);
}

/// Extension for IsmChatFocusMenuType to get corresponding icon.
extension MenuIcon on IsmChatFocusMenuType {
  /// Returns the icon data for the current focus menu type.
  IconData get icon {
    switch (this) {
      case IsmChatFocusMenuType.info:
        return Icons.info_outline_rounded;
      case IsmChatFocusMenuType.reply:
        return Icons.reply_rounded;
      case IsmChatFocusMenuType.forward:
        return Icons.shortcut_rounded;
      case IsmChatFocusMenuType.copy:
        return Icons.copy_rounded;
      case IsmChatFocusMenuType.delete:
        return Icons.delete_outline_rounded;
      case IsmChatFocusMenuType.selectMessage:
        return Icons.select_all_rounded;
    }
  }
}

/// Extension for IsmChatAttachmentType to get corresponding icon.
extension AttachmentIcon on IsmChatAttachmentType {
  /// Returns the icon data for the current attachment type.
  IconData get iconData {
    switch (this) {
      case IsmChatAttachmentType.camera:
        return Icons.camera_alt_outlined;
      case IsmChatAttachmentType.gallery:
        return Icons.collections;

      case IsmChatAttachmentType.document:
        return Icons.description;
      case IsmChatAttachmentType.location:
        return Icons.pin_drop;

      case IsmChatAttachmentType.contact:
        return Icons.person_rounded;
    }
  }
}

/// Extension for IsmChatConversationType to get conversation-related widgets and properties.
extension Conversation on IsmChatConversationType {
  /// Returns the display name for the conversation type.
  String get conversationName {
    switch (this) {
      case IsmChatConversationType.private:
        return 'All Chats';
      case IsmChatConversationType.public:
        return 'Public';
      case IsmChatConversationType.open:
        return 'Open';
    }
  }

  /// Returns the widget for the conversation type.
  Widget get conversationWidget {
    switch (this) {
      case IsmChatConversationType.private:
        return const IsmChatConversationList();
      case IsmChatConversationType.public:
        return const IsmChatPublicConversationView();
      case IsmChatConversationType.open:
        return const IsmChatOpenConversationView();
    }
  }

  /// Returns the icon for the conversation type.
  IconData get icon {
    switch (this) {
      case IsmChatConversationType.private:
        return Icons.admin_panel_settings_outlined;
      case IsmChatConversationType.public:
        return Icons.group_add_rounded;
      case IsmChatConversationType.open:
        return Icons.lock_open_outlined;
    }
  }

  /// Returns the conversation type string.
  String get conversationType {
    switch (this) {
      case IsmChatConversationType.private:
        return IsmChatStrings.conversation;
      case IsmChatConversationType.public:
        return IsmChatStrings.publicConversation;
      case IsmChatConversationType.open:
        return IsmChatStrings.openConversation;
    }
  }

  /// Navigates to the appropriate route based on conversation type.
  void goToRoute() {
    final controller = IsmChatUtility.conversationController;
    switch (this) {
      case IsmChatConversationType.private:
        break;
      case IsmChatConversationType.public:
        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          controller.isRenderScreen =
              IsRenderConversationScreen.publicConverationView;
          Scaffold.of(controller.isDrawerContext!).openDrawer();
        } else {
          IsmChatRoute.goToRoute(const IsmChatPublicConversationView());
        }

        break;
      case IsmChatConversationType.open:
        if (IsmChatResponsive.isWeb(
            IsmChatConfig.kNavigatorKey.currentContext ??
                IsmChatConfig.context)) {
          controller.isRenderScreen =
              IsRenderConversationScreen.openConverationView;
          Scaffold.of(controller.isDrawerContext!).openDrawer();
        } else {
          IsmChatRoute.goToRoute(const IsmChatOpenConversationView());
        }

        break;
    }
  }
}
