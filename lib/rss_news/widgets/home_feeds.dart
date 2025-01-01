import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';
import 'package:flutter_browser/rss_news/widgets/rss_feeds.dart';

import '../constants/constants.dart';

class HomeFeeds extends StatefulWidget {
  // final Future<List<GGetFeedsData_getFeeds>> customLanguageFeeds;
  final List<Feed> customLanguageFeeds;

  const HomeFeeds({Key? key, required this.customLanguageFeeds});

  @override
  State<HomeFeeds> createState() => _HomeFeedsState();
}

class _HomeFeedsState extends State<HomeFeeds> {
  List<String> feedUrls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUrls();
  }

  @override
  void didUpdateWidget(HomeFeeds oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.customLanguageFeeds != oldWidget.customLanguageFeeds) {
      _loadUrls();
    }
  }

  // Form a list of urls based on language and category
  Future<void> _loadUrls() async {
    setState(() {
      isLoading = true;
    });
    try {
      final feeds =  widget.customLanguageFeeds;
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        feedUrls =
            feeds.map((feed) => '${feed.feed_url}*${feed.source}').toList();
      });
    } catch (e) {
      // Handle error if needed
    } finally {
      // ignore: control_flow_in_finally
      if (!mounted) return; // Check if widget is still mounted
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Loader()
        : feedUrls.isEmpty
            ? const Center(child: Text('No feeds available.'))
            : RSSFeedScreen(
                feedUrls: feedUrls,
              );
  }
}
