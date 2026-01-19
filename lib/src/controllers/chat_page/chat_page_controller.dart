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

/// A GetxController that provides common functionality for Isometrik Chat Flutter.
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
  IsmChatPageController(this.viewModel);
  final IsmChatPageViewModel viewModel;

  IsmChatConversationsController get conversationController =>
      IsmChatUtility.conversationController;

  IsmChatCommonController get commonController =>
      Get.find<IsmChatCommonController>();

  bool get controllerIsRegister => IsmChatUtility.chatPageControllerRegistered;
}
