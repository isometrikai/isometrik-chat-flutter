// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html show window;

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';

/// A web implementation of the ChatComponentPlatform of the ChatComponent plugin.
class IsometrikChatFlutterWeb extends IsometrikChatFlutterPlatform {
  /// Constructs a ChatComponentWeb
  IsometrikChatFlutterWeb();

  static void registerWith(Registrar registrar) {
    IsometrikChatFlutterPlatform.instance = IsometrikChatFlutterWeb();
  }

  /// Returns a [String] containing the version of the platform.
  @override
  Future<String?> getPlatformVersion() async {
    final version = html.window.navigator.userAgent;
    return version;
  }
}
