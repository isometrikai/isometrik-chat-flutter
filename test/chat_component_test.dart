import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_method_channel.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatComponentPlatform
    with MockPlatformInterfaceMixin
    implements ChatComponentPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final initialPlatform = ChatComponentPlatform.instance;

  test('$MethodChannelChatComponent is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelChatComponent>());
  });

  test('getPlatformVersion', () async {
    var isometrikChatPlugin = IsometrikChat();
    var fakePlatform = MockChatComponentPlatform();
    ChatComponentPlatform.instance = fakePlatform;

    expect(await isometrikChatPlugin.getPlatformVersion(), '42');
  });
}
