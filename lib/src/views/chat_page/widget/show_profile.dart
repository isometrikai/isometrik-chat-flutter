import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';

class IsmChatProfilePicView extends StatelessWidget {
  const IsmChatProfilePicView({super.key, this.user});

  final UserDetails? user;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: IsmChatColors.blackColor,
        appBar: AppBar(
          leading: const IconButton(
              onPressed: IsmChatRoute.goBack,
              icon: Icon(
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
            user?.userName ?? '',
            style: IsmChatStyles.w600White18,
          ),
        ),
        body: Center(
            child: PhotoView(
          imageProvider: NetworkImage(user?.profileUrl ?? ''),
          loadingBuilder: (context, event) => const IsmChatLoadingDialog(),
          wantKeepAlive: true,
        )),
      );
}
