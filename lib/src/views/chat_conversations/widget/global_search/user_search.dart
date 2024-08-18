import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatUserSearchView extends StatelessWidget {
  const IsmChatUserSearchView({super.key});

  static const String route = IsmPageRoutes.userSearch;

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
          initState: (state) {
            IsmChatLog.error(state.controller?.callApiOrNot);
          },
          builder: (controller) => const Scaffold(
                body: Center(
                  child: Text('User'),
                ),
              ));
}
