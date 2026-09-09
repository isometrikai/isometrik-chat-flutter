import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatBlockedUsersView extends StatelessWidget {
  const IsmChatBlockedUsersView({super.key});

  /// Web hosts this screen in a [Drawer] (see conversation header), not a
  /// pushed route. Mobile uses [IsmChatRoute.goToRoute]. Reuse this for the
  /// AppBar close/back control and after a successful unblock.
  static void dismiss(
    BuildContext context,
    IsmChatConversationsController controller,
  ) {
    if (IsmChatResponsive.isWeb(context)) {
      controller.isRenderScreen = IsRenderConversationScreen.none;
      final scaffold = Scaffold.maybeOf(context);
      if (scaffold?.isDrawerOpen ?? false) {
        scaffold!.closeDrawer();
      }
      return;
    }
    // Only pop when the blocked-users route is actually on the stack.
    final nav = IsmChatConfig.kNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatConversationsController>(
      tag: IsmChat.i.chatListPageTag,
      initState: (state) {
        IsmChatUtility.doLater(() async {
          await Get.find<IsmChatConversationsController>(
                  tag: IsmChat.i.chatListPageTag)
              .getBlockUser(isLoading: true);
        });
      },
      builder: (controller) {
        final profileTheme = IsmChatThemeResolver.profileFromConfig(context);
        return Scaffold(
            backgroundColor: profileTheme.scaffoldBackgroundColor,
            appBar: IsmChatAppBar(
              title: Text(
                IsmChatStrings.blockedUsers,
                style:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.titleStyle ??
                        IsmChatStyles.w600White18,
              ),
              onBack: () => dismiss(context, controller),
            ),
            body: controller.blockUsers.isEmpty
                ? Center(
                    child: IsmIconAndText(
                      icon: Icons.supervised_user_circle_rounded,
                      text: IsmChatStrings.noBlockedUsers,
                    ),
                  )
                : ListView.builder(
                    itemCount: controller.blockUsers.length,
                    itemBuilder: (_, index) {
                      var user = controller.blockUsers[index];
                      return ListTile(
                        leading: IsmChatImage.profile(user.profileUrl),
                        title: Text(
                          user.userName,
                          style: profileTheme.listTileTitleStyle,
                        ),
                        subtitle: Text(
                          user.userIdentifier,
                          style: profileTheme.listTileSubtitleStyle,
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Same API + local list update on web and mobile.
                              // (Web previously only called unblockUserForWeb,
                              // which no-ops when that user is not the open chat.)
                              final success = await controller.unblockUser(
                                opponentId: user.userId,
                                isLoading: true,
                              );
                              if (!success || !context.mounted) return;

                              // Web: close drawer — do not root-navigator pop.
                              // Mobile: stay on the list (user may unblock more).
                              if (IsmChatResponsive.isWeb(context)) {
                                dismiss(context, controller);
                              }
                            } catch (e, st) {
                              IsmChatLog.error(
                                'Error unblocking user ${user.userId}: $e',
                                st,
                              );
                            }
                          },
                          child: Text(
                            IsmChatStrings.unblock,
                          ),
                        ),
                      );
                    },
                  ),
          );
      });
}
