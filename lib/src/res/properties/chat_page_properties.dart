import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageProperties {
  IsmChatPageProperties({
    this.header,
    this.placeholder,
    this.messageBuilder,
    this.attachments = IsmChatAttachmentType.values,
    this.features = IsmChatFeature.values,
    this.isAllowedDeleteChatFromLocal = false,
    this.attachmentConfig,
    this.messageAllowedConfig,
    this.forwardToUserList,
    this.onForwardTap,
    this.onAddGroupMembersTap,
    this.emojiIcon,
    this.meessageFieldFocusNode,
    this.messageFieldSuffix,
    this.onCallBlockUnblock,
    this.onBlockUnblockSuccess,
    this.onCoverstaionStatus,
    this.messageSenderProfileBuilder,
    this.messageSenderNameBuilder,
    this.messageSenderName,
    this.messageSenderProfileUrl,
    this.messageInfoAcknowldge,
    this.isSendMediaAllowed,
    this.mentionUserName,
    this.mentionUserProfileUrl,
    this.onMessageTap,
    this.isShowMessageBlur,
    this.loggedInUser,
    this.messageStatus,
    this.textFieldActions,
    this.inputFormatters,
    this.enableInteractiveSelection = true,
    this.contextMenuBuilder,
    this.messageInputHintText,
    this.shouldShowHoverHold,
    this.backgroundImageUrl,
    this.canReplayMessage,
    this.conversationDetailsApiInterval = const Duration(minutes: 1),
    this.enablePaidMediaHandling = false,
    this.contactMessageAvatarBuilder,
    this.voiceMessagePlayIcon,
    this.voiceMessagePauseIcon,
    this.voiceMessageLoadingIcon,
    this.voiceMessageWaveColorMe,
    this.voiceMessageWaveColorOpponent,
    this.voiceMessageProgressOverlayColorMe,
    this.voiceMessageProgressOverlayColorOpponent,
    this.onUserConversationInfoTap,
  });

  final Widget? placeholder;

  final bool isAllowedDeleteChatFromLocal;

  /// Provide this widget show emoji icon in message type input filed
  final Widget? emojiIcon;

  /// It is an optional parameter you can provide any widget
  /// You can pass tap handler on this widget for any uses
  final ConversationWidgetBuilder? messageFieldSuffix;

  final MessageWidgetBuilder? messageBuilder;

  final MessageSenderInfoBuilder? messageSenderProfileBuilder;

  final MessageSenderInfoBuilder? messageSenderNameBuilder;

  final MessageSenderInfoCallback? messageSenderName;

  final MessageSenderInfoCallback? messageSenderProfileUrl;

  final UserDetailsStringCallback? mentionUserName;

  final UserDetailsStringCallback? mentionUserProfileUrl;

  /// It is an optional parameter which take List of `IsmChatAttachmentType` which is an enum.
  /// Pass in the types of attachments that you want to allow.
  ///
  /// Defaults to all
  final List<IsmChatAttachmentType> attachments;

  /// It is an optional parameter which take List of `IsmChatFeature` which is an enum.
  /// Pass in the types of features that you want to allow.
  ///
  /// Defaults to all
  final List<IsmChatFeature> features;

  final IsmChatPageHeaderProperties? header;

  /// It is an optional parameter you can use for meessage send allow or not
  final MessageAllowedConfig? messageAllowedConfig;

  /// It is an optional parameter you can use for attachments configuration
  /// you can use for size and how to show per Lines
  final AttachmentConfig? attachmentConfig;

  /// It is an optional parameter you can use for forward to user list
  /// you can use for show user list in forward screen
  final ForwardMessageInfoBuilder? forwardToUserList;

  /// Required parameter
  ///
  /// Primarily designed for nagivating to Message screen
  ///
  /// ```dart
  /// ConversationVoidCallback? onForwardTap;
  /// ```
  ///
  /// `IsmChatConversationModel` gives data of current chat, it could be used for local storage or state variables
  final ConversationVoidCallback? onForwardTap;

  /// Optional callback when admin taps add-members in group info.
  ///
  /// If provided, host app handles navigation.
  /// If null, SDK opens default `IsmChatGroupEligibleUser` screen.
  final ConversationVoidCallback? onAddGroupMembersTap;

  /// It is an optional parameter for Message send text fieled
  /// You can check keyboard open or not with this parameter
  final MeessageFieldFocusNode? meessageFieldFocusNode;

  /// Optional parameter
  ///
  /// Primarily designed for block, UnBlock to User
  ///
  /// ```dart
  /// Future<ConversationVoidCallback>? onCallBlockUnblock
  /// ```
  ///
  /// Deprecated: The SDK now performs block/unblock internally.
  ///
  /// Use [onBlockUnblockSuccess] for app-side customizations after success.
  @Deprecated('SDK now blocks/unblocks internally; use onBlockUnblockSuccess')
  final FutureConversationVoidCallback? onCallBlockUnblock;

  /// Called **after** the SDK successfully blocks/unblocks a user.
  ///
  /// Use this for app-side customizations (toast/snackbar, analytics, navigation,
  /// refreshing your own state).
  ///
  /// - `didBlock`: true when block succeeded, false when unblock succeeded.
  final BlockUnblockSuccessCallback? onBlockUnblockSuccess;

  /// Required parameter
  ///
  /// Primarily designed for nagivating to Message screen
  ///
  /// ```dart
  /// ConversationVoidCallback? onCoverstaionStatus;
  /// ```
  ///
  /// `IsmChatConversationModel` gives data of current chat, it could be used for local storage or state variables
  final ConversationVoidCallback? onCoverstaionStatus;

  /// Optional parameter
  ///
  /// Primarily designed for check messgae info
  ///
  final IsmChatPageMessageAcknowldgeProperties? messageInfoAcknowldge;

  final Future<bool?>? Function(BuildContext, IsmChatConversationModel?)?
      isSendMediaAllowed;

  final MessageFutureCallback? onMessageTap;

  final MessageRecordsCallback? isShowMessageBlur;

  final Widget? loggedInUser;

  final IsmChatMessgaeStatusProperties? messageStatus;

  final Widget? textFieldActions;

  /// Input formatters for the message composer field.
  ///
  /// Example:
  /// ```dart
  /// inputFormatters: [
  ///   FilteringTextInputFormatter.deny(RegExp(r'\\n')),
  /// ],
  /// ```
  final List<TextInputFormatter>? inputFormatters;

  /// Whether selection handles/copy-paste interaction is enabled
  /// in the message composer field.
  final bool enableInteractiveSelection;

  /// Custom context menu builder for the message composer field.
  ///
  /// Useful for custom copy/paste menus on iOS/Android/Desktop.
  final EditableTextContextMenuBuilder? contextMenuBuilder;

  /// Hint text for the message input field.
  ///
  /// Defaults to [IsmChatStrings.hintText] when null.
  final String? messageInputHintText;

  final bool? Function(
          BuildContext, IsmChatConversationModel?, IsmChatMessageModel)?
      shouldShowHoverHold;

  final String? backgroundImageUrl;

  final MessageCallback? canReplayMessage;

  /// Configurable interval for periodic conversation details API calls.
  ///
  /// This duration determines how frequently the conversation details
  /// are fetched from the API to keep the conversation data up-to-date.
  ///
  /// Defaults to 1 minute (`Duration(minutes: 1)`).
  ///
  /// Example:
  /// ```dart
  /// IsmChatPageProperties(
  ///   conversationDetailsApiInterval: Duration(seconds: 30), // Every 30 seconds
  /// )
  /// ```
  final Duration conversationDetailsApiInterval;

  /// Enable paid media handling for external processing.
  ///
  /// When enabled, selected media (images/videos) will be delegated to external handler
  /// via [IsmChat.i.onPaidMediaSend] when user clicks send button, instead of being
  /// sent through the normal SDK flow.
  ///
  /// Defaults to `false`.
  ///
  /// Example:
  /// ```dart
  /// IsmChatPageProperties(
  ///   enablePaidMediaHandling: true,
  /// )
  /// ```
  ///
  /// **Note:** When enabled, you must set the delegate callback:
  /// - [IsmChat.i.onPaidMediaSend] - Called when user clicks send with selected media.
  ///   The delegate should show paid/free screen and send message from outside SDK.
  final bool enablePaidMediaHandling;

  /// Customize the avatar/profile UI shown inside a **contact message bubble**.
  ///
  /// This is used by `IsmChatContactMessage` (custom type: contact) to render
  /// each contact's picture. Return `null` to fall back to the SDK default
  /// avatar (`IsmChatImage.profile` / placeholder asset).
  ///
  /// Note: This does not affect the main message sender profile; for that use
  /// [messageSenderProfileBuilder].
  final ContactMessageAvatarBuilder? contactMessageAvatarBuilder;

  /// Icon widget for **play** in voice message button.
  ///
  /// If null, SDK uses the default `Icons.play_arrow`.
  final Widget? voiceMessagePlayIcon;

  /// Icon widget for **pause** in voice message button.
  ///
  /// If null, SDK uses the default `Icons.pause`.
  final Widget? voiceMessagePauseIcon;

  /// Icon/widget shown while voice message is loading/configuring.
  ///
  /// If null, SDK uses a small `CircularProgressIndicator`.
  final Widget? voiceMessageLoadingIcon;

  /// Waveform/bar color for voice messages sent by me.
  ///
  /// Used by the cached noise widget created in `IsmChatPageController.getNoise`.
  /// If null, SDK defaults to white.
  final Color? voiceMessageWaveColorMe;

  /// Waveform/bar color for voice messages sent by opponent.
  ///
  /// If null, SDK defaults to grey.
  final Color? voiceMessageWaveColorOpponent;

  /// Moving progress overlay color for voice messages sent by me.
  ///
  /// If null, SDK derives it from `meBgColor` with opacity.
  final Color? voiceMessageProgressOverlayColorMe;

  /// Moving progress overlay color for voice messages sent by opponent.
  ///
  /// If null, SDK derives it from `opponentBgColor` with opacity.
  final Color? voiceMessageProgressOverlayColorOpponent;

  /// Called when user taps the **1-1 chat** (non-group) profile image or name
  /// inside `IsmChatConverstaionInfoView`.
  ///
  /// Use this when you want to open your app-side user profile screen.
  /// If null, SDK keeps its existing behavior (e.g. opens profile image preview).
  final ConversationVoidCallback? onUserConversationInfoTap;
}
