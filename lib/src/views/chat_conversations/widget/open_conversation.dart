import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatOpenConversationView extends StatefulWidget {
  const IsmChatOpenConversationView({super.key});

  @override
  State<IsmChatOpenConversationView> createState() =>
      _IsmChatOpenConversationViewState();
}

class _IsmChatOpenConversationViewState
    extends State<IsmChatOpenConversationView> {
  var scrollController = ScrollController();
  final converstaionController = IsmChatUtility.conversationController;
  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(() {
      converstaionController
          .intiPublicAndOpenConversation(IsmChatConversationType.open);
      scrollController.addListener(() {
        if (scrollController.offset.toInt() ==
            scrollController.position.maxScrollExtent.toInt()) {
          converstaionController.getPublicAndOpenConversation(
            conversationType: IsmChatConversationType.open.value,
            skip: converstaionController.publicAndOpenConversation.length
                .pagination(),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
        tag: IsmChat.i.chatListPageTag,
        builder: (controller) => Scaffold(
          appBar: [
            IsmChatConversationPosition.tabBar,
            IsmChatConversationPosition.navigationBar
          ].contains(
                  IsmChatProperties.conversationProperties.conversationPosition)
              ? null
              : IsmChatAppBar(
                  height: IsmChatDimens.fiftyFive,
                  title: controller.showSearchField
                      ? IsmChatInputField(
                          fillColor: IsmChatConfig.chatTheme.primaryColor,
                          style: IsmChatStyles.w400White16,
                          hint: IsmChatStrings.searchUser,
                          hintStyle: IsmChatStyles.w400White16,
                          onChanged: (value) {
                            controller.debounce.run(
                              () {
                                if (value.trim().isNotEmpty) {
                                  controller
                                    ..isLoadResponse = false
                                    ..getPublicAndOpenConversation(
                                      searchTag: value,
                                      conversationType:
                                          IsmChatConversationType.public.value,
                                    );
                                }
                              },
                            );
                          },
                        )
                      : Text(
                          IsmChatStrings.openConversation,
                          style: IsmChatStyles.w600White18,
                        ),
                  action: [
                    IconButton(
                      onPressed: () {
                        controller.showSearchField =
                            !controller.showSearchField;
                      },
                      icon: Icon(
                        controller.showSearchField
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        color: IsmChatColors.whiteColor,
                      ),
                    ),
                  ],
                ),
          body: controller.publicAndOpenConversation.isEmpty
              ? controller.isLoadResponse
                  ? Center(
                      child: Text(
                        IsmChatStrings.noConversationFound,
                        style: IsmChatStyles.w600Black16,
                      ),
                    )
                  : const IsmChatLoadingDialog()
              : SizedBox(
                  height: IsmChatDimens.percentHeight(1),
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: controller.publicAndOpenConversation.length,
                    itemBuilder: (_, index) {
                      var data = controller.publicAndOpenConversation[index];
                      return Column(
                        children: [
                          ListTile(
                            onTap: () async {
                              var response = await controller.joinObserver(
                                  conversationId: data.conversationId ?? '',
                                  isLoading: true);
                              if (response != null) {
                                IsmChatProperties
                                        .conversationProperties.onChatTap!(
                                    IsmChatConfig
                                            .kNavigatorKey.currentContext ??
                                        IsmChatConfig.context,
                                    data);
                                controller.updateLocalConversation(data);

                                if (IsmChatResponsive.isWeb(IsmChatConfig
                                        .kNavigatorKey.currentContext ??
                                    IsmChatConfig.context)) {
                                  IsmChatRoute.goBack();

                                  if (!IsmChatUtility
                                      .chatPageControllerRegistered) {
                                    IsmChatPageBinding().dependencies();
                                  }
                                  controller.isRenderChatPageaScreen =
                                      IsRenderChatPageScreen
                                          .openChatMessagePage;
                                  final chatPagecontroller =
                                      IsmChatUtility.chatPageController;
                                  chatPagecontroller.messages.clear();
                                  chatPagecontroller.closeOverlay();
                                  // Defer initialization to allow UI to render first
                                  unawaited(Future.microtask(
                                      () => chatPagecontroller.startInit(
                                            isBroadcasts: true,
                                          )));
                                  chatPagecontroller.messages.add(
                                    IsmChatMessageModel(
                                      body: '',
                                      userName: IsmChatConfig
                                              .communicationConfig
                                              .userConfig
                                              .userName ??
                                          controller.userDetails?.userName ??
                                          '',
                                      customType:
                                          IsmChatCustomMessageType.observerJoin,
                                      sentAt:
                                          DateTime.now().millisecondsSinceEpoch,
                                      sentByMe: true,
                                    ),
                                  );
                                  chatPagecontroller.messages =
                                      chatPagecontroller.commonController
                                          .sortMessages(
                                    chatPagecontroller.messages,
                                  );
                                } else {
                                  await IsmChatRoute.goToRoute(
                                    const IsmChatOpenChatMessagePage(),
                                  );
                                }
                              }
                            },
                            leading: IsmChatImage.profile(
                              data.profileUrl,
                              name: data.chatName,
                            ),
                            title: Text(
                              data.chatName,
                              style: IsmChatStyles.w600Black14,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.person_rounded),
                                Text(
                                  '${data.membersCount} members',
                                  style: IsmChatStyles.w400Black14,
                                )
                              ],
                            ),
                            trailing: Column(
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: IsmChatDimens.sixty,
                                  height: IsmChatDimens.twentyFive,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: IsmChatConfig.chatTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(
                                        IsmChatDimens.ten),
                                  ),
                                  child: Text(
                                    'Open',
                                    style: IsmChatStyles.w500White14,
                                  ),
                                ),
                                IsmChatDimens.boxWidth4,
                                Text(
                                  data.createdAt?.toLastMessageTimeString ?? '',
                                  style: IsmChatStyles.w400Black12,
                                )
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  ),
                ),
        ),
      );
}
