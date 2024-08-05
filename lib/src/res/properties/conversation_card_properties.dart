import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

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
}
