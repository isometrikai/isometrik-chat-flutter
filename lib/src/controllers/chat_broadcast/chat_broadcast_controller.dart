import 'dart:async';

import 'package:azlistview/azlistview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Controller for managing broadcast-related functionality in the chat system.
/// Handles broadcast creation, updates, member management, and listing.
class IsmChatBroadcastController extends GetxController {
  /// Creates a new instance of `IsmChatBroadcastController`.
  ///
  /// Requires an [IsmChatBroadcastViewModel] for handling business logic.
  IsmChatBroadcastController(this._viewModel);

  /// View model for handling broadcast-related business logic.
  final IsmChatBroadcastViewModel _viewModel;

  /// Debouncer for handling rapid user interactions.
  final debounce = IsmChatDebounce();

  /// Current broadcast being managed.
  BroadcastModel? broadcast;

  /// Controller for broadcast name input.
  TextEditingController broadcastName = TextEditingController();

  /// Controller for member search input.
  TextEditingController searchMemberController = TextEditingController();

  /// Controller for handling pull-to-refresh functionality.
  final refreshController = RefreshController(
    initialRefresh: false,
    initialLoadStatus: LoadStatus.idle,
  );

  /// Observable list of broadcast members.
  final _broadcastMembers = Rx<BroadcastMemberModel?>(null);
  BroadcastMemberModel? get broadcastMembers => _broadcastMembers.value;
  set broadcastMembers(BroadcastMemberModel? value) {
    _broadcastMembers.value = value;
  }

  /// Observable list of broadcasts.
  final _broadcastList = <BroadcastModel>[].obs;
  List<BroadcastModel> get broadcastList => _broadcastList;
  set broadcastList(List<BroadcastModel> value) {
    _broadcastList.value = value;
  }

  /// Observable list of eligible members for broadcast.
  final _eligibleMembers = <SelectedMembers>[].obs;
  List<SelectedMembers> get eligibleMembers => _eligibleMembers;
  set eligibleMembers(List<SelectedMembers> value) {
    _eligibleMembers.value = value;
  }

  /// Duplicate list of eligible members for comparison and restoration.
  List<SelectedMembers> eligibleMembersduplicate = [];

  /// Observable list of selected users.
  final _selectedUserList = <UserDetails>[].obs;
  List<UserDetails> get selectedUserList => _selectedUserList;
  set selectedUserList(List<UserDetails> value) {
    _selectedUserList.value = value;
  }

  /// Observable flag for search field visibility.
  final _showSearchField = false.obs;
  bool get showSearchField => _showSearchField.value;
  set showSearchField(bool value) => _showSearchField.value = value;

  /// Observable flag for API call state.
  final _isApiCall = false.obs;
  bool get isApiCall => _isApiCall.value;
  set isApiCall(bool value) {
    _isApiCall.value = value;
  }

  /// Retrieves broadcasts with pagination support.
  ///
  /// Parameters:
  /// - `isShowLoader`: Whether to show loading indicator
  /// - `isloading`: Whether the request is loading
  /// - `skip`: Number of items to skip for pagination
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

  /// Deletes a broadcast group.
  ///
  /// - `groupcastId`: ID of the broadcast to delete
  /// - `isloading`: Whether to show loading indicator
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

  /// Updates an existing broadcast.
  ///
  /// - `groupcastId`: ID of the broadcast to update
  /// - `isloading`: Whether to show loading indicator
  /// - `searchableTags`: Optional tags for searching
  /// - `metaData`: Optional metadata for the broadcast
  /// - `groupcastTitle`: Optional new title
  /// - `groupcastImageUrl`: Optional new image URL
  /// - `customType`: Optional custom type
  /// - `shouldCallBack`: Whether to navigate back after update
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
    // Preserve existing broadcast values if not provided
    // This ensures at least one field is always included in the update
    final existingBroadcast = broadcastList.firstWhereOrNull(
      (b) => b.groupcastId == groupcastId,
    );

    // Use provided values, or fall back to existing values if not provided or empty
    final finalGroupcastTitle =
        (groupcastTitle != null && groupcastTitle.isNotEmpty)
            ? groupcastTitle
            : existingBroadcast?.groupcastTitle;
    final finalGroupcastImageUrl =
        (groupcastImageUrl != null && groupcastImageUrl.isNotEmpty)
            ? groupcastImageUrl
            : existingBroadcast?.groupcastImageUrl;
    final finalCustomType = (customType != null && customType.isNotEmpty)
        ? customType
        : existingBroadcast?.customType?.toString();
    final finalMetaData = metaData ?? existingBroadcast?.metaData?.toMap();
    final finalSearchableTags =
        searchableTags ?? existingBroadcast?.searchableTags;

    final response = await _viewModel.updateBroadcast(
      groupcastId: groupcastId,
      customType: finalCustomType,
      groupcastImageUrl: finalGroupcastImageUrl,
      groupcastTitle: finalGroupcastTitle,
      isloading: isloading,
      metaData: finalMetaData,
      searchableTags: finalSearchableTags,
    );
    if (response && shouldCallBack) {
      unawaited(getBroadCast(
        isShowLoader: false,
        isloading: false,
      ));
      IsmChatRoute.goBack();
    }
  }

  /// Retrieves members of a broadcast group.
  ///
  /// - `groupcastId`: ID of the broadcast
  /// - `isloading`: Whether to show loading indicator
  /// - `skip`: Number of items to skip for pagination
  /// - `limit`: Maximum number of items to retrieve
  /// - `ids`: Optional list of specific member IDs to retrieve
  /// - `searchTag`: Optional search tag to filter members
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

  /// Removes members from a broadcast group.
  ///
  /// - `broadcast`: The broadcast model containing group information
  /// - `isloading`: Whether to show loading indicator
  /// - `members`: List of member IDs to remove
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
      // Get current broadcast from list to ensure we have latest metadata
      final currentBroadcast = broadcastList.firstWhereOrNull(
            (b) => b.groupcastId == broadcast.groupcastId,
          ) ??
          broadcast;

      // Get existing membersDetail and remove all specified members
      final existingMembers = currentBroadcast.metaData?.membersDetail ?? [];
      final memberIdsToRemove = members.toSet();
      final updatedMembers = existingMembers
          .where((member) => !memberIdsToRemove.contains(member.memberId))
          .toList();

      // Create updated metadata with remaining members
      final updatedMetadata = BroadcastMetadata(
        membersDetail: updatedMembers,
      );

      // Update the broadcast object
      if (this.broadcast?.groupcastId == broadcast.groupcastId) {
        this.broadcast = this.broadcast!.copyWith(metaData: updatedMetadata);
      }

      // Update broadcast with updated metadata (remove members from metadata)
      await updateBroadcast(
        groupcastId: broadcast.groupcastId ?? '',
        metaData: updatedMetadata.toMap(),
        isloading: false,
      );

      // Refresh broadcast list to update member count and names
      await getBroadCast(
        isShowLoader: false,
        isloading: false,
      );

      // Refresh broadcast members list
      await getBroadcastMembers(
        groupcastId: broadcast.groupcastId ?? '',
        isloading: true,
      );
    }
  }

  /// Retrieves eligible members for a broadcast group.
  ///
  /// - `groupcastId`: ID of the broadcast
  /// - `isloading`: Whether to show loading indicator
  /// - `skip`: Number of items to skip for pagination
  /// - `limit`: Maximum number of items to retrieve
  /// - `searchTag`: Optional search tag to filter eligible members
  /// - `shouldShowLoader`: Whether to show loading indicator
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
    final users = response ?? [];

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

  /// Handles sorting and indexing of member list for UI display.
  ///
  /// - `list`: List of selected members to process
  void handleList(List<SelectedMembers> list) {
    if (list.isEmpty) return;
    for (var i = 0, length = list.length; i < length; i++) {
      final tag = list[i].userDetails.userName[0].toUpperCase();
      final isLocal = list[i].localContacts ?? false;
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

  /// Toggles selection state of an eligible member.
  ///
  /// - `index`: Index of the member in the eligible members list
  void onEligibleMemberTap(int index) {
    eligibleMembers[index].isUserSelected =
        !eligibleMembers[index].isUserSelected;
  }

  /// Updates the selection state of a user in the selected members list.
  ///

  /// - `userDetails`: User details to update selection status
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

  /// Adds eligible members to a broadcast group.
  ///
  /// - `groupcastId`: ID of the broadcast
  /// - `members`: List of user details to add as members
  ///
  /// This method:
  /// 1. Adds new members to the broadcast
  /// 2. Updates the broadcast metadata with new member details
  /// 3. Refreshes the broadcast members list
  /// 4. Updates the broadcast with new metadata
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
        // Get current broadcast from list to ensure we have latest metadata
        final currentBroadcast = broadcastList.firstWhereOrNull(
              (b) => b.groupcastId == groupcastId,
            ) ??
            broadcast;

        // Get existing membersDetail from current broadcast
        final existingMembers = currentBroadcast?.metaData?.membersDetail ?? [];

        // Create new member details list
        final newMemberList = members
            .map(
              (e) => MembersDetail(memberId: e.userId, memberName: e.userName),
            )
            .toList();

        // Merge existing and new members, avoiding duplicates
        final allMembers = <MembersDetail>[];
        final existingMemberIds =
            existingMembers.map((e) => e.memberId).toSet();

        // Add existing members
        allMembers.addAll(existingMembers);

        // Add new members that don't already exist
        for (final newMember in newMemberList) {
          if (!existingMemberIds.contains(newMember.memberId)) {
            allMembers.add(newMember);
          }
        }

        // Update broadcast metadata with all members
        final updatedMetadata = BroadcastMetadata(
          membersDetail: allMembers,
        );

        // Update the broadcast object
        if (broadcast != null) {
          broadcast = broadcast!.copyWith(metaData: updatedMetadata);
        }

        await getBroadcastMembers(
          groupcastId: groupcastId,
          isloading: true,
        );

        // Refresh broadcast list to update member count
        await getBroadCast(
          isShowLoader: false,
          isloading: false,
        );

        // Update broadcast with complete metadata including all members
        unawaited(
          updateBroadcast(
            groupcastId: groupcastId,
            metaData: updatedMetadata.toMap(),
            shouldCallBack: true,
          ),
        );
      }
    } catch (_) {
      IsmChatRoute.goBack();
    }
  }
}
