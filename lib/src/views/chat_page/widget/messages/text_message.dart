import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

class IsmChatTextMessage extends StatelessWidget {
  const IsmChatTextMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: IntrinsicWidth(
          child: Container(
            alignment:
                message.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
            constraints: const BoxConstraints(
              minHeight: 36,
            ),
            padding: IsmChatDimens.edgeInsets4,
            child: RichText(
              text: TextSpan(
                text: message.mentionedUsers.isNullOrEmpty &&
                        message.body.phoneNumerList.isNullOrEmpty
                    ? message.body
                    : null,
                style: message.style,
                children: message.mentionedUsers.isNullOrEmpty &&
                        message.body.phoneNumerList.isNullOrEmpty
                    ? null
                    : message.mentionList
                        .map(
                          (e) => TextSpan(
                            recognizer: TapGestureRecognizer()
                              ..onTap = !(e.isMentioned || e.isPhoneNumber)
                                  ? null
                                  : () async {
                                      if (e.isPhoneNumber) {
                                        await Get.dialog(
                                          IsmChatAlertDialogBox(
                                            title: IsmChatStrings
                                                .thisPhoneNumberNotonChat,
                                            actionLabels: [
                                              '${IsmChatStrings.dial} ${e.text}',
                                              IsmChatStrings.addToContact,
                                            ],
                                            callbackActions: [
                                              () {
                                                IsmChatUtility.dialNumber(
                                                  e.text,
                                                );
                                              },
                                              () async {
                                                final contact = Contact(
                                                    phones: [Phone(e.text)]);
                                                await FlutterContacts
                                                    .openExternalInsert(
                                                        contact);
                                              },
                                            ],
                                          ),
                                        );
                                        return;
                                      }
                                      var user = message.mentionedUsers
                                          ?.where((user) =>
                                              user.userName.toLowerCase() ==
                                              e.text.substring(1).toLowerCase())
                                          .toList();

                                      if (!user.isNullOrEmpty) {
                                        var conversationcontroller = Get.find<
                                            IsmChatConversationsController>();
                                        var conversationId =
                                            conversationcontroller
                                                .getConversationId(
                                                    user!.first.userId);
                                        conversationcontroller.contactDetails =
                                            user.first;
                                        conversationcontroller
                                                .userConversationId =
                                            conversationId;
                                        if (IsmChatResponsive.isWeb(context)) {
                                          conversationcontroller
                                                  .isRenderChatPageaScreen =
                                              IsRenderChatPageScreen
                                                  .userInfoView;
                                        } else {
                                          IsmChatRouteManagement.goToUserInfo(
                                            conversationId: conversationId,
                                            user: user.first,
                                            fromMessagePage: true,
                                          );
                                        }
                                      }
                                    },
                            text: e.text,
                            style: message.style.copyWith(
                              color: e.isMentioned || e.isPhoneNumber
                                  ? message.sentByMe
                                      ? IsmChatConfig.chatTheme.mentionColor
                                      : IsmChatConfig.chatTheme.primaryColor
                                  : null,
                            ),
                          ),
                        )
                        .toList(),
              ),
              softWrap: true,
              maxLines: null,
            ),
          ),
        ),
      );
}
