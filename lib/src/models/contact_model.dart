import 'package:azlistview/azlistview.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class SelectedContact extends ISuspensionBean {
  SelectedContact({
    required bool isConotactSelected,
    required this.contact,
    this.tagIndex,
  }) : _isConotactSelected = isConotactSelected.obs;
  final RxBool _isConotactSelected;
  final Contact contact;
  String? tagIndex;

  bool get isConotactSelected => _isConotactSelected.value;
  set isConotactSelected(bool value) => _isConotactSelected.value = value;

  SelectedContact copyWith({
    bool? isConotactSelected,
    Contact? contact,
    String? tagIndex,
  }) =>
      SelectedContact(
        isConotactSelected: isConotactSelected ?? this.isConotactSelected,
        contact: contact ?? this.contact,
        tagIndex: tagIndex ?? this.tagIndex,
      );

  @override
  String toString() =>
      'SelectedContact(isConotactSelected: $isConotactSelected, contact: $contact, tagIndex: $tagIndex)';

  @override
  bool operator ==(covariant SelectedContact other) {
    if (identical(this, other)) return true;

    return other.isConotactSelected == isConotactSelected &&
        other.contact == contact &&
        other.tagIndex == tagIndex;
  }

  @override
  int get hashCode =>
      isConotactSelected.hashCode ^ contact.hashCode ^ tagIndex.hashCode;

  @override
  String getSuspensionTag() => tagIndex ?? '';
}
