import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ConversationConfigModel {
  factory ConversationConfigModel.fromJson(String source) =>
      ConversationConfigModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  factory ConversationConfigModel.fromMap(Map<String, dynamic> map) =>
      ConversationConfigModel(
        typingEvents: map['typingEvents'] as bool? ?? false,
        readEvents: map['readEvents'] as bool? ?? false,
        pushNotifications: map['pushNotifications'] as bool? ?? false,
      );

  ConversationConfigModel({
    this.id = 0,
    required this.typingEvents,
    required this.readEvents,
    required this.pushNotifications,
  });
  int id;
  final bool typingEvents;
  final bool readEvents;
  final bool pushNotifications;

  ConversationConfigModel copyWith({
    bool? typingEvents,
    bool? readEvents,
    bool? pushNotifications,
  }) =>
      ConversationConfigModel(
        typingEvents: typingEvents ?? this.typingEvents,
        readEvents: readEvents ?? this.readEvents,
        pushNotifications: pushNotifications ?? this.pushNotifications,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'typingEvents': typingEvents,
        'readEvents': readEvents,
        'pushNotifications': pushNotifications,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ConversationConfig(typingEvents: $typingEvents, readEvents: $readEvents, pushNotifications: $pushNotifications)';

  @override
  bool operator ==(covariant ConversationConfigModel other) {
    if (identical(this, other)) return true;

    return other.typingEvents == typingEvents &&
        other.readEvents == readEvents &&
        other.pushNotifications == pushNotifications;
  }

  @override
  int get hashCode =>
      typingEvents.hashCode ^ readEvents.hashCode ^ pushNotifications.hashCode;
}
