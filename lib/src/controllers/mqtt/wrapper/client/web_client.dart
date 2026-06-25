import 'package:isometrik_chat_flutter/src/controllers/mqtt/mqtt_helper.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

/// A helper class for connecting to an MQTT broker using the `mqtt_browser_client` package in a web environment.
///
/// This class provides a convenient way to set up an MQTT connection in a web browser by creating an instance of `MqttBrowserClient` and configuring it with the provided `MqttConfig`.
class MqttHelperClient {
  late MqttBrowserClient _client;

  /// The underlying `MqttBrowserClient` instance.
  ///
  /// This property provides access to the configured `MqttBrowserClient` instance, which can be used to connect to the MQTT broker and perform other MQTT-related operations.
  MqttBrowserClient get client => _client;

  /// Sets up the MQTT connection using the provided configuration.
  ///
  /// This method creates a new instance of `MqttBrowserClient` and configures it with the provided `MqttConfig`. The configured client is then stored in the `client` property.
  ///
  /// Parameters:
  ///   - `config`: The configuration for the MQTT connection.
  ///
  /// Returns: The configured `MqttBrowserClient` instance.
  MqttBrowserClient setup(MqttConfig config) {
    var userIdentifier = config.projectConfig.userIdentifier;
    var deviceId = config.projectConfig.deviceId;
    var identifier = '$userIdentifier$deviceId';

    final attempts =
        config.maxAutoReconnectRetry < 1 ? 1 : config.maxAutoReconnectRetry;
    _client = MqttBrowserClient(
      config.serverConfig.hostName,
      identifier,
      maxConnectionAttempts: attempts,
    );
    return _client;
  }
}
