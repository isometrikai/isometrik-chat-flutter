import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatPageMessageAcknowldgeProperties {
  IsmChatPageMessageAcknowldgeProperties({
    this.profileImageBuilder,
    this.profileImageUrl,
    this.titleBuilder,
    this.title,
    this.trailingBuilder,
    this.trailing,
  });

  final UserDetailsWidgetCallback? profileImageBuilder;
  final UserDetailsStringCallback? profileImageUrl;
  final UserDetailsWidgetCallback? titleBuilder;
  final UserDetailsStringCallback? title;
  final UserDetailsWidgetCallback? trailingBuilder;
  final UserDetailsStringCallback? trailing;
}
