import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Conversation documents tab ([IsmMedia]).
///
/// Text colors from [IsmChatConfig.chatTheme.chatPageTheme.mediaTheme].
class IsmDocsView extends StatefulWidget {
  const IsmDocsView({super.key, required this.mediaListDocs});

  final List<IsmChatMessageModel> mediaListDocs;

  @override
  State<IsmDocsView> createState() => _IsmDocsViewState();
}

class _IsmDocsViewState extends State<IsmDocsView>
    with TickerProviderStateMixin {
  List<Map<String, List<IsmChatMessageModel>>> storeWidgetDocsList = [];

  final chatPageController = IsmChatUtility.chatPageController;

  @override
  void initState() {
    super.initState();
    IsmChatUtility.doLater(
      () {
        var storeSortDocs = chatPageController.commonController
            .sortMessages(widget.mediaListDocs);
        storeWidgetDocsList =
            chatPageController.sortMediaList(storeSortDocs).reversed.toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaTheme = IsmChatThemeResolver.mediaFromConfig(context);
        return Padding(
          padding: IsmChatDimens.edgeInsets10,
          child: widget.mediaListDocs.isEmpty
              ? Center(
                  child: Text(
                    IsmChatStrings.noDocs,
                    style: mediaTheme.emptyStateTextStyle,
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
                    var key = media.keys
                        .toString()
                        .replaceAll(RegExp(r'\(|\)'), '');
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          key,
                          style: mediaTheme.sectionTitleTextStyle,
                        ),
                        ListView.separated(
                          physics: const ClampingScrollPhysics(),
                          addAutomaticKeepAlives: true,
                          shrinkWrap: true,
                          itemBuilder: (_, index) => ListTile(
                            onTap: () {
                              chatPageController
                                  .tapForMediaPreview(value[index]);
                            },
                            contentPadding: IsmChatDimens.edgeInsets0,
                            dense: true,
                            title: Text(
                              value[index].attachments?.first.name ?? '',
                              style: mediaTheme.docTitleTextStyle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              IsmChatUtility.formatBytes(
                                  value[index].attachments?.first.size ?? 0),
                              style: mediaTheme.docSubtitleTextStyle,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              value[index].sentAt.toLastMessageTimeString,
                              style: mediaTheme.docTrailingTextStyle,
                            ),
                            leading: SvgPicture.asset(
                              IsmChatAssets.pdfSvg,
                              height: IsmChatDimens.thirtyTwo,
                              width: IsmChatDimens.thirtyTwo,
                            ),
                          ),
                          separatorBuilder: (_, index) => Divider(
                            color: mediaTheme.dividerColor.applyIsmOpacity(.5),
                          ),
                          itemCount: value.length,
                        )
                      ],
                    );
                  },
                ),
        );
  }
}
