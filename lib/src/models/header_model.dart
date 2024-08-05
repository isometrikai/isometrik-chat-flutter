import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class IsmChatHeader {
  IsmChatHeader({
    this.backgroundColor,
    this.iconColor,
    this.titleStyle,
    this.subtitleStyle,
    this.popupItems,
    this.shape,
    this.bottom,
    this.bottomOnTap,
    this.onProfileWidget,
    this.name,
    this.nameBuilder,
    this.profileImageBuilder,
    this.profileImageUrl,
    this.elevation,
    this.shadowColors,
  });

  final Color? backgroundColor;
  final Color? iconColor;
  final ConversationWidgetCallback? profileImageBuilder;
  final ConversationStringCallback? profileImageUrl;
  final ConversationWidgetCallback? nameBuilder;
  final ConversationStringCallback? name;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final List<IsmChatPopupMenuItem>? popupItems;
  final ShapeBorder? shape;
  final Widget? Function(BuildContext, IsmChatConversationModel)? bottom;
  final ConversationWidgetCallback? onProfileWidget;
  final void Function(IsmChatConversationModel)? bottomOnTap;
  final double? elevation;
  final Color? shadowColors;
}
