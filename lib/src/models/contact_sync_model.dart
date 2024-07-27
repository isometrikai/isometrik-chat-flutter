// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

ContactSync contactSyncFromJson(String str) =>
    ContactSync.fromJson(json.decode(str));

String contactSyncToJson(ContactSync data) => json.encode(data.toJson());

class ContactSync {
  ContactSync({
    this.createdUnderProjectId,
    this.data,
    this.totalCount,
  });

  factory ContactSync.fromJson(Map<String, dynamic> json) => ContactSync(
        data: json['data'] == null
            ? []
            : List<ContactSyncModel>.from(json['data']!.map(
                (x) => ContactSyncModel.fromJson(x as Map<String, dynamic>))),
        totalCount: json['totalCount'] as int? ?? 0,
      );
  final String? createdUnderProjectId;
  final List<ContactSyncModel>? data;
  final int? totalCount;

  ContactSync copyWith({
    String? createdUnderProjectId,
    List<ContactSyncModel>? data,
  }) =>
      ContactSync(
        createdUnderProjectId:
            createdUnderProjectId ?? this.createdUnderProjectId,
        data: data ?? this.data,
      );

  Map<String, dynamic> toJson() => {
        'createdUnderProjectId': createdUnderProjectId,
        'contacts': data == null
            ? []
            : List.from(
                (data ?? []).map(
                  (x) => x.toJson(),
                ),
              ),
      };
}

class ContactSyncModel {
  ContactSyncModel({
    this.userId,
    this.isRegisteredUser,
    this.contactId,
    this.createdUnderProjectId,
    this.firstName,
    this.lastName,
    this.fullName,
    this.countryCode,
    this.contactNo,
  });

  factory ContactSyncModel.fromJson(Map<String, dynamic> json) =>
      ContactSyncModel(
        firstName: json['firstName'] as String? ?? '',
        lastName: json['lastName'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        countryCode: json['countryCode'] as String? ?? '',
        contactNo: json['contactNo'] as String? ?? '',
        createdUnderProjectId: json['createdUnderProjectId'] as String? ?? '',
        contactId: json['contactId'] as String? ?? '',
        isRegisteredUser: json['isRegisteredUser'] as bool? ?? false,
        userId: json['userId'] as String? ?? '',
      );
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? countryCode;
  final String? contactNo;
  final String? userId;
  final bool? isRegisteredUser;
  final String? contactId;
  final String? createdUnderProjectId;

  ContactSyncModel copyWith({
    String? firstName,
    String? lastName,
    String? fullName,
    String? countryCode,
    String? contactNo,
  }) =>
      ContactSyncModel(
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        fullName: fullName ?? this.fullName,
        countryCode: countryCode ?? this.countryCode,
        contactNo: contactNo ?? this.contactNo,
      );

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'fullName': fullName,
        'countryCode': countryCode,
        'contactNo': contactNo,
      };
}
