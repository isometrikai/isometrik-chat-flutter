import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Emoji, GIF, and sticker panel shown above the message composer.
class EmojiBoard extends StatelessWidget {
  const EmojiBoard({super.key});

  bool get _showGiphyPicker {
    final apiKey =
        IsmChatProperties.chatPageProperties.giphyApiKey?.trim() ?? '';
    return apiKey.isNotEmpty &&
        IsmChatProperties.chatPageProperties.features
            .contains(IsmChatFeature.giphyPicker);
  }

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
          final showGiphy = _showGiphyPicker;

          return ColoredBox(
            color: panelColor,
            child: SizedBox(
              height: IsmChatDimens.twoHundredFifty,
              child: Column(
                children: [
                  if (showGiphy) ...[
                    Obx(
                      () => Row(
                        children: [
                          _PanelTab(
                            label: 'Emoji',
                            selected: controller.emojiBoardTab ==
                                IsmChatEmojiBoardTab.emoji,
                            onTap: () => controller.emojiBoardTab =
                                IsmChatEmojiBoardTab.emoji,
                            primaryColor: primaryColor,
                            textStyle: textFieldTheme.inputTextStyle,
                          ),
                          _PanelTab(
                            label: IsmChatStrings.gif,
                            selected: controller.emojiBoardTab ==
                                IsmChatEmojiBoardTab.gif,
                            onTap: () => controller.emojiBoardTab =
                                IsmChatEmojiBoardTab.gif,
                            primaryColor: primaryColor,
                            textStyle: textFieldTheme.inputTextStyle,
                          ),
                          _PanelTab(
                            label: IsmChatStrings.sticker,
                            selected: controller.emojiBoardTab ==
                                IsmChatEmojiBoardTab.sticker,
                            onTap: () => controller.emojiBoardTab =
                                IsmChatEmojiBoardTab.sticker,
                            primaryColor: primaryColor,
                            textStyle: textFieldTheme.inputTextStyle,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                  Expanded(
                    child: showGiphy
                        ? Obx(() {
                            switch (controller.emojiBoardTab) {
                              case IsmChatEmojiBoardTab.gif:
                                return const GiphyPickerPanel(
                                  key: ValueKey('ism_giphy_gif_panel'),
                                  stickers: false,
                                );
                              case IsmChatEmojiBoardTab.sticker:
                                return const GiphyPickerPanel(
                                  key: ValueKey('ism_giphy_sticker_panel'),
                                  stickers: true,
                                );
                              case IsmChatEmojiBoardTab.emoji:
                                return _EmojiPickerView(
                                  key: const ValueKey('ism_emoji_panel'),
                                  controller: controller,
                                  panelColor: panelColor,
                                  categoryIconColor: categoryIconColor,
                                  actionIconColor: actionIconColor,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                  textFieldTheme: textFieldTheme,
                                );
                            }
                          })
                        : _EmojiPickerView(
                            controller: controller,
                            panelColor: panelColor,
                            categoryIconColor: categoryIconColor,
                            actionIconColor: actionIconColor,
                            primaryColor: primaryColor,
                            isDark: isDark,
                            textFieldTheme: textFieldTheme,
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class _PanelTab extends StatelessWidget {
  const _PanelTab({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.primaryColor,
    required this.textStyle,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color primaryColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) => Expanded(
        child: IsmChatTapHandler(
          onTap: onTap,
          child: Container(
            padding: IsmChatDimens.edgeInsets12,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              label,
              style: textStyle?.copyWith(
                color: selected ? primaryColor : IsmChatColors.greyColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      );
}

class _EmojiPickerView extends StatelessWidget {
  const _EmojiPickerView({
    super.key,
    required this.controller,
    required this.panelColor,
    required this.categoryIconColor,
    required this.actionIconColor,
    required this.primaryColor,
    required this.isDark,
    required this.textFieldTheme,
  });

  final IsmChatPageController controller;
  final Color panelColor;
  final Color categoryIconColor;
  final Color actionIconColor;
  final Color primaryColor;
  final bool isDark;
  final IsmChatTextFiledTheme textFieldTheme;

  @override
  Widget build(BuildContext context) => EmojiPicker(
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
            iconColorSelected: textFieldTheme.emojiColor ?? primaryColor,
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
          final value = controller.chatInputController.text;
          if (value.isEmpty) {
            return;
          }
          controller.chatInputController.text =
              value.substring(0, value.length - 1);
        },
      );
}
