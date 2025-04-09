import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

typedef IsmChatMessageMap = Map<dynamic, dynamic>;

typedef IsmChatConversationMap = String;

typedef IsmChatMessages = Map<String, IsmChatMessageModel>;

typedef ConversationCardCallback = Widget Function(
  BuildContext,
  IsmChatConversationModel,
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
  IsmChatConversationModel,
  bool,
);

typedef PopupItemListCallback = List<IsmChatPopupMenuItem> Function(
  BuildContext,
  IsmChatConversationModel,
);

typedef ConversationVoidCallback = void Function(
  BuildContext,
  IsmChatConversationModel,
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
  UserDetails,
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
  IsmChatConversationModel,
);

typedef MessageSenderInfoCallback = String? Function(
  BuildContext,
  IsmChatMessageModel,
  IsmChatConversationModel,
);

typedef ConversationWidgetBuilder = Widget? Function(
  BuildContext,
  IsmChatConversationModel,
  bool,
);

typedef ConversationPredicate = bool Function(IsmChatConversationModel);

typedef MeessageFieldFocusNode = void Function(
  BuildContext,
  IsmChatConversationModel,
  bool,
);

typedef ConversationParser = (IsmChatConversationModel, bool)? Function(
  IsmChatConversationModel,
  Map<String, dynamic>,
);

typedef InternetFileProgress = void Function(
  int receivedLength,
  int contentLength,
);

typedef IsmChatConversationModifier = Future<IsmChatConversationModel> Function(
  IsmChatConversationModel,
);

typedef NotificaitonCallback = void Function(
  String,
  String,
  String,
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
  IsmChatConversationModel,
);

typedef MessageCallback = bool Function(
  BuildContext,
  IsmChatMessageModel,
);

typedef ConversationCallback = bool Function(
  BuildContext,
  IsmChatConversationModel,
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
  IsmChatConversationModel,
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
  IsmChatConversationModel,
  IsmChatCustomMessageType,
);
