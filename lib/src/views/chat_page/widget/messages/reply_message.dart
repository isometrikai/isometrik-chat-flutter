import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatReplyMessage extends StatelessWidget {
  const IsmChatReplyMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: BlurFilter.widget(
          isBlured: IsmChatProperties.chatPageProperties.isShowMessageBlur
                  ?.call(context, message) ??
              false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReplyMessage(message),
              IsmChatDimens.boxHeight5,
              ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (IsmChatResponsive.isWeb(context))
                        ? context.height * .04
                        : context.height * .05,
                  ),
                  child: IsmChatMessageWrapperWithMetaData(message)),
            ],
          ),
        ),
      );
}

class _ReplyMessage extends StatelessWidget {
  const _ReplyMessage(this.message);

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) {
          var replyingMyMessage = message.sentByMe ==
              (message.metaData?.replyMessage?.parentMessageInitiator ?? false);
          return Material(
            color: Colors.transparent,
            child: IsmChatTapHandler(
              onTap: () {
                controller.scrollToMessage(message.parentMessageId ?? '');
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: (IsmChatResponsive.isWeb(context))
                        ? context.height * .04
                        : context.height * .05,
                  ),
                  decoration: BoxDecoration(
                    color: (message.sentByMe
                            ? IsmChatColors.whiteColor
                            : IsmChatColors.greyColor)
                        .applyIsmOpacity(0.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      SizedBox(
                        width: IsmChatDimens.four,
                        height: IsmChatDimens.fifty,
                        child: ColoredBox(
                          color: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.replyMessageTheme !=
                                  null
                              ? replyingMyMessage
                                  ? IsmChatConfig.chatTheme.chatPageTheme
                                          ?.replyMessageTheme?.selfMessage ??
                                      IsmChatColors.yellowColor
                                  : IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.replyMessageTheme
                                          ?.opponentMessage ??
                                      IsmChatColors.blueColor
                              : replyingMyMessage
                                  ? IsmChatColors.yellowColor
                                  : IsmChatColors.blueColor,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          spacing: IsmChatDimens.five,
                          children: [
                            Padding(
                              padding: IsmChatDimens.edgeInsets4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Builder(builder: (context) {
                                    var name = '';

                                    if (controller.conversation?.isGroup ??
                                        false) {
                                      if (replyingMyMessage) {
                                        name = IsmChatStrings.you;
                                      } else {
                                        name = ((controller.conversation
                                                                ?.members ??
                                                            [])
                                                        .firstWhereOrNull(
                                                          (e) =>
                                                              message
                                                                  .metaData
                                                                  ?.replyMessage
                                                                  ?.parentMessageUserId ==
                                                              e.userId,
                                                        )
                                                        ?.userName ??
                                                    controller.conversation
                                                        ?.chatName ??
                                                    '')
                                                .capitalizeFirst ??
                                            '';
                                      }
                                    } else {
                                      name = replyingMyMessage
                                          ? IsmChatStrings.you
                                          : controller.conversation?.replyName
                                                  .capitalizeFirst ??
                                              '';
                                    }

                                    return Text(
                                      name,
                                      style: IsmChatStyles.w500Black14.copyWith(
                                        fontSize: IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.replyMessageTheme !=
                                                null
                                            ? IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.replyMessageTheme
                                                ?.fontSizeMessage
                                            : IsmChatDimens.forteen,
                                        color: IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.replyMessageTheme !=
                                                null
                                            ? replyingMyMessage
                                                ? IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.replyMessageTheme
                                                    ?.selfMessage
                                                : IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.replyMessageTheme
                                                    ?.opponentMessage
                                            : replyingMyMessage
                                                ? IsmChatColors.yellowColor
                                                : IsmChatColors.blueColor,
                                      ),
                                    );
                                  }),
                                  Row(
                                    children: [
                                      _replayParentIcon(message),
                                      IsmChatDimens.boxWidth4,
                                      Text(
                                        IsmChatUtility.decodeString(message
                                                .metaData
                                                ?.replyMessage
                                                ?.parentMessageBody ??
                                            ''),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: message.style,
                                      ),
                                      if (message.metaData?.replyMessage
                                              ?.parentMessageMessageType ==
                                          IsmChatCustomMessageType.audio) ...[
                                        Text(
                                          ' (${Duration(seconds: message.metaData?.replyMessage?.parentMessageAttachmentDuration ?? 0).formatDuration})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: message.style,
                                        )
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            ReplayParentMessage(
                              replayData: message.metaData?.replyMessage,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );

  Widget _replayParentIcon(IsmChatMessageModel? message) {
    final messageType =
        message?.metaData?.replyMessage?.parentMessageMessageType;
    final icon = switch (messageType) {
      IsmChatCustomMessageType.image => Icons.image_outlined,
      IsmChatCustomMessageType.video => Icons.play_circle_outlined,
      IsmChatCustomMessageType.audio => Icons.mic_outlined,
      IsmChatCustomMessageType.location => Icons.location_on_outlined,
      IsmChatCustomMessageType.file => Icons.description_outlined,
      IsmChatCustomMessageType.contact => Icons.contact_page_outlined,
      _ => null,
    };
    if (icon == null) return IsmChatDimens.box0;
    return Icon(
      icon,
      color: message?.style.color ?? IsmChatColors.greyColor,
      size: IsmChatDimens.twenty,
    );
  }
}

class ReplayParentMessage extends StatelessWidget {
  ReplayParentMessage(
      {super.key, this.replayData, double? height, double? width})
      : _height = height ?? IsmChatDimens.fifty,
        _width = width ?? IsmChatDimens.fifty;

  final IsmChatReplyMessageModel? replayData;
  final double _height;
  final double _width;
  @override
  Widget build(BuildContext context) {
    try {
      if ([IsmChatCustomMessageType.image, IsmChatCustomMessageType.video]
          .contains(replayData?.parentMessageMessageType)) {
        Uint8List? bytes;
        if (IsmChatCustomMessageType.video ==
                replayData?.parentMessageMessageType &&
            (replayData?.parentMessageAttachmentUrl?.isValidUrl == false)) {
          bytes =
              (replayData?.parentMessageAttachmentUrl ?? '').strigToUnit8List;
        }
        return Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: _height,
              width: _width,
              child: IsmChatImage(
                replayData?.parentMessageAttachmentUrl ?? '',
                isNetworkImage:
                    replayData?.parentMessageAttachmentUrl?.isValidUrl ?? false,
                isBytes: bytes != null,
              ),
            ),
            if (IsmChatCustomMessageType.video ==
                replayData?.parentMessageMessageType) ...[
              const Icon(
                Icons.play_circle_filled_outlined,
                color: IsmChatColors.whiteColor,
              ),
            ]
          ],
        );
      }
      if (IsmChatCustomMessageType.location ==
          replayData?.parentMessageMessageType) {
        var url = replayData?.parentMessageAttachmentUrl ?? '';
        var position = url.position;
        return SizedBox(
          height: _height,
          width: _width,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 10,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('1'),
                position: position,
                infoWindow: const InfoWindow(title: 'Shared Location'),
              )
            },
            myLocationButtonEnabled: false,
            myLocationEnabled: false,
            rotateGesturesEnabled: false,
            scrollGesturesEnabled: false,
            buildingsEnabled: true,
            mapToolbarEnabled: false,
            tiltGesturesEnabled: false,
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            trafficEnabled: false,
          ),
        );
      }
    } catch (_) {
      return IsmChatDimens.box0;
    }
    return IsmChatDimens.box0;
  }
}

class ReplayParentMessagePreview extends StatelessWidget {
  const ReplayParentMessagePreview({
    super.key,
    required this.controller,
  });

  final IsmChatPageController controller;

  @override
  Widget build(BuildContext context) => Builder(
        builder: (context) {
          final replayMessage = controller.replayMessage;
          final customType = replayMessage?.customType;
          final attachment = replayMessage?.attachments?.isNotEmpty == true
              ? replayMessage?.attachments?.first
              : null;
          final contact = replayMessage?.metaData?.contacts?.isNotEmpty == true
              ? replayMessage?.metaData?.contacts?.first
              : null;
          final attachmentUrl = switch (customType) {
            IsmChatCustomMessageType.audio ||
            IsmChatCustomMessageType.file =>
              attachment?.name,
            IsmChatCustomMessageType.contact => contact?.contactIdentifier,
            IsmChatCustomMessageType.location ||
            IsmChatCustomMessageType.image =>
              attachment?.mediaUrl,
            IsmChatCustomMessageType.video => attachment?.thumbnailUrl,
            _ => replayMessage?.body,
          };
          final replayData = IsmChatReplyMessageModel(
            parentMessageAttachmentUrl: attachmentUrl,
            parentMessageAttachmentDuration:
                replayMessage?.metaData?.duration?.inSeconds,
            parentMessageMessageType: customType,
            parentMessageInitiator: replayMessage?.sentByMe,
            parentMessageBody: replayMessage?.body,
            parentMessageUserId: replayMessage?.senderInfo?.userId,
          );
          return ClipRRect(
            borderRadius: BorderRadius.circular(IsmChatDimens.eight),
            child: ReplayParentMessage(
              replayData: replayData,
              height: IsmChatDimens.fiftyFive,
              width: IsmChatDimens.hundred,
            ),
          );
        },
      );
}
