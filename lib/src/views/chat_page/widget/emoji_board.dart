import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// The `EmojiBoard` widget is a Flutter component that provides a visual representation
/// of an emoji board, allowing users to select and insert emojis into their desired context.
///
/// It offers a grid-based layout with scrollable functionality, ensuring an intuitive and engaging user experience.
class EmojiBoard extends StatelessWidget {
  const EmojiBoard({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<IsmChatPageController>(
        tag: IsmChat.i.tag,
        builder: (controller) => SizedBox(
          height: IsmChatDimens.twoHundredFifty,
          child: EmojiPicker(
            textEditingController: controller.chatInputController,
            config: Config(
              bottomActionBarConfig: BottomActionBarConfig(
                showBackspaceButton: true,
                enabled: true,
                // customBottomActionBar: (config, state, showSearchView) {
                // },
                buttonIconColor: IsmChatColors.blackColor,
                buttonColor: IsmChatConfig.chatTheme.backgroundColor ??
                    IsmChatColors.whiteColor,
                backgroundColor: IsmChatConfig.chatTheme.backgroundColor ??
                    IsmChatColors.whiteColor,
              ),
              categoryViewConfig: CategoryViewConfig(
                indicatorColor: IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
                iconColorSelected: IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
                backspaceColor: IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
              ),
              skinToneConfig: SkinToneConfig(
                dialogBackgroundColor:
                    IsmChatConfig.chatTheme.backgroundColor ??
                        IsmChatColors.whiteColor,
                indicatorColor: IsmChatConfig.chatTheme.primaryColor ??
                    IsmChatColors.primaryColorLight,
              ),
              emojiViewConfig: EmojiViewConfig(
                emojiSizeMax: IsmChatDimens.twentyFour,
                columns: 8,
                backgroundColor: IsmChatConfig.chatTheme.backgroundColor ??
                    IsmChatColors.whiteColor,
              ),
            ),
            onBackspacePressed: () {
              controller.chatInputController.text = controller
                  .chatInputController.text
                  .substring(0, controller.chatInputController.text.length);
            },
          ),
        ),
      );
}
