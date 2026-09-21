import 'package:flutter_test/flutter_test.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

IsmChatMessageModel _callMessage({
  required String meetingId,
  required int sentAt,
  required String action,
  int meetingType = 0,
  String? messageId,
}) =>
    IsmChatMessageModel(
      body: '',
      sentAt: sentAt,
      customType: IsmChatCustomMessageType.oneToOneCall,
      sentByMe: false,
      meetingId: meetingId,
      meetingType: meetingType,
      action: action,
      messageId: messageId ?? 'msg-$sentAt',
    );

void main() {
  group('mergeCallMessageIntoMap', () {
    test('inserts first call row when meetingId is new', () {
      final created = _callMessage(
        meetingId: 'meet-1',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
      );

      final result = IsmChatDBWrapper.mergeCallMessageIntoMap({}, created);

      expect(result.length, 1);
      expect(result['1000']?.action, IsmChatActionEvents.meetingCreated.name);
      expect(result['1000']?.meetingId, 'meet-1');
    });

    test('updates same meetingId in place and keeps anchor sentAt', () {
      final created = _callMessage(
        meetingId: 'meet-1',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
        meetingType: 1,
      );
      final ended = _callMessage(
        meetingId: 'meet-1',
        sentAt: 2000,
        action: IsmChatActionEvents.meetingEndedByHost.name,
        messageId: 'msg-ended',
      );

      var map = IsmChatDBWrapper.mergeCallMessageIntoMap({}, created);
      expect(map.length, 1);
      expect(map.values.first.key, '1000');
      map = IsmChatDBWrapper.mergeCallMessageIntoMap(map, ended);
      expect(map.keys, ['1000'], reason: 'keys after merge: ${map.keys}');
      expect(map.length, 1);
      expect(map.containsKey('1000'), isTrue);
      expect(map.containsKey('2000'), isFalse);
      expect(map['1000']?.action, IsmChatActionEvents.meetingEndedByHost.name);
      expect(map['1000']?.meetingType, 1);
      expect(map['1000']?.sentAt, 1000);
    });

    test('updates same meetingId when ended due to no user publishing', () {
      final created = _callMessage(
        meetingId: 'meet-1',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
      );
      final ended = _callMessage(
        meetingId: 'meet-1',
        sentAt: 2000,
        action: IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
      );

      var map = IsmChatDBWrapper.mergeCallMessageIntoMap({}, created);
      map = IsmChatDBWrapper.mergeCallMessageIntoMap(map, ended);
      expect(map.length, 1);
      expect(
        map['1000']?.action,
        IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
      );
    });

    test('hang-up keeps created messageId and conversationId', () {
      final created = _callMessage(
        meetingId: 'meet-1',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
        messageId: 'msg-created',
      ).copyWith(conversationId: 'conv-1');
      final ended = IsmChatMessageModel(
        body: '',
        sentAt: 2000,
        customType: IsmChatCustomMessageType.videoCall,
        sentByMe: false,
        meetingId: 'meet-1',
        action: IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
        messageId: '',
        conversationId: 'conv-1',
      );

      var map = IsmChatDBWrapper.mergeCallMessageIntoMap({}, created);
      map = IsmChatDBWrapper.mergeCallMessageIntoMap(map, ended);
      expect(map.length, 1);
      expect(map['1000']?.messageId, 'msg-created');
      expect(map['1000']?.conversationId, 'conv-1');
      expect(
        map['1000']?.action,
        IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
      );
      expect(map['1000']?.customType, IsmChatCustomMessageType.videoCall);
    });

    test('hang-up merge keeps per-member callDurations', () {
      final created = _callMessage(
        meetingId: '6ab0fcb0246a5400015d91da',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
      );
      final ended = IsmChatMessageModel(
        body: '',
        sentAt: 2000,
        customType: IsmChatCustomMessageType.audioCall,
        sentByMe: false,
        meetingId: '6ab0fcb0246a5400015d91da',
        action: IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
        conversationId: '69396623a525150001a18fac',
        callDurations: [
          CallDuration(
            memberId: '6926df877953350001bc494d',
            durationInMilliseconds: 9631,
          ),
          CallDuration(
            memberId: '693965ca795335000183d575',
            durationInMilliseconds: 12542,
          ),
        ],
      );

      var map = IsmChatDBWrapper.mergeCallMessageIntoMap({}, created);
      map = IsmChatDBWrapper.mergeCallMessageIntoMap(map, ended);
      expect(map.length, 1);
      expect(map['1000']?.callDurations, ended.callDurations);
      expect(
        map['1000']?.action,
        IsmChatActionEvents.meetingEndedDueToNoUserPublishing.name,
      );
    });

    test('listWidgetKey changes suffix when meeting ends', () {
      final created = _callMessage(
        meetingId: 'meet-1',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
      );
      final ended = _callMessage(
        meetingId: 'meet-1',
        sentAt: 2000,
        action: IsmChatActionEvents.meetingEndedByHost.name,
      );

      expect(created.listWidgetKey, 'call-meet-1');
      expect(ended.listWidgetKey, 'call-meet-1-ended');
    });

    test('listWidgetKey follows session liveness for keep-alive bubbles', () {
      final created = _callMessage(
        meetingId: 'meet-live',
        sentAt: 1000,
        action: IsmChatActionEvents.meetingCreated.name,
      );
      IsmChatCallMeetingLiveness.markLive('meet-live');
      expect(created.listWidgetKey, 'call-meet-live-ring');
      IsmChatCallMeetingLiveness.markConnected('meet-live');
      expect(created.listWidgetKey, 'call-meet-live-in');
      IsmChatCallMeetingLiveness.markEnded('meet-live');
      expect(created.listWidgetKey, 'call-meet-live-ended');
      IsmChatCallMeetingLiveness.clear();
    });

    test('CallDuration.listFrom accepts MQTT Map<dynamic, dynamic> rows', () {
      final parsed = CallDuration.listFrom([
        {'memberId': '6926df877953350001bc494d', 'durationInMilliseconds': 9631},
        {
          'memberId': '693965ca795335000183d575',
          'durationInMilliseconds': 12542,
        },
      ]);
      expect(parsed.length, 2);
      expect(parsed.first.memberId, '6926df877953350001bc494d');
      expect(parsed.first.durationInMilliseconds, 9631);
      expect(parsed.last.durationInMilliseconds, 12542);
    });
  });
}
