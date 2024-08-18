import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatEligibleMembersView extends StatelessWidget {
  IsmChatEligibleMembersView({super.key});

  static const String route = IsmPageRoutes.eligibleMemberstView;

  final groupcastId = Get.arguments as String;

  @override
  Widget build(BuildContext context) => GetX<IsmChatBroadcastController>(
        initState: (state) {
          IsmChatUtility.doLater(() async {
            final controller = Get.find<IsmChatBroadcastController>();
            controller.isApiCall = false;
            controller.showSearchField = false;
            controller.selectedUserList.clear();
            controller.eligibleMembers.clear();
            await controller.getEligibleMembers(
              groupcastId: groupcastId,
            );
          });
        },
        builder: (controller) => Scaffold(
          appBar: IsmChatAppBar(
            title: controller.showSearchField
                ? IsmChatInputField(
                    fillColor: IsmChatConfig.chatTheme.primaryColor,
                    controller: controller.searchMemberController,
                    style: IsmChatStyles.w400White16,
                    hint: IsmChatStrings.searchUser,
                    hintStyle: IsmChatStyles.w400White16,
                    onChanged: (value) {
                      if (value.isNullOrEmpty) {
                        controller.eligibleMembers =
                            controller.eligibleMembersduplicate
                                .map((e) => SelectedMembers(
                                      isUserSelected:
                                          controller.selectedUserList.any((d) =>
                                              d.userId == e.userDetails.userId),
                                      userDetails: e.userDetails,
                                      isBlocked: e.isBlocked,
                                      tagIndex: e.tagIndex,
                                    ))
                                .toList();
                        controller.handleList(controller.eligibleMembers);
                        return;
                      }
                      controller.debounce.run(() async {
                        if (value.length > 4) {
                          await controller.getEligibleMembers(
                            groupcastId: groupcastId,
                            shouldShowLoader: false,
                            searchTag: value,
                          );
                        }
                      });
                    },
                  )
                : Text(
                    IsmChatStrings.eligibleMembers,
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
                  ),
            action: [
              IconButton(
                  onPressed: () {
                    controller.showSearchField = !controller.showSearchField;
                    controller.searchMemberController.clear();
                    if (!controller.showSearchField &&
                        controller.eligibleMembersduplicate.isNotEmpty) {
                      controller.eligibleMembers = controller
                          .eligibleMembersduplicate
                          .map((e) => SelectedMembers(
                              isUserSelected: controller.selectedUserList
                                  .any((d) => d.userId == e.userDetails.userId),
                              userDetails: e.userDetails,
                              isBlocked: e.isBlocked,
                              tagIndex: e.tagIndex))
                          .toList();
                      controller.handleList(controller.eligibleMembers);
                    }
                  },
                  icon: Icon(
                    controller.showSearchField
                        ? Icons.clear_rounded
                        : Icons.search_rounded,
                    color: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.iconColor ??
                        IsmChatColors.whiteColor,
                  ))
            ],
          ),
          body: controller.isApiCall
              ? const IsmChatLoadingDialog()
              : controller.eligibleMembers.isEmpty
                  ? const Center(
                      child: IsmIconAndText(
                        icon: Icons.supervised_user_circle_rounded,
                        text: IsmChatStrings.boradcastNotFound,
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: AzListWidgtet(
                            data: controller.eligibleMembers,
                            builderList: controller.eligibleMembers,
                            imageUrl: (data) => data.userDetails.profileUrl,
                            title: (data) => data.userDetails.userName,
                            subTitle: (data) => data.userDetails.userIdentifier,
                            isSelected: (data) => data.isUserSelected,
                            onTap: (index, data) {
                              controller.onEligibleMemberTap(index);
                              controller.isSelectedMembers(
                                data.userDetails,
                              );
                            },
                            onScollLoadMore: () {
                              controller.getEligibleMembers(
                                shouldShowLoader: false,
                                groupcastId: groupcastId,
                                skip: controller.eligibleMembers.length
                                    .pagination(),
                              );
                            },
                            onScollRefresh: () {
                              controller.getEligibleMembers(
                                  groupcastId: groupcastId,
                                  shouldShowLoader: false);
                            },
                          ),
                        ),
                        if (controller.selectedUserList.isNotEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                top: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                              ),
                            ),
                            height: IsmChatDimens.eighty,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount:
                                        controller.selectedUserList.length,
                                    separatorBuilder: (_, __) =>
                                        IsmChatDimens.boxWidth8,
                                    itemBuilder: (context, index) {
                                      var user =
                                          controller.selectedUserList[index];
                                      return InkWell(
                                        onTap: () {
                                          controller.isSelectedMembers(user);
                                          controller.onEligibleMemberTap(
                                            controller.eligibleMembers.indexOf(
                                              controller.eligibleMembers
                                                  .selectedUsers[index],
                                            ),
                                          );
                                        },
                                        child: SizedBox(
                                          width: IsmChatDimens.fifty,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Stack(
                                                clipBehavior: Clip.none,
                                                children: [
                                                  SizedBox(
                                                    width: IsmChatDimens.forty,
                                                    height: IsmChatDimens.forty,
                                                    child: IsmChatImage.profile(
                                                      user.userProfileImageUrl,
                                                      name: user.userName,
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: IsmChatDimens
                                                        .twentySeven,
                                                    left: IsmChatDimens
                                                        .twentySeven,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          IsmChatConfig
                                                              .chatTheme
                                                              .backgroundColor,
                                                      radius:
                                                          IsmChatDimens.eight,
                                                      child: Icon(
                                                        Icons.close_rounded,
                                                        color: IsmChatConfig
                                                            .chatTheme
                                                            .primaryColor,
                                                        size: IsmChatDimens
                                                            .twelve,
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height:
                                                    IsmChatDimens.twentyEight,
                                                child: Text(
                                                  user.userName,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      IsmChatStyles.w600Black10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                IsmChatDimens.boxWidth8,
                                FloatingActionButton(
                                  elevation: 0,
                                  shape: const CircleBorder(),
                                  backgroundColor:
                                      IsmChatConfig.chatTheme.primaryColor,
                                  child: const Icon(
                                    Icons.done_rounded,
                                    color: IsmChatColors.whiteColor,
                                  ),
                                  onPressed: () async {
                                    await controller.addEligibleMembers(
                                      groupcastId: groupcastId,
                                      members: controller.selectedUserList,
                                    );
                                  },
                                ),
                                IsmChatDimens.boxWidth8,
                              ],
                            ),
                          ),
                      ],
                    ),
        ),
      );
}
