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
  IsmChatConversationsController(this._viewModel);
  final IsmChatConversationsViewModel _viewModel;

  /// Gets the view model instance.
  /// This is exposed for mixins to access the view model.
  IsmChatConversationsViewModel get viewModel => _viewModel;
}
