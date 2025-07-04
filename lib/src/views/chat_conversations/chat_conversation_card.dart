import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatConversationCard extends StatefulWidget {
  const IsmChatConversationCard(
    this.conversation, {
    this.profileImageBuilder,
    this.nameBuilder,
    this.subtitleBuilder,
    this.onTap,
    this.onLongPress,
    this.name,
    this.profileImageUrl,
    this.subtitle,
    this.trailingBuilder,
    this.trailing,
    this.isShowBackgroundColor,
    this.onProfileTap,
    this.canShowStack,
    super.key,
  });

  final IsmChatConversationModel conversation;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ConversationWidgetCallback? profileImageBuilder;
  final ConversationStringCallback? profileImageUrl;
  final ConversationWidgetCallback? nameBuilder;
  final ConversationStringCallback? name;
  final ConversationWidgetCallback? subtitleBuilder;
  final ConversationStringCallback? subtitle;
  final ConversationWidgetCallback? trailingBuilder;
  final ConversationStringCallback? trailing;
  final bool? isShowBackgroundColor;
  final ConversationVoidCallback? onProfileTap;
  final bool? canShowStack;

  @override
  State<IsmChatConversationCard> createState() =>
      _IsmChatConversationCardState();
}

class _IsmChatConversationCardState extends State<IsmChatConversationCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return IsmChatTapHandler(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: IsmChatResponsive.isWeb(context)
              ? IsmChatUtility.conversationController.currentConversationId ==
                      widget.conversation.conversationId
                  ? IsmChatConfig
                          .chatTheme.chatListCardThemData?.backgroundColor ??
                      IsmChatConfig.chatTheme.primaryColor?.applyIsmOpacity(.2)
                  : null
              : null,
        ),
        padding: IsmChatDimens.edgeInsets15,
        width: IsmChatDimens.percentWidth(1),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: widget.conversation.conversationType ==
                      IsmChatConversationType.open
                  ? null
                  : Alignment.centerRight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  if (widget.conversation.conversationType ==
                      IsmChatConversationType.open) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: IsmChatColors.greyColorLight.applyIsmOpacity(.4),
                        border: Border.all(
                          color: IsmChatColors.whiteColor,
                          width: IsmChatDimens.two,
                        ),
                        borderRadius: BorderRadius.circular(
                          IsmChatDimens.fifty,
                        ),
                      ),
                      height: IsmChatDimens.fifty,
                      width: IsmChatDimens.fifty,
                    ),
                  ] else ...[
                    IsmChatTapHandler(
                      onTap: widget.onProfileTap != null
                          ? () {
                              widget.onProfileTap
                                  ?.call(context, widget.conversation);
                            }
                          : null,
                      child: widget.profileImageBuilder?.call(
                              context,
                              widget.conversation,
                              widget.conversation.profileUrl) ??
                          IsmChatImage.profile(
                            widget.profileImageUrl?.call(
                                    context,
                                    widget.conversation,
                                    widget.conversation.profileUrl) ??
                                widget.conversation.profileUrl,
                            name: widget.conversation.chatName,
                          ),
                    ),
                  ],
                  if (widget.conversation.conversationType ==
                          IsmChatConversationType.open &&
                      (widget.canShowStack ?? true)) ...[
                    Positioned(
                      left: IsmChatDimens.seven,
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              IsmChatColors.greyColorLight.applyIsmOpacity(.4),
                          border: Border.all(
                            color: IsmChatColors.whiteColor,
                            width: IsmChatDimens.two,
                          ),
                          borderRadius: BorderRadius.circular(
                            IsmChatDimens.fifty,
                          ),
                        ),
                        height: IsmChatDimens.fifty,
                        width: IsmChatDimens.fifty,
                      ),
                    ),
                    Positioned(
                      top: IsmChatDimens.two,
                      left: IsmChatDimens.forteen,
                      child: widget.profileImageBuilder?.call(
                              context,
                              widget.conversation,
                              widget.conversation.profileUrl) ??
                          IsmChatImage.profile(
                            widget.profileImageUrl?.call(
                                    context,
                                    widget.conversation,
                                    widget.conversation.profileUrl) ??
                                widget.conversation.profileUrl,
                            name: widget.conversation.chatName,
                            dimensions: IsmChatDimens.fortyFive,
                          ),
                    ),
                  ],
                  if (widget.conversation.conversationType ==
                          IsmChatConversationType.public &&
                      (widget.canShowStack ?? true)) ...[
                    Positioned(
                        bottom: IsmChatDimens.zero,
                        right: IsmChatDimens.zero,
                        child: SvgPicture.asset(IsmChatAssets.publicGroupSvg))
                  ]
                ],
              ),
            ),
            IsmChatDimens.boxWidth12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: widget.nameBuilder?.call(
                            context,
                            widget.conversation,
                            widget.conversation.chatName) ??
                        Text(
                          widget.name?.call(context, widget.conversation,
                                  widget.conversation.chatName) ??
                              widget.conversation.chatName,
                          style: IsmChatConfig.chatTheme.chatListCardThemData
                                  ?.titleTextStyle ??
                              IsmChatStyles.w600Black14,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                  IsmChatDimens.boxHeight2,
                  if (widget.subtitle != null) ...[
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (widget.conversation.lastMessageDetails?.reactionType
                                ?.isEmpty ==
                            true) ...[
                          if (!(widget.conversation.isGroup ?? false)) ...[
                            widget.conversation.readCheck,
                          ],
                          widget.conversation.sender,
                          if (widget.conversation.isGroup ?? false) ...[
                            widget.conversation.readCheck,
                          ],
                          widget.conversation.lastMessageDetails?.icon ??
                              IsmChatDimens.box0,
                          IsmChatDimens.boxWidth4,
                        ],
                        Flexible(
                          child: Text(
                            widget.subtitle?.call(
                                    context,
                                    widget.conversation,
                                    widget.conversation.lastMessageDetails
                                            ?.messageBody ??
                                        '') ??
                                '',
                            style: IsmChatConfig.chatTheme.chatListCardThemData
                                    ?.subTitleTextStyle ??
                                IsmChatStyles.w400Black12.copyWith(
                                  fontStyle: widget.conversation
                                              .lastMessageDetails?.customType ==
                                          IsmChatCustomMessageType
                                              .deletedForEveryone
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  ] else ...[
                    widget.subtitleBuilder?.call(
                            context,
                            widget.conversation,
                            widget.conversation.lastMessageDetails
                                    ?.messageBody ??
                                '') ??
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (widget.conversation.lastMessageDetails
                                    ?.reactionType?.isEmpty ==
                                true) ...[
                              if (!(widget.conversation.isGroup ?? false)) ...[
                                widget.conversation.readCheck,
                              ],
                              widget.conversation.sender,
                              if (widget.conversation.isGroup ?? false) ...[
                                widget.conversation.readCheck,
                              ],
                              widget.conversation.lastMessageDetails?.icon ??
                                  IsmChatDimens.box0,
                              IsmChatDimens.boxWidth4,
                            ],
                            Flexible(
                              child: Text(
                                widget.conversation.lastMessageDetails
                                        ?.messageBody ??
                                    '',
                                style: IsmChatConfig
                                        .chatTheme
                                        .chatListCardThemData
                                        ?.subTitleTextStyle ??
                                    IsmChatStyles.w400Black12.copyWith(
                                      fontStyle: widget
                                                  .conversation
                                                  .lastMessageDetails
                                                  ?.customType ==
                                              IsmChatCustomMessageType
                                                  .deletedForEveryone
                                          ? FontStyle.italic
                                          : FontStyle.normal,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                  ]
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  widget.conversation.lastMessageDetails?.sentAt
                          .toLastMessageTimeString ??
                      '',
                  style: IsmChatConfig
                          .chatTheme.chatListCardThemData?.trailingTextStyle ??
                      IsmChatStyles.w400Black10,
                ),
                IsmChatDimens.boxHeight4,
                if (widget.conversation.unreadMessagesCount != 0) ...[
                  FittedBox(
                    child: CircleAvatar(
                      radius: IsmChatConfig.chatTheme.chatListCardThemData
                              ?.messageCountTheme?.padding ??
                          IsmChatDimens.ten,
                      backgroundColor: IsmChatConfig.chatTheme
                              .chatListCardThemData?.trailingBackgroundColor ??
                          IsmChatConfig.chatTheme.primaryColor ??
                          IsmChatColors.whiteColor,
                      child: Text(
                        (widget.conversation.unreadMessagesCount ?? 0) < 99
                            ? widget.conversation.unreadMessagesCount.toString()
                            : '99+',
                        style: IsmChatConfig.chatTheme.chatListCardThemData
                                ?.messageCountTheme?.textStyle ??
                            IsmChatStyles.w700White10,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ],
        ),
      ),
    );
  }
}
