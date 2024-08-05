import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat_method_channel.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatComponentPlatform
    with MockPlatformInterfaceMixin
    implements IsometrikFlutterChatPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final initialPlatform = IsometrikFlutterChatPlatform.instance;

  test('$MethodChannelIsometrikFlutterChat is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIsometrikFlutterChat>());
  });

  test('getPlatformVersion', () async {
    var IsometrikFlutterChatPlugin = IsmChat();
    var fakePlatform = MockChatComponentPlatform();
    IsometrikFlutterChatPlatform.instance = fakePlatform;

    expect(await IsometrikFlutterChatPlugin.getPlatformVersion(), '42');
  });
}
