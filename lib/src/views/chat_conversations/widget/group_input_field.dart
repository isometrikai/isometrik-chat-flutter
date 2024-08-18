import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class GroupInputField extends StatelessWidget {
  const GroupInputField({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
        builder: (controller) => SizedBox(
          width: IsmChatDimens.percentWidth(.9),
          child: TextFormField(
            textCapitalization: TextCapitalization.sentences,
            controller: controller.addGrouNameController,
            decoration: InputDecoration(
              hintText: 'Write your group name',
              hintStyle: IsmChatStyles.w400Grey12,
              contentPadding: IsmChatDimens.edgeInsets10,
              isDense: true,
              isCollapsed: true,
              filled: true,
              fillColor: IsmChatTheme.of(context).backgroundColor,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                borderSide: const BorderSide(color: Colors.transparent),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(IsmChatDimens.ten),
                borderSide: const BorderSide(
                  color: Colors.transparent,
                ),
              ),
            ),
            onChanged: (_) {},
          ),
        ),
      );
}
