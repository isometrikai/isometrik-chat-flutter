import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Attachment picker bottom sheet content.
///
/// Uses [IsmChatConfig.chatTheme.chatPageTheme.attachmentCardTheme]; rebuilds on
/// theme change via [Obx] + [Get.isDarkMode].
class IsmChatAttachmentCard extends StatelessWidget {
  const IsmChatAttachmentCard({super.key});

  double getWidgetHight() {
    var maxPerLine = IsmChatProperties
            .chatPageProperties.attachmentConfig?.attachmentShowperLine ??
        IsmChatConstants.attachmentShowLine;
    var height = IsmChatProperties
            .chatPageProperties.attachmentConfig?.attachmentHight ??
        IsmChatConstants.attachmentHight;
    var result =
        (IsmChatProperties.chatPageProperties.attachments.length / maxPerLine)
            .ceil();

    var x = (result * height).toDouble();
    return x;
  }

  IsmChatAttachmentCardTheme _attachmentCardTheme() =>
      IsmChatConfig.chatTheme.chatPageTheme?.attachmentCardTheme ??
      (Get.isDarkMode
          ? IsmChatAttachmentCardTheme.dark()
          : IsmChatAttachmentCardTheme.light());

  @override
  Widget build(BuildContext context) => Obx(() {
        final _ = Get.isDarkMode;
        final cardTheme = _attachmentCardTheme();
        return ColoredBox(
          color: cardTheme.backgroundColor,
          child: SafeArea(
            child: Padding(
              padding: IsmChatDimens.edgeInsets10,
              child: SizedBox(
                height: getWidgetHight(),
                child: GetBuilder<IsmChatPageController>(
                  tag: IsmChat.i.chatPageTag,
                  builder: (controller) {
                    var allowedAttachments = controller.attachments
                        .where((e) => IsmChatProperties
                            .chatPageProperties.attachments
                            .contains(e.attachmentType))
                        .toList();

                    return GridView.builder(
                      itemCount: allowedAttachments.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: IsmChatDimens.eight,
                        mainAxisSpacing: IsmChatDimens.four,
                      ),
                      itemBuilder: (_, index) {
                        var attachment = allowedAttachments[index];
                        return IsmChatTapHandler(
                          onTap: () {
                            IsmChatRoute.goBack();
                            controller.onBottomAttachmentTapped(
                                attachment.attachmentType);
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: IsmChatDimens.fifty,
                                width: IsmChatDimens.fifty,
                                decoration: BoxDecoration(
                                  color: attachment.backgroundColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  attachment.icon,
                                  color: IsmChatColors.whiteColor,
                                ),
                              ),
                              IsmChatDimens.boxHeight4,
                              Text(
                                attachment.label,
                                style: cardTheme.labelTextStyle,
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        );
      });
}
