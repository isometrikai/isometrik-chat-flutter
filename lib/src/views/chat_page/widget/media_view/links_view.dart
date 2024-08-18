import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// IsmMedia class is for showing the conversation media
class IsmLinksView extends StatefulWidget {
  const IsmLinksView({super.key, required this.mediaListLinks});

  final List<IsmChatMessageModel> mediaListLinks;

  @override
  State<IsmLinksView> createState() => _IsmLinksViewState();
}

class _IsmLinksViewState extends State<IsmLinksView>
    with TickerProviderStateMixin {
  List<Map<String, List<IsmChatMessageModel>>> storeWidgetLinksList = [];

  final chatPageController = Get.find<IsmChatPageController>();

  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(() {
      var storeSortLinks =
          chatPageController.sortMessages(widget.mediaListLinks);
      storeWidgetLinksList =
          chatPageController.sortMediaList(storeSortLinks).reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmChatDimens.edgeInsets10,
        child: widget.mediaListLinks.isEmpty
            ? Center(
                child: Text(
                  IsmChatStrings.noLinks,
                  style: IsmChatStyles.w600Black20,
                ),
              )
            : ListView.separated(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: storeWidgetLinksList.length,
                separatorBuilder: (_, index) => IsmChatDimens.boxHeight10,
                itemBuilder: (context, index) {
                  var media = storeWidgetLinksList[index];
                  var value = media.values.toList().first;
                  var key =
                      media.keys.toString().replaceAll(RegExp(r'\(|\)'), '');
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key,
                        style: IsmChatStyles.w400Black14,
                      ),
                      IsmChatDimens.boxHeight10,
                      ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        itemCount: value.length,
                        itemBuilder: (context, valueIndex) => IsmChatTapHandler(
                          child: Container(
                            padding: IsmChatDimens.edgeInsets10,
                            width: context.width * 0.8,
                            child: AnyLinkPreview(
                              displayDirection:
                                  UIDirection.uiDirectionHorizontal,
                              bodyMaxLines: 4,
                              urlLaunchMode: LaunchMode.externalApplication,
                              removeElevation: true,
                              bodyTextOverflow: TextOverflow.ellipsis,
                              cache: const Duration(minutes: 5),
                              link: value[valueIndex].body.convertToValidUrl,
                              backgroundColor: Colors.transparent,
                              titleStyle: IsmChatStyles.w500Black16,
                              errorWidget: Text(
                                  IsmChatStrings.errorLoadingPreview,
                                  style: IsmChatStyles.w400White12),
                              placeholderWidget: Text('Loading preview...',
                                  style: IsmChatStyles.w400White12),
                            ),
                          ),
                        ),
                        separatorBuilder: (_, index) =>
                            IsmChatDimens.boxHeight10,
                      ),
                    ],
                  );
                },
              ),
      );
}
