import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmChatConversationSearchView extends StatelessWidget {
  const IsmChatConversationSearchView({super.key});

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        tag: IsmChat.i.chatListPageTag,
        initState: (state) {
          IsmChatUtility.doLater(() async {
            await IsmChatUtility.conversationController
                .getChatSearchConversations();
          });
        },
        builder: (controller) => Scaffold(
          body: controller.isConversationsLoading
              ? const IsmChatLoadingDialog()
              : SmartRefresher(
                  physics: const ClampingScrollPhysics(),
                  controller: controller.searchConversationrefreshController,
                  enablePullDown: true,
                  enablePullUp: true,
                  onRefresh: () {
                    controller.getChatSearchConversations(
                      skip: 0,
                      origin: ApiCallOrigin.referesh,
                    );
                  },
                  onLoading: () {
                    controller.getChatSearchConversations(
                      skip:
                          controller.searchConversationList.length.pagination(),
                      origin: ApiCallOrigin.loadMore,
                    );
                  },
                  child: SizedBox(
                    height: IsmChatProperties.conversationProperties.height ??
                        IsmChatDimens.percentHeight(1),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.searchConversationList.length,
                        itemBuilder: (context, index) {
                          final conversation =
                              controller.searchConversationList[index];
                          return Column(
                            children: [
                              IsmChatConversationCard(
                                isShowBackgroundColor:
                                    IsmChatResponsive.isWeb(context)
                                        ? controller.currentConversationId ==
                                            conversation.conversationId
                                        : false,
                                name: IsmChatProperties.conversationProperties
                                    .cardElementBuilders?.name,
                                nameBuilder: IsmChatProperties
                                    .conversationProperties
                                    .cardElementBuilders
                                    ?.nameBuilder,
                                profileImageUrl: IsmChatProperties
                                    .conversationProperties
                                    .cardElementBuilders
                                    ?.profileImageUrl,
                                subtitle: IsmChatProperties
                                    .conversationProperties
                                    .cardElementBuilders
                                    ?.subtitle,
                                conversation,
                                profileImageBuilder: IsmChatProperties
                                    .conversationProperties
                                    .cardElementBuilders
                                    ?.profileImageBuilder,
                                subtitleBuilder: !conversation.isSomeoneTyping
                                    ? IsmChatProperties.conversationProperties
                                        .cardElementBuilders?.subtitleBuilder
                                    : (_, __, ___) => Text(
                                          conversation.typingUsers,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: IsmChatStyles.typing,
                                        ),
                                onTap: () async {
                                  if (IsmChatProperties
                                          .conversationProperties.onChatTap !=
                                      null) {
                                    IsmChatProperties
                                        .conversationProperties.onChatTap
                                        ?.call(
                                      context,
                                      conversation,
                                    );
                                  }
                                  controller
                                      .updateLocalConversation(conversation);
                                  await controller.goToChatPage();
                                },
                                onLongPress: () {
                                  if (IsmChatProperties
                                          .conversationProperties.onLongPress !=
                                      null) {
                                    IsmChatProperties
                                        .conversationProperties.onLongPress
                                        ?.call(
                                      context,
                                      conversation,
                                    );
                                  }
                                },
                              ),
                              SizedBox(
                                width: IsmChatDimens.percentWidth(.95),
                                child: const Divider(),
                              )
                            ],
                          );
                        }),
                  ),
                ),
        ),
      );
}
