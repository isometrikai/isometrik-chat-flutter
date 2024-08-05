import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

typedef ConversationCardCallback = Widget Function(
  BuildContext,
  IsmChatConversationModel,
  int,
);

typedef ConversationWidgetCallback = Widget? Function(
  BuildContext,
  IsmChatConversationModel,
  String,
);

typedef UserDetailsWidgetCallback = Widget? Function(
  BuildContext,
  UserDetails,
);

typedef WidgetCallback = Widget? Function(
  BuildContext,
  IsmChatConversationModel,
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
  IsmChatConversationModel,
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
    IsmChatConversationModel, Map<String, dynamic>);

typedef InternetFileProgress = void Function(
  int receivedLength,
  int contentLength,
);

typedef IsmChatConversationModifier = Future<IsmChatConversationModel> Function(
    IsmChatConversationModel);

typedef NotificaitonCallback = void Function(
  String,
  String,
  String,
);
