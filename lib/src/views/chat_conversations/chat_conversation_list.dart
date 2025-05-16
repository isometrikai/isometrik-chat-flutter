import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// `ChatConversationList` can be used to show the list of all the conversations user has done.
class IsmChatConversationList extends StatelessWidget {
  const IsmChatConversationList({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        builder: (controller) {
          if (controller.isConversationsLoading) {
            return const IsmChatLoadingDialog();
          }
          if (controller.userConversations.isEmpty) {
            return SmartRefresher(
              physics: const ClampingScrollPhysics(),
              controller: controller.refreshControllerOnEmptyList,
              enablePullDown: true,
              enablePullUp: true,
              onRefresh: () {
                controller.getChatConversations(
                  origin: ApiCallOrigin.referesh,
                );
              },
              child: Center(
                child: IsmChatProperties.conversationProperties.placeholder ??
                    const IsmChatEmptyView(
                      icon: Icon(Icons.chat_outlined),
                      text: IsmChatStrings.noConversation,
                    ),
              ),
            );
          }
          return SizedBox(
            height: IsmChatProperties.conversationProperties.height ??
                IsmChatDimens.percentHeight(1),
            child: kIsWeb
                ? SlidableAutoCloseBehavior(
                    child: _ConversationList(),
                  )
                : SmartRefresher(
                    physics: const ClampingScrollPhysics(),
                    controller: controller.refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: () {
                      controller.getChatConversations(
                        origin: ApiCallOrigin.referesh,
                      );
                      Get.find<IsmChatMqttController>()
                          .getChatConversationsUnreadCount();
                    },
                    onLoading: () {
                      controller.getChatConversations(
                        skip: controller.conversations.length.pagination(),
                        origin: ApiCallOrigin.loadMore,
                      );
                    },
                    child: SlidableAutoCloseBehavior(
                      child: _ConversationList(),
                    ),
                  ),
          );
        },
      );
}

class _ConversationList extends StatelessWidget {
  _ConversationList();

  final controller = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: IsmChatDimens.edgeInsets0_10,
        shrinkWrap: true,
        itemCount: controller.userConversations.length,
        controller: controller.conversationScrollController,
        separatorBuilder: (_, __) =>
            IsmChatProperties.conversationProperties.conversationDivider ??
            IsmChatDimens.boxHeight2,
        addAutomaticKeepAlives: true,
        itemBuilder: (_, index) {
          var conversation = controller.userConversations[index];
          return IsmChatTapHandler(
            onTap: () async {
              IsmChatProperties.conversationProperties.onChatTap
                  ?.call(_, conversation);
              if (IsmChatProperties.conversationProperties.shouldGoToChatPage
                      ?.call(context, conversation) ??
                  true) {
                controller.updateLocalConversation(conversation);
                await controller.goToChatPage();
              }
            },
            child: IsmChatProperties.conversationProperties.cardBuilder
                    ?.call(_, conversation, index) ??
                _SlidableWidget(conversation: conversation),
          );
        },
      );
}

class _SlidableWidget extends StatefulWidget {
  const _SlidableWidget({required this.conversation});

  final IsmChatConversationModel conversation;

  @override
  State<_SlidableWidget> createState() => _SlidableWidgetState();
}

class _SlidableWidgetState extends State<_SlidableWidget>
    with SingleTickerProviderStateMixin {
  SlidableController? slidableController;

  final controller = Get.find<IsmChatConversationsController>();

  @override
  void initState() {
    slidableController = SlidableController(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Slidable(
        controller: slidableController,
        direction: Axis.horizontal,
        enabled: IsmChatProperties.conversationProperties.isSlidableEnable
                ?.call(context, widget.conversation) ??
            false,
        startActionPane: !(IsmChatProperties
                    .conversationProperties.startActionSlidableEnable
                    ?.call(context, widget.conversation) ??
                false)
            ? null
            : (IsmChatProperties.conversationProperties.actions == null ||
                    IsmChatProperties.conversationProperties.actions?.isEmpty ==
                        true)
                ? null
                : ActionPane(
                    extentRatio: 0.3,
                    motion: const ScrollMotion(),
                    children: [
                      ...IsmChatProperties.conversationProperties.actions?.map(
                            (e) => IsmChatActionWidget(
                              onTap: () {
                                slidableController?.close();
                                e.onTap.call(widget.conversation);
                              },
                              decoration: e.decoration,
                              icon: e.icon,
                              label: e.label,
                              labelStyle: e.labelStyle,
                            ),
                          ) ??
                          [],
                    ],
                  ),
        endActionPane: !IsmChatProperties.conversationProperties.allowDelete &&
                !(IsmChatProperties
                        .conversationProperties.endActionSlidableEnable
                        ?.call(context, widget.conversation) ??
                    true)
            ? null
            : !IsmChatProperties.conversationProperties.allowDelete &&
                    (IsmChatProperties.conversationProperties.endActions ==
                            null ||
                        IsmChatProperties
                                .conversationProperties.endActions?.isEmpty ==
                            true)
                ? null
                : ActionPane(
                    extentRatio: 0.3,
                    motion: const StretchMotion(),
                    children: [
                      ...IsmChatProperties.conversationProperties.endActions
                              ?.map(
                            (e) => IsmChatActionWidget(
                              onTap: () {
                                slidableController?.close();
                                e.onTap.call(widget.conversation);
                              },
                              decoration: e.decoration,
                              icon: e.icon,
                              label: e.label,
                              labelStyle: e.labelStyle,
                            ),
                          ) ??
                          [],
                      if (IsmChatProperties.conversationProperties.allowDelete)
                        SlidableAction(
                          onPressed: (_) async {
                            await IsmChatContextWidget.showBottomsheetContext(
                              content: IsmChatClearConversationBottomSheet(
                                widget.conversation,
                              ),
                              isDismissible: false,
                              elevation: 0,
                            );
                          },
                          flex: 1,
                          backgroundColor: IsmChatColors.redColor,
                          foregroundColor: IsmChatColors.whiteColor,
                          icon: const Icon(
                            Icons.delete_rounded,
                            color: IsmChatColors.whiteColor,
                          ).icon,
                          label: IsmChatStrings.delete,
                        ),
                    ],
                  ),
        child: Obx(
          () => IsmChatConversationCard(
            canShowStack: IsmChatProperties
                .conversationProperties.cardElementBuilders?.canShowStack,
            onProfileTap: IsmChatProperties
                .conversationProperties.cardElementBuilders?.onProfileTap,
            isShowBackgroundColor: IsmChatResponsive.isWeb(context)
                ? controller.currentConversationId ==
                    widget.conversation.conversationId
                : false,
            name: IsmChatProperties
                .conversationProperties.cardElementBuilders?.name,
            nameBuilder: IsmChatProperties
                .conversationProperties.cardElementBuilders?.nameBuilder,
            trailing: IsmChatProperties
                .conversationProperties.cardElementBuilders?.trailing,
            trailingBuilder: IsmChatProperties
                .conversationProperties.cardElementBuilders?.trailingBuilder,
            profileImageUrl: IsmChatProperties
                .conversationProperties.cardElementBuilders?.profileImageUrl,
            subtitle: IsmChatProperties
                .conversationProperties.cardElementBuilders?.subtitle,
            widget.conversation,
            profileImageBuilder: IsmChatProperties.conversationProperties
                .cardElementBuilders?.profileImageBuilder,
            subtitleBuilder: !widget.conversation.isSomeoneTyping
                ? IsmChatProperties
                    .conversationProperties.cardElementBuilders?.subtitleBuilder
                : (_, __, ___) => Text(
                      widget.conversation.typingUsers,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IsmChatStyles.typing,
                    ),
            onTap: () async {
              if (IsmChatProperties.conversationProperties.onChatTap != null) {
                IsmChatProperties.conversationProperties.onChatTap?.call(
                  context,
                  widget.conversation,
                );
              }
              if (IsmChatProperties.conversationProperties.shouldGoToChatPage
                      ?.call(context, widget.conversation) ??
                  true) {
                controller.updateLocalConversation(widget.conversation);
                unawaited(Get.find<IsmChatMqttController>()
                    .getChatConversationsUnreadCount());
                await controller.goToChatPage();
              }
            },
          ),
        ),
      );
}
