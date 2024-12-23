import 'package:flutter/services.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';

import 'package:flutter_browser/rss_news/models/rules_model.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CustomRules {
  List<Rules> allRules = HiveDBHelper.getAllRules();

  String findLongestPart(String url) {
    // Split the string by '.'
    List<String> parts = url.split('.');

    // Find the longest part
    String longestPart = parts.reduce((a, b) => a.length >= b.length ? a : b);

    return longestPart;
  }

  Future<void> removeElementsUsingRules(
    InAppWebViewController? webViewController,
    String category,
    String type,
    bool isHidden,
    WebUri? uri,
  ) async {
    // var url = webViewTab.webViewModel.url
    // String url = WebUri(uri);
    String host = findLongestPart(uri!.host);
    // debugPrint(host);
    String jsCode = await rootBundle.loadString('assets/js/remove_adds.js');
    List<Rules> filteredRules = allRules
        .where((rule) =>
            rule.category == category &&
            rule.type == type &&
            host == (rule.domain.toLowerCase().replaceAll(' ', '')))
        .toList();

    List idNamesToRemove = filteredRules.map((rule) => rule.value).toList();
    // debugPrint(idNamesToRemove.toString());
    // Execute the JavaScript in the WebView
    if (webViewController != null) {
      await webViewController.evaluateJavascript(source: '''
  $jsCode
  removeElementsUsingRulesJs(${idNamesToRemove.map((id) => '"$id"').toList()}, "$type", $isHidden);
''');
    }
  }

  removeHeaderAndFooter(InAppWebViewController? webViewController) async {
    String jsCode = await rootBundle.loadString('assets/js/remove_adds.js');
    if (webViewController != null) {
      await webViewController
          .evaluateJavascript(source: '''$jsCode modifyPage() ''');
    }
  }
}
