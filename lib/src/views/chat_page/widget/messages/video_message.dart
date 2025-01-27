import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatVideoMessage extends StatelessWidget {
  const IsmChatVideoMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: BlurFilter(
          isNotBlured: IsmChatProperties
                  .chatPageProperties.isShowMediaMeessageBlure
                  ?.call(context, message) ??
              true,
          child: Stack(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: IsmChatDimens.edgeInsetsBottom4,
                        constraints: IsmChatConfig.chatTheme.chatPageTheme
                                ?.messageConstraints?.videoConstraints ??
                            BoxConstraints(
                              maxWidth: (IsmChatResponsive.isWeb(context))
                                  ? context.width * .25
                                  : context.width * .7,
                              maxHeight: (IsmChatResponsive.isWeb(context))
                                  ? context.height * .35
                                  : context.height * .7,
                            ),
                        child: IsmChatImage(
                          message.attachments?.first.thumbnailUrl ?? '',
                          isNetworkImage: message.attachments?.first
                                  .thumbnailUrl?.isValidUrl ??
                              false,
                          isBytes: !(message.attachments?.first.thumbnailUrl
                                  ?.isValidUrl ??
                              false),
                        ),
                      ),
                      if (message.metaData?.caption?.isNotEmpty == true) ...[
                        Container(
                          padding: IsmChatDimens.edgeInsetsTop5,
                          width: IsmChatDimens.percentWidth(.6),
                          child: Text(
                            message.metaData?.caption ?? '',
                            style: message.style.copyWith(
                              fontSize: IsmChatDimens.tharteen,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        )
                      ]
                    ],
                  ),
                  Icon(
                    Icons.play_circle,
                    size: IsmChatDimens.sixty,
                    color: IsmChatColors.whiteColor,
                  ),
                  if (message.isUploading == true)
                    IsmChatUtility.circularProgressBar(
                        IsmChatColors.blackColor, IsmChatColors.whiteColor),
                ],
              ),
            ],
          ),
        ),
      );
}
