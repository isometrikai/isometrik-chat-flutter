// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatLatLongModel {
  final double lat;
  final double lng;
  IsmChatLatLongModel({
    required this.lat,
    required this.lng,
  });

  IsmChatLatLongModel copyWith({
    double? lat,
    double? lng,
  }) =>
      IsmChatLatLongModel(
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'lat': lat,
        'lng': lng,
      }.removeNullValues();

  factory IsmChatLatLongModel.fromMap(Map<String, dynamic> map) =>
      IsmChatLatLongModel(
        lat: map['lat'] as double,
        lng: map['lng'] as double,
      );
  LatLng get latlng => LatLng(lat, lng);

  String toJson() => json.encode(toMap());

  factory IsmChatLatLongModel.fromJson(String source) =>
      IsmChatLatLongModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'LatLongModel(lat: $lat, lng: $lng)';

  @override
  bool operator ==(covariant IsmChatLatLongModel other) {
    if (identical(this, other)) return true;

    return other.lat == lat && other.lng == lng;
  }

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}
