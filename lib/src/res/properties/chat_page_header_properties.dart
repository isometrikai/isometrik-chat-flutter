import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Customization for the chat page app bar / header.
///
/// Passed via [IsmChatPageProperties.header].
///
/// Popup menu icons (search, wallpaper, block, clear chat, delete group) can be
/// overridden from the host app. Prefer `Widget` overrides so apps can pass
/// [Icon], SVG, or any custom asset. If null, SDK Material icons are used.
///
/// Example:
/// ```dart
/// IsmChatPageProperties(
///   header: IsmChatPageHeaderProperties(
///     searchMessageIcon: SvgPicture.asset('assets/icons/search.svg'),
///     changeWallpaperIcon: SvgPicture.asset('assets/icons/wallpaper.svg'),
///     clearChatIcon: SvgPicture.asset('assets/icons/clear_chat.svg'),
///   ),
/// )
/// ```
class IsmChatPageHeaderProperties {
  IsmChatPageHeaderProperties({
    this.profileImageBuilder,
    this.profileImageUrl,
    this.titleBuilder,
    this.title,
    this.subtitleBuilder,
    this.subtitle,
    this.popupItems,
    this.bottom,
    this.onBackTap,
    this.height,
    this.shape,
    this.onProfileTap,
    this.actionBuilder,
    // Popup menu icons — app-side overrides (reuse from host branding)
    this.moreMenuIcon,
    this.searchMessageIcon,
    this.changeWallpaperIcon,
    this.blockUserIcon,
    this.unblockUserIcon,
    this.clearChatIcon,
    this.deleteGroupIcon,
  });

  final ConversationWidgetCallback? profileImageBuilder;
  final ConversationStringCallback? profileImageUrl;
  final ConversationWidgetCallback? titleBuilder;
  final ConversationStringCallback? title;
  final WidgetCallback? subtitleBuilder;
  final StringConversationCallback? subtitle;
  final WidgetCallback? actionBuilder;

  /// Provides this methode with exclude hight of widget
  final WidgetCallback? bottom;
  final PopupItemListCallback? popupItems;
  final Function(bool)? onBackTap;

  /// This funcation provides for tap on profile pic of chat page header,
  /// This is optional parameter
  /// When you have use `profileImageBuilder` then you don't use tap handler on this widget
  final void Function(IsmChatConversationModel?)? onProfileTap;

  final double? Function(
    BuildContext,
    IsmChatConversationModel?,
  )? height;
  final ShapeBorder? shape;

  // ---------------------------------------------------------------------------
  // Popup menu icons (chat page header overflow menu)
  // Reusable from host app; keep null to use SDK defaults.
  // ---------------------------------------------------------------------------

  /// Overflow / more-vert button on the header.
  ///
  /// If null, SDK uses `Icons.more_vert`.
  final Widget? moreMenuIcon;

  /// Search messages item in the header popup menu.
  ///
  /// If null, SDK uses `Icons.search_rounded`.
  final Widget? searchMessageIcon;

  /// Change wallpaper item in the header popup menu.
  ///
  /// If null, SDK uses `Icons.wallpaper_rounded`.
  final Widget? changeWallpaperIcon;

  /// Block user item when the opponent is not blocked.
  ///
  /// Pair with [unblockUserIcon]. If null, SDK uses `Icons.block`.
  final Widget? blockUserIcon;

  /// Unblock user item when the opponent is blocked.
  ///
  /// If null, falls back to [blockUserIcon], then SDK `Icons.block`.
  final Widget? unblockUserIcon;

  /// Clear chat item in the header popup menu.
  ///
  /// If null, SDK uses `Icons.delete`.
  final Widget? clearChatIcon;

  /// Delete group item in the header popup menu.
  ///
  /// If null, SDK uses `Icons.group_off_rounded`.
  final Widget? deleteGroupIcon;
}
