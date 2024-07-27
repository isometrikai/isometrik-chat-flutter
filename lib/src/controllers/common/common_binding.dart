import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatCommonBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      IsmChatCommonController(
        IsmChatCommonViewModel(
          IsmChatCommonRepository(),
        ),
      ),
      permanent: true,
    );
  }
}
