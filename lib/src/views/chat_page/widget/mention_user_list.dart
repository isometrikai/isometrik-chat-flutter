import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/src/controllers/chat_page/chat_page_controller.dart';
import 'package:isometrik_flutter_chat/src/res/res.dart';
import 'package:isometrik_flutter_chat/src/utilities/utilities.dart';
import 'package:isometrik_flutter_chat/src/widgets/widgets.dart';

class MentionUserList extends StatelessWidget {
  const MentionUserList({super.key});

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => AnimatedContainer(
          curve: Curves.easeInOut,
          duration: IsmChatConfig.animationDuration,
          margin: IsmChatDimens.edgeInsetsLeft10,
          decoration: BoxDecoration(
            border: Border.all(color: IsmChatConfig.chatTheme.primaryColor!),
            borderRadius: BorderRadius.circular(IsmChatDimens.sixteen),
            color: IsmChatColors.whiteColor,
          ),
          height: controller.mentionSuggestions.isEmpty
              ? IsmChatDimens.zero
              // ? IsmChatDimens.percentHeight(0.08)
              : controller.mentionSuggestions.take(4).length *
                  IsmChatDimens.percentHeight(0.07),
          width: IsmChatResponsive.isWeb(context)
              ? IsmChatDimens.percentWidth(.4)
              : IsmChatDimens.percentWidth(.8),
          child: controller.mentionSuggestions.isEmpty
              ? const SizedBox.shrink()
              : ListView.separated(
                  shrinkWrap: true,
                  padding: IsmChatDimens.edgeInsets0_4,
                  separatorBuilder: (_, index) => IsmChatDimens.box0,
                  itemCount: controller.mentionSuggestions.length,
                  itemBuilder: (_, index) {
                    var member = controller.mentionSuggestions[index];
                    return IsmChatTapHandler(
                      onTap: () {
                        controller.updateMentionUser(member.userName);
                      },
                      child: ListTile(
                        mouseCursor: SystemMouseCursors.click,
                        dense: true,
                        horizontalTitleGap: IsmChatDimens.ten,
                        title: Text(
                          member.userName.capitalizeFirst ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: IsmChatStyles.w600Black13,
                        ),
                        leading: IsmChatImage.profile(
                          member.profileUrl,
                          dimensions: IsmChatDimens.thirtyTwo,
                        ),
                      ),
                    );
                  },
                ),
        ),
      );
}
