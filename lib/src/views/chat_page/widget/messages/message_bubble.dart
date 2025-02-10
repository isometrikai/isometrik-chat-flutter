import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

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
        _globalKey = IsmChatResponsive.isWeb(Get.context!)
            ? GlobalKey()
            : Get.find<IsmChatPageController>(tag: IsmChat.i.tag)
                .getGlobalKey(message?.sentAt ?? 0);

  final IsmChatMessageModel _message;
  final bool showMessageInCenter;
  final int? index;
  final GlobalKey _globalKey;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (controller) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_message.sentByMe) ...[
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
                            : context.width * .7,
                        minWidth: IsmChatResponsive.isWeb(context)
                            ? context.width * .05
                            : context.width * .25,
                      ),
              decoration: showMessageInCenter
                  ? null
                  : BoxDecoration(
                      color: _message.backgroundColor,
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
                  Padding(
                    padding: !showMessageInCenter
                        ? IsmChatDimens.edgeInsets5_5_5_20
                        : IsmChatDimens.edgeInsets0,
                    child: SingleChildScrollView(
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
                                            controller.conversation!,
                                          ) !=
                                          null) {
                                        name = IsmChatProperties
                                                .chatPageProperties
                                                .messageSenderName
                                                ?.call(
                                              context,
                                              _message,
                                              controller.conversation!,
                                            ) ??
                                            '';
                                      } else {
                                        name =
                                            '${_message.senderInfo?.metaData?.firstName ?? ''} ${_message.senderInfo?.metaData?.lastName ?? ''}';
                                      }
                                      return IsmChatProperties
                                              .chatPageProperties
                                              .messageSenderNameBuilder
                                              ?.call(
                                            context,
                                            _message,
                                            controller.conversation!,
                                          ) ??
                                          Text(
                                            name.trim().isNotEmpty
                                                ? name
                                                : _message
                                                        .senderInfo?.userName ??
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
                          IsmChatMessageWrapper(_message)
                        ],
                      ),
                    ),
                  ),
                  if (!showMessageInCenter) ...[
                    Positioned(
                      bottom: IsmChatDimens.four,
                      right: IsmChatDimens.ten,
                      child: Material(
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: _message.sentByMe
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Text(
                              _message.sentAt.toTimeString(),
                              style: _message.style.copyWith(
                                  fontSize: (_message.style.fontSize ?? 0) - 5),
                            ),
                            if (_message.sentByMe &&
                                _message.customType !=
                                    IsmChatCustomMessageType
                                        .deletedForEveryone) ...[
                              if (_message.messageId?.isEmpty == true) ...[
                                IsmChatDimens.boxWidth2,
                                Icon(
                                  Icons.watch_later_outlined,
                                  color: IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.messageStatusTheme
                                          ?.unreadCheckColor ??
                                      Colors.white,
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
                                  _message.deliveredToAll ?? false
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
                                          Colors.white,
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
            if (!_message.sentByMe) ...[
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
                        globalKey.currentContext ?? Get.context!,
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
