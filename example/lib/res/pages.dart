import 'package:chat_component_example/controllers/controllers.dart';
import 'package:chat_component_example/views/signup_view.dart';
import 'package:chat_component_example/views/views.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: LoginView.route,
      page: LoginView.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: SignupView.route,
      page: SignupView.new,
      binding: AuthBinding(),
    ),
    GetPage(
      name: ChatList.route,
      page: ChatList.new,
      binding: ChatConversationBinding(),
    ),
    GetPage(
      name: UserListPageView.route,
      page: UserListPageView.new,
      binding: ChatConversationBinding(),
    ),
    ...IsmChatPages.pages
  ];
}
