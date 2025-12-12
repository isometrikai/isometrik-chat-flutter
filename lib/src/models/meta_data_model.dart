import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatMetaData {
  IsmChatMetaData({
    this.locationAddress,
    this.locationSubAddress,
    this.profilePic,
    this.lastName,
    this.firstName,
    this.contacts,
    this.assetList,
    this.duration,
    this.caption,
    this.replyMessage,
    this.senderInfo,
    this.customType,
    this.customMetaData,
    this.aboutText,
    this.isDownloaded,
    this.messageSentAt,
    this.isOnelyEmoji,
    this.blockedMessage,
    this.isBroadCastMessage,
    this.groupCastId,
  });

  factory IsmChatMetaData.fromMap(Map<String, dynamic> map) {
    var data = IsmChatMetaData(
        caption: map['caption'] != null
            ? map['caption'] as String? ?? ''
            : map['captionMessage'] != null
                ? map['captionMessage'] as String? ?? ''
                : '',
        locationAddress: map['locationAddress'] as String? ?? '',
        locationSubAddress: map['locationSubAddress'] as String? ?? '',
        profilePic: map['profilePic'] as String? ?? '',
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        customType: map['customType'].runtimeType == String
            ? {'${map['customType']}': map['customType']}
            : map['customType'] as Map<String, dynamic>? ?? {},
        customMetaData: map['customMetaData'] != null
            ? map['customMetaData'] as Map<String, dynamic>? ?? {}
            : map,
        assetList: map['assetList'] == null
            ? []
            : List<Map<String, IsmChatBackgroundModel>>.from(
                map['assetList'].map(
                  (x) => Map.from(x).map(
                    (k, v) => MapEntry<String, IsmChatBackgroundModel>(
                      k,
                      v.runtimeType == String
                          ? IsmChatBackgroundModel.fromJson(v)
                          : IsmChatBackgroundModel.fromMap(v),
                    ),
                  ),
                ),
              ).toList(),
        duration: Duration(seconds: map['duration'] as int? ?? 0),
        replyMessage: map['replyMessage'] != null
            ? IsmChatReplyMessageModel.fromMap(
                map['replyMessage'] as Map<String, dynamic>)
            : null,
        contacts: map['contacts'] != null
            ? List<IsmChatContactMetaDatModel>.from(
                (map['contacts'] as List).map<IsmChatContactMetaDatModel?>(
                  (x) => IsmChatContactMetaDatModel.fromMap(
                      x as Map<String, dynamic>),
                ),
              )
            : null,
        senderInfo: map['senderInfo'] != null
            ? UserDetails.fromMap(map['senderInfo'] as Map<String, dynamic>)
            : null,
        isDownloaded: map['isDownloaded'] as bool? ?? true,
        isOnelyEmoji: map['isOnelyEmoji'] as bool? ?? false,
        messageSentAt: map['messageSentAt'] as int? ?? 0,
        aboutText: map['aboutText'] != null
            ? AboutTextModel.fromMap(map['aboutText'] as Map<String, dynamic>)
            : map['about'] != null
                ? AboutTextModel(title: map['about'] as String? ?? '')
                : null,
        blockedMessage: map['blockedMessage'] != null
            ? IsmChatMessageModel.fromMap(
                map['blockedMessage'] as Map<String, dynamic>)
            : null,
        isBroadCastMessage: map['isBroadCastMessage'] as bool? ?? false,
        groupCastId: map['groupCastId'] as String? ?? '');
    return data;
  }

  factory IsmChatMetaData.fromJson(String? source) {
    if (source?.isEmpty == true || source == null) {
      return IsmChatMetaData();
    }
    return IsmChatMetaData.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  final String? locationAddress;
  final String? locationSubAddress;
  final String? profilePic;
  final String? lastName;
  final String? firstName;
  final List<IsmChatContactMetaDatModel>? contacts;
  final Map<String, dynamic>? customType;
  final Map<String, dynamic>? customMetaData;
  final List<Map<String, IsmChatBackgroundModel>>? assetList;
  final Duration? duration;
  final String? caption;
  final IsmChatReplyMessageModel? replyMessage;
  final UserDetails? senderInfo;
  final AboutTextModel? aboutText;
  final bool? isDownloaded;
  final int? messageSentAt;
  final bool? isOnelyEmoji;
  final IsmChatMessageModel? blockedMessage;
  final bool? isBroadCastMessage;
  final String? groupCastId;
  IsmChatMetaData copyWith(
          {String? parentMessageBody,
          String? locationAddress,
          String? locationSubAddress,
          String? profilePic,
          String? lastName,
          String? firstName,
          List<IsmChatContactMetaDatModel>? contacts,
          bool? parentMessageInitiator,
          Map<String, dynamic>? customType,
          Map<String, dynamic>? customMetaData,
          List<Map<String, IsmChatBackgroundModel>>? assetList,
          Duration? duration,
          String? captionMessage,
          IsmChatCustomMessageType? replayMessageCustomType,
          IsmChatReplyMessageModel? replyMessage,
          UserDetails? senderInfo,
          AboutTextModel? aboutText,
          bool? isDownloaded,
          int? messageSentAt,
          bool? isOnelyEmoji,
          IsmChatMessageModel? blockedMessage,
          bool? isBroadCastMessage,
          String? groupCastId}) =>
      IsmChatMetaData(
        locationAddress: locationAddress ?? this.locationAddress,
        locationSubAddress: locationSubAddress ?? this.locationSubAddress,
        profilePic: profilePic ?? this.profilePic,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        customType: customType ?? this.customType,
        customMetaData: customMetaData ?? this.customMetaData,
        duration: duration ?? this.duration,
        assetList: assetList ?? this.assetList,
        contacts: contacts ?? this.contacts,
        caption: captionMessage ?? caption,
        replyMessage: replyMessage ?? this.replyMessage,
        aboutText: aboutText ?? this.aboutText,
        isDownloaded: isDownloaded ?? this.isDownloaded,
        isOnelyEmoji: isOnelyEmoji ?? this.isOnelyEmoji,
        messageSentAt: messageSentAt ?? this.messageSentAt,
        blockedMessage: blockedMessage,
        isBroadCastMessage: isBroadCastMessage ?? this.isBroadCastMessage,
        groupCastId: groupCastId ?? this.groupCastId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'locationAddress': locationAddress,
        'locationSubAddress': locationSubAddress,
        'profilePic': profilePic,
        'lastName': lastName,
        'firstName': firstName,
        'contacts': contacts?.map((x) => x.toMap()).toList(),
        'customType': customType,
        'customMetaData': customMetaData,
        'assetList': assetList,
        'duration': duration?.inSeconds,
        'captionMessage': caption,
        'replyMessage': replyMessage?.toMap(),
        'senderInfo': senderInfo?.toMap(),
        'isDownloaded': isDownloaded,
        'isOnelyEmoji': isOnelyEmoji,
        'messageSentAt': messageSentAt,
        'aboutText': aboutText?.toMap(),
        'blockedMessage': blockedMessage?.toMap(),
        'isBroadCastMessage': isBroadCastMessage,
        'groupCastId': groupCastId,
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatMetaData(locationAddress: $locationAddress, locationSubAddress: $locationSubAddress, profilePic: $profilePic, lastName: $lastName, firstName: $firstName, contacts: $contacts,customType: $customType, assetList: $assetList, duration: $duration, captionMessage: $caption,replyMessage: $replyMessage, senderInfo : $senderInfo ,aboutText : $aboutText, isDownloaded : $isDownloaded, messageSentAt : $messageSentAt, customMetaData : $customMetaData, isOnelyEmoji : $isOnelyEmoji, blockedMessage : $blockedMessage, isBroadCastMessage : $isBroadCastMessage,groupCastId : $groupCastId)';

  @override
  bool operator ==(covariant IsmChatMetaData other) {
    if (identical(this, other)) return true;

    return other.locationAddress == locationAddress &&
        other.locationSubAddress == locationSubAddress &&
        other.profilePic == profilePic &&
        other.lastName == lastName &&
        other.firstName == firstName &&
        listEquals(other.contacts, contacts) &&
        mapEquals(other.customType, customType) &&
        mapEquals(other.customMetaData, customMetaData) &&
        listEquals(other.assetList, assetList) &&
        other.duration == duration &&
        other.caption == caption &&
        other.replyMessage == replyMessage &&
        other.senderInfo == senderInfo &&
        other.isDownloaded == isDownloaded &&
        other.messageSentAt == messageSentAt &&
        other.aboutText == aboutText &&
        other.isOnelyEmoji == isOnelyEmoji &&
        other.blockedMessage == blockedMessage &&
        other.isBroadCastMessage == isBroadCastMessage &&
        other.groupCastId == groupCastId;
  }

  @override
  int get hashCode =>
      locationAddress.hashCode ^
      locationSubAddress.hashCode ^
      profilePic.hashCode ^
      lastName.hashCode ^
      firstName.hashCode ^
      contacts.hashCode ^
      customType.hashCode ^
      customMetaData.hashCode ^
      assetList.hashCode ^
      duration.hashCode ^
      caption.hashCode ^
      replyMessage.hashCode ^
      senderInfo.hashCode ^
      isDownloaded.hashCode ^
      messageSentAt.hashCode ^
      aboutText.hashCode ^
      isOnelyEmoji.hashCode ^
      blockedMessage.hashCode ^
      isBroadCastMessage.hashCode ^
      groupCastId.hashCode;
}
