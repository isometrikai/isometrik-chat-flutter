import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat_platform_interface.dart';

/// An implementation of [IsometrikFlutterChatPlatform] that uses method channels.
class MethodChannelIsometrikFlutterChat extends IsometrikFlutterChatPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('isometrik_flutter_chat');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
