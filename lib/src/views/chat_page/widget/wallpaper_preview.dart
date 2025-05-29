import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatWallpaperPreview extends StatelessWidget {
  const IsmChatWallpaperPreview(
      {super.key, this.backgroundColor, this.imagePath, this.assetSrNo});

  final String? backgroundColor;
  final XFile? imagePath;
  final int? assetSrNo;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: IsmChatAppBar(
          title: Text(
            'Preview',
            style: IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                IsmChatStyles.w400White18,
          ),
          centerTitle: false,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: backgroundColor?.isNotEmpty == true
                ? backgroundColor?.toColor
                : null,
            image: imagePath != null
                ? DecorationImage(
                    image: imagePath?.path.contains('blob') == true
                        ? NetworkImage(imagePath?.path ?? '')
                        : imagePath?.path.contains(
                                    'packages/isometrik_chat_flutter/assets') ==
                                true
                            ? AssetImage(
                                imagePath?.path ?? '',
                              ) as ImageProvider
                            : FileImage(
                                File(imagePath?.path ?? ''),
                              ),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: IsmChatDimens.edgeInsets10_20_10_0,
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: IsmChatConfig.chatTheme.backgroundColor,
                          borderRadius:
                              BorderRadius.circular(IsmChatDimens.eight),
                        ),
                        padding: IsmChatDimens.edgeInsets8_4,
                        child: Text(
                          'Today',
                          style: IsmChatStyles.w500Black12.copyWith(
                            color: IsmChatConfig.chatTheme.primaryColor,
                          ),
                        ),
                      ),
                      IsmChatDimens.boxHeight10,
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                            width: IsmChatDimens.percentWidth(
                                IsmChatResponsive.isWeb(context) ? .08 : .3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(IsmChatDimens.ten),
                                bottomLeft: Radius.circular(IsmChatDimens.ten),
                                bottomRight: Radius.circular(IsmChatDimens.ten),
                              ),
                              border: Border.all(
                                  color: IsmChatConfig.chatTheme.primaryColor!),
                              color: IsmChatConfig.chatTheme.backgroundColor,
                            ),
                            alignment: Alignment.centerLeft,
                            constraints: BoxConstraints(
                              minHeight:
                                  IsmChatDimens.thirtyTwo + IsmChatDimens.four,
                            ),
                            padding: IsmChatDimens.edgeInsets4,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: IsmChatDimens.edgeInsetsR4
                                      .copyWith(right: 50),
                                  child: Text(
                                    'Hiiiiii',
                                    style: IsmChatStyles.w400Black14,
                                  ),
                                ),
                                Text(
                                  DateFormat('hh:mm a').format(
                                    DateTime.now(),
                                  ),
                                  style: IsmChatConfig.chatTheme.chatPageTheme
                                          ?.opponentMessageTheme?.textStyle ??
                                      IsmChatStyles.w500Black12,
                                )
                              ],
                            )),
                      ),
                      IsmChatDimens.boxHeight10,
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                            width: IsmChatDimens.percentWidth(
                                IsmChatResponsive.isWeb(context) ? .07 : .3),
                            padding: IsmChatDimens.edgeInsets4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(IsmChatDimens.ten),
                                  bottomLeft:
                                      Radius.circular(IsmChatDimens.ten),
                                  bottomRight:
                                      Radius.circular(IsmChatDimens.ten),
                                ),
                                color: IsmChatConfig.chatTheme.primaryColor,
                                border:
                                    Border.all(color: IsmChatColors.greyColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Hello....',
                                  style: IsmChatConfig.chatTheme.chatPageTheme
                                          ?.selfMessageTheme?.textStyle ??
                                      IsmChatStyles.w500White14,
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      DateFormat('hh:mm a').format(
                                        DateTime.now()
                                            .add(const Duration(minutes: 1)),
                                      ),
                                      style: IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.selfMessageTheme
                                              ?.textStyle ??
                                          IsmChatStyles.w500White14
                                              .copyWith(fontSize: 12),
                                    ),
                                    Icon(
                                      Icons.done_all_rounded,
                                      size: IsmChatDimens.sixteen,
                                      color: Colors.blue,
                                    )
                                  ],
                                )
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                height: IsmChatDimens.hundred,
                width: IsmChatDimens.percentWidth(1),
                decoration: BoxDecoration(
                  color: IsmChatColors.blackColor.applyIsmOpacity(.3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(IsmChatDimens.twenty),
                    topRight: Radius.circular(IsmChatDimens.twenty),
                  ),
                ),
                child: IsmChatTapHandler(
                  onTap: () async {
                    final pageController = Get.find<IsmChatPageController>(
                        tag: IsmChat.i.chatPageTag);
                    final conversationController =
                        Get.find<IsmChatConversationsController>();
                    if (imagePath?.path.isNotEmpty == true) {
                      IsmChatUtility.showLoader();
                      pageController.backgroundImage = imagePath?.path ?? '';
                      pageController.backgroundColor = '';
                      if (assetSrNo == 100) {
                        var file = imagePath;
                        var bytes = await file?.readAsBytes() ?? Uint8List(0);
                        var fileExtension = file?.path.split('.').last;
                        await conversationController.getPresignedUrl(
                            fileExtension ?? '', bytes);
                      }
                      var assetList = conversationController
                              .userDetails?.metaData?.assetList ??
                          [];
                      var assetIndex = assetList.indexWhere((e) => e.keys
                          .contains(
                              pageController.conversation?.conversationId));
                      if (assetIndex != -1) {
                        assetList[assetIndex] = {
                          '${pageController.conversation?.conversationId}':
                              IsmChatBackgroundModel(
                            isImage: true,
                            imageUrl: assetSrNo == 100
                                ? conversationController.profileImage
                                : imagePath?.path ?? '',
                            srNoBackgroundAssset:
                                assetSrNo == 100 ? 100 : assetSrNo,
                          )
                        };
                      } else {
                        assetList.add({
                          '${pageController.conversation?.conversationId}':
                              IsmChatBackgroundModel(
                            isImage: true,
                            imageUrl: assetSrNo == 100
                                ? conversationController.profileImage
                                : imagePath?.path ?? '',
                            srNoBackgroundAssset:
                                assetSrNo == 100 ? 100 : assetSrNo,
                          )
                        });
                      }
                      await conversationController.updateUserData(
                        metaData: {'assetList': assetList},
                      );

                      IsmChatUtility.closeLoader();
                    } else {
                      IsmChatUtility.showLoader();
                      pageController.backgroundColor = backgroundColor ?? '';

                      pageController.backgroundImage = '';
                      var assetList = conversationController
                              .userDetails?.metaData?.assetList ??
                          [];
                      var assetIndex = assetList.indexWhere((e) => e.keys
                          .contains(
                              pageController.conversation?.conversationId));

                      if (assetIndex != -1) {
                        assetList[assetIndex] = {
                          '${pageController.conversation?.conversationId}':
                              IsmChatBackgroundModel(
                            color: backgroundColor,
                            isImage: false,
                            srNoBackgroundAssset: assetSrNo,
                          )
                        };
                      } else {
                        assetList.add({
                          '${pageController.conversation?.conversationId}':
                              IsmChatBackgroundModel(
                            color: backgroundColor,
                            isImage: false,
                            srNoBackgroundAssset: assetSrNo,
                          )
                        });
                      }
                      await conversationController.updateUserData(
                        metaData: {'assetList': assetList},
                      );
                      IsmChatUtility.closeLoader();
                    }
                    await conversationController.getUserData(isLoading: true);
                    if (assetSrNo != 100) IsmChatRoute.goBack();
                    IsmChatRoute.goBack();
                  },
                  child: Container(
                    padding: IsmChatDimens.edgeInsets20_15,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(IsmChatDimens.fifteen),
                      border: Border.all(color: IsmChatColors.whiteColor),
                      color: IsmChatColors.blackColor.applyIsmOpacity(.3),
                    ),
                    child: Text(
                      'Set wallpaper',
                      style: IsmChatStyles.w500White14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
