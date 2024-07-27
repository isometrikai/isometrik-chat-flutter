class Api {
  const Api._();

  static const String baseUrl = 'https://apis.isometrik.io';

  static const String user = '$baseUrl/chat/user';
  static const String allUsers = '$baseUrl/chat/users';
  static const String authenticate = '$user/authenticate';
  static const String presignedurl = '$user/presignedurl/create';
}
