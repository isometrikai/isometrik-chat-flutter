// ignore_for_file: avoid_setters_without_getters

import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/main.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

import '../models/models.dart';

class AppConfig {
  const AppConfig._();

  static UserDetailsModel? userDetail;

  /// Example app + SDK UI language.
  ///
  /// Supported by the chat SDK packs: `en`, `fr`, `pt`.
  /// Driven by [Constants.languageCode] (currently English).
  static Locale appLocale = Locale(Constants.languageCode);

  /// Applies [appLocale] to the chat SDK (titles / labels / dialogs only).
  static void applyLocale() {
    IsmChat.i.setLocale(appLocale);
  }

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
