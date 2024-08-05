import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:isometrik_flutter_chat/src/utilities/blob_io.dart'
    if (dart.library.html) 'package:isometrik_flutter_chat/src/utilities/blob_html.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class SendMessageIntent extends Intent {
  const SendMessageIntent();
}

class IsmChatMessageField extends StatelessWidget {
  const IsmChatMessageField({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) {
          var messageBody = controller.getMessageBody(controller.replayMessage);
          return Row(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (controller.isEnableRecordingAudio) ...[
                Expanded(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    padding: IsmChatDimens.edgeInsets20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IsmChatTapHandler(
                          onTap: () {
                            controller.recordDelete();
                          },
                          child: Icon(
                            Icons.delete_outlined,
                            size: IsmChatDimens.thirty,
                            color: IsmChatConfig.chatTheme.primaryColor ??
                                IsmChatColors.blackColor,
                          ),
                        ),
                        IsmChatDimens.boxWidth12,
                        IsmChatTapHandler(
                          onTap: () async {
                            await controller.recordPlayPauseVoice();
                          },
                          child: Icon(
                            controller.isRecordPlay
                                ? Icons.pause_circle_outline_outlined
                                : Icons.play_circle_outline_outlined,
                            size: IsmChatDimens.thirty,
                            color: IsmChatConfig.chatTheme.primaryColor ??
                                IsmChatColors.blackColor,
                          ),
                        ),
                        IsmChatDimens.boxWidth12,
                        const Icon(
                          Icons.radio_button_checked_outlined,
                          color: Colors.red,
                        ),
                        IsmChatDimens.boxWidth32,
                        Text(
                            controller.seconds
                                .getTimerRecord(controller.seconds),
                            style: IsmChatStyles.w600Black20),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                if (IsmChatResponsive.isWeb(context)) ...[
                  IsmChatDimens.boxWidth8,
                  Container(
                    margin: IsmChatDimens.edgeInsetsBottom4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: IsmChatConfig.chatTheme.primaryColor,
                    ),
                    child: const _EmojiButton(IsmChatColors.whiteColor),
                  ),
                  IsmChatDimens.boxWidth8,
                  if (IsmChatProperties
                      .chatPageProperties.attachments.isNotEmpty)
                    Container(
                      margin: IsmChatDimens.edgeInsetsBottom4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: IsmChatConfig.chatTheme.primaryColor,
                      ),
                      child: _AttachmentIconForWeb(
                        IsmChatConfig.chatTheme.primaryColor,
                      ),
                    ),
                  IsmChatDimens.boxWidth2,
                ],
                Expanded(
                  child: Shortcuts(
                    shortcuts: {
                      LogicalKeySet(
                        LogicalKeyboardKey.enter,
                        // LogicalKeyboardKey.newKey,
                      ): const SendMessageIntent(),
                    },
                    child: Actions(
                      actions: {
                        SendMessageIntent: CallbackAction<SendMessageIntent>(
                            onInvoke: (SendMessageIntent intent) async {
                          if (controller.showSendButton) {
                            if (!(controller.conversation?.isChattingAllowed ==
                                true)) {
                              controller.showDialogCheckBlockUnBlock();
                            } else {
                              await controller.getMentionedUserList(
                                  controller.chatInputController.text.trim());
                              if (controller.chatInputController.text
                                      .trim()
                                      .isNotEmpty &&
                                  controller.isMessageSent == false) {
                                controller.isMessageSent = true;
                                controller.sendTextMessage(
                                  conversationId:
                                      controller.conversation?.conversationId ??
                                          '',
                                  userId: controller.conversation
                                          ?.opponentDetails?.userId ??
                                      '',
                                );
                              }
                            }
                          }
                          return null;
                        }),
                      },
                      child: Focus(
                        autofocus: true,
                        child: Container(
                          margin: IsmChatDimens.edgeInsets4.copyWith(
                              bottom: controller.isreplying
                                  ? IsmChatDimens.twelve
                                  : IsmChatDimens.eight),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: IsmChatConfig.chatTheme.chatPageTheme
                                      ?.textFiledThemData?.borderColor ??
                                  IsmChatConfig.chatTheme.primaryColor!,
                            ),
                            borderRadius:
                                BorderRadius.circular(IsmChatDimens.twenty),
                            color: IsmChatConfig.chatTheme.chatPageTheme
                                    ?.textFiledThemData?.backgroundColor ??
                                IsmChatConfig.chatTheme.backgroundColor,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (controller.isreplying)
                                _ReplyMessage(
                                  messageBody: messageBody,
                                ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      enableSuggestions: false,
                                      style: IsmChatConfig
                                          .chatTheme
                                          .chatPageTheme
                                          ?.textFiledThemData
                                          ?.inputTextStyle,
                                      maxLines: 4,
                                      minLines: 1,
                                      focusNode:
                                          controller.messageFieldFocusNode,
                                      controller:
                                          controller.chatInputController,
                                      cursorColor: IsmChatConfig
                                              .chatTheme
                                              .chatPageTheme
                                              ?.textFiledThemData
                                              ?.cursorColor ??
                                          IsmChatConfig.chatTheme.primaryColor,
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      decoration: InputDecoration(
                                        hintText: IsmChatStrings.hintText,
                                        hintStyle: IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.textFiledThemData
                                                ?.hintTextStyle ??
                                            IsmChatStyles.w400Black12,
                                        isDense: true,
                                        filled: true,
                                        fillColor: IsmChatConfig
                                                .chatTheme
                                                .chatPageTheme
                                                ?.textFiledThemData
                                                ?.backgroundColor ??
                                            IsmChatConfig
                                                .chatTheme.backgroundColor,
                                        contentPadding:
                                            IsmChatResponsive.isWeb(context)
                                                ? IsmChatDimens.edgeInsets12
                                                : IsmChatDimens.edgeInsets8,
                                        prefixIcon:
                                            IsmChatResponsive.isWeb(context)
                                                ? null
                                                : _EmojiButton(IsmChatConfig
                                                    .chatTheme
                                                    .chatPageTheme
                                                    ?.textFiledThemData
                                                    ?.emojiColor),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              IsmChatDimens.twenty),
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            IsmChatDimens.twenty,
                                          ),
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          ),
                                        ),
                                      ),
                                      onChanged: (_) {
                                        if ((controller
                                                    .conversation
                                                    ?.conversationId
                                                    ?.isNotEmpty ??
                                                false) &&
                                            controller
                                                    .conversation?.customType !=
                                                IsmChatStrings.broadcast) {
                                          controller.notifyTyping();
                                          controller.showMentionsUserList(_);
                                        }
                                      },
                                    ),
                                  ),
                                  if (IsmChatProperties.chatPageProperties
                                          .attachments.isNotEmpty &&
                                      !IsmChatResponsive.isWeb(context)) ...[
                                    const _AttachmentIcon()
                                  ]
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const _MicOrSendButton(),
              IsmChatDimens.boxWidth4,
            ],
          );
        },
      );
}

class _ReplyMessage extends StatelessWidget {
  _ReplyMessage({
    required this.messageBody,
  }) : controller = Get.find<IsmChatPageController>();

  final String messageBody;
  final IsmChatPageController controller;

  @override
  Widget build(BuildContext context) => Container(
        margin: IsmChatDimens.edgeInsets4.copyWith(
          bottom: IsmChatDimens.zero,
        ),
        padding: IsmChatDimens.edgeInsets8,
        width: Get.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            IsmChatDimens.sixteen,
          ),
          color: IsmChatConfig.chatTheme.primaryColor!.withOpacity(.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.replayMessage?.sentByMe ?? false
                      ? IsmChatStrings.you
                      : IsmChatProperties.chatPageProperties.header?.title
                              ?.call(context, controller.conversation!,
                                  controller.conversation!.chatName) ??
                          controller.conversation?.chatName.capitalizeFirst ??
                          '',
                  style: IsmChatStyles.w600White14,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * 0.7,
                  ),
                  child: Text(
                    messageBody,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            IsmChatTapHandler(
              onTap: () {
                controller.isreplying = false;
              },
              child: Icon(
                Icons.close_rounded,
                size: IsmChatDimens.sixteen,
              ),
            ),
          ],
        ),
      );
}

class _EmojiButton extends StatelessWidget {
  const _EmojiButton(this.color);
  final Color? color;

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => IconButton(
          color: color ?? IsmChatConfig.chatTheme.primaryColor,
          icon: AnimatedSwitcher(
            duration: IsmChatConfig.animationDuration,
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: animation,
              child: child,
            ),
            child: controller.showEmojiBoard
                ? Icon(
                    Icons.keyboard_rounded,
                    key: UniqueKey(),
                  )
                : IsmChatProperties.chatPageProperties.emojiIcon ??
                    Icon(
                      Icons.emoji_emotions_rounded,
                      key: UniqueKey(),
                    ),
          ),
          onPressed: () {
            if (!(controller.conversation?.isChattingAllowed == true)) {
              controller.showDialogCheckBlockUnBlock();
            } else {
              controller.toggleEmojiBoard();
            }
          },
        ),
      );
}

class _MicOrSendButton extends StatelessWidget {
  const _MicOrSendButton();
  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: IsmChatConfig.chatTheme.chatPageTheme?.sendButtonThemData
                    ?.backgroundColor ??
                IsmChatConfig.chatTheme.primaryColor,
          ),
          child: IconButton(
            onPressed: () async {
              if (!(controller.conversation?.isChattingAllowed == true)) {
                controller.showDialogCheckBlockUnBlock();
                return;
              }

              if (controller.showSendButton) {
                if (controller.isEnableRecordingAudio) {
                  var audioPath = await controller.recordVoice.stop() ?? '';
                  controller.forRecordTimer?.cancel();
                  controller.showSendButton = false;
                  controller.isEnableRecordingAudio = false;
                  String? sizeMedia;
                  WebMediaModel? webMediaModel;
                  if (await IsmChatProperties.chatPageProperties
                          .messageAllowedConfig?.isMessgeAllowed
                          ?.call(
                              Get.context!,
                              Get.find<IsmChatPageController>()
                                  .conversation!) ??
                      true) {
                    if (kIsWeb) {
                      var bytes =
                          await IsmChatUtility.fetchBytesFromBlobUrl(audioPath);

                      sizeMedia = await IsmChatUtility.bytesToSize(bytes);
                      webMediaModel = WebMediaModel(
                        platformFile: IsmchPlatformFile(
                          name: '${DateTime.now().millisecondsSinceEpoch}.mp3',
                          size: bytes.length,
                          bytes: bytes,
                          path: audioPath,
                          extension: 'mp3',
                        ),
                        isVideo: false,
                        thumbnailBytes: Uint8List(0),
                        dataSize: sizeMedia,
                        duration: Duration(
                          seconds: controller.seconds,
                        ),
                      );
                    } else {
                      sizeMedia =
                          await IsmChatUtility.fileToSize(File(audioPath));
                    }

                    if (sizeMedia.size()) {
                      controller.sendAudio(
                        webMediaModel: webMediaModel,
                        path: audioPath,
                        conversationId:
                            controller.conversation?.conversationId ?? '',
                        userId:
                            controller.conversation?.opponentDetails?.userId ??
                                '',
                        duration: Duration(seconds: controller.seconds),
                      );
                      controller.seconds = 0;
                    } else {
                      await Get.dialog(
                        const IsmChatAlertDialogBox(
                          title: IsmChatStrings.youCanNotSend,
                          cancelLabel: IsmChatStrings.okay,
                        ),
                      );
                    }
                  }
                } else {
                  if (await IsmChatProperties.chatPageProperties
                          .messageAllowedConfig?.isMessgeAllowed
                          ?.call(
                              Get.context!,
                              Get.find<IsmChatPageController>()
                                  .conversation!) ??
                      true) {
                    await controller.getMentionedUserList(
                        controller.chatInputController.text.trim());
                    if (controller.chatInputController.text.trim().isNotEmpty &&
                        controller.isMessageSent == false) {
                      controller.isMessageSent = true;
                      controller.sendTextMessage(
                        conversationId:
                            controller.conversation?.conversationId ?? '',
                        userId:
                            controller.conversation?.opponentDetails?.userId ??
                                '',
                      );
                    }
                  }
                }
              } else {
                if (controller.showEmojiBoard) {
                  controller.toggleEmojiBoard();
                }
                if (!(await IsmChatProperties
                        .chatPageProperties.isSendMediaAllowed
                        ?.call(context, controller.conversation!) ??
                    true)) {
                  return;
                }
                var allowPermission = false;
                if (kIsWeb) {
                  final state = await IsmChatBlob.checkPermission('microphone');
                  if (state == 'prompt') {
                    unawaited(Get.dialog(
                      const IsmChatAlertDialogBox(
                        title: IsmChatStrings.micePermission,
                        cancelLabel: IsmChatStrings.okay,
                      ),
                    ));
                    await controller.recordVoice.hasPermission();
                    return;
                  } else if (state == 'denied') {
                    await Get.dialog(
                      const IsmChatAlertDialogBox(
                        title: IsmChatStrings.micePermissionBlock,
                        cancelLabel: IsmChatStrings.okay,
                      ),
                    );
                  } else {
                    allowPermission = true;
                  }
                } else {
                  if (await controller.recordVoice.hasPermission()) {
                    allowPermission = true;
                  }
                }
                if (allowPermission) {
                  if (!(controller
                              .conversation?.lastMessageDetails?.customType ==
                          IsmChatCustomMessageType.removeMember &&
                      controller.conversation?.lastMessageDetails?.userId ==
                          IsmChatConfig
                              .communicationConfig.userConfig.userId)) {
                    controller.isEnableRecordingAudio = true;
                    controller.showSendButton = true;
                    controller.forRecordTimer =
                        Timer.periodic(const Duration(seconds: 1), (_) {
                      controller.seconds++;
                    });
                    String? audioPath;
                    if (!kIsWeb) {
                      final dir = await getApplicationDocumentsDirectory();
                      audioPath = p.join(
                        dir.path,
                        'audio_${DateTime.now().millisecondsSinceEpoch}.m4a',
                      );
                    } else {
                      audioPath =
                          'audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
                    }

                    if (!kIsWeb) {
                      const encoder = AudioEncoder.aacLc;
                      if (!await controller.isEncoderSupported(encoder)) {
                        return;
                      }
                      final devs =
                          await controller.recordVoice.listInputDevices();
                      IsmChatLog.info(devs.toString());
                      const config =
                          RecordConfig(encoder: encoder, numChannels: 1);
                      await controller.recordVoice.start(
                        config,
                        path: audioPath,
                      );
                    } else {
                      await controller.recordVoice.start(
                        const RecordConfig(encoder: AudioEncoder.wav),
                        path: audioPath,
                      );
                    }
                  }
                }
              }
            },
            icon: AnimatedSwitcher(
              duration: IsmChatConfig.animationDuration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: controller.showSendButton
                  ? Icon(
                      Icons.send_rounded,
                      key: UniqueKey(),
                      color: IsmChatColors.whiteColor,
                    )
                  : Icon(
                      Icons.mic_rounded,
                      key: UniqueKey(),
                      color: IsmChatColors.whiteColor,
                    ),
            ),
          ),
        ),
      );
}

class _AttachmentIconForWeb extends StatefulWidget {
  const _AttachmentIconForWeb(this.backgroundColor);

  final Color? backgroundColor;

  @override
  State<_AttachmentIconForWeb> createState() => _AttachmentIconForWebState();
}

class _AttachmentIconForWebState extends State<_AttachmentIconForWeb>
    with TickerProviderStateMixin {
  final controller = Get.find<IsmChatPageController>();
  final layerLink = LayerLink();

  late Animation<double> curve;
  late Animation<double> _buttonAnimation;
  int? toolTipIndex;

  @override
  void initState() {
    toolTipIndex = null;
    controller.fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    curve = CurvedAnimation(
      parent: controller.fabAnimationController!,
      curve: Curves.easeInOut,
    );

    _buttonAnimation = Tween<double>(
      begin: 10,
      end: 0,
    ).animate(curve);
    super.initState();
  }

  void _toggle(BuildContext context) async {
    controller.textEditingController.clear();
    if (controller.showAttachment) {
      showOverLay(context);
    } else {
      await controller.fabAnimationController?.reverse();
      if (controller.fabAnimationController?.isDismissed == true) {
        controller.attchmentOverlayEntry?.remove();
      }
    }
  }

  showOverLay(BuildContext context) async {
    final renderBox = context.findRenderObject() as RenderBox?;
    final size = renderBox!.size;
    OverlayState? overlayState = Overlay.of(context);
    controller.attchmentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: size.height + IsmChatDimens.twenty,
        child: CompositedTransformFollower(
          offset: Offset(-IsmChatDimens.one,
              -(IsmChatDimens.oneHundredFifty + IsmChatDimens.thirty)),
          showWhenUnlinked: false,
          link: layerLink,
          child: Material(
            color: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                IsmChatProperties.chatPageProperties.attachments.length * 2 - 1,
                (i) {
                  if (i % 2 != 0) {
                    return IsmChatDimens.boxHeight10;
                  }
                  var index = i ~/ 2;
                  var data =
                      IsmChatProperties.chatPageProperties.attachments[index];
                  return Transform(
                    transform: Matrix4.translationValues(
                      0.0,
                      _buttonAnimation.value * (index + 1),
                      0.0,
                    ),
                    child: SizedBox(
                      width: IsmChatDimens.oneHundredFifty,
                      child: InkWell(
                        hoverColor: Colors.transparent,
                        onHover: (value) {
                          if (value) {
                            toolTipIndex = index;
                          } else {
                            toolTipIndex = null;
                          }
                          overlayState.setState(() {});
                        },
                        onTap: () {
                          controller.showAttachment =
                              !controller.showAttachment;
                          _toggle(context);
                          controller.onBottomAttachmentTapped(data);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: IsmChatDimens.edgeInsets10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: IsmChatConfig.chatTheme.primaryColor,
                              ),
                              child: Icon(
                                data.iconData,
                                color: IsmChatColors.whiteColor,
                              ),
                            ),
                            // CircleAvatar(
                            //   radius: IsmChatDimens.twenty + IsmChatDimens.two,
                            //   backgroundColor:
                            //       IsmChatConfig.chatTheme.primaryColor,
                            //   child: Icon(
                            //     data.iconData,
                            //     color: IsmChatColors.whiteColor,
                            //   ),
                            // ),
                            if (toolTipIndex == index) ...[
                              IsmChatDimens.boxWidth4,
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: IsmChatColors.blackColor),
                                  borderRadius:
                                      BorderRadius.circular(IsmChatDimens.ten),
                                  color: IsmChatColors.whiteColor,
                                ),
                                width: IsmChatDimens.ninty,
                                height: IsmChatDimens.thirty,
                                child: Text(
                                  data.name.capitalizeFirst.toString(),
                                  style: IsmChatStyles.w400Black14,
                                ),
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    controller.fabAnimationController?.addListener(() {
      overlayState.setState(() {});
    });

    overlayState.insert(controller.attchmentOverlayEntry!);
    await controller.fabAnimationController?.forward();
  }

  @override
  Widget build(BuildContext context) => GetX<IsmChatPageController>(
        builder: (controller) => CompositedTransformTarget(
          link: layerLink,
          child: IconButton(
            color: IsmChatColors.whiteColor,
            icon: AnimatedSwitcher(
              duration: IsmChatConfig.animationDuration,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: controller.showAttachment
                  ? Icon(
                      Icons.close_rounded,
                      key: UniqueKey(),
                    )
                  : Icon(
                      Icons.attachment_rounded,
                      key: UniqueKey(),
                    ),
            ),
            onPressed: () {
              if (!(controller.conversation?.isChattingAllowed == true)) {
                controller.showDialogCheckBlockUnBlock();
              } else {
                controller.showAttachment = !controller.showAttachment;
                _toggle(context);
              }
            },
          ),
        ),
      );
}

class _AttachmentIcon extends GetView<IsmChatPageController> {
  const _AttachmentIcon();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (IsmChatProperties.chatPageProperties.messageFieldSuffix !=
              null) ...[
            IsmChatProperties.chatPageProperties.messageFieldSuffix?.call(
                    context,
                    controller.conversation!,
                    controller.conversation?.isChattingAllowed == true) ??
                IsmChatDimens.box0
          ],
          IconButton(
            onPressed: () async {
              if (!(controller.conversation?.isChattingAllowed == true)) {
                controller.showDialogCheckBlockUnBlock();
              } else {
                if (await IsmChatProperties
                        .chatPageProperties.isSendMediaAllowed
                        ?.call(context, controller.conversation!) ??
                    true) {
                  await Get.bottomSheet(
                    const IsmChatAttachmentCard(),
                    enterBottomSheetDuration:
                        IsmChatConstants.bottomSheetDuration,
                    exitBottomSheetDuration:
                        IsmChatConstants.bottomSheetDuration,
                    elevation: 0,
                  );
                }
              }
            },
            color: IsmChatConfig.chatTheme.chatPageTheme?.textFiledThemData
                    ?.attchmentColor ??
                IsmChatConfig.chatTheme.primaryColor,
            icon: const Icon(Icons.attach_file_rounded),
          ),
        ],
      );
}
