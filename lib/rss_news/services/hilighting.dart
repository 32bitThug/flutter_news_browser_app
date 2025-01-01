import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HilightService {
  Future<void> injectHighlightJS(
      InAppWebViewController? webViewController) async {
    if (webViewController == null) {
      debug('WebViewController is null. Cannot inject JavaScript.');
      return;
    }

    try {
      await webViewController.evaluateJavascript(source: '''
        if (!document.querySelector('#highlight-style')) {
            const style = document.createElement('style');
            style.id = 'highlight-style';
            style.textContent = '.highlighted { background-color: yellow; }';
            document.head.appendChild(style);
        }

        document.addEventListener('contextmenu', function(e) {
          const selection = window.getSelection();
          if (selection.toString().length > 0) {
            window.lastSelection = selection.getRangeAt(0);
          }
        });

        window.highlightSelection = function() {
          if (window.lastSelection) {
            const span = document.createElement('span');
            span.className = 'highlighted';
            window.lastSelection.surroundContents(span);
            window.flutter_inappwebview.callHandler('onHighlight', span.textContent);
            window.lastSelection = null;
          }
        };

        window.removeHighlights = function() {
          const highlights = document.querySelectorAll('.highlighted');
          highlights.forEach(function(node) {
            node.replaceWith(...node.childNodes);
          });
        };
      ''');
    } catch (e) {
      debug('Error injecting JavaScript: $e');
    }
  }

  Future<void> highlightText(
      InAppWebViewController? webViewController, String url) async {
    if (webViewController == null) return;
    // debug(url);

    try {
      String jsCode = await loadLocalJs();

      await webViewController.evaluateJavascript(source: jsCode);
      String hashFun = """ window.generateContentFingerprint() """;
      String hash = await webViewController.evaluateJavascript(source: hashFun);
      final List<String> highlights = HiveDBHelper.getHighlights(hash);

      // debug(highlights);

      String highlightJs = """
        window.highlightContent(${highlights.map((e) => jsonEncode(e)).toList()});
      """;

      // Evaluate the generated JavaScript
      await webViewController.evaluateJavascript(source: highlightJs);
    } catch (e) {
      debug('Error highlighting text: $e');
    }
  }

  Future<String> loadLocalJs() async {
    return await rootBundle.loadString('assets/js/highlighting.js');
  }
}
