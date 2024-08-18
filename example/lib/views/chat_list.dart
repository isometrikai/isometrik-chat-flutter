import 'package:chat_component_example/controllers/controllers.dart';
import 'package:chat_component_example/res/res.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  static const String route = AppRoutes.chatList;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChatListController>(
      builder: (controller) {
        return Scaffold(
          body: IsmChatApp(
            // conversationParser: (conversation, data) {
            //   AppLog(conversation);
            //   AppLog.info('checkData $data');
            //   return true;
            // },
            chatTheme: IsmChatThemeData(
              chatPageHeaderTheme: IsmChatHeaderThemeData(),
              primaryColor: AppColors.primaryColorLight,
              // chatPageHeaderTheme: IsmChatHeaderThemeData(
              //   iconColor: Colors.red,
              // ),
              chatPageTheme: IsmChatPageThemeData(
                selfMessageTheme: IsmChatMessageThemeData(
                  borderColor: Colors.grey,
                  // showProfile: ShowProfile(
                  //   isShowProfile: true,
                  //   isPostionBottom: false,
                  // ),
                ),
                opponentMessageTheme: IsmChatMessageThemeData(
                  borderColor: AppColors.primaryColorLight,
                  // showProfile: ShowProfile(
                  //   isShowProfile: true,
                  //   isPostionBottom: false,
                  // ),
                ),
              ),
            ),

            chatPageProperties: IsmChatPageProperties(
              // isAllowedDeleteChatFromLocal: true,
              // onCoverstaionStatus: (p0, conversation) {
              //   IsmChatLog.error(conversation.usersOwnDetails?.isDeleted);
              // },
              // onCallBlockUnblock: (p0, p1, p2) async {
              //   IsmChatLog.error(p2);
              //   return true;
              // },

              header: IsmChatPageHeaderProperties(

                  // height: (p0, p1) => 200,
                  // bottom: (p0, p1) {
                  //   return Container(
                  //       alignment: Alignment.center,
                  //       width: double.infinity,
                  //       child: const Text('Rahul Saryam'));
                  // },
                  ),
              // meessageFieldFocusNode: (_, coverstaion, value) {
              //   IsmChatLog.info(value);
              //   controller.isBottomVisibile = !controller.isBottomVisibile;
              //   controller.update();
              // },
              placeholder: IsmChatEmptyView(
                icon: Icon(
                  Icons.chat_outlined,
                  size: IsmChatDimens.fifty,
                  color: IsmChatColors.greyColor,
                ),
                text: 'No Messages',
              ),
              onMessageTap: (p0, p1, p2) {},

              attachments: const [
                IsmChatAttachmentType.camera,
                IsmChatAttachmentType.gallery,
                IsmChatAttachmentType.document,
                if (!kIsWeb) IsmChatAttachmentType.location,
                if (!kIsWeb) IsmChatAttachmentType.contact,
              ],

              // features: [
              //   IsmChatFeature.reply,
              // ]
            ),
            noChatSelectedPlaceholder: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    IsmChatAssets.placeHolderSvg,
                  ),
                  Text(
                    'Isometrik Chat',
                    style: IsmChatStyles.w600Black27,
                  ),
                  SizedBox(
                    width: IsmChatDimens.percentWidth(.5),
                    child: Text(
                      'Isometrik web chat is fully sync with mobile isomterik chat , all charts are synced when connected to the network',
                      style: IsmChatStyles.w400Black12,
                      textAlign: TextAlign.center,
                    ),
                  )
                ],
              ),
            ),
            conversationProperties: IsmChatConversationProperties(
              conversationPosition: IsmChatConversationPosition.menu,
              allowedConversations: [
                IsmChatConversationType.private,
                IsmChatConversationType.public,
                IsmChatConversationType.open,
              ],
              showCreateChatIcon: true,
              enableGroupChat: true,
              allowDelete: true,
              onCreateTap: () {},

              isHeaderAppBar: IsmChatResponsive.isWeb(context) ? false : true,
              header: IsmChatListHeader(
                onSignOut: () {
                  controller.onSignOut();
                },
                onSearchTap: (p0, p1, p2) {},
                showSearch: false,
                width: IsmChatResponsive.isWeb(context)
                    ? IsmChatDimens.percentWidth(.3)
                    : null,
              ),
              placeholder: const IsmChatEmptyView(
                text: 'Create conversation',
                icon: Icon(
                  Icons.add_circle_outline_outlined,
                  size: 70,
                  color: AppColors.primaryColorLight,
                ),
              ),
              isSlidableEnable: (_, conversation) {
                return true;
              },
              // cardElementBuilders: const IsmChatCardProperties(
              // onProfileTap: (p0, p1) {
              //   IsmChatLog.error('Yes i am tap');
              // },
              // )

              // endActionSlidableEnable: (p0, p1) => true,
              // startActionSlidableEnable: (p0, p1) => true,
              // conversationPredicate: (e) =>
              //     e.chatName.toLowerCase().startsWith('t'),

              opponentSubTitle: (_, opponent) {
                return opponent.metaData?.aboutText?.title == null
                    ? 'Hey there! I am using IsoChat'
                    : opponent.metaData?.aboutText?.title ?? '';
              },
            ),
          ),
        );
      },
    );
  }
}
