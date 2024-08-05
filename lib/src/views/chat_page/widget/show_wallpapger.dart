import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class ImsChatShowWallpaper extends StatefulWidget {
  const ImsChatShowWallpaper({
    super.key,
  });

  @override
  State<ImsChatShowWallpaper> createState() => _ImsChatShowWallpaperState();
}

class _ImsChatShowWallpaperState extends State<ImsChatShowWallpaper>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final conversationController = Get.find<IsmChatConversationsController>();
  final chatPageController = Get.find<IsmChatPageController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) => Container(
        color: IsmChatColors.whiteColor,
        height: IsmChatDimens.percentHeight(.6),
        child: Column(
          children: [
            Padding(
              padding: IsmChatDimens.edgeInsets10_0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (chatPageController.backgroundColor.isNotEmpty ||
                      chatPageController.backgroundImage.isNotEmpty) ...[
                    IsmChatTapHandler(
                      onTap: () async {
                        IsmChatUtility.showLoader();
                        var assetList = conversationController
                                .userDetails?.metaData?.assetList ??
                            [];
                        var assetIndex = assetList.indexWhere((e) => e.keys
                            .contains(chatPageController
                                .conversation?.conversationId));
                        assetList.removeAt(assetIndex);
                        await conversationController.updateUserData(
                          metaData: {'assetList': assetList},
                        );
                        IsmChatUtility.closeLoader();
                        await conversationController.getUserData(
                            isLoading: true);
                        chatPageController.backgroundColor = '';
                        chatPageController.backgroundImage = '';
                        Get.back();
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.delete_rounded,
                            color: IsmChatColors.redColor,
                          ),
                          Text(
                            IsmChatStrings.removeWallpaper,
                            style: IsmChatStyles.w600red16,
                          )
                        ],
                      ),
                    ),
                  ] else ...[
                    const Spacer()
                  ],
                  IconButton(
                    onPressed: Get.back,
                    icon: Icon(
                      Icons.clear_rounded,
                      color: IsmChatConfig
                              .chatTheme.chatPageHeaderTheme?.iconColor ??
                          IsmChatColors.blackColor,
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            Container(
              alignment: Alignment.topCenter,
              height: IsmChatDimens.forty,
              child: TabBar(
                  dividerColor: IsmChatColors.whiteColor,
                  controller: _tabController,
                  tabs: [
                    Text(
                      IsmChatStrings.photos,
                      style: IsmChatStyles.w600Black16,
                    ),
                    Text(
                      IsmChatStrings.colors,
                      style: IsmChatStyles.w600Black16,
                    ),
                  ]),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  conversationController.backgroundImage.isEmpty
                      ? const IsmChatLoadingDialog()
                      : GridView.builder(
                          cacheExtent: 999999,
                          shrinkWrap: true,
                          padding: IsmChatDimens.edgeInsets10,
                          itemCount:
                              conversationController.backgroundImage.length + 1,
                          addAutomaticKeepAlives: true,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return IsmChatTapHandler(
                                onTap: () async {
                                  Get.back();
                                  var file = await IsmChatUtility.pickMedia(
                                    ImageSource.gallery,
                                  );
                                  if (file.isNotEmpty) {
                                    if (IsmChatResponsive.isWeb(Get.context!)) {
                                      await Get.dialog(IsmChatPageDailog(
                                          child: IsmChatWallpaperPreview(
                                        assetSrNo: 100,
                                        backgroundColor: '',
                                        imagePath: file.first,
                                      )));
                                    } else {
                                      IsmChatRouteManagement
                                          .goToWallpaperPreview(
                                        assetSrNo: 100,
                                        backgroundColor: '',
                                        imagePath: file.first,
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  height: IsmChatDimens.hundred,
                                  width: IsmChatDimens.hundred,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: IsmChatConfig
                                              .chatTheme.primaryColor!)),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.photo_library_outlined,
                                        size: IsmChatDimens.thirty,
                                      ),
                                      Text(
                                        IsmChatStrings.myPhotos,
                                        style: IsmChatStyles.w400Black14,
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }
                            var image = conversationController
                                .backgroundImage[index - 1];
                            return IsmChatTapHandler(
                              onTap: () async {
                                if (IsmChatResponsive.isWeb(Get.context!)) {
                                  await Get.dialog(
                                    IsmChatPageDailog(
                                      child: IsmChatWallpaperPreview(
                                        assetSrNo: image.srNo,
                                        backgroundColor: '',
                                        imagePath: XFile(
                                            '${IsmChatAssets.backgroundImages}/${image.path!}'),
                                      ),
                                    ),
                                  );
                                } else {
                                  IsmChatRouteManagement.goToWallpaperPreview(
                                    assetSrNo: image.srNo,
                                    backgroundColor: '',
                                    imagePath: XFile(
                                        '${IsmChatAssets.backgroundImages}/${image.path!}'),
                                  );
                                }
                              },
                              child: _BackgroundImage(image: image),
                            );
                          },
                        ),
                  conversationController.backgroundColor.isEmpty
                      ? const IsmChatLoadingDialog()
                      : GridView.builder(
                          padding: IsmChatDimens.edgeInsets10_0,
                          itemCount:
                              conversationController.backgroundColor.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                          ),
                          itemBuilder: (context, index) {
                            var color =
                                conversationController.backgroundColor[index];
                            return IsmChatTapHandler(
                              onTap: () async {
                                if (IsmChatResponsive.isWeb(context)) {
                                  await Get.dialog(
                                    IsmChatPageDailog(
                                      child: IsmChatWallpaperPreview(
                                        backgroundColor: color.color,
                                        imagePath: null,
                                        assetSrNo: color.srNo,
                                      ),
                                    ),
                                  );
                                } else {
                                  IsmChatRouteManagement.goToWallpaperPreview(
                                    backgroundColor: color.color,
                                    imagePath: null,
                                    assetSrNo: color.srNo,
                                  );
                                }
                              },
                              child: SizedBox(
                                height: IsmChatDimens.hundred,
                                width: IsmChatDimens.hundred,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: color.color != null
                                      ? ColoredBox(
                                          color: color.color?.toColor ??
                                              Colors.transparent,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _BackgroundImage extends StatefulWidget {
  const _BackgroundImage({
    required this.image,
  });

  final BackGroundAsset image;

  @override
  State<_BackgroundImage> createState() => _BackgroundImageState();
}

class _BackgroundImageState extends State<_BackgroundImage>
    with AutomaticKeepAliveClientMixin<_BackgroundImage> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: IsmChatDimens.hundred,
      width: IsmChatDimens.hundred,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(IsmChatDimens.ten),
        child: Image.asset(
          '${IsmChatAssets.backgroundImages}/${widget.image.path!}',
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            IsmChatLog.error(error, stackTrace);
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
