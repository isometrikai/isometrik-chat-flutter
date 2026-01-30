/// Model-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on SDK model classes like IsmChatConversationModel,
/// IsmChatMessageModel, LastMessageDetails, etc. for common model operations.
library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for IsmChatConversationModel to check block status.
extension BlockStatus on IsmChatConversationModel {
  /// Returns true if chatting is allowed (messaging is not disabled).
  bool get isChattingAllowed => !(messagingDisabled ?? false);

  /// Returns true if the conversation is blocked by the current user.
  bool get isBlockedByMe {
    if (isChattingAllowed) {
      return false;
    }
    var controller = IsmChatUtility.conversationController;
    var blockedList = controller.blockUsers.map((e) => e.userId);
    return blockedList.contains(opponentDetails?.userId);
  }
}

/// Extension for IsmChatConversationModel to get typing users and message status.
extension ModelConversion on IsmChatConversationModel {
  /// Gets the MQTT controller instance.
  IsmChatMqttController get _mqttController =>
      Get.find<IsmChatMqttController>();

  /// Returns a formatted string of typing users.
  String get typingUsers {
    var users = _mqttController.typingUsers
        .where(
          (u) => u.conversationId == conversationId,
        )
        .toList()
        .unique()
      ..sort(
        (a, b) => a.userName.toLowerCase().compareTo(b.userName.toLowerCase()),
      );

    return isGroup == true
        ? '${users.map((e) => e.userName).join(', ')} is ${IsmChatStrings.typing}'
        : IsmChatStrings.typing;
  }

  /// Returns true if someone is typing in this conversation.
  bool get isSomeoneTyping => _mqttController.typingUsers
      .map((e) => e.conversationId)
      .contains(conversationId);

  /// Returns a widget showing the sender name for group messages.
  Widget get sender {
    if (!(isGroup ?? false) ||
        lastMessageDetails!.messageBody.isEmpty ||
        [IsmChatCustomMessageType.memberLeave]
            .contains(lastMessageDetails?.customType)) {
      return const SizedBox.shrink();
    }

    var senderName = lastMessageDetails?.sentByMe == true
        ? 'You'
        : lastMessageDetails?.senderName;

    return Text(
      '$senderName: ',
      style: IsmChatStyles.w500Black12,
    );
  }

  /// Returns a widget showing the read/delivered status icon.
  Widget get readCheck {
    try {
      if (!(lastMessageDetails?.sentByMe ?? false)) {
        return IsmChatDimens.box0;
      }
      if (lastMessageDetails?.messageBody.isEmpty == true) {
        return IsmChatDimens.box0;
      }

      if ([
        IsmChatCustomMessageType.addMember,
        IsmChatCustomMessageType.unblock,
        IsmChatCustomMessageType.block,
        IsmChatCustomMessageType.deletedForEveryone,
        IsmChatCustomMessageType.memberJoin,
        IsmChatCustomMessageType.memberLeave,
        IsmChatCustomMessageType.conversationCreated,
        IsmChatCustomMessageType.conversationImageUpdated,
        IsmChatCustomMessageType.conversationTitleUpdated,
      ].contains(lastMessageDetails!.customType)) {
        return IsmChatDimens.box0;
      }

      var deliveredToAll = false;
      var readByAll = false;
      if (!isGroup!) {
        // this means not recieved by the user
        if (lastMessageDetails?.deliverCount != 0) {
          deliveredToAll = true;
          // this means not read by the user
          if (lastMessageDetails?.readCount != 0) {
            readByAll = true;
          }
        }
      } else {
        if (membersCount == lastMessageDetails?.deliverCount) {
          deliveredToAll = true;
          if (membersCount == lastMessageDetails?.readCount) {
            readByAll = true;
          }
        }
      }

      return lastMessageDetails?.messageId.isEmpty == true
          ? lastMessageDetails?.isInvalidMessage == true
              ? Icon(
                  Icons.error_outlined,
                  color: IsmChatConfig.chatTheme.chatPageTheme
                          ?.messageStatusTheme?.inValidIconColor ??
                      IsmChatColors.greyColor,
                  size:
                      IsmChatConfig.chatTheme.chatListCardThemData?.iconSize ??
                          IsmChatDimens.sixteen,
                )
              : Icon(
                  Icons.watch_later_outlined,
                  color: IsmChatConfig.chatTheme.chatPageTheme
                          ?.messageStatusTheme?.unreadCheckColor ??
                      IsmChatColors.greyColor,
                  size:
                      IsmChatConfig.chatTheme.chatListCardThemData?.iconSize ??
                          IsmChatDimens.sixteen,
                )
          : IsmChatProperties.chatPageProperties.features.contains(
              IsmChatFeature.showMessageStatus,
            )
              ? Icon(
                  // If readByAll is true, deliveredToAll must also be true
                  // Always show double checkmark if read
                  readByAll || deliveredToAll
                      ? Icons.done_all_rounded
                      : Icons.done_rounded,
                  color: readByAll
                      ? IsmChatConfig.chatTheme.chatPageTheme
                              ?.messageStatusTheme?.readCheckColor ??
                          IsmChatColors.blueColor
                      : IsmChatConfig.chatTheme.chatPageTheme
                              ?.messageStatusTheme?.unreadCheckColor ??
                          IsmChatColors.greyColor,
                  size:
                      IsmChatConfig.chatTheme.chatListCardThemData?.iconSize ??
                          IsmChatDimens.sixteen,
                )
              : IsmChatDimens.box0;
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return const SizedBox.shrink();
    }
  }
}

/// Extension for LastMessageDetails to get message body and icon.
extension LastMessageBody on LastMessageDetails {
  /// Returns the formatted message body based on custom type.
  String get messageBody {
    switch (customType) {
      case IsmChatCustomMessageType.reply:
        //return 'Replied to $body';
        return body;
      case IsmChatCustomMessageType.image:
        return 'Image';
      case IsmChatCustomMessageType.video:
        return 'Video';
      case IsmChatCustomMessageType.audio:
        return 'Audio';
      case IsmChatCustomMessageType.file:
        return 'Document';
      case IsmChatCustomMessageType.location:
        return 'Location';
      case IsmChatCustomMessageType.block:
        var status = 'blocked';
        var text =
            IsmChatConfig.communicationConfig.userConfig.userId == initiatorId
                ? 'You $status this user'
                : 'You are $status';
        return text;
      case IsmChatCustomMessageType.contact:
        return 'Contact';
      case IsmChatCustomMessageType.unblock:
        var status = 'unblocked';
        var text =
            IsmChatConfig.communicationConfig.userConfig.userId == initiatorId
                ? 'You $status this user'
                : 'You are $status';
        return text;

      case IsmChatCustomMessageType.conversationCreated:
        return 'Conversation created';
      case IsmChatCustomMessageType.conversationImageUpdated:
        return 'Changed this group profile';
      case IsmChatCustomMessageType.conversationTitleUpdated:
        return 'Changed this group title';
      case IsmChatCustomMessageType.removeMember:
        return 'Removed ${(members ?? []).join(', ')}';
      case IsmChatCustomMessageType.addMember:
        return 'Added ${(members ?? []).join(', ')}';
      case IsmChatCustomMessageType.addAdmin:
        return 'Added $adminOpponentName as an Admin';
      case IsmChatCustomMessageType.removeAdmin:
        return 'Remove $adminOpponentName as an Admin';
      case IsmChatCustomMessageType.memberLeave:
        return '$senderName left';
      case IsmChatCustomMessageType.memberJoin:
        return '$senderName join';
      case IsmChatCustomMessageType.deletedForMe:
      case IsmChatCustomMessageType.deletedForEveryone:
        return sentByMe
            ? IsmChatStrings.deletedMessage
            : IsmChatStrings.wasDeletedMessage;
      case IsmChatCustomMessageType.oneToOneCall:
        if (action == IsmChatActionEvents.meetingCreated.name) {
          return '${meetingType == 0 ? 'Voice' : 'Video'} call • In call';
        } else if (callDurations?.length == 2) {
          return '${meetingType == 0 ? 'Voice' : 'Video'} call';
        } else {
          return 'Missed ${meetingType == 0 ? 'voice' : 'video'} call';
        }
      case IsmChatCustomMessageType.link:
      case IsmChatCustomMessageType.forward:
      case IsmChatCustomMessageType.date:
      case IsmChatCustomMessageType.text:
      default:
        var isReacted = action == IsmChatActionEvents.reactionAdd.name;
        return reactionType?.isNotEmpty == true
            ? sentByMe
                ? 'You ${isReacted ? 'reacted' : 'removed'} ${reactionType?.reactionString} ${isReacted ? 'to' : 'from'} a message'
                : '$senderName ${isReacted ? 'reacted' : 'removed'} ${reactionType?.reactionString} ${isReacted ? 'to' : 'from'} a message'
            : body;
    }
  }

  /// Returns an icon widget based on the message custom type.
  Widget get icon {
    IconData? iconData;
    switch (customType) {
      // case IsmChatCustomMessageType.reply:
      //   iconData = Icons.reply_rounded;
      //   break;
      case IsmChatCustomMessageType.image:
        iconData = Icons.image_rounded;
        break;
      case IsmChatCustomMessageType.video:
        iconData = Icons.videocam_rounded;
        break;
      case IsmChatCustomMessageType.audio:
        iconData = Icons.audiotrack_rounded;
        break;
      case IsmChatCustomMessageType.file:
        iconData = Icons.description_rounded;
        break;
      case IsmChatCustomMessageType.location:
        iconData = Icons.location_on_rounded;
        break;
      case IsmChatCustomMessageType.block:
      case IsmChatCustomMessageType.unblock:
        iconData = Icons.block_rounded;
        break;
      case IsmChatCustomMessageType.conversationCreated:
        iconData = Icons.how_to_reg_rounded;
        break;
      case IsmChatCustomMessageType.addMember:
        iconData = Icons.waving_hand_rounded;
        break;
      case IsmChatCustomMessageType.memberLeave:
        iconData = Icons.directions_walk_rounded;
        break;
      case IsmChatCustomMessageType.memberJoin:
        iconData = Icons.join_inner_outlined;
        break;
      case IsmChatCustomMessageType.link:
        iconData = Icons.link_rounded;
        break;
      case IsmChatCustomMessageType.forward:
        iconData = Icons.shortcut_rounded;
        break;
      case IsmChatCustomMessageType.removeMember:
        iconData = Icons.group_remove_outlined;
        break;
      case IsmChatCustomMessageType.deletedForEveryone:
        iconData = Icons.remove_circle_outline_rounded;
        break;
      case IsmChatCustomMessageType.oneToOneCall:
        iconData = meetingType == 0
            ? sentByMe
                ? Icons.call_outlined
                : Icons.phone_callback_outlined
            : sentByMe
                ? Icons.video_call_outlined
                : Icons.missed_video_call_outlined;
        break;
      case IsmChatCustomMessageType.addAdmin:
      case IsmChatCustomMessageType.removeAdmin:
      case IsmChatCustomMessageType.deletedForMe:
      case IsmChatCustomMessageType.conversationImageUpdated:
      case IsmChatCustomMessageType.conversationTitleUpdated:
      case IsmChatCustomMessageType.date:
      case IsmChatCustomMessageType.text:
      case IsmChatCustomMessageType.reply:
      default:
    }

    if (iconData != null) {
      return Icon(
        iconData,
        size: IsmChatConfig.chatTheme.chatListCardThemData?.iconSize,
        color: IsmChatConfig.chatTheme.chatListCardThemData?.subTitleColor ??
            IsmChatColors.blackColor,
      );
    }
    return IsmChatDimens.box0;
  }
}

/// Extension for IsmChatMessageModel to get mention list, focus menu, and styling.
extension MentionMessage on IsmChatMessageModel {
  /// Extracts mentions and links from the message body.
  List<LocalMentionAndLinkData> get mentionList {
    try {
      final linkRegExp = RegExp(
        r'(\bhttps?:\/\/\S+\b|\bwww\.\S+\b|\b\d{9,13}\b|\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b|@[A-Za-z0-9_]+)',
        caseSensitive: false,
      );
      final matches = linkRegExp.allMatches(body);
      var lastMatchEnd = 0;
      var messageList = <LocalMentionAndLinkData>[];
      for (var match in matches) {
        if (match.start > lastMatchEnd) {
          messageList.add(
            LocalMentionAndLinkData(
              text: body.substring(lastMatchEnd, match.start),
              isLink: false,
            ),
          );
        }

        final linkText = match.group(0) ?? '';
        messageList.add(
          LocalMentionAndLinkData(
            text: linkText,
            isLink: true,
          ),
        );

        lastMatchEnd = match.end;
      }
      if (lastMatchEnd < body.length) {
        messageList.add(LocalMentionAndLinkData(
          text: body.substring(lastMatchEnd),
          isLink: false,
        ));
      }

      return messageList;
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return [];
    }
  }

  /// Returns a list of focus menu types available for this message.
  List<IsmChatFocusMenuType> get focusMenuList {
    var menu = [...IsmChatFocusMenuType.values];
    if (!sentByMe) {
      menu.remove(IsmChatFocusMenuType.info);
    }
    if ([
      IsmChatCustomMessageType.video,
      IsmChatCustomMessageType.image,
      IsmChatCustomMessageType.audio,
      IsmChatCustomMessageType.file
    ].contains(customType)) {
      menu.remove(IsmChatFocusMenuType.copy);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.reply)) {
      menu.remove(IsmChatFocusMenuType.reply);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.forward)) {
      menu.remove(IsmChatFocusMenuType.forward);
    }
    if (IsmChatUtility.chatPageController.isBroadcast) {
      menu.removeWhere((e) => [
            IsmChatFocusMenuType.info,
            IsmChatFocusMenuType.delete,
            IsmChatFocusMenuType.reply,
            IsmChatFocusMenuType.selectMessage
          ].contains(e));
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.copyMessage)) {
      menu.remove(IsmChatFocusMenuType.copy);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.selectMessage)) {
      menu.remove(IsmChatFocusMenuType.selectMessage);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.deleteMessage)) {
      menu.remove(IsmChatFocusMenuType.delete);
    }

    if (!(IsmChatProperties.chatPageProperties.canReplayMessage?.call(this) ??
        true)) {
      menu.remove(IsmChatFocusMenuType.reply);
    }

    return menu;
  }

  /// Returns the text style for the message based on sender.
  TextStyle get style {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return (theme?.selfMessageTheme?.textStyle ?? IsmChatStyles.w500White14)
          .copyWith(
        color: theme?.selfMessageTheme?.textColor,
      );
    }
    return (theme?.opponentMessageTheme?.textStyle ?? IsmChatStyles.w500Black14)
        .copyWith(
      color: theme?.opponentMessageTheme?.textColor,
    );
  }

  /// Returns the read more text style for the message.
  TextStyle get readTextStyle {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.readMoreTextStyle ??
          IsmChatStyles.w500White14;
    }
    return theme?.opponentMessageTheme?.readMoreTextStyle ??
        IsmChatStyles.w500Black14;
  }

  /// Returns the time text style for the message.
  TextStyle get timeStyle {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.timeStyle ??
          style.copyWith(fontSize: (style.fontSize ?? 0) - 5);
    }
    return theme?.opponentMessageTheme?.timeStyle ??
        style.copyWith(fontSize: (style.fontSize ?? 0) - 5);
  }

  /// Returns the text color for the message.
  Color? get textColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.textColor ?? IsmChatColors.whiteColor;
    }
    return theme?.opponentMessageTheme?.textColor ?? IsmChatColors.blackColor;
  }

  /// Returns the background color for the message.
  Color? get backgroundColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.backgroundColor ??
          IsmChatConfig.chatTheme.primaryColor;
    }
    return theme?.opponentMessageTheme?.backgroundColor ??
        IsmChatConfig.chatTheme.backgroundColor;
  }

  /// Returns the gradient for the message (if any).
  Gradient? get gradient {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.gradient;
    }
    return theme?.opponentMessageTheme?.gradient;
  }

  /// Returns the border color for the message.
  Color? get borderColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.borderColor ??
          IsmChatConfig.chatTheme.primaryColor;
    }
    return theme?.opponentMessageTheme?.borderColor ??
        IsmChatConfig.chatTheme.backgroundColor;
  }

  /// Returns a unique key for the message based on timestamp.
  String get key {
    final key = metaData?.messageSentAt ?? sentAt;
    final mapKey = key != 0 ? key : sentAt;
    return '$mapKey';
  }
}
