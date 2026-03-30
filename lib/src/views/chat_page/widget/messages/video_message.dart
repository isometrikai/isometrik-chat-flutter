import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatVideoMessage extends StatelessWidget {
  IsmChatVideoMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  /// Tracks expand/collapse state for long captions (show more / show less).
  final isExpandedNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    final data = IsmChatProperties.chatPageProperties.isShowMessageBlur
        ?.call(context, message);
    final thumbnailUrl = message.attachments?.first.thumbnailUrl ?? '';
    final isNetworkThumbnail = thumbnailUrl.isValidUrl;
    return Material(
      color: Colors.transparent,
      child: BlurFilter(
        isBlured: data?.shouldBlured ?? false,
        sigmaX: data?.sigmaX ?? 10,
        sigmaY: data?.sigmaY ?? 10,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Keep media interactions isolated to thumbnail.
            IsmChatTapHandler(
              onTap: () {
                if (IsmChatUtility.chatPageControllerRegistered) {
                  IsmChatUtility.chatPageController.tapForMediaPreview(message);
                }
              },
              child: Container(
                margin: IsmChatDimens.edgeInsetsBottom4,
                child: SizedBox.square(
                  // Keep a stable thumbnail size during upload so height doesn't jump.
                  dimension: _thumbnailDimension(context),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IsmChatImage(
                        thumbnailUrl,
                        isNetworkImage: isNetworkThumbnail,
                        isBytes: !isNetworkThumbnail,
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
                ),
              ),
            ),
            if (message.metaData?.caption?.isNotEmpty == true) ...[
              Padding(
                padding: IsmChatDimens.edgeInsetsTop5,
                child: ValueListenableBuilder<bool>(
                  valueListenable: isExpandedNotifier,
                  builder: (context, isExpanded, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.metaData?.caption ?? '',
                        style: message.style,
                        textAlign: TextAlign.start,
                        overflow: isExpanded
                            ? TextOverflow.visible
                            : TextOverflow.ellipsis,
                        maxLines: isExpanded ? null : 3,
                      ),
                      if (_isCaptionOverflowing(context))
                        TextButton(
                          style: TextButton.styleFrom(
                            padding: IsmChatDimens.edgeInsets0,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () {
                            isExpandedNotifier.value = !isExpanded;
                          },
                          child: Text(
                            isExpanded ? 'Show less' : 'Show more',
                            style: message.readTextStyle,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }

  /// Returns true if caption exceeds 3 lines so we can show "Show more" button.
  bool _isCaptionOverflowing(BuildContext context) {
    final caption = message.metaData?.caption ?? '';
    if (caption.isEmpty) return false;

    final textPainter = TextPainter(
      text: TextSpan(text: caption, style: message.style),
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: context.width * 0.7);

    return textPainter.didExceedMaxLines;
  }

  double _thumbnailDimension(BuildContext context) {
    final maxByScreen = IsmChatResponsive.isWeb(context)
        ? context.width * .25
        : context.width * .6;
    final maxByTheme = IsmChatResponsive.isWeb(context)
        ? IsmChatDimens.twoHundredTwenty
        : IsmChatDimens.twoHundredFifty;
    return maxByScreen < maxByTheme ? maxByScreen : maxByTheme;
  }
}
