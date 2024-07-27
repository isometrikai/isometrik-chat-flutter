import 'package:flutter/material.dart';

class IsmChatTapHandler extends StatelessWidget {
  const IsmChatTapHandler({
    super.key,
    this.onTap,
    this.behavior,
    this.onLongPress,
    required this.child,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final HitTestBehavior? behavior;
  final Widget child;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        hitTestBehavior: behavior ?? HitTestBehavior.translucent,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          behavior: behavior ?? HitTestBehavior.translucent,
          child: child,
        ),
      );
}
