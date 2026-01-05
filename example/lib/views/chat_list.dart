import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/controllers/controllers.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  static const String route = AppRoutes.chatList;

  @override
  Widget build(BuildContext context) => GetBuilder<ChatListController>(
        initState: (state) {
          if (!Get.isRegistered<ChatListController>()) {
            ChatConversationBinding().dependencies();
          }
        },
        builder: (controller) {
          return Scaffold(
            body: IsmChatApp(
              context: context,
              // conversationParser: (conversation, data) {
              //   AppLog(conversation);
              //   AppLog.info('checkData $data');
              //   return true;
              // },
              chatTheme: IsmChatThemeData(
                chatListCardThemData: IsmChatListCardTheme(iconSize: 16),
                // cardBackgroundColor: const Color(0xFF292030),
                // backgroundColor: const Color(0xFF292030),
                chatPageHeaderTheme: IsmChatHeaderTheme(),
                primaryColor: AppColors.primaryColorLight,
                // chatPageHeaderTheme: IsmChatHeaderThemeData(
                //   iconColor: Colors.red,
                // ),
                chatPageTheme: IsmChatPageTheme(
                  centerMessageTheme:
                      const IsmChatCenterMessageTheme(textColor: Colors.white),
                  // backgroundColor: const Color(0xFF292030),
                  selfMessageTheme: IsmChatMessageTheme(
                      borderColor: Colors.grey, linkPreviewColor: Colors.white

                      // showProfile: ShowProfile(
                      //   isShowProfile: true,
                      //   isPostionBottom: false,
                      // ),
                      ),

                  opponentMessageTheme: IsmChatMessageTheme(
                    borderColor: AppColors.primaryColorLight,
                    linkPreviewColor: Colors.black,
                    // showProfile: ShowProfile(
                    //   isShowProfile: true,
                    //   isPostionBottom: false,
                    // ),
                  ),
                ),
              ),

              chatPageProperties: IsmChatPageProperties(
                // Configure the interval for periodic conversation details API calls
                // Default is 1 minute. You can customize it as needed:
                conversationDetailsApiInterval:
                    Duration(seconds: 10), // Every 30 seconds
                // backgroundImageUrl: AssetConstants.background,
                // isShowMessageBlur: (p0, p1) => true,
                // stackWidget: Container(
                //   alignment: Alignment.center,
                //   color: IsmChatColors.greenColor,
                //   child: const Text('Stack '),
                // ),
                // isShowMediaMeessageBlure: (p0, p1) => true,
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
                // onMessageTap: (p0, message, _) async {
                //   return (<String, dynamic>{}, false);
                // },
                attachments: const [
                  IsmChatAttachmentType.camera,
                  IsmChatAttachmentType.gallery,
                  IsmChatAttachmentType.document,
                  if (!kIsWeb) IsmChatAttachmentType.location,
                  if (!kIsWeb) IsmChatAttachmentType.contact,
                ],

                // features: [
                //   IsmChatFeature.reply,
                //   IsmChatFeature.showMessageStatus,
                //   IsmChatFeature.audioMessage,
                //   IsmChatFeature.emojiIcon,
                // ],
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
                shouldShowAppBar:
                    IsmChatResponsive.isWeb(context) ? false : true,
                header: Column(
                  children: [
                    IsmChatListHeader(
                      onSignOut: () {
                        controller.onSignOut();
                      },
                      onSearchTap: (p0, p1, p2) {},
                      showSearch: false,
                      width: IsmChatResponsive.isWeb(context)
                          ? IsmChatDimens.percentWidth(.3)
                          : null,
                    ),
                  ],
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
                  // Show online/last seen status based on lastActiveTimestamp
                  if (opponent?.isOnlineBasedOnLastActive ?? false) {
                    return IsmChatStrings.online;
                  } else {
                    final lastSeenTimestamp = opponent?.lastSeenTimestamp;
                    if (lastSeenTimestamp != null) {
                      return lastSeenTimestamp.toCurrentTimeStirng();
                    }
                  }

                  // Fallback to about text if no last seen info available
                  return opponent?.metaData?.aboutText?.title == null
                      ? 'Hey there! I am using IsoChat'
                      : opponent?.metaData?.aboutText?.title ?? '';
                },
              ),
            ),
          );
        },
      );
}
