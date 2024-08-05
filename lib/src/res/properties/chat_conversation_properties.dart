import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

/// A class that holds properties for the conversation UI.
///
/// Use this class to customize the conversation UI, such as setting callbacks,
/// customizing the appearance of chat items, and more.
class IsmChatConversationProperties {
  /// Creates a new instance of [IsmChatConversationProperties].
  ///
  /// You can customize the conversation UI by passing various parameters to this constructor.
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

  /// A callback that is called when a chat item is tapped.
  ///
  /// This callback takes two parameters: the [BuildContext] and the [IsmChatConversationModel] of the tapped chat item.
  ///
  /// Example:
  /// ```dart
  /// onChatTap: (context, conversation) {},
  /// ```
  final ConversationVoidCallback? onChatTap;

  /// A callback that is called when the create chat button is tapped.
  ///
  /// This callback should navigate to the create chat screen.
  ///
  /// Example:
  /// ```dart
  /// onCreateTap: () {},
  /// ```
  final VoidCallback? onCreateTap;

  /// A callback that is used to build each chat item.
  ///
  /// This callback takes three parameters: the [BuildContext], the index of the chat item, and the [IsmChatConversationModel] of the chat item.
  ///
  /// Example:
  /// ```dart
  /// cardBuilder: (context, index, conversation) {
  ///   return ListTile(
  ///     title: Text(conversation.name),
  ///     subtitle: Text(conversation.message),
  ///   );
  /// },
  /// ```
  final ConversationCardCallback? cardBuilder;

  /// A set of properties that can be used to customize the appearance of chat items.
  ///
  /// Example:
  /// ```dart
  /// cardElementBuilders: IsmChatCardProperties(
  ///   titleStyle: TextStyle(fontSize: 18),
  ///   subtitleStyle: TextStyle(fontSize: 14),
  /// ),
  /// ```
  final IsmChatCardProperties? cardElementBuilders;

  /// Whether to enable group chat.
  ///
  /// Defaults to `false`.
  final bool enableGroupChat;

  /// Whether to show the create chat button.
  ///
  /// Defaults to `false`.
  final bool showCreateChatIcon;

  /// The icon to use for the create chat button.
  final Widget? createChatIcon;

  /// Whether to allow deleting chat items.
  ///
  /// Defaults to `false`.
  final bool allowDelete;

  /// A list of actions that can be performed on each chat item.
  final List<IsmChatConversationAction>? actions;

// A list of actions that can be performed on each chat item, displayed at the end of the item.
  final List<IsmChatConversationAction>? endActions;

  /// A placeholder widget to display when there are no chat items.
  final Widget? placeholder;

  /// A callback that determines whether a chat item can be slid.
  ///
  /// This callback takes two parameters: the [BuildContext] and the [IsmChatConversationModel] of the chat item.
  ///
  /// Returns `true` if the chat item can be slid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// isSlidableEnable: (context, conversation) {
  ///   return conversation.type == IsmChatConversationType.private;
  /// },
  /// ```
  final bool? Function(BuildContext, IsmChatConversationModel)?
      isSlidableEnable;

  /// A callback that determines whether the start action of a chat item can be slid.
  ///
  /// This callback takes two parameters: the [BuildContext] and the [IsmChatConversationModel] of the chat item.
  ///
  /// Returns `true` if the start action can be slid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// startActionSlidableEnable: (context, conversation) {
  ///   return conversation.type == IsmChatConversationType.private;
  /// },
  /// ```
  final bool? Function(BuildContext, IsmChatConversationModel)?
      startActionSlidableEnable;

  /// A callback that determines whether the end action of a chat item can be slid.
  ///
  /// This callback takes two parameters: the [BuildContext] and the [IsmChatConversationModel] of the chat item.
  ///
  /// Returns `true` if the end action can be slid, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// endActionSlidableEnable: (context, conversation) {
  ///   return conversation.type == IsmChatConversationType.private;
  /// },
  /// ```
  final bool? Function(BuildContext, IsmChatConversationModel)?
      endActionSlidableEnable;

  /// Provide this height parameter to set the maximum height for conversation list
  ///
  /// If not provided, Screen height will be taken
  final double? height;

  /// The header to display above the conversation UI.
  final Widget? header;

  /// The app bar to display above the conversation UI.
  final PreferredSizeWidget? appBar;

  /// Whether the header is an app bar.
  ///
  /// Defaults to `false`.
  final bool isHeaderAppBar;

  /// The height of the header.
  final double? headerHeight;

  /// Provide this allowedConversations parameter, to allow different types of conversations.
  ///
  /// It cannot be empty and  `IsmChatConversationType.private` must be passed in the list
  ///
  /// Furthermore, the position of types to show in the UI can be set by using [conversationPosition]
  final List<IsmChatConversationType> allowedConversations;

  /// Provide this conversationPosition parameter to set postion of allowedConversations list in your app
  final IsmChatConversationPosition conversationPosition;

  /// A widget to display in the third column of the conversation UI.
  final WidgetCallback? thirdColumnWidget;

  /// A predicate that filters the conversations to display.
  ///
  /// This callback takes a [IsmChatConversationModel] and returns `true` if the conversation should be displayed, `false` otherwise.
  ///
  /// Example:
  /// ```dart
  /// conversationPredicate: (conversation) {
  ///   return conversation.type == IsmChatConversationType.private;
  /// },
  /// ```
  final ConversationPredicate? conversationPredicate;

  /// A callback that returns the subtitle to display for the opponent in a conversation.
  ///
  /// This callback takes a [IsmChatConversationModel] and returns a string.
  ///
  /// Example:
  /// ```dart
  /// opponentSubTitle: (conversation) {
  ///   return conversation.opponent.name;
  /// },
  /// ```
  final UserDetailsStringCallback? opponentSubTitle;
}
