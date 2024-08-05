import 'dart:convert';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

extension ScaffoldExtenstion on Scaffold {
  Widget withUnfocusGestureDetctor(BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: this,
      );
}

extension NullCheck<T> on Iterable<T>? {
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;
}

extension NullStringExtension on String? {
  bool get isNullOrEmpty => this == null || (this?.trim() ?? '').isEmpty;
}

extension MatchString on String {
  bool didMatch(String other) => toLowerCase().contains(other.toLowerCase());

  String get convertToValidUrl =>
      'https://${replaceAll('http://', '').replaceAll('https://', '')}';

  bool get isValidUrl =>
      toLowerCase().contains('https') ||
      toLowerCase().contains('http') ||
      toLowerCase().contains('www');

  bool get isAlphabet => RegExp(r'^[A-Za-z]+$').hasMatch(this);

  List<String> get phoneNumerList {
    var exp =
        RegExp(r'[+]?[(]?[0-9]{2,3}[)]?[\-\s\.]?[0-9]{2,5}[\-\s\.]?[0-9]{4,5}');
    var matches = exp.allMatches(this);
    var phoneNumerList = <String>[];
    for (var match in matches) {
      phoneNumerList.add(substring(match.start, match.end));
    }
    return phoneNumerList;
  }
}

extension MessagePagination on int {
  int pagination(
      {int endValue = 20,
      bool notEqualPagination = false,
      int increaseValue = 20}) {
    if (this == 0) {
      return this;
    }

    if (this <= endValue && notEqualPagination == false) {
      return endValue;
    }
    endValue = endValue + increaseValue;
    return pagination(endValue: endValue);
  }

  // int limitPagination({
  //   int value = 30,
  // }) {
  //   if (this == 0) {
  //     return this;
  //   }
  //   if (this <=value) {
  //     return value;
  //   }
  //   value = value + 20;
  //   return pagination(endValue: value);
  // }
}

extension DistanceLatLng on LatLng {
  double getDistance(LatLng other) {
    var lat1 = latitude,
        lon1 = longitude,
        lat2 = other.latitude,
        lon2 = other.longitude;
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }
}

extension DurationExtensions on Duration {
  String formatDuration() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    var twoDigitMinutes = twoDigits(inMinutes.remainder(60));
    var twoDigitSeconds = twoDigits(inSeconds.remainder(60));
    var hour = num.parse(twoDigits(inHours));
    if (hour > 0) {
      return '${twoDigits(inHours)}:$twoDigitMinutes:$twoDigitSeconds';
    } else {
      return '$twoDigitMinutes:$twoDigitSeconds';
    }
  }

  List<double> get waveSamples {
    var number = (inMilliseconds ~/ 30).clamp(100, 150).toInt();
    var random = Random();
    return List.generate(number, (i) => (random.nextInt(130) + 30).toDouble());
  }

  String get formatFullDuration {
    var h = inHours.toString().padLeft(2, '0');
    var m = (inMinutes % 60).toString().padLeft(2, '0');
    var s = (inSeconds % 60).toString().padLeft(2, '0');
    if (h != '00') {
      h = '$h Hours';
    }
    if (m != '00') {
      m = '$m Mins';
    }
    if (s != '00') {
      s = '$s Secs';
    }
    return [h, m, s].where((e) => e != '00').join(' ');
  }
}

extension IntToTimeLeft on int {
  String getTimerRecord(int value) {
    int h, m, s;
    h = value ~/ 3600;
    m = (value - h * 3600) ~/ 60;
    s = value - (h * 3600) - (m * 60);
    var minuteLeft = m.toString().length < 2 ? '0$m' : m.toString();
    var secondsLeft = s.toString().length < 2 ? '0$s' : s.toString();
    var result = '$minuteLeft:$secondsLeft';
    return result;
  }
}

extension FlashIcon on FlashMode {
  IconData get icon {
    switch (this) {
      case FlashMode.off:
        return Icons.flash_off_rounded;
      case FlashMode.auto:
        return Icons.flash_auto_rounded;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on_rounded;
    }
  }
}

extension DateConvertor on int {
  DateTime toDate() => DateTime.fromMillisecondsSinceEpoch(this);

  String toTimeString() =>
      DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(this));

  String toCurrentTimeStirng() {
    if (this == 0 || this == -1) {
      return IsmChatStrings.tapInfo;
    }
    final timeStamp = toDate().removeTime();
    final now = DateTime.now().removeTime();

    if (now.day == timeStamp.day) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.today} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate())}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.yestarday} ${IsmChatStrings.at} ${DateFormat.jm().format(toDate())}';
    }
    if (now.difference(timeStamp) <= const Duration(days: 7)) {
      return '${IsmChatStrings.lastSeen} ${IsmChatStrings.at} ${DateFormat('E h:mm a').format(toDate())}';
    }
    return '${IsmChatStrings.lastSeen} ${IsmChatStrings.on} ${DateFormat('MMM d, yyyy h:mm a').format(toDate())}';
  }

  String toLastMessageTimeString() {
    if (this == 0 || this == -1) {
      return '';
    }
    final timeStamp = toDate().removeTime();
    final now = DateTime.now().removeTime();
    if (now.day == timeStamp.day) {
      return DateFormat.jm().format(toDate());
    }
    if (now.difference(timeStamp) <= const Duration(days: 1)) {
      return IsmChatStrings.yestarday.capitalizeFirst!;
    }
    return DateFormat('dd/MM/yyyy').format(toDate());
  }

  String get weekDayString {
    if (this > 7 || this < 1) {
      throw const IsmChatInvalidWeekdayNumber('Value should be between 1 & 7');
    }
    var weekDays = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday',
    };
    return weekDays[this]!;
  }

  String toMessageDateString() {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now();
    var date = toDate();
    if (now.isSameDay(date)) {
      return 'Today';
    }
    if (now.isSameMonth(date)) {
      if (now.day - date.day == 1) {
        return 'Yesterday';
      }
      if (now.difference(date) < const Duration(days: 8)) {
        return date.weekday.weekDayString;
      }
      return date.toDateString();
    }
    return date.toDateString();
  }

  String toMessageMonthString() {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now();
    var date = toDate();

    if (now.isSameDay(date)) {
      return 'Today';
    } else if (now.difference(date) < const Duration(days: 8)) {
      return date.weekday.weekDayString;
    }
    return date.toDateString();
  }

  String get deliverTime {
    if (this == 0 || this == -1) {
      return '';
    }
    var now = DateTime.now();
    var timestamp = toDate();
    late DateFormat dateFormat;
    if (now.difference(timestamp) > const Duration(days: 365)) {
      dateFormat = DateFormat('EEEE, MMM d, yyyy');
    } else if (now.difference(timestamp) > const Duration(days: 7)) {
      dateFormat = DateFormat('E, d MMM yyyy, hh:mm:ss aa');
    } else {
      dateFormat = DateFormat('EEEE  hh:mm:ss aa');
    }

    return dateFormat.format(timestamp);
  }

  String get getTime {
    final timeStamp = DateTime.fromMillisecondsSinceEpoch(this);
    final time = DateFormat.jm().format(timeStamp);
    final monthDay = DateFormat.MMMd().format(timeStamp);
    return '$monthDay, $time';
  }
}

extension DateFormats on DateTime {
  String toTimeString() => DateFormat.jm().format(this);

  bool isSameDay(DateTime other) => isSameMonth(other) && day == other.day;

  bool isSameMonth(DateTime other) =>
      year == other.year && month == other.month;

  String toDateString() => DateFormat('dd MMM yyyy').format(this);

  DateTime removeTime() => DateTime(year, month, day);
}

extension ChildWidget on IsmChatCustomMessageType {
  bool get canCopy => [
        IsmChatCustomMessageType.text,
        IsmChatCustomMessageType.link,
        IsmChatCustomMessageType.location,
        IsmChatCustomMessageType.reply,
      ].contains(this);
}

extension LastMessageWidget on String {
  Widget lastMessageType(LastMessageDetails message) {
    switch (this) {
      case 'Image':
        return Row(
          children: [
            Icon(
              Icons.image,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Image',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Video':
        return Row(
          children: [
            Icon(
              Icons.video_call,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Video',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Audio':
        return Row(
          children: [
            Icon(
              Icons.audio_file,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Audio',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );

      case 'Document':
        return Row(
          children: [
            Icon(
              Icons.file_copy_outlined,
              size: IsmChatDimens.sixteen,
            ),
            IsmChatDimens.boxWidth2,
            Text(
              'Document',
              style: IsmChatStyles.w400Black12,
            )
          ],
        );
    }
    if (contains('https://www.google.com/maps/')) {
      return Row(
        children: [
          Icon(
            Icons.location_on_outlined,
            size: IsmChatDimens.sixteen,
          ),
          IsmChatDimens.boxWidth2,
          Text(
            'Location',
            style: IsmChatStyles.w400Black12,
          )
        ],
      );
    }
    return Text(
      message.body,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: IsmChatStyles.w400Black12,
    );
  }

  Color getColor() => Color(int.parse('0xff${replaceFirst('#', '')}'));
}

extension GetLink on String {
  /// Here we are extracting location coordinates from the url of the app
  /// <BaseUrl>?<Params>&query=`Lat`%2C`Lng`&<Rest Params>
  LatLng get position {
    if (!contains('map')) {
      throw const IsmChatInvalidMapUrlException(
          "Invalid url, link doesn't contains map link to extract position coordinates");
    }
    var position = split('query=')
        .last
        .split('&')
        .first
        .split('%2C')
        .map(double.parse)
        .toList();

    return LatLng(position.first, position.last);
  }
}

extension AddressString on Placemark {
  /// This function is an extension on `Placemark` class from [geocoding](https://pub.dev/packages/geocoding) package
  /// This will return a formatted address
  String toAddress() => [
        name,
        street,
        subLocality,
        locality,
        administrativeArea,
        country,
        postalCode
      ].join(', ');
}

extension BlockStatus on IsmChatConversationModel {
  bool get isChattingAllowed => !(messagingDisabled ?? false);

  bool get isBlockedByMe {
    if (isChattingAllowed) {
      return false;
    }
    var controller = Get.find<IsmChatConversationsController>();
    var blockedList = controller.blockUsers.map((e) => e.userId);
    return blockedList.contains(opponentDetails!.userId);
  }
}

extension ConversationCount on List<IsmChatConversationModel> {
  int get unreadCount {
    var i = 0;
    var count = 0;
    while (i < length) {
      var conversaiton = this[i];
      if (conversaiton.unreadMessagesCount != 0) {
        count++;
      }
      i++;
    }
    return count;
  }
}

extension MenuIcon on IsmChatFocusMenuType {
  IconData get icon {
    switch (this) {
      case IsmChatFocusMenuType.info:
        return Icons.info_outline_rounded;
      case IsmChatFocusMenuType.reply:
        return Icons.reply_rounded;
      case IsmChatFocusMenuType.forward:
        return Icons.shortcut_rounded;
      case IsmChatFocusMenuType.copy:
        return Icons.copy_rounded;
      case IsmChatFocusMenuType.delete:
        return Icons.delete_outline_rounded;
      case IsmChatFocusMenuType.selectMessage:
        return Icons.select_all_rounded;
    }
  }
}

extension SelectedUsers on List<SelectedMembers> {
  List<SelectedMembers> get selectedUsers =>
      where((e) => e.isUserSelected).toList();
}

extension SelectedContacts on List<SelectedContact> {
  List<SelectedContact> get selectedContact =>
      where((e) => e.isConotactSelected).toList();
}

extension UniqueElements<T> on List<T> {
  List<T> unique() => [
        ...{...this}
      ];
}

extension ModelConversion on IsmChatConversationModel {
  IsmChatMqttController get _mqttController =>
      Get.find<IsmChatMqttController>();

  String get typingUsers {
    var users = _mqttController.typingUsers
        .where(
          (u) => u.conversationId == conversationId,
        )
        .toList()
        .unique();
    users.sort(
      (a, b) => a.userName.toLowerCase().compareTo(b.userName.toLowerCase()),
    );

    return isGroup!
        ? '${users.map((e) => e.userName).join(', ')} is ${IsmChatStrings.typing}'
        : IsmChatStrings.typing;
  }

  bool get isSomeoneTyping => _mqttController.typingUsers
      .map((e) => e.conversationId)
      .contains(conversationId);

  Widget get sender {
    if (!isGroup! ||
        lastMessageDetails!.messageBody.isEmpty ||
        [IsmChatCustomMessageType.memberLeave]
            .contains(lastMessageDetails!.customType)) {
      return const SizedBox.shrink();
    }

    var senderName = lastMessageDetails?.sentByMe == true
        ? 'You'
        : lastMessageDetails?.senderName;

    return Text(
      '$senderName: ',
      style: IsmChatStyles.w500Black12,
    );
  }

  Widget get readCheck {
    try {
      if (!(lastMessageDetails?.sentByMe ?? false)) {
        return const SizedBox.shrink();
      }
      if (lastMessageDetails?.messageBody.isEmpty == true) {
        return const SizedBox.shrink();
      }

      if ([
        IsmChatCustomMessageType.addMember,
        IsmChatCustomMessageType.unblock,
        IsmChatCustomMessageType.block,
        IsmChatCustomMessageType.deletedForEveryone,
        IsmChatCustomMessageType.memberJoin,
        IsmChatCustomMessageType.memberLeave,
        IsmChatCustomMessageType.conversationCreated,
        IsmChatCustomMessageType.conversationImageUpdated,
        IsmChatCustomMessageType.conversationTitleUpdated,
      ].contains(lastMessageDetails!.customType)) {
        return const SizedBox.shrink();
      }

      var deliveredToAll = false;
      var readByAll = false;
      if (!isGroup!) {
        // this means not recieved by the user
        if (lastMessageDetails?.deliverCount != 0) {
          deliveredToAll = true;
          // this means not read by the user
          if (lastMessageDetails?.readCount != 0) {
            readByAll = true;
          }
        }
      } else {
        if (membersCount == lastMessageDetails?.deliverCount) {
          deliveredToAll = true;
          if (membersCount == lastMessageDetails?.readCount) {
            readByAll = true;
          }
        }
      }

      return Icon(
        lastMessageDetails?.messageId.isEmpty == true
            ? Icons.watch_later_outlined
            : deliveredToAll
                ? Icons.done_all_rounded
                : Icons.done_rounded,
        color: lastMessageDetails?.messageId.isEmpty == true
            ? IsmChatConfig.chatTheme.chatPageTheme?.unreadCheckColor ??
                IsmChatColors.whiteColor
            : readByAll
                ? IsmChatConfig.chatTheme.chatPageTheme?.readCheckColor ??
                    IsmChatColors.blueColor
                : IsmChatConfig.chatTheme.chatPageTheme?.unreadCheckColor ??
                    IsmChatColors.greyColor,
        size: IsmChatDimens.sixteen,
      );
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return const SizedBox.shrink();
    }
  }
}

extension LastMessageBody on LastMessageDetails {
  String get messageBody {
    switch (customType) {
      case IsmChatCustomMessageType.reply:
        return 'Replied to $body';
      case IsmChatCustomMessageType.image:
        return 'Image';
      case IsmChatCustomMessageType.video:
        return 'Video';
      case IsmChatCustomMessageType.audio:
        return 'Audio';
      case IsmChatCustomMessageType.file:
        return 'Document';
      case IsmChatCustomMessageType.location:
        return 'Location';
      case IsmChatCustomMessageType.block:
        var status = 'blocked';
        var text =
            IsmChatConfig.communicationConfig.userConfig.userId == initiatorId
                ? 'You $status this user'
                : 'You are $status';
        return text;
      case IsmChatCustomMessageType.contact:
        return 'Contact';
      case IsmChatCustomMessageType.unblock:
        var status = 'unblocked';
        var text =
            IsmChatConfig.communicationConfig.userConfig.userId == initiatorId
                ? 'You $status this user'
                : 'You are $status';
        return text;

      case IsmChatCustomMessageType.conversationCreated:
        return 'Conversation created';
      case IsmChatCustomMessageType.conversationImageUpdated:
        return 'Changed this group profile';
      case IsmChatCustomMessageType.conversationTitleUpdated:
        return 'Changed this group title';
      case IsmChatCustomMessageType.removeMember:
        return 'Removed ${(members ?? []).join(', ')}';
      case IsmChatCustomMessageType.addMember:
        return 'Added ${(members ?? []).join(', ')}';
      case IsmChatCustomMessageType.addAdmin:
        return 'Added $adminOpponentName as an Admin';
      case IsmChatCustomMessageType.removeAdmin:
        return 'Remove $adminOpponentName as an Admin';
      case IsmChatCustomMessageType.memberLeave:
        return '$senderName left';
      case IsmChatCustomMessageType.memberJoin:
        return '$senderName join';
      case IsmChatCustomMessageType.deletedForMe:
      case IsmChatCustomMessageType.deletedForEveryone:
        return sentByMe
            ? IsmChatStrings.deletedMessage
            : IsmChatStrings.wasDeletedMessage;
      case IsmChatCustomMessageType.oneToOneCall:
        if (action == IsmChatActionEvents.meetingCreated.name) {
          return '${meetingType == 0 ? 'Voice' : 'Video'} call • In call';
        } else if (callDurations?.length == 2) {
          return '${meetingType == 0 ? 'Voice' : 'Video'} call';
        } else {
          return 'Missed ${meetingType == 0 ? 'voice' : 'video'} call';
        }
      case IsmChatCustomMessageType.link:
      case IsmChatCustomMessageType.forward:
      case IsmChatCustomMessageType.date:
      case IsmChatCustomMessageType.text:
      default:
        var isReacted = action == IsmChatActionEvents.reactionAdd.name;
        return reactionType?.isNotEmpty == true
            ? sentByMe
                ? 'You ${isReacted ? 'reacted' : 'removed'} ${reactionType?.reactionString} ${isReacted ? 'to' : 'from'} a message'
                : '$senderName ${isReacted ? 'reacted' : 'removed'} ${reactionType?.reactionString} ${isReacted ? 'to' : 'from'} a message'
            : body;
    }
  }

  Widget get icon {
    IconData? iconData;
    switch (customType) {
      case IsmChatCustomMessageType.reply:
        iconData = Icons.reply_rounded;
        break;
      case IsmChatCustomMessageType.image:
        iconData = Icons.image_rounded;
        break;
      case IsmChatCustomMessageType.video:
        iconData = Icons.videocam_rounded;
        break;
      case IsmChatCustomMessageType.audio:
        iconData = Icons.audiotrack_rounded;
        break;
      case IsmChatCustomMessageType.file:
        iconData = Icons.description_rounded;
        break;
      case IsmChatCustomMessageType.location:
        iconData = Icons.location_on_rounded;
        break;
      case IsmChatCustomMessageType.block:
      case IsmChatCustomMessageType.unblock:
        iconData = Icons.block_rounded;
        break;
      case IsmChatCustomMessageType.conversationCreated:
        iconData = Icons.how_to_reg_rounded;
        break;
      case IsmChatCustomMessageType.addMember:
        iconData = Icons.waving_hand_rounded;
        break;
      case IsmChatCustomMessageType.memberLeave:
        iconData = Icons.directions_walk_rounded;
        break;
      case IsmChatCustomMessageType.memberJoin:
        iconData = Icons.join_inner_outlined;
        break;
      case IsmChatCustomMessageType.link:
        iconData = Icons.link_rounded;
        break;
      case IsmChatCustomMessageType.forward:
        iconData = Icons.shortcut_rounded;
        break;
      case IsmChatCustomMessageType.removeMember:
        iconData = Icons.group_remove_outlined;
        break;
      case IsmChatCustomMessageType.deletedForEveryone:
        iconData = Icons.remove_circle_outline_rounded;
        break;
      case IsmChatCustomMessageType.oneToOneCall:
        iconData = meetingType == 0
            ? sentByMe
                ? Icons.call_outlined
                : Icons.phone_callback_outlined
            : sentByMe
                ? Icons.video_call_outlined
                : Icons.missed_video_call_outlined;
        break;
      case IsmChatCustomMessageType.addAdmin:
      case IsmChatCustomMessageType.removeAdmin:
      case IsmChatCustomMessageType.deletedForMe:
      case IsmChatCustomMessageType.conversationImageUpdated:
      case IsmChatCustomMessageType.conversationTitleUpdated:
      case IsmChatCustomMessageType.date:
      case IsmChatCustomMessageType.text:
      default:
    }

    if (iconData != null) {
      return Icon(
        iconData,
        size: IsmChatDimens.fifteen,
        color: IsmChatConfig.chatTheme.chatListCardThemData?.subTitleColor ??
            IsmChatColors.blackColor,
      );
    }
    return const SizedBox.shrink();
  }
}

extension ReactionLastMessgae on String {
  String get reactionString {
    var reactionValue = IsmChatEmoji.values.firstWhere((e) => e.value == this);

    var reaction = Get.find<IsmChatConversationsController>()
        .reactions
        .firstWhere((e) => e.name == reactionValue.emojiKeyword);

    return reaction.emoji;
  }
}

extension MentionMessage on IsmChatMessageModel {
  List<LocalMentionAndPhoneNumber> get mentionList {
    try {
      var messageList = <LocalMentionAndPhoneNumber>[];
      var phoneNumerList = body.phoneNumerList;

      if (body.contains('@')) {
        var splitMessages = body.split('@');
        messageList.add(
          LocalMentionAndPhoneNumber(
            text: splitMessages.first,
            isMentioned: false,
            isPhoneNumber: false,
          ),
        );
        var length = mentionedUsers!.length;

        var splitLength = splitMessages.length;

        for (var i = 0; i < length; i++) {
          var mention = mentionedUsers![i];
          messageList.add(
            LocalMentionAndPhoneNumber(
              text: '@${mention.userName.capitalizeFirst}',
              isMentioned: true,
              isPhoneNumber: false,
            ),
          );

          if (splitLength < length || i < length) {
            messageList.add(
              LocalMentionAndPhoneNumber(
                text: splitMessages[i + 1]
                    .split(mention.userName.capitalizeFirst!)
                    .last,
                isMentioned: false,
                isPhoneNumber: false,
              ),
            );
          }
        }
      } else {
        var splitMessages = body.split(' ');
        messageList.add(
          LocalMentionAndPhoneNumber(
            text: splitMessages.first,
            isMentioned: false,
            isPhoneNumber: false,
          ),
        );

        var length = phoneNumerList.length;

        var splitLength = splitMessages.length;

        for (var i = 0; i < length; i++) {
          var number = phoneNumerList[i];
          if (splitLength != 1) {
            messageList.add(
              LocalMentionAndPhoneNumber(
                text: '  $number',
                isMentioned: false,
                isPhoneNumber: true,
              ),
            );

            if (splitLength < length || i < length) {
              messageList.add(
                LocalMentionAndPhoneNumber(
                  text: splitMessages[i + 1].split(number).last,
                  isMentioned: false,
                  isPhoneNumber: false,
                ),
              );
            }
          }
        }
      }

      if (phoneNumerList.isNotEmpty) {
        var messageWithPhone = <LocalMentionAndPhoneNumber>[];
        for (var x in messageList) {
          var isPhone = phoneNumerList.any((e) => x.text.trim() == e.trim());
          x = x.copyWith(isPhoneNumber: isPhone);
          messageWithPhone.add(x);
        }
        messageList = messageWithPhone;
      }

      return messageList;
    } catch (e, st) {
      IsmChatLog.error(e, st);
      return [];
    }
  }

  List<IsmChatFocusMenuType> get focusMenuList {
    var menu = [...IsmChatFocusMenuType.values];
    if (!sentByMe) {
      menu.remove(IsmChatFocusMenuType.info);
    }
    if ([
      IsmChatCustomMessageType.video,
      IsmChatCustomMessageType.image,
      IsmChatCustomMessageType.audio,
      IsmChatCustomMessageType.file
    ].contains(customType)) {
      menu.remove(IsmChatFocusMenuType.copy);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.reply)) {
      menu.remove(IsmChatFocusMenuType.reply);
    }
    if (!IsmChatProperties.chatPageProperties.features
        .contains(IsmChatFeature.forward)) {
      menu.remove(IsmChatFocusMenuType.forward);
    }
    if (Get.find<IsmChatPageController>().isBroadcast) {
      menu.removeWhere((e) => [
            IsmChatFocusMenuType.info,
            IsmChatFocusMenuType.delete,
            IsmChatFocusMenuType.reply,
            IsmChatFocusMenuType.selectMessage
          ].contains(e));
    }
    return menu;
  }

  TextStyle get style {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.textStyle ??
          IsmChatStyles.w500White14.copyWith(
            color: theme?.selfMessageTheme?.textColor,
          );
    }
    return (theme?.opponentMessageTheme?.textStyle ?? IsmChatStyles.w500Black14)
        .copyWith(
      color: theme?.opponentMessageTheme?.textColor,
    );
  }

  Color? get textColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.textColor ?? IsmChatColors.whiteColor;
    }
    return theme?.opponentMessageTheme?.textColor ?? IsmChatColors.blackColor;
  }

  Color? get backgroundColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.backgroundColor ??
          IsmChatConfig.chatTheme.primaryColor;
    }
    return theme?.opponentMessageTheme?.backgroundColor ??
        IsmChatConfig.chatTheme.backgroundColor;
  }

  Color? get borderColor {
    var theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (sentByMe) {
      return theme?.selfMessageTheme?.borderColor ??
          IsmChatConfig.chatTheme.primaryColor;
    }
    return theme?.opponentMessageTheme?.borderColor ??
        IsmChatConfig.chatTheme.backgroundColor;
  }
}

extension SizeOfMedia on String {
  bool size({double limit = 100.0}) {
    if (split(' ').last == 'KB') {
      return true;
    }
    if (double.parse(split(' ').first).round() <= limit.round()) {
      return true;
    }

    return false;
  }

  Uint8List get strigToUnit8List {
    if (isNotEmpty) {
      var list = Uint8List.fromList(
        List.from(jsonDecode(this) as List),
      );
      return list;
    }
    return Uint8List(0);
  }
}

extension ColorExtension on String {
  Color? get toColor {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension AttachmentIcon on IsmChatAttachmentType {
  IconData get iconData {
    switch (this) {
      case IsmChatAttachmentType.camera:
        return Icons.camera_alt_outlined;
      case IsmChatAttachmentType.gallery:
        return Icons.collections;

      case IsmChatAttachmentType.document:
        return Icons.description;
      case IsmChatAttachmentType.location:
        return Icons.pin_drop;

      case IsmChatAttachmentType.contact:
        return Icons.person_rounded;
    }
  }
}

extension Conversation on IsmChatConversationType {
  String get conversationName {
    switch (this) {
      case IsmChatConversationType.private:
        return 'Conversation';
      case IsmChatConversationType.public:
        return 'Public';
      case IsmChatConversationType.open:
        return 'Open';
    }
  }

  Widget get conversationWidget {
    switch (this) {
      case IsmChatConversationType.private:
        return const IsmChatConversationList();
      case IsmChatConversationType.public:
        return const IsmChatPublicConversationView();
      case IsmChatConversationType.open:
        return const IsmChatOpenConversationView();
    }
  }

  IconData get icon {
    switch (this) {
      case IsmChatConversationType.private:
        return Icons.admin_panel_settings_outlined;
      case IsmChatConversationType.public:
        return Icons.group_add_rounded;
      case IsmChatConversationType.open:
        return Icons.lock_open_outlined;
    }
  }

  String get conversationType {
    switch (this) {
      case IsmChatConversationType.private:
        return IsmChatStrings.conversation;
      case IsmChatConversationType.public:
        return IsmChatStrings.publicConversation;
      case IsmChatConversationType.open:
        return IsmChatStrings.openConversation;
    }
  }

  void goToRoute() {
    final controller = Get.find<IsmChatConversationsController>();
    switch (this) {
      case IsmChatConversationType.private:
        break;
      case IsmChatConversationType.public:
        if (IsmChatResponsive.isWeb(Get.context!)) {
          controller.isRenderScreen =
              IsRenderConversationScreen.publicConverationView;
          Scaffold.of(controller.isDrawerContext!).openDrawer();
        } else {
          IsmChatRouteManagement.goToPublicView();
        }

        break;
      case IsmChatConversationType.open:
        if (IsmChatResponsive.isWeb(Get.context!)) {
          controller.isRenderScreen =
              IsRenderConversationScreen.openConverationView;
          Scaffold.of(controller.isDrawerContext!).openDrawer();
        } else {
          IsmChatRouteManagement.goToOpenView();
        }

        break;
    }
  }
}

extension ListMerging<T> on List<List<T>?> {
  List<T> merge() => fold([], (a, b) {
        a.addAll(b ?? []);
        return a;
      });

  List<T> mergeWithSeprator([T? seperator]) {
    var result = <T>[];
    for (var i = 0; i < length; i++) {
      result.addAll(this[i] ?? []);
      if (seperator != null) {
        result.add(seperator);
      }
    }
    if (seperator != null) {
      result.removeLast();
    }
    return result;
  }
}

// This extension is to remove any key value pair from the map
// where the value is null
extension OnMap on Map<String, dynamic> {
  Map<String, dynamic> removeNullValues() {
    var result = <String, dynamic>{};
    for (var entry in entries) {
      var k = entry.key;
      var v = entry.value;
      if (v != null) {
        if (!v.runtimeType.toString().contains('List') &&
            v.runtimeType.toString().contains('Map')) {
          result[k] = (v as Map<String, dynamic>).removeNullValues();
        } else {
          // if (v is String && v.trim().isEmpty) {
          //   continue;
          // }
          result[k] = v;
        }
      }
    }
    return result;
  }
}
