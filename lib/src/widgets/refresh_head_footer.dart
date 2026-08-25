import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Pull-to-refresh / load-more wrapper that owns **one** [RefreshController]
/// per widget instance.
///
/// Reuse this for any list that needs `SmartRefresher`. Do **not** store a
/// single [RefreshController] on a GetX controller and pass it into
/// [SmartRefresher] — `pull_to_refresh` asserts if that controller is bound to
/// more than one refresher (`_refresherState == null`). That shows up in host
/// apps that put chat inside a [TabBarView] / [IndexedStack] / bottom nav
/// (the SDK example does not, so it never hits the race).
///
/// Keep this widget **outside** (or at a stable slot of) GetX/Obx builders so
/// rebuilds update [child] instead of creating a second [SmartRefresher].
class IsmChatPullToRefresh extends StatefulWidget {
  const IsmChatPullToRefresh({
    super.key,
    required this.child,
    this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = true,
    this.header,
    this.footer,
    this.physics = const ClampingScrollPhysics(),
  });

  final Widget child;
  final Future<void> Function()? onRefresh;

  /// Return `true` when the server sent no more items (footer shows no-more).
  final Future<bool> Function()? onLoading;
  final bool enablePullDown;
  final bool enablePullUp;
  final Widget? header;
  final Widget? footer;
  final ScrollPhysics physics;

  @override
  State<IsmChatPullToRefresh> createState() => _IsmChatPullToRefreshState();
}

class _IsmChatPullToRefreshState extends State<IsmChatPullToRefresh> {
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(
      initialRefresh: false,
      initialLoadStatus: LoadStatus.idle,
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    try {
      await widget.onRefresh?.call();
      if (mounted) {
        _refreshController.refreshCompleted(resetFooterState: true);
      }
    } catch (_) {
      if (mounted) {
        _refreshController.refreshFailed();
      }
    }
  }

  Future<void> _onLoading() async {
    try {
      final noMore = await widget.onLoading?.call() ?? false;
      if (!mounted) {
        return;
      }
      if (noMore) {
        _refreshController.loadNoData();
      } else {
        _refreshController.loadComplete();
      }
    } catch (_) {
      if (mounted) {
        _refreshController.loadFailed();
      }
    }
  }

  @override
  Widget build(BuildContext context) => SmartRefresher(
        physics: widget.physics,
        controller: _refreshController,
        enablePullDown: widget.enablePullDown,
        enablePullUp: widget.enablePullUp,
        header: widget.header,
        footer: widget.footer,
        onRefresh: widget.onRefresh != null ? _onRefresh : null,
        onLoading: widget.onLoading != null ? _onLoading : null,
        child: widget.child,
      );
}

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
