import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

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
    this.onForwardTap,
    this.emojiIcon,
    this.meessageFieldFocusNode,
    this.messageFieldSuffix,
    this.onCallBlockUnblock,
    this.onCoverstaionStatus,
    this.messageSenderProfileBuilder,
    this.messageSenderNameBuilder,
    this.messageSenderName,
    this.messageSenderProfileUrl,
    this.messageInfoAcknowldge,
    this.isSendMediaAllowed,
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
  /// `IsmChatConversationModel` gives data of current chat, it could be used for local storage or state variables
  final FutureConversationVoidCallback? onCallBlockUnblock;

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

  final Future<bool?>? Function(BuildContext, IsmChatConversationModel)?
      isSendMediaAllowed;
}
