import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Link preview for chat messages using `flutter_link_previewer`.
///
/// Layout: square image → title → description → URL.
/// When [embedded] is true, the message text is shown by the parent bubble and
/// only the preview card is rendered here (same card as URL-only messages).
class LinkPreviewView extends StatefulWidget {
  const LinkPreviewView({
    super.key,
    required this.url,
    required this.message,
    this.width,
    this.embedded = false,
  });

  final String url;
  final IsmChatMessageModel message;

  /// When null, width follows chat bubble constraints.
  final double? width;

  /// Hides linkified message text — use when text is already shown above.
  final bool embedded;

  @override
  State<LinkPreviewView> createState() => _LinkPreviewViewState();
}

class _LinkPreviewViewState extends State<LinkPreviewView> {
  dynamic _previewData;

  Color _getLinkPreviewColor() {
    final theme = IsmChatConfig.chatTheme.chatPageTheme;
    if (widget.message.sentByMe) {
      return theme?.selfMessageTheme?.linkPreviewColor ??
          IsmChatColors.pureBlue;
    }
    return theme?.opponentMessageTheme?.linkPreviewColor ??
        IsmChatConfig.chatTheme.mentionColor ??
        IsmChatColors.pureBlue;
  }

  double _resolvePreviewWidth(BuildContext context) {
    if (widget.width != null) {
      return widget.width!;
    }

    final themeConstraints = IsmChatConfig
        .chatTheme.chatPageTheme?.messageConstraints?.messageConstraints;
    if (themeConstraints?.maxWidth != null &&
        themeConstraints!.maxWidth.isFinite) {
      return themeConstraints.maxWidth;
    }

    return IsmChatResponsive.isWeb(context)
        ? MediaQuery.sizeOf(context).width * 0.25
        : MediaQuery.sizeOf(context).width * 0.6;
  }

  Future<void> _openLink(String url) async {
    final uri = Uri.tryParse(url.convertToValidUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  TextStyle _titleStyle() => widget.message.style.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: (widget.message.style.fontSize ?? 14) + 2,
      );

  TextStyle _descriptionStyle() => widget.message.style;

  TextStyle _urlStyle(Color linkColor) => widget.message.style.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: linkColor,
        color: linkColor,
      );

  Widget _buildPreviewCard(
    BuildContext context,
    dynamic data,
    double previewWidth,
    Color linkColor,
  ) {
    final imageUrl = data.image?.url as String?;
    final link = (data.link as String?) ?? widget.url.convertToValidUrl;
    final title = data.title as String?;
    final description = data.description as String?;

    return IsmChatTapHandler(
      onTap: () => _openLink(link),
      child: Padding(
        padding: widget.embedded
            ? const EdgeInsets.only(top: 8)
            : IsmChatDimens.edgeInsets10_0,
        child: SizedBox(
          width: previewWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(IsmChatDimens.eight),
                  child: SizedBox(
                    width: previewWidth,
                    height: previewWidth,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: previewWidth,
                      height: previewWidth,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => ColoredBox(
                        color: IsmChatColors.greyColor.applyIsmOpacity(0.15),
                        child: const Center(
                          child: Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
                IsmChatDimens.boxHeight10,
              ],
              if (title != null && title.isNotEmpty) ...[
                Text(
                  title,
                  style: _titleStyle(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                IsmChatDimens.boxHeight5,
              ],
              if (description != null && description.isNotEmpty) ...[
                Text(
                  description,
                  style: _descriptionStyle(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                IsmChatDimens.boxHeight5,
              ],
              Text(
                link,
                style: _urlStyle(linkColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final messageText = widget.message.body.trim().isNotEmpty
        ? widget.message.body
        : widget.url;
    final linkColor = _getLinkPreviewColor();
    final previewWidth = _resolvePreviewWidth(context);

    return LinkPreview(
      enableAnimation: true,
      text: messageText,
      width: previewWidth,
      previewData: _previewData,
      onPreviewDataFetched: (data) {
        if (mounted) {
          setState(() => _previewData = data);
        }
      },
      textWidget: widget.embedded ? const SizedBox.shrink() : null,
      previewBuilder: (context, data) => _buildPreviewCard(
        context,
        data,
        previewWidth,
        linkColor,
      ),
      textStyle: widget.message.style,
      linkStyle: widget.message.style.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: linkColor,
        color: linkColor,
      ),
      padding: widget.embedded ? EdgeInsets.zero : IsmChatDimens.edgeInsets10_0,
    );
  }
}
