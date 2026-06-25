import 'dart:convert';

/// Represents a server configuration.
class ServerConfig {
  /// Creates a new `ServerConfig` instance.
  const ServerConfig({
    required this.hostName,
    required this.port,
  });

  /// The host name of the server.
  final String hostName;

  /// The port number of the server.
  final int port;

  /// Creates a copy of the current `ServerConfig` instance with optional changes.
  ///
  /// This method creates a new instance of `ServerConfig` with the same properties as the current instance, but with the option to override some of the properties.
  ServerConfig copyWith({
    String? hostName,
    int? port,
  }) {
    return ServerConfig(
      hostName: hostName ?? this.hostName,
      port: port ?? this.port,
    );
  }

  /// Converts the `ServerConfig` instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'hostName': hostName,
      'port': port,
    };
  }

  /// Creates a `ServerConfig` instance from a map.
  factory ServerConfig.fromMap(Map<String, dynamic> map) {
    return ServerConfig(
      hostName: map['hostName'] as String,
      port: map['port'] as int,
    );
  }

  /// Converts the `ServerConfig` instance to a JSON string.
  String toJson() {
    // This method converts the `ServerConfig` instance to a JSON string.
    return json.encode(toMap());
  }

  /// Creates a `ServerConfig` instance from a JSON string.
  factory ServerConfig.fromJson(String source) {
    return ServerConfig.fromMap(
      json.decode(source) as Map<String, dynamic>,
    );
  }

  /// Returns a string representation of the `ServerConfig` instance.
  @override
  String toString() {
    return 'ServerConfig(hostName: $hostName, port: $port)';
  }

  /// Compares two `ServerConfig` instances for equality.
  @override
  bool operator ==(covariant ServerConfig other) {
    if (identical(this, other)) return true;

    return other.hostName == hostName && other.port == port;
  }

  /// Returns the hash code of the `ServerConfig` instance.
  @override
  int get hashCode {
    return hostName.hashCode ^ port.hashCode;
  }
}
