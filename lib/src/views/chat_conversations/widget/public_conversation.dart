import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPublicConversationView extends StatefulWidget {
  const IsmChatPublicConversationView({super.key});

  static const String route = IsmPageRoutes.publicView;

  @override
  State<IsmChatPublicConversationView> createState() =>
      _IsmChatPublicConversationViewState();
}

class _IsmChatPublicConversationViewState
    extends State<IsmChatPublicConversationView> {
  final converstaionController = Get.find<IsmChatConversationsController>();
  var scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(
      () {
        converstaionController
            .intiPublicAndOpenConversation(IsmChatConversationType.public);
        scrollController.addListener(() {
          if (scrollController.offset.toInt() ==
              scrollController.position.maxScrollExtent.toInt()) {
            converstaionController.getPublicAndOpenConversation(
              conversationType: IsmChatConversationType.public.value,
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
      builder: (controller) => Scaffold(
            appBar: [
              IsmChatConversationPosition.tabBar,
              IsmChatConversationPosition.navigationBar
            ].contains(IsmChatProperties
                    .conversationProperties.conversationPosition)
                ? null
                : IsmChatAppBar(
                    title: controller.showSearchField
                        ? IsmChatInputField(
                            fillColor: IsmChatConfig.chatTheme.primaryColor,
                            style: IsmChatStyles.w400White16,
                            hint: IsmChatStrings.searchUser,
                            hintStyle: IsmChatStyles.w400White16,
                            onChanged: (value) {
                              controller.debounce.run(
                                () {
                                  controller.isLoadResponse = false;
                                  controller.getPublicAndOpenConversation(
                                    searchTag:
                                        value.trim().isNotEmpty ? value : '',
                                    conversationType:
                                        IsmChatConversationType.public.value,
                                  );
                                },
                              );
                            },
                          )
                        : Text(
                            IsmChatStrings.publicConversation,
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
                    height: Get.height,
                    child: ListView.builder(
                      itemCount: controller.publicAndOpenConversation.length,
                      itemBuilder: (_, index) {
                        var data = controller.publicAndOpenConversation[index];
                        return Column(
                          children: [
                            ListTile(
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
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  IsmChatTapHandler(
                                    onTap: () {
                                      controller.joinConversation(
                                        conversationId:
                                            data.conversationId ?? '',
                                        isloading: true,
                                      );
                                    },
                                    child: Container(
                                      width: IsmChatDimens.sixty,
                                      height: IsmChatDimens.twentyFive,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: IsmChatColors.greenColor,
                                        borderRadius: BorderRadius.circular(
                                            IsmChatDimens.ten),
                                      ),
                                      child: Text(
                                        'Join',
                                        style: IsmChatStyles.w500White14,
                                      ),
                                    ),
                                  ),
                                  IsmChatDimens.boxWidth4,
                                  Text(
                                    data.createdAt!.toLastMessageTimeString(),
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
          ));
}
