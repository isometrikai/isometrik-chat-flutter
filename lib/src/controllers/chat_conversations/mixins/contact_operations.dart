part of '../chat_conversations_controller.dart';

/// Contact operations mixin for IsmChatConversationsController.
///
/// This mixin contains methods related to contact management including
/// fetching contacts, loading contacts in background, searching local contacts,
/// and managing contact synchronization.
mixin IsmChatConversationsContactOperationsMixin on GetxController {
  /// Gets the controller instance.
  IsmChatConversationsController get _controller =>
      this as IsmChatConversationsController;

  /// Fetches a list of non-blocked users for creating chats or forwarding messages.
  ///
  /// Will be used for Create chat and/or Forward message
  ///  `sort`: Sorting order.
  ///  `skip`: Number of users to skip.
  ///  `limit`: Maximum number of users to return.
  ///  `searchTag`: Search term for filtering users.
  ///  `opponentId`: ID of the opponent to exclude.
  ///  `isLoading`: Indicates if loading should be shown.
  ///  `isGroupConversation`: Indicates if the conversation is a group chat.
  Future<List<SelectedMembers>?> getNonBlockUserList({
    int sort = 1,
    int skip = 0,
    int limit = 20,
    String searchTag = '',
    String? opponentId,
    bool isLoading = false,
    bool isGroupConversation = false,
  }) async {
    if (!_controller.callApiOrNot) return null;
    _controller.callApiOrNot = false;
    final response = await _controller.viewModel.getNonBlockUserList(
      sort: sort,
      skip: searchTag.isNotEmpty
          ? 0
          : _controller.forwardedList.isEmpty
              ? 0
              : _controller.forwardedList.length.pagination(),
      limit: limit,
      searchTag: searchTag,
      isLoading: isLoading,
    );

    final users = response?.users ?? [];
    if (users.isEmpty) {
      _controller.isLoadResponse = true;
    }
    users.sort((a, b) => a.userName.compareTo(b.userName));

    if (opponentId != null) {
      users.removeWhere((e) => e.userId == opponentId);
    }

    if (searchTag.isEmpty) {
      _controller.forwardedList.addAll(List.from(users)
          .map((e) => SelectedMembers(
                isUserSelected: _controller.selectedUserList.isEmpty
                    ? false
                    : _controller.selectedUserList
                        .any((d) => d.userId == (e as UserDetails).userId),
                userDetails: e as UserDetails,
                isBlocked: false,
              ))
          .toList());
      _controller.forwardedListDuplicat = List<SelectedMembers>.from(_controller.forwardedList);
    } else {
      _controller.forwardedList = List.from(users)
          .map(
            (e) => SelectedMembers(
              isUserSelected: _controller.selectedUserList.isEmpty
                  ? false
                  : _controller.selectedUserList
                      .any((d) => d.userId == (e as UserDetails).userId),
              userDetails: e as UserDetails,
              isBlocked: false,
            ),
          )
          .toList();
    }

    if (response != null) {
      _controller.commonController.handleSorSelectedMembers(
        _controller.forwardedList,
      );
    }

    if (response == null && searchTag.isEmpty && isGroupConversation == false) {
      unawaited(_controller.getContacts(isLoading: isLoading, searchTag: searchTag));
      _controller.callApiOrNot = true;
      return _controller.forwardedList;
    }
    _controller.callApiOrNot = true;
    return _controller.forwardedList;
  }

  /// Loads all contacts in the background for A-Z navigation.
  ///
  /// This method continuously fetches contacts in batches until all contacts are loaded.
  /// It runs in the background and updates the forwardedList in batches to avoid frequent UI updates.
  Future<void> loadAllContactsInBackground({
    String? opponentId,
    bool isGroupConversation = false,
  }) async {
    // Prevent multiple background loading processes
    if (_controller.isLoadingAllContacts) return;

    _controller.isLoadingAllContacts = true;

    // Small delay to ensure initial load completes
    await Future.delayed(const Duration(milliseconds: 500));

    var skip = _controller.forwardedList.length;
    const limit = 20;
    var hasMoreContacts = true;

    // Batch contacts before updating UI (update every 3 batches = 60 contacts)
    final batchedContacts = <SelectedMembers>[];
    const batchUpdateSize = 3; // Update UI every 3 API calls
    var batchCount = 0;

    while (hasMoreContacts && _controller.callApiOrNot) {
      try {
        final response = await _controller.viewModel.getNonBlockUserList(
          sort: 1,
          skip: skip,
          limit: limit,
          searchTag: '',
          isLoading: false,
        );

        final users = response?.users ?? [];

        // If we get less than limit, we've reached the end
        if (users.isEmpty || users.length < limit) {
          hasMoreContacts = false;
        }

        if (users.isNotEmpty) {
          users.sort((a, b) => a.userName.compareTo(b.userName));

          if (opponentId != null) {
            users.removeWhere((e) => e.userId == opponentId);
          }

          // Filter out duplicates and current user
          final newUsers = users
              .where((user) =>
                  user.userId !=
                      IsmChatConfig.communicationConfig.userConfig.userId &&
                  !_controller.forwardedList.any((existing) =>
                      existing.userDetails.userId == user.userId) &&
                  !batchedContacts.any(
                      (existing) => existing.userDetails.userId == user.userId))
              .toList();

          if (newUsers.isNotEmpty) {
            final newMembers = newUsers
                .map((e) => SelectedMembers(
                      isUserSelected: _controller.selectedUserList.isEmpty
                          ? false
                          : _controller.selectedUserList.any((d) => d.userId == e.userId),
                      userDetails: e,
                      isBlocked: false,
                    ))
                .toList();

            batchedContacts.addAll(newMembers);
            batchCount++;
          }

          skip += users.length;

          // Update UI only after collecting multiple batches
          if (batchCount >= batchUpdateSize || !hasMoreContacts) {
            if (batchedContacts.isNotEmpty) {
              // Sort batched contacts before adding
              batchedContacts.sort((a, b) =>
                  a.userDetails.userName.compareTo(b.userDetails.userName));

              _controller.forwardedList.addAll(batchedContacts);
              _controller.forwardedListDuplicat = List<SelectedMembers>.from(_controller.forwardedList);

              // Sort and update suspension tags only once per batch update
              _controller.commonController.handleSorSelectedMembers(_controller.forwardedList);

              // Clear batched contacts
              batchedContacts.clear();
              batchCount = 0;
            }
          }
        } else {
          // Update remaining batched contacts before exiting
          if (batchedContacts.isNotEmpty) {
            batchedContacts.sort((a, b) =>
                a.userDetails.userName.compareTo(b.userDetails.userName));

            _controller.forwardedList.addAll(batchedContacts);
            _controller.forwardedListDuplicat = List<SelectedMembers>.from(_controller.forwardedList);
            _controller.commonController.handleSorSelectedMembers(_controller.forwardedList);
          }
          hasMoreContacts = false;
        }

        // Small delay between API calls to avoid overwhelming the server
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        IsmChatLog.error('Error loading contacts in background: $e');
        // Update remaining batched contacts before exiting on error
        if (batchedContacts.isNotEmpty) {
          batchedContacts.sort((a, b) =>
              a.userDetails.userName.compareTo(b.userDetails.userName));

          _controller.forwardedList.addAll(batchedContacts);
          _controller.forwardedListDuplicat = List<SelectedMembers>.from(_controller.forwardedList);
          _controller.commonController.handleSorSelectedMembers(_controller.forwardedList);
        }
        hasMoreContacts = false;
      }
    }

    _controller.isLoadingAllContacts = false;
  }

  /// Gets the list of alphabets that have contacts.
  ///
  /// Returns a list of alphabet letters (A-Z) that have at least one contact
  List<String> getAvailableAlphabets() {
    final availableLetters = <String>{};

    for (var member in _controller.forwardedList) {
      if (member.userDetails.userName.isNotEmpty) {
        final firstChar = member.userDetails.userName[0].toUpperCase();
        // Check if it's a valid letter (A-Z)
        if (firstChar.codeUnitAt(0) >= 'A'.codeUnitAt(0) &&
            firstChar.codeUnitAt(0) <= 'Z'.codeUnitAt(0)) {
          availableLetters.add(firstChar);
        }
      }
    }

    // Return sorted list
    final sortedList = availableLetters.toList()..sort();
    return sortedList;
  }

  /// Retrieves contacts from the server and updates the forwarded list.
  ///
  /// `isLoading`: Indicates if loading should be shown.
  /// `isRegisteredUser` : Indicates if only registered users should be fetched.
  /// `skip`: Number of contacts to skip.
  /// `limit`: Maximum number of contacts to return.
  /// `searchTag`: Optional search term for filtering contacts.
  Future<void> getContacts({
    bool isLoading = false,
    bool isRegisteredUser = false,
    int skip = 400,
    int limit = 20,
    String searchTag = '',
  }) async {
    if (IsmChatConfig.communicationConfig.userConfig.accessToken != null) {
      final res = await _controller.viewModel.getContacts(
        searchTag: searchTag,
        isLoading: isLoading,
        isRegisteredUser: isRegisteredUser,
        skip: _controller.getContactSyncUser.isNotEmpty
            ? _controller.getContactSyncUser.length.pagination()
            : 10,
        limit: limit,
      );

      if (res != null && (res.data ?? []).isNotEmpty) {
        _controller.getContactSyncUser.addAll(res.data ?? []);
        await _controller.removeDBUser();
        final forwardedListLocalList = <SelectedMembers>[];
        for (var e in _controller.getContactSyncUser) {
          if (_controller.hashMapSendContactSync[e.contactNo ?? ''] != null) {
            forwardedListLocalList.add(
              SelectedMembers(
                localContacts: true,
                isUserSelected: false,
                userDetails: UserDetails(
                    userProfileImageUrl: '',
                    userName: _controller.hashMapSendContactSync[e.contactNo ?? ''] ?? '',
                    userIdentifier:
                        '${e.countryCode ?? ''} ${e.contactNo ?? ''}',
                    userId: e.userId ?? '',
                    online: false,
                    lastSeen: DateTime.now().microsecondsSinceEpoch),
                isBlocked: false,
              ),
            );
          }
        }
        _controller.forwardedList.addAll(forwardedListLocalList);
      }
      _controller.commonController.handleSorSelectedMembers(
        _controller.forwardedList,
      );

      _controller.update();
    }
  }

  /// Fetches and fills the local contacts into a usable model.
  void fillContact() async {
    final localList = [];
    var contacts = await FlutterContacts.getContacts(
        withProperties: true, withPhoto: true);
    _controller.hashMapSendContactSync.clear();
    for (final x in contacts) {
      if (x.phones.isNotEmpty) {
        final phone = x.phones.first.number;
        if (!((phone.contains('@')) && (phone.contains('.com'))) &&
            x.displayName.isNotEmpty) {
          if (x.phones.isNotEmpty) {
            if (x.phones.first.number.contains('+')) {
              final code = x.phones.first.number.removeAllWhitespace;
              localList.add(
                ContactSyncModel(
                  contactNo: code.substring(3, code.length),
                  countryCode: code.substring(0, 3),
                  firstName: x.name.first,
                  fullName: '${x.name.first} ${x.name.last}',
                  lastName: x.name.last,
                ),
              );
              _controller.hashMapSendContactSync[code.substring(3, code.length)] =
                  '${x.name.first} ${x.name.last}';
              _controller.hashMapSendContactSync['${x.name.first} ${x.name.last}'] =
                  code.substring(3, code.length);
            } else if (x.phones.first.normalizedNumber.contains('+')) {
              final code = x.phones.first.normalizedNumber.removeAllWhitespace;
              localList.add(
                ContactSyncModel(
                  contactNo: code.substring(3, code.length),
                  countryCode: code.substring(0, 3),
                  firstName: x.name.first,
                  fullName: '${x.name.first} ${x.name.last}',
                  lastName: x.name.last,
                ),
              );
              _controller.hashMapSendContactSync[code.substring(3, code.length)] =
                  '${x.name.first} ${x.name.last}';
              _controller.hashMapSendContactSync['${x.name.first} ${x.name.last}'] =
                  code.substring(3, code.length);
            }
          }
        }
      }
    }
    _controller.sendContactSync.clear();
    _controller.sendContactSync = List.from(localList);
  }

  /// Requests permission to access contacts.
  Future<void> askPermissions() async {
    if (await IsmChatUtility.requestPermission(Permission.contacts)) {
      _controller.fillContact();
    }
  }

  /// Searches local contacts based on the provided search term.
  ///
  /// `search`: The search term to filter local contacts.
  void searchOnLocalContacts(String search) async {
    final filterContacts = _controller.sendContactSync
        .where((element) => (element.fullName ?? '').contains(search))
        .toList();
    for (var i in _controller.forwardedListSkip) {
      filterContacts.removeWhere((element) => i.userDetails.userIdentifier
          .trim()
          .contains(element.contactNo ?? '*~.'));
    }
    _controller.forwardedList.addAll(
      List.from(
        filterContacts.map(
          (e) => SelectedMembers(
            localContacts: true,
            isUserSelected: false,
            userDetails: UserDetails(
                userProfileImageUrl: '',
                userName: _controller.hashMapSendContactSync[e.contactNo] ?? '',
                userIdentifier: '${e.countryCode ?? ''} ${e.contactNo}',
                userId: e.userId ?? '',
                online: false,
                lastSeen: DateTime.now().microsecondsSinceEpoch),
            isBlocked: false,
          ),
        ),
      ),
    );
    _controller.commonController.handleSorSelectedMembers(
      _controller.forwardedList,
    );
  }

  /// Navigates to the contact synchronization page.
  Future<void> goToContactSync() async {
    // await askPermissions();
    await Future.delayed(Durations.extralong1);

    await IsmChatRoute.goToRoute(IsmChatCreateConversationView(
      isGroupConversation: false,
      conversationType: IsmChatConversationType.private,
    ));
  }

  /// Removes local users from the forwarded list.
  Future<void> removeDBUser() async {
    _controller.forwardedList.removeWhere((element) => element.localContacts == true);
  }

  /// Adds contacts to the server.
  Future<void> addContact({
    bool isLoading = true,
  }) async {
    final res = await _controller.viewModel.addContact(
      isLoading: isLoading,
      payload: ContactSync(
        createdUnderProjectId:
            IsmChatConfig.communicationConfig.projectConfig.projectId,
        data: _controller.sendContactSync,
      ).toJson(),
    );
    if (res != null) {}
  }
}

