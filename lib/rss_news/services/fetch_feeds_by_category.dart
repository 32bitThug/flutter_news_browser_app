import 'dart:convert';

import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';

import 'package:http/http.dart' as http;
class FetchFeedsByCategory {

   Future<List<Feed>> byAStaticCategory(String category) async {
  try {
    final response = await http.get(Uri.parse(staticApiUrl));
    
    if (response.statusCode == 200) {
      // Decode the response body
      final Map<String, dynamic> data = json.decode(response.body);
      
      if (data['feeds'] is List) {
        // Convert the JSON data to List<Feed> and filter by category
        final List<Feed> allFeeds = (data['feeds'] as List)
            .map((item) => Feed.fromJson(item as Map<String, dynamic>))
            .where((feed) => feed.category.toLowerCase() == category.toLowerCase())
            .toList();
            
        debug('Fetched ${allFeeds.length} feeds for category: $category');
        return allFeeds;
      } else {
        throw Exception('Unexpected data format: "feeds" key is missing or not a list');
      }
    } else {
      throw Exception('Failed to fetch data. Status code: ${response.statusCode}');
    }
  } catch (e) {
    debug('Error fetching feeds by category: $e');
    throw Exception('Error fetching feeds by category: $e');
  }
}


}
