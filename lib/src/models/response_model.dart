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
