import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class ProfileChange extends StatelessWidget {
  const ProfileChange({super.key});

  @override
  Widget build(BuildContext context) =>
      GetBuilder<IsmChatConversationsController>(
          builder: (controller) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () async {
                      Get.back();
                      final chatpageController =
                          Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
                      await controller.ismChangeImage(ImageSource.camera);
                      await chatpageController.changeGroupProfile(
                        conversationImageUrl: controller.profileImage,
                        conversationId:
                            chatpageController.conversation?.conversationId ??
                                '',
                        isLoading: true,
                      );
                    },
                    child: Padding(
                      padding: IsmChatDimens.edgeInsets10_0,
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blueAccent,
                            ),
                            width: IsmChatDimens.forty,
                            height: IsmChatDimens.forty,
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: IsmChatColors.whiteColor,
                            ),
                          ),
                          IsmChatDimens.boxWidth8,
                          Text(
                            IsmChatStrings.camera,
                            style: IsmChatStyles.w500Black16,
                          )
                        ],
                      ),
                    ),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () async {
                      Get.back();
                      final chatpageController =
                          Get.find<IsmChatPageController>(tag: IsmChat.i.tag);
                      await controller.ismChangeImage(ImageSource.gallery);
                      await chatpageController.changeGroupProfile(
                        conversationImageUrl: controller.profileImage,
                        conversationId:
                            chatpageController.conversation?.conversationId ??
                                '',
                        isLoading: true,
                      );
                    },
                    child: Padding(
                      padding: IsmChatDimens.edgeInsets10_0,
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.purpleAccent,
                            ),
                            width: IsmChatDimens.forty,
                            height: IsmChatDimens.forty,
                            child: const Icon(
                              Icons.photo_rounded,
                              color: IsmChatColors.whiteColor,
                            ),
                          ),
                          IsmChatDimens.boxWidth8,
                          Text(
                            IsmChatStrings.gallery,
                            style: IsmChatStyles.w500Black16,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: Get.back,
                  isDestructiveAction: true,
                  child: Text(
                    IsmChatStrings.cancel,
                    style: IsmChatStyles.w600Black16,
                  ),
                ),
              ));
}
