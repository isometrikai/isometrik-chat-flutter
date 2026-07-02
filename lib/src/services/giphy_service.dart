import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:isometrik_chat_flutter/src/models/giphy_item_model.dart';

/// Lightweight Giphy REST client for GIF and sticker search.
///
/// Requires a free API key from [Giphy Developers](https://developers.giphy.com/).
class IsmGiphyService {
  const IsmGiphyService._();

  static const _baseUrl = 'https://api.giphy.com/v1';

  static Future<List<IsmGiphyItem>> search({
    required String apiKey,
    required String query,
    required bool stickers,
    int offset = 0,
    int limit = 24,
  }) async {
    if (apiKey.isEmpty || query.trim().isEmpty) {
      return [];
    }
    final resource = stickers ? 'stickers' : 'gifs';
    final uri = Uri.parse('$_baseUrl/$resource/search').replace(
      queryParameters: {
        'api_key': apiKey,
        'q': query.trim(),
        'limit': '$limit',
        'offset': '$offset',
        'rating': 'pg',
        'lang': 'en',
      },
    );
    return _fetchItems(uri);
  }

  static Future<List<IsmGiphyItem>> trending({
    required String apiKey,
    required bool stickers,
    int offset = 0,
    int limit = 24,
  }) async {
    if (apiKey.isEmpty) {
      return [];
    }
    final resource = stickers ? 'stickers' : 'gifs';
    final uri = Uri.parse('$_baseUrl/$resource/trending').replace(
      queryParameters: {
        'api_key': apiKey,
        'limit': '$limit',
        'offset': '$offset',
        'rating': 'pg',
      },
    );
    return _fetchItems(uri);
  }

  static Future<List<IsmGiphyItem>> _fetchItems(Uri uri) async {
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      return [];
    }
    final decoded = json.decode(response.body) as Map<String, dynamic>;
    final data = decoded['data'];
    if (data is! List) {
      return [];
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(IsmGiphyItem.fromMap)
        .where((item) => item.sendUrl.isNotEmpty)
        .toList();
  }
}
