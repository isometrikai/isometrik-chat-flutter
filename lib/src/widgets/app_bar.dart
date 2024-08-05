import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_flutter_chat/isometrik_flutter_chat.dart';

@protected
class IsmChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const IsmChatAppBar({
    required this.title,
    this.onBack,
    this.height,
    this.action,
    this.backIcon,
    this.leading,
    this.leadingWidth,
    this.shadowColor,
    this.backgroundColor,
    this.centerTitle,
    this.elevation,
    this.shape,
    this.surfaceTintColor,
    this.titleSpacing,
    this.bottom,
    super.key,
  });

  final double? height;
  final Widget title;
  final IconData? backIcon;

  final VoidCallback? onBack;

  final Color? shadowColor;

  final Color? surfaceTintColor;

  final Color? backgroundColor;

  final Widget? leading;

  final bool? centerTitle;

  final List<Widget>? action;

  final ShapeBorder? shape;
  final double? titleSpacing;

  final double? elevation;

  final double? leadingWidth;

  final PreferredSizeWidget? bottom;

  @override
  Size get preferredSize =>
      Size.fromHeight(height ?? IsmChatDimens.appBarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        bottom: bottom,
        titleSpacing: titleSpacing,
        centerTitle: centerTitle ?? true,
        shape: shape,
        elevation: elevation,
        surfaceTintColor: surfaceTintColor,
        shadowColor: shadowColor,
        leadingWidth: leadingWidth,
        backgroundColor: backgroundColor ??
            IsmChatConfig.chatTheme.chatPageHeaderTheme?.backgroundColor ??
            IsmChatConfig.chatTheme.primaryColor,
        leading: leading ??
            IconButton(
              onPressed: onBack ?? Get.back,
              icon: Icon(
                IsmChatResponsive.isWeb(context)
                    ? Icons.close_rounded
                    : backIcon ?? Icons.arrow_back_rounded,
                color: IsmChatConfig.chatTheme.chatPageHeaderTheme?.iconColor ??
                    IsmChatColors.whiteColor,
              ),
            ),
        title: title,
        actions: action,
      );
}
