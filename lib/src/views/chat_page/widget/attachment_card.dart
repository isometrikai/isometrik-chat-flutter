import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

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

  @override
  Widget build(BuildContext context) => StatusBarTransparent(
        child: SafeArea(
          child: Container(
            margin: IsmChatDimens.edgeInsets10,
            decoration: BoxDecoration(
              color: IsmChatColors.whiteColor,
              borderRadius: BorderRadius.circular(IsmChatDimens.twentyFour),
            ),
            padding: IsmChatDimens.edgeInsets10,
            height: getWidgetHight(),
            alignment: Alignment.center,
            child: GetBuilder<IsmChatPageController>(
              tag: IsmChat.i.tag,
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
                      onTap: () => controller
                          .onBottomAttachmentTapped(attachment.attachmentType),
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
                            style: IsmChatStyles.w400Black14,
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
      );
}
