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
                  onLongPress: () {
                    if (IsmChatUtility.chatPageControllerRegistered) {
                      IsmChatUtility.chatPageController.onMessageLongPress(
                        context,
                        message,
                      );
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
                      maxWidth: maxWidth,
                      maxHeight: maxHeight,
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
    required this.maxWidth,
    required this.maxHeight,
  });

  final IsmChatMessageModel message;
  final bool isSticker;
  final bool isGif;
  final double maxWidth;
  final double maxHeight;

  /// GIFs decode at full intrinsic size unless boxed — reserve space up front.
  static Size _gifDisplaySize(double maxWidth, double maxHeight) {
    var width = maxWidth;
    const aspectRatio = 1.0;
    var height = width / aspectRatio;
    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }
    return Size(width, height);
  }

  static Widget _loadingPlaceholder(Size size) => SizedBox(
        width: size.width,
        height: size.height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator.adaptive(strokeWidth: 2),
          ),
        ),
      );

  static Widget _placeholderImage({
    required Size size,
    required String? imageUrl,
    required BoxFit fit,
  }) {
    if (imageUrl == null || !imageUrl.isValidUrl) {
      return _loadingPlaceholder(size);
    }
    return SizedBox(
      width: size.width,
      height: size.height,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        placeholder: (_, __) => _loadingPlaceholder(size),
        errorWidget: (_, __, ___) => _loadingPlaceholder(size),
      ),
    );
  }

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
    final fit = isSticker || isGif ? BoxFit.contain : BoxFit.cover;
    final borderRadius = isSticker
        ? BorderRadius.zero
        : BorderRadius.circular(IsmChatDimens.eight);
    final gifSize = isGif ? _gifDisplaySize(maxWidth, maxHeight) : null;
    final placeholderUrl = isGif
        ? _gifPlaceholderUrl(attachment)
        : null;

    Widget child;
    if (hasNetworkUrl) {
      child = CachedNetworkImage(
        imageUrl: mediaUrl,
        fit: fit,
        width: gifSize?.width,
        height: gifSize?.height,
        placeholder: (_, __) => _placeholderImage(
          size: gifSize ?? Size(maxWidth, maxHeight),
          imageUrl: placeholderUrl,
          fit: fit,
        ),
        errorWidget: (_, __, ___) => _mediaError(gifSize),
      );
    } else if (hasBytes) {
      child = Image.memory(
        bytes,
        fit: fit,
        width: gifSize?.width,
        height: gifSize?.height,
      );
    } else if (hasLocalFile) {
      child = Image.file(
        File(mediaUrl),
        fit: fit,
        width: gifSize?.width,
        height: gifSize?.height,
      );
    } else if (IsmChatResponsive.isWeb(context) && mediaUrl.isNotEmpty) {
      final webBytes = mediaUrl.strigToUnit8List;
      child = webBytes.isEmpty
          ? _mediaError(gifSize)
          : Image.memory(
              webBytes,
              fit: fit,
              width: gifSize?.width,
              height: gifSize?.height,
            );
    } else {
      child = _mediaError(gifSize);
    }

    final media = gifSize != null
        ? SizedBox(width: gifSize.width, height: gifSize.height, child: child)
        : child;

    return ClipRRect(
      borderRadius: borderRadius,
      child: media,
    );
  }

  /// Prefer still frame while the animated GIF loads (Giphy sends this).
  static String? _gifPlaceholderUrl(AttachmentModel? attachment) {
    if (attachment == null) return null;
    final still = attachment.stillUrl ?? '';
    if (still.isValidUrl) return still;
    final thumb = attachment.thumbnailUrl ?? '';
    if (thumb.isValidUrl) return thumb;
    return null;
  }

  Widget _mediaError(Size? gifSize) => Container(
        width: gifSize?.width,
        height: gifSize?.height,
        alignment: Alignment.center,
        color: IsmChatColors.greyColor.applyIsmOpacity(0.15),
        child: const Icon(Icons.broken_image_outlined),
      );
}
