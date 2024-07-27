import 'package:mqtt_client/mqtt_client.dart';

class IsmChatMqttConfig {
  const IsmChatMqttConfig({
    required this.hostName,
    required this.port,
    this.useWebSocket = false,
    this.websocketProtocols = MqttClientConstants.protocolsSingleDefault,
  });
  final String hostName;
  final int port;
  final bool useWebSocket;
  final List<String> websocketProtocols;
}
