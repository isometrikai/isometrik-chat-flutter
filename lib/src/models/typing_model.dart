class IsmChatTypingModel {
  IsmChatTypingModel({
    required this.conversationId,
    required this.userName,
  });

  final String conversationId;
  final String userName;

  IsmChatTypingModel copyWith({
    String? conversationId,
    String? userName,
  }) =>
      IsmChatTypingModel(
        conversationId: conversationId ?? this.conversationId,
        userName: userName ?? this.userName,
      );

  @override
  String toString() =>
      'IsmChatTypingModel(conversationId: $conversationId, userName: $userName)';

  @override
  bool operator ==(covariant IsmChatTypingModel other) {
    if (identical(this, other)) return true;

    return other.conversationId == conversationId && other.userName == userName;
  }

  @override
  int get hashCode => conversationId.hashCode ^ userName.hashCode;
}
