import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:isometrik_chat_flutter/isometrik_chat_flutter.dart';
import 'package:isometrik_chat_flutter/src/services/giphy_service.dart';

class GiphyPickerPanel extends StatefulWidget {
  const GiphyPickerPanel({
    required this.stickers,
    super.key,
  });

  final bool stickers;

  @override
  State<GiphyPickerPanel> createState() => _GiphyPickerPanelState();
}

class _GiphyPickerPanelState extends State<GiphyPickerPanel> {
  final _searchController = TextEditingController();
  final _items = <IsmGiphyItem>[].obs;
  final _isLoading = false.obs;
  Timer? _debounce;
  var _offset = 0;
  var _hasMore = true;

  String get _apiKey =>
      IsmChatProperties.chatPageProperties.giphyApiKey?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    unawaited(_loadTrending(reset: true));
  }

  @override
  void didUpdateWidget(covariant GiphyPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stickers != widget.stickers) {
      _searchController.clear();
      _offset = 0;
      _hasMore = true;
      _items.clear();
      unawaited(_loadTrending(reset: true));
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTrending({required bool reset}) async {
    if (_apiKey.isEmpty) {
      return;
    }
    if (reset) {
      _offset = 0;
      _hasMore = true;
    }
    if (!_hasMore && !reset) {
      return;
    }
    _isLoading.value = true;
    final results = await IsmGiphyService.trending(
      apiKey: _apiKey,
      stickers: widget.stickers,
      offset: _offset,
    );
    if (reset) {
      _items.value = results;
    } else {
      _items.addAll(results);
    }
    _offset += results.length;
    _hasMore = results.length >= 24;
    _isLoading.value = false;
  }

  Future<void> _search(String query) async {
    if (_apiKey.isEmpty) {
      return;
    }
    _isLoading.value = true;
    final results = await IsmGiphyService.search(
      apiKey: _apiKey,
      query: query,
      stickers: widget.stickers,
    );
    _items.value = results;
    _hasMore = false;
    _isLoading.value = false;
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final query = value.trim();
      if (query.isEmpty) {
        unawaited(_loadTrending(reset: true));
      } else {
        unawaited(_search(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final textFieldTheme = IsmChatThemeResolver.textFieldFromConfig(context);
    final panelColor = textFieldTheme.emojiBoardBackgroundColor ??
        textFieldTheme.backgroundColor ??
        IsmChatColors.whiteColor;

    if (_apiKey.isEmpty) {
      return ColoredBox(
        color: panelColor,
        child: Center(
          child: Padding(
            padding: IsmChatDimens.edgeInsets20,
            child: Text(
              'Add giphyApiKey to IsmChatPageProperties to enable ${widget.stickers ? 'stickers' : 'GIFs'}.',
              textAlign: TextAlign.center,
              style: textFieldTheme.hintTextStyle,
            ),
          ),
        ),
      );
    }

    return ColoredBox(
      color: panelColor,
      child: Column(
        children: [
          Padding(
            padding: IsmChatDimens.edgeInsets8,
            child: TextField(
              controller: _searchController,
              style: textFieldTheme.inputTextStyle,
              decoration: InputDecoration(
                isDense: true,
                hintText: widget.stickers
                    ? IsmChatStrings.searchStickers
                    : IsmChatStrings.searchGifs,
                hintStyle: textFieldTheme.hintTextStyle,
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: panelColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(IsmChatDimens.twenty),
                  borderSide: BorderSide(
                    color: IsmChatColors.greyColor.applyIsmOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(IsmChatDimens.twenty),
                  borderSide: BorderSide(
                    color: IsmChatColors.greyColor.applyIsmOpacity(0.3),
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: Obx(
              () {
                if (_isLoading.value && _items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator.adaptive(),
                  );
                }
                if (_items.isEmpty) {
                  return Center(
                    child: Text(
                      'No results',
                      style: textFieldTheme.hintTextStyle,
                    ),
                  );
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification.metrics.pixels >=
                            notification.metrics.maxScrollExtent - 120 &&
                        !_isLoading.value &&
                        _hasMore &&
                        _searchController.text.trim().isEmpty) {
                      unawaited(_loadTrending(reset: false));
                    }
                    return false;
                  },
                  child: GridView.builder(
                    padding: IsmChatDimens.edgeInsets8,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      childAspectRatio: 1,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return IsmChatTapHandler(
                        onTap: () async {
                          if (!IsmChatUtility.chatPageControllerRegistered) {
                            return;
                          }
                          final controller = IsmChatUtility.chatPageController;
                          await controller.sendGiphyItem(
                            item,
                            isSticker: widget.stickers,
                          );
                          controller.toggleEmojiBoard(false, false);
                        },
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(IsmChatDimens.eight),
                          child: CachedNetworkImage(
                            imageUrl: item.previewUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => ColoredBox(
                              color: IsmChatColors.greyColor.applyIsmOpacity(0.2),
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.broken_image_outlined,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: IsmChatDimens.edgeInsets4,
            child: Text(
              IsmChatStrings.giphyAttribution,
              style: textFieldTheme.hintTextStyle?.copyWith(fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }
}
