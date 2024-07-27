import 'dart:convert';

class MentionModel {
  factory MentionModel.fromJson(String source) =>
      MentionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory MentionModel.fromMap(Map<String, dynamic> map) => MentionModel(
        userId: map['userId'] as String? ?? '',
        wordCount: map['wordCount'] as int? ?? 0,
        order: map['order'] as int? ?? 0,
      );

  const MentionModel({
    required this.userId,
    required this.wordCount,
    required this.order,
  });
  final String userId;
  final int wordCount;
  final int order;

  MentionModel copyWith({
    String? userId,
    int? wordCount,
    int? order,
  }) =>
      MentionModel(
        userId: userId ?? this.userId,
        wordCount: wordCount ?? this.wordCount,
        order: order ?? this.order,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userId': userId,
        'wordCount': wordCount,
        'order': order,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MentionModel(userId: $userId, wordCount: $wordCount, order: $order)';

  @override
  bool operator ==(covariant MentionModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.wordCount == wordCount &&
        other.order == order;
  }

  @override
  int get hashCode => userId.hashCode ^ wordCount.hashCode ^ order.hashCode;
}
