import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatFocusMenu extends StatelessWidget {
  IsmChatFocusMenu(
    this.message, {
    super.key,
    required this.animation,
    this.blur,
    this.blurBackgroundColor,
  }) : canReact = IsmChatProperties.chatPageProperties.features
            .contains(IsmChatFeature.reaction);

  final double? blur;
  final Color? blurBackgroundColor;
  final IsmChatMessageModel message;
  final Animation<double> animation;
  final bool canReact;

  final controller = IsmChatUtility.chatPageController;

  @override
  Widget build(BuildContext context) => IsmChatResponsive.isWeb(context)
      ? IsmChatTapHandler(
          onTap: controller.closeOverlay,
          child: Padding(
            padding: IsmChatDimens.edgeInsets8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: message.sentByMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (canReact && !controller.isBroadcast)
                  _FocusAnimationBuilder(
                    animation: animation,
                    child: ReactionGrid(message),
                  ),
                IsmChatDimens.boxHeight8,
                _FocusAnimationBuilder(
                  animation: animation,
                  child: Container(
                    width: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messgaeFocusedTheme?.width ??
                        IsmChatDimens.oneHundredSeventy,
                    decoration: IsmChatConfig.chatTheme.chatPageTheme
                            ?.messgaeFocusedTheme?.decoration ??
                        BoxDecoration(
                          border: Border.all(
                            color: IsmChatColors.blackColor,
                          ),
                          borderRadius:
                              BorderRadius.circular(IsmChatDimens.sixteen),
                        ),
                    child: ClipRRect(
                      borderRadius: IsmChatConfig.chatTheme.chatPageTheme
                              ?.messgaeFocusedTheme?.decoration?.borderRadius ??
                          BorderRadius.circular(IsmChatDimens.sixteen),
                      clipBehavior: Clip.antiAlias,
                      child: GetBuilder<IsmChatPageController>(
                          tag: IsmChat.i.chatPageTag,
                          builder: (controller) => ListView.builder(
                                itemCount: message.focusMenuList.length,
                                shrinkWrap: true,
                                itemBuilder: (_, index) {
                                  var item = message.focusMenuList[index];
                                  return IsmChatTapHandler(
                                    onTap: () {
                                      controller
                                        ..closeOverlay()
                                        ..onMenuItemSelected(
                                            item, message, context);
                                    },
                                    child: Container(
                                      height: IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.messgaeFocusedTheme
                                              ?.hight ??
                                          IsmChatDimens.forty,
                                      padding: IsmChatDimens.edgeInsets16_0,
                                      decoration: BoxDecoration(
                                        color:
                                            item == IsmChatFocusMenuType.delete
                                                ? IsmChatColors.redColor
                                                : IsmChatConfig
                                                    .chatTheme.backgroundColor,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item.toString(),
                                            style: IsmChatStyles.w400Black12
                                                .copyWith(
                                              fontSize: IsmChatConfig
                                                  .chatTheme
                                                  .chatPageTheme
                                                  ?.messgaeFocusedTheme
                                                  ?.fontSize,
                                              color: item ==
                                                      IsmChatFocusMenuType
                                                          .delete
                                                  ? IsmChatColors.whiteColor
                                                  : null,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            item.icon,
                                            color: item ==
                                                    IsmChatFocusMenuType.delete
                                                ? IsmChatColors.whiteColor
                                                : null,
                                            size: IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.messgaeFocusedTheme
                                                ?.iconSize,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      : IsmChatTapHandler(
          onTap: () {
            if (IsmChatResponsive.isWeb(context)) {
              IsmChatUtility.chatPageController.closeOverlay();
            } else {
              Navigator.pop(context);
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: blur ?? 4,
                      sigmaY: blur ?? 4,
                    ),
                    child: Container(
                      color: (blurBackgroundColor ?? Colors.black)
                          .applyIsmOpacity(0.5),
                    ),
                  ),
                  Container(
                    alignment: message.sentByMe
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    padding: IsmChatDimens.edgeInsets8,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: message.sentByMe
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          if (canReact && !controller.isBroadcast)
                            _FocusAnimationBuilder(
                              animation: animation,
                              child: ReactionGrid(message),
                            ),
                          IsmChatDimens.boxHeight8,
                          Hero(
                            tag: message,
                            child: IsmChatProperties
                                    .chatPageProperties.messageBuilder
                                    ?.call(context, message,
                                        message.customType!, false) ??
                                MessageBubble(
                                  message: message,
                                  showMessageInCenter: false,
                                ),
                          ),
                          IsmChatDimens.boxHeight8,
                          _FocusAnimationBuilder(
                            animation: animation,
                            child: Container(
                              width: IsmChatDimens.oneHundredSeventy,
                              decoration: BoxDecoration(
                                color: IsmChatConfig.chatTheme
                                    .chatPageHeaderTheme?.popupBackgroundColor,
                                borderRadius: BorderRadius.circular(
                                  IsmChatDimens.sixteen,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: GetBuilder<IsmChatPageController>(
                                  tag: IsmChat.i.chatPageTag,
                                  builder: (controller) => ListView.builder(
                                        itemCount: message.focusMenuList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (_, index) {
                                          var item =
                                              message.focusMenuList[index];
                                          return IsmChatTapHandler(
                                            onTap: () {
                                              IsmChatRoute.goBack();
                                              controller
                                                ..closeOverlay()
                                                ..onMenuItemSelected(
                                                  item,
                                                  message,
                                                  context,
                                                );
                                            },
                                            child: Container(
                                              height: IsmChatDimens.forty,
                                              padding:
                                                  IsmChatDimens.edgeInsets16_0,
                                              decoration: BoxDecoration(
                                                color: item ==
                                                        IsmChatFocusMenuType
                                                            .delete
                                                    ? IsmChatColors.redColor
                                                    : IsmChatConfig
                                                            .chatTheme
                                                            .chatPageHeaderTheme
                                                            ?.popupBackgroundColor ??
                                                        IsmChatConfig.chatTheme
                                                            .backgroundColor,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    item.toString(),
                                                    style: IsmChatStyles
                                                        .w400Black12
                                                        .copyWith(
                                                      color: item ==
                                                              IsmChatFocusMenuType
                                                                  .delete
                                                          ? IsmChatColors
                                                              .whiteColor
                                                          : IsmChatConfig
                                                              .chatTheme
                                                              .chatPageHeaderTheme
                                                              ?.popupLableColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    item.icon,
                                                    color: item ==
                                                            IsmChatFocusMenuType
                                                                .delete
                                                        ? IsmChatColors
                                                            .whiteColor
                                                        : IsmChatConfig
                                                            .chatTheme
                                                            .chatPageHeaderTheme
                                                            ?.iconColor,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
}

class _FocusAnimationBuilder extends StatelessWidget {
  const _FocusAnimationBuilder({
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, widget) => ScaleTransition(
          scale: animation,
          child: widget!,
        ),
        child: child,
      );
}
