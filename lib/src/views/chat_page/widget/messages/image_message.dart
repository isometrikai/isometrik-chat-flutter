import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatImageMessage extends StatelessWidget {
  const IsmChatImageMessage(this.message, {super.key});

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
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: IsmChatDimens.edgeInsetsBottom4,
                    constraints: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messageConstraints?.imageConstraints ??
                        BoxConstraints(
                          maxWidth: (IsmChatResponsive.isWeb(context))
                              ? context.width * .25
                              : context.width * .7,
                          maxHeight: (IsmChatResponsive.isWeb(context))
                              ? context.height * .35
                              : context.height * .7,
                        ),
                    child: IsmChatImage(
                      message.attachments?.first.mediaUrl ?? '',
                      isNetworkImage:
                          message.attachments?.first.mediaUrl?.isValidUrl ??
                              false,
                      isBytes:
                          !(message.attachments?.first.mediaUrl?.isValidUrl ??
                              false),
                    ),
                  ),
                  if (message.metaData?.caption?.isNotEmpty == true) ...[
                    Padding(
                      padding: IsmChatDimens.edgeInsetsTop5,
                      child: Text(
                        message.metaData?.caption ?? '',
                        style: message.style,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    )
                  ]
                ],
              ),
              if (message.isUploading == true)
                IsmChatUtility.circularProgressBar(
                  IsmChatColors.blackColor,
                  IsmChatColors.whiteColor,
                ),
            ],
          ),
        ),
      );
}
