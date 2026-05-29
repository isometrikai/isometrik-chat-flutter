import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatContactMessage extends StatelessWidget {
  const IsmChatContactMessage(
    this.message, {
    super.key,
  });

  final IsmChatMessageModel message;

  Widget _defaultAvatar(IsmChatContactMetaDatModel data) {
    final hasImage = (data.contactImageUrl?.isNotEmpty ?? false);
    if (hasImage) {
      return IsmChatImage.profile(
        backgroundColor: IsmChatColors.blueColor,
        data.contactImageUrl ?? '',
        name: data.contactName ?? '',
        isNetworkImage: false,
        isBytes: true,
        dimensions: IsmChatDimens.fortyFive,
      );
    }
    return const _NoImageWidget();
  }

  @override
  Widget build(BuildContext context) {
    final data = IsmChatProperties.chatPageProperties.isShowMessageBlur
        ?.call(context, message);
    return Material(
      color: Colors.transparent,
      child: BlurFilter.widget(
        isBlured: data?.shouldBlured ?? false,
        sigmaX: data?.sigmaX ?? 3,
        sigmaY: data?.sigmaY ?? 3,
        child: Container(
          width: message.contacts.length == 1
              ? IsmChatDimens.oneHundredSeventy
              : null,
          decoration: BoxDecoration(
            color: message.backgroundColor?.applyIsmOpacity(.5),
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
                          final customAvatar = IsmChatProperties
                              .chatPageProperties.contactMessageAvatarBuilder
                              ?.call(context, data);
                          final avatar = customAvatar ?? _defaultAvatar(data);
                          if (index == 0) {
                            return avatar;
                          }

                          return Positioned(
                            left: index * IsmChatDimens.ten,
                            child: avatar,
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
                      style:
                          message.style.copyWith(fontWeight: FontWeight.w600),
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
                    style: message.style.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: IsmChatDimens.twelve),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
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
