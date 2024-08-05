import 'dart:convert';

import 'package:isometrik_flutter_chat/src/models/user_details_model.dart';
import 'package:flutter/foundation.dart';

class IsmChatUserListModel {
  factory IsmChatUserListModel.fromJson(String source) =>
      IsmChatUserListModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory IsmChatUserListModel.fromMap(Map<String, dynamic> map) =>
      IsmChatUserListModel(
        users: List<UserDetails>.from(
          (map['users'] as List<dynamic>).map<UserDetails>(
            (x) => UserDetails.fromMap(x as Map<String, dynamic>),
          ),
        ),
        pageToken: map['pageToken'] == null ? '' : map['pageToken'] as String,
      );

  const IsmChatUserListModel({
    required this.users,
    required this.pageToken,
  });
  final List<UserDetails> users;
  final String pageToken;

  IsmChatUserListModel copyWith({
    List<UserDetails>? users,
    String? pageToken,
  }) =>
      IsmChatUserListModel(
        users: users ?? this.users,
        pageToken: pageToken ?? this.pageToken,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'users': users.map((x) => x.toMap()).toList(),
        'pageToken': pageToken,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() => 'IsmUserListModel(users: $users, pageToken: $pageToken)';

  @override
  bool operator ==(covariant IsmChatUserListModel other) {
    if (identical(this, other)) return true;

    return listEquals(other.users, users) && other.pageToken == pageToken;
  }

  @override
  int get hashCode => users.hashCode ^ pageToken.hashCode;
}
