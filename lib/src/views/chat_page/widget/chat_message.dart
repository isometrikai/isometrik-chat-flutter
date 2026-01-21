import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMessage extends StatefulWidget {
  IsmChatMessage(
    this.index,
    IsmChatMessageModel? message, {
    bool isIgnorTap = false,
    bool isFromSearchMessage = false,
    super.key,
  })  : _message = IsmChatUtility.chatPageControllerRegistered
            ? isFromSearchMessage
                ? IsmChatUtility.chatPageController.searchMessages.reversed
                    .toList()[index]
                : IsmChatUtility.chatPageController.messages.reversed
                    .toList()[index]
            : message,
        _isIgnorTap = isIgnorTap;

  final IsmChatMessageModel? _message;
  final bool? _isIgnorTap;
  final int index;

  @override
  State<IsmChatMessage> createState() => _IsmChatMessageState();
}

class _IsmChatMessageState extends State<IsmChatMessage>
    with AutomaticKeepAliveClientMixin<IsmChatMessage> {
  @override
  bool get wantKeepAlive => mounted;

  final coverstaionController = IsmChatUtility.conversationController;

  late bool showMessageInCenter;
  late bool isGroup;

  void _updateWidget() {
    showMessageInCenter = [
      IsmChatCustomMessageType.date,
      IsmChatCustomMessageType.block,
      IsmChatCustomMessageType.unblock,
      IsmChatCustomMessageType.conversationCreated,
      IsmChatCustomMessageType.removeMember,
      IsmChatCustomMessageType.addMember,
      IsmChatCustomMessageType.addAdmin,
      IsmChatCustomMessageType.removeAdmin,
      IsmChatCustomMessageType.memberLeave,
      IsmChatCustomMessageType.conversationImageUpdated,
      IsmChatCustomMessageType.conversationTitleUpdated,
      IsmChatCustomMessageType.memberJoin,
      IsmChatCustomMessageType.observerJoin,
      IsmChatCustomMessageType.observerLeave,
    ].contains(widget._message?.customType);
    isGroup = coverstaionController.currentConversation?.isGroup ?? false;
  }

  @override
  void initState() {
    super.initState();
    _updateWidget();
  }

  @override
  void didUpdateWidget(covariant IsmChatMessage oldWidget) {
    _updateWidget();
    super.didUpdateWidget(oldWidget);
  }

  /// Checks if this message should be hidden because it's part of a grid group
  /// but not the first message in that group
  bool _shouldHideMessage(IsmChatPageController controller) {
    final isImage =
        widget._message?.customType == IsmChatCustomMessageType.image;
    final isVideo =
        widget._message?.customType == IsmChatCustomMessageType.video;

    if (!isImage && !isVideo) {
      return false;
    }

    // Get all messages (excluding date messages) - these are in chronological order
    final allMessages = controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();

    if (allMessages.isEmpty) {
      return false;
    }

    // Since ListView is reversed, the index in the reversed list corresponds to
    // (allMessages.length - 1 - index) in the chronological list
    final reversedIndex = allMessages.length - 1 - widget.index;

    if (reversedIndex < 0 || reversedIndex >= allMessages.length) {
      return false;
    }

    final currentMessage = allMessages[reversedIndex];
    final sentByMe = currentMessage.sentByMe;
    final timeWindow =
        10000; // 10 seconds in milliseconds - allows for upload delays
    final groupedMessages = <IsmChatMessageModel>[];

    // Find the first message in the group by going backwards chronologically
    // (which means going forward in the reversed list)
    var groupStartIndex = reversedIndex;
    for (var i = reversedIndex; i >= 0; i--) {
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
    for (var i = groupStartIndex; i < allMessages.length; i++) {
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
  Widget build(BuildContext context) {
    super.build(context);
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    return GetBuilder<IsmChatPageController>(
      tag: IsmChat.i.chatPageTag,
      builder: (controller) {
        // Hide the entire message if it's part of a grid but not the first message
        if (IsmChatUtility.chatPageControllerRegistered &&
            _shouldHideMessage(controller)) {
          return const SizedBox.shrink();
        }
        return IgnorePointer(
          ignoring: showMessageInCenter || widget._isIgnorTap!,
          child: IsmChatTapHandler(
            onLongPress: showMessageInCenter ||
                    (IsmChatProperties.chatPageProperties.shouldShowHoverHold
                            ?.call(context, controller.conversation,
                                widget._message!) ??
                        false)
                ? null
                : () async {
                    if (widget._message?.customType !=
                        IsmChatCustomMessageType.deletedForEveryone) {
                      if (!IsmChatResponsive.isWeb(context)) {
                        if (!(controller.conversation?.isChattingAllowed ??
                            false)) {
                          controller.showDialogCheckBlockUnBlock();
                          return;
                        } else {
                          await controller.showOverlay(
                              context, widget._message!);
                        }
                      }
                    } else {
                      controller.isMessageSeleted = true;
                      controller.selectedMessage.add(widget._message!);
                    }
                  },
            onTap: showMessageInCenter
                ? null
                : () {
                    IsmChatUtility.hideKeyboard();
                    controller.onMessageSelect(widget._message!);
                    if (controller.showEmojiBoard) {
                      controller.toggleEmojiBoard(false, false);
                    }
                  },
            child: AbsorbPointer(
              absorbing: controller.isMessageSeleted,
              child: Container(
                padding: IsmChatDimens.edgeInsets4_0,
                color: controller.selectedMessage.contains(widget._message)
                    ? (IsmChatConfig.chatTheme.chatPageTheme
                                ?.messageSelectionColor ??
                            IsmChatConfig.chatTheme.primaryColor!)
                        .applyIsmOpacity(.2)
                    : null,
                child: UnconstrainedBox(
                  clipBehavior: Clip.antiAlias,
                  alignment: showMessageInCenter
                      ? Alignment.center
                      : widget._message?.sentByMe == true
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Padding(
                    padding: showMessageInCenter
                        ? IsmChatDimens.edgeInsets0
                        : IsmChatDimens.edgeInsets0_4,
                    child: Row(
                      crossAxisAlignment:
                          theme?.selfMessageTheme?.showProfile != null &&
                                  theme?.selfMessageTheme?.showProfile
                                          ?.isPostionBottom ==
                                      true
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                      children: [
                        if (isGroup &&
                            !showMessageInCenter &&
                            !(widget._message?.sentByMe == true)) ...[
                          IsmChatProperties.chatPageProperties
                                  .messageSenderProfileBuilder
                                  ?.call(
                                context,
                                widget._message!,
                                controller.conversation,
                              ) ??
                              IsmChatTapHandler(
                                onTap: () async {
                                  await controller.showUserDetails(
                                    widget._message!.senderInfo!,
                                  );
                                },
                                child: IsmChatImage.profile(
                                  IsmChatProperties.chatPageProperties
                                          .messageSenderProfileUrl
                                          ?.call(
                                        context,
                                        widget._message!,
                                        controller.conversation,
                                      ) ??
                                      widget._message?.senderInfo?.profileUrl ??
                                      '',
                                  name: widget._message?.senderInfo?.userName ??
                                      '',
                                  dimensions: IsmChatConfig.chatTheme
                                          .chatPageTheme?.profileImageSize ??
                                      35,
                                ),
                              )
                        ],
                        if (theme?.opponentMessageTheme?.showProfile !=
                            null) ...[
                          if (theme?.opponentMessageTheme?.showProfile
                                      ?.isShowProfile ==
                                  true &&
                              !isGroup &&
                              !showMessageInCenter &&
                              !(widget._message?.sentByMe == true)) ...[
                            IsmChatImage.profile(
                              IsmChatProperties.chatPageProperties.header
                                      ?.profileImageUrl
                                      ?.call(
                                          context,
                                          controller.conversation,
                                          controller.conversation?.profileUrl ??
                                              '') ??
                                  controller.conversation?.profileUrl ??
                                  '',
                              name: IsmChatProperties
                                      .chatPageProperties.header?.title
                                      ?.call(
                                          context,
                                          controller.conversation,
                                          controller.conversation?.chatName ??
                                              '') ??
                                  controller.conversation?.chatName,
                              dimensions: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.profileImageSize ??
                                  IsmChatDimens.thirty,
                            ),
                            if (IsmChatProperties
                                    .chatPageProperties.messageBuilder ==
                                null) ...[
                              IsmChatDimens.boxWidth2,
                            ],
                          ],
                        ] else ...[
                          IsmChatDimens.boxWidth4,
                        ],
                        if (IsmChatUtility.chatPageControllerRegistered) ...[
                          MessageCard(
                            message: widget._message!,
                            showMessageInCenter: showMessageInCenter,
                            index: widget.index,
                          )
                        ],
                        if (theme?.selfMessageTheme?.showProfile != null)
                          if (theme?.selfMessageTheme?.showProfile
                                      ?.isShowProfile ==
                                  true &&
                              !isGroup &&
                              !showMessageInCenter &&
                              widget._message?.sentByMe == true) ...[
                            if (IsmChatProperties
                                    .chatPageProperties.messageBuilder ==
                                null) ...[
                              IsmChatDimens.boxWidth4,
                            ],
                            IsmChatImage.profile(
                              IsmChatConfig.communicationConfig.userConfig
                                      .userProfile ??
                                  coverstaionController
                                      .userDetails?.userProfileImageUrl ??
                                  '',
                              name: IsmChatConfig.communicationConfig.userConfig
                                      .userName ??
                                  coverstaionController.userDetails?.userName,
                              dimensions: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.profileImageSize ??
                                  IsmChatDimens.thirty,
                            ),
                          ]
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
