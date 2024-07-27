import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';

/// An implementation of [ChatComponentPlatform] that uses method channels.
class MethodChannelChatComponent extends ChatComponentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('isometrik_chat_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
