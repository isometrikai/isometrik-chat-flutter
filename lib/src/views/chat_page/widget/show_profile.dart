import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class IsmChatProfilePicView extends StatelessWidget {
  IsmChatProfilePicView({super.key});

  static const String route = IsmPageRoutes.profilePicView;

  final argument = Get.arguments as Map<String, dynamic>;

  @override
  Widget build(BuildContext context) {
    final user = argument['user'] as UserDetails;
    return Scaffold(
      backgroundColor: IsmChatColors.blackColor,
      appBar: AppBar(
        leading: IconButton(
            onPressed: Get.back,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: IsmChatColors.whiteColor,
            )),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
          statusBarColor: IsmChatColors.blackColor,
          statusBarBrightness: Brightness.dark,
        ),
        backgroundColor: IsmChatColors.blackColor,
        title: Text(
          user.userName,
          style: IsmChatStyles.w600White18,
        ),
      ),
      body: Center(
          child: PhotoView(
        imageProvider: NetworkImage(user.profileUrl),
        loadingBuilder: (context, event) => const IsmChatLoadingDialog(),
        wantKeepAlive: true,
      )),
    );
  }
}
