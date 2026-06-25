import 'dart:convert';

import 'package:flutter/foundation.dart';

/// The EventModel class represents a data model for events, consisting of a topic and a payload. This class provides a structured way to work with events, making it easier to create, manipulate, and compare events.
class EventModel {
  /// The topic of the event.
  final String topic;

  /// The payload of the event, represented as a map of strings to dynamic values.
  final Map<String, dynamic> payload;

  /// Creates a new [EventModel] instance with the given topic and payload.
  EventModel({
    required this.topic,
    required this.payload,
  });

  /// Creates a copy of the current [EventModel] instance with optional changes.
  EventModel copyWith({
    String? topic,
    Map<String, dynamic>? payload,
  }) {
    return EventModel(
      topic: topic ?? this.topic,
      payload: payload ?? this.payload,
    );
  }

  /// Converts the [EventModel] instance to a map.
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'topic': topic,
      'payload': payload,
    };
  }

  /// Creates an [EventModel] instance from a map.
  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      topic: map['topic'] as String,
      payload: (map['payload'] as Map<String, dynamic>),
    );
  }

  /// Converts the [EventModel] instance to a JSON string.
  String toJson() => json.encode(toMap());

  /// Creates an [EventModel] instance from a JSON string.
  factory EventModel.fromJson(
    String source,
  ) =>
      EventModel.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );

  /// Returns a string representation of the [EventModel] instance.
  @override
  String toString() => 'EventModel(topic: $topic, payload: $payload)';

  /// Compares two [EventModel] instances for equality.
  @override
  bool operator ==(covariant EventModel other) {
    if (identical(this, other)) return true;

    return other.topic == topic && mapEquals(other.payload, payload);
  }

  /// Returns the hash code of the [EventModel] instance.
  @override
  int get hashCode => topic.hashCode ^ payload.hashCode;
}
