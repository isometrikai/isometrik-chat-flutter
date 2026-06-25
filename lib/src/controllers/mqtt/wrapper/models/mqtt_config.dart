import 'dart:convert';

import 'models.dart';

/// Represents a configuration for an MQTT connection.
class MqttConfig {
  /// The server configuration.
  final ServerConfig serverConfig;

  /// The project configuration.
  final ProjectConfig projectConfig;

  /// The WebSocket configuration, optional.
  final WebSocketConfig? webSocketConfig;

  /// Whether to enable logging, default is `true`.
  final bool enableLogging;

  /// Whether to use a secure connection, default is `false`.
  final bool secure;

  /// Whether to use a autoreconnect connection, default is `true`.
  final bool autoReconnect;

  /// Passed to [mqtt_client](https://pub.dev/packages/mqtt_client) as
  /// `maxConnectionAttempts`: broker handshake retries per connect (including
  /// each auto-reconnect cycle). Default is `3`.
  final int maxAutoReconnectRetry;

  /// Keep-alive interval in seconds (MQTT PING when idle). Passed to [MqttClient.keepAlivePeriod].
  final int keepAliveSeconds;

  /// If the broker does not answer a PING within this many seconds, the client
  /// drops the connection (then [MqttClient.autoReconnect] runs). Passed to
  /// [MqttClient.disconnectOnNoResponsePeriod]. Use `0` to disable (library default).
  final int disconnectOnNoPingResponseSeconds;

  /// Creates a new `MqttConfig` instance with the given configurations and settings.
  MqttConfig({
    required this.serverConfig,
    required this.projectConfig,
    this.webSocketConfig,
    this.enableLogging = true,
    this.secure = false,
    this.autoReconnect = true,
    this.maxAutoReconnectRetry = 3,
    this.keepAliveSeconds = 30,
    this.disconnectOnNoPingResponseSeconds = 10,
  });

  /// Creates a copy of the current `MqttConfig` instance with optional changes.
  MqttConfig copyWith({
    ServerConfig? serverConfig,
    ProjectConfig? projectConfig,
    WebSocketConfig? webSocketConfig,
    bool? enableLogging,
    bool? secure,
    bool? autoReconnect,
    int? maxAutoReconnectRetry,
    int? keepAliveSeconds,
    int? disconnectOnNoPingResponseSeconds,
  }) {
    return MqttConfig(
      serverConfig: serverConfig ?? this.serverConfig,
      projectConfig: projectConfig ?? this.projectConfig,
      webSocketConfig: webSocketConfig ?? this.webSocketConfig,
      enableLogging: enableLogging ?? this.enableLogging,
      secure: secure ?? this.secure,
      autoReconnect: autoReconnect ?? this.autoReconnect,
      maxAutoReconnectRetry:
          maxAutoReconnectRetry ?? this.maxAutoReconnectRetry,
      keepAliveSeconds: keepAliveSeconds ?? this.keepAliveSeconds,
      disconnectOnNoPingResponseSeconds: disconnectOnNoPingResponseSeconds ??
          this.disconnectOnNoPingResponseSeconds,
    );
  }

  /// Converts the `MqttConfig` instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'serverConfig': serverConfig.toMap(),
      'projectConfig': projectConfig.toMap(),
      'webSocketConfig': webSocketConfig?.toMap(),
      'enableLogging': enableLogging,
      'secure': secure,
      'autoReconnect': autoReconnect,
      'maxAutoReconnectRetry': maxAutoReconnectRetry,
      'keepAliveSeconds': keepAliveSeconds,
      'disconnectOnNoPingResponseSeconds': disconnectOnNoPingResponseSeconds,
    };
  }

  /// Creates an `MqttConfig` instance from a map.
  factory MqttConfig.fromMap(Map<String, dynamic> map) {
    return MqttConfig(
      serverConfig: ServerConfig.fromMap(
        map['serverConfig'] as Map<String, dynamic>,
      ),
      projectConfig: ProjectConfig.fromMap(
        map['projectConfig'] as Map<String, dynamic>,
      ),
      webSocketConfig: map['webSocketConfig'] != null
          ? WebSocketConfig.fromMap(
              map['webSocketConfig'] as Map<String, dynamic>,
            )
          : null,
      enableLogging: map['enableLogging'] as bool,
      secure: map['secure'] as bool,
      autoReconnect: map['autoReconnect'] as bool,
      maxAutoReconnectRetry: map['maxAutoReconnectRetry'] as int,
      keepAliveSeconds: map['keepAliveSeconds'] as int? ?? 30,
      disconnectOnNoPingResponseSeconds:
          map['disconnectOnNoPingResponseSeconds'] as int? ?? 10,
    );
  }

  /// Converts the `MqttConfig` instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates an `MqttConfig` instance from a JSON string.
  factory MqttConfig.fromJson(String source) => MqttConfig.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Returns a string representation of the `MqttConfig` instance.
  @override
  String toString() {
    return 'MqttConfig(serverConfig: $serverConfig, projectConfig: $projectConfig, webSocketConfig: $webSocketConfig, enableLogging: $enableLogging, secure: $secure, autoReconnect: $autoReconnect, maxAutoReconnectRetry: $maxAutoReconnectRetry, keepAliveSeconds: $keepAliveSeconds, disconnectOnNoPingResponseSeconds: $disconnectOnNoPingResponseSeconds)';
  }

  /// Compares two `MqttConfig` instances for equality.
  @override
  bool operator ==(covariant MqttConfig other) {
    if (identical(this, other)) return true;

    return other.serverConfig == serverConfig &&
        other.projectConfig == projectConfig &&
        other.webSocketConfig == webSocketConfig &&
        other.enableLogging == enableLogging &&
        other.autoReconnect == autoReconnect &&
        other.maxAutoReconnectRetry == maxAutoReconnectRetry &&
        other.secure == secure &&
        other.keepAliveSeconds == keepAliveSeconds &&
        other.disconnectOnNoPingResponseSeconds ==
            disconnectOnNoPingResponseSeconds;
  }

  /// Returns the hash code of the `MqttConfig` instance.
  @override
  int get hashCode {
    return serverConfig.hashCode ^
        projectConfig.hashCode ^
        webSocketConfig.hashCode ^
        enableLogging.hashCode ^
        autoReconnect.hashCode ^
        maxAutoReconnectRetry.hashCode ^
        secure.hashCode ^
        keepAliveSeconds.hashCode ^
        disconnectOnNoPingResponseSeconds.hashCode;
  }
}
