import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class IsmChatTextMessage extends StatelessWidget {
  IsmChatTextMessage(this.message, {super.key});

  final IsmChatMessageModel message;

  final isExpandedNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: IntrinsicWidth(
          child: BlurFilter.widget(
            isBlured: IsmChatProperties.chatPageProperties.isShowMessageBlur
                    ?.call(context, message) ??
                false,
            child: Container(
              alignment: message.sentByMe
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              constraints: BoxConstraints(
                minHeight: (IsmChatResponsive.isWeb(context))
                    ? context.height * .04
                    : context.height * .05,
              ),
              padding: IsmChatDimens.edgeInsets4,
              child: message.metaData?.isOnelyEmoji == true
                  ? BouncingEmoji(message: message)
                  : ValueListenableBuilder<bool>(
                      valueListenable: isExpandedNotifier,
                      builder: (context, isExpanded, _) => Column(
                            crossAxisAlignment: message.sentByMe
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: message.style,
                                  children: message.mentionList.map(
                                    (e) {
                                      if (e.isLink) {
                                        return TextSpan(
                                          text: e.text,
                                          style: message.style.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: IsmChatConfig
                                                .chatTheme.mentionColor,
                                          ),
                                          recognizer: TapGestureRecognizer()
                                            ..onTap = () async {
                                              if (e.isLink) {
                                                if (e.text.contains(
                                                    RegExp(r'^\d{9,13}$'))) {
                                                  await IsmChatContextWidget
                                                      .showDialogContext(
                                                    content:
                                                        IsmChatAlertDialogBox(
                                                      title: IsmChatStrings
                                                          .thisPhoneNumberNotonChat,
                                                      actionLabels: [
                                                        '${IsmChatStrings.dial} ${e.text}',
                                                        IsmChatStrings
                                                            .addToContact,
                                                      ],
                                                      callbackActions: [
                                                        () {
                                                          IsmChatUtility
                                                              .dialNumber(
                                                            e.text,
                                                          );
                                                        },
                                                        () async {
                                                          final contact =
                                                              Contact(phones: [
                                                            Phone(e.text)
                                                          ]);
                                                          await FlutterContacts
                                                              .openExternalInsert(
                                                                  contact);
                                                        },
                                                      ],
                                                    ),
                                                  );
                                                } else if (e.text
                                                        .contains('@') &&
                                                    !e.text.startsWith('@')) {
                                                  final emailUri = Uri(
                                                      scheme: 'mailto',
                                                      path: e.text);

                                                  if (await canLaunchUrl(
                                                      emailUri)) {
                                                    await launchUrl(emailUri);
                                                  }
                                                } else if (e.text
                                                        .startsWith('http') ||
                                                    e.text.startsWith('www')) {
                                                  String? url;
                                                  if (e.text
                                                      .startsWith('www')) {
                                                    url = 'https://${e.text}';
                                                  } else {
                                                    url = e.text;
                                                  }

                                                  if (await canLaunchUrl(
                                                      Uri.parse(url))) {
                                                    await launchUrl(
                                                        Uri.parse(url));
                                                  }
                                                } else if (e.text
                                                    .startsWith('@')) {
                                                  var user = message
                                                      .mentionedUsers
                                                      ?.where((user) => user
                                                          .userName
                                                          .toLowerCase()
                                                          .contains(e.text
                                                              .substring(1)
                                                              .toLowerCase()))
                                                      .toList();

                                                  if (!user.isNullOrEmpty) {
                                                    var conversationcontroller =
                                                        IsmChatUtility
                                                            .conversationController;
                                                    var conversationId =
                                                        conversationcontroller
                                                            .getConversationId(
                                                                user!.first
                                                                    .userId);
                                                    conversationcontroller
                                                            .contactDetails =
                                                        user.first;
                                                    conversationcontroller
                                                            .userConversationId =
                                                        conversationId;
                                                    if (IsmChatResponsive.isWeb(
                                                        context)) {
                                                      conversationcontroller
                                                              .isRenderChatPageaScreen =
                                                          IsRenderChatPageScreen
                                                              .userInfoView;
                                                    } else {
                                                      await IsmChatRoute
                                                          .goToRoute(
                                                        IsmChatUserInfo(
                                                          conversationId:
                                                              conversationId,
                                                          user: user.first,
                                                          fromMessagePage: true,
                                                        ),
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
                                maxLines: isExpanded ? null : 15,
                                overflow: isExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                              ),
                              if (_isTextOverflowing(context))
                                TextButton(
                                  style: TextButton.styleFrom(
                                      padding: IsmChatDimens.edgeInsets0,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap),
                                  onPressed: () {
                                    isExpandedNotifier.value = !isExpanded;
                                  },
                                  child: Text(
                                    isExpanded ? 'Show less' : 'Show more',
                                    style: message.readTextStyle,
                                  ),
                                ),
                            ],
                          )),
            ),
          ),
        ),
      );

  bool _isTextOverflowing(BuildContext context) {
    final textSpan = TextSpan(
      style: message.style,
      children: message.mentionList
          .map((e) => TextSpan(
                text: e.text,
                style: e.isLink
                    ? message.style.copyWith(
                        fontWeight: FontWeight.bold,
                        color: IsmChatConfig.chatTheme.mentionColor,
                      )
                    : message.style,
              ))
          .toList(),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 15,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: context.width * 0.7);

    return textPainter.didExceedMaxLines;
  }
}

class BouncingEmoji extends StatefulWidget {
  const BouncingEmoji({super.key, required this.message});
  final IsmChatMessageModel message;

  @override
  State<BouncingEmoji> createState() => _BouncingEmojiState();
}

class _BouncingEmojiState extends State<BouncingEmoji>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _animation;
  bool isMoerThanOneEmoji = false;

  @override
  void initState() {
    super.initState();
    isMoerThanOneEmoji = widget.message.body.length > 2;
    if (!isMoerThanOneEmoji) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      )..repeat(reverse: true);
      _animation = Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller!, curve: Curves.easeInOut),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMoerThanOneEmoji) {
      return Text(
        widget.message.body,
        style: widget.message.style.copyWith(
          fontSize: IsmChatDimens.thirty,
        ),
      );
    }
    return ScaleTransition(
      scale: _animation!,
      child: Text(
        widget.message.body,
        style: widget.message.style.copyWith(
          fontSize: IsmChatDimens.fortyFive,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
