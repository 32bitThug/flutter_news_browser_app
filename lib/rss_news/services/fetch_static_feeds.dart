import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FetchStaticFeeds {
  Future<List<Feed>> fetchStaticFeeds() async {
    try {
      final response = await http.get(Uri.parse(staticApiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['feeds'] is List) {
          final List<Feed> feeds = (data['feeds'] as List)
              .map((item) => Feed.fromJson(item as Map<String, dynamic>))
              .toList();

          // print('Fetched data: $feeds');
          return feeds;
        } else {
          throw Exception(
              'Unexpected data format: "feeds" key is missing or not a list');
        }
      } else {
        throw Exception(
            'Failed to fetch data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debug('Error fetching data: $e');
      throw Exception('Error fetching data: $e');
    }
  }

  Future<List<Feed>> feedsBySelectedLanguage(List<String> languages) async {
    final feeds = await fetchStaticFeeds();

    return feeds.where((feed) => languages.contains(feed.language)).toList();
  }

  Future<List<Feed>> feedsBySelectedCategories(
      List<String> languages, List<String> categories) async {
    final feeds = await feedsBySelectedLanguage(languages);
    // debugPrint('feeds$feeds.');
    return feeds.where((feed) => categories.contains(feed.category)).toList();
  }

  Future<List<Feed>> feedsBySelectedSource(List<String> languages,
      List<String> categories, List<String> sources) async {
    final feeds = await feedsBySelectedCategories(languages, categories);
    // debugPrint('feeds$feeds.');
    return feeds.where((feed) => sources.contains(feed.source)).toList();
  }
}
