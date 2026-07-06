import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatImageMessage extends StatefulWidget {
  const IsmChatImageMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  State<IsmChatImageMessage> createState() => _IsmChatImageMessageState();
}

class _IsmChatImageMessageState extends State<IsmChatImageMessage> {
  late final ValueNotifier<bool> _isExpandedNotifier;

  @override
  void initState() {
    super.initState();
    _isExpandedNotifier = ValueNotifier(false);
  }

  @override
  void dispose() {
    _isExpandedNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.message;
    final isSticker = message.isStickerMessage;
    final isGif = message.isGifMessage;
    final maxWidth = isSticker
        ? IsmChatDimens.hundredFourty
        : (IsmChatResponsive.isWeb(context)
            ? context.width * .35
            : context.width * .6);
    final maxHeight = isSticker
        ? IsmChatDimens.hundredFourty
        : (IsmChatResponsive.isWeb(context)
            ? context.height * .35
            : context.height * .6);
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
                IsmChatTapHandler(
                  onTap: () {
                    if (IsmChatUtility.chatPageControllerRegistered) {
                      IsmChatUtility.chatPageController
                          .tapForMediaPreview(message);
                    }
                  },
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
                    ),
                    child: _MessageMediaImage(
                      message: message,
                      isSticker: isSticker,
                      isGif: isGif,
                    ),
                  ),
                ),
                if (!isGif &&
                    !isSticker &&
                    message.metaData?.caption?.isNotEmpty == true) ...[
                  Padding(
                    padding: IsmChatDimens.edgeInsetsTop5,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final caption = message.metaData?.caption ?? '';
                        final textSpan = TextSpan(
                          text: caption,
                          style: message.style,
                        );
                        final textPainter = TextPainter(
                          text: textSpan,
                          maxLines: _isExpandedNotifier.value ? null : 3,
                          textDirection: TextDirection.ltr,
                        )..layout(
                            maxWidth: constraints.maxWidth > 0
                                ? constraints.maxWidth
                                : context.width * 0.7);

                        final didOverflow = textPainter.didExceedMaxLines;

                        return ValueListenableBuilder<bool>(
                          valueListenable: _isExpandedNotifier,
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
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: IsmChatDimens.edgeInsets0,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      _isExpandedNotifier.value = true;
                                    },
                                    child: Text(
                                      'Show more',
                                      style: message.readTextStyle,
                                    ),
                                  ),
                                ),
                              if (isExpanded)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      padding: IsmChatDimens.edgeInsets0,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () {
                                      _isExpandedNotifier.value = false;
                                    },
                                    child: Text(
                                      'Show less',
                                      style: message.readTextStyle,
                                    ),
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
            if (message.isUploading == true &&
                !_MessageMediaImage.hasDisplayableMedia(message))
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
}

class _MessageMediaImage extends StatelessWidget {
  const _MessageMediaImage({
    required this.message,
    required this.isSticker,
    required this.isGif,
  });

  final IsmChatMessageModel message;
  final bool isSticker;
  final bool isGif;

  static bool hasDisplayableMedia(IsmChatMessageModel message) {
    final attachment = message.attachments?.firstOrNull;
    if (attachment == null) {
      return false;
    }
    final mediaUrl = attachment.mediaUrl ?? '';
    if (mediaUrl.isValidUrl) {
      return true;
    }
    if (attachment.bytes != null && attachment.bytes!.isNotEmpty) {
      return true;
    }
    if (!kIsWeb && mediaUrl.isNotEmpty && File(mediaUrl).existsSync()) {
      return true;
    }
    if (kIsWeb && mediaUrl.isNotEmpty && mediaUrl.strigToUnit8List.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final attachment = message.attachments?.firstOrNull;
    final mediaUrl = attachment?.mediaUrl ?? '';
    final bytes = attachment?.bytes;
    final hasNetworkUrl = mediaUrl.isValidUrl;
    final hasBytes = bytes != null && bytes.isNotEmpty;
    final hasLocalFile = !kIsWeb &&
        !hasNetworkUrl &&
        mediaUrl.isNotEmpty &&
        File(mediaUrl).existsSync();
    final fit = isSticker ? BoxFit.contain : BoxFit.cover;
    final borderRadius = isSticker
        ? BorderRadius.zero
        : BorderRadius.circular(IsmChatDimens.eight);

    Widget child;
    if (hasNetworkUrl) {
      child = CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: fit,
        placeholder: (_, __) => const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _mediaError(),
      );
    } else if (hasBytes) {
      child = Image.memory(bytes, fit: fit);
    } else if (hasLocalFile) {
      child = Image.file(File(mediaUrl), fit: fit);
    } else if (IsmChatResponsive.isWeb(context) && mediaUrl.isNotEmpty) {
      final webBytes = mediaUrl.strigToUnit8List;
      child =
          webBytes.isEmpty ? _mediaError() : Image.memory(webBytes, fit: fit);
    } else {
      child = _mediaError();
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }

  Widget _mediaError() => Container(
        alignment: Alignment.center,
        color: IsmChatColors.greyColor.applyIsmOpacity(0.15),
        child: const Icon(Icons.broken_image_outlined),
      );
}
