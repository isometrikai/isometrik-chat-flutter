import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

typedef IsmChatMessageMap = Map<dynamic, dynamic>;

typedef IsmChatConversationMap = String;

typedef IsmChatMessages = Map<String, IsmChatMessageModel>;

typedef ConversationCardCallback = Widget Function(
  BuildContext,
  IsmChatConversationModel?,
  int,
);

typedef ConversationWidgetCallback = Widget? Function(
  BuildContext,
  IsmChatConversationModel?,
  String,
);

typedef UserDetailsWidgetCallback = Widget? Function(
  BuildContext,
  UserDetails,
);

typedef WidgetCallback = Widget? Function(
  BuildContext,
  IsmChatConversationModel?,
);

typedef PopupItemListCallback = List<IsmChatPopupMenuItem> Function(
  BuildContext,
  IsmChatConversationModel?,
);

typedef ConversationVoidCallback = void Function(
  BuildContext,
  IsmChatConversationModel?,
);

typedef FutureConversationVoidCallback = Future<bool> Function(
  BuildContext,
  IsmChatConversationModel,
  bool,
);

typedef ConversationStringCallback = String? Function(
  BuildContext,
  IsmChatConversationModel?,
  String,
);

typedef UserDetailsStringCallback = String? Function(
  BuildContext,
  UserDetails?,
);

typedef MessageWidgetBuilder = Widget? Function(
  BuildContext,
  IsmChatMessageModel,
  IsmChatCustomMessageType,
  bool,
);

typedef MessageSenderInfoBuilder = Widget? Function(
  BuildContext,
  IsmChatMessageModel,
  IsmChatConversationModel?,
);

typedef MessageSenderInfoCallback = String? Function(
  BuildContext,
  IsmChatMessageModel,
  IsmChatConversationModel?,
);

typedef ConversationWidgetBuilder = Widget? Function(
  BuildContext,
  IsmChatConversationModel?,
  bool,
);

typedef ConversationPredicate = bool Function(IsmChatConversationModel?);

typedef MeessageFieldFocusNode = void Function(
  BuildContext,
  IsmChatConversationModel?,
  bool,
);

typedef ConversationParser = (IsmChatConversationModel, bool)? Function(
  IsmChatConversationModel?,
  Map<String, dynamic>,
);

typedef InternetFileProgress = void Function(
  int receivedLength,
  int contentLength,
);

typedef IsmChatConversationModifier = Future<IsmChatConversationModel> Function(
  IsmChatConversationModel?,
);

typedef NotificaitonCallback = void Function(
  String,
  String,
  Map<String, dynamic>,
);

typedef MessageFutureCallback = Future<
        ({
          Map<String, dynamic>? metaData,
          bool shouldUpdateMessage,
          bool shouldGoToMediaPreview
        })>
    Function(
  BuildContext,
  IsmChatMessageModel,
  IsmChatConversationModel?,
);

typedef MessageCallback = bool Function(
  IsmChatMessageModel,
);

typedef ConversationCallback = bool Function(
  BuildContext,
  IsmChatConversationModel?,
);

typedef ResponseCallback = void Function(
  IsmChatResponseModel?,
  String,
);

typedef SortingConversationCallback = String Function();

typedef ConnectionStateCallback = void Function(
  IsmChatConnectionState,
);

typedef SendMessageCallback = bool Function(
  BuildContext,
  IsmChatConversationModel?,
  IsmChatCustomMessageType,
);

typedef ConditionConversationCallback = bool Function(
  BuildContext,
  IsmChatConversationModel?,
);
typedef StringConversationCallback = String Function(
  BuildContext,
  IsmChatConversationModel?,
);
typedef WidgetConversationCallback = Widget Function(
  BuildContext,
  IsmChatConversationModel?,
);

typedef ConditionConversationCustomeTypeCallback = Future<bool?>? Function(
  BuildContext,
  IsmChatConversationModel?,
  IsmChatCustomMessageType,
);

typedef ConditionCallback = void Function(bool);

typedef MessageRecordsCallback
    = ({double sigmaX, double sigmaY, bool shouldBlured}) Function(
  BuildContext,
  IsmChatMessageModel,
);

typedef NotificationBodyCallback = String Function(
    String, IsmChatCustomMessageType);

/// Callback for handling paid media when user clicks send.
///
/// This callback is invoked when user clicks send button with selected media
/// (images or videos) and paid media handling is enabled. The callback receives:
/// - [BuildContext] - The current build context
/// - [IsmChatConversationModel] - The current conversation
/// - [List<WebMediaModel>] - The selected media (images and/or videos)
///
/// Return `true` to indicate the delegate handled the media, `false` otherwise.
/// If `true` is returned, the SDK will not proceed with normal media sending.
/// The delegate should show paid/free screen and send message from outside SDK.
typedef PaidMediaSendCallback = Future<bool> Function(
  BuildContext,
  IsmChatConversationModel?,
  List<WebMediaModel>,
);
