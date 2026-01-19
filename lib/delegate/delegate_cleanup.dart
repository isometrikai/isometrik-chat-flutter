part of '../isometrik_chat_flutter.dart';

/// Database and cleanup mixin for IsmChatDelegate.
///
/// This mixin contains methods related to database operations, cleanup,
/// and resource management.
mixin IsmChatDelegateCleanupMixin {
  /// Logs out and cleans up all resources.
  Future<void> logout() async {
    try {
      await IsmChatConfig.dbWrapper?.deleteChatLocalDb();
      await Future.wait([
        Get.delete<IsmChatConversationsController>(
            tag: IsmChat.i.chatListPageTag, force: true),
        Get.delete<IsmChatCommonController>(force: true),
        Get.delete<IsmChatMqttController>(force: true),
      ]);
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }

  /// Disconnects from MQTT.
  Future<void> disconnectMQTT() async {
    if (Get.isRegistered<IsmChatMqttController>()) {
      final mqttController = Get.find<IsmChatMqttController>();
      if (mqttController.connectionState == IsmChatConnectionState.connected) {
        mqttController.mqttHelper.disconnect();
      }
    }
  }

  /// Clears the local chat database.
  Future<void> clearChatLocalDb() async {
    await IsmChatConfig.dbWrapper?.clearChatLocalDb();
  }

  /// Deletes a chat conversation.
  Future<void> deleteChat(
    String conversationId, {
    bool deleteFromServer = true,
    bool shouldUpdateLocal = true,
  }) async {
    await IsmChatUtility.conversationController.deleteChat(
      conversationId,
      deleteFromServer: deleteFromServer,
      shouldUpdateLocal: shouldUpdateLocal,
    );
  }

  /// Deletes a chat from the database.
  Future<bool> deleteChatFormDB(String isometrickChatId,
          {String conversationId = ''}) async =>
      await Get.find<IsmChatMqttController>()
          .deleteChatFormDB(isometrickChatId, conversationId: conversationId);

  /// Exits a group conversation.
  Future<void> exitGroup({
    required int adminCount,
    required bool isUserAdmin,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.leaveGroup(
        adminCount: adminCount,
        isUserAdmin: isUserAdmin,
      );
    }
  }

  /// Clears all messages from a conversation.
  Future<void> clearAllMessages(
    String conversationId, {
    bool fromServer = true,
  }) async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      await IsmChatUtility.chatPageController.clearAllMessages(
        conversationId,
        fromServer: fromServer,
      );
    }
  }

  /// Deletes the chat page controller.
  Future<void> deleteChatPageController() async {
    try {
      if (IsmChatUtility.chatPageControllerRegistered) {
        await Get.delete<IsmChatPageController>(
            tag: IsmChat.i.chatPageTag, force: true);
      }
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }

  /// Deletes the conversation controller.
  Future<void> deleteConversationController() async {
    try {
      if (IsmChatUtility.conversationControllerRegistered) {
        await Get.delete<IsmChatConversationsController>(
            tag: IsmChat.i.chatListPageTag, force: true);
      }
    } catch (e, st) {
      IsmChatLog.error('Error $e stackTree $st');
    }
  }
}
