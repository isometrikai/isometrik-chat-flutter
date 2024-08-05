import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';

class AzListWidgtet<T> extends StatefulWidget {
  const AzListWidgtet({
    super.key,
    required this.data,
    this.showIndexBar = false,
    required this.onTap,
    required this.builderList,
    required this.imageUrl,
    required this.isSelected,
    required this.subTitle,
    required this.title,
    this.onScollLoadMore,
    this.onScollRefresh,
  });

  final List<ISuspensionBean> data;
  final bool showIndexBar;
  final Function(int, T) onTap;
  final List<T> builderList;
  final String Function(T) title;
  final String Function(T) subTitle;
  final String Function(T) imageUrl;
  final bool Function(T) isSelected;
  final VoidCallback? onScollLoadMore;
  final VoidCallback? onScollRefresh;

  @override
  State<AzListWidgtet<T>> createState() => _AzListWidgtetState<T>();
}

class _AzListWidgtetState<T> extends State<AzListWidgtet<T>> {
  @override
  Widget build(BuildContext context) =>
      NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          if (scrollNotification is ScrollEndNotification) {
            if (scrollNotification.metrics.pixels >
                scrollNotification.metrics.maxScrollExtent * 0.3) {
              widget.onScollLoadMore?.call();
            } else if (scrollNotification.metrics.pixels ==
                scrollNotification.metrics.minScrollExtent * 0.3) {
              widget.onScollRefresh?.call();
            }
          }
          return true;
        },
        child: AzListView(
          data: widget.data,
          itemCount: widget.data.length,
          indexBarData: widget.showIndexBar
              ? SuspensionUtil.getTagIndexList(widget.data)
              : [],
          indexBarMargin: IsmChatDimens.edgeInsets10,
          indexBarHeight: IsmChatDimens.percentHeight(5),
          indexBarWidth: IsmChatDimens.forty,
          indexBarItemHeight: IsmChatDimens.twenty,
          indexHintBuilder: (context, hint) => Container(
            alignment: Alignment.center,
            width: IsmChatDimens.eighty,
            height: IsmChatDimens.eighty,
            decoration: BoxDecoration(
              color: IsmChatConfig.chatTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Text(
              hint,
              style: const TextStyle(
                color: IsmChatColors.whiteColor,
                fontSize: 30.0,
              ),
            ),
          ),
          indexBarOptions: IndexBarOptions(
            indexHintDecoration:
                const BoxDecoration(color: IsmChatColors.whiteColor),
            indexHintChildAlignment: Alignment.center,
            selectTextStyle: IsmChatStyles.w400White12,
            selectItemDecoration: BoxDecoration(
              color: IsmChatConfig.chatTheme.primaryColor,
              shape: BoxShape.circle,
            ),
            needRebuild: true,
            indexHintHeight: IsmChatDimens.percentHeight(.2),
          ),
          itemBuilder: (_, int index) {
            var member = widget.builderList[index];
            var suspension = widget.data[index];
            var susTag = suspension.getSuspensionTag();
            return Column(
              children: [
                Offstage(
                  offstage: suspension.isShowSuspension != true,
                  child: IsmChatUtility.buildSusWidget(susTag),
                ),
                ColoredBox(
                  color: widget.isSelected.call(member)
                      ? IsmChatConfig.chatTheme.primaryColor!.withOpacity(.2)
                      : IsmChatColors.transparent,
                  child: ListTile(
                    onTap: () {
                      widget.onTap.call(index, member);
                      setState(() {});
                    },
                    dense: true,
                    mouseCursor: SystemMouseCursors.click,
                    leading: IsmChatImage.profile(
                      widget.imageUrl.call(member),
                      name: widget.title.call(member),
                    ),
                    title: Text(
                      widget.title.call(member),
                      style: IsmChatStyles.w600Black14,
                    ),
                    subtitle: Text(
                      widget.subTitle.call(member),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: IsmChatStyles.w400Black12,
                    ),
                    trailing: Container(
                      padding: IsmChatDimens.edgeInsets8_4,
                      decoration: BoxDecoration(
                        color: IsmChatConfig.chatTheme.primaryColor
                            ?.withOpacity(.2),
                        borderRadius:
                            BorderRadius.circular(IsmChatDimens.eight),
                      ),
                      child: Text(
                        widget.isSelected.call(member)
                            ? IsmChatStrings.remove
                            : IsmChatStrings.add,
                        style: IsmChatStyles.w400Black12.copyWith(
                          color: IsmChatConfig.chatTheme.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );
}
