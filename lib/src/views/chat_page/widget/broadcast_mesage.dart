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
      // Clean up the controller
      await Get.delete<IsmChatPageController>(
          force: true, tag: IsmChat.i.chatPageTag);

      // Pop back to previous screen (broadcast list)
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

class _BroadCastMessage extends StatefulWidget {
  const _BroadCastMessage({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  State<_BroadCastMessage> createState() => _BroadCastMessageState();
}

class _BroadCastMessageState extends State<_BroadCastMessage> {
  String? _broadcastTitle;
  int? _broadcastMembersCount;
  List<String> _broadcastMemberNames = [];

  @override
  void initState() {
    super.initState();
    _fetchBroadcastTitle();
  }

  Future<void> _fetchBroadcastTitle() async {
    if (!Get.isRegistered<IsmChatBroadcastController>()) {
      IsmChatBroadcastBinding().dependencies();
    }

    // Wait a bit for the controller to be ready
    await Future.delayed(const Duration(milliseconds: 100));

    final chatPageController = Get.find<IsmChatPageController>(
      tag: IsmChat.i.chatPageTag,
    );
    final conversationId = chatPageController.conversation?.conversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    try {
      final broadcastController = Get.find<IsmChatBroadcastController>();
      await broadcastController.getBroadCast(isShowLoader: false);

      // Find the broadcast matching the conversationId (which is the groupcastId)
      final broadcast = broadcastController.broadcastList.firstWhereOrNull(
        (b) => b.groupcastId == conversationId,
      );

      if (mounted && broadcast != null) {
        final title = broadcast.groupcastTitle;
        final membersCount = broadcast.membersCount;
        // Get member names from metadata
        final memberNames = broadcast.metaData?.membersDetail
                ?.map((e) => e.memberName ?? '')
                .where((name) => name.isNotEmpty)
                .toList() ??
            [];

        // Update title, member count, and member names
        setState(() {
          if (title != null &&
              title.isNotEmpty &&
              title != IsmChatStrings.defaultString) {
            _broadcastTitle = title;
          } else {
            // Clear title to show "X Recipients Selected" fallback
            _broadcastTitle = null;
          }
          _broadcastMembersCount = membersCount;
          _broadcastMemberNames = memberNames;
        });
      }
    } catch (e) {
      // Log error for debugging but don't show to user
      IsmChatLog.error('Error fetching broadcast title: $e');
    }
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) {
          // Refetch title if conversationId is available but we don't have the title yet
          final conversationId = controller.conversation?.conversationId;
          if (conversationId != null &&
              conversationId.isNotEmpty &&
              (_broadcastTitle == null || _broadcastTitle!.isEmpty)) {
            // Fetch title asynchronously without blocking UI
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchBroadcastTitle();
            });
          }
          return Scaffold(
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageTheme?.backgroundColor ??
                    IsmChatColors.whiteColor,
            appBar: IsmChatAppBar(
              height: IsmChatDimens.fiftyFive,
              leading: IsmChatTapHandler(
                onTap: widget.onBackTap,
                child: Padding(
                  padding: IsmChatDimens.edgeInsetsLeft10,
                  child: Icon(
                    IsmChatResponsive.isWeb(context)
                        ? Icons.close_rounded
                        : Icons.arrow_back_rounded,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.whiteColor,
                  ),
                ),
              ),
              centerTitle: false,
              leadingWidth: IsmChatDimens.forty,
              title: IsmChatTapHandler(
                onTap: () async {
                  final conversation = controller.conversation;
                  if (conversation?.conversationId != null) {
                    final broadcast = BroadcastModel(
                      sendPushForNewConversationCreated: true,
                      hideNewConversationsForSender: false,
                      customType: IsmChatStrings.broadcast,
                      groupcastId: conversation?.conversationId,
                      groupcastTitle: _broadcastTitle,
                      membersCount: conversation?.members?.length ?? 0,
                    );
                    // Navigate to edit screen and wait for result
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => IsmChatEditBroadcastView(
                          broadcast: broadcast,
                        ),
                      ),
                    );
                    // Refetch broadcast title when returning from edit screen
                    // Add a small delay to ensure the update has completed
                    if (mounted) {
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (mounted) {
                        _fetchBroadcastTitle();
                      }
                    }
                  }
                },
                child: Row(
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
                            _broadcastTitle != null &&
                                    _broadcastTitle!.isNotEmpty &&
                                    _broadcastTitle !=
                                        IsmChatStrings.defaultString
                                ? _broadcastTitle!
                                : '${_broadcastMembersCount ?? controller.conversation?.members?.length ?? 0} Recipients Selected',
                            style: IsmChatConfig.chatTheme.chatPageHeaderTheme
                                    ?.titleStyle ??
                                IsmChatStyles.w600White16,
                          ),
                          Text(
                            () {
                              // Use broadcast member names if available, otherwise fallback to conversation members
                              final memberNames =
                                  _broadcastMemberNames.isNotEmpty
                                      ? _broadcastMemberNames
                                      : controller.conversation?.members
                                              ?.map((e) => e.userName)
                                              .where((name) => name.isNotEmpty)
                                              .toList() ??
                                          [];

                              // Show only first 3 member names
                              final displayMembers =
                                  memberNames.take(3).toList();
                              final remainingCount = memberNames.length > 3
                                  ? memberNames.length - 3
                                  : 0;

                              if (remainingCount > 0) {
                                return '${displayMembers.join(', ')} and $remainingCount more';
                              } else {
                                return displayMembers.join(', ');
                              }
                            }(),
                            style: IsmChatConfig.chatTheme.chatPageHeaderTheme
                                    ?.subtileStyle ??
                                IsmChatStyles.w400White12,
                            overflow: TextOverflow.ellipsis,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: IsmChatConfig
                      .chatTheme.chatPageHeaderTheme?.backgroundColor ??
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
          );
        },
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
