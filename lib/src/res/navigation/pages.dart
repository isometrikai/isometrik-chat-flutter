import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/controllers/controllers.dart';
import 'package:isometrik_chat_flutter/src/views/views.dart';

class IsmChatPages {
  static final pages = [
    GetPage(
      name: IsmChatConversations.route,
      page: IsmChatConversations.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatCreateConversationView.route,
      page: IsmChatCreateConversationView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatPublicConversationView.route,
      page: IsmChatPublicConversationView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatOpenConversationView.route,
      page: IsmChatOpenConversationView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatForwardView.route,
      page: IsmChatForwardView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatBlockedUsersView.route,
      page: IsmChatBlockedUsersView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatObserverUsersView.route,
      page: IsmChatObserverUsersView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatCreateBroadCastView.route,
      page: IsmChatCreateBroadCastView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatMessageSearchView.route,
      page: IsmChatMessageSearchView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatConversationSearchView.route,
      page: IsmChatConversationSearchView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatGlobalSearchView.route,
      page: IsmChatGlobalSearchView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatBroadCastView.route,
      page: IsmChatBroadCastView.new,
      binding: IsmChatBroadcastBinding(),
    ),
    GetPage(
      name: IsmChatEditBroadcastView.route,
      page: IsmChatEditBroadcastView.new,
      binding: IsmChatBroadcastBinding(),
    ),
    GetPage(
      name: IsmChatEligibleMembersView.route,
      page: IsmChatEligibleMembersView.new,
      binding: IsmChatBroadcastBinding(),
    ),
    GetPage(
      name: IsmChatUserSearchView.route,
      page: IsmChatUserSearchView.new,
      binding: IsmChatConversationsBinding(),
    ),
    GetPage(
      name: IsmChatPageView.route,
      page: IsmChatPageView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatConverstaionInfoView.route,
      page: IsmChatConverstaionInfoView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatGroupEligibleUser.route,
      page: IsmChatGroupEligibleUser.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmMediaPreview.route,
      page: IsmMediaPreview.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatMessageInfo.route,
      page: IsmChatMessageInfo.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatUserInfo.route,
      page: IsmChatUserInfo.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatWallpaperPreview.route,
      page: IsmChatWallpaperPreview.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmMedia.route,
      page: IsmMedia.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatLocationWidget.route,
      page: IsmChatLocationWidget.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmWebMessageMediaPreview.route,
      page: IsmWebMessageMediaPreview.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: WebMediaPreview.route,
      page: WebMediaPreview.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatCameraView.route,
      page: IsmChatCameraView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatContactView.route,
      page: IsmChatContactView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatContactsInfoView.route,
      page: IsmChatContactsInfoView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatSearchMessgae.route,
      page: IsmChatSearchMessgae.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatBoradcastMessagePage.route,
      page: IsmChatBoradcastMessagePage.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatOpenChatMessagePage.route,
      page: IsmChatOpenChatMessagePage.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatImageEditView.route,
      page: IsmChatImageEditView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatGalleryAssetsView.route,
      page: IsmChatGalleryAssetsView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatProfilePicView.route,
      page: IsmChatProfilePicView.new,
      binding: IsmChatPageBinding(),
    ),
    GetPage(
      name: IsmChatVideoView.route,
      page: IsmChatVideoView.new,
      binding: IsmChatPageBinding(),
    ),
  ];
}
