// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/foundation.dart';

class IsmChatStructuredFormatting {
  String? mainText;
  List<IsmChatMatchedSubstring>? matchedString;
  String? secondaryText;
  IsmChatStructuredFormatting({
    this.mainText,
    this.matchedString,
    this.secondaryText,
  });

  IsmChatStructuredFormatting copyWith({
    String? mainText,
    List<IsmChatMatchedSubstring>? matchedString,
    String? secondaryText,
  }) =>
      IsmChatStructuredFormatting(
        mainText: mainText ?? this.mainText,
        matchedString: matchedString ?? this.matchedString,
        secondaryText: secondaryText ?? this.secondaryText,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'mainText': mainText,
        'matchedString': matchedString!.map((x) => x.toMap()).toList(),
        'secondaryText': secondaryText,
      };

  factory IsmChatStructuredFormatting.fromMap(Map<String, dynamic> map) =>
      IsmChatStructuredFormatting(
        mainText: map['mainText'] != null ? map['mainText'] as String : null,
        matchedString: map['matchedString'] != null
            ? List<IsmChatMatchedSubstring>.from(
                (map['matchedString'] as List<int>)
                    .map<IsmChatMatchedSubstring?>(
                  (x) => IsmChatMatchedSubstring.fromMap(
                      x as Map<String, dynamic>),
                ),
              )
            : null,
        secondaryText: map['secondaryText'] != null
            ? map['secondaryText'] as String
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmChatStructuredFormatting.fromJson(String source) =>
      IsmChatStructuredFormatting.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'StructuredFormatting(mainText: $mainText, matchedString: $matchedString, secondaryText: $secondaryText)';

  @override
  bool operator ==(covariant IsmChatStructuredFormatting other) {
    if (identical(this, other)) return true;

    return other.mainText == mainText &&
        listEquals(other.matchedString, matchedString) &&
        other.secondaryText == secondaryText;
  }

  @override
  int get hashCode =>
      mainText.hashCode ^ matchedString.hashCode ^ secondaryText.hashCode;
}
