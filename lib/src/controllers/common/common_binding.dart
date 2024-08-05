import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:get/get.dart';

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
