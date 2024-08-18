import 'package:flutter/widgets.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPopupMenuItem {
  IsmChatPopupMenuItem({
    required this.label,
    required this.icon,
    this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color? color;
  final void Function(IsmChatConversationModel) onTap;

  @override
  String toString() =>
      'IsmChatPopupMenuItem(label: $label, icon: $icon, color: $color, onTap: $onTap)';

  @override
  bool operator ==(covariant IsmChatPopupMenuItem other) {
    if (identical(this, other)) return true;

    return other.label == label && other.icon == icon && other.color == color;
  }

  @override
  int get hashCode =>
      label.hashCode ^ icon.hashCode ^ color.hashCode ^ onTap.hashCode;
}
