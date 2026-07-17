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
    final message = widget._message;
    if (message == null || !message.isGridDisplayableMedia) {
      return false;
    }

    final allMessages = controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();
    final group = IsmChatMediaGridGrouping.collect(allMessages, message);
    return IsmChatMediaGridGrouping.shouldHide(group, message);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final conversation = IsmChatUtility.chatPageControllerRegistered
        ? IsmChatUtility.chatPageController.conversation
        : coverstaionController.currentConversation;
    if (widget._message != null &&
        !widget._message!.isVisibleInGroupChat(conversation)) {
      return const SizedBox.shrink();
    }
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
                : () => controller.onMessageLongPress(
                      context,
                      widget._message!,
                      showMessageInCenter: showMessageInCenter,
                    ),
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
