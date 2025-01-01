import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AdblockFilterProvider with ChangeNotifier {
  bool contentBlockerEnabled = false;
  List<ContentBlocker> contentBlockers = [];

  void toggleContentBlocker() {
    contentBlockerEnabled = !contentBlockerEnabled;
    notifyListeners();
  }

  Future<void> initializeBlockers(List<ContentBlocker> initialBlockers) async {
    contentBlockers = initialBlockers;
    notifyListeners();
  }

  bool get iscontentBlockerEnabled => contentBlockerEnabled;
  
  List<ContentBlocker> get activeBlockers =>
      contentBlockerEnabled ? contentBlockers : [];
}
