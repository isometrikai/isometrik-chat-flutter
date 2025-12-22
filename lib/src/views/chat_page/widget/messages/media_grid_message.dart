import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';
import 'package:isometrik_chat_flutter/src/utilities/utilities.dart';

/// Widget to display multiple images/videos in a grid layout similar to WhatsApp
class IsmChatMediaGridMessage extends StatelessWidget {
  const IsmChatMediaGridMessage({
    super.key,
    required this.messages,
    required this.sentByMe,
  });

  final List<IsmChatMessageModel> messages;
  final bool sentByMe;

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    final totalCount = messages.length;
    final crossAxisCount = 2; // Always use 2 columns for grid
    final aspectRatio = 1.0;

    // Determine display count and remaining count based on total
    int displayCount;
    int remainingCount;

    if (totalCount == 1) {
      displayCount = 1;
      remainingCount = 0;
    } else if (totalCount == 2) {
      displayCount = 2;
      remainingCount = 0;
    } else if (totalCount == 3) {
      // For 3 items, show 2 items with "+1" overlay
      displayCount = 2;
      remainingCount = 1;
    } else {
      // For 4+ items, show 2x2 grid (4 items) with "+X" overlay on 4th item
      displayCount = 4;
      remainingCount = totalCount > 4 ? totalCount - 4 : 0;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: aspectRatio,
            ),
            itemCount: displayCount,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isImage =
                  message.customType == IsmChatCustomMessageType.image;
              final isVideo =
                  message.customType == IsmChatCustomMessageType.video;

              if (!isImage && !isVideo) {
                return const SizedBox.shrink();
              }

              final mediaUrl = isImage
                  ? message.attachments?.first.mediaUrl ?? ''
                  : message.attachments?.first.thumbnailUrl ?? '';

              // Check if it's a valid network URL
              final isNetworkImage = mediaUrl.isValidUrl;

              // For web, check if it's bytes (stored as string representation)
              final isBytes = !isNetworkImage &&
                  IsmChatResponsive.isWeb(context) &&
                  mediaUrl.isNotEmpty &&
                  (mediaUrl.startsWith('[') || mediaUrl.contains('blob'));

              // Check if it's a local file path that exists
              final isLocalFile =
                  !isNetworkImage && !isBytes && mediaUrl.isNotEmpty && !kIsWeb;

              // Check if we should show remaining count overlay
              // For 3 items: show on index 1 (second item)
              // For 4+ items: show on index 3 (fourth item)
              final showRemainingCount = remainingCount > 0 &&
                  ((totalCount == 3 && index == 1) ||
                      (totalCount >= 4 && index == 3));

              return IsmChatTapHandler(
                onTap: () {
                  if (IsmChatUtility.chatPageControllerRegistered) {
                    // If tapping on the "+X" item, open preview starting from the next item
                    IsmChatMessageModel messageToShow;
                    if (showRemainingCount) {
                      if (totalCount == 3) {
                        // For 3 items, "+1" is on index 1, so start from index 2
                        messageToShow = messages[2];
                      } else {
                        // For 4+ items, "+X" is on index 3, so start from index 4
                        messageToShow =
                            messages.length > 4 ? messages[4] : message;
                      }
                    } else {
                      messageToShow = message;
                    }
                    IsmChatUtility.chatPageController
                        .tapForMediaPreview(messageToShow);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: _buildGridImage(
                        mediaUrl,
                        isNetworkImage,
                        isBytes,
                        isLocalFile,
                      ),
                    ),
                    if (showRemainingCount)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            '+$remainingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black54,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    if (isVideo && !showRemainingCount)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_circle,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    if (message.isUploading == true && !showRemainingCount)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: IsmChatUtility.circularProgressBar(
                          IsmChatColors.blackColor,
                          IsmChatColors.whiteColor,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        // Show caption if any message has a caption
        if (_hasCaption(messages))
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 0),
            child: _buildCaption(context),
          ),
      ],
    );
  }

  bool _hasCaption(List<IsmChatMessageModel> messages) {
    return messages.any((msg) => msg.metaData?.caption?.isNotEmpty == true);
  }

  Widget _buildCaption(BuildContext context) {
    // Get the first message with a caption, or use the last message
    final messageWithCaption = messages.firstWhere(
      (msg) => msg.metaData?.caption?.isNotEmpty == true,
      orElse: () => messages.last,
    );

    final caption = messageWithCaption.metaData?.caption ?? '';
    if (caption.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      caption,
      style: messageWithCaption.style,
      textAlign: TextAlign.start,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
    );
  }

  Widget _buildGridImage(
    String imageUrl,
    bool isNetworkImage,
    bool isBytes,
    bool isLocalFile,
  ) {
    if (isNetworkImage) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
          child: const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
          child: const Icon(Icons.error_outline),
        ),
      );
    } else if (isBytes) {
      final bytes = imageUrl.strigToUnit8List;
      if (bytes.isEmpty) {
        return Container(
          color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
          child: const Icon(Icons.error_outline),
        );
      }
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
      );
    } else if (isLocalFile) {
      // Check if file exists before trying to load it
      final file = File(imageUrl);
      if (file.existsSync()) {
        try {
          return Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
              child: const Icon(Icons.error_outline),
            ),
          );
        } catch (e) {
          return Container(
            color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
            child: const Icon(Icons.error_outline),
          );
        }
      } else {
        // File doesn't exist - might be a network URL that wasn't detected properly
        // Try treating it as network URL
        if (imageUrl.isNotEmpty) {
          return CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
              child: const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
              child: const Icon(Icons.error_outline),
            ),
          );
        }
        return Container(
          color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
          child: const Icon(Icons.error_outline),
        );
      }
    } else {
      // Fallback - try as network URL if URL is not empty
      if (imageUrl.isNotEmpty) {
        return CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
            child: const Icon(Icons.error_outline),
          ),
        );
      }
      return Container(
        color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
        child: const Icon(Icons.error_outline),
      );
    }
  }
}
