import 'dart:convert';

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatProjectConfig {
  factory IsmChatProjectConfig.fromMap(Map<String, dynamic> map) =>
      IsmChatProjectConfig(
        accountId: map['accountId'] as String,
        appSecret: map['appSecret'] as String,
        userSecret: map['userSecret'] as String,
        keySetId: map['keySetId'] as String,
        licenseKey: map['licenseKey'] as String,
        projectId: map['projectId'] as String,
        deviceId: map['deviceId'] as String,
        chatApisBaseUrl: map['chatApisBaseUrl'] != null
            ? map['chatApisBaseUrl'] as String
            : null,
        googleApiKey:
            map['googleApiKey'] != null ? map['googleApiKey'] as String : null,
        appName: map['appName'] as String,
      );

  factory IsmChatProjectConfig.fromJson(String source) =>
      IsmChatProjectConfig.fromMap(json.decode(source) as Map<String, dynamic>);
  const IsmChatProjectConfig({
    required this.accountId,
    required this.appSecret,
    required this.userSecret,
    required this.keySetId,
    required this.licenseKey,
    required this.projectId,
    required this.deviceId,
    this.chatApisBaseUrl,
    this.googleApiKey,
    this.appName = 'ISM',
  });
  final String accountId;
  final String appSecret;
  final String userSecret;
  final String keySetId;
  final String licenseKey;
  final String projectId;
  final String deviceId;
  final String? chatApisBaseUrl;
  final String? googleApiKey;
  final String appName;

  Map<String, dynamic> toMap() => <String, dynamic>{
        'accountId': accountId,
        'appSecret': appSecret,
        'userSecret': userSecret,
        'keySetId': keySetId,
        'licenseKey': licenseKey,
        'projectId': projectId,
        'deviceId': deviceId,
        'chatApisBaseUrl': chatApisBaseUrl,
        'googleApiKey': googleApiKey,
        'appName': appName,
      }.removeNullValues();

  @override
  String toString() =>
      'IsmChatProjectConfig(accountId: $accountId, appSecret: $appSecret, userSecret: $userSecret, keySetId: $keySetId, licenseKey: $licenseKey, projectId: $projectId, deviceId: $deviceId, chatApisBaseUrl: $chatApisBaseUrl, googleApiKey: $googleApiKey, appName: $appName)';
}
