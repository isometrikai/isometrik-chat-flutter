import 'dart:async';

import 'package:custom_will_pop_scope/custom_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBoradcastMessagePage extends StatefulWidget {
  const IsmChatBoradcastMessagePage({super.key, this.viewTag});

  final String? viewTag;

  @override
  State<IsmChatBoradcastMessagePage> createState() =>
      _IsmChatBoradcastMessagePageState();
}

class _IsmChatBoradcastMessagePageState
    extends State<IsmChatBoradcastMessagePage> {
  @override
  void initState() {
    super.initState();
    IsmChat.i.chatPageTag = widget.viewTag;
    if (!IsmChatUtility.chatPageControllerRegistered) {
      IsmChatPageBinding().dependencies();
    }
  }

  @override
  void dispose() {
    IsmChat.i.chatPageTag = null;
    super.dispose();
  }

  Future<bool> _back(
    BuildContext context,
  ) async {
    var controller = IsmChatUtility.chatPageController;
    var conversationController = IsmChatUtility.conversationController;

    if (IsmChatResponsive.isWeb(context)) {
      var controller = IsmChatUtility.chatPageController;
      controller.isBroadcast = false;
      conversationController.currentConversation = null;
      conversationController.currentConversationId = '';
      conversationController.isRenderChatPageaScreen =
          IsRenderChatPageScreen.none;
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
    } else {
      if (controller.messages.isNotEmpty) {
        await Get.delete<IsmChatPageController>(
            force: true, tag: IsmChat.i.chatPageTag);
        IsmChatRoute.goBack();
      }
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);
      IsmChatRoute.goBack();
    }
    if (controller.messages.isNotEmpty) {
      unawaited(conversationController.getChatConversations());
      conversationController.selectedUserList.clear();
      conversationController.forwardedList.clear();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => CustomWillPopScope(
        onWillPop: () async {
          if (!GetPlatform.isAndroid) return false;
          return await _back(context);
        },
        child: GetPlatform.isIOS
            ? _SwipeGestureDetector(
                onSwipeRight: () => _back(context),
                child: _BroadCastMessage(
                  onBackTap: () => _back(context),
                ),
              )
            : _BroadCastMessage(
                onBackTap: () => _back(context),
              ),
      );
}

class _BroadCastMessage extends StatelessWidget {
  const _BroadCastMessage({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => Scaffold(
          backgroundColor:
              IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                  IsmChatColors.whiteColor,
          appBar: IsmChatAppBar(
            height: IsmChatDimens.fiftyFive,
            leading: IsmChatTapHandler(
              onTap: onBackTap,
              child: Padding(
                padding: IsmChatDimens.edgeInsetsLeft10,
                child: Icon(
                  IsmChatResponsive.isWeb(context)
                      ? Icons.close_rounded
                      : Icons.arrow_back_rounded,
                  color:
                      IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.whiteColor,
                ),
              ),
            ),
            centerTitle: false,
            leadingWidth: IsmChatDimens.forty,
            title: Row(
              children: [
                Container(
                  height: IsmChatDimens.forty,
                  width: IsmChatDimens.forty,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: IsmChatColors.whiteColor,
                  ),
                  child: const Icon(Icons.campaign_rounded),
                ),
                IsmChatDimens.boxWidth12,
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.conversation?.members?.length} Recipients Selected',
                        style: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.titleStyle ??
                            IsmChatStyles.w600White16,
                      ),
                      Text(
                        controller.conversation?.members
                                ?.map((e) => e.userName)
                                .join(',') ??
                            '',
                        style: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.subtileStyle ??
                            IsmChatStyles.w400White12,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor ??
                    IsmChatConfig.chatTheme.primaryColor,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: controller.isMessagesLoading
                    ? const IsmChatLoadingDialog()
                    : controller.messages.isNotEmpty
                        ? Align(
                            alignment: Alignment.topCenter,
                            child: ListView.builder(
                              scrollDirection: Axis.vertical,
                              shrinkWrap: true,
                              reverse: true,
                              padding: IsmChatDimens.edgeInsets4_8,
                              itemCount: controller.messages.length,
                              itemBuilder: (_, index) => IsmChatMessage(
                                index,
                                controller.messages[index],
                                isIgnorTap: true,
                              ),
                            ),
                          )
                        : IsmChatProperties.chatPageProperties.placeholder ??
                            const IsmChatEmptyView(
                              icon: Icon(
                                Icons.chat_outlined,
                              ),
                              text: IsmChatStrings.noMessages,
                            ),
              ),
              Container(
                padding: IsmChatConfig
                    .chatTheme.chatPageTheme?.textFiledTheme?.textfieldInsets,
                decoration: IsmChatConfig
                    .chatTheme.chatPageTheme?.textFiledTheme?.decoration,
                child: const SafeArea(
                  child: IsmChatMessageField(),
                ),
              ),
            ],
          ),
        ),
      );
}

/// Custom gesture detector that requires a deliberate swipe gesture to trigger navigation.
///
/// This widget prevents accidental navigation by requiring both:
/// - A minimum drag distance (100 pixels)
/// - A minimum velocity (300 pixels per second)
///
/// This ensures only intentional swipe gestures trigger the back navigation.
class _SwipeGestureDetector extends StatefulWidget {
  const _SwipeGestureDetector({
    required this.child,
    this.onSwipeRight,
  });

  final Widget child;
  final VoidCallback? onSwipeRight;

  @override
  State<_SwipeGestureDetector> createState() => _SwipeGestureDetectorState();
}

class _SwipeGestureDetectorState extends State<_SwipeGestureDetector> {
  double _dragDistance = 0.0;
  static const double _minDragDistance = 100.0;
  static const double _minVelocity = 300.0;

  @override
  Widget build(BuildContext context) {
    if (widget.onSwipeRight == null) {
      return widget.child;
    }

    return GestureDetector(
      onHorizontalDragStart: (_) {
        _dragDistance = 0.0;
      },
      onHorizontalDragUpdate: (details) {
        // Only track rightward swipes (positive dx)
        if (details.delta.dx > 0) {
          _dragDistance += details.delta.dx;
        }
      },
      onHorizontalDragEnd: (details) {
        final velocity = details.velocity.pixelsPerSecond.dx;
        // Require both minimum distance and velocity for a deliberate swipe
        if (_dragDistance >= _minDragDistance && velocity >= _minVelocity) {
          widget.onSwipeRight?.call();
        }
        _dragDistance = 0.0;
      },
      child: widget.child,
    );
  }
}
