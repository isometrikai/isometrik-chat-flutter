import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatVideoMessage extends StatelessWidget {
  const IsmChatVideoMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final data = IsmChatProperties.chatPageProperties.isShowMessageBlur
        ?.call(context, message);
    return Material(
      color: Colors.transparent,
      child: BlurFilter(
        isBlured: data?.shouldBlured ?? false,
        sigmaX: data?.sigmaX ?? 10,
        sigmaY: data?.sigmaY ?? 10,
        child: Stack(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: (IsmChatResponsive.isWeb(context))
                            ? context.height * .35
                            : context.height * .6,
                      ),
                      margin: IsmChatDimens.edgeInsetsBottom4,
                      child: IsmChatImage(
                        message.attachments?.first.thumbnailUrl ?? '',
                        isNetworkImage: message
                                .attachments?.first.thumbnailUrl?.isValidUrl ??
                            false,
                        isBytes: !(message
                                .attachments?.first.thumbnailUrl?.isValidUrl ??
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
                Icon(
                  Icons.play_circle,
                  size: IsmChatDimens.sixty,
                  color: IsmChatColors.whiteColor,
                ),
                if (message.isUploading == true)
                  Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: IsmChatUtility.circularProgressBar(
                        IsmChatColors.blackColor,
                        IsmChatColors.whiteColor,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
