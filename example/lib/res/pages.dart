import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/controllers/controllers.dart';
import 'package:isometrik_chat_flutter_example/views/signup_view.dart';
import 'package:isometrik_chat_flutter_example/views/views.dart';

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
