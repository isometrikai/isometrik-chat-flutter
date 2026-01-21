part of '../chat_conversations_controller.dart';

/// Navigation mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to navigation including navigating
/// to chat pages and broadcast message pages.
mixin IsmChatConversationsNavigationMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Navigates to the chat page based on the platform (web or mobile).
  Future<void> goToChatPage() async {
    if (IsmChatResponsive.isWeb(
      IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context,
    )) {
      if (!IsmChatUtility.chatPageControllerRegistered) {
        IsmChatPageBinding().dependencies();
        return;
      }
      _controller.isRenderChatPageaScreen = IsRenderChatPageScreen.none;
      final chatPagecontroller = IsmChatUtility.chatPageController
        ..closeOverlay();
      if (chatPagecontroller.showEmojiBoard) {
        chatPagecontroller.toggleEmojiBoard(false, false);
      }
      // Defer initialization to allow UI to render first
      unawaited(Future.microtask(chatPagecontroller.startInit));
    } else {
      await IsmChatRoute.goToRoute(IsmChatPageView(
        viewTag: IsmChat.i.chatPageTag,
      ));
    }
  }

  /// Navigates to the broadcast message page with specified members.
  ///
  /// `members`: List of members to include in the broadcast.
  /// `conversationId`: The ID of the conversation for the broadcast.
  void goToBroadcastMessage(List<UserDetails> members, String conversationId) {
    final conversation = IsmChatConversationModel(
      members: members,
      conversationImageUrl: IsmChatAssets.noImage,
      customType: IsmChatStrings.broadcast,
      conversationId: conversationId,
    );

    _controller.updateLocalConversation(conversation);
    if (IsmChatResponsive.isWeb(
        IsmChatConfig.kNavigatorKey.currentContext ?? IsmChatConfig.context)) {
      IsmChatRoute.goBack();
      if (!IsmChatUtility.chatPageControllerRegistered) {
        IsmChatPageBinding().dependencies();
      }
      _controller.isRenderChatPageaScreen = IsRenderChatPageScreen.boradcastChatMessagePage;
      final chatPagecontroller = IsmChatUtility.chatPageController
        ..closeOverlay();
      // Defer initialization to allow UI to render first
      Future.microtask(() => chatPagecontroller.startInit(isBroadcasts: true));
    } else {
      if (!IsmChatUtility.chatPageControllerRegistered) {
        IsmChatPageBinding().dependencies();
      }
      IsmChatUtility.chatPageController.isBroadcast = true;
      IsmChatRoute.goToRoute(const IsmChatBoradcastMessagePage());
    }
  }
}

