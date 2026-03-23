import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatImageMessage extends StatelessWidget {
  IsmChatImageMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  final isExpandedNotifier = ValueNotifier(false);

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
                  child: IsmChatImage(
                    message.attachments?.first.mediaUrl ?? '',
                    isNetworkImage:
                        message.attachments?.first.mediaUrl?.isValidUrl ??
                            false,
                    isBytes: (IsmChatResponsive.isWeb(context)) ? true : false,
                  ),
                ),
                if (message.metaData?.caption?.isNotEmpty == true) ...[
                  Padding(
                    padding: IsmChatDimens.edgeInsetsTop5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final caption = message.metaData?.caption ?? '';
                        // Determine if caption is overflowing right now given expansion state:
                        final textSpan = TextSpan(
                          text: caption,
                          style: message.style,
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          maxLines: isExpandedNotifier.value ? null : 3,
                          textDirection: TextDirection.ltr,
                        )..layout(
                            maxWidth: constraints.maxWidth > 0
                                ? constraints.maxWidth
                                : context.width * 0.7);

                        final didOverflow = textPainter.didExceedMaxLines;

                        return ValueListenableBuilder<bool>(
                          valueListenable: isExpandedNotifier,
                          builder: (context, isExpanded, _) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                caption,
                                style: message.style,
                                textAlign: TextAlign.start,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                maxLines: isExpanded ? null : 3,
                              ),
                              if (!isExpanded && didOverflow)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: IsmChatDimens.edgeInsets0,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    isExpandedNotifier.value = true;
                                  },
                                  child: Text(
                                    'Show more',
                                    style: message.readTextStyle,
                                  ),
                                ),
                              if (isExpanded)
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: IsmChatDimens.edgeInsets0,
                                    minimumSize: const Size(0, 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () {
                                    isExpandedNotifier.value = false;
                                  },
                                  child: Text(
                                    'Show less',
                                    style: message.readTextStyle,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ]
              ],
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
    );
  }

  bool _isCaptionOverflowing(BuildContext context) {
    final caption = message.metaData?.caption ?? '';
    if (caption.isEmpty) return false;

    final textSpan = TextSpan(
      text: caption,
      style: message.style,
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 3,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: context.width * 0.7);

    return textPainter.didExceedMaxLines;
  }
}
