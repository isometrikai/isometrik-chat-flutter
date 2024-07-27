import 'package:chat_component_example/view_models/view_models.dart';
import 'package:get/get.dart';

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
