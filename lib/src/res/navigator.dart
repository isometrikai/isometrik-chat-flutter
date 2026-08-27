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
    final nav = IsmChatConfig.kNavigatorKey.currentState;
    // Avoid invalid stack / assert when nothing can be popped (common on web).
    if (nav == null || !nav.canPop()) return;
    nav.pop(result);

    // Navigator.of(IsmChatConfig.kNavigatorKey.currentContext!).pop(result);
  }
}
