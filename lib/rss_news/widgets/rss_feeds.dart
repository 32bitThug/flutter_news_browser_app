import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/models/window_model.dart';
import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/webview_tab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
// import 'package:flutter_browser/src/constants/constants.dart';
import 'package:xml/xml.dart' as xml;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/feed_item.dart';

class RSSFeedScreen extends StatefulWidget {
  final List<String> feedUrls;
  const RSSFeedScreen({Key? key, required this.feedUrls});
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
    // debugPrint('rss${widget.feedUrls.toString()})');
    _fetchFeeds();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<BackgroundTask>(context, listen: false)
    //       .getHighlights(context, widget.feedUrls);
    // });
  }

  void addNewTab({WebUri? url}) async {
    var browserModel = Provider.of<BrowserModel>(context, listen: false);
    var settings = browserModel.getSettings();
    url ??= settings.homePageEnabled && settings.customUrlHomePage.isNotEmpty
        ? WebUri(settings.customUrlHomePage)
        : WebUri(settings.searchEngine.url);
    var windowModel = Provider.of<WindowModel>(context, listen: false);
    windowModel.addTab(
        WebViewTab(key: GlobalKey(), webViewModel: WebViewModel(url: url)));
    executeJS(windowModel);
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
              final title = item.findElements('title').first.text;
              final description = item.findElements('description').first.text;
              final link = item.findElements('link').first.text;
              final pubDate = item.findElements('pubDate').first.text;
              // debugPrint(pubDate.toString());
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
            debugPrint('XML Parsing Error for $url: ${e.message}');
          } else {
            // Log other errors and continue with next URL
            debugPrint('Error loading RSS feed from $url: $e');
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
      setState(() {
        _error = 'Failed to load RSS feeds: $e';
      });
      _isLoading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _isLoading
              ? const Loader()
              : _error.isNotEmpty
                  ? Center(
                      child: Text(
                        _error,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _feedItems.length,
                      itemBuilder: (context, index) {
                        final item = _feedItems[index];
                        return Card(
                          color: Colors.white, // White background for the card
                          // margin: const EdgeInsets.symmetric(
                          //     vertical: 8, horizontal: 16),
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
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  if (item.imageUrl != null)
                                    Image.network(
                                      item.imageUrl!,
                                      width: double
                                          .infinity, // Image takes full width
                                      height: 200, // Fixed height for image
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/news.jpeg',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.pubDate != null
                                            ? _formatPubDate(item.pubDate!)
                                            : 'Unknown Date',
                                        style:
                                            const TextStyle(color: Colors.grey),
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
        ),
      ],
    );
  }

  Future<String> loadLocalJs() async {
    return await rootBundle.loadString('assets/js/remove_adds.js');
  }

  void executeJS(WindowModel browserModel) async {
    try {
      final currentTab = browserModel.getCurrentTab();
      if (currentTab == null) {
        debugPrint("No current tab available");
        return;
      }

      final webViewModel = currentTab.webViewModel;

      await Future.delayed(const Duration(seconds: 1));
      final webViewController = webViewModel.webViewController;

      if (webViewController == null) {
        debugPrint("WebViewController is null");
        return;
      }
      try {
        String jsCode = await loadLocalJs();
        await webViewController.evaluateJavascript(source: jsCode);
      } catch (jsError) {
        debugPrint("JavaScript execution error: $jsError");
      }
    } catch (e, stackTrace) {
      debugPrint("Error in addNewTab: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }
}
