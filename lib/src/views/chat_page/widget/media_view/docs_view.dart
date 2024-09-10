import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// IsmMedia class is for showing the conversation media
class IsmDocsView extends StatefulWidget {
  const IsmDocsView({super.key, required this.mediaListDocs});

  final List<IsmChatMessageModel> mediaListDocs;

  @override
  State<IsmDocsView> createState() => _IsmDocsViewState();
}

class _IsmDocsViewState extends State<IsmDocsView>
    with TickerProviderStateMixin {
  List<Map<String, List<IsmChatMessageModel>>> storeWidgetDocsList = [];

  final chatPageController =
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(
      () {
        var storeSortDocs =
            chatPageController.sortMessages(widget.mediaListDocs);
        storeWidgetDocsList =
            chatPageController.sortMediaList(storeSortDocs).reversed.toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmChatDimens.edgeInsets10,
        child: widget.mediaListDocs.isEmpty
            ? Center(
                child: Text(
                  IsmChatStrings.noDocs,
                  style: IsmChatStyles.w600Black20,
                ),
              )
            : ListView.separated(
                physics: const ClampingScrollPhysics(),
                shrinkWrap: true,
                itemCount: storeWidgetDocsList.length,
                separatorBuilder: (_, index) => IsmChatDimens.boxHeight10,
                itemBuilder: (context, index) {
                  var media = storeWidgetDocsList[index];
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
                      ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        addAutomaticKeepAlives: true,
                        shrinkWrap: true,
                        itemBuilder: (_, index) => ListTile(
                          onTap: () {
                            chatPageController.tapForMediaPreview(value[index]);
                          },
                          contentPadding: IsmChatDimens.edgeInsets0,
                          dense: true,
                          title: Text(
                            value[index].attachments?.first.name ?? '',
                            style: IsmChatStyles.w400Black14,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            IsmChatUtility.formatBytes(
                                value[index].attachments?.first.size ?? 0),
                            style: IsmChatStyles.w400Black10,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                              value[index].sentAt.toLastMessageTimeString()),
                          leading: SvgPicture.asset(
                            IsmChatAssets.pdfSvg,
                            height: IsmChatDimens.thirtyTwo,
                            width: IsmChatDimens.thirtyTwo,
                          ),
                        ),
                        separatorBuilder: (_, index) => Divider(
                          color: IsmChatColors.greyColor.withOpacity(.5),
                        ),
                        itemCount: value.length,
                      )
                    ],
                  );
                },
              ),
      );
}
