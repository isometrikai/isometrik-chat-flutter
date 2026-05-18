import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mixins/mqtt_event/utilities.dart';

/// Block/unblock mixin for IsmChatMqttEventMixin.
///
/// Option A: banner rows live in `messages`; MQTT updates user B via
/// [IsmChatBlockUnblockCoordinator.handleMqttEvent].
mixin IsmChatMqttEventBlockUnblockMixin {
  /// Handles a block user or unblock event (including user B when A blocks/unblocks).
  void handleBlockUserOrUnBlock(IsmChatMqttActionModel actionModel) async {
    final self = this;
    if (self is! IsmChatMqttEventUtilitiesMixin) return;

    final utils = self as IsmChatMqttEventUtilitiesMixin;
    final isInitiatedByMe =
        utils.isSenderMe(actionModel.initiatorDetails?.userId);

    if (isInitiatedByMe &&
        !IsmChatBlockUnblockCoordinator.isBlockAction(actionModel.action) &&
        !IsmChatBlockUnblockCoordinator.isUnblockAction(actionModel.action)) {
      return;
    }

    await IsmChatBlockUnblockCoordinator.handleMqttEvent(actionModel);
  }
}
