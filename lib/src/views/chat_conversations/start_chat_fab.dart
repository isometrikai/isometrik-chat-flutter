import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatStartChatFAB extends StatelessWidget {
  const IsmChatStartChatFAB({required this.onTap, this.icon, super.key});

  final VoidCallback onTap;
  final Widget? icon;

  @override
  Widget build(BuildContext context) => Theme(
        data: ThemeData.light(useMaterial3: true).copyWith(
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: IsmChatConfig.chatTheme.primaryColor,
          ),
        ),
        child: FloatingActionButton(
          onPressed: onTap,
          child: icon ??
              Icon(
                Icons.chat_rounded,
                color: IsmChatConfig
                    .chatTheme.floatingActionButtonTheme!.foregroundColor,
              ),
        ),
      );
}
