/// Location and map-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on location-related types like LatLng
/// and Placemark for distance calculations and address formatting.

import 'dart:math';

import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Extension for LatLng to calculate distance between two coordinates.
extension DistanceLatLng on LatLng {
  /// Calculates the distance in kilometers between this LatLng and another.
  ///
  /// Uses the Haversine formula to calculate the great-circle distance
  /// between two points on a sphere.
  double getDistance(LatLng other) {
    var lat1 = latitude,
        lon1 = longitude,
        lat2 = other.latitude,
        lon2 = other.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

/// Extension for Placemark to format address string.
extension AddressString on Placemark {
  /// Formats a Placemark into a comma-separated address string.
  ///
  /// Includes: name, street, subLocality, locality, administrativeArea,
  /// country, and postalCode.
  String toAddress() => [
        name,
        street,
        subLocality,
        locality,
        administrativeArea,
        country,
        postalCode
      ].join(', ');
}

