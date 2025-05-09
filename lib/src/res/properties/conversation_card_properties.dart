import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCardProperties {
  const IsmChatCardProperties({
    this.profileImageBuilder,
    this.profileImageUrl,
    this.nameBuilder,
    this.name,
    this.subtitleBuilder,
    this.subtitle,
    this.trailingBuilder,
    this.trailing,
    this.onProfileTap,
    this.canShowStack,
  });

  final ConversationWidgetCallback? profileImageBuilder;
  final ConversationStringCallback? profileImageUrl;
  final ConversationWidgetCallback? nameBuilder;
  final ConversationStringCallback? name;
  final ConversationWidgetCallback? subtitleBuilder;
  final ConversationStringCallback? subtitle;
  final ConversationWidgetCallback? trailingBuilder;
  final ConversationStringCallback? trailing;
  final ConversationVoidCallback? onProfileTap;
  final bool? canShowStack;
}
