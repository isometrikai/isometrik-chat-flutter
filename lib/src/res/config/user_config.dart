class IsmChatUserConfig {
  const IsmChatUserConfig({
    required this.userToken,
    required this.userId,
    this.userName,
    this.userEmail,
    this.userProfile,
    this.accessToken,

    // this.imageBaseUrl,
  });
  final String userToken;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String? userProfile;
  final String? accessToken;

  // final String? imageBaseUrl;
}
