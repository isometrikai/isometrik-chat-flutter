class IsmChatProjectConfig {
  const IsmChatProjectConfig({
    required this.accountId,
    required this.appSecret,
    required this.userSecret,
    required this.keySetId,
    required this.licenseKey,
    required this.projectId,
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
  final String? chatApisBaseUrl;
  final String? googleApiKey;
  final String appName;
}
