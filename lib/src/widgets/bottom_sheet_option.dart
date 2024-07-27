import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatBottomSheet extends StatelessWidget {
  const IsmChatBottomSheet({
    super.key,
    required this.onClearTap,
    required this.onDeleteTap,
  });

  final VoidCallback onClearTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmChatDimens.edgeInsetsBottom10,
        child: Container(
          margin: IsmChatDimens.edgeInsets10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: IsmChatColors.whiteColor,
                  borderRadius: BorderRadius.circular(IsmChatDimens.twenty),
                ),
                padding: IsmChatDimens.edgeInsets20,
                width: Get.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Get.back<void>();
                        onClearTap.call();
                      },
                      child: Text(
                        IsmChatStrings.clearChat,
                        overflow: TextOverflow.ellipsis,
                        style: IsmChatStyles.w600Black16,
                      ),
                    ),
                    IsmChatDimens.boxHeight16,
                    InkWell(
                      onTap: () {
                        Get.back<void>();
                        onDeleteTap.call();
                      },
                      child: Text(
                        IsmChatStrings.deleteChat,
                        overflow: TextOverflow.ellipsis,
                        style: IsmChatStyles.w600Black16,
                      ),
                    ),
                  ],
                ),
              ),
              IsmChatDimens.boxHeight4,
              InkWell(
                onTap: Get.back,
                child: Container(
                  padding: IsmChatDimens.edgeInsets10,
                  decoration: BoxDecoration(
                    color: IsmChatColors.whiteColor,
                    borderRadius: BorderRadius.circular(IsmChatDimens.twenty),
                  ),
                  child: Center(
                    child: Text(
                      IsmChatStrings.cancel,
                      style: IsmChatStyles.w600Black16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

@protected
class IsmChatProfilePhotoBottomSheet extends StatelessWidget {
  const IsmChatProfilePhotoBottomSheet({
    super.key,
    required this.onGalleryTap,
    required this.onCameraTap,
  });

  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: onCameraTap,
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
            onPressed: onGalleryTap,
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
          child: const Text('Cancel'),
        ),
      );
}
