import 'package:flutter/material.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatContactMessage extends StatelessWidget {
  const IsmChatContactMessage(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: Container(
          width: message.contacts.length == 1
              ? IsmChatDimens.oneHundredSeventy
              : null,
          decoration: BoxDecoration(
            color: IsmChatConfig.chatTheme.backgroundColor,
            borderRadius: BorderRadius.circular(IsmChatDimens.eight),
          ),
          padding: IsmChatDimens.edgeInsets10,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: message.contacts.length == 1
                        ? IsmChatDimens.fifty
                        : IsmChatDimens.seventy,
                    child: Stack(
                      clipBehavior: Clip.hardEdge,
                      children: List.generate(
                        message.contacts.length <= 3
                            ? message.contacts.length
                            : 3,
                        (index) {
                          var data = message.contacts[index];
                          if (index == 0) {
                            return data.contactImageUrl != null
                                ? IsmChatImage.profile(
                                    backgroundColor: IsmChatColors.blueColor,
                                    data.contactImageUrl ?? '',
                                    name: data.contactName ?? '',
                                    isNetworkImage: false,
                                    isBytes: true,
                                    dimensions: IsmChatDimens.fortyFive,
                                  )
                                : const _NoImageWidget();
                          }

                          return Positioned(
                            left: index * IsmChatDimens.ten,
                            child: data.contactImageUrl != null
                                ? IsmChatImage.profile(
                                    backgroundColor: IsmChatColors.blueColor,
                                    data.contactImageUrl ?? '',
                                    name: data.contactName ?? '',
                                    isNetworkImage: false,
                                    isBytes: true,
                                    dimensions: IsmChatDimens.fortyFive,
                                  )
                                : const _NoImageWidget(),
                          );
                        },
                      ).toList().reversed.toList(),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      message.contacts.length == 1
                          ? message.contacts.first.contactName ?? ''
                          : '${message.contacts.first.contactName} and ${message.contacts.length - 1} other contact',
                      style: IsmChatStyles.w600Black14,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              const Divider(
                thickness: 1,
              ),
              if (!IsmChatResponsive.isWeb(context))
                Center(
                  child: Text(
                    'View ${message.contacts.length != 1 ? 'All' : ''}',
                    style: IsmChatStyles.w600Black12,
                  ),
                )
            ],
          ),
        ),
      );
}

class _NoImageWidget extends StatelessWidget {
  const _NoImageWidget();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(IsmChatDimens.fifty)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(IsmChatDimens.fifty),
          child: Image.asset(
            IsmChatAssets.noImage,
            width: IsmChatDimens.thirty,
            height: IsmChatDimens.thirty,
          ),
        ),
      );
}
