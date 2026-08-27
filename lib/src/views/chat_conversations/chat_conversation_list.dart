import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// `ChatConversationList` can be used to show the list of all the conversations user has done.
class IsmChatConversationList extends StatelessWidget {
  const IsmChatConversationList({
    super.key,
  });

  Future<void> _onRefresh() async {
    if (!IsmChatUtility.conversationControllerRegistered) {
      return;
    }
    final controller = IsmChatUtility.conversationController;
    // If user pulled-to-refresh while a search query is present,
    // clear it first so the refreshed list & query stay consistent.
    FocusManager.instance.primaryFocus?.unfocus();
    controller.searchConversationTEC.clear();
    await controller.getChatConversations(
      origin: ApiCallOrigin.referesh,
    );
    if (Get.isRegistered<IsmChatMqttController>()) {
      await Get.find<IsmChatMqttController>()
          .getChatConversationsUnreadCount();
    }
  }

  Future<bool> _onLoading() async {
    if (!IsmChatUtility.conversationControllerRegistered) {
      return true;
    }
    final controller = IsmChatUtility.conversationController;
    final chats = await controller.getChatConversations(
      skip: controller.conversations.length.pagination(),
      origin: ApiCallOrigin.loadMore,
    );
    return chats.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // GetX must only rebuild list/empty/loading content. [IsmChatPullToRefresh]
    // stays outside so host TabBarView / multiple list instances never share
    // one RefreshController (pull_to_refresh `_refresherState == null`).
    final content = GetX<IsmChatConversationsController>(
      tag: IsmChat.i.chatListPageTag,
      builder: (controller) {
        if (controller.isConversationsLoading) {
          return const IsmChatLoadingDialog();
        }
        if (controller.userConversations.isEmpty) {
          return Center(
            child: IsmChatProperties.conversationProperties.placeholder ??
                const IsmChatEmptyView(
                  icon: Icon(Icons.chat_outlined),
                  text: IsmChatStrings.noConversation,
                ),
          );
        }
        return SizedBox(
          height: IsmChatProperties.conversationProperties.height ??
              IsmChatDimens.percentHeight(1),
          child: SlidableAutoCloseBehavior(
            child: _ConversationList(),
          ),
        );
      },
    );

    if (kIsWeb) {
      return content;
    }

    return IsmChatPullToRefresh(
      footer: const RefreshFooter(),
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: content,
    );
  }
}

class _ConversationList extends StatelessWidget {
  _ConversationList();

  final controller = IsmChatUtility.conversationController;

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
                await controller.updateLocalConversation(conversation);
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

  final controller = IsmChatUtility.conversationController;

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
                              backgroundColor: IsmChatColors.transparent,
                              isDismissible: true,
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
                await controller.updateLocalConversation(widget.conversation);

                await controller.goToChatPage();
              }
            },
            onLongPress: () {
              if (IsmChatProperties.conversationProperties.onLongPress !=
                  null) {
                IsmChatProperties.conversationProperties.onLongPress?.call(
                  context,
                  widget.conversation,
                );
              }
            },
          ),
        ),
      );
}
