import 'package:isometrik_chat_flutter/isometrik_chat_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class IsometrikChatFlutterPlatform extends PlatformInterface {
  /// Constructs a ChatComponentPlatform.
  IsometrikChatFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static IsometrikChatFlutterPlatform _instance =
      MethodChannelIsometrikChatFlutter();

  /// The default instance of [IsometrikChatFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelIsometrikChatFlutter].
  static IsometrikChatFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IsometrikChatFlutterPlatform] when
  /// they register themselves.
  static set instance(IsometrikChatFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
