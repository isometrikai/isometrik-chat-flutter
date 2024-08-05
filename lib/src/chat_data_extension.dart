import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

class IsmChatDataExtension extends ThemeExtension<IsmChatDataExtension> {
  IsmChatDataExtension({
    this.theme,
  });

  final IsmChatThemeData? theme;

  @override
  ThemeExtension<IsmChatDataExtension> copyWith({
    IsmChatThemeData? theme,
  }) =>
      IsmChatDataExtension(theme: theme ?? this.theme);

  @override
  ThemeExtension<IsmChatDataExtension> lerp(
      covariant ThemeExtension<IsmChatDataExtension>? other, double t) {
    if (other is! IsmChatDataExtension) {
      return this;
    }
    return IsmChatDataExtension(theme: theme?.lerp(other.theme, t));
  }
}
