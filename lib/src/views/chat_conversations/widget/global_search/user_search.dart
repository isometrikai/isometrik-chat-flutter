import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatUserSearchView extends StatelessWidget {
  const IsmChatUserSearchView({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        tag: IsmChat.i.chatListPageTag,
        builder: (controller) => const Scaffold(
          body: Center(
            child: Text('User'),
          ),
        ),
      );
}
