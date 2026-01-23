import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

part 'mixins/variables.dart';
part 'mixins/lifecycle_initialization.dart';
part 'mixins/connectivity.dart';
part 'mixins/scroll_listeners.dart';
part 'mixins/widget_rendering.dart';
part 'mixins/background_assets.dart';
part 'mixins/user_operations.dart';
part 'mixins/conversation_operations.dart';
part 'mixins/contact_operations.dart';
part 'mixins/forward_operations.dart';
part 'mixins/public_open_conversations.dart';
part 'mixins/observer_operations.dart';
part 'mixins/navigation.dart';
part 'mixins/pending_messages.dart';
part 'mixins/story_operations.dart';

/// Controller for managing the conversations list screen.
///
/// This controller handles all functionality related to displaying and managing
/// the list of conversations. It uses the mixin pattern extensively, composing
/// 15 focused mixins to organize functionality.
///
/// **Architecture:**
/// - **Size**: 56 lines (reduced from 1,989 lines - 97.2% reduction)
/// - **Mixins**: 15 mixins organized by functionality
/// - **Pattern**: Mixin composition pattern
///
/// **Key Responsibilities:**
/// - Conversation list management
/// - Search and filtering conversations
/// - Group operations
/// - Story operations
/// - Connectivity management
/// - Conversation CRUD operations
/// - Contact operations
/// - Forward operations
/// - Observer operations
/// - Navigation
/// - Pending message handling
///
/// **Mixins:**
/// - [IsmChatConversationsVariablesMixin] - State variables
/// - [IsmChatConversationsLifecycleInitializationMixin] - Lifecycle management
/// - [IsmChatConversationsConnectivityMixin] - Network connectivity
/// - [IsmChatConversationsScrollListenersMixin] - Scroll handling
/// - [IsmChatConversationsWidgetRenderingMixin] - Widget rendering
/// - [IsmChatConversationsBackgroundAssetsMixin] - Background assets
/// - [IsmChatConversationsUserOperationsMixin] - User operations
/// - [IsmChatConversationsConversationOperationsMixin] - Conversation operations
/// - [IsmChatConversationsContactOperationsMixin] - Contact operations
/// - [IsmChatConversationsForwardOperationsMixin] - Forward operations
/// - [IsmChatConversationsPublicOpenConversationsMixin] - Public conversations
/// - [IsmChatConversationsObserverOperationsMixin] - Observer operations
/// - [IsmChatConversationsNavigationMixin] - Navigation
/// - [IsmChatConversationsPendingMessagesMixin] - Pending messages
/// - [IsmChatConversationsStoryOperationsMixin] - Story operations
///
/// **Usage:**
/// ```dart
/// // Get controller instance
/// final controller = Get.find<IsmChatConversationsController>();
///
/// // Get conversations
/// await controller.getChatConversation();
///
/// // Access conversations list
/// final conversations = controller.conversations;
/// ```
///
/// **Dependencies:**
/// - [IsmChatConversationsViewModel] - View model for business logic
///
/// **See Also:**
/// - [MODULE_CONTROLLERS.md] - Controllers documentation
/// - [REFACTORING_CHAT_CONVERSATIONS_CONTROLLER.md] - Refactoring documentation
/// - [ARCHITECTURE.md] - Architecture documentation
class IsmChatConversationsController extends GetxController
    with
        IsmChatConversationsVariablesMixin,
        IsmChatConversationsLifecycleInitializationMixin,
        IsmChatConversationsConnectivityMixin,
        IsmChatConversationsScrollListenersMixin,
        IsmChatConversationsWidgetRenderingMixin,
        IsmChatConversationsBackgroundAssetsMixin,
        IsmChatConversationsUserOperationsMixin,
        IsmChatConversationsConversationOperationsMixin,
        IsmChatConversationsContactOperationsMixin,
        IsmChatConversationsForwardOperationsMixin,
        IsmChatConversationsPublicOpenConversationsMixin,
        IsmChatConversationsObserverOperationsMixin,
        IsmChatConversationsNavigationMixin,
        IsmChatConversationsPendingMessagesMixin,
        IsmChatConversationsStoryOperationsMixin {
  /// Creates a new instance of [IsmChatConversationsController].
  ///
  /// **Parameters:**
  /// - `_viewModel`: The view model instance that provides business logic
  ///   and data access for this controller.
  IsmChatConversationsController(this._viewModel);

  /// The view model instance for this controller.
  ///
  /// This is private to enforce encapsulation. Use the [viewModel] getter
  /// to access it from mixins.
  final IsmChatConversationsViewModel _viewModel;

  /// Gets the view model instance.
  ///
  /// This is exposed as a public getter so mixins can access the view model
  /// for business logic and data access operations.
  ///
  /// **Returns:**
  /// - [IsmChatConversationsViewModel]: The view model instance.
  IsmChatConversationsViewModel get viewModel => _viewModel;
}
