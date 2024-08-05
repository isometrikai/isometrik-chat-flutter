import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

/// ConversationMediaWidget is a widget to show the media item
class ConversationMediaWidget extends StatelessWidget {
  const ConversationMediaWidget({
    super.key,
    required this.media,
    required this.iconData,
    required this.url,
  });

  final IsmChatMessageModel media;
  final IconData iconData;
  final String url;

  @override
  Widget build(BuildContext context) => Container(
        height: IsmChatDimens.hundred,
        width: IsmChatDimens.hundred,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: IsmChatConfig.chatTheme.backgroundColor,
          borderRadius: BorderRadius.circular(
            IsmChatDimens.ten,
          ),
        ),
        child: [IsmChatCustomMessageType.audio, IsmChatCustomMessageType.file]
                .contains(media.customType)
            ? Icon(
                iconData,
                color: IsmChatConfig.chatTheme.primaryColor,
              )
            : IsmChatImage(
                url,
                isNetworkImage: url.isValidUrl,
              ),
      );
}
