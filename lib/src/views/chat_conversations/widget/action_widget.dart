// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/src/widgets/widgets.dart';

class IsmChatActionWidget extends StatelessWidget {
  const IsmChatActionWidget({
    super.key,
    required this.onTap,
    this.decoration,
    required this.icon,
    this.label,
    this.labelStyle,
  });

  final VoidCallback onTap;
  final Decoration? decoration;
  final Widget icon;
  final String? label;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) => Expanded(
        flex: 1,
        child: IsmChatTapHandler(
          onTap: onTap,
          child: Container(
            alignment: Alignment.center,
            decoration: decoration,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                if (label != null && labelStyle != null)
                  Text(
                    label!,
                    style: labelStyle,
                  )
              ],
            ),
          ),
        ),
      );
}
