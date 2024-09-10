import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatFileMessage extends StatelessWidget {
  const IsmChatFileMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) {
    final memoryImage = message.attachments?.first.mediaUrl?.isValidUrl == true
        ? MemoryImage(Uint8List(0))
        : Get.find<IsmChatPageController>(tag: IsmChat.i.tag).getMemoryImage(
            message.sentAt,
            (message.attachments?.first.thumbnailUrl ?? '').strigToUnit8List);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: context.width * 0.5,
          height: kIsWeb ? context.height * 0.2 : null,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IsmChatDimens.ten),
          ),
          clipBehavior: Clip.antiAlias,
          child: kIsWeb
              ? Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: double.maxFinite,
                      height: IsmChatDimens.twoHundredTwenty,
                      child: IsmChatPdfView(
                        filePath: message.attachments?.first.mediaUrl,
                      ),
                    ),
                    Container(
                      height: IsmChatDimens.fifty,
                      width: double.maxFinite,
                      color: message.backgroundColor,
                      child: Container(
                        color: (message.sentByMe
                                ? IsmChatColors.whiteColor
                                : IsmChatColors.greyColor)
                            .withOpacity(0.2),
                        padding: IsmChatDimens.edgeInsets4,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              IsmChatAssets.pdfSvg,
                              height: IsmChatDimens.thirtyTwo,
                              width: IsmChatDimens.thirtyTwo,
                            ),
                            IsmChatDimens.boxWidth4,
                            Flexible(
                              child: Text(
                                message.attachments?.first.name ?? '',
                                style: (message.sentByMe
                                        ? IsmChatStyles.w400White12
                                        : IsmChatStyles.w400Black12)
                                    .copyWith(
                                  color: message.style.color,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (message.attachments?.first.mediaUrl?.isNotEmpty == true)
                      SizedBox(
                          width: IsmChatDimens.percentWidth(.5),
                          height: IsmChatDimens.oneHundredThirty,
                          child: message.attachments?.first.mediaUrl
                                      ?.isValidUrl ==
                                  true
                              ? Image.network(
                                  message.attachments?.first.thumbnailUrl ?? '',
                                  fit: BoxFit.fill,
                                )
                              : Image(
                                  image: memoryImage,
                                  fit: BoxFit.fill,
                                  gaplessPlayback: true,
                                )),
                    Container(
                      height: context.width * 0.15,
                      width: double.maxFinite,
                      color: message.backgroundColor,
                      child: Container(
                        color: (message.sentByMe
                                ? IsmChatColors.whiteColor
                                : IsmChatColors.greyColor)
                            .withOpacity(0.2),
                        padding: IsmChatDimens.edgeInsets4,
                        child: Material(
                          color: Colors.transparent,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                IsmChatAssets.pdfSvg,
                                height: IsmChatDimens.thirtyTwo,
                                width: IsmChatDimens.thirtyTwo,
                              ),
                              IsmChatDimens.boxWidth4,
                              Flexible(
                                child: Text(
                                  message.attachments?.first.name ?? '',
                                  style: (message.sentByMe
                                          ? IsmChatStyles.w400White12
                                          : IsmChatStyles.w400Black12)
                                      .copyWith(
                                    color: message.style.color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        if (message.isUploading == true)
          IsmChatUtility.circularProgressBar(
              IsmChatColors.blackColor, IsmChatColors.whiteColor),
      ],
    );
  }
}
