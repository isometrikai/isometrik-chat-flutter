import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class CustomeSnackBar extends StatelessWidget {
  const CustomeSnackBar(
      {super.key,
      required this.downloadedFileCount,
      required this.noOfFiles,
      required this.downloadProgress});

  final int downloadedFileCount;
  final int noOfFiles;
  final int downloadProgress;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            IsmChatStrings.downloadingMedia,
            style: IsmChatStyles.w400White16,
          ),
          const Spacer(),
          Text(
            '$downloadedFileCount of $noOfFiles',
            style: IsmChatStyles.w400White16,
          ),
          IsmChatDimens.boxWidth8,
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: IsmChatDimens.forty,
                width: IsmChatDimens.forty,
                child: CircularProgressIndicator(
                  value: downloadProgress / 100,
                  valueColor:
                      const AlwaysStoppedAnimation(IsmChatColors.whiteColor),
                  strokeWidth: IsmChatDimens.three,
                  backgroundColor: IsmChatConfig.chatTheme.primaryColor,
                  color: IsmChatColors.whiteColor,
                ),
              ),
              Text(
                '$downloadProgress%',
                style: IsmChatStyles.w400White12,
              )
            ],
          )
        ],
      );
}
