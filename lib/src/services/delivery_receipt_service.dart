import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/controllers/mqtt/mqtt_controller.dart';
import 'package:isometrik_chat_flutter/src/repositories/mqtt_repository.dart';
import 'package:isometrik_chat_flutter/src/utilities/chat_log.dart';
import 'package:isometrik_chat_flutter/src/utilities/config/chat_config.dart';
import 'package:isometrik_chat_flutter/src/utilities/delivery_receipt_bridge.dart';

/// Background delivery receipt orchestration.
///
/// Reuses existing SDK APIs only:
/// - [IsmChatMqttRepository.pingMessageDelivered] → `PUT /chat/indicator/delivered`
/// - [IsmChatMqttController.getUserMessges] → reconciliation on foreground/init
class IsmChatDeliveryReceiptService {
  IsmChatDeliveryReceiptService._();

  static final IsmChatMqttRepository _mqttRepository = IsmChatMqttRepository();

  static bool _reconcileInFlight = false;

  /// Ack delivery via the existing delivered-indicator API.
  static Future<void> ackDelivered({
    required String conversationId,
    required String messageId,
    bool enqueueNative = false,
  }) async {
    if (conversationId.isEmpty || messageId.isEmpty) return;

    await _mqttRepository.pingMessageDelivered(
      conversationId: conversationId,
      messageId: messageId,
    );

    if (enqueueNative) {
      await IsmChatDeliveryReceiptBridge.enqueueNativeAck(
        messageId: messageId,
        conversationId: conversationId,
      );
    }
  }

  /// Safety-net reconciliation when app returns to foreground.
  ///
  /// Delegates to the existing [IsmChatMqttController.getUserMessges] flow which
  /// already pings delivery for messages not yet marked delivered to self.
  static Future<void> reconcileUndelivered() async {
    if (!IsmChatConfig.configInitilized) return;
    if (_reconcileInFlight) return;
    if (!Get.isRegistered<IsmChatMqttController>()) return;

    _reconcileInFlight = true;
    try {
      final userId = IsmChatConfig.communicationConfig.userConfig.userId;
      if (userId.isEmpty) return;

      await Get.find<IsmChatMqttController>().getUserMessges(
        senderIds: [userId],
        senderIdsExclusive: true,
        limit: 50,
      );
    } catch (e, st) {
      IsmChatLog.error('reconcileUndelivered $e', st);
    } finally {
      _reconcileInFlight = false;
    }
  }

  /// Sync native credentials so killed-state push can ack delivery.
  static Future<void> syncForBackgroundDelivery() async {
    await IsmChatDeliveryReceiptBridge.syncNativeCredentials();
  }
}
