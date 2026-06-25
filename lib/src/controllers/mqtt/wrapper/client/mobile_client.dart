import 'package:isometrik_chat_flutter/src/controllers/mqtt/mqtt_helper.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

/// A helper class for connecting to an MQTT broker using the `mqtt_client` package.
///
/// This class provides a convenient way to set up an MQTT connection by creating an instance of `MqttServerClient` and configuring it with the provided `MqttConfig`.
class MqttHelperClient {
  late MqttServerClient _client;

  /// The underlying `MqttServerClient` instance.
  MqttServerClient get client => _client;

  // Sets up the MQTT connection using the provided configuration.
  ///
  /// Parameters:
  ///   - `config`: The configuration for the MQTT connection.
  ///
  /// Returns: The configured `MqttServerClient` instance.
  MqttServerClient setup(MqttConfig config) {
    var userIdentifier = config.projectConfig.userIdentifier;
    var deviceId = config.projectConfig.deviceId;
    var identifier = '$userIdentifier$deviceId';

    final attempts = config.maxAutoReconnectRetry < 1
        ? 1
        : config.maxAutoReconnectRetry;
    _client = MqttServerClient(
      config.serverConfig.hostName,
      identifier,
      maxConnectionAttempts: attempts,
    );
    _client.secure = config.secure;
    _client.useWebSocket = config.webSocketConfig?.useWebsocket ?? false;
    return _client;
  }
}
