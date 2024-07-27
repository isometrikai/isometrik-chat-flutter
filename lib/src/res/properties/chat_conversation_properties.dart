import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationProperties {
  IsmChatConversationProperties({
    this.onChatTap,
    this.onCreateTap,
    this.cardBuilder,
    this.cardElementBuilders,
    this.showCreateChatIcon = false,
    this.createChatIcon,
    this.enableGroupChat = false,
    this.allowDelete = false,
    this.actions,
    this.endActions,
    this.isSlidableEnable,
    this.startActionSlidableEnable,
    this.endActionSlidableEnable,
    this.placeholder,
    this.height,
    this.appBar,
    this.header,
    this.isHeaderAppBar = false,
    this.headerHeight,
    this.thirdColumnWidget,
    this.conversationPredicate,
    this.allowedConversations = const [IsmChatConversationType.private],
    this.conversationPosition = IsmChatConversationPosition.tabBar,
    this.opponentSubTitle,
  }) {
    assert(
      (showCreateChatIcon && onCreateTap != null) || !showCreateChatIcon,
      'If showCreateChatIcon is set to true then a non null callback must be passed to onCreateChatTap parameter',
    );
    assert(!isHeaderAppBar || (isHeaderAppBar && header != null),
        'If isHeaderAppBar is set to true then a widget must be passed to header parameter');
    assert(
        allowedConversations.isNotEmpty &&
            allowedConversations.contains(IsmChatConversationType.private),
        'allowedConversations must not be empty and must contain IsmChatConversationType.private');
  }

  /// Required parameter
  ///
  /// Primarily designed for nagivating to Message screen
  ///
  /// `onChatTap` takes a non-null callback function that takes 2 arguments in its parameter list
  ///
  /// ```dart
  /// void Function(BuildContext, IsmChatConversationModel) onChatTap;
  /// ```
  ///
  /// `IsmChatConversationModel` gives data of current chat, it could be used for local storage or state variables
  final ConversationVoidCallback? onChatTap;

  /// A callback for `navigating` to the create chat screen
  ///
  /// A non-null callback should be passed, if showCreateChatIcon is set to `true`
  final VoidCallback? onCreateTap;

  /// `itemBuilder` will handle how child items are rendered on the screen.
  ///
  /// You can pass `childBuilder` callback to change the UI for each child item.
  ///
  /// It takes 3 parameters
  /// ```dart
  /// final BuildContext context;
  /// final int index;
  /// final ChatConversationModel conversation;
  /// ```
  /// `conversation` of type [IsmChatConversationModel] will provide you with data of single chat item
  ///
  /// You can playaround with index parameter for your logics.
  final ConversationCardCallback? cardBuilder;

  /// The `cardBuilder` callback can be provided if you want to change how the chat items are rendered on the screen.
  ///
  /// Provide it like you are passing cardBuilder for `ListView` or any constructor of [ListView]
  ///
  final IsmChatCardProperties? cardElementBuilders;
  final bool enableGroupChat;

  /// This signifies whether or not to show [FloatingActionButton] that will navigate to the create chat screen
  ///
  /// Defaults to `false`
  ///
  /// If set to `true`, then onCreateChatTap callback must be passed to `navigate` to the screen
  final bool showCreateChatIcon;
  final Widget? createChatIcon;
  final bool allowDelete;
  final List<IsmChatConversationAction>? actions;
  final List<IsmChatConversationAction>? endActions;
  final Widget? placeholder;
  final bool? Function(BuildContext, IsmChatConversationModel)?
      isSlidableEnable;
  final bool? Function(BuildContext, IsmChatConversationModel)?
      startActionSlidableEnable;
  final bool? Function(BuildContext, IsmChatConversationModel)?
      endActionSlidableEnable;

  /// Provide this height parameter to set the maximum height for conversation list
  ///
  /// If not provided, Screen height will be taken
  final double? height;

  /// This widget will be visible above the conversation list inside the conversation view
  final Widget? header;

  final PreferredSizeWidget? appBar;

  final bool isHeaderAppBar;

  /// This height will be use for when you use header on AppBar of coversation list
  final double? headerHeight;

  /// Provide this allowedConversations parameter, to allow different types of conversations.
  ///
  /// It cannot be empty and  `IsmChatConversationType.private` must be passed in the list
  ///
  /// Furthermore, the position of types to show in the UI can be set by using [conversationPosition]
  final List<IsmChatConversationType> allowedConversations;

  /// Provide this conversationPosition parameter to set postion of allowedConversations list in your app
  final IsmChatConversationPosition conversationPosition;

  final WidgetCallback? thirdColumnWidget;

  final ConversationPredicate? conversationPredicate;

  final UserDetailsStringCallback? opponentSubTitle;
}
