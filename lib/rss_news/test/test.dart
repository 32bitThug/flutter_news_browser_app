import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/foundation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enable debugging for Android if in debug mode
  if (!kIsWeb &&
      kDebugMode &&
      defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  runApp(const MaterialApp(
    home: AdsContentBlockerApp(),
  ));
}

class AdsContentBlockerApp extends StatefulWidget {
  const AdsContentBlockerApp({Key? key}) : super(key: key);

  @override
  State<AdsContentBlockerApp> createState() => _AdsContentBlockerAppState();
}

class _AdsContentBlockerAppState extends State<AdsContentBlockerApp> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;

  // List of basic ad URL filters
  final List<String> adUrlFilters = [
    ".*.doubleclick.net/.*",
    ".*.googlesyndication.com/.*",
    ".*.google-analytics.com/.*",
    ".*.adsafeprotected.com/.*",
    ".*.adservice.google.*/.*",
  ];

  final List<ContentBlocker> contentBlockers = [];
  bool contentBlockerEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeContentBlockers();
  }

  // Initialize the ad blockers
  void _initializeContentBlockers() {
    // Add basic ad blockers
    // for (String filter in adUrlFilters) {
    //   contentBlockers.add(ContentBlocker(
    //     trigger: ContentBlockerTrigger(urlFilter: filter),
    //     action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
    //   ));
    // }

    // // Add CSS display: none blocker for ad banners
    // contentBlockers.add(ContentBlocker(
    //   trigger: ContentBlockerTrigger(urlFilter: ".*"),
    //   action: ContentBlockerAction(
    //     type: ContentBlockerActionType.CSS_DISPLAY_NONE,
    //     selector: ".ads, .ad, .advert, .banner",
    //   ),
    // ));

    // // Load EasyList dynamically
    _loadEasyListRules();
  }

  // Function to load EasyList rules
  Future<void> _loadEasyListRules() async {
    try {
      // Simulate loading EasyList rules from a local file or remote source
      String easyListContent = await DefaultAssetBundle.of(context)
          .loadString('assets/easylist.txt'); // Ensure this file exists

      List<ContentBlocker> easyListBlockers =
          await _parseEasyList(easyListContent);
      setState(() {
        contentBlockers.addAll(easyListBlockers);
        debug("Loaded ${easyListBlockers.length} EasyList rules");
      });
    } catch (e) {
      debugPrint("Failed to load EasyList: $e");
    }
  }

  // Parse EasyList content into ContentBlockers
  Future<List<ContentBlocker>> _parseEasyList(String content) async {
    List<ContentBlocker> blockers = [];
    for (String line in content.split('\n')) {
      if (line.isEmpty || line.startsWith('!')) continue;

      // Simple URL filtering
      if (line.startsWith('||')) {
        String domain = line.substring(2).split('^')[0];
        blockers.add(ContentBlocker(
          trigger: ContentBlockerTrigger(urlFilter: ".*$domain.*"),
          action: ContentBlockerAction(type: ContentBlockerActionType.BLOCK),
        ));
      }
    }
    return blockers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("WebView with Ad Blocking"),
        actions: [
          TextButton(
            onPressed: () async {
              setState(() {
                contentBlockerEnabled = !contentBlockerEnabled;
              });
              await webViewController?.setSettings(
                settings: InAppWebViewSettings(
                  contentBlockers: contentBlockerEnabled ? contentBlockers : [],
                ),
              );
              webViewController?.reload();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: Text(contentBlockerEnabled ? "Disable" : "Enable"),
          ),
        ],
      ),
      body: SafeArea(
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest: URLRequest(
            url: WebUri(
                "https://www.hindustantimes.com/world-news/bodycam-footage-shows-distressing-aftermath-of-azerbaijan-airlines-plane-crash-in-kazakhstan-101735177637247.html"),
          ),
          initialSettings: InAppWebViewSettings(
            contentBlockers: contentBlockers,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
        ),
      ),
    );
  }
}
