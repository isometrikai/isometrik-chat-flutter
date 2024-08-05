import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:get/get.dart';

class IsmChatPageBinding extends Bindings {
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
