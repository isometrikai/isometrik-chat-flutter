/// List and Iterable-related extensions for the Isometrik Chat Flutter SDK.
///
/// This file contains extensions on List and Iterable types for common
/// list operations like filtering, merging, and unique elements.

import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

/// Extension for nullable Iterable to check if it's null or empty.
extension NullCheck<T> on Iterable<T>? {
  /// Returns true if the iterable is null or empty.
  bool get isNullOrEmpty => this == null || this?.isEmpty == true;
}

/// Extension for List of SelectedMembers to get selected users.
extension SelectedUsers on List<SelectedMembers> {
  /// Returns a list of selected members where isUserSelected is true.
  List<SelectedMembers> get selectedUsers =>
      where((e) => e.isUserSelected).toList();
}

/// Extension for List of SelectedContact to get selected contacts.
extension SelectedContacts on List<SelectedContact> {
  /// Returns a list of selected contacts where isConotactSelected is true.
  List<SelectedContact> get selectedContact =>
      where((e) => e.isConotactSelected).toList();
}

/// Extension for List to get unique elements.
extension UniqueElements<T> on List<T> {
  /// Returns a new list containing only unique elements.
  List<T> unique() => [
        ...{...this}
      ];
}

/// Extension for List of IsmChatConversationModel to count unread messages.
extension ConversationCount on List<IsmChatConversationModel> {
  /// Returns the count of conversations with unread messages.
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

/// Extension for List of Lists to merge them.
extension ListMerging<T> on List<List<T>?> {
  /// Merges all lists into a single list.
  List<T> merge() => fold([], (a, b) {
        a.addAll(b ?? []);
        return a;
      });

  /// Merges all lists with an optional separator between each list.
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

