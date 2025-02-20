import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MessageCard extends StatefulWidget {
  MessageCard({
    super.key,
    required this.showMessageInCenter,
    required this.message,
    required this.index,
  }) : canReply = IsmChatProperties.chatPageProperties.features
            .contains(IsmChatFeature.reply);

  final bool showMessageInCenter;
  final IsmChatMessageModel message;
  final int index;
  final bool canReply;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard>
    with SingleTickerProviderStateMixin {
  AnimationController? controllerAnimation;
  Animation<Offset>? animation;

  @override
  initState() {
    super.initState();
    controllerAnimation = AnimationController(
      vsync: this,
      duration: IsmChatConstants.swipeDuration,
    );
    animation = Tween<Offset>(
      begin: const Offset(0.0, 0.0),
      end: const Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: controllerAnimation!),
    );
    controllerAnimation?.addListener(() {
      setState(() {});
    });
  }

  @override
  dispose() {
    controllerAnimation?.dispose();
    super.dispose();
  }

  ///Run animation for child widget
  void _runAnimation({required bool onRight}) {
    //set child animation
    animation = Tween(
      begin: const Offset(0.0, 0.0),
      end: Offset(onRight ? 0.8 : -0.8, 0.0),
    ).animate(
      CurvedAnimation(curve: Curves.decelerate, parent: controllerAnimation!),
    );

    //Forward animation
    controllerAnimation?.forward().whenComplete(() {
      controllerAnimation?.reverse().whenComplete(() {
        Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
            .onReplyTap(widget.message);
      });
    });
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (controller) => GestureDetector(
          onHorizontalDragUpdate: widget.showMessageInCenter
              ? null
              : widget.message.customType ==
                      IsmChatCustomMessageType.deletedForEveryone
                  ? null
                  : (details) {
                      if (details.delta.dx > 1) {
                        _runAnimation(
                          onRight: true,
                        );
                      }
                      if (details.delta.dx < -1) {
                        _runAnimation(
                          onRight: false,
                        );
                      }
                    },
          child: SlideTransition(
            position: animation!,
            child: InkWell(
              splashColor: IsmChatColors.transparent,
              onHover: (value) {
                if (controller.conversationController.isRenderChatPageaScreen !=
                    IsRenderChatPageScreen.none) {
                  return;
                }
                if (value) {
                  controller.onMessageHoverIndex = widget.index;
                } else {
                  controller.onMessageHoverIndex = -1;
                }
              },
              borderRadius: BorderRadius.zero,
              hoverColor: IsmChatColors.transparent,
              focusColor: IsmChatColors.transparent,
              highlightColor: IsmChatColors.transparent,
              onTap: () {
                controller.onMessageTap(
                  context: context,
                  message: widget.message,
                );
              },
              child: Column(
                crossAxisAlignment: widget.message.sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AutoScrollTag(
                        controller: controller.messagesScrollController,
                        index: widget.index,
                        key: Key('scroll-${widget.message.messageId}'),
                        child: kIsWeb
                            ? MessageBubble(
                                message: widget.message,
                                showMessageInCenter: widget.showMessageInCenter,
                                index: widget.index,
                              )
                            : Hero(
                                tag: widget.message,
                                child: IsmChatProperties
                                        .chatPageProperties.messageBuilder
                                        ?.call(
                                            context,
                                            widget.message,
                                            widget.message.customType!,
                                            widget.showMessageInCenter) ??
                                    MessageBubble(
                                      message: widget.message,
                                      showMessageInCenter:
                                          widget.showMessageInCenter,
                                      index: widget.index,
                                    ),
                              ),
                      ),
                      if (widget.message.reactions?.isNotEmpty == true)
                        Positioned(
                          right: widget.message.sentByMe ? 0 : null,
                          left: widget.message.sentByMe ? null : 0,
                          bottom: IsmChatDimens.six,
                          child: ImsChatReaction(
                            message: widget.message,
                          ),
                        ),
                    ],
                  ),
                  if (!widget.showMessageInCenter &&
                      (IsmChatProperties.chatPageProperties.messageStatus
                              ?.shouldShowTimeStatusOuter ??
                          false)) ...[
                    IsmChatDimens.boxHeight5,
                    Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: widget.message.sentByMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (IsmChatProperties.chatPageProperties.messageStatus
                                  ?.shouldShowMessageTime ??
                              false) ...[
                            Text(widget.message.sentAt.toTimeString(),
                                style: widget.message.style.copyWith(
                                    color: IsmChatColors.blackColor,
                                    fontSize:
                                        (widget.message.style.fontSize ?? 0) -
                                            5))
                          ],
                          if ((IsmChatProperties.chatPageProperties
                                      .messageStatus?.shouldShowMessgaeStatus ??
                                  false) &&
                              widget.message.sentByMe &&
                              widget.message.customType !=
                                  IsmChatCustomMessageType
                                      .deletedForEveryone) ...[
                            if (widget.message.messageId?.isEmpty == true) ...[
                              IsmChatDimens.boxWidth2,
                              Icon(
                                Icons.watch_later_outlined,
                                color: IsmChatConfig
                                        .chatTheme
                                        .chatPageTheme
                                        ?.messageStatusTheme
                                        ?.unreadCheckColor ??
                                    Colors.black,
                                size: IsmChatConfig.chatTheme.chatPageTheme
                                        ?.messageStatusTheme?.checkSize ??
                                    IsmChatDimens.forteen,
                              ),
                            ] else if (IsmChatProperties
                                .chatPageProperties.features
                                .contains(
                              IsmChatFeature.showMessageStatus,
                            )) ...[
                              IsmChatDimens.boxWidth2,
                              Icon(
                                widget.message.deliveredToAll ?? false
                                    ? Icons.done_all_rounded
                                    : Icons.done_rounded,
                                color: widget.message.readByAll ?? false
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
                                        Colors.black,
                                size: IsmChatConfig.chatTheme.chatPageTheme
                                        ?.messageStatusTheme?.checkSize ??
                                    IsmChatDimens.forteen,
                              ),
                            ]
                          ],
                        ],
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ),
      );
}
