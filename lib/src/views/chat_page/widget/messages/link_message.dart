import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class IsmChatLinkMessage extends StatelessWidget {
  const IsmChatLinkMessage(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          constraints: IsmChatConfig.chatTheme.chatPageTheme?.messageConstraints
                  ?.textConstraints ??
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
              ),
          child: _LinkPreview(
            message: message,
            link: message.body,
            child: AnyLinkPreview(
              previewHeight: IsmChatDimens.oneHundredFifty,
              bodyMaxLines: 5,
              link: message.body.convertToValidUrl,
              urlLaunchMode: LaunchMode.externalApplication,
              backgroundColor: Colors.transparent,
              removeElevation: true,
              bodyStyle: message.style,
              titleStyle: message.style,
              bodyTextOverflow: TextOverflow.ellipsis,
              cache: const Duration(minutes: 5),
              errorBody: 'Unable to get link preview',
              errorTitle: 'Error',
              errorImage: 'https://google.com/',
              errorWidget: Text(
                IsmChatStrings.errorLoadingPreview,
                style: message.style,
              ),
              displayDirection: UIDirection.uiDirectionHorizontal,
              showMultimedia: true,
              placeholderWidget: Text(
                'Loading preview...',
                style: message.style,
              ),
              // proxyUrl: 'https://corsproxy.io/?',
              // headers: {
              //   'Access-Control-Allow-Origin': '*',
              //   'Access-Control-Allow-Methods': 'GET',
              // },
            ),
          ),
        ),
      );
}

class _LinkPreview extends StatelessWidget {
  const _LinkPreview({
    required this.child,
    required this.message,
    required this.link,
  });

  final Widget child;
  final IsmChatMessageModel message;
  final String link;

  @override
  Widget build(BuildContext context) => IsmChatTapHandler(
        onTap: () => launchUrl(Uri.parse(link.convertToValidUrl)),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: message.sentByMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: (message.sentByMe
                          ? IsmChatColors.whiteColor
                          : IsmChatColors.greyColor)
                      .applyIsmOpacity(0.2),
                  borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                ),
                padding: IsmChatDimens.edgeInsets8_10,
                child: child,
              ),
              IsmChatDimens.boxHeight4,
              Padding(
                padding: IsmChatDimens.edgeInsets5,
                child: Text(
                  link,
                  style: message.style.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: message.style.color,
                  ),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
}
