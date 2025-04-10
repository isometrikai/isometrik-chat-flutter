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
    _isLoading = true;
    updateState();
    try {
      _metadata = await _fetchMetadata(widget.url);
      if (_metadata == null) {
        _setErrorState();
      }
    } catch (e) {
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
    final proxyUrl =
        'https://api.allorigins.win/get?url=${Uri.encodeComponent(url)}';
    final response = await http.get(Uri.parse(proxyUrl));
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final htmlString = jsonResponse['contents'];
      return _parseHtmlToMetadata(htmlString, url);
    }
    return null;
  }

  MetaDataResponse? _parseHtmlToMetadata(String htmlString, String url) {
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

    if (imageUrl == null) {
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
