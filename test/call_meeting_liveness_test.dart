import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

void main() {
  tearDown(IsmChatCallMeetingLiveness.clear);

  test('history meetingCreated is not live until this session marks it', () {
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isFalse);
    IsmChatCallMeetingLiveness.markLive('meet-1');
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isTrue);
  });

  test('hang-up wins over live so Ringing cannot stick', () {
    IsmChatCallMeetingLiveness.markLive('meet-1');
    IsmChatCallMeetingLiveness.markEnded('meet-1');
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isFalse);
    expect(IsmChatCallMeetingLiveness.isEnded('meet-1'), isTrue);
    IsmChatCallMeetingLiveness.markLive('meet-1');
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isFalse);
  });

  test('joinRequestAccept marks connected until hang-up', () {
    IsmChatCallMeetingLiveness.markLive('meet-1');
    expect(IsmChatCallMeetingLiveness.isConnected('meet-1'), isFalse);
    IsmChatCallMeetingLiveness.markConnected('meet-1');
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isTrue);
    expect(IsmChatCallMeetingLiveness.isConnected('meet-1'), isTrue);
    IsmChatCallMeetingLiveness.markEnded('meet-1');
    expect(IsmChatCallMeetingLiveness.isConnected('meet-1'), isFalse);
  });

  test('group memberJoin is connected like joinRequestAccept', () {
    IsmChatCallMeetingLiveness.markLive('meet-g');
    expect(IsmChatCallMeetingLiveness.isConnected('meet-g'), isFalse);
    IsmChatCallMeetingLiveness.markConnected('meet-g');
    expect(IsmChatCallMeetingLiveness.isLive('meet-g'), isTrue);
    expect(IsmChatCallMeetingLiveness.isConnected('meet-g'), isTrue);
  });

  test('clear wipes session state like logout', () {
    IsmChatCallMeetingLiveness.markLive('meet-1');
    IsmChatCallMeetingLiveness.markConnected('meet-1');
    IsmChatCallMeetingLiveness.markEnded('meet-2');
    IsmChatCallMeetingLiveness.clear();
    expect(IsmChatCallMeetingLiveness.isLive('meet-1'), isFalse);
    expect(IsmChatCallMeetingLiveness.isConnected('meet-1'), isFalse);
    expect(IsmChatCallMeetingLiveness.isEnded('meet-2'), isFalse);
  });

  test('revision notifies listeners on live / connected / ended', () {
    var ticks = 0;
    void listener() => ticks++;
    IsmChatCallMeetingLiveness.revision.addListener(listener);
    IsmChatCallMeetingLiveness.markLive('meet-1');
    IsmChatCallMeetingLiveness.markConnected('meet-1');
    IsmChatCallMeetingLiveness.markEnded('meet-1');
    IsmChatCallMeetingLiveness.revision.removeListener(listener);
    expect(ticks, greaterThanOrEqualTo(3));
  });
}
