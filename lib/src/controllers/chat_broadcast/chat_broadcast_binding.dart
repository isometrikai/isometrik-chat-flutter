import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBroadcastBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IsmChatBroadcastController>(
      IsmChatBroadcastController(
        IsmChatBroadcastViewModel(
          IsmChatBroadcastRepository(),
        ),
      ),
    );
  }
}
