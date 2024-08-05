import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat_method_channel.dart';

void main() {
  var platform = MethodChannelIsometrikFlutterChat();
  // const channel = MethodChannel('isometrik_flutter_chat');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // channel.setMockMethodCallHandler((MethodCall methodCall) async => '42');
  });

  tearDown(() {
    // channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
