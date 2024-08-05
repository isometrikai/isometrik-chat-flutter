import 'dart:convert';

import 'package:isometrik_flutter_chat/src/models/user_details_model.dart';
import 'package:azlistview/azlistview.dart';
import 'package:get/get.dart';

class SelectedMembers extends ISuspensionBean {
  factory SelectedMembers.fromJson(String source) =>
      SelectedMembers.fromMap(json.decode(source) as Map<String, dynamic>);

  factory SelectedMembers.fromMap(Map<String, dynamic> map) => SelectedMembers(
        isUserSelected: map['isUserSelected'] as bool? ?? false,
        userDetails: map['userDetails'] != null
            ? UserDetails.fromMap(map['userDetails'] as Map<String, dynamic>)
            : UserDetails(
                online: false,
                userName: '',
                lastSeen: 0,
                userId: '',
                userIdentifier: '',
                userProfileImageUrl: '',
              ),
        isBlocked: map['isBlocked'] as bool? ?? false,
        tagIndex: map['tagIndex'] as String? ?? '',
      );

  SelectedMembers({
    required bool isUserSelected,
    required this.userDetails,
    required this.isBlocked,
    this.tagIndex,
    this.localContacts,
  }) : _isUserSelected = isUserSelected.obs;

  final RxBool _isUserSelected;
  final UserDetails userDetails;
  final bool isBlocked;
  String? tagIndex;
  final bool? localContacts;

  bool get isUserSelected => _isUserSelected.value;
  set isUserSelected(bool value) => _isUserSelected.value = value;

  SelectedMembers copyWith({
    bool? isUserSelected,
    UserDetails? userDetails,
    bool? isBlocked,
    String? tagIndex,
  }) =>
      SelectedMembers(
          isUserSelected: isUserSelected ?? this.isUserSelected,
          userDetails: userDetails ?? this.userDetails,
          isBlocked: isBlocked ?? this.isBlocked,
          tagIndex: tagIndex ?? this.tagIndex);

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isUserSelected': isUserSelected,
        'userDetails': userDetails.toMap(),
        'isBlocked': isBlocked,
        'tagIndex': tagIndex
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'SelectedForwardUser(isUserSelected: $isUserSelected, userDetails: $userDetails, isBlocked: $isBlocked, tagIndex: $tagIndex)';

  @override
  bool operator ==(covariant SelectedMembers other) {
    if (identical(this, other)) return true;

    return other.isUserSelected == isUserSelected &&
        other.userDetails == userDetails &&
        other.isBlocked == isBlocked &&
        other.tagIndex == tagIndex;
  }

  @override
  int get hashCode =>
      isUserSelected.hashCode ^
      userDetails.hashCode ^
      isBlocked.hashCode ^
      tagIndex.hashCode;

  @override
  String getSuspensionTag() => tagIndex ?? '';
}
