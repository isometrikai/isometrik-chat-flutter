import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatResponseModel {
  factory IsmChatResponseModel.fromJson(String source) =>
      IsmChatResponseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory IsmChatResponseModel.fromMap(Map<String, dynamic> map) =>
      IsmChatResponseModel(
        data: map['data'] as String,
        hasError: map['hasError'] as bool,
        errorCode: map['errorCode'] as int,
      );

  factory IsmChatResponseModel.message(
    String message, {
    bool isSuccess = false,
    int? errorCode,
  }) =>
      IsmChatResponseModel(
        data: jsonEncode({'message': message}),
        hasError: !isSuccess,
        errorCode: errorCode ?? 1000,
      );

  const IsmChatResponseModel({
    required this.data,
    required this.hasError,
    required this.errorCode,
  });

  final String data;
  final bool hasError;
  final int errorCode;

  /// Prefer the server error text over a static fallback.
  ///
  /// Tries common Isometrik / HTTP body keys (`error`, `message`,
  /// `errorMessage`, nested `data`), then [fallback] only if none are present.
  /// Reuse this for any dialog/toast that used to hard-code API failures
  /// (send message, create conversation, etc.).
  String apiErrorMessage({String fallback = 'Something went wrong'}) {
    final body = data.trim();
    if (body.isEmpty) {
      return fallback;
    }
    try {
      final decoded = jsonDecode(body);
      final fromMap = _apiErrorFromDecoded(decoded);
      if (fromMap != null && fromMap.isNotEmpty) {
        return fromMap;
      }
    } catch (_) {
      // Non-JSON body — show raw text when it looks user-facing.
      if (body.length < 280 && !body.startsWith('<')) {
        return body;
      }
    }
    return fallback;
  }

  static String? _apiErrorFromDecoded(dynamic decoded) {
    if (decoded is! Map) {
      return decoded is String ? decoded.trim() : null;
    }
    final map = Map<String, dynamic>.from(decoded);
    for (final key in const ['error', 'message', 'errorMessage', 'detail']) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
      // Some APIs return `{ "error": { "message": "..." } }`.
      if (value is Map) {
        final nested = _apiErrorFromDecoded(value);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    }
    final data = map['data'];
    if (data != null) {
      return _apiErrorFromDecoded(data);
    }
    return null;
  }

  IsmChatResponseModel copyWith({
    String? data,
    bool? hasError,
    int? errorCode,
  }) =>
      IsmChatResponseModel(
        data: data ?? this.data,
        hasError: hasError ?? this.hasError,
        errorCode: errorCode ?? this.errorCode,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'data': data,
        'hasError': hasError,
        'errorCode': errorCode,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'ResponseModel(data: $data, hasError: $hasError, errorCode: $errorCode)';

  @override
  bool operator ==(covariant IsmChatResponseModel other) {
    if (identical(this, other)) return true;

    return other.data == data &&
        other.hasError == hasError &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode => data.hashCode ^ hasError.hashCode ^ errorCode.hashCode;
}

class ModelWrapper<T> {
  const ModelWrapper({
    required this.data,
    required this.statusCode,
  });
  final T? data;
  final int statusCode;
}
