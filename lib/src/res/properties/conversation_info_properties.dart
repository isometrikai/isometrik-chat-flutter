import 'package:flutter/material.dart';

/// App-overridable icons / widgets for conversation info screens
/// ([IsmChatConverstaionInfoView], [IsmChatUserInfo]).
///
/// Kept separate from [IsmChatPageProperties] so chat-page composer settings
/// stay lean. Configure via [IsmChatProperties.conversationInfoProperties].
///
/// Example:
/// ```dart
/// IsmChatProperties.conversationInfoProperties =
///     IsmChatConversationInfoProperties(
///   clearChatIcon: SvgPicture.asset('assets/icons/clear_chat.svg'),
///   exitGroupIcon: SvgPicture.asset('assets/icons/exit_group.svg'),
///   deleteChatIcon: SvgPicture.asset('assets/icons/delete_chat.svg'),
///   blockUserIcon: SvgPicture.asset('assets/icons/block.svg'),
///   unblockUserIcon: SvgPicture.asset('assets/icons/unblock.svg'),
///   conversationMediaIcon: SvgPicture.asset('assets/icons/gallery.svg'),
///   groupProfileEditIcon: Icon(Icons.camera_alt_outlined, size: 18),
/// );
/// ```
class IsmChatConversationInfoAssets {
  IsmChatConversationInfoAssets({
    this.groupProfileEditIcon,
    this.conversationMediaIcon,
    this.clearChatIcon,
    this.deleteChatIcon,
    this.exitGroupIcon,
    this.blockUserIcon,
    this.unblockUserIcon,
    this.changeGroupTitleIcon,
    this.changeGroupImageIcon,
  });

  /// Edit badge on the group profile photo.
  ///
  /// If null, SDK uses `Icons.edit_outlined`.
  final Widget? groupProfileEditIcon;

  /// Leading icon for the Media / Links / Docs row.
  ///
  /// Reused by group info and 1:1 [IsmChatUserInfo].
  /// If null, SDK uses [IsmChatAssets.gallarySvg].
  final Widget? conversationMediaIcon;

  /// Clear chat action (group + 1:1).
  ///
  /// If null, SDK defaults:
  /// - Group: `Icons.clear_all_rounded`
  /// - 1:1: `Icons.clear_all_outlined` (red)
  final Widget? clearChatIcon;

  /// Delete chat action (1:1).
  ///
  /// If null, SDK uses `Icons.delete_forever_outlined` (red).
  final Widget? deleteChatIcon;

  /// Exit group action.
  ///
  /// If null, SDK uses `Icons.logout_rounded` (red).
  final Widget? exitGroupIcon;

  /// Block action when the opponent is not blocked.
  ///
  /// Pair with [unblockUserIcon]. If null, SDK uses `Icons.block_outlined` (red).
  final Widget? blockUserIcon;

  /// Unblock action when the opponent is blocked.
  ///
  /// If null, falls back to [blockUserIcon], then SDK `Icons.block_outlined` (red).
  final Widget? unblockUserIcon;

//Menu icons
  final Widget? changeGroupTitleIcon;

  final Widget? changeGroupImageIcon;
}
