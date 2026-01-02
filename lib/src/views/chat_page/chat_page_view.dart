import 'dart:async';
import 'dart:io';

import 'package:custom_will_pop_scope/custom_will_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Main chat page view widget that displays the conversation interface.
///
/// This widget manages the chat page lifecycle, handles app state changes,
/// and provides navigation controls. It supports both Android and iOS platforms
/// with platform-specific gesture handling.
///
/// The [viewTag] parameter is optional and used for multiple chat page instances.
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

  /// Handles app lifecycle state changes to manage MQTT connection and message synchronization.
  ///
  /// When the app resumes:
  /// - Sets MQTT controller background state to false
  /// - Fetches new messages from API that arrived while in background
  /// - Fetches message status updates
  /// - Marks all messages as read
  ///
  /// When the app is paused:
  /// - Sets MQTT controller background state to true
  ///
  /// When the app is detached:
  /// - Logs the state change for debugging
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final mqttController = Get.find<IsmChatMqttController>();
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (AppLifecycleState.resumed == state &&
          !(controller.conversation?.conversationId.isNullOrEmpty == true)) {
        mqttController.isAppInBackground = false;
        // Fetch new messages that arrived while app was in background
        // This ensures messages are displayed on receiver's screen
        unawaited(controller.getMessagesFromAPI().then((_) async {
          // After fetching messages, ensure they're loaded from DB
          final conversationId = controller.conversation?.conversationId ?? '';
          if (conversationId.isNotEmpty) {
            await controller.getMessagesFromDB(conversationId);
          }
          // Then get status updates and mark as read
          controller.getMessageForStatus();
          await Future.delayed(const Duration(milliseconds: 100));
          controller.readAllMessages();
        }));
        IsmChatLog.info('app chat in resumed');
      }
    }

    if (AppLifecycleState.paused == state) {
      mqttController.isAppInBackground = true;
      IsmChatLog.info('app chat in background');
    }
    if (AppLifecycleState.detached == state) {
      IsmChatLog.info('app chat in killed');
    }
  }

  /// Handles navigation back action with proper cleanup.
  ///
  /// If messages are currently selected, deselects them and prevents navigation.
  /// Otherwise, performs cleanup operations:
  /// - Closes any open overlays
  /// - Updates the last message
  /// - Calls the onBackTap callback if provided
  /// - Navigates back
  ///
  /// Returns `true` if navigation should proceed, `false` otherwise.
  Future<bool> navigateBack() async {
    if (IsmChatUtility.chatPageControllerRegistered) {
      final controller = IsmChatUtility.chatPageController;
      if (controller.isMessageSeleted) {
        // Deselect messages and prevent navigation
        controller.isMessageSeleted = false;
        controller.selectedMessage.clear();
        return false;
      } else {
        // Perform cleanup and navigate back
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
            ? _SwipeGestureDetector(
                onSwipeRight:
                    IsmChat.i.chatPageTag == null ? () => navigateBack() : null,
                child: const _IsmChatPageView(),
              )
            : const _IsmChatPageView(),
      );
}

/// Internal widget that builds the actual chat page UI.
///
/// This widget handles:
/// - Background decoration (color and image)
/// - App bar (message selection mode or normal header)
/// - Message list display
/// - Message input field
/// - Emoji board
/// - Scroll-to-bottom button
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
            // App bar: Shows selection mode or normal header
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
                      // Delete button for selected messages
                      IconButton(
                        onPressed: () async {
                          // Convert selected messages to map format
                          var selectedMessage = <String, IsmChatMessageModel>{};
                          for (var message in controller.selectedMessage) {
                            selectedMessage
                                .addEntries({message.key: message}.entries);
                          }
                          // Check if all messages are from current user
                          var messageSenderSide =
                              controller.isAllMessagesFromMe();
                          // Check if any message is deleted for everyone
                          var messageDeletedForEveryone =
                              controller.isAnyMessageDeletedForEveryone();
                          // Show delete confirmation dialog
                          controller.showDialogForDeleteMultipleMessage(
                              messageSenderSide,
                              messageDeletedForEveryone,
                              selectedMessage);
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
                    // Handle profile tap: Use custom callback, or navigate to conversation info
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
                                    // Navigate to conversation info if allowed
                                    if (controller.isActionAllowed == false &&
                                        controller.isBroadcast == false) {
                                      // Don't navigate if user was removed from group
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
            // Body content: Shows media preview, camera view, or main chat interface
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
                                // Messages list area
                                Expanded(
                                  child: controller.isMessagesLoading
                                      ? const IsmChatLoadingDialog()
                                      : GestureDetector(
                                          // Close overlay when tapping on messages area
                                          onTap: controller.hasOverlay
                                              ? controller.closeOverlay
                                              : null,
                                          child: AbsorbPointer(
                                            // Prevent interactions when overlay is shown
                                            absorbing: controller.hasOverlay,
                                            child: Stack(
                                              alignment: Alignment.bottomLeft,
                                              children: [
                                                // Messages list or empty state
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
                                                // Mention user list overlay
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
                                // Message input restrictions and input field
                                // Show message restrictions based on various conditions
                                if (controller.isActionAllowed == true &&
                                    controller.conversation?.isGroup ==
                                        true) ...[
                                  // User was removed from group
                                  const _MessageNotAllowedWidget(
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
                                  // Current user was removed from group
                                  const _MessageNotAllowedWidget(
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
                                  // Custom message restriction from properties
                                  _MessageNotAllowedWidget(
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
                                  // Opponent user has been deleted
                                  const _MessageNotAllowedWidget(
                                    showMessage:
                                        IsmChatStrings.userDeleteMessage,
                                  )
                                ] else ...[
                                  // Normal message input field
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
                                // Emoji board (hidden when not shown)
                                Offstage(
                                  offstage: !controller.showEmojiBoard,
                                  child: const EmojiBoard(),
                                ),
                              ],
                            ),
                          ),
                          // Scroll to bottom button (shown when there are unread messages)
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

/// Widget that displays a message when message input is not allowed.
///
/// This widget is shown in various scenarios:
/// - User was removed from a group
/// - Opponent user has been deleted
/// - Custom message restrictions are configured
///
/// The [showMessage] parameter contains the text to display.
/// The [messageWidget] parameter is optional and allows customizing the message widget.
class _MessageNotAllowedWidget extends StatelessWidget {
  const _MessageNotAllowedWidget({
    required this.showMessage,
    this.messageWidget,
  });

  /// The message text to display when message input is not allowed.
  final String showMessage;

  /// Optional custom widget to display instead of the default text message.
  final Widget? messageWidget;

  @override
  Widget build(BuildContext context) => Container(
        color: IsmChatConfig.chatTheme.backgroundColor,
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
