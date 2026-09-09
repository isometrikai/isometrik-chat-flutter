import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:photo_view/photo_view.dart';

class IsmChatProfilePicView extends StatelessWidget {
  const IsmChatProfilePicView({super.key, this.userName, this.imageUrl});

  final String? userName;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    // Display-only: Flutter [Text] does not interpret HTML/JS (no web XSS).
    final name = (userName ?? '').trim();
    final url = (imageUrl ?? '').trim();
    // Reuse [String.isValidUrl] — never pass empty / non-http values to
    // [NetworkImage] (can fail hard in PhotoView).
    final canLoadNetwork = url.isNotEmpty && url.isValidUrl;

    return Scaffold(
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
          name,
          style: IsmChatStyles.w600White18,
        ),
      ),
      body: Center(
        child: canLoadNetwork
            ? PhotoView(
                imageProvider: NetworkImage(url),
                loadingBuilder: (context, event) =>
                    const IsmChatLoadingDialog(),
                wantKeepAlive: true,
              )
            : IsmChatImage.profile(
                '',
                name: name.isEmpty ? 'U' : name,
                dimensions: IsmChatDimens.oneHundredFifty,
              ),
      ),
    );
  }
}
