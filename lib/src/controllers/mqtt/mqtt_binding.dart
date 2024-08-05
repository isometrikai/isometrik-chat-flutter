import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:get/get.dart';

class IsmChatMqttBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<IsmChatMqttController>(
      IsmChatMqttController(
        IsmChatMqttViewModel(
          IsmChatMqttRepository(),
        ),
      ),
      permanent: true,
    );
  }
}
