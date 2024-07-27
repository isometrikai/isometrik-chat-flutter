// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class UserDetailsModel {
  String? userId;

  String? userToken;

  String? email;

  String? userName;
  UserDetailsModel({
    this.userId,
    this.userToken,
    this.email,
    this.userName,
  });

  UserDetailsModel copyWith({
    String? userId,
    String? userToken,
    String? email,
    String? userName,
  }) {
    return UserDetailsModel(
      userId: userId ?? this.userId,
      userToken: userToken ?? this.userToken,
      email: email ?? this.email,
      userName: userName ?? this.userName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'userToken': userToken,
      'email': email,
      'userName': userName,
    };
  }

  factory UserDetailsModel.fromMap(Map<String, dynamic> map) {
    return UserDetailsModel(
      userId: map['userId'] != null ? map['userId'] as String : null,
      userToken: map['userToken'] != null ? map['userToken'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      userName: map['userName'] != null ? map['userName'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserDetailsModel.fromJson(String source) =>
      UserDetailsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserDetailsModel(userId: $userId, userToken: $userToken, email: $email, userName: $userName)';
  }

  @override
  bool operator ==(covariant UserDetailsModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId &&
        other.userToken == userToken &&
        other.email == email &&
        other.userName == userName;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        userToken.hashCode ^
        email.hashCode ^
        userName.hashCode;
  }
}
