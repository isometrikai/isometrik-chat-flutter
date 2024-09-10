import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

// / The view part of the [IsmChatPageView], which will be used to
/// show the Message Information view page
class IsmChatMessageInfo extends StatelessWidget {
  IsmChatMessageInfo({super.key, IsmChatMessageModel? message, bool? isGroup})
      : _isGroup = isGroup ??
            (Get.arguments as Map<String, dynamic>?)?['isGroup'] ??
            false,
        _message =
            message ?? (Get.arguments as Map<String, dynamic>?)?['message'];

  final IsmChatMessageModel? _message;
  final bool? _isGroup;

  static const String route = IsmPageRoutes.messageInfoView;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (chatController) => Scaffold(
          backgroundColor: IsmChatColors.whiteColor,
          appBar: AppBar(
            systemOverlayStyle: IsmChatConfig
                    .chatTheme.chatPageHeaderTheme?.systemUiOverlayStyle ??
                SystemUiOverlayStyle(
                  statusBarBrightness: Brightness.dark,
                  statusBarIconBrightness: Brightness.light,
                  statusBarColor: IsmChatConfig.chatTheme.primaryColor ??
                      IsmChatColors.primaryColorLight,
                ),
            elevation: 0,
            leading: IconButton(
              onPressed: IsmChatResponsive.isWeb(context)
                  ? () {
                      Get.find<IsmChatConversationsController>()
                              .isRenderChatPageaScreen =
                          IsRenderChatPageScreen.none;
                    }
                  : Get.back,
              icon: Icon(
                IsmChatResponsive.isWeb(context)
                    ? Icons.close_rounded
                    : Icons.arrow_back_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
              ),
            ),
            backgroundColor:
                IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor ??
                    IsmChatConfig.chatTheme.primaryColor,
            titleSpacing: 1,
            title: Text(IsmChatStrings.messageInfo,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Container(
              margin: IsmChatDimens.edgeInsets16,
              height: Get.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: IsmChatConfig.chatTheme.backgroundColor,
                        borderRadius:
                            BorderRadius.circular(IsmChatDimens.eight),
                      ),
                      padding: IsmChatDimens.edgeInsets8_4,
                      child: Text(
                        _message?.sentAt.toMessageDateString() ?? '',
                        style: IsmChatStyles.w500Black12.copyWith(
                          color: IsmChatConfig.chatTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  IsmChatDimens.boxHeight16,
                  UnconstrainedBox(
                    alignment: _message?.sentByMe ?? false
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: _message?.sentByMe ?? false
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        MessageBubble(
                          message: _message,
                          showMessageInCenter: false,
                        )
                      ],
                    ),
                  ),
                  IsmChatDimens.boxHeight16,
                  _isGroup ?? false
                      ? Obx(
                          () => Column(
                            children: [
                              if (chatController
                                  .deliverdMessageMembers.isNotEmpty) ...[
                                _UserInfo(
                                  userList:
                                      chatController.deliverdMessageMembers,
                                  title: IsmChatStrings.deliveredTo,
                                ),
                              ] else ...[
                                const _MessageReadDelivered(
                                  title: IsmChatStrings.deliveredTo,
                                )
                              ],
                              IsmChatDimens.boxHeight10,
                              if (chatController
                                  .readMessageMembers.isNotEmpty) ...[
                                _UserInfo(
                                  userList: chatController.readMessageMembers,
                                  title: IsmChatStrings.readby,
                                  isRead: true,
                                ),
                              ] else ...[
                                const _MessageReadDelivered(
                                  title: IsmChatStrings.readby,
                                )
                              ],
                            ],
                          ),
                        )
                      : Obx(
                          () => Card(
                            elevation: 1,
                            child: Padding(
                              padding: IsmChatDimens.edgeInsets10,
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.done_all,
                                            color: Colors.grey,
                                            size: IsmChatDimens.twenty,
                                          ),
                                          IsmChatDimens.boxWidth8,
                                          Text(
                                            'Delivered',
                                            style: IsmChatStyles.w400Black12,
                                          ),
                                        ],
                                      ),
                                      chatController
                                              .deliverdMessageMembers.isEmpty
                                          ? Icon(
                                              Icons.remove,
                                              size: IsmChatDimens.twenty,
                                            )
                                          : Text(
                                              chatController
                                                  .deliverdMessageMembers
                                                  .first
                                                  .timestamp!
                                                  .deliverTime,
                                              style: IsmChatStyles.w400Black12,
                                            )
                                    ],
                                  ),
                                  IsmChatDimens.boxHeight8,
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.grey,
                                  ),
                                  IsmChatDimens.boxHeight8,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.done_all,
                                            color: Colors.blue,
                                            size: IsmChatDimens.twenty,
                                          ),
                                          IsmChatDimens.boxWidth14,
                                          Text('Read',
                                              style: IsmChatStyles.w400Black12)
                                        ],
                                      ),
                                      chatController.readMessageMembers.isEmpty
                                          ? Icon(
                                              Icons.remove,
                                              size: IsmChatDimens.twenty,
                                            )
                                          : Text(
                                              chatController.readMessageMembers
                                                  .first.timestamp!.deliverTime,
                                              style: IsmChatStyles.w400Black12,
                                            ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ).withUnfocusGestureDetctor(context),
      );
}

class _MessageReadDelivered extends StatelessWidget {
  const _MessageReadDelivered({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 1,
        child: Container(
          width: IsmChatDimens.percentWidth(.9),
          padding: IsmChatDimens.edgeInsets16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: IsmChatStyles.w600Black16,
              ),
              IsmChatDimens.boxHeight5,
              Text(
                '...',
                style: IsmChatStyles.w600Black16,
              )
            ],
          ),
        ),
      );
}

class _UserInfo extends StatelessWidget {
  const _UserInfo(
      {required this.userList, required this.title, this.isRead = false});

  final List<UserDetails> userList;
  final String title;
  final bool isRead;

  @override
  Widget build(BuildContext context) => Card(
        elevation: 1,
        child: Padding(
          padding: IsmChatDimens.edgeInsets10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: IsmChatStyles.w600Black16,
                  ),
                  Icon(
                    Icons.done_all_rounded,
                    size: IsmChatDimens.fifteen,
                    color: isRead
                        ? IsmChatConfig
                                .chatTheme.chatPageTheme?.readCheckColor ??
                            Colors.blue
                        : IsmChatConfig
                                .chatTheme.chatPageTheme?.unreadCheckColor ??
                            Colors.grey,
                  ),
                ],
              ),
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (_, inex) {
                  var user = userList[inex];

                  return ListTile(
                    contentPadding: IsmChatDimens.edgeInsets0,
                    leading: IsmChatProperties.chatPageProperties
                            .messageInfoAcknowldge?.profileImageBuilder
                            ?.call(_, user) ??
                        IsmChatImage.profile(
                          IsmChatProperties.chatPageProperties
                                  .messageInfoAcknowldge?.profileImageUrl
                                  ?.call(_, user) ??
                              user.profileUrl,
                          name: user.userName,
                          dimensions: IsmChatDimens.forty,
                        ),
                    title: IsmChatProperties.chatPageProperties
                            .messageInfoAcknowldge?.titleBuilder
                            ?.call(_, user) ??
                        Text(IsmChatProperties
                                .chatPageProperties.messageInfoAcknowldge?.title
                                ?.call(_, user) ??
                            user.userName),
                    trailing: IsmChatProperties.chatPageProperties
                            .messageInfoAcknowldge?.trailingBuilder
                            ?.call(_, user) ??
                        Text(IsmChatProperties.chatPageProperties
                                .messageInfoAcknowldge?.trailing
                                ?.call(_, user) ??
                            (user.timestamp ?? 0).deliverTime),
                  );
                },
                separatorBuilder: (_, index) => const Divider(),
                itemCount: userList.length,
              )
            ],
          ),
        ),
      );
}
