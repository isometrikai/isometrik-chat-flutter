import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_chat_flutter/src/utilities/blob_html.dart';
import 'package:isometrik_chat_flutter/src/views/chat_page/widget/profile_change.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdfx/pdfx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_compress/video_compress.dart';

part './mixins/get_message.dart';
part './mixins/group_admin.dart';
part './mixins/send_message.dart';
part './mixins/send_message_reactions.dart';
part './mixins/send_message_audio.dart';
part './mixins/send_message_location.dart';
part './mixins/send_message_contact.dart';
part './mixins/send_message_document.dart';
part './mixins/send_message_media.dart';
part './mixins/send_message_broadcast.dart';
part './mixins/send_message_core.dart';
part './mixins/show_dialog.dart';
part './mixins/taps_controller.dart';
part './mixins/variables.dart';
part './mixins/lifecycle_initialization.dart';
part './mixins/scroll_navigation.dart';
part './mixins/camera_operations.dart';
part './mixins/ui_state_management.dart';
part './mixins/utility_methods.dart';
part './mixins/contact_group_operations.dart';
part './mixins/message_operations.dart';
part './mixins/media_operations.dart';
part './mixins/message_management.dart';
part './mixins/block_unblock.dart';
part './mixins/other_operations.dart';

/// Controller for managing the chat page (individual conversation view).
///
/// This controller handles all functionality related to displaying and interacting
/// with a single chat conversation. It uses the mixin pattern extensively,
/// composing 25 focused mixins to organize functionality.
///
/// **Architecture:**
/// - **Size**: 98 lines (reduced from 2,038 lines - 95.2% reduction)
/// - **Mixins**: 25 mixins organized by functionality
/// - **Pattern**: Mixin composition pattern
///
/// **Key Responsibilities:**
/// - Message sending and receiving
/// - UI state management
/// - Media operations (camera, gallery, files)
/// - Scroll navigation
/// - Contact and group operations
/// - Message management (delete, forward, reply)
/// - Block/unblock functionality
/// - Voice messages
/// - Location sharing
///
/// **Mixins:**
/// - **Message Operations**: send_message, get_message, message_operations
/// - **UI Management**: ui_state_management, scroll_navigation
/// - **Media**: camera_operations, media_operations
/// - **Lifecycle**: lifecycle_initialization
/// - **Utilities**: utility_methods, contact_group_operations
/// - And 15 more...
///
/// **Usage:**
/// ```dart
/// // Get controller instance
/// final controller = Get.find<IsmChatPageController>();
///
/// // Send a message
/// await controller.sendMessage(text: 'Hello');
///
/// // Get messages
/// final messages = controller.messages;
/// ```
///
/// **Dependencies:**
/// - [IsmChatPageViewModel] - View model for business logic
/// - [IsmChatConversationsController] - Conversations controller
/// - [IsmChatCommonController] - Common controller
///
/// **See Also:**
/// - [MODULE_CONTROLLERS.md] - Controllers documentation
/// - [REFACTORING_CHAT_PAGE_CONTROLLER.md] - Refactoring documentation
/// - [ARCHITECTURE.md] - Architecture documentation
class IsmChatPageController extends GetxController
    with
        IsmChatPageSendMessageMixin,
        IsmChatPageSendMessageReactionsMixin,
        IsmChatPageSendMessageAudioMixin,
        IsmChatPageSendMessageLocationMixin,
        IsmChatPageSendMessageContactMixin,
        IsmChatPageSendMessageDocumentMixin,
        IsmChatPageSendMessageMediaMixin,
        IsmChatPageSendMessageBroadcastMixin,
        IsmChatPageSendMessageCoreMixin,
        IsmChatPageGetMessageMixin,
        IsmChatGroupAdminMixin,
        IsmChatShowDialogMixin,
        IsmChatTapsController,
        IsmChatPageVariablesMixin,
        IsmChatPageLifecycleInitializationMixin,
        IsmChatPageScrollNavigationMixin,
        IsmChatPageCameraOperationsMixin,
        IsmChatPageUiStateManagementMixin,
        IsmChatPageUtilityMethodsMixin,
        IsmChatPageContactGroupOperationsMixin,
        IsmChatPageMessageOperationsMixin,
        IsmChatPageMediaOperationsMixin,
        IsmChatPageMessageManagementMixin,
        IsmChatPageBlockUnblockMixin,
        IsmChatPageOtherOperationsMixin,
        GetTickerProviderStateMixin {
  /// Creates a new instance of [IsmChatPageController].
  ///
  /// **Parameters:**
  /// - `viewModel`: The view model instance that provides business logic
  ///   and data access for this controller.
  IsmChatPageController(this.viewModel);

  /// The view model instance for this controller.
  ///
  /// The view model provides business logic and coordinates with repositories
  /// for data access. It's exposed as a public getter so mixins can access it.
  final IsmChatPageViewModel viewModel;

  /// Gets the conversations controller instance.
  ///
  /// This provides access to the conversations controller, which is useful
  /// for operations that need to update the conversation list (e.g., after
  /// sending a message).
  ///
  /// **Returns:**
  /// - [IsmChatConversationsController]: The conversations controller instance.
  IsmChatConversationsController get conversationController =>
      IsmChatUtility.conversationController;

  /// Gets the common controller instance.
  ///
  /// The common controller provides shared functionality used across
  /// multiple controllers.
  ///
  /// **Returns:**
  /// - [IsmChatCommonController]: The common controller instance.
  IsmChatCommonController get commonController =>
      Get.find<IsmChatCommonController>();

  /// Checks if this controller is registered in GetX.
  ///
  /// This is useful for checking if the controller is available before
  /// performing operations that depend on it.
  ///
  /// **Returns:**
  /// - `bool`: `true` if the controller is registered, `false` otherwise.
  bool get controllerIsRegister => IsmChatUtility.chatPageControllerRegistered;
}
