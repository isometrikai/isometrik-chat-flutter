import 'dart:io';

import 'package:custom_will_pop_scope/custom_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageView extends StatefulWidget {
  const IsmChatPageView({
    super.key,
    this.viewTag,
  });

  final String? viewTag;

  @override
  State<IsmChatPageView> createState() => _IsmChatPageViewState();
}

class _IsmChatPageViewState extends State<IsmChatPageView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    IsmChat.i.chatPageTag = widget.viewTag;
    if (!IsmChatUtility.chatPageControllerRegistered) {
      IsmChatPageBinding().dependencies();
    }
  }

  @override
  void dispose() {
    IsmChat.i.chatPageTag = null;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final mqttController = Get.find<IsmChatMqttController>();
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (AppLifecycleState.resumed == state &&
          !(controller.conversation?.conversationId.isNullOrEmpty == true)) {
        mqttController.isAppInBackground = false;
        controller.getMessageForStatus();
        controller.readAllMessages();
        IsmChatLog.info('app chat in resumed');
      }
    }

    if (AppLifecycleState.paused == state) {
      mqttController.isAppInBackground = true;
      IsmChatLog.info('app chat in backgorund');
    }
    if (AppLifecycleState.detached == state) {
      IsmChatLog.info('app chat in killed');
    }
  }

  Future<bool> navigateBack() async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (controller.isMessageSeleted) {
        controller.isMessageSeleted = false;
        controller.selectedMessage.clear();
        return false;
      } else {
        IsmChatRoute.goBack();
        controller.closeOverlay();
        final updateMessage = await controller.updateLastMessage();
        IsmChatProperties.chatPageProperties.header?.onBackTap
            ?.call(updateMessage);
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => CustomWillPopScope(
        onWillPop: () async {
          if (!GetPlatform.isAndroid) return false;
          return IsmChat.i.chatPageTag == null ? await navigateBack() : false;
        },
        child: GetPlatform.isIOS
            ? GestureDetector(
                onHorizontalDragEnd: IsmChat.i.chatPageTag == null
                    ? (details) {
                        if (details.velocity.pixelsPerSecond.dx > 50) {
                          navigateBack();
                        }
                      }
                    : null,
                child: const _IsmChatPageView(),
              )
            : const _IsmChatPageView(),
      );
}

class _IsmChatPageView extends StatelessWidget {
  const _IsmChatPageView();

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) => DecoratedBox(
          decoration: BoxDecoration(
            color: controller.backgroundColor.isNotEmpty
                ? controller.backgroundColor.toColor
                : IsmChatColors.whiteColor,
            image: controller.backgroundImage.isNotEmpty
                ? DecorationImage(
                    image: controller.backgroundImage.isValidUrl
                        ? NetworkImage(controller.backgroundImage)
                        : IsmChatProperties.chatPageProperties
                                .backgroundImageUrl.isNullOrEmpty
                            ? controller.backgroundImage.contains(
                                    'packages/isometrik_chat_flutter/assets')
                                ? AssetImage(controller.backgroundImage)
                                    as ImageProvider
                                : FileImage(
                                    File(controller.backgroundImage),
                                  )
                            : AssetImage(controller.backgroundImage),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Scaffold(
            drawerEnableOpenDragGesture: false,
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                    Colors.transparent,
            resizeToAvoidBottomInset: true,
            appBar: controller.isMessageSeleted
                ? AppBar(
                    systemOverlayStyle: IsmChatConfig.chatTheme
                            .chatPageHeaderTheme?.systemUiOverlayStyle ??
                        SystemUiOverlayStyle(
                          statusBarBrightness: Brightness.dark,
                          statusBarIconBrightness: Brightness.light,
                          statusBarColor:
                              IsmChatConfig.chatTheme.primaryColor ??
                                  IsmChatColors.primaryColorLight,
                        ),
                    leading: IsmChatTapHandler(
                      onTap: () async {
                        controller.isMessageSeleted = false;
                        controller.selectedMessage.clear();
                      },
                      child: Icon(
                        IsmChatResponsive.isWeb(context)
                            ? Icons.close_rounded
                            : Icons.arrow_back_rounded,
                      ),
                    ),
                    titleSpacing: IsmChatDimens.four,
                    title: Text(
                      '${controller.selectedMessage.length} Messages',
                      style: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.titleStyle ??
                          IsmChatStyles.w600White18,
                    ),
                    backgroundColor: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.backgroundColor ??
                        IsmChatConfig.chatTheme.primaryColor,
                    iconTheme: IconThemeData(
                        color: IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.iconColor ??
                            IsmChatColors.whiteColor),
                    actions: [
                      IconButton(
                        onPressed: () async {
                          var selectedMessage = <String, IsmChatMessageModel>{};
                          for (var message in controller.selectedMessage) {
                            selectedMessage
                                .addEntries({message.key: message}.entries);
                          }
                          var messageSenderSide =
                              controller.isAllMessagesFromMe();
                          controller.showDialogForDeleteMultipleMessage(
                              messageSenderSide, selectedMessage);
                        },
                        icon: Icon(
                          Icons.delete_rounded,
                          color: IsmChatConfig
                                  .chatTheme.chatPageHeaderTheme?.iconColor ??
                              IsmChatColors.whiteColor,
                        ),
                      ),
                    ],
                  )
                : IsmChatPageHeader(
                    onTap: IsmChatProperties
                                .chatPageProperties.header?.onProfileTap !=
                            null
                        ? () => IsmChatProperties
                            .chatPageProperties.header?.onProfileTap
                            ?.call(controller.conversation)
                        : IsmChatProperties.chatPageProperties.header
                                    ?.profileImageBuilder !=
                                null
                            ? null
                            : controller.isActionAllowed == false
                                ? () {
                                    if (controller.isActionAllowed == false &&
                                        controller.isBroadcast == false) {
                                      if (!(controller
                                                  .conversation
                                                  ?.lastMessageDetails
                                                  ?.customType ==
                                              IsmChatCustomMessageType
                                                  .removeMember &&
                                          controller
                                                  .conversation
                                                  ?.lastMessageDetails
                                                  ?.userId ==
                                              IsmChatConfig.communicationConfig
                                                  .userConfig.userId)) {
                                        if (IsmChatResponsive.isWeb(context)) {
                                          IsmChatUtility.conversationController
                                                  .isRenderChatPageaScreen =
                                              IsRenderChatPageScreen
                                                  .coversationInfoView;
                                        } else {
                                          IsmChatRoute.goToRoute(
                                              IsmChatConverstaionInfoView());
                                        }
                                      }
                                    }
                                  }
                                : null,
                  ),
            body: IsmChatResponsive.isWeb(context) &&
                    controller.webMedia.isNotEmpty
                ? const WebMediaPreview()
                : IsmChatResponsive.isWeb(context) && controller.isCameraView
                    ? const IsmChatCameraView()
                    : Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            decoration: IsmChatConfig
                                .chatTheme.chatPageTheme?.pageDecoration,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Expanded(
                                  child: controller.isMessagesLoading
                                      ? const IsmChatLoadingDialog()
                                      : GestureDetector(
                                          onTap: controller.hasOverlay
                                              ? controller.closeOverlay
                                              : null,
                                          child: AbsorbPointer(
                                            absorbing: controller.hasOverlay,
                                            child: Stack(
                                              alignment: Alignment.bottomLeft,
                                              children: [
                                                controller.messages.isNotEmpty
                                                    ? Align(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: ListView.builder(
                                                          physics:
                                                              const ClampingScrollPhysics(),
                                                          controller: controller
                                                              .messagesScrollController,
                                                          scrollDirection:
                                                              Axis.vertical,
                                                          shrinkWrap: true,
                                                          keyboardDismissBehavior:
                                                              ScrollViewKeyboardDismissBehavior
                                                                  .onDrag,
                                                          padding: IsmChatDimens
                                                              .edgeInsets4_8,
                                                          reverse: true,
                                                          addAutomaticKeepAlives:
                                                              true,
                                                          itemCount: controller
                                                              .messages.length,
                                                          itemBuilder: (_,
                                                                  index) =>
                                                              controller
                                                                      .controllerIsRegister
                                                                  ? IsmChatMessage(
                                                                      index,
                                                                      controller
                                                                              .messages[
                                                                          index],
                                                                    )
                                                                  : IsmChatDimens
                                                                      .box0,
                                                        ),
                                                      )
                                                    : IsmChatProperties
                                                            .chatPageProperties
                                                            .placeholder ??
                                                        const IsmChatEmptyView(
                                                          icon: Icon(
                                                            Icons.chat_outlined,
                                                          ),
                                                          text: IsmChatStrings
                                                              .noMessages,
                                                        ),
                                                Obx(() => Align(
                                                      alignment:
                                                          IsmChatResponsive
                                                                  .isWeb(
                                                                      context)
                                                              ? Alignment
                                                                  .bottomCenter
                                                              : Alignment
                                                                  .bottomLeft,
                                                      child: controller
                                                              .showMentionUserList
                                                          ? const MentionUserList()
                                                          : const SizedBox
                                                              .shrink(),
                                                    )),
                                              ],
                                            ),
                                          ),
                                        ),
                                ),
                                if (controller.isActionAllowed == true &&
                                    controller.conversation?.isGroup ==
                                        true) ...[
                                  const _MessgeNotAllowdWidget(
                                    showMessage:
                                        IsmChatStrings.removeGroupMessage,
                                  )
                                ] else if (controller.isActionAllowed == false &&
                                    controller.conversation?.isGroup == true &&
                                    controller.conversation?.lastMessageDetails
                                            ?.customType ==
                                        IsmChatCustomMessageType.removeMember &&
                                    controller.conversation?.lastMessageDetails?.userId ==
                                        IsmChatConfig.communicationConfig
                                            .userConfig.userId) ...[
                                  const _MessgeNotAllowdWidget(
                                    showMessage:
                                        IsmChatStrings.removeGroupMessage,
                                  )
                                ] else if (IsmChatProperties
                                            .chatPageProperties
                                            .messageAllowedConfig
                                            ?.isShowTextfiledConfig !=
                                        null &&
                                    !(IsmChatProperties
                                            .chatPageProperties
                                            .messageAllowedConfig
                                            ?.isShowTextfiledConfig
                                            ?.isShowMessageAllowed
                                            .call(context,
                                                controller.conversation) ==
                                        true)) ...[
                                  _MessgeNotAllowdWidget(
                                    showMessage: IsmChatProperties
                                            .chatPageProperties
                                            .messageAllowedConfig
                                            ?.isShowTextfiledConfig
                                            ?.shwoMessage
                                            ?.call(context,
                                                controller.conversation) ??
                                        '',
                                    messageWidget: IsmChatProperties
                                        .chatPageProperties
                                        .messageAllowedConfig
                                        ?.isShowTextfiledConfig
                                        ?.messageWidget
                                        ?.call(
                                            context, controller.conversation),
                                  )
                                ] else if (controller.conversation?.isOpponentDetailsEmpty ==
                                    true) ...[
                                  const _MessgeNotAllowdWidget(
                                    showMessage:
                                        IsmChatStrings.userDeleteMessage,
                                  )
                                ] else ...[
                                  Container(
                                    padding: IsmChatConfig
                                        .chatTheme
                                        .chatPageTheme
                                        ?.textFiledTheme
                                        ?.textfieldInsets,
                                    decoration: IsmChatConfig
                                        .chatTheme
                                        .chatPageTheme
                                        ?.textFiledTheme
                                        ?.decoration,
                                    child: SafeArea(
                                      bottom: !controller.showEmojiBoard,
                                      child: const IsmChatMessageField(),
                                    ),
                                  ),
                                ],
                                Offstage(
                                  offstage: !controller.showEmojiBoard,
                                  child: const EmojiBoard(),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => !controller.showDownSideButton
                                ? IsmChatDimens.box0
                                : Positioned(
                                    bottom: IsmChatResponsive.isMobile(context)
                                        ? controller.isreplying
                                            ? IsmChatDimens.oneHundredThirty
                                            : IsmChatDimens.ninty
                                        : IsmChatDimens.oneHundredFifty,
                                    right: IsmChatDimens.eight,
                                    child: IsmChatTapHandler(
                                      onTap: controller.scrollDown,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: IsmChatConfig
                                              .chatTheme.backgroundColor
                                              ?.applyIsmOpacity(0.5),
                                          border: Border.all(
                                            color: IsmChatConfig
                                                    .chatTheme.primaryColor ??
                                                IsmChatColors.primaryColorLight,
                                            width: 1.5,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: IsmChatDimens.edgeInsets8,
                                        child: Icon(
                                          Icons.expand_more_rounded,
                                          color: IsmChatConfig
                                              .chatTheme.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
          ).withUnfocusGestureDetctor(context),
        ),
      );
}

class _MessgeNotAllowdWidget extends StatelessWidget {
  const _MessgeNotAllowdWidget({required this.showMessage, this.messageWidget});

  final String showMessage;

  final Widget? messageWidget;

  @override
  Widget build(BuildContext context) => Container(
        color: IsmChatConfig.chatTheme.backgroundColor,
        // height: IsmChatDimens.sixty,
        width: double.maxFinite,
        child: SafeArea(
          child: Center(
            child: SizedBox(
              width: IsmChatDimens.percentWidth(.9),
              child: messageWidget ??
                  Text(
                    showMessage,
                    style: IsmChatResponsive.isWeb(context)
                        ? IsmChatStyles.w600Black20
                        : IsmChatStyles.w600Black12,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
            ),
          ),
        ),
      );
}
