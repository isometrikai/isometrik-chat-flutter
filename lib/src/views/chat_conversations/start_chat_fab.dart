import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';
import 'package:flutter/material.dart';

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
