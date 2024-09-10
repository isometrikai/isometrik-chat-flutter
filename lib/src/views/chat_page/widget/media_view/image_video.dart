import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// IsmMedia class is for showing the conversation media
class IsmMediaView extends StatefulWidget {
  const IsmMediaView({super.key, required this.mediaList});

  final List<IsmChatMessageModel> mediaList;

  @override
  State<IsmMediaView> createState() => _IsmMediaViewState();
}

class _IsmMediaViewState extends State<IsmMediaView>
    with TickerProviderStateMixin {
  List<Map<String, List<IsmChatMessageModel>>> storeWidgetMediaList = [];

  final chatPageController =
      Get.find<IsmChatPageController>(tag: IsmChat.i.tag);

  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(
      () {
        var storeSortMedia = chatPageController.sortMessages(widget.mediaList);
        storeWidgetMediaList =
            chatPageController.sortMediaList(storeSortMedia).reversed.toList();
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmChatDimens.edgeInsets10,
        child: widget.mediaList.isEmpty
            ? Center(
                child: Text(
                  IsmChatStrings.noMedia,
                  style: IsmChatStyles.w600Black20,
                ),
              )
            : ListView.separated(
                physics: const ScrollPhysics(),
                shrinkWrap: true,
                itemCount: storeWidgetMediaList.length,
                separatorBuilder: (_, index) => IsmChatDimens.boxHeight10,
                itemBuilder: (context, index) {
                  var media = storeWidgetMediaList[index];
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
                      GridView.builder(
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: value.length,
                        addAutomaticKeepAlives: true,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 6,
                          crossAxisSpacing: 6,
                        ),
                        itemBuilder: (context, valueIndex) {
                          var url = value[valueIndex].customType ==
                                  IsmChatCustomMessageType.image
                              ? value[valueIndex].attachments?.first.mediaUrl ??
                                  ''
                              : value[valueIndex]
                                      .attachments!
                                      .first
                                      .thumbnailUrl ??
                                  '';
                          var iconData = value[valueIndex].customType ==
                                  IsmChatCustomMessageType.audio
                              ? Icons.audio_file_rounded
                              : Icons.description_rounded;

                          return IsmChatTapHandler(
                            onTap: () => Get.find<IsmChatPageController>(
                                    tag: IsmChat.i.tag)
                                .tapForMediaPreview(value[valueIndex]),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                ConversationMediaWidget(
                                  media: value[valueIndex],
                                  iconData: iconData,
                                  url: url,
                                ),
                                if (value[valueIndex].customType ==
                                    IsmChatCustomMessageType.video)
                                  Icon(
                                    Icons.play_circle_outline_outlined,
                                    color: IsmChatColors.whiteColor,
                                    size: IsmChatDimens.thirty,
                                  )
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
      );
}
