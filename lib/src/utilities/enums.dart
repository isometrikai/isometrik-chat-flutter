import 'package:any_link_preview/any_link_preview.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

enum IsmChatMessageType {
  normal(0),
  forward(1),
  reply(2),
  admin(3);

  const IsmChatMessageType(this.value);

  factory IsmChatMessageType.fromValue(int value) {
    switch (value) {
      case 0:
        return IsmChatMessageType.normal;
      case 1:
        return IsmChatMessageType.forward;
      case 2:
        return IsmChatMessageType.reply;
      case 3:
        return IsmChatMessageType.admin;
      default:
        return IsmChatMessageType.normal;
    }
  }

  final int value;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

enum IsmChatCustomMessageType {
  text(1),
  reply(2),
  forward(3),
  image(4),
  video(5),
  audio(6),
  file(7),
  location(8),
  block(9),
  unblock(10),
  deletedForMe(11),
  deletedForEveryone(12),
  link(13),
  conversationCreated(14),
  removeMember(15),
  addMember(16),
  addAdmin(17),
  removeAdmin(18),
  memberLeave(19),
  conversationTitleUpdated(20),
  conversationImageUpdated(21),
  contact(22),
  memberJoin(23),
  observerJoin(24),
  observerLeave(25),
  aboutText(26),
  oneToOneCall(27),
  date(100);

  const IsmChatCustomMessageType(this.number);

  factory IsmChatCustomMessageType.fromValue(int data) =>
      IsmChatCustomMessageType.values
          .asMap()
          .map((_, v) => MapEntry(v.number, v))[data] ??
      IsmChatCustomMessageType.text;

  factory IsmChatCustomMessageType.fromString(String value) {
    const map = <String, IsmChatCustomMessageType>{
      'text': IsmChatCustomMessageType.text,
      'AttachmentMessage:Text': IsmChatCustomMessageType.text,
      'file': IsmChatCustomMessageType.file,
      'AttachmentMessage:File': IsmChatCustomMessageType.file,
      'replyText': IsmChatCustomMessageType.reply,
      'reply': IsmChatCustomMessageType.reply,
      'AttachmentMessage:Reply': IsmChatCustomMessageType.reply,
      'video': IsmChatCustomMessageType.video,
      'AttachmentMessage:Video': IsmChatCustomMessageType.video,
      'image': IsmChatCustomMessageType.image,
      'AttachmentMessage:Image': IsmChatCustomMessageType.image,
      'AttachmentMessage:Sticker': IsmChatCustomMessageType.image,
      'AttachmentMessage:Gif': IsmChatCustomMessageType.image,
      'voice': IsmChatCustomMessageType.audio,
      'audio': IsmChatCustomMessageType.audio,
      'AttachmentMessage:Audio': IsmChatCustomMessageType.audio,
      'location': IsmChatCustomMessageType.location,
      'AttachmentMessage:Location': IsmChatCustomMessageType.location,
      'contact': IsmChatCustomMessageType.contact,
      'AttachmentMessage:Contact': IsmChatCustomMessageType.contact,
      'block': IsmChatCustomMessageType.block,
      'unblock': IsmChatCustomMessageType.unblock,
      'conversationCreated': IsmChatCustomMessageType.conversationCreated,
      'membersRemove': IsmChatCustomMessageType.removeMember,
      'removeMember': IsmChatCustomMessageType.removeMember,
      'membersAdd': IsmChatCustomMessageType.addMember,
      'addMember': IsmChatCustomMessageType.addMember,
      'addAdmin': IsmChatCustomMessageType.addAdmin,
      'revokeAdmin': IsmChatCustomMessageType.removeAdmin,
      'memberLeave': IsmChatCustomMessageType.memberLeave,
      'conversationTitleUpdated':
          IsmChatCustomMessageType.conversationTitleUpdated,
      'conversationImageUpdated':
          IsmChatCustomMessageType.conversationImageUpdated,
      'messagesDeleteForAll': IsmChatCustomMessageType.deletedForEveryone,
      'memberJoin': IsmChatCustomMessageType.memberJoin,
      'observerJoin': IsmChatCustomMessageType.observerJoin,
      'observerLeave': IsmChatCustomMessageType.observerLeave,
      'date': IsmChatCustomMessageType.date,
      'aboutText': IsmChatCustomMessageType.aboutText,
      'oneToOneCall': IsmChatCustomMessageType.oneToOneCall
    };
    var type = value.split('.').last;
    return map[type] ?? IsmChatCustomMessageType.text;
  }

  factory IsmChatCustomMessageType.fromMap(dynamic value) {
    if (value.runtimeType != int && value.runtimeType != String) {
      return IsmChatCustomMessageType.text;
    }
    if (value.runtimeType == int) {
      return IsmChatCustomMessageType.fromValue(value as int);
    } else {
      return IsmChatCustomMessageType.fromString(value as String);
    }
  }

  factory IsmChatCustomMessageType.withBody(String body) {
    if (body.isEmpty) {
      return IsmChatCustomMessageType.text;
    }
    if (body.toLowerCase().contains('map')) {
      return IsmChatCustomMessageType.location;
    }

    /// This code run for react web messages
    // if (IsmChatConstants.imageExtensions
    //     .any((e) => body.split('.').last.toLowerCase() == e.toLowerCase())) {
    //   return IsmChatCustomMessageType.image;
    // }
    // if (IsmChatConstants.videoExtensions
    //     .any((e) => body.split('.').last.toLowerCase() == e.toLowerCase())) {
    //   return IsmChatCustomMessageType.video;
    // }
    // if (IsmChatConstants.audioExtensions
    //     .any((e) => body.split('.').last.toLowerCase() == e.toLowerCase())) {
    //   return IsmChatCustomMessageType.audio;
    // }
    // if (IsmChatConstants.fileExtensions
    //     .any((e) => body.split('.').last.toLowerCase() == e.toLowerCase())) {
    //   return IsmChatCustomMessageType.file;
    // }
    if (AnyLinkPreview.isValidLink(body) ||
        body.toLowerCase().contains('.com')) {
      return IsmChatCustomMessageType.link;
    }
    return IsmChatCustomMessageType.text;
  }

  static IsmChatCustomMessageType? fromAction(String value) {
    var action = IsmChatActionEvents.fromName(value);
    switch (action) {
      case IsmChatActionEvents.typingEvent:
        return null;
      case IsmChatActionEvents.conversationCreated:
        return IsmChatCustomMessageType.conversationCreated;
      case IsmChatActionEvents.messageDelivered:
        return null;
      case IsmChatActionEvents.messageRead:
        return null;
      case IsmChatActionEvents.messagesDeleteForAll:
        return null;
      case IsmChatActionEvents.multipleMessagesRead:
        return null;
      case IsmChatActionEvents.clearConversation:
        return null;
      case IsmChatActionEvents.deleteConversationLocally:
        return null;
      case IsmChatActionEvents.reactionAdd:
        return null;
      case IsmChatActionEvents.reactionRemove:
        return null;
      case IsmChatActionEvents.removeAdmin:
        return IsmChatCustomMessageType.removeAdmin;
      case IsmChatActionEvents.addAdmin:
        return IsmChatCustomMessageType.addAdmin;
      case IsmChatActionEvents.userBlock:
        return IsmChatCustomMessageType.block;
      case IsmChatActionEvents.userBlockConversation:
        return IsmChatCustomMessageType.block;
      case IsmChatActionEvents.userUnblock:
        return IsmChatCustomMessageType.unblock;
      case IsmChatActionEvents.userUnblockConversation:
        return IsmChatCustomMessageType.unblock;
      case IsmChatActionEvents.removeMember:
        return IsmChatCustomMessageType.removeMember;
      case IsmChatActionEvents.addMember:
        return IsmChatCustomMessageType.addMember;
      case IsmChatActionEvents.memberLeave:
        return IsmChatCustomMessageType.memberLeave;
      case IsmChatActionEvents.conversationTitleUpdated:
        return IsmChatCustomMessageType.conversationTitleUpdated;
      case IsmChatActionEvents.conversationImageUpdated:
        return IsmChatCustomMessageType.conversationImageUpdated;

      case IsmChatActionEvents.memberJoin:
        return IsmChatCustomMessageType.memberJoin;
      case IsmChatActionEvents.observerJoin:
        return IsmChatCustomMessageType.observerJoin;
      case IsmChatActionEvents.observerLeave:
        return IsmChatCustomMessageType.observerLeave;

      default:
        return null;
    }
  }

  final int number;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';

  String get value {
    switch (this) {
      case IsmChatCustomMessageType.forward:
        return 'forward';
      case IsmChatCustomMessageType.reply:
        return 'AttachmentMessage:Reply';
      case IsmChatCustomMessageType.text:
        return 'AttachmentMessage:Text';
      case IsmChatCustomMessageType.image:
        return 'AttachmentMessage:Image';
      case IsmChatCustomMessageType.video:
        return 'AttachmentMessage:Video';
      case IsmChatCustomMessageType.audio:
        return 'AttachmentMessage:Audio';
      case IsmChatCustomMessageType.file:
        return 'AttachmentMessage:File';
      case IsmChatCustomMessageType.location:
        return 'AttachmentMessage:Location';
      case IsmChatCustomMessageType.contact:
        return 'AttachmentMessage:Contact';
      case IsmChatCustomMessageType.link:
        return 'link';
      case IsmChatCustomMessageType.block:
        return 'block';
      case IsmChatCustomMessageType.unblock:
        return 'unblock';
      case IsmChatCustomMessageType.deletedForMe:
        return 'deletedForMe';
      case IsmChatCustomMessageType.deletedForEveryone:
        return 'messagesDeleteForAll';
      case IsmChatCustomMessageType.conversationCreated:
        return 'conversationCreated';
      case IsmChatCustomMessageType.removeMember:
        return 'removeMember';
      case IsmChatCustomMessageType.addMember:
        return 'addMember';
      case IsmChatCustomMessageType.addAdmin:
        return 'addAdmin';
      case IsmChatCustomMessageType.removeAdmin:
        return 'removeAdmin';
      case IsmChatCustomMessageType.memberLeave:
        return 'memberLeave';
      case IsmChatCustomMessageType.conversationTitleUpdated:
        return 'conversationTitleUpdated';
      case IsmChatCustomMessageType.conversationImageUpdated:
        return 'conversationImageUpdated';
      case IsmChatCustomMessageType.memberJoin:
        return 'memberJoin';
      case IsmChatCustomMessageType.observerJoin:
        return 'observerJoin';
      case IsmChatCustomMessageType.observerLeave:
        return 'observerLeave';
      case IsmChatCustomMessageType.date:
        return 'date';
      case IsmChatCustomMessageType.aboutText:
        return 'aboutText';
      case IsmChatCustomMessageType.oneToOneCall:
        return 'oneToOneCall';
    }
  }
}

enum IsmChatConnectionState {
  connected,
  disconnected,
  connecting,
  subscribed,
  unsubscribed;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

enum IsmChatMessageStatus {
  pending(0),
  sent(1),
  delivered(2),
  read(3);

  const IsmChatMessageStatus(this.value);

  final int value;
}

enum IsmChatConversationType {
  private(0),
  public(1),
  open(2);

  const IsmChatConversationType(this.value);

  factory IsmChatConversationType.fromValue(int value) {
    switch (value) {
      case 0:
        return IsmChatConversationType.private;
      case 1:
        return IsmChatConversationType.public;
      case 2:
        return IsmChatConversationType.open;
      default:
        return IsmChatConversationType.private;
    }
  }

  final int value;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

/// [IsmChatMediaType] is an `Enum` used for passing different type of media to and from API
enum IsmChatMediaType {
  image(0),
  video(1),
  audio(2),
  file(3),
  location(4),
  sticker(5),
  gif(6),
  adminMessage(7);

  const IsmChatMediaType(this.value);

  factory IsmChatMediaType.fromMap(int value) {
    switch (value) {
      case 0:
        return IsmChatMediaType.image;
      case 1:
        return IsmChatMediaType.video;
      case 2:
        return IsmChatMediaType.audio;
      case 3:
        return IsmChatMediaType.file;
      case 4:
        return IsmChatMediaType.location;
      case 5:
        return IsmChatMediaType.sticker;
      case 6:
        return IsmChatMediaType.gif;
      case 7:
        return IsmChatMediaType.adminMessage;
      default:
        return IsmChatMediaType.image;
    }
  }

  final int value;
}

enum IsmChatActionEvents {
  typingEvent,
  conversationCreated,
  messageDelivered,
  messageRead,
  messagesDeleteForAll,
  multipleMessagesRead,
  userBlock,
  userBlockConversation,
  userUnblock,
  userUnblockConversation,
  clearConversation,
  removeMember,
  addMember,
  removeAdmin,
  addAdmin,
  memberLeave,
  deleteConversationLocally,
  reactionAdd,
  reactionRemove,
  conversationDetailsUpdated,
  conversationTitleUpdated,
  conversationImageUpdated,
  broadcast,
  memberJoin,
  observerJoin,
  observerLeave,
  userUpdate,
  meetingEndedByHost,
  meetingCreated,
  meetingEndedDueToRejectionByAll;

  factory IsmChatActionEvents.fromName(String name) {
    switch (name) {
      case 'typingEvent':
        return IsmChatActionEvents.typingEvent;
      case 'conversationCreated':
        return IsmChatActionEvents.conversationCreated;
      case 'messageDelivered':
        return IsmChatActionEvents.messageDelivered;
      case 'messageRead':
        return IsmChatActionEvents.messageRead;
      case 'messagesDeleteForAll':
        return IsmChatActionEvents.messagesDeleteForAll;
      case 'multipleMessagesRead':
        return IsmChatActionEvents.multipleMessagesRead;
      case 'userBlock':
        return IsmChatActionEvents.userBlock;
      case 'userBlockConversation':
        return IsmChatActionEvents.userBlockConversation;
      case 'userUnblock':
        return IsmChatActionEvents.userUnblock;
      case 'userUnblockConversation':
        return IsmChatActionEvents.userUnblockConversation;
      case 'clearConversation':
        return IsmChatActionEvents.clearConversation;
      case 'deleteConversationLocally':
        return IsmChatActionEvents.deleteConversationLocally;
      case 'membersRemove':
        return IsmChatActionEvents.removeMember;
      case 'membersAdd':
        return IsmChatActionEvents.addMember;
      case 'removeAdmin':
        return IsmChatActionEvents.removeAdmin;
      case 'addAdmin':
        return IsmChatActionEvents.addAdmin;
      case 'memberLeave':
        return IsmChatActionEvents.memberLeave;
      case 'reactionAdd':
        return IsmChatActionEvents.reactionAdd;
      case 'reactionRemove':
        return IsmChatActionEvents.reactionRemove;
      case 'conversationDetailsUpdated':
        return IsmChatActionEvents.conversationDetailsUpdated;
      case 'conversationTitleUpdated':
        return IsmChatActionEvents.conversationTitleUpdated;
      case 'conversationImageUpdated':
        return IsmChatActionEvents.conversationImageUpdated;
      case 'broadcast':
        return IsmChatActionEvents.broadcast;
      case 'memberJoin':
        return IsmChatActionEvents.memberJoin;
      case 'observerJoin':
        return IsmChatActionEvents.observerJoin;
      case 'observerLeave':
        return IsmChatActionEvents.observerLeave;
      case 'userUpdate':
        return IsmChatActionEvents.userUpdate;
      case 'meetingEndedByHost':
        return IsmChatActionEvents.meetingEndedByHost;
      case 'meetingCreated':
        return IsmChatActionEvents.meetingCreated;
      case 'meetingEndedDueToRejectionByAll':
        return IsmChatActionEvents.meetingEndedDueToRejectionByAll;
      default:
        return IsmChatActionEvents.typingEvent;
    }
  }

  @override
  String toString() {
    switch (this) {
      case IsmChatActionEvents.typingEvent:
        return 'typingEvent';
      case IsmChatActionEvents.conversationCreated:
        return 'conversationCreated';
      case IsmChatActionEvents.messageDelivered:
        return 'messageDelivered';
      case IsmChatActionEvents.messageRead:
        return 'messageRead';
      case IsmChatActionEvents.messagesDeleteForAll:
        return 'messagesDeleteForAll';
      case IsmChatActionEvents.multipleMessagesRead:
        return 'multipleMessagesRead';
      case IsmChatActionEvents.userBlock:
        return 'userBlock';
      case IsmChatActionEvents.userBlockConversation:
        return 'userBlockConversation';
      case IsmChatActionEvents.userUnblock:
        return 'userUnblock';
      case IsmChatActionEvents.userUnblockConversation:
        return 'userUnblockConversation';
      case IsmChatActionEvents.clearConversation:
        return 'clearConversation';
      case IsmChatActionEvents.deleteConversationLocally:
        return 'deleteConversationLocally';
      case IsmChatActionEvents.removeMember:
        return 'membersRemove';
      case IsmChatActionEvents.addMember:
        return 'membersAdd';
      case IsmChatActionEvents.removeAdmin:
        return 'removeAdmin';
      case IsmChatActionEvents.addAdmin:
        return 'addAdmin';
      case IsmChatActionEvents.memberLeave:
        return 'memberLeave';
      case IsmChatActionEvents.reactionAdd:
        return 'reactionAdd';
      case IsmChatActionEvents.reactionRemove:
        return 'reactionRemove';
      case IsmChatActionEvents.conversationDetailsUpdated:
        return 'conversationDetailsUpdated';
      case IsmChatActionEvents.conversationTitleUpdated:
        return 'conversationTitleUpdated';
      case IsmChatActionEvents.conversationImageUpdated:
        return 'conversationImageUpdated';
      case IsmChatActionEvents.broadcast:
        return 'broadcast';
      case IsmChatActionEvents.memberJoin:
        return 'memberJoin';

      case IsmChatActionEvents.observerJoin:
        return 'observerJoin';
      case IsmChatActionEvents.observerLeave:
        return 'observerLeave';
      case IsmChatActionEvents.userUpdate:
        return 'userUpdate';
      case IsmChatActionEvents.meetingEndedByHost:
        return 'meetingEndedByHost';
      case IsmChatActionEvents.meetingCreated:
        return 'meetingCreated';
      case IsmChatActionEvents.meetingEndedDueToRejectionByAll:
        return 'meetingEndedDueToRejectionByAll';
    }
  }
}

enum SendMessageType {
  pendingMessage,
  forwardMessage,
}

enum ApiCallOrigin {
  referesh,
  loadMore,
}

enum IsmChatFocusMenuType {
  info,
  copy,
  selectMessage,
  reply,
  forward,
  delete;

  @override
  String toString() => this == IsmChatFocusMenuType.selectMessage
      ? 'Select Message'
      : '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

enum IsmChatAttachmentType {
  camera(1),
  gallery(2),
  document(3),
  location(4),
  contact(5);

  const IsmChatAttachmentType(this.value);
  final int value;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

enum IsmChatEmoji {
  yes(
    value: 'yes',
    emojiKeyword: 'Thumbs Up',
  ),
  surprised(
    value: 'surprised',
    emojiKeyword: 'Astonished Face',
  ),
  cryingWithLaughter(
    value: 'crying_with_laughter',
    emojiKeyword: 'Face With Tears of Joy',
  ),
  crying(
    value: 'crying',
    emojiKeyword: 'Loudly Crying Face',
  ),
  heart(
    value: 'heart',
    emojiKeyword: 'Red Heart',
  ),
  sarcastic(
    value: 'sarcastic',
    emojiKeyword: 'Smirking Face',
  ),
  rock(
    value: 'rock',
    emojiKeyword: 'Love-You Gesture',
  ),
  facepal(
    value: 'facepalm',
    emojiKeyword: 'Man Facepalming',
  ),
  star(
    value: 'star',
    emojiKeyword: 'Star-Struck',
  ),
  no(
    value: 'no',
    emojiKeyword: 'Thumbs Down',
  ),
  bowing(
    value: 'bowing',
    emojiKeyword: 'Man Bowing',
  ),
  party(
    value: 'party',
    emojiKeyword: 'Partying Face',
  ),
  highFive(
    value: 'high_five',
    emojiKeyword: 'Folded Hands',
  ),
  talkingTooMuch(
    value: 'talking_too_much',
    emojiKeyword: 'Woozy Face',
  ),
  dancing(
    value: 'dancing',
    emojiKeyword: 'Man Dancing',
  );

  factory IsmChatEmoji.fromMap(String value) =>
      IsmChatEmoji.values.firstWhere((e) => e.value == value);

  factory IsmChatEmoji.fromEmoji(Emoji emoji) =>
      IsmChatEmoji.values.firstWhere((e) => e.emojiKeyword == emoji.name);

  const IsmChatEmoji({
    required this.value,
    required this.emojiKeyword,
  });

  final String value;
  final String emojiKeyword;

  @override
  String toString() =>
      'IsmChatEmoji(value: $value, emojiKeyword: $emojiKeyword)';
}

enum IsmChatFeature {
  reply,
  forward,
  reaction,
  chageWallpaper,
  searchMessage;
}

enum IsmChatDbBox { main, pending }

enum IsRenderConversationScreen {
  none,
  blockView,
  broadCastListView,
  groupUserView,
  createConverstaionView,
  userView,
  broadcastView,
  openConverationView,
  publicConverationView,
  // editbroadCast,
  // broadCastEligible,
}

enum IsRenderChatPageScreen {
  none,
  coversationInfoView,
  wallpaperView,
  messgaeInfoView,
  groupEligibleView,
  coversationMediaView,
  userInfoView,
  messageSearchView,
  boradcastChatMessagePage,
  openChatMessagePage,
  observerUsersView,
  outSideView,
}

enum IsmChatConversationPosition {
  tabBar,
  menu,
  navigationBar,
}
