import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter_example/controllers/controllers.dart';
import 'package:isometrik_chat_flutter_example/res/res.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  static const String route = AppRoutes.chatList;

  @override
  Widget build(BuildContext context) => GetBuilder<ChatListController>(
        initState: (state) {
          if (!Get.isRegistered<ChatListController>()) {
            ChatConversationBinding().dependencies();
          }
        },
        builder: (controller) {
          return Scaffold(
            body: IsmChatApp(
              context: context,
              // conversationParser: (conversation, data) {
              //   AppLog(conversation);
              //   AppLog.info('checkData $data');
              //   return true;
              // },
              chatTheme: IsmChatThemeData(
                chatListCardThemData: IsmChatListCardTheme(iconSize: 16),
                // cardBackgroundColor: const Color(0xFF292030),
                // backgroundColor: const Color(0xFF292030),
                chatPageHeaderTheme: IsmChatHeaderTheme(),
                primaryColor: AppColors.primaryColorLight,
                // chatPageHeaderTheme: IsmChatHeaderThemeData(
                //   iconColor: Colors.red,
                // ),
                chatPageTheme: IsmChatPageTheme(
                  centerMessageTheme:
                      const IsmChatCenterMessageTheme(textColor: Colors.white),
                  // Mobile: widen bubbles to 80% of screen (SDK default is 60%).
                  // Web keeps SDK defaults when this is null.
                  messageConstraints: IsmChatResponsive.isWeb(context)
                      ? null
                      : IsmChatMessageConstraints(
                          messageConstraints: BoxConstraints(
                            maxWidth: context.width * .8,
                            minWidth: context.width * .25,
                          ),
                        ),
                  // Bubble padding for all message types (text, audio, media,
                  // location, contact, …). Bottom ≥ 20 leaves room for time/status.
                  // contactMessagePadding: const EdgeInsets.all(10),
                  // backgroundColor: const Color(0xFF292030),
                  selfMessageTheme: IsmChatMessageTheme(
                      borderColor: Colors.grey, linkPreviewColor: Colors.white

                      // showProfile: ShowProfile(
                      //   isShowProfile: true,
                      //   isPostionBottom: false,
                      // ),
                      ),

                  opponentMessageTheme: IsmChatMessageTheme(
                    borderColor: AppColors.primaryColorLight,
                    linkPreviewColor: Colors.black,
                    // showProfile: ShowProfile(
                    //   isShowProfile: true,
                    //   isPostionBottom: false,
                    // ),
                  ),
                ),
              ),

              chatPageProperties: IsmChatPageProperties(
                // Giphy: free API key from https://developers.giphy.com/
                giphyApiKey: 'oXf5IF53KmB99uHRcNDOkwUpxyAAAk7Y',
                // features: [..., IsmChatFeature.giphyPicker, IsmChatFeature.emojiIcon],
                // Configure the interval for periodic conversation details API calls
                // Default is 1 minute. You can customize it as needed:
                conversationDetailsApiInterval:
                    Duration(seconds: 30), // Every 30 seconds
                // Host-app custom UI for conversationCreated (affiliate intro card).
                // Returns null → SDK keeps its default production UI.
                conversationCreatedMessageBuilder:
                    (context, message, conversation) {
                  return _AffiliateConversationCreatedMessage.buildIfNeeded(
                    message: message,
                    conversation: conversation,
                  );
                },
                // Host-app custom composer. Comment out to restore SDK default.
                // Host chat input area — see docs/HOST_CUSTOM_COMPOSER.md
                // chatInputAreaBuilder: (context, conversation, defaultComposer) {
                //   return Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [YourStrip(...), defaultComposer],
                //   );
                // },
                // backgroundImageUrl: AssetConstants.background,
                // isShowMessageBlur: (p0, p1) => true,
                // stackWidget: Container(
                //   alignment: Alignment.center,
                //   color: IsmChatColors.greenColor,
                //   child: const Text('Stack '),
                // ),
                // isShowMediaMeessageBlure: (p0, p1) => true,
                // isAllowedDeleteChatFromLocal: true,
                // onCoverstaionStatus: (p0, conversation) {
                //   IsmChatLog.error(conversation.usersOwnDetails?.isDeleted);
                // },
                // onCallBlockUnblock: (p0, p1, p2) async {
                //   IsmChatLog.error(p2);
                //   return true;
                // },

                header: IsmChatPageHeaderProperties(
                    // Sticky banner under AppBar — see docs/HOST_CUSTOM_COMPOSER.md
                    // height: (context, conversation) =>
                    //     IsmChatDimens.appBarHeight + 40,
                    // bottom: (context, conversation) {
                    //   return YourStickyBanner();
                    // },
                    ),
                // meessageFieldFocusNode: (_, coverstaion, value) {
                //   IsmChatLog.info(value);
                //   controller.isBottomVisibile = !controller.isBottomVisibile;
                //   controller.update();
                // },

                placeholder: IsmChatEmptyView(
                  icon: Icon(
                    Icons.chat_outlined,
                    size: IsmChatDimens.fifty,
                    color: IsmChatColors.greyColor,
                  ),
                  text: 'No Messages',
                ),
                // onMessageTap: (p0, message, _) async {
                //   return (<String, dynamic>{}, false);
                // },
                attachments: const [
                  IsmChatAttachmentType.camera,
                  IsmChatAttachmentType.gallery,
                  IsmChatAttachmentType.document,
                  if (!kIsWeb) IsmChatAttachmentType.location,
                  if (!kIsWeb) IsmChatAttachmentType.contact,
                ],

                // features: [
                //   IsmChatFeature.reply,
                //   IsmChatFeature.showMessageStatus,
                //   IsmChatFeature.audioMessage,
                //   IsmChatFeature.emojiIcon,
                // ],
              ),

              noChatSelectedPlaceholder: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      IsmChatAssets.placeHolderSvg,
                    ),
                    Text(
                      'Isometrik Chat',
                      style: IsmChatStyles.w600Black27,
                    ),
                    SizedBox(
                      width: IsmChatDimens.percentWidth(.5),
                      child: Text(
                        'Isometrik web chat is fully sync with mobile isomterik chat , all charts are synced when connected to the network',
                        style: IsmChatStyles.w400Black12,
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              conversationProperties: IsmChatConversationProperties(
                conversationPosition: IsmChatConversationPosition.menu,
                allowedConversations: [
                  IsmChatConversationType.private,
                  IsmChatConversationType.public,
                  IsmChatConversationType.open,
                ],
                showCreateChatIcon: true,
                enableGroupChat: true,
                allowDelete: true,
                onCreateTap: () {},
                shouldShowAppBar:
                    IsmChatResponsive.isWeb(context) ? false : true,
                header: Column(
                  children: [
                    IsmChatListHeader(
                      onSignOut: () {
                        controller.onSignOut();
                      },
                      onSearchTap: (p0, p1, p2) {},
                      showSearch: false,
                      width: IsmChatResponsive.isWeb(context)
                          ? IsmChatDimens.percentWidth(.3)
                          : null,
                    ),
                  ],
                ),
                placeholder: const IsmChatEmptyView(
                  text: 'Create conversation',
                  icon: Icon(
                    Icons.add_circle_outline_outlined,
                    size: 70,
                    color: AppColors.primaryColorLight,
                  ),
                ),
                isSlidableEnable: (_, conversation) {
                  return true;
                },

                // cardElementBuilders: const IsmChatCardProperties(
                // onProfileTap: (p0, p1) {
                //   IsmChatLog.error('Yes i am tap');
                // },
                // )

                // endActionSlidableEnable: (p0, p1) => true,
                // startActionSlidableEnable: (p0, p1) => true,
                // conversationPredicate: (e) =>
                //     e.chatName.toLowerCase().startsWith('t'),

                opponentSubTitle: (_, opponent) {
                  // Show online/last seen status based on lastSeen
                  if (opponent?.online ?? false) {
                    return IsmChatStrings.online;
                  } else {
                    final lastSeenTimestamp = opponent?.lastSeen;
                    if (lastSeenTimestamp != null) {
                      return lastSeenTimestamp.toCurrentTimeStirng();
                    }
                  }

                  // Fallback to about text if no last seen info available
                  return opponent?.metaData?.aboutText?.title == null
                      ? 'Hey there! I am using IsoChat'
                      : opponent?.metaData?.aboutText?.title ?? '';
                },
              ),
            ),
          );
        },
      );
}

/// Example host composer (optional). Prefer `chatInputAreaBuilder` —
/// see docs/HOST_CUSTOM_COMPOSER.md.
// ignore: unused_element
class _ExampleHostComposer extends StatelessWidget {
  const _ExampleHostComposer();

  static const _navy = Color(0xFF1B3A6B);

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        tag: IsmChat.i.chatPageTag,
        builder: (controller) {
          final input = controller.chatInputController;

          return Material(
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isreplying) ...[
                      _ReplyBanner(
                        body: controller.replayMessage?.body ?? '',
                        onClose: IsmChat.i.cancelComposerReply,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Row(
                      children: [
                        _CircleAction(
                          icon: Icons.add,
                          onTap: () =>
                              IsmChat.i.openComposerAttachments(context),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ListenableBuilder(
                            listenable: input,
                            builder: (_, __) => TextField(
                              controller: input,
                              focusNode: IsmChat.i.chatInputFocusNode,
                              minLines: 1,
                              maxLines: 4,
                              textCapitalization: TextCapitalization.sentences,
                              onChanged: IsmChat.i.onComposerTextChanged,
                              decoration: InputDecoration(
                                hintText: 'Message',
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 15,
                                ),
                                isDense: true,
                                filled: true,
                                fillColor: const Color(0xFFF0F0F0),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ListenableBuilder(
                          listenable: input,
                          builder: (_, __) => _CircleAction(
                            icon: Icons.send_rounded,
                            onTap: input.text.trim().isEmpty
                                ? null
                                : () => IsmChat.i.sendComposerText(),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: onTap == null
            ? _ExampleHostComposer._navy.withValues(alpha: 0.4)
            : _ExampleHostComposer._navy,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      );
}

class _ReplyBanner extends StatelessWidget {
  const _ReplyBanner({
    required this.body,
    required this.onClose,
  });

  final String body;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: const Icon(Icons.close, size: 18),
            ),
          ],
        ),
      );
}

/// Example host-app UI for affiliate `conversationCreated` messages.
///
/// Shown only when:
/// - `metaData.isAffiliateIncluded == true`
/// - `metaData.affiliateIsometrikUserId` exists in conversation members
///
/// Otherwise returns `null` so SDK default UI is used.
class _AffiliateConversationCreatedMessage extends StatelessWidget {
  const _AffiliateConversationCreatedMessage({
    required this.message,
    required this.affiliate,
    required this.membersLabel,
  });

  final IsmChatMessageModel message;
  final UserDetails affiliate;
  final String membersLabel;

  static Widget? buildIfNeeded({
    required IsmChatMessageModel message,
    required IsmChatConversationModel? conversation,
  }) {
    final meta = conversation?.metaData?.customMetaData ??
        message.metaData?.customMetaData;
    if (meta == null) return null;

    final isAffiliateIncluded = meta['isAffiliateIncluded'] == true;
    final affiliateId =
        (meta['affiliateIsometrikUserId'] as String?)?.trim() ?? '';
    if (!isAffiliateIncluded || affiliateId.isEmpty) return null;

    final members = conversation?.members ?? const <UserDetails>[];
    UserDetails? affiliate;
    for (final member in members) {
      if (member.userId.trim() == affiliateId ||
          (member.memberId?.trim() ?? '') == affiliateId) {
        affiliate = member;
        break;
      }
    }
    if (affiliate == null) return null;

    return _AffiliateConversationCreatedMessage(
      message: message,
      affiliate: affiliate,
      membersLabel: _membersLabel(members),
    );
  }

  static String _membersLabel(List<UserDetails> members) {
    final currentUserId =
        IsmChatConfig.communicationConfig.userConfig.userId.trim();
    final otherNames = members
        .where((m) => m.userId.trim() != currentUserId)
        .map((m) {
          final name = m.userName.trim().isNotEmpty
              ? m.userName.trim()
              : (m.memberName ?? '').trim();
          return name;
        })
        .where((name) => name.isNotEmpty)
        .toList();

    if (otherNames.isEmpty) return 'You';
    if (otherNames.length == 1) return '${otherNames.first} & You';
    return '${otherNames.join(', ')} & You';
  }

  @override
  Widget build(BuildContext context) {
    final name = affiliate.userName.trim().isNotEmpty
        ? affiliate.userName.trim()
        : (affiliate.memberName ?? '').trim();
    final displayName = name.isNotEmpty ? name : 'Affiliate Manager';
    final about = affiliate.metaData?.aboutText?.title?.trim();
    final intro = (about != null && about.isNotEmpty)
        ? about
        : "Hi both — I'm $displayName, Affiliate Manager. "
            'Looping in to help coordinate timing on this one.';
    final dateLabel = message.sentAt.toMessageDateString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IsmChatImage.profile(
                  affiliate.profileUrl,
                  name: displayName,
                  dimensions: 40,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AFFILIATE MANAGER',
                        style: TextStyle(
                          color: Color(0xFFB45309),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        intro,
                        style: const TextStyle(
                          color: Color(0xFF292524),
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Group created · $membersLabel · $dateLabel',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
