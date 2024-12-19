import 'package:flutter_browser/rss_news/models/page_attributes_model.dart';

class SessionServices {

static List<Map<String, dynamic>> createHierarchy(List<PageAttributes> items) {
    final List<Map<String, dynamic>> hierarchy = [];
    Map<String, dynamic>? currentChapter;
    Map<String, dynamic>? currentTopic;

    final sortedItems = List<PageAttributes>.from(items)
      ..sort((a, b) => a.order.compareTo(b.order));

    for (var item in sortedItems) {
      if (item.type == 'chapter') {
        currentChapter = {
          'item': item,
          'topics': <Map<String, dynamic>>[],
          'subtopics': <Map<String, dynamic>>[],
        };
        hierarchy.add(currentChapter);
        currentTopic = null;
      } else if (item.type == 'topic') {
        if (currentChapter != null) {
          final topic = {
            'item': item,
            'subtopics': <Map<String, dynamic>>[],
          };
          currentChapter['topics'].add(topic);
          currentTopic = topic;
        }
      } else {
        // For subtopics
        if (currentTopic != null) {
          // If it's under a topic
          currentTopic['subtopics'].add({
            'item': item,
          });
        } else if (currentChapter != null) {
          // If it's directly under a chapter (no intermediate topic)
          currentChapter['subtopics'].add({
            'item': item,
          });
        }
      }
    }

    return hierarchy;
  }
}