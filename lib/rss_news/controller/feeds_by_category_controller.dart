import 'package:flutter_browser/rss_news/services/fetch_feeds_by_category.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';

class FeedsByCategoryController {
  final FetchFeedsByCategory _byCategory = FetchFeedsByCategory();

  Future<List<Feed>> byAStaticCategory(String category) async {
    // converting the first characte for categories like delhi and Delhi
    String modifiedCategory = category.isNotEmpty
        ? (category[0].toUpperCase() == category[0]
            ? category[0].toLowerCase() + category.substring(1)
            : category[0].toUpperCase() + category.substring(1))
        : category;
    final originalFeeds = await _byCategory.byAStaticCategory(category);
    final modifiedFeeds = await _byCategory.byAStaticCategory(modifiedCategory);
    final combinedFeeds = {...originalFeeds, ...modifiedFeeds}.toList();
    // debugPrint('controller${feeds}');
    return combinedFeeds;
  }
}
