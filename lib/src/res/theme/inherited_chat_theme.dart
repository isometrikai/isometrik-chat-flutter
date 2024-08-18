import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/res/res.dart';

class IsmChatTheme extends StatelessWidget {
  const IsmChatTheme({
    super.key,
    required this.chatThemeData,
    required this.child,
  });

  final IsmChatThemeData chatThemeData;
  final Widget child;

  static final IsmChatThemeData _kFallbackTheme = IsmChatThemeData.fallback();

  static IsmChatThemeData of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_InheritedChatTheme>()
          ?.chatTheme
          .chatThemeData ??
      _kFallbackTheme;

  @override
  Widget build(BuildContext context) => _InheritedChatTheme(
        chatTheme: this,
        child: child,
      );
}

///
class _InheritedChatTheme extends InheritedTheme {
  const _InheritedChatTheme({
    required this.chatTheme,
    required super.child,
  });

  final IsmChatTheme chatTheme;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      oldWidget.child != child;

  @override
  Widget wrap(BuildContext context, Widget child) => _InheritedChatTheme(
        chatTheme: chatTheme,
        child: child,
      );
}
