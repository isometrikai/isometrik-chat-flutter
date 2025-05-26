import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class RefreshHeader extends StatelessWidget {
  const RefreshHeader({super.key});

  @override
  Widget build(BuildContext context) => CustomHeader(
        builder: (_, mode) {
          switch (mode) {
            case RefreshStatus.refreshing:
            case RefreshStatus.idle:
            case RefreshStatus.canRefresh:
            default:
              return const _SmartRefreshDialog();
          }
        },
      );
}

class RefreshFooter extends StatelessWidget {
  const RefreshFooter({super.key});

  @override
  Widget build(BuildContext context) => CustomFooter(
        builder: (_, mode) {
          switch (mode) {
            case LoadStatus.failed:
            case LoadStatus.idle:
            case LoadStatus.canLoading:
            case LoadStatus.noMore:
              return IsmChatProperties.conversationProperties.refreshFooter ??
                  Center(
                      child: Padding(
                    padding: IsmChatDimens.edgeInsetsTop20,
                    child: Text(
                      'No more data',
                      style: IsmChatStyles.w400Grey14,
                    ),
                  ));

            default:
              return const _SmartRefreshDialog();
          }
        },
      );
}

class _SmartRefreshDialog extends StatelessWidget {
  const _SmartRefreshDialog();

  @override
  Widget build(BuildContext context) => StatusBarTransparent(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IsmChatProperties.conversationProperties.refreshHeader ??
                CircularProgressIndicator.adaptive(
                  backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                ),
          ),
        ),
      );
}
