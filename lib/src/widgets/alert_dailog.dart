import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAlertDialogBox extends StatelessWidget {
  const IsmChatAlertDialogBox({
    super.key,
    this.title = 'Are you sure?',
    this.actionLabels,
    this.callbackActions,
    this.cancelLabel,
    this.onCancel,
    this.content,
    this.contentPadding,
    this.shape,
    this.contentTextStyle,
  }) : assert(
          (actionLabels == null && callbackActions == null) ||
              (actionLabels != null &&
                  callbackActions != null &&
                  actionLabels.length == callbackActions.length),
          'Equal number of actionLabels & callbackActions must be passed',
        );

  final String title;
  final List<String>? actionLabels;
  final List<VoidCallback>? callbackActions;

  /// Defaults to [IsmChatStrings.cancel] when null (resolved at build time for l10n).
  final String? cancelLabel;
  final VoidCallback? onCancel;
  final Widget? content;
  final TextStyle? contentTextStyle;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;

  EdgeInsets _resolveInsets(IsmChatDialogTheme dialogTheme) {
    final inset = dialogTheme.insetPadding;
    if (inset is EdgeInsets) return inset;
    return IsmChatDimens.edgeInsets16;
  }

  @override
  Widget build(BuildContext context) {
    final dialogTheme = IsmChatThemeResolver.dialogFromConfig(context);
    final resolvedCancelLabel = cancelLabel ?? IsmChatStrings.cancel;
    final resolvedContentStyle =
        contentTextStyle ?? dialogTheme.contentTextStyle;
    final resolvedShape = shape ?? dialogTheme.shape;
    final insets = _resolveInsets(dialogTheme);
    final titlePadding =
        EdgeInsets.fromLTRB(insets.left, insets.top, insets.right, 8);
    final resolvedContentPadding = contentPadding ??
        EdgeInsets.fromLTRB(
          insets.left,
          0,
          insets.right,
          content != null ? insets.bottom : 0,
        );
    final actionsPadding =
        EdgeInsets.fromLTRB(8, 0, insets.right, insets.bottom);

    return StatusBarTransparent(
      child: (actionLabels?.length ?? 0) <= 1
          ? AlertDialog(
              titlePadding: titlePadding,
              actionsPadding: actionsPadding,
              title: Text(title),
              backgroundColor: dialogTheme.backgroundColor,
              titleTextStyle: dialogTheme.titleTextStyle,
              contentPadding: resolvedContentPadding,
              contentTextStyle: resolvedContentStyle,
              content: content,
              shape: resolvedShape,
              actions: [
                IsmChatTapHandler(
                  onTap: () {
                    onCancel != null ? onCancel!() : IsmChatRoute.goBack();
                  },
                  child: Text(
                    resolvedCancelLabel,
                    style: dialogTheme.actionTextStyle,
                  ),
                ),
                if (actionLabels != null) ...[
                  IsmChatDimens.boxWidth8,
                  IsmChatTapHandler(
                    onTap: () {
                      IsmChatRoute.goBack();
                      callbackActions?.first();
                    },
                    child: Text(
                      actionLabels?.first ?? '',
                      style: dialogTheme.actionTextStyle,
                    ),
                  ),
                ],
              ],
            )
          : SimpleDialog(
              backgroundColor: dialogTheme.backgroundColor,
              shape: resolvedShape,
              titlePadding: titlePadding,
              title: Text(
                title,
                style: dialogTheme.titleTextStyle,
              ),
              children: [
                if (content != null)
                  Padding(
                    padding: resolvedContentPadding,
                    child: DefaultTextStyle(
                      style: resolvedContentStyle,
                      child: content!,
                    ),
                  ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ...actionLabels!.map<Widget>((label) {
                      var action =
                          callbackActions![actionLabels!.indexOf(label)];
                      return SimpleDialogOption(
                        child: IsmChatTapHandler(
                          onTap: () {
                            IsmChatRoute.goBack();
                            action.call();
                          },
                          child: Text(
                            label,
                            style: dialogTheme.actionTextStyle,
                          ),
                        ),
                      );
                    }),
                    SimpleDialogOption(
                      child: IsmChatTapHandler(
                        onTap: () {
                          onCancel != null
                              ? onCancel!()
                              : IsmChatRoute.goBack();
                        },
                        child: Text(
                          resolvedCancelLabel,
                          style: dialogTheme.actionTextStyle,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }
}
