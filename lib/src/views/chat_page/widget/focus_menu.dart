import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Resolved label / icon / row colors for [IsmChatFocusMenu] items.
class _FocusMenuItemStyle {
  const _FocusMenuItemStyle({
    required this.backgroundColor,
    required this.labelColor,
    required this.iconColor,
  });

  final Color backgroundColor;
  final Color labelColor;
  final Color iconColor;
}

_FocusMenuItemStyle _focusMenuItemStyle(
  BuildContext context,
  IsmChatFocusMenuType item,
) {
  if (item == IsmChatFocusMenuType.delete) {
    return const _FocusMenuItemStyle(
      backgroundColor: IsmChatColors.redColor,
      labelColor: IsmChatColors.whiteColor,
      iconColor: IsmChatColors.whiteColor,
    );
  }

  final headerTheme = IsmChatConfig.chatTheme.chatPageHeaderTheme;
  final isDark = IsmChatThemeResolver.brightness(context) == Brightness.dark;
  return _FocusMenuItemStyle(
    backgroundColor: headerTheme?.popupBackgroundColor ??
        (isDark ? const Color(0xFF353535) : IsmChatColors.whiteColor),
    labelColor: headerTheme?.popupLableColor ??
        (isDark ? IsmChatColors.whiteColor : IsmChatColors.blackColor),
    iconColor: headerTheme?.iconColor ??
        (isDark ? IsmChatColors.whiteColor : IsmChatColors.blackColor),
  );
}

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

  int? _messageReversedIndexForGridPreview() {
    final allMessages = controller.messages
        .where((msg) => msg.customType != IsmChatCustomMessageType.date)
        .toList();
    if (allMessages.isEmpty) return null;

    final chronologicalIndex = allMessages.indexWhere(
      (msg) => msg.key == message.key,
    );
    if (chronologicalIndex == -1) return null;

    // MessageBubble expects index from reversed list.
    return allMessages.length - 1 - chronologicalIndex;
  }

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
                                  final itemStyle =
                                      _focusMenuItemStyle(context, item);
                                  return IsmChatTapHandler(
                                    onTap: () async {
                                      controller.closeOverlay();
                                      await controller.onMenuItemSelected(
                                        item,
                                        message,
                                        context,
                                      );
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
                                        color: itemStyle.backgroundColor,
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
                                              color: itemStyle.labelColor,
                                            ),
                                          ),
                                          const Spacer(),
                                          Icon(
                                            item.icon,
                                            color: itemStyle.iconColor,
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
                                  index: _messageReversedIndexForGridPreview(),
                                ),
                          ),
                          IsmChatDimens.boxHeight8,
                          _FocusAnimationBuilder(
                            animation: animation,
                            child: Container(
                              width: IsmChatDimens.oneHundredSeventy,
                              decoration: BoxDecoration(
                                color: IsmChatConfig.chatTheme
                                        .chatPageHeaderTheme
                                        ?.popupBackgroundColor ??
                                    (IsmChatThemeResolver.brightness(context) ==
                                            Brightness.dark
                                        ? const Color(0xFF353535)
                                        : IsmChatColors.whiteColor),
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
                                          final itemStyle =
                                              _focusMenuItemStyle(
                                                  context, item);
                                          return IsmChatTapHandler(
                                            onTap: () async {
                                              Navigator.of(context).pop();
                                              controller.closeOverlay();
                                              await WidgetsBinding.instance
                                                  .endOfFrame;
                                              if (!context.mounted) return;
                                              await controller
                                                  .onMenuItemSelected(
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
                                                color: itemStyle.backgroundColor,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    item.toString(),
                                                    style: IsmChatStyles
                                                        .w400Black12
                                                        .copyWith(
                                                      color:
                                                          itemStyle.labelColor,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  Icon(
                                                    item.icon,
                                                    color: itemStyle.iconColor,
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
