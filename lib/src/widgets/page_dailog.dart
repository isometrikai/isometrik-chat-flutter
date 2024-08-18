import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatPageDailog extends StatelessWidget {
  const IsmChatPageDailog({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IsmChatDimens.twelve),
        ),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: IsmChatDimens.percentWidth(.35),
            maxHeight: IsmChatDimens.percentHeight(.9),
          ),
          child: child,
        ),
      );
}
