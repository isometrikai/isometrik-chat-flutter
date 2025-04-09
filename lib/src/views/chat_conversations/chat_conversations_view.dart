import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversations extends StatefulWidget {
  const IsmChatConversations({
    super.key,
  });

  static const String route = IsmPageRoutes.chatlist;

  @override
  State<IsmChatConversations> createState() => _IsmChatConversationsState();
}

class _IsmChatConversationsState extends State<IsmChatConversations>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    startInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    closeOverlay();
    super.dispose();
  }

  @override
  void deactivate() {
    closeOverlay();
    super.deactivate();
  }

  void closeOverlay() {
    if (Get.isRegistered<IsmChatPageController>()) {
      Get.find<IsmChatPageController>().closeOverlay();
    }
  }

  startInit() {
    if (!Get.isRegistered<IsmChatMqttController>()) {
      IsmChatLog.info(
          'IsmMQttController initiliazing from {IsmChatConversations view}');
      IsmChatMqttBinding().dependencies();
      IsmChatLog.info(
          'IsmMQttController initiliazing success from {IsmChatConversations view}');
    }
    if (!Get.isRegistered<IsmChatConversationsController>()) {
      IsmChatCommonBinding().dependencies();
      IsmChatConversationsBinding().dependencies();
    }
    var controller = Get.find<IsmChatConversationsController>();
    controller.tabController = TabController(
      length:
          IsmChatProperties.conversationProperties.allowedConversations.length,
      vsync: this,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (AppLifecycleState.resumed == state) {
      if (Get.isRegistered<IsmChatConversationsController>()) {
        Get.find<IsmChatConversationsController>().getChatConversations();
      }
      IsmChatLog.info('app in resumed');
    }
    if (AppLifecycleState.paused == state) {
      IsmChatLog.info('app in backgorund');
    }
    if (AppLifecycleState.detached == state) {
      IsmChatLog.info('app in killed');
    }
  }

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        builder: (controller) {
          controller.context = context;
          return Scaffold(
            backgroundColor:
                IsmChatConfig.chatTheme.chatListTheme?.backGroundColor,
            drawerScrimColor: Colors.transparent,
            appBar: (IsmChatProperties.conversationProperties.shouldShowAppBar
                ? PreferredSize(
                    preferredSize: Size(
                      Get.width,
                      IsmChatProperties.conversationProperties.headerHeight ??
                          IsmChatDimens.sixty,
                    ),
                    child: IsmChatProperties.conversationProperties.header ??
                        IsmChatDimens.box0,
                  )
                : null),
            body: SafeArea(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: IsmChatResponsive.isWeb(context)
                          ? Border(
                              right: BorderSide(
                                color: IsmChatConfig.chatTheme.dividerColor ??
                                    IsmChatColors.whiteColor,
                              ),
                            )
                          : null,
                    ),
                    width: IsmChatResponsive.isWeb(context)
                        ? IsmChatProperties.sideWidgetWidth ??
                            IsmChatDimens.percentWidth(.3)
                        : IsmChatDimens.percentWidth(1),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (!IsmChatProperties
                                .conversationProperties.shouldShowAppBar &&
                            IsmChatProperties.conversationProperties.header !=
                                null) ...[
                          IsmChatProperties.conversationProperties.header ??
                              IsmChatDimens.box0,
                        ],
                        if (IsmChatProperties.conversationProperties
                                    .allowedConversations.length !=
                                1 &&
                            IsmChatProperties.conversationProperties
                                    .conversationPosition ==
                                IsmChatConversationPosition.tabBar) ...[
                          _IsmchatTabBar(),
                          _IsmChatTabView()
                        ] else ...[
                          Obx(
                            () => Expanded(
                              child: controller.conversationView[
                                  controller.currentConversationIndex],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                  if (IsmChatResponsive.isWeb(context)) ...[
                    Expanded(
                      child: Stack(
                        children: [
                          Obx(
                            () => controller.currentConversation != null
                                ? ([
                                    IsRenderChatPageScreen
                                        .boradcastChatMessagePage,
                                    IsRenderChatPageScreen.openChatMessagePage
                                  ].contains(
                                        controller.isRenderChatPageaScreen))
                                    ? controller.isRenderChatScreenWidget()
                                    : controller.chatPageView[
                                        controller.currentConversationIndex]
                                : IsmChatProperties.noChatSelectedPlaceholder ??
                                    Center(
                                      child: Text(
                                        IsmChatStrings.startConversation,
                                        style: IsmChatStyles.w400White18,
                                      ),
                                    ),
                          ),
                          if (IsmChatResponsive.isTablet(context)) ...[
                            Obx(
                              () => controller.isRenderChatPageaScreen !=
                                      IsRenderChatPageScreen.none
                                  ? controller.isRenderChatScreenWidget()
                                  : IsmChatDimens.box0,
                            )
                          ]
                        ],
                      ),
                    ),
                    if (IsmChatResponsive.isWeb(context)) ...[
                      Obx(
                        () => ![
                          IsRenderChatPageScreen.none,
                          IsRenderChatPageScreen.boradcastChatMessagePage,
                          IsRenderChatPageScreen.openChatMessagePage
                        ].contains(controller.isRenderChatPageaScreen)
                            ? Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: IsmChatConfig
                                              .chatTheme.dividerColor ??
                                          IsmChatColors.whiteColor,
                                    ),
                                  ),
                                ),
                                width: IsmChatProperties.sideWidgetWidth ??
                                    IsmChatDimens.percentWidth(.3),
                                child: controller.isRenderChatScreenWidget(),
                              )
                            : IsmChatDimens.box0,
                      )
                    ]
                  ]
                ],
              ),
            ),
            floatingActionButton: IsmChatProperties
                        .conversationProperties.showCreateChatIcon &&
                    !IsmChatResponsive.isWeb(context)
                ? IsmChatStartChatFAB(
                    icon:
                        IsmChatProperties.conversationProperties.createChatIcon,
                    onTap: () {
                      if (IsmChatProperties
                          .conversationProperties.enableGroupChat) {
                        Get.bottomSheet(
                          const _CreateChatBottomSheet(),
                          backgroundColor: Colors.transparent,
                          elevation: 0,
                        );
                      } else {
                        IsmChatProperties.conversationProperties.onCreateTap
                            ?.call();
                        IsmChatRouteManagement.goToCreateChat(
                          isGroupConversation: false,
                        );
                      }
                    },
                  )
                : null,
            drawer: IsmChatResponsive.isWeb(context)
                ? Obx(
                    () => SizedBox(
                      width: IsmChatDimens.percentWidth(.299),
                      child: controller.isRenderScreenWidget(),
                    ),
                  )
                : null,
          );
        },
      );
}

class _IsmchatTabBar extends StatelessWidget {
  _IsmchatTabBar();

  final controller = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => Container(
        height: IsmChatDimens.forty,
        margin: IsmChatDimens.edgeInsets10,
        padding: IsmChatDimens.edgeInsets4,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: IsmChatColors.whiteColor,
          borderRadius: BorderRadius.circular(
            IsmChatDimens.twenty,
          ),
          boxShadow: [
            BoxShadow(
              color: IsmChatColors.greyColor,
              blurRadius: IsmChatDimens.one,
            ),
          ],
        ),
        child: TabBar(
          splashBorderRadius: BorderRadius.circular(
            IsmChatDimens.twenty,
          ),
          controller: controller.tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(
              IsmChatDimens.twenty,
            ),
            color: IsmChatConfig.chatTheme.primaryColor,
          ),
          labelColor: IsmChatColors.whiteColor,
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: IsmChatStyles.w400White14,
          unselectedLabelColor: IsmChatColors.greyColor,
          physics: const ClampingScrollPhysics(),
          unselectedLabelStyle: IsmChatStyles.w400Black14,
          tabs: List.generate(
            IsmChatProperties
                .conversationProperties.allowedConversations.length,
            (index) {
              var data = IsmChatProperties
                  .conversationProperties.allowedConversations[index];
              return Tab(
                text: data.conversationName,
              );
            },
          ),
        ),
      );
}

class _IsmChatTabView extends StatelessWidget {
  _IsmChatTabView();

  final controller = Get.find<IsmChatConversationsController>();

  @override
  Widget build(BuildContext context) => Expanded(
        child: TabBarView(
          controller: controller.tabController,
          children: List.generate(
            IsmChatProperties
                .conversationProperties.allowedConversations.length,
            (index) {
              var data = IsmChatProperties
                  .conversationProperties.allowedConversations[index];
              return data.conversationWidget;
            },
          ),
        ),
      );
}

class _CreateChatBottomSheet extends StatelessWidget {
  const _CreateChatBottomSheet();

  void _startConversation(
      [bool isGroup = false,
      IsmChatConversationType conversationType =
          IsmChatConversationType.private]) {
    Get.back();
    IsmChatRouteManagement.goToCreateChat(
      isGroupConversation: isGroup,
      conversationType: conversationType,
    );
  }

  @override
  Widget build(BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              _startConversation();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: IsmChatDimens.fifty,
                  child: Icon(
                    Icons.people_rounded,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
                IsmChatDimens.boxWidth8,
                Text(
                  '1 to 1 ${IsmChatStrings.conversation}',
                  style: IsmChatStyles.w400White18.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              _startConversation(true);
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: IsmChatDimens.fifty,
                  child: Icon(
                    Icons.groups_rounded,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
                IsmChatDimens.boxWidth8,
                Text(
                  IsmChatStrings.groupConversation,
                  style: IsmChatStyles.w400White18.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              _startConversation(
                true,
                IsmChatConversationType.public,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: IsmChatDimens.fifty,
                  child: Icon(
                    Icons.group_add_outlined,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
                IsmChatDimens.boxWidth8,
                Text(
                  IsmChatStrings.publicConversation,
                  style: IsmChatStyles.w400White18.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              _startConversation(
                true,
                IsmChatConversationType.open,
              );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: IsmChatDimens.fifty,
                  child: Icon(
                    Icons.reduce_capacity_outlined,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
                IsmChatDimens.boxWidth8,
                Text(
                  IsmChatStrings.openConversation,
                  style: IsmChatStyles.w400White18.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Get.back();
              IsmChatRouteManagement.goToCreteBroadcastView();
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: IsmChatDimens.fifty,
                  child: Icon(
                    Icons.campaign_outlined,
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
                IsmChatDimens.boxWidth8,
                Text(
                  IsmChatStrings.boradcastMessge,
                  style: IsmChatStyles.w400White18.copyWith(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: Get.back,
          isDestructiveAction: true,
          child: const Text('Cancel'),
        ),
      );
}
