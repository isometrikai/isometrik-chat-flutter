import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

class UserListPageView extends StatelessWidget {
  const UserListPageView({super.key});

  static const String route = AppRoutes.userListPage;

  @override
  Widget build(BuildContext context) {
    return IsmChatCreateConversationView(
      conversationType: IsmChatConversationType.private,
      isGroupConversation: false,
    );
  }
}
