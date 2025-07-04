import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// IsmMedia class is for showing the conversation media
class IsmMedia extends StatefulWidget {
  const IsmMedia({
    super.key,
    required this.mediaList,
    required this.mediaListLinks,
    required this.mediaListDocs,
  });

  final List<IsmChatMessageModel> mediaList;
  final List<IsmChatMessageModel> mediaListLinks;
  final List<IsmChatMessageModel> mediaListDocs;

  @override
  State<IsmMedia> createState() => _IsmMediaState();
}

class _IsmMediaState extends State<IsmMedia> with TickerProviderStateMixin {
  List<Map<String, List<IsmChatMessageModel>>> storeWidgetMediaList = [];

  final chatPageController = IsmChatUtility.chatPageController;

  TabController? _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 3);
    _tabController?.addListener(_handleTabSelection);
    super.initState();
  }

  void _handleTabSelection() {
    setState(() {});
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: IsmChatColors.whiteColor,
            elevation: IsmChatDimens.three,
            shadowColor: Colors.grey,
            title: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                color: IsmChatColors.darkBlueGreyColor,
              ),
              child: _TabBarView(tabController: _tabController),
            ),
            centerTitle: GetPlatform.isAndroid ? true : false,
            leading: IconButton(
              onPressed: IsmChatResponsive.isWeb(context)
                  ? () {
                      IsmChatUtility
                              .conversationController.isRenderChatPageaScreen =
                          IsRenderChatPageScreen.none;
                    }
                  : IsmChatRoute.goBack,
              icon: Icon(
                IsmChatResponsive.isWeb(context)
                    ? Icons.close_rounded
                    : Icons.arrow_back_rounded,
              ),
            ),
          ),
          body: SafeArea(
            child: TabBarView(
              controller: _tabController,
              children: [
                IsmMediaView(mediaList: widget.mediaList),
                IsmLinksView(mediaListLinks: widget.mediaListLinks),
                IsmDocsView(mediaListDocs: widget.mediaListDocs),
              ],
            ),
          ),
        ),
      );
}

class _TabBarView extends StatelessWidget {
  const _TabBarView({
    required TabController? tabController,
  }) : _tabController = tabController;

  final TabController? _tabController;

  @override
  Widget build(BuildContext context) => TabBar(
        overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (Set<WidgetState> states) => states.contains(WidgetState.focused)
                ? null
                : Colors.transparent),
        dividerColor: Colors.transparent,
        controller: _tabController,
        labelColor: IsmChatColors.blackColor,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: IsmChatDimens.edgeInsets0,
        indicatorWeight: double.minPositive,
        labelPadding: IsmChatDimens.edgeInsets2_0,
        labelStyle: IsmChatStyles.w600Black16,
        splashBorderRadius: BorderRadius.zero,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: [
          Row(
            children: [
              Container(
                  margin: IsmChatDimens.edgeInsets4,
                  height: IsmChatDimens.twentySeven,
                  width: IsmChatDimens.seventyEight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(IsmChatDimens.six),
                    color: _tabController?.index == 0
                        ? IsmChatColors.whiteColor
                        : IsmChatColors.darkBlueGreyColor,
                  ),
                  child: const Tab(
                    text: IsmChatStrings.media,
                  )),
              if (_tabController?.index == 2)
                Container(
                  height: IsmChatDimens.twenty,
                  width: IsmChatDimens.two,
                  color: IsmChatColors.greyColor.applyIsmOpacity(.1),
                )
            ],
          ),
          Container(
              margin: IsmChatDimens.edgeInsets4,
              height: IsmChatDimens.twentySeven,
              width: IsmChatDimens.seventyEight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmChatDimens.six),
                color: _tabController?.index == 1
                    ? IsmChatColors.whiteColor
                    : IsmChatColors.darkBlueGreyColor,
              ),
              child: const Tab(text: IsmChatStrings.links)),
          Row(
            children: [
              if (_tabController?.index == 0)
                Container(
                  height: IsmChatDimens.twenty,
                  width: IsmChatDimens.two,
                  color: IsmChatColors.greyColor.applyIsmOpacity(.1),
                ),
              Container(
                  margin: IsmChatDimens.edgeInsets4,
                  height: IsmChatDimens.twentySeven,
                  width: IsmChatDimens.seventyEight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(IsmChatDimens.six),
                    color: _tabController?.index == 2
                        ? IsmChatColors.whiteColor
                        : IsmChatColors.darkBlueGreyColor,
                  ),
                  child: const Tab(text: IsmChatStrings.docs)),
            ],
          ),
        ],
      );
}
