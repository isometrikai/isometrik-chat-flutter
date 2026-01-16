/// Map-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on Map types for common map operations
/// like removing null values and converting to message maps.

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for Map to remove null values and convert to message maps.
///
/// This extension provides utilities to clean up maps by removing null values
/// and converting maps to message model maps.
extension OnMap on Map<dynamic, dynamic> {
  /// Removes all null values from the map recursively.
  ///
  /// Also removes empty strings, empty lists, and empty maps.
  /// Returns a new map with only non-null, non-empty values.
  Map<String, dynamic> removeNullValues() {
    var result = <String, dynamic>{};
    forEach(
      (key, value) {
        if (value != null) {
          if (value is Map) {
            if (value.isEmpty) return;
            if (value is Map<String, dynamic>) {
              result[key] = value.removeNullValues();
            } else {
              return;
            }
          } else if (value is List) {
            if (value.isEmpty) return;
            var data = value
                .where((element) =>
                    element != null &&
                    ((element is String || element is List || element is Map)
                        ? element.isNotEmpty
                        : true))
                .map((element) {
              if (element is Map) {
                if (element.isEmpty) return;
                if (element is Map<String, dynamic>) {
                  return element.removeNullValues();
                }
              } else if (element is String && element.trim().isEmpty) {
                return element;
              }
              return element;
            }).toList();
            if (data.isEmpty) return;
            result[key] = data;
          } else if (value is String && value.trim().isNotEmpty) {
            result[key] = value;
          } else if (value is! String) {
            result[key] = value;
          }
        }
      },
    );
    return result;
  }

  /// Converts a map to an IsmChatMessages map.
  ///
  /// Handles both string JSON values and map values, converting them
  /// to IsmChatMessageModel instances.
  IsmChatMessages get messageMap => {
        for (var entry in entries)
          if (entry.value is String)
            entry.key: IsmChatMessageModel.fromJson(entry.value)
          else
            entry.key:
                IsmChatMessageModel.fromMap(entry.value as Map<String, dynamic>)
      };
}

