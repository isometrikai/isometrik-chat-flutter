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
part 'delegate/delegate_paid_media.dart';
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
part 'mixins/paid_media_operations.dart';
part 'mixins/cleanup_operations.dart';
part 'mixins/update_operations.dart';

/// The main class for interacting with the Isometrik Flutter Chat SDK.
///
/// This class serves as the public API entry point for the SDK. It uses the
/// mixin pattern to compose functionality from 11 focused mixins, each
/// handling a specific domain of operations.
///
/// **Architecture:**
/// - Uses delegate pattern: delegates implementation to [IsmChatDelegate]
/// - Uses mixin pattern: composes 11 mixins for functionality
/// - Singleton pattern: single instance accessible via [IsmChat.i]
///
/// **Usage:**
/// ```dart
/// // Initialize the SDK
/// await IsmChat.i.initialize(
///   communicationConfig: config,
///   kNavigatorKey: navigatorKey,
/// );
///
/// // Use SDK methods
/// await IsmChat.i.sendMessage(...);
/// final conversations = await IsmChat.i.getAllConversationFromDB();
/// ```
///
/// **Mixins:**
/// - [IsmChatInitializationMixin] - SDK initialization
/// - [IsmChatPropertiesMixin] - Configuration getters
/// - [IsmChatMqttOperationsMixin] - MQTT operations
/// - [IsmChatUiOperationsMixin] - UI state management
/// - [IsmChatConversationOperationsMixin] - Conversation CRUD
/// - [IsmChatUserOperationsMixin] - User management
/// - [IsmChatMessageOperationsMixin] - Message operations
/// - [IsmChatNavigationOperationsMixin] - External navigation
/// - [IsmChatNotificationOperationsMixin] - Push notifications
/// - [IsmChatCleanupOperationsMixin] - Resource cleanup
/// - [IsmChatUpdateOperationsMixin] - Chat page updates
///
/// See [ARCHITECTURE.md] for detailed architecture documentation.
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
        IsmChatPaidMediaOperationsMixin,
        IsmChatCleanupOperationsMixin,
        IsmChatUpdateOperationsMixin {
  /// Factory constructor for creating a new instance of [IsmChat].
  ///
  /// Returns the singleton instance [instance].
  ///
  /// **Example:**
  /// ```dart
  /// final chat = IsmChat(); // Returns IsmChat.i
  /// ```
  factory IsmChat() => instance;

  /// Private constructor for creating a new instance of [IsmChat].
  ///
  /// This constructor is private to enforce the singleton pattern.
  /// Use [IsmChat.i] or [factory IsmChat()] to access the instance.
  ///
  /// **Parameters:**
  /// - `_delegate`: The delegate instance that handles implementation.
  IsmChat._(this._delegate);

  /// The delegate used by this instance of [IsmChat].
  ///
  /// This delegate handles all implementation details, allowing [IsmChat]
  /// to maintain a clean public API while delegating actual work to
  /// [IsmChatDelegate].
  ///
  /// **Note:** This field overrides a getter from the mixins, hence the
  /// `@override` annotation.
  @override
  final IsmChatDelegate _delegate;

  /// The static instance of [IsmChat].
  ///
  /// This is the primary way to access the SDK. Use `IsmChat.i` to call
  /// SDK methods.
  ///
  /// **Example:**
  /// ```dart
  /// await IsmChat.i.initialize(...);
  /// ```
  static IsmChat i = IsmChat._(IsmChatDelegate());

  /// The static instance of [IsmChat].
  ///
  /// Alias for [i]. Both [i] and [instance] refer to the same singleton.
  static IsmChat instance = i;

  /// Whether the MQTT controller has been initialized.
  ///
  /// This flag is set to `true` after [IsmChatInitializationMixin.initialize]
  /// completes successfully. It's used to ensure the SDK is initialized
  /// before certain operations are performed.
  ///
  /// **Note:** This is a static field, so it's shared across all instances
  /// (though there should only be one instance due to singleton pattern).
  static bool _initialized = false;
}
