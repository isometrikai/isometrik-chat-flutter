import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatRoute {
  IsmChatRoute._();

  static Future<T?> goToRoute<T>(Widget child) async =>
      await IsmChatConfig.kNavigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (BuildContext context) => child,
        ),
      );

  static void goBack<T>([T? result]) {
    IsmChatConfig.kNavigatorKey.currentState?.pop(result);

    // Navigator.of(IsmChatConfig.kNavigatorKey.currentContext!).pop(result);
  }
}
