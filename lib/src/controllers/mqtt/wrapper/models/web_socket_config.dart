import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a WebSocket configuration.
class WebSocketConfig {
  /// Whether to use WebSocket or not.
  /// This variable determines if the WebSocket connection should be established or not.
  /// If set to true, the WebSocket connection will be established, otherwise it will not.
  final bool useWebsocket;

  /// The list of WebSocket protocols to be used.
  /// This variable represents the list of protocols that will be used to establish the WebSocket connection.
  /// The protocols are used to negotiate the connection with the WebSocket server.
  final List<String> websocketProtocols;

  /// Creates a new `WebSocketConfig` instance with the given properties.
  const WebSocketConfig({
    required this.useWebsocket,
    required this.websocketProtocols,
  }) : assert(!useWebsocket || (useWebsocket && websocketProtocols.length != 0),
            'if useWebsocket is set to true, the websocket protocols must be specified');

  /// Creates a copy of the current `WebSocketConfig` instance with optional changes.
  /// This method allows you to create a new instance of `WebSocketConfig` with the same properties as the current instance,
  /// but with the option to override some of the properties.
  WebSocketConfig copyWith({
    bool? useWebsocket,
    List<String>? websocketProtocols,
  }) {
    return WebSocketConfig(
      useWebsocket: useWebsocket ?? this.useWebsocket,
      websocketProtocols: websocketProtocols ?? this.websocketProtocols,
    );
  }

  /// Converts the `WebSocketConfig` instance to a map.
  /// This method returns a map representation of the `WebSocketConfig` instance,
  /// where each key-value pair represents a property of the instance.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'useWebsocket': useWebsocket,
      'websocketProtocols': websocketProtocols,
    };
  }

  /// Creates a new `WebSocketConfig` instance from a map.
  /// This factory method creates a new instance of `WebSocketConfig` from a map,
  /// where each key-value pair in the map represents a property of the instance.
  factory WebSocketConfig.fromMap(Map<String, dynamic> map) {
    return WebSocketConfig(
      useWebsocket: map['useWebsocket'] as bool,
      websocketProtocols: (map['websocketProtocols'] as List).cast(),
    );
  }

  /// Converts the `WebSocketConfig` instance to a JSON string.
  /// This method returns a JSON string representation of the `WebSocketConfig` instance,
  /// which can be used to serialize the instance.
  String toJson() => json.encode(toMap());

  /// Creates a new `WebSocketConfig` instance from a JSON string.
  /// This factory method creates a new instance of `WebSocketConfig` from a JSON string,
  /// which can be used to deserialize the instance.
  factory WebSocketConfig.fromJson(String source) => WebSocketConfig.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Returns a string representation of the `WebSocketConfig` instance.
  /// This method returns a string that represents the `WebSocketConfig` instance,
  /// which can be used for debugging or logging purposes.
  @override
  String toString() =>
      'WebSocketConfig(useWebsocket: $useWebsocket, websocketProtocols: $websocketProtocols)';

  /// Compares two `WebSocketConfig` instances for equality.
  /// This method checks if two instances of `WebSocketConfig` are equal,
  /// based on their properties.
  @override
  bool operator ==(covariant WebSocketConfig other) {
    if (identical(this, other)) return true;

    return other.useWebsocket == useWebsocket &&
        listEquals(
          other.websocketProtocols,
          websocketProtocols,
        );
  }

  /// Returns the hash code of the `WebSocketConfig` instance.
  /// This method returns a hash code that represents the `WebSocketConfig` instance,
  /// which can be used for storing the instance in a collection.
  @override
  int get hashCode => useWebsocket.hashCode ^ websocketProtocols.hashCode;
}
