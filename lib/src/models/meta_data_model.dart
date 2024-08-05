import 'dart:convert';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/foundation.dart';

class IsmChatMetaData {
  IsmChatMetaData({
    this.locationAddress,
    this.locationSubAddress,
    this.profilePic,
    this.lastName,
    this.firstName,
    this.contacts,
    this.customType,
    this.assetList,
    this.duration,
    this.caption,
    this.replyMessage,
    this.senderInfo,
    this.countryCode,
    this.phone,
    this.phoneIsoCode,
    this.aboutText,
  });

  factory IsmChatMetaData.fromMap(Map<String, dynamic> map) => IsmChatMetaData(
        caption: map['caption'] != null
            ? IsmChatUtility.decodeString(map['caption'] as String)
            : map['captionMessage'] != null
                ? IsmChatUtility.decodeString(map['captionMessage'] as String)
                : '',
        locationAddress: map['locationAddress'] as String? ?? '',
        locationSubAddress: map['locationSubAddress'] as String? ?? '',
        profilePic: map['profilePic'] as String? ?? '',
        firstName: map['firstName'] as String? ?? '',
        lastName: map['lastName'] as String? ?? '',
        countryCode: map['countryCode'] as String? ?? '',
        phone: map['phone'] as String? ?? '',
        phoneIsoCode: map['phoneIsoCode'] as String? ?? '',
        customType: map['customType'].runtimeType == String
            ? {'${map['customType']}': map['customType']}
            : map['customType'] as Map<String, dynamic>? ?? {},
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
        aboutText: map['aboutText'] != null
            ? AboutTextModel.fromMap(map['aboutText'] as Map<String, dynamic>)
            : map['about'] != null
                ? AboutTextModel(title: map['about'] as String? ?? '')
                : null,
      );

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
  final List<Map<String, IsmChatBackgroundModel>>? assetList;
  final Duration? duration;
  final String? caption;
  final IsmChatReplyMessageModel? replyMessage;
  final UserDetails? senderInfo;
  final String? phoneIsoCode;
  final String? phone;
  final String? countryCode;
  // final String? about;
  final AboutTextModel? aboutText;

  IsmChatMetaData copyWith({
    String? parentMessageBody,
    String? locationAddress,
    String? locationSubAddress,
    String? profilePic,
    String? lastName,
    String? firstName,
    List<IsmChatContactMetaDatModel>? contacts,
    bool? parentMessageInitiator,
    Map<String, dynamic>? customType,
    List<Map<String, IsmChatBackgroundModel>>? assetList,
    Duration? duration,
    String? captionMessage,
    IsmChatCustomMessageType? replayMessageCustomType,
    IsmChatReplyMessageModel? replyMessage,
    UserDetails? senderInfo,
    String? phoneIsoCode,
    String? phone,
    String? countryCode,
    String? about,
    AboutTextModel? aboutText,
  }) =>
      IsmChatMetaData(
        locationAddress: locationAddress ?? this.locationAddress,
        locationSubAddress: locationSubAddress ?? this.locationSubAddress,
        profilePic: profilePic ?? this.profilePic,
        lastName: lastName ?? this.lastName,
        firstName: firstName ?? this.firstName,
        contacts: contacts ?? this.contacts,
        customType: customType ?? this.customType,
        assetList: assetList ?? this.assetList,
        duration: duration ?? this.duration,
        caption: captionMessage ?? caption,
        replyMessage: replyMessage ?? this.replyMessage,
        senderInfo: senderInfo ?? this.senderInfo,
        phoneIsoCode: phoneIsoCode ?? this.phoneIsoCode,
        phone: phone ?? this.phone,
        countryCode: countryCode ?? this.countryCode,
        aboutText: aboutText ?? this.aboutText,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'locationAddress': locationAddress,
        'locationSubAddress': locationSubAddress,
        'profilePic': profilePic,
        'lastName': lastName,
        'firstName': firstName,
        'contacts': contacts?.map((x) => x.toMap()).toList(),
        'customType': customType,
        'assetList': assetList,
        'duration': duration?.inSeconds,
        'captionMessage': caption,
        'replyMessage': replyMessage?.toMap(),
        'senderInfo': senderInfo?.toMap(),
        'phoneIsoCode': phoneIsoCode,
        'phone': phone,
        'countryCode': countryCode,
        'aboutText': aboutText?.toMap()
      }.removeNullValues();

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmChatMetaData(locationAddress: $locationAddress, locationSubAddress: $locationSubAddress, profilePic: $profilePic, lastName: $lastName, firstName: $firstName, contacts: $contacts,customType: $customType, assetList: $assetList, duration: $duration, captionMessage: $caption,replyMessage: $replyMessage, senderInfo : $senderInfo  phoneIsoCode : $phoneIsoCode, phone : $phone, countryCode : $countryCode,aboutText : $aboutText)';

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
        listEquals(other.assetList, assetList) &&
        other.duration == duration &&
        other.caption == caption &&
        other.replyMessage == replyMessage &&
        other.senderInfo == senderInfo &&
        other.phoneIsoCode == phoneIsoCode &&
        other.phone == phone &&
        other.countryCode == countryCode &&
        other.aboutText == aboutText;
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
      assetList.hashCode ^
      duration.hashCode ^
      caption.hashCode ^
      replyMessage.hashCode ^
      senderInfo.hashCode ^
      phone.hashCode ^
      phoneIsoCode.hashCode ^
      countryCode.hashCode ^
      aboutText.hashCode;
}
