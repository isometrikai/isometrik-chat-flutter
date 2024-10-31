import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
                style: message.style,
                children: message.mentionList.map(
                  (e) {
                    if (e.isLink) {
                      return TextSpan(
                        text: e.text,
                        style: message.style.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: IsmChatDimens.fifteen,
                          color: IsmChatConfig.chatTheme.mentionColor,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            if (e.isLink) {
                              if (e.text.contains(RegExp(r'^\d{9,13}$'))) {
                                await Get.dialog(
                                  IsmChatAlertDialogBox(
                                    title:
                                        IsmChatStrings.thisPhoneNumberNotonChat,
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
                                        final contact =
                                            Contact(phones: [Phone(e.text)]);
                                        await FlutterContacts
                                            .openExternalInsert(contact);
                                      },
                                    ],
                                  ),
                                );
                              } else if (e.text.contains('@') &&
                                  !e.text.startsWith('@')) {
                                final emailUri =
                                    Uri(scheme: 'mailto', path: e.text);

                                if (await canLaunchUrl(emailUri)) {
                                  await launchUrl(emailUri);
                                }
                              } else if (e.text.startsWith('http') ||
                                  e.text.startsWith('www')) {
                                String? url;
                                if (e.text.startsWith('www')) {
                                  url = 'https://${e.text}';
                                } else {
                                  url = e.text;
                                }

                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                }
                              } else if (e.text.startsWith('@')) {
                                var user = message.mentionedUsers
                                    ?.where((user) => user.userName
                                        .toLowerCase()
                                        .contains(
                                            e.text.substring(1).toLowerCase()))
                                    .toList();

                                if (!user.isNullOrEmpty) {
                                  var conversationcontroller = Get.find<
                                      IsmChatConversationsController>();
                                  var conversationId = conversationcontroller
                                      .getConversationId(user!.first.userId);
                                  conversationcontroller.contactDetails =
                                      user.first;
                                  conversationcontroller.userConversationId =
                                      conversationId;
                                  if (IsmChatResponsive.isWeb(context)) {
                                    conversationcontroller
                                            .isRenderChatPageaScreen =
                                        IsRenderChatPageScreen.userInfoView;
                                  } else {
                                    IsmChatRouteManagement.goToUserInfo(
                                      conversationId: conversationId,
                                      user: user.first,
                                      fromMessagePage: true,
                                    );
                                  }
                                }
                              }
                            }
                          },
                      );
                    } else {
                      return TextSpan(
                        text: e.text,
                        style: message.style,
                      );
                    }
                  },
                ).toList(),
              ),
              softWrap: true,
              maxLines: null,
            ),
          ),
        ),
      );
}

class LinkifyText extends StatelessWidget {
  LinkifyText({super.key, required this.text});
  final String text;

  // Regular expression to detect URLs, phone numbers, emails, and mentions
  final RegExp _linkRegExp = RegExp(
    r'(\bhttps?:\/\/\S+\b|\bwww\.\S+\b|\b\d{9,13}\b|\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b|@[A-Za-z0-9_]+)',
    caseSensitive: false,
  );

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: _linkify(text).map((element) {
            if (element.isLink) {
              return TextSpan(
                text: element.text,
                style: const TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
                recognizer: element.tapGestureRecognizer,
              );
            } else {
              return TextSpan(
                  text: element.text,
                  style: const TextStyle(color: Colors.black));
            }
          }).toList(),
        ),
      );

  List<_LinkElement> _linkify(String text) {
    final matches = _linkRegExp.allMatches(text);
    var lastMatchEnd = 0;
    var elements = <_LinkElement>[];

    for (var match in matches) {
      if (match.start > lastMatchEnd) {
        elements.add(
            _LinkElement(text.substring(lastMatchEnd, match.start), false));
      }

      final linkText = match.group(0)!;
      elements.add(_LinkElement(
        linkText,
        true,
        onTap: () => _handleLinkTap(linkText),
      ));

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      elements.add(_LinkElement(text.substring(lastMatchEnd), false));
    }

    return elements;
  }

  void _handleLinkTap(String link) async {
    if (link.startsWith('@')) {
      // Mention detected
      // Handle mention logic here (e.g., navigate to a user's profile)
      // Here you can implement your logic for mentions
    } else if (link.startsWith('http') || link.startsWith('www')) {
      // URL detected
      if (!link.startsWith('http')) {
        link = 'https://$link'; // Add https if not present
      }
      if (await canLaunchUrl(Uri.parse(link))) {
        await launchUrl(Uri.parse(link));
      }
    }
  }
}

class _LinkElement {
  _LinkElement(this.text, this.isLink, {GestureTapCallback? onTap})
      : tapGestureRecognizer =
            isLink ? (TapGestureRecognizer()..onTap = onTap) : null;
  final String text;
  final bool isLink;
  final GestureRecognizer? tapGestureRecognizer;
}
