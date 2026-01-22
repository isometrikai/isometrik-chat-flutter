library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';

export 'package:mqtt_helper/mqtt_helper.dart';

export 'src/app/app.dart';
export 'src/controllers/controllers.dart';
export 'src/data/data.dart';
export 'src/models/models.dart';
export 'src/repositories/repositories.dart';
export 'src/res/properties/properties.dart';
export 'src/res/res.dart';
export 'src/utilities/utilities.dart';
export 'src/view_models/view_models.dart';
export 'src/views/views.dart';
export 'src/widgets/widgets.dart';

part 'delegate/isometrik_chat_flutter_delegate.dart';
part 'delegate/delegate_cleanup.dart';
part 'delegate/delegate_conversation.dart';
part 'delegate/delegate_initialization.dart';
part 'delegate/delegate_message.dart';
part 'delegate/delegate_mqtt.dart';
part 'delegate/delegate_navigation.dart';
part 'delegate/delegate_notification.dart';
part 'delegate/delegate_ui.dart';
part 'delegate/delegate_user.dart';

part 'mixins/initialization.dart';
part 'mixins/properties.dart';
part 'mixins/mqtt_operations.dart';
part 'mixins/ui_operations.dart';
part 'mixins/conversation_operations.dart';
part 'mixins/user_operations.dart';
part 'mixins/message_operations.dart';
part 'mixins/navigation_operations.dart';
part 'mixins/notification_operations.dart';
part 'mixins/cleanup_operations.dart';
part 'mixins/update_operations.dart';

/// The main class for interacting with the Isometrik Flutter Chat SDK.
class IsmChat
    with
        IsmChatInitializationMixin,
        IsmChatPropertiesMixin,
        IsmChatMqttOperationsMixin,
        IsmChatUiOperationsMixin,
        IsmChatConversationOperationsMixin,
        IsmChatUserOperationsMixin,
        IsmChatMessageOperationsMixin,
        IsmChatNavigationOperationsMixin,
        IsmChatNotificationOperationsMixin,
        IsmChatCleanupOperationsMixin,
        IsmChatUpdateOperationsMixin {
  /// Factory constructor for creating a new instance of [IsmChat].
  factory IsmChat() => instance;

  /// Private constructor for creating a new instance of [IsmChat].
  IsmChat._(this._delegate);

  /// The delegate used by this instance of [IsmChat].
  @override
  final IsmChatDelegate _delegate;

  /// The static instance of [IsmChat].
  static IsmChat i = IsmChat._(const IsmChatDelegate());

  /// The static instance of [IsmChat].
  static IsmChat instance = i;

  /// Whether the MQTT controller has been initialized.
  static bool _initialized = false;
}
