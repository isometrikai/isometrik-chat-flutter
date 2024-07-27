import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<IsmChatPageController>(
      IsmChatPageController(
        IsmChatPageViewModel(
          IsmChatPageRepository(),
        ),
      ),
    );
  }
}
