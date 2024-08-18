import 'package:isometrik_chat_flutter/src/res/config/config.dart';

///[IsmChatCommunicationConfig] class will be used to store all the configurations required to setup the communication connection
class IsmChatCommunicationConfig {
  IsmChatCommunicationConfig({
    required this.userConfig,
    required this.projectConfig,
    this.mqttConfig,
    String? username,
    String? password,
  })  : username =
            username ?? '2${projectConfig.accountId}${projectConfig.projectId}',
        password =
            password ?? '${projectConfig.licenseKey}${projectConfig.keySetId}';

  final IsmChatUserConfig userConfig;
  final IsmChatProjectConfig projectConfig;
  final IsmChatMqttConfig? mqttConfig;
  final String? username;
  final String? password;
}
