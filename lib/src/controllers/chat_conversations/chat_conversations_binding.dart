import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
        IsmChatConversationsController(
          IsmChatConversationsViewModel(
            IsmChatConversationsRepository(),
          ),
        ),
        permanent: IsmChat.i.chatListPageTag == null,
        tag: IsmChat.i.chatListPageTag);
  }
}
