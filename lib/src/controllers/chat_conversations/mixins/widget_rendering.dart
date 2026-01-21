part of '../chat_conversations_controller.dart';

/// Widget rendering mixin for IsmChatConversationsController.
///
/// This mixin contains methods that return widgets based on the current
/// render screen state for conversations and chat pages.
mixin IsmChatConversationsWidgetRenderingMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Returns the appropriate widget based on the current render screen state.
  Widget isRenderScreenWidget() {
    switch (_controller.isRenderScreen) {
      case IsRenderConversationScreen.none:
        return const SizedBox.shrink();
      case IsRenderConversationScreen.blockView:
        return const IsmChatBlockedUsersView();
      case IsRenderConversationScreen.broadCastListView:
        IsmChatBroadcastBinding().dependencies();
        return const IsmChatBroadCastView();
      case IsRenderConversationScreen.groupUserView:
        return IsmChatCreateConversationView(
          isGroupConversation: true,
          conversationType: IsmChatConversationType.private,
        );
      case IsRenderConversationScreen.createConverstaionView:
        return IsmChatCreateConversationView(
          isGroupConversation: false,
          conversationType: IsmChatConversationType.private,
        );
      case IsRenderConversationScreen.userView:
        return IsmChatUserView();
      case IsRenderConversationScreen.broadcastView:
        return const IsmChatCreateBroadCastView();
      case IsRenderConversationScreen.openConverationView:
        return const IsmChatOpenConversationView();
      case IsRenderConversationScreen.publicConverationView:
        return const IsmChatPublicConversationView();
      // case IsRenderConversationScreen.editbroadCast:
      //   return IsmChatEditBroadcastView();
    }
  }

  /// Returns the appropriate widget based on the current chat page screen state.
  Widget isRenderChatScreenWidget() {
    switch (_controller.isRenderChatPageaScreen) {
      case IsRenderChatPageScreen.coversationInfoView:
        return IsmChatConverstaionInfoView();
      case IsRenderChatPageScreen.wallpaperView:
        break;
      case IsRenderChatPageScreen.messgaeInfoView:
        return IsmChatMessageInfo(
          isGroup: _controller.currentConversation?.isGroup ?? false,
          message: _controller.message!,
        );
      case IsRenderChatPageScreen.groupEligibleView:
        return const IsmChatGroupEligibleUser();
      case IsRenderChatPageScreen.none:
        return const SizedBox.shrink();
      case IsRenderChatPageScreen.coversationMediaView:
        return IsmMedia(
          mediaList: _controller.mediaList,
          mediaListDocs: _controller.mediaListDocs,
          mediaListLinks: _controller.mediaListLinks,
        );
      case IsRenderChatPageScreen.userInfoView:
        return IsmChatUserInfo(
          user: _controller.contactDetails,
          conversationId: _controller.userConversationId ?? '',
          fromMessagePage: true,
        );
      case IsRenderChatPageScreen.messageSearchView:
        return const IsmChatSearchMessgae();
      case IsRenderChatPageScreen.boradcastChatMessagePage:
        return const IsmChatBoradcastMessagePage();

      case IsRenderChatPageScreen.openChatMessagePage:
        return const IsmChatOpenChatMessagePage();
      case IsRenderChatPageScreen.observerUsersView:
        return IsmChatObserverUsersView(
          conversationId: _controller.currentConversation?.conversationId ?? '',
        );
      case IsRenderChatPageScreen.outSideView:
        return IsmChatProperties.conversationProperties.thirdColumnWidget?.call(
              IsmChatConfig.kNavigatorKey.currentContext ??
                  IsmChatConfig.context,
              _controller.currentConversation!,
            ) ??
            const SizedBox.shrink();
    }
    return const SizedBox.shrink();
  }
}

