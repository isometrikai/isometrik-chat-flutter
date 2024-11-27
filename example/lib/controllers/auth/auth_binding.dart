import 'package:get/get.dart';
import 'package:isometrik_chat_flutter_example/view_models/view_models.dart';

import 'auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(
      () => AuthController(
        Get.put<AuthViewModel>(
          AuthViewModel(),
        ),
      ),
    );
  }
}
