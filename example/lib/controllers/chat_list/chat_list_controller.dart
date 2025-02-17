import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/main.dart';
import 'package:isometrik_chat_flutter_example/models/models.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';
import 'package:isometrik_chat_flutter_example/utilities/config.dart';
import 'package:isometrik_chat_flutter_example/utilities/device_config.dart';

import '../../utilities/local_notice_service.dart';

class ChatListController extends GetxController {
  UserDetailsModel userDetails = UserDetailsModel();

  bool isBottomVisibile = true;

  final deviceConfig = Get.find<DeviceConfig>();

  @override
  void onInit() {
    super.onInit();
    userDetails = AppConfig.userDetail!;
    if (!kIsWeb) {
      subscribeToTopic();
    }
    initialize();
  }

  void initialize() async {
    IsmChatLog.error(AppConfig.userDetail?.toJson());
    await IsmChat.i.initialize(
      IsmChatCommunicationConfig(
        userConfig: IsmChatUserConfig(
          userToken: AppConfig.userDetail?.userToken ?? '',
          userId: AppConfig.userDetail?.userId ?? '',
          userEmail: AppConfig.userDetail?.email ?? '',
          userProfile: '',
        ),
        mqttConfig: const IsmChatMqttConfig(
          hostName: kIsWeb ? Constants.hostnameForWeb : Constants.hostname,
          port: kIsWeb ? Constants.portForWeb : Constants.port,
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
      mqttProperties: IsmMqttProperties(
        shouldSetupMqtt: false,
        autoReconnect: false,
      ),
      showNotification: (title, body, conversataionId) {
        LocalNoticeService().showFlutterNotification(
          title,
          body,
          conversataionId: conversataionId,
        );
      },
    );
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
    IsmChatUtility.showLoader();
    await unSubscribeToTopic();
    await dbWrapper?.deleteChatLocalDb();
    await IsmChat.i.logout();
    IsmChatUtility.closeLoader();
    Get.offAllNamed(AppRoutes.login);
  }

  // void callFuncation() async {
  //   await Future.delayed(const Duration(seconds: 5));
  //   firstUpdateWidget = true;
  //   IsmChatApp.updateChatPageController();
  // }
}
