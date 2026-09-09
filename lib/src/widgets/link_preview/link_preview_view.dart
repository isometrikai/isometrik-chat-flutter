import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import 'package:flutter_link_previewer/flutter_link_previewer.dart'
    show getPreviewData;
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-memory preview cache shared by chat bubbles and the long-press focus menu.
///
/// Reuse this whenever the same URL is rendered in more than one place (list
/// bubble → focus overlay Hero) so metadata is not re-fetched and the UI does
/// not jump from "link text only" → "image + title".
///
/// Clear via [clear] only if you need to force a refresh (e.g. logout).
class IsmChatLinkPreviewCache {
  IsmChatLinkPreviewCache._();

  static final Map<String, PreviewData> _cache = <String, PreviewData>{};

  static PreviewData? get(String url) => _cache[url];

  static void set(String url, PreviewData data) => _cache[url] = data;

  static void clear() => _cache.clear();
}

/// Link preview for chat messages.
///
/// Layout: square image (or placeholder) → title → description → URL.
/// A fixed-size image slot is reserved while metadata / the image loads so
/// long-press focus menus do not resize and push Delete under the system nav bar.
///
/// When [embedded] is true, the message text is shown by the parent bubble and
/// only the preview card is rendered here.
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
  PreviewData? _previewData;
  bool _isLoading = true;

  String get _cacheKey => widget.url.convertToValidUrl;

  @override
  void initState() {
    super.initState();
    _bootstrapPreview();
  }

  @override
  void didUpdateWidget(covariant LinkPreviewView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _bootstrapPreview();
    }
  }

  void _bootstrapPreview() {
    final cached = IsmChatLinkPreviewCache.get(_cacheKey);
    if (cached != null) {
      _previewData = cached;
      _isLoading = false;
      return;
    }
    _previewData = null;
    _isLoading = true;
    _fetchPreview();
  }

  Future<void> _fetchPreview() async {
    try {
      final data = await getPreviewData(_cacheKey);
      IsmChatLinkPreviewCache.set(_cacheKey, data);
      if (!mounted) return;
      setState(() {
        _previewData = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

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

  /// Fixed square slot used for the real OG image or a loading placeholder.
  /// Keeping this size stable avoids focus-menu flicker / overflow on Android.
  Widget _buildImageSlot({
    required double previewWidth,
    String? imageUrl,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(IsmChatDimens.eight),
      child: SizedBox(
        width: previewWidth,
        height: previewWidth,
        child: imageUrl != null && imageUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: previewWidth,
                height: previewWidth,
                fit: BoxFit.cover,
                // Keep the same footprint while the network image decodes.
                placeholder: (_, __) => _LinkPreviewImagePlaceholder(
                  size: previewWidth,
                ),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: IsmChatColors.greyColor.applyIsmOpacity(0.15),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              )
            : _LinkPreviewImagePlaceholder(size: previewWidth),
      ),
    );
  }

  Widget _buildPreviewCard(
    BuildContext context,
    double previewWidth,
    Color linkColor,
  ) {
    final data = _previewData;
    final imageUrl = data?.image?.url;
    final link = (data?.link as String?) ?? widget.url.convertToValidUrl;
    final title = data?.title;
    final description = data?.description;

    // Show image slot while loading, or when we know an image exists.
    // After a successful fetch with no image, drop the slot to avoid a blank box.
    final showImageSlot = _isLoading || (imageUrl != null && imageUrl.isNotEmpty);

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
              if (!widget.embedded) ...[
                Text(
                  widget.message.body.trim().isNotEmpty
                      ? widget.message.body
                      : widget.url,
                  style: widget.message.style.copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: linkColor,
                    color: linkColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                IsmChatDimens.boxHeight8,
              ],
              if (showImageSlot) ...[
                _buildImageSlot(
                  previewWidth: previewWidth,
                  imageUrl: imageUrl,
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
    final linkColor = _getLinkPreviewColor();
    final previewWidth = _resolvePreviewWidth(context);
    return _buildPreviewCard(context, previewWidth, linkColor);
  }
}

/// Neutral square placeholder reused for metadata fetch and image decode.
///
/// Prefer this over collapsing the image slot so list + focus-menu heights stay
/// aligned while previews load.
class _LinkPreviewImagePlaceholder extends StatelessWidget {
  const _LinkPreviewImagePlaceholder({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: IsmChatColors.greyColor.applyIsmOpacity(0.15),
      child: Center(
        child: Icon(
          Icons.language_outlined,
          size: size * 0.22,
          color: IsmChatColors.greyColor.applyIsmOpacity(0.7),
        ),
      ),
    );
  }
}
