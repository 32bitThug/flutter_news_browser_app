import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AdBlockService {
  final List<ContentBlocker> contentBlockers = [];

  Future<List<ContentBlocker>> loadEasyListRules(BuildContext context) async {
    try {
      String easyListContent = await DefaultAssetBundle.of(context)
          .loadString('assets/easylist.txt');
      List<ContentBlocker> easyListBlockers = await _parseEasyList(easyListContent);
      contentBlockers.addAll(easyListBlockers);
      return contentBlockers;
    } catch (e) {
      debug("Failed to load EasyList: $e");
      return [];
    }
  }

  Future<List<ContentBlocker>> _parseEasyList(String content) async {
    List<ContentBlocker> blockers = [];
    
    for (String line in content.split('\n')) {
      try {
        // Skip comments and empty lines
        if (line.isEmpty || line.startsWith('!') || line.startsWith('[')) {
          continue;
        }

        // Handle domain blocking rules
        if (line.startsWith('||')) {
          String pattern = _sanitizePattern(line);
          if (pattern.isNotEmpty) {
            blockers.add(ContentBlocker(
              trigger: ContentBlockerTrigger(
                urlFilter: pattern,
                // Add unless-domain to prevent false positives
                unlessDomain: const ["*"], 
              ),
              action: ContentBlockerAction(
                type: ContentBlockerActionType.BLOCK,
              ),
            ));
          }
        }
        
        // Limit the number of rules to prevent memory issues
        if (blockers.length >= 5000) {
          debug("Reached maximum number of rules");
          break;
        }
      } catch (e) {
        debug("Error parsing rule: $line");
        continue; // Skip problematic rules
      }
    }
    return blockers;
  }

  String _sanitizePattern(String rule) {
    try {
      // Remove the domain prefix
      String pattern = rule.substring(2);
      
      // Remove any options or comments
      if (pattern.contains('\$')) {
        pattern = pattern.split('\$')[0];
      }
      
      // Remove common problematic characters
      pattern = pattern
        .replaceAll('^', '')
        .replaceAll('*', '.*')
        .replaceAll('?', '\\?')
        .replaceAll('.', '\\.')
        .replaceAll('|', '\\|')
        .replaceAll('[', '\\[')
        .replaceAll(']', '\\]')
        .replaceAll('(', '\\(')
        .replaceAll(')', '\\)')
        .trim();

      // Ensure the pattern is valid
      if (pattern.isEmpty || pattern == '.*') {
        return '';
      }

      return pattern;
    } catch (e) {
      debug("Error sanitizing pattern: $rule");
      return '';
    }
  }
}