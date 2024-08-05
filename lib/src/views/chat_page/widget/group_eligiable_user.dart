import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatGroupEligibleUser extends StatelessWidget {
  const IsmChatGroupEligibleUser({super.key});

  static const String route = IsmPageRoutes.groupEligiableView;

  Widget _buildSusWidget(String susTag) => Container(
        padding: IsmChatDimens.edgeInsets10_0,
        height: IsmChatDimens.forty,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              susTag,
              textScaler: const TextScaler.linear(1.5),
              style: IsmChatStyles.w600Black14,
            ),
            SizedBox(
                width: IsmChatDimens.percentWidth(
                    IsmChatResponsive.isWeb(Get.context!) ? .24 : .7),
                child: Divider(
                  height: .0,
                  indent: IsmChatDimens.ten,
                ))
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        initState: (_) {
          var chatPageController = Get.find<IsmChatPageController>();
          chatPageController.groupEligibleUser.clear();
          chatPageController.canCallCurrentApi = false;
          chatPageController.isMemberSearch = false;
          chatPageController.getEligibleMembers(
              conversationId: chatPageController.conversation!.conversationId!,
              limit: 20);
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: IsmChatAppBar(
            onBack: !IsmChatResponsive.isWeb(context)
                ? null
                : () => Get.find<IsmChatConversationsController>()
                        .isRenderChatPageaScreen =
                    IsRenderChatPageScreen.coversationInfoView,
            title: controller.isMemberSearch
                ? IsmChatInputField(
                    fillColor: IsmChatConfig.chatTheme.primaryColor,
                    autofocus: true,
                    hint: 'Search user..',
                    hintStyle: IsmChatStyles.w600White16,
                    cursorColor: IsmChatColors.whiteColor,
                    style: IsmChatStyles.w600White16,
                    controller: controller.participnatsEditingController,
                    onChanged: (value) {
                      controller.addParticipantSearch(value);
                    },
                  )
                : Text(
                    'Add participants...  ${controller.groupEligibleUser.selectedUsers.isEmpty ? '' : controller.groupEligibleUser.selectedUsers.length}',
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
                  ),
            action: [
              IconButton(
                onPressed: () {
                  controller.isMemberSearch = !controller.isMemberSearch;
                  controller.participnatsEditingController.clear();
                  controller.addParticipantSearch('');
                },
                icon: Icon(
                  controller.isMemberSearch
                      ? Icons.clear_rounded
                      : Icons.search_rounded,
                  color: IsmChatColors.whiteColor,
                ),
              )
            ],
          ),
          body: controller.groupEligibleUser.isEmpty
              ? controller.isMemberSearch
                  ? Center(
                      child: Text(
                        'No user found',
                        style: IsmChatStyles.w600Black16,
                      ),
                    )
                  : const IsmChatLoadingDialog()
              : SizedBox(
                  child: Column(
                    children: [
                      Expanded(
                          child: NotificationListener<ScrollNotification>(
                        onNotification: (scrollNotification) {
                          if (scrollNotification is ScrollEndNotification) {
                            if (scrollNotification.metrics.pixels >
                                scrollNotification.metrics.maxScrollExtent *
                                    0.7) {
                              controller.getEligibleMembers(
                                conversationId:
                                    controller.conversation!.conversationId!,
                                limit: 20,
                              );
                            }
                          }
                          return true;
                        },
                        child: AzListView(
                          data: controller.groupEligibleUser,
                          itemCount: controller.groupEligibleUser.length,
                          physics: const BouncingScrollPhysics(),
                          indexHintBuilder: (context, hint) => Container(
                            alignment: Alignment.center,
                            width: IsmChatDimens.eighty,
                            height: IsmChatDimens.eighty,
                            decoration: BoxDecoration(
                              color: IsmChatConfig.chatTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: Text(hint,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30.0)),
                          ),
                          indexBarData: SuspensionUtil.getTagIndexList(
                              controller.groupEligibleUser),
                          // const [
                          //   'A',
                          //   'B',
                          //   'C',
                          //   'D',
                          //   'E',
                          //   'F',
                          //   'G',
                          //   'H',
                          //   'I',
                          //   'J',
                          //   'K',
                          //   'L',
                          //   'M',
                          //   'N',
                          //   'O',
                          //   'P',
                          //   'Q',
                          //   'R',
                          //   'S',
                          //   'T',
                          //   'U',
                          //   'V',
                          //   'W',
                          //   'X',
                          //   'Y',
                          //   'Z'
                          // ],
                          indexBarMargin: IsmChatDimens.edgeInsets10,
                          indexBarHeight: IsmChatDimens.percentHeight(5),
                          indexBarWidth: IsmChatDimens.forty,
                          indexBarItemHeight: IsmChatDimens.twenty,

                          indexBarOptions: IndexBarOptions(
                            indexHintDecoration: const BoxDecoration(
                              color: IsmChatColors.whiteColor,
                            ),
                            indexHintChildAlignment: Alignment.center,
                            selectTextStyle: IsmChatStyles.w400White12,
                            selectItemDecoration: BoxDecoration(
                              color: IsmChatConfig.chatTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            needRebuild: true,
                            indexHintHeight: IsmChatDimens.percentHeight(.2),
                          ),
                          itemBuilder: (_, int index) {
                            var user = controller.groupEligibleUser[index];
                            var susTag = user.getSuspensionTag();
                            if (user.userDetails.userId ==
                                IsmChatConfig
                                    .communicationConfig.userConfig.userId) {
                              return const SizedBox.shrink();
                            }
                            return IsmChatTapHandler(
                              onTap: () =>
                                  controller.onGrouEligibleUserTap(index),
                              child: Column(
                                children: [
                                  Offstage(
                                    offstage: user.isShowSuspension != true,
                                    child: _buildSusWidget(susTag),
                                  ),
                                  Container(
                                    color: controller.groupEligibleUser[index]
                                            .isUserSelected
                                        ? IsmChatConfig.chatTheme.primaryColor!
                                            .withOpacity(.2)
                                        : null,
                                    child: Column(
                                      children: [
                                        ListTile(
                                          dense: true,
                                          leading: IsmChatImage.profile(
                                            user.userDetails.profileUrl,
                                            name: user.userDetails.userName
                                                    .capitalizeFirst ??
                                                '',
                                          ),
                                          title: Text(
                                            user.userDetails.userName
                                                    .capitalizeFirst ??
                                                '',
                                            style: IsmChatStyles.w600Black14,
                                          ),
                                          subtitle: Text(
                                            user.userDetails.userIdentifier,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: IsmChatStyles.w400Black12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )),
                      if (controller.groupEligibleUser.selectedUsers.isNotEmpty)
                        const _SelectedUsers(),
                    ],
                  ),
                ),
        ),
      );
}

class _SelectedUsers extends StatelessWidget {
  const _SelectedUsers();

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: IsmChatConfig.chatTheme.backgroundColor,
            ),
            height: IsmChatDimens.ninty,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                        controller.groupEligibleUser.selectedUsers.length,
                    separatorBuilder: (_, __) => IsmChatDimens.boxWidth8,
                    itemBuilder: (context, index) {
                      var conversation = controller
                          .groupEligibleUser.selectedUsers[index].userDetails;
                      return IsmChatTapHandler(
                        onTap: () => controller.onGrouEligibleUserTap(
                          controller.groupEligibleUser.indexOf(
                            controller.groupEligibleUser.selectedUsers[index],
                          ),
                        ),
                        child: SizedBox(
                          width: IsmChatDimens.fifty,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  SizedBox(
                                    width: IsmChatDimens.forty,
                                    height: IsmChatDimens.forty,
                                    child: IsmChatImage.profile(
                                      conversation.userProfileImageUrl,
                                      name: conversation.userName,
                                    ),
                                  ),
                                  Positioned(
                                    top: IsmChatDimens.twentySeven,
                                    left: IsmChatDimens.twentySeven,
                                    child: CircleAvatar(
                                      backgroundColor:
                                          IsmChatConfig.chatTheme.primaryColor,
                                      radius: IsmChatDimens.eight,
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: IsmChatColors.whiteColor,
                                        size: IsmChatDimens.twelve,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: IsmChatDimens.twentyEight,
                                child: Text(
                                  conversation.userName,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: IsmChatStyles.w600Black10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IsmChatDimens.boxWidth4,
                FloatingActionButton(
                  elevation: 0,
                  shape: const CircleBorder(),
                  backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                  child: const Icon(
                    Icons.check,
                    color: IsmChatColors.whiteColor,
                  ),
                  onPressed: () async {
                    var memberIds = <String>[];
                    for (var x in controller.groupEligibleUser) {
                      if (x.isUserSelected == true) {
                        memberIds.add(x.userDetails.userId);
                      }
                    }
                    Get.back<void>();
                    await controller.addMembers(
                        isLoading: true, memberIds: memberIds);
                  },
                ),
                IsmChatDimens.boxWidth4,
              ],
            ),
          ),
        ),
      );
}
