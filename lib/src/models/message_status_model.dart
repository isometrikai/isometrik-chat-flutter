import 'dart:convert';

class MessageStatusModel {
  MessageStatusModel({
    required this.deliveredToAll,
    required this.messageId,
    required this.readByAll,
  });

  factory MessageStatusModel.fromMap(Map<String, dynamic> map) =>
      MessageStatusModel(
        deliveredToAll: map['deliveredToAll'] as bool? ?? false,
        messageId: map['messageId'] as String? ?? '',
        readByAll: map['readByAll'] as bool? ?? false,
      );

  factory MessageStatusModel.fromJson(String source) =>
      MessageStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final bool deliveredToAll;
  final String messageId;
  final bool readByAll;

  MessageStatusModel copyWith({
    bool? deliveredToAll,
    String? messageId,
    bool? readByAll,
  }) =>
      MessageStatusModel(
        deliveredToAll: deliveredToAll ?? this.deliveredToAll,
        messageId: messageId ?? this.messageId,
        readByAll: readByAll ?? this.readByAll,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'deliveredToAll': deliveredToAll,
        'messageId': messageId,
        'readByAll': readByAll,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MessageStatusModel(deliveredToAll: $deliveredToAll, messageId: $messageId, readByAll: $readByAll)';

  @override
  bool operator ==(covariant MessageStatusModel other) {
    if (identical(this, other)) return true;

    return other.deliveredToAll == deliveredToAll &&
        other.messageId == messageId &&
        other.readByAll == readByAll;
  }

  @override
  int get hashCode =>
      deliveredToAll.hashCode ^ messageId.hashCode ^ readByAll.hashCode;
}
