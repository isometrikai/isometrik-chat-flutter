import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class IsmChatPageHeaderProperties {
  IsmChatPageHeaderProperties(
      {this.profileImageBuilder,
      this.profileImageUrl,
      this.titleBuilder,
      this.title,
      this.subtitleBuilder,
      this.subtitle,
      this.popupItems,
      this.bottom,
      this.onBackTap,
      this.height,
      this.shape,
      this.onProfileTap,
      this.actionBuilder});

  final ConversationWidgetCallback? profileImageBuilder;
  final ConversationStringCallback? profileImageUrl;
  final ConversationWidgetCallback? titleBuilder;
  final ConversationStringCallback? title;
  final WidgetCallback? subtitleBuilder;
  final WidgetCallback? subtitle;
  final WidgetCallback? actionBuilder;

  /// Provides this methode with exclude hight of widget
  final WidgetCallback? bottom;
  final PopupItemListCallback? popupItems;
  final Function(bool)? onBackTap;

  /// This funcation provides for tap on profile pic of chat page header,
  /// This is optional parameter
  /// When you have use `profileImageBuilder` then you don't use tap handler on this widget
  final void Function(IsmChatConversationModel)? onProfileTap;
  final double? Function(
    BuildContext,
    IsmChatConversationModel,
  )? height;
  final ShapeBorder? shape;
}
