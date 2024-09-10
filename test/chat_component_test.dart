import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_method_channel.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockChatComponentPlatform
    with MockPlatformInterfaceMixin
    implements IsometrikChatFlutterPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final initialPlatform = IsometrikChatFlutterPlatform.instance;

  test('$MethodChannelIsometrikChatFlutter is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelIsometrikChatFlutter>());
  });

  test('getPlatformVersion', () async {
    final isometrikChatFlutterPlugin = IsmChat();
    final fakePlatform = MockChatComponentPlatform();
    IsometrikChatFlutterPlatform.instance = fakePlatform;
    expect(await isometrikChatFlutterPlugin.getPlatformVersion(), '42');
  });
}
