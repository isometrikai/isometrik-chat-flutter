import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                backgroundColor: IsmChatConfig
                        .chatTheme.chatPageHeaderTheme?.popupBackgroundColor ??
                    IsmChatColors.whiteColor,
                titleTextStyle: IsmChatStyles.w600Black14,
                contentPadding: contentPadding,
                contentTextStyle: contentTextStyle,
                content: content,
                shape:
                    IsmChatConfig.chatTheme.chatPageHeaderTheme?.popupShape ??
                        shape,
                actions: [
                  IsmChatTapHandler(
                    onTap: onCancel ??
                        () {
                          Get.back<void>();
                        },
                    child: Text(
                      cancelLabel,
                      style: IsmChatStyles.w400Black14,
                    ),
                  ),
                  if (actionLabels != null) ...[
                    IsmChatDimens.boxWidth8,
                    IsmChatTapHandler(
                      onTap: () {
                        Get.back<void>();
                        callbackActions!.first();
                      },
                      child: Text(
                        actionLabels!.first,
                        style: IsmChatStyles.w400Black14,
                      ),
                    ),
                  ],
                ],
              )
            : SimpleDialog(
                title: Text(
                  title,
                  style: IsmChatStyles.w600Black14,
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
                              Get.back<void>();
                              action();
                            },
                            child: Text(label),
                          ),
                        );
                      }),
                      SimpleDialogOption(
                        child: IsmChatTapHandler(
                          onTap: onCancel ?? Get.back,
                          child: Text(cancelLabel),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      );
}
