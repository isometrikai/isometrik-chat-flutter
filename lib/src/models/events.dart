import 'dart:convert';

class IsmChatEvents {
  IsmChatEvents({
    this.typingEvents,
    this.readEvents,
    this.pushNotifications,
    this.updateUnreadCount,
    this.sendPushNotification,
  });

  factory IsmChatEvents.fromMap(Map<String, dynamic> map) => IsmChatEvents(
        typingEvents: map['typingEvents'] as bool? ?? false,
        readEvents: map['readEvents'] as bool? ?? false,
        pushNotifications: map['pushNotifications'] as bool? ?? false,
        updateUnreadCount: map['updateUnreadCount'] as bool? ?? false,
        sendPushNotification: map['sendPushNotification'] as bool? ?? false,
      );

  factory IsmChatEvents.fromJson(String source) =>
      IsmChatEvents.fromMap(json.decode(source) as Map<String, dynamic>);
  bool? typingEvents;
  bool? readEvents;
  bool? pushNotifications;
  bool? updateUnreadCount;
  bool? sendPushNotification;

  IsmChatEvents copyWith({
    bool? typingEvents,
    bool? readEvents,
    bool? pushNotifications,
    bool? updateUnreadCount,
    bool? sendPushNotification,
  }) =>
      IsmChatEvents(
        typingEvents: typingEvents ?? this.typingEvents,
        readEvents: readEvents ?? this.readEvents,
        pushNotifications: pushNotifications ?? this.pushNotifications,
        updateUnreadCount: updateUnreadCount ?? this.updateUnreadCount,
        sendPushNotification: sendPushNotification ?? this.sendPushNotification,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        if (typingEvents != null) 'typingEvents': typingEvents,
        if (readEvents != null) 'readEvents': readEvents,
        if (pushNotifications != null) 'pushNotifications': pushNotifications,
        if (updateUnreadCount != null) 'updateUnreadCount': updateUnreadCount,
        if (sendPushNotification != null)
          'sendPushNotification': sendPushNotification,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatEvents(typingEvents: $typingEvents, readEvents: $readEvents, pushNotifications: $pushNotifications, updateUnreadCount: $updateUnreadCount, sendPushNotification: $sendPushNotification)';

  @override
  bool operator ==(covariant IsmChatEvents other) {
    if (identical(this, other)) return true;

    return other.typingEvents == typingEvents &&
        other.readEvents == readEvents &&
        other.pushNotifications == pushNotifications &&
        other.updateUnreadCount == updateUnreadCount &&
        other.sendPushNotification == sendPushNotification;
  }

  @override
  int get hashCode =>
      typingEvents.hashCode ^
      readEvents.hashCode ^
      pushNotifications.hashCode ^
      updateUnreadCount.hashCode ^
      sendPushNotification.hashCode;
}
