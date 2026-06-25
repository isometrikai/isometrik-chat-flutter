import 'dart:convert';

/// Represents a project configuration.
class ProjectConfig {
  /// The device ID.
  final String deviceId;

  /// The user identifier.
  final String userIdentifier;

  /// The username.
  final String username;

  /// The password.
  final String password;

  /// Creates a new `ProjectConfig` instance with the given properties.
  ProjectConfig({
    required this.deviceId,
    required this.userIdentifier,
    required this.username,
    required this.password,
  });

  /// Creates a copy of the current `ProjectConfig` instance with optional changes.
  ProjectConfig copyWith({
    String? deviceId,
    String? userIdentifier,
    String? username,
    String? password,
  }) {
    return ProjectConfig(
      deviceId: deviceId ?? this.deviceId,
      userIdentifier: userIdentifier ?? this.userIdentifier,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  /// Converts the `ProjectConfig` instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'deviceId': deviceId,
      'userIdentifier': userIdentifier,
      'username': username,
      'password': password,
    };
  }

  /// Creates a `ProjectConfig` instance from a map.
  factory ProjectConfig.fromMap(Map<String, dynamic> map) {
    return ProjectConfig(
      deviceId: map['deviceId'] as String,
      userIdentifier: map['userIdentifier'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
    );
  }

  /// Converts the `ProjectConfig` instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates a `ProjectConfig` instance from a JSON string.
  factory ProjectConfig.fromJson(String source) =>
      ProjectConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Returns a string representation of the `ProjectConfig` instance.
  @override
  String toString() {
    return 'ProjectConfig(deviceId: $deviceId, userIdentifier: $userIdentifier, username: $username, password: $password)';
  }

  /// Compares two `ProjectConfig` instances for equality.
  @override
  bool operator ==(covariant ProjectConfig other) {
    if (identical(this, other)) return true;

    return other.deviceId == deviceId &&
        other.userIdentifier == userIdentifier &&
        other.username == username &&
        other.password == password;
  }

  /// Returns the hash code of the `ProjectConfig` instance.
  @override
  int get hashCode {
    return deviceId.hashCode ^
        userIdentifier.hashCode ^
        username.hashCode ^
        password.hashCode;
  }
}
