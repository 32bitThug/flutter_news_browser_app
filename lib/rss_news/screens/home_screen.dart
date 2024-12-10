import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/controller/feeds_by_category_controller.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';
import 'package:flutter_browser/rss_news/screens/category_selection_screen.dart';
import 'package:flutter_browser/rss_news/services/fetch_static_feeds.dart';
import 'package:flutter_browser/rss_news/widgets/home_feeds.dart';
import 'package:flutter_browser/rss_news/widgets/nav_bar.dart';
import 'package:hive/hive.dart';

import '../widgets/custom_category_feeds.dart';
import 'language_selection_screen.dart'; // Import the screen here

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String selectedLanguage;

  // late Future<List<GGetFeedsData_getFeeds>> categoryFeeds;
  late List<Feed> categoryFeeds;
  // final FetchFeeds _fetchFeeds = FetchFeeds();
  final FetchStaticFeeds _fetchStaticFeeds = FetchStaticFeeds();
  final FeedsByCategoryController _feedsByCategoryController =
      FeedsByCategoryController();
  // List<GGetFeedsByCategoryData_getFeeds> feedsByACategory = [];
  List<Feed> feedsByACategory = [];
  String selectedCategory = "";
  late List<String> _categories = [];
  bool isLoading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    if (!mounted) return; // Ensure widget is still in the tree
    setState(() {
      isLoading = true;
    });
    final box = Hive.box<List<String>>('preferences');
    final language = box.get('selectedLanguages');
    _categories = box.get('selectedCategories')!;
    final sources = box.get('selectedSources')!;
    if (language != null) {
      categoryFeeds = await _fetchStaticFeeds.feedsBySelectedSource(
          language, _categories, sources);
      debugPrint(categoryFeeds.toString());
      if (mounted) {
        // Check again before updating the state
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onCategoryTap(String category) async {
    if (category == "Home Feeds") {
      setState(() {
        selectedCategory = "";
      });
    } else {
      setState(() {
        isLoading = true;
      });
      debugPrint(category);
      final feeds =
          await _feedsByCategoryController.byAStaticCategory(category);
      setState(() {
        feedsByACategory = feeds;
        selectedCategory = category;
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoading = true;
    });
    await _loadSelectedLanguage();
    if (selectedCategory.isNotEmpty) {
      feedsByACategory =
          await _feedsByCategoryController.byAStaticCategory(selectedCategory);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            Row(
              children: [
                NavBar(
                  categories: _categories,
                  selectedCategory: selectedCategory,
                  onCategoryTap: _onCategoryTap,
                ),
                Container(
                  color: Colors.white,
                  height: 40,
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _refreshData,
                      ),
                      PopupMenuButton<String>(
                        color: Colors.white,
                        icon: const Icon(Icons.edit),
                        onSelected: (String result) {
                          if (result == 'lan') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const LanguageSelectionScreen(
                                  fromWelcomeScreen: false,
                                ),
                              ),
                            );
                          } else if (result == 'category') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const CategoriesSelectionScreen(
                                  fromWelcomeScreen: false,
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'lan',
                            child: Text('Change Language'),
                          ),
                          const PopupMenuItem<String>(
                            value: 'category',
                            child: Text('Change Categories'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : selectedCategory.isEmpty
                      ? error.isNotEmpty
                          ? Center(child: Text(error))
                          : HomeFeeds(customLanguageFeeds: categoryFeeds)
                      : CustomCategoryFeeds(feedsByACategory: feedsByACategory),
            ),
          ],
        ),
      ),
    );
  }
}
