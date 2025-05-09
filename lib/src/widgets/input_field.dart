import 'package:flutter/material.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';

class IsmChatInputField extends StatelessWidget {
  const IsmChatInputField({
    this.controller,
    this.padding,
    this.suffixIcon,
    this.hint,
    this.onChanged,
    this.fillColor,
    this.cursorColor,
    this.textInputAction,
    this.style,
    this.autofocus,
    this.hintStyle,
    this.onFieldSubmitted,
    this.maxLines,
    this.minLines,
    this.textCapitalization,
    this.readOnly = false,
    this.focusNode,
    this.contentPadding,
    this.borderColor,
    this.borderRadius,
    this.isShowBorderColor = false,
    super.key,
  });
  final FocusNode? focusNode;
  final TextEditingController? controller;
  final Widget? suffixIcon;
  final String? hint;
  final EdgeInsetsGeometry? padding;
  final Function(String)? onChanged;
  final Color? fillColor;
  final Color? cursorColor;
  final TextInputAction? textInputAction;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final bool? autofocus;
  final Function(String)? onFieldSubmitted;
  final int? maxLines;
  final int? minLines;
  final TextCapitalization? textCapitalization;
  final bool readOnly;
  final EdgeInsets? contentPadding;
  final bool isShowBorderColor;
  final Color? borderColor;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding ?? IsmChatDimens.edgeInsets10_4,
        child: TextFormField(
          focusNode: focusNode,
          maxLines: maxLines,
          minLines: minLines,
          textCapitalization:
              textCapitalization ?? TextCapitalization.sentences,
          cursorColor: cursorColor ?? IsmChatColors.whiteColor,
          controller: controller,
          textInputAction: textInputAction ?? TextInputAction.search,
          autofocus: autofocus ?? true,
          style: style ?? IsmChatStyles.w500White16,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintStyle ?? IsmChatStyles.w400Grey12,
            contentPadding: contentPadding ?? IsmChatDimens.edgeInsets10,
            isDense: true,
            isCollapsed: true,
            filled: true,
            fillColor: fillColor ?? IsmChatConfig.chatTheme.backgroundColor,
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(borderRadius ?? IsmChatDimens.ten),
              borderSide: BorderSide(
                color: isShowBorderColor
                    ? borderColor ??
                        IsmChatConfig.chatTheme.chatPageTheme?.textFiledTheme
                            ?.borderColor ??
                        IsmChatConfig.chatTheme.primaryColor!
                    : IsmChatColors.transparent,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          enableSuggestions: false,
        ),
      );
}
