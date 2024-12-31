import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_browser/webview_tab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
// import 'package:flutter_browser/src/constants/constants.dart';
import 'package:xml/xml.dart' as xml;

import '../models/feed_item.dart';

class RSSFeedScreen extends StatefulWidget {
  final List<String> feedUrls;
  const RSSFeedScreen({super.key, required this.feedUrls});
  // WebViewTabAppBar _webViewTabAppBar = new WebViewTabAppBar();
  @override
  State<RSSFeedScreen> createState() => _RSSFeedScreenState();
}

class _RSSFeedScreenState extends State<RSSFeedScreen> {
  List<FeedItem> _feedItems = [];
  bool _isLoading = true;
  String _error = '';
  @override
  void initState() {
    super.initState();
    _fetchFeeds();
  }

  void addNewTab({WebUri? url}) async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);

    browserModel.addTab(
        WebViewTab(key: GlobalKey(), webViewModel: WebViewModel(url: url)));
  }

  DateTime _sortDateTime(String pubDate) {
    try {
      return DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(pubDate);
    } catch (e) {
      // Return a very old date in case of parsing error
      return DateTime(1970, 1, 1);
    }
  }

  String _formatPubDate(String pubDate) {
    try {
      final dateTime = DateFormat('EEE, dd MMM yyyy HH:mm:ss Z').parse(pubDate);
      return timeago.format(dateTime);
    } catch (e) {
      return 'Unknown Date';
    }
  }

  Future<void> _fetchFeeds() async {
    try {
      List<FeedItem> allFeedItems = [];
      for (String url in widget.feedUrls) {
        try {
          List<String> urlParts = url.split('*');
          String originalUrl = urlParts.isNotEmpty ? urlParts[0] : url;
          String source = urlParts.isNotEmpty ? urlParts[1] : url;

          final response = await http.get(Uri.parse(originalUrl));
          if (response.statusCode == 200) {
            final decodedBody = utf8.decode(response.bodyBytes);

            final document = xml.XmlDocument.parse(decodedBody);
            final items = document.findAllElements('item');
            final feedItems = items.map((item) {
              final title = item.findElements('title').first.innerText;
              final description =
                  item.findElements('description').first.innerText;
              final link = item.findElements('link').first.innerText;
              final pubDate = item.findElements('pubDate').first.innerText;
              // debug(pubDate.toString());
              final imageUrl = item.findAllElements('media:content').isNotEmpty
                  ? item
                      .findAllElements('media:content')
                      .first
                      .getAttribute('url')
                  : null;
              return FeedItem(
                  title, description, link, imageUrl, source, pubDate);
            }).toList();
            allFeedItems.addAll(feedItems);
          } else {
            throw Exception(
                'Failed to load RSS feed from $url with status code: ${response.statusCode}');
          }
        } catch (e) {
          if (e is xml.XmlParserException) {
            // Log XML parsing error and continue with next URL
            debug('XML Parsing Error for $url: ${e.message}');
          } else {
            // Log other errors and continue with next URL
            debug('Error loading RSS feed from $url: $e');
          }
        }
      }
      allFeedItems.sort((a, b) =>
          _sortDateTime(b.pubDate!).compareTo(_sortDateTime(a.pubDate!)));
      setState(() {
        _feedItems = allFeedItems;
        _isLoading = false;
      });
    } catch (e) {
      _error = 'Failed to load RSS feeds: $e';
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the frequency of horizontal sections
    const int verticalChunkSize =
        3; // Show horizontal section after every 3 vertical items
    const int horizontalSectionSize =
        5; // Number of items in each horizontal section

    // Separate vertical and horizontal items
    final List<FeedItem> verticalItems = _feedItems
        .asMap()
        .entries
        .where((entry) =>
            entry.key % (verticalChunkSize + horizontalSectionSize) <
            verticalChunkSize)
        .map((entry) => entry.value)
        .toList();

    final List<FeedItem> horizontalItems = _feedItems
        .asMap()
        .entries
        .where((entry) =>
            entry.key % (verticalChunkSize + horizontalSectionSize) >=
            verticalChunkSize)
        .map((entry) => entry.value)
        .toList();

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : ListView.builder(
                  itemCount: verticalItems.length +
                      (horizontalItems.length ~/ horizontalSectionSize),
                  itemBuilder: (context, index) {
                    // Add horizontal section after every 3 vertical items
                    if (index > 0 &&
                        index % (verticalChunkSize + 1) == verticalChunkSize) {
                      int horizontalIndex = index ~/
                          (verticalChunkSize + 1) *
                          horizontalSectionSize;
                      return Column(
                        children: [
                          SizedBox(
                            height: 150, // Height for horizontal section
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: horizontalSectionSize,
                              itemBuilder: (context, hIndex) {
                                if (horizontalIndex + hIndex >=
                                    horizontalItems.length) {
                                  return const SizedBox.shrink();
                                }
                                final item =
                                    horizontalItems[horizontalIndex + hIndex];
                                return Container(
                                  width: 200,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Card(
                                    //  elevation: 3,
                                    color: Colors.white,
                                    child: InkWell(
                                      onTap: () {
                                        addNewTab(
                                            url: WebUri(item.link.toString()));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.source,
                                                  size: 16,
                                                  color: Colors.grey,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.source.toString(),
                                                  style: const TextStyle(
                                                      color: Colors.lightBlue),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Expanded(
                                              child: Text(
                                                item.title ?? "No Title",
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.calendar_today,
                                                    size: 12,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(
                                                  item.pubDate != null
                                                      ? _formatPubDate(
                                                          item.pubDate!)
                                                      : 'Unknown Date',
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 15, vertical: 6),
                            child: Divider(),
                          ), // Add a separator here
                        ],
                      );
                    }

                    // Vertical item
                    final verticalIndex =
                        index - (index ~/ (verticalChunkSize + 1));
                    if (verticalIndex >= verticalItems.length) {
                      return const SizedBox.shrink();
                    }
                    final item = verticalItems[verticalIndex];
                    return Card(
                      color: Colors.white,
                      child: InkWell(
                        onTap: () {
                          addNewTab(url: WebUri(item.link.toString()));
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title.toString(),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 8),
                              if (item.imageUrl != null)
                                Image.network(
                                  item.imageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/news.jpeg',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.pubDate != null
                                        ? _formatPubDate(item.pubDate!)
                                        : 'Unknown Date',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.source,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.source.toString(),
                                    style: const TextStyle(
                                        color: Colors.lightBlue),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
