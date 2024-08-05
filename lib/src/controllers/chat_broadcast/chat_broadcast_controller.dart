import 'dart:async';

import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmChatBroadcastController extends GetxController {
  IsmChatBroadcastController(this._viewModel);

  final IsmChatBroadcastViewModel _viewModel;

  final debounce = IsmChatDebounce();

  BroadcastModel? broadcast;

  TextEditingController broadcastName = TextEditingController();

  TextEditingController searchMemberController = TextEditingController();

  final refreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );

  final _broadcastMembers = Rx<BroadcastMemberModel?>(null);
  BroadcastMemberModel? get broadcastMembers => _broadcastMembers.value;
  set broadcastMembers(BroadcastMemberModel? value) {
    _broadcastMembers.value = value;
  }

  final _broadcastList = <BroadcastModel>[].obs;
  List<BroadcastModel> get broadcastList => _broadcastList;
  set broadcastList(List<BroadcastModel> value) {
    _broadcastList.value = value;
  }

  final _eligibleMembers = <SelectedMembers>[].obs;
  List<SelectedMembers> get eligibleMembers => _eligibleMembers;
  set eligibleMembers(List<SelectedMembers> value) {
    _eligibleMembers.value = value;
  }

  List<SelectedMembers> eligibleMembersduplicate = [];

  final _selectedUserList = <UserDetails>[].obs;
  List<UserDetails> get selectedUserList => _selectedUserList;
  set selectedUserList(List<UserDetails> value) {
    _selectedUserList.value = value;
  }

  final _showSearchField = false.obs;
  bool get showSearchField => _showSearchField.value;
  set showSearchField(bool value) => _showSearchField.value = value;

  final _isApiCall = false.obs;
  bool get isApiCall => _isApiCall.value;
  set isApiCall(bool value) {
    _isApiCall.value = value;
  }

  Future<void> getBroadCast({
    bool isShowLoader = true,
    bool isloading = false,
    int skip = 0,
  }) async {
    if (isShowLoader) isApiCall = true;

    final response = await _viewModel.getBroadCast(
      isloading: isloading,
      skip: skip,
    );
    if (skip == 0 && response != null) {
      broadcastList = response;
    } else if (skip != 0 && response != null) {
      broadcastList.addAll(response);
    } else if (skip == 0) {
      broadcastList.clear();
    }
    if (isShowLoader) isApiCall = false;
  }

  Future<void> deleteBroadcast({
    required String groupcastId,
    bool isloading = false,
  }) async {
    final respones = await _viewModel.deleteBroadcast(
        groupcastId: groupcastId, isloading: isloading);
    if (respones) {
      await getBroadCast(
        isShowLoader: false,
        isloading: isloading,
      );
    }
  }

  Future<void> updateBroadcast({
    required String groupcastId,
    bool isloading = false,
    List<String>? searchableTags,
    Map<String, dynamic>? metaData,
    String? groupcastTitle,
    String? groupcastImageUrl,
    String? customType,
    bool shouldCallBack = false,
  }) async {
    final response = await _viewModel.updateBroadcast(
      groupcastId: groupcastId,
      customType: customType,
      groupcastImageUrl: groupcastImageUrl,
      groupcastTitle: groupcastTitle,
      isloading: isloading,
      metaData: metaData,
      searchableTags: searchableTags,
    );
    if (response && shouldCallBack) {
      unawaited(getBroadCast(
        isShowLoader: false,
        isloading: false,
      ));
      Get.back();
    }
  }

  Future<void> getBroadcastMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    List<String>? ids,
    String? searchTag,
  }) async {
    final response = await _viewModel.getBroadcastMembers(
      groupcastId: groupcastId,
      isloading: isloading,
      ids: ids,
      limit: limit,
      searchTag: searchTag,
      skip: skip,
    );
    if (response != null) {
      broadcastMembers = response;
    }
  }

  Future<void> deleteBroadcastMember({
    required BroadcastModel broadcast,
    bool isloading = false,
    required List<String> members,
  }) async {
    final response = await _viewModel.deleteBroadcastMember(
      groupcastId: broadcast.groupcastId ?? '',
      members: members,
      isloading: isloading,
    );
    if (response != null) {
      final memberList = broadcast.metaData?.membersDetail ?? [];
      memberList.removeWhere((e) => e.memberId == members.first);
      broadcast.metaData?.copyWith(membersDetail: memberList);
      unawaited(
        updateBroadcast(
          groupcastId: broadcast.groupcastId ?? '',
          metaData: broadcast.metaData?.toMap(),
        ),
      );
      unawaited(getBroadCast(
        isShowLoader: false,
        isloading: false,
      ));
      await getBroadcastMembers(
          groupcastId: broadcast.groupcastId ?? '', isloading: true);
    }
  }

  Future<void> getEligibleMembers({
    required String groupcastId,
    bool isloading = false,
    int skip = 0,
    int limit = 20,
    String? searchTag,
    bool shouldShowLoader = true,
  }) async {
    if (shouldShowLoader) isApiCall = true;
    final response = await _viewModel.getEligibleMembers(
      groupcastId: groupcastId,
      isloading: isloading,
      skip: skip,
      limit: limit,
      searchTag: searchTag,
    );
    var users = response ?? [];

    if (searchTag.isNullOrEmpty) {
      eligibleMembers.addAll(List.from(users)
          .map((e) => SelectedMembers(
                isUserSelected: selectedUserList.isEmpty
                    ? false
                    : selectedUserList
                        .any((d) => d.userId == (e as UserDetails).userId),
                userDetails: e as UserDetails,
                isBlocked: false,
              ))
          .toList());
      eligibleMembersduplicate = List<SelectedMembers>.from(eligibleMembers);
    } else {
      eligibleMembers = List.from(users)
          .map(
            (e) => SelectedMembers(
              isUserSelected: selectedUserList.isEmpty
                  ? false
                  : selectedUserList
                      .any((d) => d.userId == (e as UserDetails).userId),
              userDetails: e as UserDetails,
              isBlocked: false,
            ),
          )
          .toList();
    }
    if (response != null) {
      handleList(eligibleMembers);
    }
    if (shouldShowLoader) isApiCall = false;
  }

  void handleList(List<SelectedMembers> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      var tag = list[i].userDetails.userName[0].toUpperCase();
      var isLocal = list[i].localContacts ?? false;
      if (RegExp('[A-Z]').hasMatch(tag) && isLocal == false) {
        list[i].tagIndex = tag;
      } else {
        if (isLocal == true) {
          list[i].tagIndex = '#';
        }
      }
    }

    // A-Z sort.
    SuspensionUtil.sortListBySuspensionTag(eligibleMembers);

    // show sus tag.
    SuspensionUtil.setShowSuspensionStatus(eligibleMembers);
  }

  void onEligibleMemberTap(int index) {
    eligibleMembers[index].isUserSelected =
        !eligibleMembers[index].isUserSelected;
  }

  void isSelectedMembers(UserDetails userDetails) {
    if (selectedUserList.isEmpty) {
      selectedUserList.add(userDetails);
    } else {
      if (selectedUserList.any((e) => e.userId == userDetails.userId)) {
        selectedUserList.removeWhere((e) => e.userId == userDetails.userId);
      } else {
        selectedUserList.add(userDetails);
      }
    }
  }

  Future<void> addEligibleMembers({
    required String groupcastId,
    required List<UserDetails> members,
  }) async {
    try {
      final response = await _viewModel.addEligibleMembers(
          groupcastId: groupcastId,
          members: members
              .map((e) => {
                    'newConversationTypingEvents': true,
                    'newConversationReadEvents': true,
                    'newConversationPushNotificationsEvents': true,
                    'newConversationCustomType': 'Broadcast',
                    'newConversationMetadata': {},
                    'memberId': e.userId
                  })
              .toList(),
          isloading: true);
      if (response != null) {
        final memberList = members
            .map(
              (e) => MembersDetail(memberId: e.userId, memberName: e.userName),
            )
            .toList();
        broadcast?.metaData?.membersDetail?.addAll(memberList);
        broadcast?.metaData?.copyWith(
          membersDetail: broadcast?.metaData?.membersDetail,
        );
        await getBroadcastMembers(
          groupcastId: groupcastId,
          isloading: true,
        );
        unawaited(
          updateBroadcast(
            groupcastId: groupcastId,
            metaData: broadcast?.metaData?.toMap(),
            shouldCallBack: true,
          ),
        );
      }
    } catch (_) {
      Get.back();
    }
  }
}
