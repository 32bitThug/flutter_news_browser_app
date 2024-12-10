import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/models/page_attributes_model.dart';

class TableOfContents extends StatelessWidget {
  final List<PageAttributes> items;
  final Function(int pageNumber)
      onTap; // Callback function for handling page taps

  const TableOfContents({
    super.key,
    required this.items,
    required this.onTap,
  });

  List<Map<String, dynamic>> _createHierarchy() {
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
        if (currentTopic != null) {
          currentTopic['subtopics'].add({
            'item': item,
          });
        }
      }
    }

    return hierarchy;
  }

  @override
  Widget build(BuildContext context) {
    final hierarchy = _createHierarchy();

    return ListView.builder(
      itemCount: hierarchy.length,
      itemBuilder: (context, index) {
        final chapter = hierarchy[index];
        final chapterItem = chapter['item'] as PageAttributes;
        final topics = chapter['topics'] as List<Map<String, dynamic>>;

        return Padding(
          padding:
              EdgeInsets.only(bottom: index + 1 == hierarchy.length ? 64.0 : 0),
          child: Card(
            elevation: 0,
            margin: const EdgeInsets.all(4.0),
            child: ExpansionTile(
              title: Text(
                chapterItem.text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              subtitle: Text('Page ${chapterItem.pageNumber}'),
              onExpansionChanged: (isExpanded) {
                if (chapterItem.pageNumber > 0 && !isExpanded) {
                  onTap(chapterItem.pageNumber);
                }
              },
              children: topics.map<Widget>((topic) {
                final topicItem = topic['item'] as PageAttributes;
                final subtopics =
                    topic['subtopics'] as List<Map<String, dynamic>>;

                if (subtopics.isEmpty) {
                  return ListTile(
                    title: Text(topicItem.text),
                    subtitle: Text('Page ${topicItem.pageNumber}'),
                    contentPadding:
                        const EdgeInsets.only(left: 32.0, right: 16.0),
                    onTap: () {
                      if (topicItem.pageNumber > 0) {
                        onTap(topicItem.pageNumber);
                      }
                    },
                  );
                }

                return ExpansionTile(
                  title: Text(topicItem.text),
                  subtitle: Text('Page ${topicItem.pageNumber}'),
                  onExpansionChanged: (isExpanded) {
                    if (topicItem.pageNumber > 0) {
                      onTap(topicItem.pageNumber);
                    }
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  childrenPadding: const EdgeInsets.only(left: 32.0),
                  children: subtopics.map<Widget>((subtopic) {
                    final subtopicItem = subtopic['item'] as PageAttributes;
                    return ListTile(
                      title: Text(subtopicItem.text),
                      subtitle: Text('Page ${subtopicItem.pageNumber}'),
                      contentPadding:
                          const EdgeInsets.only(left: 48.0, right: 16.0),
                      onTap: () {
                        if (subtopicItem.pageNumber > 0) {
                          onTap(subtopicItem.pageNumber);
                        }
                      },
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}