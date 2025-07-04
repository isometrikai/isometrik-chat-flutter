import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatAlertDialogBox extends StatelessWidget {
  const IsmChatAlertDialogBox({
    super.key,
    this.title = 'Are you sure?',
    this.actionLabels,
    this.callbackActions,
    this.cancelLabel = IsmChatStrings.cancel,
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
  final String cancelLabel;
  final VoidCallback? onCancel;
  final Widget? content;
  final TextStyle? contentTextStyle;
  final ShapeBorder? shape;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) => StatusBarTransparent(
        child: (actionLabels?.length ?? 0) <= 1
            ? AlertDialog(
                actionsPadding: IsmChatDimens.edgeInsets16,
                title: Text(title),
                backgroundColor:
                    IsmChatConfig.chatTheme.dialogTheme?.backgroundColor ??
                        IsmChatColors.whiteColor,
                titleTextStyle:
                    IsmChatConfig.chatTheme.dialogTheme?.titleTextStyle ??
                        IsmChatStyles.w600Black14,
                contentPadding:
                    IsmChatConfig.chatTheme.dialogTheme?.insetPadding ??
                        contentPadding,
                contentTextStyle:
                    IsmChatConfig.chatTheme.dialogTheme?.contentTextStyle ??
                        contentTextStyle,
                content: content,
                shape: IsmChatConfig.chatTheme.dialogTheme?.shape ?? shape,
                actions: [
                  IsmChatTapHandler(
                    onTap: () {
                      onCancel ?? IsmChatRoute.goBack();
                    },
                    child: Text(
                      cancelLabel,
                      style: IsmChatConfig
                              .chatTheme.dialogTheme?.actionTextStyle ??
                          IsmChatStyles.w400Black14,
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
                        style: IsmChatConfig
                                .chatTheme.dialogTheme?.actionTextStyle ??
                            IsmChatStyles.w400Black14,
                      ),
                    ),
                  ],
                ],
              )
            : SimpleDialog(
                title: Text(
                  title,
                  style: IsmChatConfig.chatTheme.dialogTheme?.titleTextStyle ??
                      IsmChatStyles.w600Black14,
                ),
                children: [
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
                              style: IsmChatConfig
                                      .chatTheme.dialogTheme?.actionTextStyle ??
                                  IsmChatStyles.w400Black14,
                            ),
                          ),
                        );
                      }),
                      SimpleDialogOption(
                        child: IsmChatTapHandler(
                          onTap: () {
                            onCancel ?? IsmChatRoute.goBack();
                          },
                          child: Text(
                            cancelLabel,
                            style: IsmChatConfig
                                    .chatTheme.dialogTheme?.actionTextStyle ??
                                IsmChatStyles.w400Black14,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );
}
