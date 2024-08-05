import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:get/get.dart';

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
