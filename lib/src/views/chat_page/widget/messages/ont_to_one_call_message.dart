import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class IsmOneToOneCallMessage extends StatelessWidget {
  const IsmOneToOneCallMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: IntrinsicWidth(
          child: Container(
              alignment: message.sentByMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              constraints: const BoxConstraints(
                minHeight: 40,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                color: message.textColor?.withOpacity(.2),
              ),
              padding: IsmChatDimens.edgeInsets10,
              child: oneToOneCallWidget(message)),
        ),
      );

  Widget oneToOneCallWidget(IsmChatMessageModel message) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            decoration: BoxDecoration(
                color: message.textColor?.withOpacity(.2),
                borderRadius: BorderRadius.circular(IsmChatDimens.fifty)),
            padding: IsmChatDimens.edgeInsets10,
            child: Icon(
              message.meetingType == 0
                  ? message.sentByMe
                      ? Icons.call_outlined
                      : Icons.phone_callback_outlined
                  : message.sentByMe
                      ? Icons.video_call_outlined
                      : Icons.missed_video_call_outlined,
              color: message.textColor,
            ),
          ),
          IsmChatDimens.boxWidth8,
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (message.callDurations?.length != 1 ||
                        message.action ==
                            IsmChatActionEvents.meetingCreated.name)
                    ? '${message.meetingType == 0 ? 'Voice' : 'Video'} call'
                    : 'Missed ${message.meetingType == 0 ? 'voice' : 'video'} call',
                style: message.style,
              ),
              if (message.callDurations?.length == 1) ...[
                Text(
                  message.sentByMe ? 'No answer' : 'Please call back',
                  style: message.style.copyWith(
                    fontSize: IsmChatDimens.twelve,
                  ),
                ),
              ] else if (message.action ==
                  IsmChatActionEvents.meetingCreated.name) ...[
                Text(
                  'In call',
                  style: message.style.copyWith(
                    fontSize: IsmChatDimens.twelve,
                  ),
                ),
              ] else ...[
                Builder(builder: (context) {
                  final smaleValue = message.callDurations?.reduce(
                      (value, element) => (value.durationInMilliseconds ?? 0) <
                              (element.durationInMilliseconds ?? 0)
                          ? value
                          : element);
                  final time = Duration(
                      milliseconds: smaleValue?.durationInMilliseconds ?? 0);
                  return Text(
                    time.formatDuration(),
                    style: message.style.copyWith(
                      fontSize: IsmChatDimens.twelve,
                    ),
                  );
                }),
              ]
            ],
          ),
        ],
      );
}
