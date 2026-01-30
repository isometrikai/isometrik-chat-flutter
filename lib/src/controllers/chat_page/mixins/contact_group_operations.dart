part of '../chat_page_controller.dart';

/// Contact and group operations mixin for IsmChatPageController.
///
/// This mixin handles contact search, selection, group member operations,
/// and mention functionality.
mixin IsmChatPageContactGroupOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatPageController get _controller => this as IsmChatPageController;

  /// Searches contacts based on the provided query.
  void onContactSearch(String query) {
    if (query.trim().isEmpty) {
      _controller.contactList = _controller.searchContactList;
      _controller.isLoadingContact = false;
    } else {
      _controller.contactList = _controller.searchContactList
          .where(
            (e) =>
                (e.contact.displayName.didMatch(query)) ||
                e.contact.phones.first.number.didMatch(query),
          )
          .toList();
      if (_controller.contactList.isEmpty) {
        _controller.isLoadingContact = true;
      }
    }

    _controller.commonController
        .handleSorSelectedContact(_controller.contactList);
  }

  /// Handles contact selection/deselection in the contact screen.
  void onSelectedContactTap(int index, SelectedContact contact) {
    _controller.contactList[index].isConotactSelected =
        !_controller.contactList[index].isConotactSelected;
    final checkContact = _controller.contactSelectedList
        .any((e) => e.contact.id == contact.contact.id);
    if (checkContact) {
      _controller.contactSelectedList
          .removeWhere((e) => e.contact.id == contact.contact.id);
    } else {
      _controller.contactSelectedList.add(contact);
    }
  }

  /// Sets contact list with selected contacts marked.
  void setContatWithSelectedContact() {
    var temContactList = <SelectedContact>[];
    for (final contact in _controller.searchContactList) {
      final checkContact = _controller.contactSelectedList
          .any((e) => e.contact.id == contact.contact.id);
      contact.isConotactSelected = checkContact;
      temContactList.add(contact);
    }
    _controller.contactList.clear();
    _controller.contactList = temContactList;
  }

  /// Handles group eligible user selection/deselection.
  void onGrouEligibleUserTap(int index) {
    _controller.groupEligibleUser[index].isUserSelected =
        !_controller.groupEligibleUser[index].isUserSelected;
  }

  /// Searches group members based on the provided query.
  /// Ensures the current user always appears first in the list.
  void onGroupSearch(String query) {
    // Get current user ID to ensure they appear first in the list
    final currentUserId = IsmChatConfig.communicationConfig.userConfig.userId;

    if (query.trim().isEmpty) {
      _controller.groupMembers = List.from(_controller.conversation!.members!);
    } else {
      _controller.groupMembers = _controller.conversation!.members!
          .where(
            (e) => [
              e.userName,
              e.userIdentifier,
            ].any(
              (e) => e.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            ),
          )
          .toList();
    }

    // Sort members: current user first, then others alphabetically
    _controller.groupMembers.sort((a, b) {
      // If one is the current user, it should come first
      if (a.userId == currentUserId) return -1;
      if (b.userId == currentUserId) return 1;
      // Otherwise, sort alphabetically by username
      return a.userName.toLowerCase().compareTo(b.userName.toLowerCase());
    });
  }

  /// Searches for participants to add to a group.
  void addParticipantSearch(String query) {
    if (query.trim().isEmpty) {
      // Reset to all eligible users when search is cleared
      _controller.groupEligibleUser = _controller.groupEligibleUserDuplicate;
      return;
    }

    // Use debounce to delay API call until user stops typing (matches 1-to-1 chat behavior)
    _controller.ismChatDebounce.run(() {
      // Call API with search query to get filtered results from server
      _controller.getEligibleMembers(
        conversationId: _controller.conversation?.conversationId ?? '',
        limit: 20,
        searchTag: query.trim(),
        isLoading: false,
      );
    });
  }

  /// Shows or hides the mention user list based on the input value.
  void showMentionsUserList(String value) async {
    if (!_controller.conversation!.isGroup!) {
      return;
    }
    _controller.showMentionUserList = value.split(' ').last.contains('@');
    if (!_controller.showMentionUserList) {
      _controller.mentionSuggestions.clear();
      return;
    }
    var query = value.split('@').last;
    _controller.mentionSuggestions = _controller.groupMembers
        .where((e) => e.userName.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// Updates the mention user in the input field.
  void updateMentionUser(String value) {
    final tempList = _controller.chatInputController.text.split('@');
    final remainingText = tempList.sublist(0, tempList.length - 1).join('@');
    final updatedText = '$remainingText@${value.capitalizeFirst} ';
    _controller.showMentionUserList = false;
    _controller.chatInputController.value =
        _controller.chatInputController.value.copyWith(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: updatedText.length,
      ),
    );
  }

  /// Gets the list of mentioned users from the message data.
  Future<void> getMentionedUserList(String data) async {
    _controller.userMentionedList.clear();
    final mentionedList = (data.split('@').toList())
      ..removeWhere((e) => e.trim().isEmpty);

    for (var x = 0; x < _controller.groupMembers.length; x++) {
      final checkerLength =
          _controller.groupMembers[x].userName.trim().split(' ').first.length;
      if (mentionedList.isNotEmpty) {
        final isMember = mentionedList.where(
          (e) =>
              checkerLength == e.trim().length &&
              _controller.groupMembers[x].userName
                  .trim()
                  .toLowerCase()
                  .contains(
                    e.trim().substring(0, checkerLength).toLowerCase(),
                  ),
        );
        if (isMember.isNotEmpty) {
          _controller.userMentionedList.add(
            MentionModel(
              wordCount: _controller.groupMembers[x].userName.split(' ').length,
              userId: _controller.groupMembers[x].userId,
              order: x,
            ),
          );
        }
      }
    }
  }
}
