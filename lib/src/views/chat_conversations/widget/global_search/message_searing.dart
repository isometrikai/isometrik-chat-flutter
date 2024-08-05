import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmChatMessageSearchView extends StatelessWidget {
  const IsmChatMessageSearchView({super.key});

  static const String route = IsmPageRoutes.messageSearch;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
          initState: (state) {
            IsmChatLog.error(state.controller?.callApiOrNot);
          },
          builder: (controller) => const Scaffold(
                body: Center(
                  child: Text('Message'),
                ),
              ));
}
