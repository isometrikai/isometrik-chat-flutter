// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmChatMatchedSubstring {
  final int? length;
  final int? offset;
  IsmChatMatchedSubstring({
    this.length,
    this.offset,
  });

  IsmChatMatchedSubstring copyWith({
    int? length,
    int? offset,
  }) =>
      IsmChatMatchedSubstring(
        length: length ?? this.length,
        offset: offset ?? this.offset,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'length': length,
        'offset': offset,
      };

  factory IsmChatMatchedSubstring.fromMap(Map<String, dynamic> map) =>
      IsmChatMatchedSubstring(
        length: map['length'] != null ? map['length'] as int : null,
        offset: map['offset'] != null ? map['offset'] as int : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmChatMatchedSubstring.fromJson(String source) =>
      IsmChatMatchedSubstring.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'MatchedSubstring(length: $length, offset: $offset)';

  @override
  bool operator ==(covariant IsmChatMatchedSubstring other) {
    if (identical(this, other)) return true;

    return other.length == length && other.offset == offset;
  }

  @override
  int get hashCode => length.hashCode ^ offset.hashCode;
}
