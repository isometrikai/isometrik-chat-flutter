import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAboutTextMessage extends StatelessWidget {
  const IsmChatAboutTextMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  constraints: IsmChatConfig.chatTheme.chatPageTheme
                          ?.messageConstraints?.textConstraints ??
                      BoxConstraints(
                        maxWidth: (IsmChatResponsive.isWeb(context))
                            ? context.width * .3
                            : context.width * .7,
                        minWidth: IsmChatResponsive.isWeb(context)
                            ? context.width * .05
                            : context.width * .2,
                        minHeight: (IsmChatResponsive.isWeb(context))
                            ? context.height * .04
                            : context.height * .05,
                        // maxHeight: (IsmChatResponsive.isWeb(context))
                        //     ? context.height * .3
                        //     : context.height * .7,
                      ),
                  padding: IsmChatDimens.edgeInsets10,
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                    border: Border.all(
                      color: IsmChatColors.whiteColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.metaData?.aboutText?.title ?? '',
                        style: message.style.copyWith(
                          fontSize: IsmChatDimens.twelve,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        message.metaData?.aboutText?.subTitle ?? '',
                        style: message.style.copyWith(
                          fontSize: IsmChatDimens.fifteen,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 4,
                      )
                    ],
                  ),
                ),
                Container(
                  padding: IsmChatDimens.edgeInsetsTop5,
                  width: IsmChatDimens.percentWidth(.6),
                  child: Text(
                    message.body,
                    style: message.style.copyWith(
                      fontSize: IsmChatDimens.tharteen,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                )
              ],
            ),
          ],
        ),
      );
}
