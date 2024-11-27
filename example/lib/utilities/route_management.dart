import 'package:get/get.dart';
import 'package:isometrik_chat_flutter_example/views/login_view.dart';
import 'package:isometrik_chat_flutter_example/views/signup_view.dart';

class RouteManagement {
  const RouteManagement._();

  static void offToLogin() {
    Get.offAllNamed(LoginView.route);
  }

  static void goToSignPage() {
    Get.toNamed(SignupView.route);
  }
}
