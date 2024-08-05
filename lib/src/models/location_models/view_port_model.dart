// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:isometrik_flutter_chat/src/models/models.dart';

class IsmChatViewportModel {
  final IsmChatLatLongModel northeast;
  final IsmChatLatLongModel southwest;
  IsmChatViewportModel({
    required this.northeast,
    required this.southwest,
  });

  IsmChatViewportModel copyWith({
    IsmChatLatLongModel? northeast,
    IsmChatLatLongModel? southwest,
  }) =>
      IsmChatViewportModel(
        northeast: northeast ?? this.northeast,
        southwest: southwest ?? this.southwest,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'northeast': northeast.toMap(),
        'southwest': southwest.toMap(),
      };

  factory IsmChatViewportModel.fromMap(Map<String, dynamic> map) =>
      IsmChatViewportModel(
        northeast: IsmChatLatLongModel.fromMap(
            map['northeast'] as Map<String, dynamic>),
        southwest: IsmChatLatLongModel.fromMap(
            map['southwest'] as Map<String, dynamic>),
      );

  String toJson() => json.encode(toMap());

  factory IsmChatViewportModel.fromJson(String source) =>
      IsmChatViewportModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'ViewportModle(northeast: $northeast, southwest: $southwest)';

  @override
  bool operator ==(covariant IsmChatViewportModel other) {
    if (identical(this, other)) return true;

    return other.northeast == northeast && other.southwest == southwest;
  }

  @override
  int get hashCode => northeast.hashCode ^ southwest.hashCode;
}
