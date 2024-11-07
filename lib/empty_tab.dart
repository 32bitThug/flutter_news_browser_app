import 'package:flutter/material.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/util.dart';
import 'package:flutter_browser/rss_news/screens/home_screen.dart';
import 'package:flutter_browser/rss_news/screens/app_language_selection_screen.dart';
import 'package:flutter_browser/webview_tab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/window_model.dart';

class EmptyTab extends StatefulWidget {
  const EmptyTab({super.key});

  @override
  State<EmptyTab> createState() => _EmptyTabState();
}

class _EmptyTabState extends State<EmptyTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 300.0),
        child: ValueListenableBuilder(
          valueListenable: Hive.box<List<String>>('preferences').listenable(),
          builder:
              (BuildContext context, Box<List<String>> box, Widget? child) {
            final sources = box.get('selectedSources');
            return Column(
              children: [
                if (sources != null && sources.isNotEmpty)
                  const Expanded(child: HomeScreen())
                else
                  Expanded(child: AppLanguageSelectionScreen())
              ],
            );
          },
        ),
      ),
    );
  }

  void openNewTab(value) {
    final windowModel = Provider.of<WindowModel>(context, listen: false);
    final browserModel = Provider.of<BrowserModel>(context, listen: false);
    final settings = browserModel.getSettings();

    var url = WebUri(value.trim());
    if (Util.isLocalizedContent(url) ||
        (url.isValidUri && url.toString().split(".").length > 1)) {
      url = url.scheme.isEmpty ? WebUri("https://$url") : url;
    } else {
      url = WebUri(settings.searchEngine.searchUrl + value);
    }

    windowModel.addTab(WebViewTab(
      key: GlobalKey(),
      webViewModel: WebViewModel(url: url),
    ));
  }
}
