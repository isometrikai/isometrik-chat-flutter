import 'dart:convert';

class IsmChatContactMetaDatModel {
  IsmChatContactMetaDatModel({
    this.contactName,
    this.contactImageUrl,
    this.contactIdentifier,
    this.contactId,
  });

  factory IsmChatContactMetaDatModel.fromMap(Map<String, dynamic> map) =>
      IsmChatContactMetaDatModel(
        contactName: map['contactName'] as String? ?? '',
        contactImageUrl: map['contactImageUrl'] as String? ?? '',
        contactIdentifier: map['contactIdentifier'] as String? ?? '',
        contactId: map['contactId'] as String? ?? '',
      );

  factory IsmChatContactMetaDatModel.fromJson(String source) =>
      IsmChatContactMetaDatModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? contactName;
  final String? contactImageUrl;
  final String? contactIdentifier;
  final String? contactId;

  IsmChatContactMetaDatModel copyWith({
    String? contactName,
    String? contactImageUrl,
    String? contactIdentifier,
    String? contactId,
  }) =>
      IsmChatContactMetaDatModel(
        contactName: contactName ?? this.contactName,
        contactImageUrl: contactImageUrl ?? this.contactImageUrl,
        contactIdentifier: contactIdentifier ?? this.contactIdentifier,
        contactId: contactId ?? this.contactId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'contactName': contactName,
        'contactImageUrl': contactImageUrl,
        'contactIdentifier': contactIdentifier,
        'contactId': contactId,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatContactMetaDatModel(contactName: $contactName, contactImageUrl: $contactImageUrl, contactIdentifier: $contactIdentifier, contactId: $contactId)';

  @override
  bool operator ==(covariant IsmChatContactMetaDatModel other) {
    if (identical(this, other)) return true;

    return other.contactName == contactName &&
        other.contactImageUrl == contactImageUrl &&
        other.contactIdentifier == contactIdentifier &&
        other.contactId == contactId;
  }

  @override
  int get hashCode =>
      contactName.hashCode ^
      contactImageUrl.hashCode ^
      contactIdentifier.hashCode ^
      contactId.hashCode;
}
