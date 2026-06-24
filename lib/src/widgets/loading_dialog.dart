import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatLoadingDialog extends StatelessWidget {
  const IsmChatLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final dialogTheme = IsmChatThemeResolver.dialogFromConfig(context);
    return StatusBarTransparent(
      child: IsmChatProperties.loadingDialog ??
          Center(
            child: SizedBox(
              height: 60,
              width: 60,
              child: Card(
                color: dialogTheme.backgroundColor,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    color: IsmChatConfig.chatTheme.primaryColor,
                  ),
                ),
              ),
            ),
          ),
    );
  }
}
