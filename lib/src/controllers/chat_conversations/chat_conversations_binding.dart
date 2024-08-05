import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:get/get.dart';

class IsmChatConversationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      IsmChatConversationsController(
        IsmChatConversationsViewModel(
          IsmChatConversationsRepository(),
        ),
      ),
      permanent: true,
    );
  }
}
