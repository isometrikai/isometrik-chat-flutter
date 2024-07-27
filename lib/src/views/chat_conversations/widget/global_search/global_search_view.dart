import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatGlobalSearchView extends StatefulWidget {
  const IsmChatGlobalSearchView({super.key});

  static const String route = IsmPageRoutes.globalSearch;

  @override
  State<IsmChatGlobalSearchView> createState() =>
      _IsmChatGlobalSearchViewState();
}

class _IsmChatGlobalSearchViewState extends State<IsmChatGlobalSearchView>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
          builder: (controller) => Scaffold(
                appBar: IsmChatAppBar(
                  title: Text(
                    IsmChatStrings.search,
                    style: IsmChatConfig
                            .chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
                  ),
                ),
                body: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    IsmChatInputField(
                      fillColor: IsmChatConfig.chatTheme.primaryColor,
                      controller: controller.globalSearchController,
                      style: IsmChatStyles.w400White16,
                      hint: IsmChatStrings.globalSearch,
                      hintStyle: IsmChatStyles.w400White16,
                      onChanged: (value) {},
                    ),
                    SizedBox(
                      height: IsmChatDimens.fifty,
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Text(IsmChatStrings.conversation),
                          Text(IsmChatStrings.messages),
                          Text(IsmChatStrings.people)
                        ],
                      ),
                    ),
                    IsmChatDimens.boxHeight20,
                    Expanded(
                      child: TabBarView(
                          controller: _tabController,
                          children: const [
                            IsmChatConversationSearchView(),
                            IsmChatMessageSearchView(),
                            IsmChatUserSearchView()
                          ]),
                    )
                  ],
                ),
              ));
}
