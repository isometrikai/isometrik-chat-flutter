import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/views/chat_page/widget/messages/media_grid_message.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble({
    super.key,
    IsmChatMessageModel? message,
    this.showMessageInCenter = false,
    this.index,
  })  : _message = message ??
            IsmChatMessageModel(
              body: '',
              sentAt: 0,
              customType: IsmChatCustomMessageType.text,
              sentByMe: true,
            ),
        _globalKey = IsmChatResponsive.isWeb(
                IsmChatConfig.kNavigatorKey.currentContext ??
                    IsmChatConfig.context)
            ? GlobalKey()
            : IsmChatUtility.chatPageController
                .getGlobalKey(message?.sentAt ?? 0);

  final IsmChatMessageModel _message;
  final bool showMessageInCenter;
  final int? index;
  final GlobalKey _globalKey;

  /// Checks if the current message is part of a group of consecutive media messages
  /// Returns the list of grouped messages if this is the first message in the group
  /// Returns null if this message should be hidden (part of a group but not the first)
  List<IsmChatMessageModel>? _getGroupedMediaMessages(
    IsmChatPageController controller,
  ) {
    final isImage = _message.customType == IsmChatCustomMessageType.image;
    final isVideo = _message.customType == IsmChatCustomMessageType.video;

    if (!isImage && !isVideo) {
      return null;
    }

    // Get all messages (excluding date messages) - these are in chronological order
    final allMessages = controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();

    if (allMessages.isEmpty || index == null) {
      return null;
    }

    // Since ListView is reversed, the index in the reversed list corresponds to
    // (allMessages.length - 1 - index) in the chronological list
    final reversedIndex = allMessages.length - 1 - index!;

    if (reversedIndex < 0 || reversedIndex >= allMessages.length) {
      return null;
    }

    final currentMessage = allMessages[reversedIndex];
    final sentByMe = currentMessage.sentByMe;
    final timeWindow =
        10000; // 10 seconds in milliseconds - allows for upload delays
    final groupedMessages = <IsmChatMessageModel>[];

    // Find the first message in the group by going backwards chronologically
    // (which means going forward in the reversed list)
    int groupStartIndex = reversedIndex;
    for (int i = reversedIndex; i >= 0; i--) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;

      // Stop if we hit a non-media message or different sender
      if (!msgIsImage && !msgIsVideo) {
        break;
      }

      if (msg.sentByMe != sentByMe) {
        break;
      }

      // Check if message is within time window
      final timeDiff = (msg.sentAt - currentMessage.sentAt).abs();
      if (timeDiff > timeWindow) {
        break;
      }

      groupStartIndex = i;
    }

    // Now collect all messages in the group starting from groupStartIndex
    for (int i = groupStartIndex; i < allMessages.length; i++) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;

      // Stop if we hit a non-media message or different sender
      if (!msgIsImage && !msgIsVideo) {
        break;
      }

      if (msg.sentByMe != sentByMe) {
        break;
      }

      // Check if message is within time window
      final timeDiff = (msg.sentAt - allMessages[groupStartIndex].sentAt).abs();
      if (timeDiff > timeWindow && groupedMessages.isNotEmpty) {
        break;
      }

      groupedMessages.add(msg);
    }

    // Only return grouped messages if there are 2 or more
    // And only if the current message is the first one in the group
    if (groupedMessages.length >= 2) {
      final firstMessage = groupedMessages.first;
      final isFirstMessage = firstMessage.sentAt == currentMessage.sentAt &&
          (firstMessage.messageId == currentMessage.messageId ||
              (firstMessage.messageId?.isEmpty == true &&
                  currentMessage.messageId?.isEmpty == true));

      // Only return the group if this is the first message
      return isFirstMessage ? groupedMessages : null;
    }

    return null;
  }

  /// Gets appropriate padding based on message type
  /// Reduces bottom padding for grid messages to minimize space above time/status
  EdgeInsets _getPaddingForMessage(IsmChatPageController controller) {
    final groupedMessages = _getGroupedMediaMessages(controller);
    final isGridMessage = groupedMessages != null && groupedMessages.isNotEmpty;

    if (isGridMessage) {
      // Check if any message in the group has a caption
      final hasCaption = groupedMessages.any(
        (msg) => msg.metaData?.caption?.isNotEmpty == true,
      );

      if (hasCaption) {
        // More bottom padding when caption is present to make room for time below caption
        return const EdgeInsets.only(
          top: 5,
          bottom: 25, // Extra space for caption + time
          left: 5,
          right: 5,
        );
      } else {
        // Enough bottom padding for grid messages without caption to show time below grid
        return const EdgeInsets.only(
          top: 5,
          bottom: 20, // Space for time below grid
          left: 5,
          right: 5,
        );
      }
    }

    // Default padding for other messages
    return IsmChatDimens.edgeInsets5_5_5_20;
  }

  /// Gets the bottom position for time/status indicator
  /// Adjusts position when grid message has caption to avoid overlap
  double _getTimeBottomPosition(IsmChatPageController controller) {
    final groupedMessages = _getGroupedMediaMessages(controller);
    final isGridMessage = groupedMessages != null && groupedMessages.isNotEmpty;

    if (isGridMessage) {
      final hasCaption = groupedMessages.any(
        (msg) => msg.metaData?.caption?.isNotEmpty == true,
      );

      if (hasCaption) {
        // Position time lower when caption is present
        return IsmChatDimens.four;
      }
    }

    // Default position
    return IsmChatDimens.four;
  }

  Widget _buildMessageContent(
    BuildContext context,
    IsmChatPageController controller,
  ) {
    final groupedMessages = _getGroupedMediaMessages(controller);

    if (groupedMessages != null && groupedMessages.isNotEmpty) {
      // If we got grouped messages, it means this IS the first message in the group
      // Show grid for the first message
      return IsmChatMediaGridMessage(
        messages: groupedMessages,
        sentByMe: _message.sentByMe,
      );
    }

    // Check if this message should be hidden (it's part of a group but not the first)
    final shouldHide = _shouldHideMessage(controller);
    if (shouldHide) {
      return const SizedBox.shrink();
    }

    // Show normal message wrapper for non-grouped messages
    return IsmChatMessageWrapper(_message);
  }

  /// Checks if this message should be hidden because it's part of a group
  /// but not the first message in that group
  bool _shouldHideMessage(IsmChatPageController controller) {
    final isImage = _message.customType == IsmChatCustomMessageType.image;
    final isVideo = _message.customType == IsmChatCustomMessageType.video;

    if (!isImage && !isVideo) {
      return false;
    }

    // Get all messages (excluding date messages) - these are in chronological order
    final allMessages = controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();

    if (allMessages.isEmpty || index == null) {
      return false;
    }

    final reversedIndex = allMessages.length - 1 - index!;
    if (reversedIndex < 0 || reversedIndex >= allMessages.length) {
      return false;
    }

    final currentMessage = allMessages[reversedIndex];
    final sentByMe = currentMessage.sentByMe;
    final timeWindow =
        10000; // 10 seconds in milliseconds - allows for upload delays
    final groupedMessages = <IsmChatMessageModel>[];

    // Find the first message in the group
    int groupStartIndex = reversedIndex;
    for (int i = reversedIndex; i >= 0; i--) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;

      if (!msgIsImage && !msgIsVideo) break;
      if (msg.sentByMe != sentByMe) break;

      final timeDiff = (msg.sentAt - currentMessage.sentAt).abs();
      if (timeDiff > timeWindow) break;

      groupStartIndex = i;
    }

    // Collect all messages in the group
    for (int i = groupStartIndex; i < allMessages.length; i++) {
      final msg = allMessages[i];
      final msgIsImage = msg.customType == IsmChatCustomMessageType.image;
      final msgIsVideo = msg.customType == IsmChatCustomMessageType.video;

      if (!msgIsImage && !msgIsVideo) break;
      if (msg.sentByMe != sentByMe) break;

      final timeDiff = (msg.sentAt - allMessages[groupStartIndex].sentAt).abs();
      if (timeDiff > timeWindow && groupedMessages.isNotEmpty) break;

      groupedMessages.add(msg);
    }

    // If there are 2+ messages in the group and this is not the first, hide it
    if (groupedMessages.length >= 2) {
      final firstMessage = groupedMessages.first;
      final isFirstMessage = firstMessage.sentAt == currentMessage.sentAt &&
          (firstMessage.messageId == currentMessage.messageId ||
              (firstMessage.messageId?.isEmpty == true &&
                  currentMessage.messageId?.isEmpty == true));

      return !isFirstMessage;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_message.sentByMe &&
                IsmChatResponsive.isWeb(context) &&
                !showMessageInCenter &&
                (IsmChatProperties.chatPageProperties.shouldShowHoverHold
                        ?.call(context, controller.conversation, _message) ??
                    true)) ...[
              _OnMessageHoverWeb(
                controller: controller,
                globalKey: _globalKey,
                index: index ?? 0,
                message: _message,
              ),
              IsmChatDimens.boxWidth8,
            ],
            Container(
              key: IsmChatResponsive.isWeb(context) ? _globalKey : null,
              margin:
                  _message.reactions?.isNotEmpty == true && !showMessageInCenter
                      ? IsmChatDimens.edgeInsetsB25
                      : null,
              padding: showMessageInCenter ? IsmChatDimens.edgeInsets4 : null,
              constraints: showMessageInCenter
                  ? BoxConstraints(
                      maxWidth: context.width * .8,
                      minWidth: context.width * .1,
                    )
                  : IsmChatConfig.chatTheme.chatPageTheme?.messageConstraints
                          ?.messageConstraints ??
                      BoxConstraints(
                        maxWidth: (IsmChatResponsive.isWeb(context))
                            ? context.width * .25
                            : context.width * .6,
                        minWidth: IsmChatResponsive.isWeb(context)
                            ? context.width * .05
                            : context.width * .25,
                      ),
              decoration: showMessageInCenter
                  ? null
                  : BoxDecoration(
                      color: _message.backgroundColor,
                      gradient: _message.gradient,
                      border: _message.borderColor != null
                          ? Border.all(color: _message.borderColor!)
                          : null,
                      borderRadius: _message.sentByMe
                          ? IsmChatConfig.chatTheme.chatPageTheme
                                  ?.selfMessageTheme?.borderRadius ??
                              BorderRadius.circular(IsmChatDimens.twelve)
                                  .copyWith(
                                bottomRight:
                                    Radius.circular(IsmChatDimens.four),
                              )
                          : IsmChatConfig.chatTheme.chatPageTheme
                                  ?.opponentMessageTheme?.borderRadius ??
                              BorderRadius.circular(IsmChatDimens.twelve)
                                  .copyWith(
                                topLeft: Radius.circular(IsmChatDimens.four),
                              ),
                    ),
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: !showMessageInCenter
                        ? (IsmChatProperties.chatPageProperties.messageStatus
                                    ?.shouldShowTimeStatusInner ??
                                true)
                            ? _getPaddingForMessage(controller)
                            : IsmChatDimens.edgeInsets5
                        : IsmChatDimens.edgeInsets0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: _message.sentByMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!showMessageInCenter &&
                                (controller.conversation?.isGroup ?? false) &&
                                !_message.sentByMe) ...[
                              Padding(
                                padding: IsmChatDimens.edgeInsetsL2,
                                child: FittedBox(
                                  child: Builder(builder: (context) {
                                    var name = '';
                                    if (IsmChatProperties.chatPageProperties
                                            .messageSenderName
                                            ?.call(
                                          context,
                                          _message,
                                          controller.conversation,
                                        ) !=
                                        null) {
                                      name = IsmChatProperties
                                              .chatPageProperties
                                              .messageSenderName
                                              ?.call(
                                            context,
                                            _message,
                                            controller.conversation,
                                          ) ??
                                          '';
                                    } else {
                                      name =
                                          '${_message.senderInfo?.metaData?.firstName ?? ''} ${_message.senderInfo?.metaData?.lastName ?? ''}';
                                    }
                                    return IsmChatProperties.chatPageProperties
                                            .messageSenderNameBuilder
                                            ?.call(
                                          context,
                                          _message,
                                          controller.conversation,
                                        ) ??
                                        Text(
                                          name.trim().isNotEmpty
                                              ? name
                                              : _message.senderInfo?.userName ??
                                                  '',
                                          style: IsmChatStyles.w400Black10,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: _message.sentByMe
                                              ? TextAlign.end
                                              : TextAlign.start,
                                          maxLines: 1,
                                        );
                                  }),
                                ),
                              ),
                            ],
                            if (_message.messageType ==
                                IsmChatMessageType.forward) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.shortcut_outlined,
                                    color: IsmChatColors.whiteColor,
                                    size: IsmChatDimens.fifteen,
                                  ),
                                  Text(
                                    IsmChatStrings.forwarded,
                                    style: _message.sentByMe
                                        ? IsmChatStyles.w400White12.copyWith(
                                            color: IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.selfMessageTheme
                                                    ?.textColor ??
                                                IsmChatColors.whiteColor,
                                          )
                                        : IsmChatStyles.w400Black12.copyWith(
                                            color: IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.selfMessageTheme
                                                    ?.textColor ??
                                                IsmChatColors.blackColor,
                                          ),
                                  ),
                                ],
                              )
                            ],
                          ],
                        ),
                        _buildMessageContent(context, controller)
                      ],
                    ),
                  ),
                  if (!showMessageInCenter &&
                      (IsmChatProperties.chatPageProperties.messageStatus
                              ?.shouldShowTimeStatusInner ??
                          true)) ...[
                    Positioned(
                      bottom: _getTimeBottomPosition(controller),
                      right: IsmChatDimens.ten,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: _message.sentByMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            if (IsmChatProperties.chatPageProperties
                                    .messageStatus?.shouldShowMessageTime ??
                                true) ...[
                              Text(
                                _message.sentAt.toTimeString,
                                style: _message.timeStyle,
                              )
                            ],
                            if ((IsmChatProperties
                                        .chatPageProperties
                                        .messageStatus
                                        ?.shouldShowMessgaeStatus ??
                                    true) &&
                                _message.sentByMe &&
                                ![
                                  IsmChatCustomMessageType.oneToOneCall,
                                  IsmChatCustomMessageType.deletedForEveryone
                                ].contains(_message.customType)) ...[
                              if (_message.messageId?.isEmpty == true) ...[
                                IsmChatDimens.boxWidth2,
                                if (_message.isInvalidMessage == true) ...[
                                  Icon(
                                    Icons.error_outlined,
                                    color: IsmChatConfig
                                            .chatTheme
                                            .chatPageTheme
                                            ?.messageStatusTheme
                                            ?.inValidIconColor ??
                                        IsmChatColors.redColor,
                                    size: IsmChatConfig.chatTheme.chatPageTheme
                                            ?.messageStatusTheme?.checkSize ??
                                        IsmChatDimens.forteen,
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.watch_later_outlined,
                                    color: IsmChatConfig
                                            .chatTheme
                                            .chatPageTheme
                                            ?.messageStatusTheme
                                            ?.unreadCheckColor ??
                                        IsmChatColors.whiteColor,
                                    size: IsmChatConfig.chatTheme.chatPageTheme
                                            ?.messageStatusTheme?.checkSize ??
                                        IsmChatDimens.forteen,
                                  ),
                                ]
                              ] else if (IsmChatProperties
                                  .chatPageProperties.features
                                  .contains(
                                IsmChatFeature.showMessageStatus,
                              )) ...[
                                IsmChatDimens.boxWidth2,
                                Icon(
                                  // If readByAll is true, deliveredToAll must also be true
                                  // Always show double checkmark if read
                                  (_message.readByAll ?? false) ||
                                          (_message.deliveredToAll ?? false)
                                      ? Icons.done_all_rounded
                                      : Icons.done_rounded,
                                  color: _message.readByAll ?? false
                                      ? IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.messageStatusTheme
                                              ?.readCheckColor ??
                                          Colors.blue
                                      : IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.messageStatusTheme
                                              ?.unreadCheckColor ??
                                          IsmChatColors.whiteColor,
                                  size: IsmChatConfig.chatTheme.chatPageTheme
                                          ?.messageStatusTheme?.checkSize ??
                                      IsmChatDimens.forteen,
                                ),
                              ]
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (!_message.sentByMe &&
                IsmChatResponsive.isWeb(context) &&
                !showMessageInCenter &&
                (IsmChatProperties.chatPageProperties.shouldShowHoverHold
                        ?.call(context, controller.conversation, _message) ??
                    true)) ...[
              IsmChatDimens.boxWidth8,
              _OnMessageHoverWeb(
                controller: controller,
                globalKey: _globalKey,
                index: index ?? 0,
                message: _message,
              )
            ],
          ],
        ),
      );
}

class _OnMessageHoverWeb extends StatelessWidget {
  const _OnMessageHoverWeb({
    required this.controller,
    required this.message,
    required this.index,
    required this.globalKey,
  });

  final IsmChatPageController controller;
  final IsmChatMessageModel message;
  final int index;
  final GlobalKey globalKey;

  @override
  Widget build(BuildContext context) => Obx(
        () => (controller.onMessageHoverIndex == index &&
                    IsmChatResponsive.isWeb(context)) &&
                message.customType !=
                    IsmChatCustomMessageType.deletedForEveryone
            ? IsmChatTapHandler(
                onTap: () {
                  if (controller.holdController?.isCompleted == true &&
                      controller.messageHoldOverlayEntry != null) {
                    controller.closeOverlay();
                  } else {
                    if (!(controller.conversation?.isChattingAllowed == true)) {
                      controller.showDialogCheckBlockUnBlock();
                    } else {
                      controller.holdController?.forward();
                      controller.showOverlayWeb(
                        globalKey.currentContext ?? context,
                        message,
                        controller.holdAnimation!,
                      );
                    }
                  }
                },
                child: Container(
                  padding: IsmChatConfig.chatTheme.chatPageTheme
                          ?.messageHoverTheme?.padding ??
                      IsmChatDimens.edgeInsets5,
                  decoration: BoxDecoration(
                    color: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messageHoverTheme?.backgroundColor ??
                        message.backgroundColor,
                    borderRadius: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messageHoverTheme?.borderRadius ??
                        BorderRadius.circular(IsmChatDimens.fifty),
                  ),
                  child: Icon(
                    Icons.expand_more_rounded,
                    color: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messageHoverTheme?.iconColor ??
                        message.textColor,
                    size: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messageHoverTheme?.iconSize ??
                        IsmChatDimens.twenty,
                  ),
                ))
            : IsmChatDimens.box0,
      );
}
