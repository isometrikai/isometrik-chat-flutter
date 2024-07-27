import 'package:get/get.dart';

import 'chat_list.dart';

class ChatConversationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatListController>(
      () => ChatListController(),
    );
  }
}
