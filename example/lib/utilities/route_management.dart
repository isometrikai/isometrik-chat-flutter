import 'package:go_router/go_router.dart';
import 'package:isometrik_chat_flutter_example/main.dart';

import '../res/routes.dart';

class RouteManagement {
  const RouteManagement._();

  static void offToLogin() {
    kNavigatorKey.currentContext?.goNamed(AppRouteName.login);
  }

  static void goToSignPage() {
    kNavigatorKey.currentContext?.goNamed(AppRouteName.signUp);
  }
}
