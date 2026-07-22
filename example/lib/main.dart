import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';
import 'package:isometrik_chat_flutter_example/utilities/local_notice_service.dart';
import 'package:isometrik_chat_flutter_example/utilities/utilities.dart';
import 'package:url_strategy/url_strategy.dart';

import 'data/data.dart';

DBWrapper? dbWrapper;

final kNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await initialize();
  runApp(const MyApp());
}

Future<void> initialize() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  if (!kIsWeb) {
    try {
      await Firebase.initializeApp();
    } catch (_) {}
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgorundHandler);
  }
  dbWrapper = await DBWrapper.create();
  Get.put(DeviceConfig()).init();
  await AppConfig.getUserData();
  await LocalNoticeService().setup();
}

/// Call this funcation for get notifcaiton when app killed
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgorundHandler(RemoteMessage message) async =>
    await Firebase.initializeApp();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb) {
      final notificationService = PushNotificationService();
      unawaited(notificationService.initialize());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Only update if user is logged in
    if (!_isUserLoggedIn()) {
      return;
    }
  }

  /// Checks if user is logged in and SDK is initialized
  bool _isUserLoggedIn() {
    try {
      // Check if SDK is initialized
      if (!IsmChatConfig.configInitilized) {
        return false;
      }

      // Check if user config exists and has valid userId
      final userId = IsmChatConfig.communicationConfig.userConfig.userId;
      if (userId.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      // If any error occurs, assume user is not logged in
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: IsmChatResponsive.isWeb(context)
          ? const Size(1450, 745)
          : IsmChatResponsive.isTablet(context)
              ? const Size(1100, 745)
              : const Size(375, 745),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: IsmChatUtility.hideKeyboard,
        child: MaterialApp.router(
          key: const Key('ChatApp'),
          title: 'Isomterik flutter web chat',
          locale: const Locale('en', 'US'),
          // localizationsDelegates:  [
          //   ...GlobalMaterialLocalizations.delegates,
          //   GlobalWidgetsLocalizations.delegate,
          // ],
          supportedLocales: const [Locale('en', 'US')],
          theme: ThemeData.light(useMaterial3: true).copyWith(
            primaryColor: AppColors.whiteColor,
            extensions: [],
          ),
          // darkTheme: ThemeData.dark(useMaterial3: true)
          //     .copyWith(primaryColor: AppColors.primaryColorDark),
          // darkTheme: ThemeData.dark(useMaterial3: true)
          //     .copyWith(primaryColor: AppColors.primaryColorDark),
          debugShowCheckedModeBanner: false,

          routerConfig: AppRouter.router,
          // translations: AppTranslations(),
          // initialRoute:
          //     AppConfig.userDetail != null ? ChatList.route : LoginView.route,
          // getPages: AppPages.pages,
        ),
      ),
    );
  }
}

class PushNotificationService {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  /// Latest FCM token — useful when testing Firebase Console → Send test message.
  static String? fcmToken;

  Future<void> requestNotificationService() async {
    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if (![AuthorizationStatus.authorized, AuthorizationStatus.provisional]
        .contains(settings.authorizationStatus)) {
      IsmChatLog.error(
        'FCM permission denied: ${settings.authorizationStatus}',
      );
      AppSettings.openAppSettings();
    }
  }

  Future<void> initialize() async {
    await requestNotificationService();

    // Required on iOS before getToken() returns a value.
    if (!kIsWeb && GetPlatform.isIOS) {
      final apnsToken = await messaging.getAPNSToken();
      IsmChatLog.success('APNS token: $apnsToken');
    }

    fcmToken = await messaging.getToken();
    IsmChatLog.success('FCM token: $fcmToken');

    messaging.onTokenRefresh.listen((token) {
      fcmToken = token;
      IsmChatLog.success('FCM token refreshed: $token');
    });

    // Handle foreground messages (logs only — no local notification overlay).
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      IsmChatLog.success('FCM foreground message received');
      IsmChatLog.success('FCM data: ${message.data}');

      if (message.notification != null) {
        IsmChatLog.success(
          'FCM notification: title=${message.notification?.title} '
          'body=${message.notification?.body}',
        );
      }
    });

    // Handle notification tap when app is opened from notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      IsmChatLog.success('FCM notification tapped (background)');
      IsmChatLog.success('FCM data: ${message.data}');
      IsmChat.i.handleNotificationPayload(message.data);
    });

    // App opened from terminated state via notification
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      IsmChatLog.success('FCM opened app from terminated state');
      IsmChatLog.success('FCM data: ${initialMessage.data}');
      IsmChat.i.handleNotificationPayload(initialMessage.data);
    }
  }

  /// Re-fetch token (e.g. after login). Prefer [PushNotificationService.fcmToken].
  Future<String?> getToken() async {
    fcmToken = await messaging.getToken();
    IsmChatLog.success('FCM token: $fcmToken');
    return fcmToken;
  }
}
