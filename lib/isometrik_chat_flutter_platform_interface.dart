import 'package:isometrik_chat_flutter/isometrik_chat_flutter_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class ChatComponentPlatform extends PlatformInterface {
  /// Constructs a ChatComponentPlatform.
  ChatComponentPlatform() : super(token: _token);

  static final Object _token = Object();

  static ChatComponentPlatform _instance = MethodChannelChatComponent();

  /// The default instance of [ChatComponentPlatform] to use.
  ///
  /// Defaults to [MethodChannelChatComponent].
  static ChatComponentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ChatComponentPlatform] when
  /// they register themselves.
  static set instance(ChatComponentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
