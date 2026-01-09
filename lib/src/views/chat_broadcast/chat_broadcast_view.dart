import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmChatBroadCastView extends StatelessWidget {
  const IsmChatBroadCastView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<IsmChatBroadcastController>()) {
      IsmChatBroadcastBinding().dependencies();
    }
    return GetX<IsmChatBroadcastController>(
      initState: (state) {
        Get.find<IsmChatBroadcastController>().getBroadCast();
      },
      builder: (controller) => Scaffold(
        appBar: IsmChatAppBar(
          height: IsmChatDimens.fiftyFive,
          title: Text(
            IsmChatStrings.broadcastList,
            style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                IsmChatStyles.w600White18,
          ),
        ),
        body: controller.isApiCall
            ? const IsmChatLoadingDialog()
            : controller.broadcastList.isEmpty
                ? SmartRefresher(
                    physics: const ClampingScrollPhysics(),
                    controller: controller.refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: () async {
                      await controller.getBroadCast(isShowLoader: false);
                      controller.refreshController.refreshCompleted();
                    },
                    child: const Center(
                      child: IsmIconAndText(
                        icon: Icons.supervised_user_circle_rounded,
                        text: IsmChatStrings.boradcastNotFound,
                      ),
                    ),
                  )
                : SmartRefresher(
                    physics: const ClampingScrollPhysics(),
                    controller: controller.refreshController,
                    enablePullDown: true,
                    enablePullUp: true,
                    onRefresh: () async {
                      await controller.getBroadCast(isShowLoader: false);
                      controller.refreshController.refreshCompleted();
                    },
                    onLoading: () async {
                      await controller.getBroadCast(
                        isShowLoader: false,
                        skip: controller.broadcastList.length.pagination(),
                      );
                      controller.refreshController.loadComplete();
                    },
                    child: SlidableAutoCloseBehavior(
                      child: ListView.builder(
                        physics: const ClampingScrollPhysics(),
                        itemCount: controller.broadcastList.length,
                        itemBuilder: (_, index) {
                          var broadcast = controller.broadcastList[index];
                          var allMembers = broadcast.metaData?.membersDetail
                                  ?.map((e) => e.memberName)
                                  .toList() ??
                              [];
                          // Show only first 3 member names
                          var members = allMembers.take(3).toList();
                          var remainingCount =
                              allMembers.length > 3 ? allMembers.length - 3 : 0;
                          return Slidable(
                            direction: Axis.horizontal,
                            closeOnScroll: true,
                            enabled: true,
                            startActionPane: ActionPane(
                              extentRatio: 0.3,
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (context) async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            IsmChatEditBroadcastView(
                                          broadcast: broadcast,
                                        ),
                                      ),
                                    );
                                    // Refresh broadcast list when returning from edit
                                    await controller.getBroadCast(
                                      isShowLoader: false,
                                    );
                                  },
                                  flex: 1,
                                  backgroundColor: IsmChatColors.greenColor,
                                  foregroundColor: IsmChatColors.whiteColor,
                                  icon: Icons.border_color_outlined,
                                  label: IsmChatStrings.edit,
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              extentRatio: 0.3,
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) async {
                                    await controller.deleteBroadcast(
                                      groupcastId: broadcast.groupcastId ?? '',
                                      isloading: true,
                                    );
                                  },
                                  flex: 1,
                                  backgroundColor: IsmChatColors.redColor,
                                  foregroundColor: IsmChatColors.whiteColor,
                                  icon: Icons.delete_rounded,
                                  label: IsmChatStrings.delete,
                                ),
                              ],
                            ),
                            child: ListTile(
                              dense: true,
                              onTap: () async {
                                final membersForNavigation = broadcast
                                        .metaData?.membersDetail
                                        ?.map((e) => UserDetails(
                                            userId: e.memberId ?? '',
                                            userName: e.memberName ?? '',
                                            userIdentifier: '',
                                            userProfileImageUrl: ''))
                                        .toList() ??
                                    [];
                                IsmChatUtility.conversationController
                                    .goToBroadcastMessage(membersForNavigation,
                                        broadcast.groupcastId ?? '');
                              },
                              leading: Container(
                                height: IsmChatDimens.fifty,
                                width: IsmChatDimens.fifty,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: IsmChatConfig.chatTheme.primaryColor
                                      ?.applyIsmOpacity(.1),
                                ),
                                child: const Icon(Icons.campaign_rounded),
                              ),
                              title: Text(
                                broadcast.groupcastTitle ==
                                        IsmChatStrings.defaultString
                                    ? '${IsmChatStrings.recipients} ${broadcast.membersCount ?? 0}'
                                        .toUpperCase()
                                    : broadcast.groupcastTitle ?? '',
                                maxLines: 1,
                                style: IsmChatStyles.w600Black14,
                              ),
                              subtitle: Text(
                                remainingCount > 0
                                    ? '${members.join(', ')} and $remainingCount more'
                                    : members.join(', '),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
      ),
    );
  }
}
