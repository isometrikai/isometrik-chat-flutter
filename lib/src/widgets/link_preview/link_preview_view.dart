import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkPreviewView extends StatefulWidget {
  const LinkPreviewView({
    super.key,
    required this.url,
    required this.message,
  });
  final String url;
  final IsmChatMessageModel message;

  @override
  State<LinkPreviewView> createState() => _LinkPreviewViewState();
}

class _LinkPreviewViewState extends State<LinkPreviewView> {
  MetaDataResponse? _metadata;
  bool _isLoading = true;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _fetchAndSetMetadata();
  }

  Future<void> _fetchAndSetMetadata() async {
    if (widget.url.isEmpty) {
      _setErrorState();
      return;
    }

    _isLoading = true;
    updateState();
    try {
      _metadata = await _fetchMetadata(widget.url);
      if (_metadata == null) {
        _setErrorState();
        return;
      }

      // Check if we have at least one valid field
      final hasTitle = _metadata!.title != null && _metadata!.title!.isNotEmpty;
      final hasDescription =
          _metadata!.description != null && _metadata!.description!.isNotEmpty;
      final hasImage =
          _metadata!.imageUrl != null && _metadata!.imageUrl!.isNotEmpty;

      if (!hasTitle && !hasDescription && !hasImage) {
        _setErrorState();
      }
    } catch (e, st) {
      IsmChatLog.error('Link preview error for ${widget.url}: $e', st);
      _setErrorState();
    } finally {
      _isLoading = false;
      updateState();
    }
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _setErrorState() {
    _isError = true;
    updateState();
  }

  Future<MetaDataResponse?> _fetchMetadata(String url) async {
    // Try with retry logic (max 2 attempts)
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final proxyUrl =
            'https://api.allorigins.win/get?url=${Uri.encodeComponent(url)}';
        final response = await http
            .get(Uri.parse(proxyUrl))
            .timeout(Duration(seconds: attempt == 1 ? 20 : 15));

        if (response.statusCode == 200) {
          final jsonResponse =
          jsonDecode(response.body) as Map<String, dynamic>;
          final htmlString = jsonResponse['contents'] as String?;

          if (htmlString == null || htmlString.isEmpty) {
            return null;
          }

          return _parseHtmlToMetadata(htmlString, url);
        }
      } catch (e) {
        if (attempt == 2) {
          // Log error only on final attempt
          IsmChatLog.error(
              'Failed to fetch metadata for $url after $attempt attempts: $e');
        } else {
          // Wait a bit before retry
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    return null;
  }

  MetaDataResponse? _parseHtmlToMetadata(String htmlString, String url) {
    try {
      if (htmlString.isEmpty) {
        return null;
      }

      final document = html_parser.parse(htmlString);

      final title = document
          .querySelector("meta[property='og:title']")
          ?.attributes['content'] ??
          document.querySelector('title')?.text;
      final description = document
          .querySelector("meta[property='og:description']")
          ?.attributes['content'] ??
          document
              .querySelector("meta[name='description']")
              ?.attributes['content'];
      var imageUrl = document
          .querySelector("meta[property='og:image']")
          ?.attributes['content'] ??
          document
              .querySelector("meta[property='twitter:image']")
              ?.attributes['content'];

      if (imageUrl == null || imageUrl.isEmpty) {
        final firstImg = document.querySelector('img');
        imageUrl = firstImg?.attributes['src'];
      }

      imageUrl = _resolveUrl(imageUrl, url);
      var additionalLink = document
          .querySelector("meta[property='og:url']")
          ?.attributes['content'] ??
          document.querySelector('a')?.attributes['href'];

      additionalLink = _resolveUrl(additionalLink, url);

      return MetaDataResponse(
        title: title,
        description: description,
        imageUrl: imageUrl,
        additionalLink: additionalLink,
      );
    } catch (e, st) {
      IsmChatLog.error('Failed to parse HTML metadata: $e', st);
      return null;
    }
  }

  String? _resolveUrl(String? url, String baseUrl) {
    if (url != null && (url.startsWith('./') || url.startsWith('/'))) {
      final baseUri = Uri.parse(baseUrl);
      return '${baseUri.scheme}://${baseUri.host}$url';
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isError) {
      return ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: IsmChatDimens.edgeInsets10_0,
        shrinkWrap: true,
        children: [
          IsmChatDimens.boxHeight10,
          Text(
            _isLoading
                ? IsmChatStrings.fetchingPreview
                : IsmChatStrings.errorLoadingPreview,
            style: widget.message.style.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: (widget.message.style.fontSize ?? 0) + 2),
          ),
          IsmChatDimens.boxHeight10,
          Text(
            widget.url,
            style: widget.message.style.copyWith(
              decoration: TextDecoration.underline,
              decorationColor: IsmChatColors.pureBlue,
              color: IsmChatColors.pureBlue,
            ),
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.start,
          ),
        ],
      );
    } else {
      return _buildMetadataContent();
    }
  }

  Widget _buildMetadataContent() => IsmChatTapHandler(
    onTap: () => launchUrl(Uri.parse(widget.url.convertToValidUrl)),
    child: ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: IsmChatDimens.edgeInsets10_0,
      shrinkWrap: true,
      children: [
        IsmChatDimens.boxHeight10,
        Image.network(
          _metadata?.imageUrl ?? '',
          errorBuilder: (_, __, ___) => IsmChatDimens.box0,
          height: (IsmChatResponsive.isWeb(context))
              ? context.height * .2
              : context.height * .15,
          fit: BoxFit.contain,
        ),
        IsmChatDimens.boxHeight10,
        Text(
          _metadata?.title ?? '',
          style: widget.message.style.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: (widget.message.style.fontSize ?? 0) + 5),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.start,
        ),
        IsmChatDimens.boxHeight5,
        Text(
          _metadata?.description ?? '',
          style: widget.message.style,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.start,
        ),
        IsmChatDimens.boxHeight5,
        Text(
          widget.url,
          style: widget.message.style.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: IsmChatColors.pureBlue,
            color: IsmChatColors.pureBlue,
          ),
          softWrap: true,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          textAlign: TextAlign.start,
        ),
      ],
    ),
  );
}

class MetaDataResponse {
  MetaDataResponse({
    this.title,
    this.description,
    this.imageUrl,
    this.additionalLink,
  });

  final String? title;
  final String? description;
  final String? imageUrl;
  final String? additionalLink;
}
