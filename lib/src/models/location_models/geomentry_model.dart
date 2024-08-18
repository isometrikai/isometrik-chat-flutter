import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatGeometry {
  IsmChatGeometry({
    this.location,
    this.viewport,
  });

  factory IsmChatGeometry.fromMap(Map<String, dynamic> map) => IsmChatGeometry(
        location: map['location'] != null
            ? IsmChatLatLongModel.fromMap(
                map['location'] as Map<String, dynamic>)
            : null,
        viewport: map['viewport'] != null
            ? IsmChatViewportModel.fromMap(
                map['viewport'] as Map<String, dynamic>)
            : null,
      );

  factory IsmChatGeometry.fromJson(String source) =>
      IsmChatGeometry.fromMap(json.decode(source) as Map<String, dynamic>);
  final IsmChatLatLongModel? location;
  final IsmChatViewportModel? viewport;

  IsmChatGeometry copyWith({
    IsmChatLatLongModel? location,
    IsmChatViewportModel? viewport,
  }) =>
      IsmChatGeometry(
        location: location ?? this.location,
        viewport: viewport ?? this.viewport,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'location': location?.toMap(),
        'viewport': viewport?.toMap(),
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'Geometry(location: $location, viewport: $viewport)';

  @override
  bool operator ==(covariant IsmChatGeometry other) {
    if (identical(this, other)) return true;

    return other.location == location && other.viewport == viewport;
  }

  @override
  int get hashCode => location.hashCode ^ viewport.hashCode;
}
