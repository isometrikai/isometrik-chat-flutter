import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Syncs auth/config to native storage so push handlers can call the existing
/// `PUT /chat/indicator/delivered` API while Flutter is not running.
///
/// **Reuse:** Host apps set [appGroupId] once before SDK initialize on iOS.
/// Android reads from SharedPreferences written by the plugin.
class IsmChatDeliveryReceiptBridge {
  IsmChatDeliveryReceiptBridge._();

  static const MethodChannel _channel =
      MethodChannel('isometrik_chat_flutter/delivery_receipts');

  /// iOS App Group (`group.<bundle-id>`). Must match main app + NSE entitlements.
  static String? appGroupId;

  /// Persists credentials for native background delivery acks.
  static Future<void> syncNativeCredentials() async {
    if (kIsWeb) return;
    if (!IsmChatConfig.configInitilized) return;

    final config = IsmChatConfig.communicationConfig;
    final baseUrl = config.projectConfig.chatApisBaseUrl ??
        'https://apis.isometrik.ai';
    final userToken = config.userConfig.userToken;
    if (userToken.isEmpty) return;

    try {
      await _channel.invokeMethod<void>('syncDeliveryReceiptConfig', {
        'baseUrl': baseUrl,
        'userToken': userToken,
        'licenseKey': config.projectConfig.licenseKey,
        'appSecret': config.projectConfig.appSecret,
        'userId': config.userConfig.userId,
        'appGroupId': appGroupId ?? '',
      });
    } catch (e, st) {
      IsmChatLog.error('syncNativeCredentials $e', st);
    }
  }

  /// Clears native credentials on logout / SDK cleanup.
  static Future<void> clearNativeCredentials() async {
    if (kIsWeb) return;
    try {
      await _channel.invokeMethod<void>('clearDeliveryReceiptConfig');
    } catch (_) {}
  }

  /// Enqueues a native background ack (Android WorkManager). Optional safety net.
  static Future<void> enqueueNativeAck({
    required String messageId,
    required String conversationId,
  }) async {
    if (kIsWeb) return;
    if (messageId.isEmpty || conversationId.isEmpty) return;
    try {
      await _channel.invokeMethod<void>('ackDelivered', {
        'messageId': messageId,
        'conversationId': conversationId,
      });
    } catch (e, st) {
      IsmChatLog.error('enqueueNativeAck $e', st);
    }
  }
}
