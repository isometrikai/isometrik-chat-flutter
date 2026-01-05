import 'dart:async';

import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/main.dart';
import 'package:isometrik_chat_flutter_example/models/models.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';
import 'package:isometrik_chat_flutter_example/utilities/local_notice_service.dart';
import 'package:isometrik_chat_flutter_example/utilities/utilities.dart';

class ChatListController extends GetxController {
  UserDetailsModel userDetails = UserDetailsModel();

  bool isBottomVisibile = true;

  final deviceConfig = Get.find<DeviceConfig>();

  /// Timer to update lastActiveTimestamp every 30 seconds
  Timer? _lastActiveTimer;

  @override
  void onInit() {
    super.onInit();
    userDetails = AppConfig.userDetail!;
    if (!kIsWeb) {
      subscribeToTopic();
    }
    initialize();
  }

  @override
  void onClose() {
    _stopLastActiveTimer();
    super.onClose();
  }

  /// Starts a timer to update lastActiveTimestamp every 30 seconds
  /// Only starts if user is logged in and SDK is initialized
  void _startLastActiveTimer() {
    // Check if user is logged in and SDK is initialized
    if (!_isUserLoggedIn()) {
      return;
    }

    // Update immediately on start
    IsmChat.i.updateLastActiveTimestamp();

    // Then update every 30 seconds
    _lastActiveTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        // Check again before each update
        if (!_isUserLoggedIn()) {
          timer.cancel();
          _lastActiveTimer = null;
          return;
        }
        IsmChat.i.updateLastActiveTimestamp(isLoading: false);
      },
    );
  }

  /// Stops the last active timer
  void _stopLastActiveTimer() {
    _lastActiveTimer?.cancel();
    _lastActiveTimer = null;
  }

  /// Checks if user is logged in and SDK is initialized
  bool _isUserLoggedIn() {
    try {
      // Check if SDK is initialized
      if (!IsmChatConfig.configInitilized) {
        return false;
      }

      // Check if user config exists and has valid userId
      final userId = IsmChatConfig.communicationConfig.userConfig.userId;
      if (userId.isEmpty) {
        return false;
      }

      // Check if conversation controller is registered (indicates active session)
      if (!IsmChatUtility.conversationControllerRegistered) {
        return false;
      }

      return true;
    } catch (e) {
      // If any error occurs, assume user is not logged in
      return false;
    }
  }

  void initialize() async {
    IsmChatLog.error(AppConfig.userDetail?.toJson());
    await IsmChat.i.initialize(
      messageEncrypted: true,
      kNavigatorKey: kNavigatorKey,
      communicationConfig: IsmChatCommunicationConfig(
        userConfig: IsmChatUserConfig(
          userToken: AppConfig.userDetail?.userToken ?? '',
          userId: AppConfig.userDetail?.userId ?? '',
          userEmail: AppConfig.userDetail?.email ?? '',
          userProfile: '',
        ),
        mqttConfig: const IsmChatMqttConfig(
          hostName: kIsWeb
              ? Constants.hostnameForWeb
              : Constants.hostname, // Constants.hostname,
          port: kIsWeb ? Constants.portForWeb : Constants.port, // Constants.app
          useWebSocket: kIsWeb,
          websocketProtocols: [if (kIsWeb) 'mqtt'],
        ),
        projectConfig: IsmChatProjectConfig(
          accountId: Constants.accountId,
          appSecret: Constants.appSecret,
          userSecret: Constants.userSecret,
          keySetId: Constants.keysetId,
          licenseKey: Constants.licenseKey,
          projectId: Constants.projectId,
          deviceId: deviceConfig.deviceId ?? '',
        ),
      ),
      showNotification: (title, body, data) {
        if (IsmChatResponsive.isMobile(kNavigatorKey.currentContext!)) {
          LocalNoticeService().showFlutterNotification(
            title,
            body,
            conversataionId: data['conversationId'] as String? ?? '',
          );
        } else {
          ElegantNotification(
            icon: Icon(
              Icons.message_rounded,
              color: IsmChatConfig.chatTheme.primaryColor ?? Colors.blue,
            ),
            width: IsmChatDimens.twoHundredFifty,
            animation: AnimationType.fromRight,
            title: Text(title),
            description: Expanded(
              child: Text(
                body,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            progressIndicatorColor:
                IsmChatConfig.chatTheme.primaryColor ?? Colors.blue,
          ).show(kNavigatorKey.currentContext!);
        }
      },
    );

    // Start timer after successful initialization
    _startLastActiveTimer();
  }

  subscribeToTopic() async {
    await FirebaseMessaging.instance
        .subscribeToTopic('chat-${userDetails.userId}');
  }

  Future<void> unSubscribeToTopic() async {
    if (!kIsWeb) {
      try {
        await FirebaseMessaging.instance.unsubscribeFromTopic(
          'chat-${userDetails.userId}',
        );
      } catch (_) {}
    }
  }

  void onSignOut() async {
    // Stop timer before logout
    _stopLastActiveTimer();

    IsmChatUtility.showLoader();
    await unSubscribeToTopic();
    await dbWrapper?.deleteChatLocalDb();
    await IsmChat.i.logout();
    IsmChatUtility.closeLoader();
    RouteManagement.offToLogin();
  }

  // void callFuncation() async {
  //   await Future.delayed(const Duration(seconds: 5));
  //   firstUpdateWidget = true;
  //   IsmChatApp.updateChatPageController();
  // }
}
