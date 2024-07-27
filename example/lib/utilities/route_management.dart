import 'package:chat_component_example/views/login_view.dart';
import 'package:chat_component_example/views/signup_view.dart';
import 'package:get/get.dart';

class RouteManagement {
  const RouteManagement._();

  static void offToLogin() {
    Get.offAllNamed(LoginView.route);
  }

  static void goToSignPage() {
    Get.toNamed(SignupView.route);
  }
}
