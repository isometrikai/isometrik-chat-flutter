import 'package:go_router/go_router.dart';
import 'package:isometrik_chat_flutter_example/views/signup_view.dart';
import 'package:isometrik_chat_flutter_example/views/views.dart';

import '../main.dart';
import '../utilities/config.dart';
import 'res.dart';

class AppRouter {
  AppRouter._();
  static GoRouter router = GoRouter(
    navigatorKey: kNavigatorKey,
    initialLocation:
        AppConfig.userDetail != null ? AppRoutes.chatList : AppRoutes.login,
    routes: [
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteName.login,
        builder: (context, state) => LoginView(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRouteName.signUp,
        builder: (context, state) => SignupView(),
      ),
      GoRoute(
        path: AppRoutes.chatList,
        name: AppRouteName.chatList,
        builder: (context, state) => ChatList(),
      ),
      GoRoute(
        path: AppRoutes.userListPage,
        name: AppRouteName.userListPage,
        builder: (context, state) => UserListPageView(),
      ),
      //  ...IsmChatPages.pages
    ],
  );
}
