import 'package:isometrik_flutter_chat/isometrik_flutter_chat_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class IsometrikFlutterChatPlatform extends PlatformInterface {
  /// Constructs a ChatComponentPlatform.
  IsometrikFlutterChatPlatform() : super(token: _token);

  static final Object _token = Object();

  static IsometrikFlutterChatPlatform _instance =
      MethodChannelIsometrikFlutterChat();

  /// The default instance of [IsometrikFlutterChatPlatform] to use.
  ///
  /// Defaults to [MethodChannelIsometrikFlutterChat].
  static IsometrikFlutterChatPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [IsometrikFlutterChatPlatform] when
  /// they register themselves.
  static set instance(IsometrikFlutterChatPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
