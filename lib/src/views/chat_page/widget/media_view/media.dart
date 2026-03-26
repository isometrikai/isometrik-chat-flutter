import 'package:flutter/material.dart';
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
  bool get _isDocumentAllowed =>
      IsmChatProperties.chatPageProperties.attachments
          .contains(IsmChatAttachmentType.document);
  int get _tabCount => _isDocumentAllowed ? 3 : 2;
  double get _tabContainerWidth => _isDocumentAllowed ? 276 : 184;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: _tabCount);
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
        length: _tabCount,
        child: Scaffold(
          appBar: AppBar(
            surfaceTintColor: IsmChatColors.whiteColor,
            elevation: IsmChatDimens.three,
            shadowColor: Colors.grey,
            title: Container(
              width: _tabContainerWidth,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                color: IsmChatColors.darkBlueGreyColor,
              ),
              child: _TabBarView(
                tabController: _tabController,
                isDocumentAllowed: _isDocumentAllowed,
              ),
            ),
            centerTitle: true,
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
                if (_isDocumentAllowed)
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
    required this.isDocumentAllowed,
  }) : _tabController = tabController;

  final TabController? _tabController;
  final bool isDocumentAllowed;

  Widget _tabItem({
    required int index,
    required String label,
  }) {
    final isSelected = _tabController?.index == index;
    return Container(
      margin: IsmChatDimens.edgeInsets4,
      height: IsmChatDimens.twentySeven,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(IsmChatDimens.six),
        color: isSelected
            ? IsmChatColors.whiteColor
            : IsmChatColors.darkBlueGreyColor,
      ),
      child: Text(
        label,
        style: IsmChatStyles.w600Black16,
      ),
    );
  }

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
        isScrollable: false,
        tabs: [
          _tabItem(index: 0, label: IsmChatStrings.media),
          _tabItem(index: 1, label: IsmChatStrings.links),
          if (isDocumentAllowed) _tabItem(index: 2, label: IsmChatStrings.docs),
        ],
      );
}
