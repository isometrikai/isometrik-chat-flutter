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
        tag: IsmChat.i.chatPageTag,
        builder: (controller) {
          final textFieldTheme =
              IsmChatThemeResolver.textFieldFromConfig(context);
          final panelColor = textFieldTheme.emojiBoardBackgroundColor ??
              textFieldTheme.backgroundColor ??
              IsmChatColors.whiteColor;
          final categoryIconColor =
              textFieldTheme.emojiBoardCategoryIconColor ??
                  IsmChatColors.greyColor;
          final actionIconColor = textFieldTheme.emojiBoardActionIconColor ??
              IsmChatColors.blackColor;
          final primaryColor = IsmChatConfig.chatTheme.primaryColor ??
              IsmChatColors.primaryColorLight;
          final isDark =
              IsmChatThemeResolver.brightness(context) == Brightness.dark;

          return ColoredBox(
            color: panelColor,
            child: SizedBox(
              height: IsmChatDimens.twoHundredFifty,
              child: EmojiPicker(
                textEditingController: controller.chatInputController,
                onEmojiSelected: (category, emoji) {
                  IsmChatLog.error(emoji.toJson());
                },
                config: Config(
                  bottomActionBarConfig: BottomActionBarConfig(
                    showBackspaceButton: true,
                    enabled: true,
                    buttonIconColor: actionIconColor,
                    buttonColor: panelColor,
                    backgroundColor: panelColor,
                  ),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: panelColor,
                    indicatorColor: primaryColor,
                    iconColor: categoryIconColor,
                    iconColorSelected:
                        textFieldTheme.emojiColor ?? primaryColor,
                    backspaceColor: primaryColor,
                    dividerColor: isDark
                        ? IsmChatColors.greyColor
                        : IsmChatColors.greyColorLight,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: panelColor,
                    buttonIconColor: categoryIconColor,
                    hintTextStyle: textFieldTheme.hintTextStyle,
                    inputTextStyle: textFieldTheme.inputTextStyle,
                  ),
                  skinToneConfig: SkinToneConfig(
                    dialogBackgroundColor: panelColor,
                    indicatorColor: primaryColor,
                  ),
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: IsmChatDimens.twentyFour,
                    columns: 8,
                    backgroundColor: panelColor,
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
        },
      );
}
