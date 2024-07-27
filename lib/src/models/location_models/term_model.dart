// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmChatTerm {
  final int? offset;
  final String? value;
  IsmChatTerm({
    this.offset,
    this.value,
  });

  IsmChatTerm copyWith({
    int? offset,
    String? value,
  }) =>
      IsmChatTerm(
        offset: offset ?? this.offset,
        value: value ?? this.value,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'offset': offset,
        'value': value,
      };

  factory IsmChatTerm.fromMap(Map<String, dynamic> map) => IsmChatTerm(
        offset: map['offset'] != null ? map['offset'] as int : null,
        value: map['value'] != null ? map['value'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmChatTerm.fromJson(String source) =>
      IsmChatTerm.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Term(offset: $offset, value: $value)';

  @override
  bool operator ==(covariant IsmChatTerm other) {
    if (identical(this, other)) return true;

    return other.offset == offset && other.value == value;
  }

  @override
  int get hashCode => offset.hashCode ^ value.hashCode;
}
