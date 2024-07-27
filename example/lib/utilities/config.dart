// ignore_for_file: avoid_setters_without_getters

import 'package:chat_component_example/main.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

import '../models/models.dart';

class AppConfig {
  const AppConfig._();

  static UserDetailsModel? userDetail;

  static Future<void> getUserData() async {
    var data = await dbWrapper!.userDetailsBox.get(IsmChatStrings.user);

    if (data == null) {
      return;
    }

    userDetail = UserDetailsModel.fromJson(data);
    // IsmChatLog.success(userDetail?.userToken);
    // IsmChatLog.success(userDetail?.toMap());
  }
}
