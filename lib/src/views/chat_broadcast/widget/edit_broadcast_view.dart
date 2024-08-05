import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class IsmChatEditBroadcastView extends StatelessWidget {
  IsmChatEditBroadcastView({super.key});

  static const String route = IsmPageRoutes.editBroadcastView;

  final broadcast = Get.arguments as BroadcastModel;

  @override
  Widget build(BuildContext context) => GetX<IsmChatBroadcastController>(
        initState: (state) {
          IsmChatUtility.doLater(() async {
            final controller = Get.find<IsmChatBroadcastController>();
            controller.broadcast = broadcast;
            if (IsmChatStrings.defaultString != broadcast.groupcastTitle) {
              controller.broadcastName.text = broadcast.groupcastTitle ?? '';
            } else {
              controller.broadcastName.clear();
            }
            controller.broadcastMembers = null;
            await controller.getBroadcastMembers(
              groupcastId: broadcast.groupcastId ?? '',
            );
          });
        },
        builder: (controller) => Scaffold(
          appBar: IsmChatAppBar(
            title: Text(
              IsmChatStrings.broadcastinfo,
              style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                  IsmChatStyles.w600White18,
            ),
            action: [
              TextButton(
                  onPressed: () {
                    controller.updateBroadcast(
                      groupcastId: broadcast.groupcastId ?? '',
                      groupcastTitle: controller.broadcastName.text,
                      isloading: true,
                      shouldCallBack: true,
                    );
                  },
                  child: Text(
                    IsmChatStrings.save,
                    style: (IsmChatConfig
                                .chatTheme.chatPageHeaderTheme?.titleStyle ??
                            IsmChatStyles.w400White16)
                        .copyWith(
                      fontSize: IsmChatDimens.sixteen,
                      fontWeight: FontWeight.w400,
                    ),
                  ))
            ],
          ),
          bottomSheet: GestureDetector(
            onTap: () {
              IsmChatRouteManagement.goToEligibleMembersView(
                broadcast.groupcastId ?? '',
              );
            },
            child: Container(
              margin: IsmChatDimens.edgeInsets20_10,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                color: IsmChatConfig.chatTheme.primaryColor,
              ),
              height: IsmChatDimens.fifty,
              child: Text(
                IsmChatStrings.addrecipient,
                style: IsmChatStyles.w600White16,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: IsmChatDimens.edgeInsets10_20_10_0,
                child: IsmChatInputField(
                  autofocus: false,
                  controller: controller.broadcastName,
                  padding: IsmChatDimens.edgeInsets0,
                  style: IsmChatStyles.w400White16,
                  maxLines: 1,
                  hint: 'Add broadcast name here...',
                  hintStyle: IsmChatStyles.w400White16,
                  textInputAction: TextInputAction.done,
                  onChanged: (value) {},
                  cursorColor: Colors.transparent,
                  fillColor: IsmChatConfig.chatTheme.primaryColor,
                ),
              ),
              IsmChatDimens.boxHeight20,
              if (controller.broadcastMembers == null) ...[
                const Spacer(),
                const IsmChatLoadingDialog(),
                const Spacer()
              ] else ...[
                Padding(
                  padding: IsmChatDimens.edgeInsets10_20_10_0,
                  child: Text(
                    '${IsmChatStrings.recipients} ${controller.broadcastMembers?.membersCount ?? ''}'
                        .toUpperCase(),
                    style: IsmChatStyles.w600Black12,
                  ),
                ),
                IsmChatDimens.boxHeight20,
                Expanded(
                  child: SlidableAutoCloseBehavior(
                    child: ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount:
                          controller.broadcastMembers?.members.length ?? 0,
                      itemBuilder: (_, index) {
                        final data =
                            controller.broadcastMembers?.members[index];
                        return Slidable(
                            direction: Axis.horizontal,
                            closeOnScroll: true,
                            enabled: true,
                            endActionPane: ActionPane(
                              extentRatio: 0.3,
                              motion: const StretchMotion(),
                              children: [
                                SlidableAction(
                                  onPressed: (_) async {
                                    await controller.deleteBroadcastMember(
                                        isloading: true,
                                        broadcast: broadcast,
                                        members: [data?.memberId ?? '']);
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
                              leading: IsmChatImage.profile(
                                  data?.memberInfo?.profileUrl ?? ''),
                              title: Text(
                                data?.memberInfo?.userName ?? '',
                                style: IsmChatStyles.w600Black16,
                              ),
                              subtitle: Text(
                                data?.memberInfo?.userIdentifier ?? '',
                              ),
                            ));
                      },
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      );
}
