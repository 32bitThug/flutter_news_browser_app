import 'package:flutter/material.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';
import 'package:flutter_browser/webview_tab.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:intl/intl.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_requests.dart';
import 'package:provider/provider.dart';

class ChildsActivityPage extends StatefulWidget {
  const ChildsActivityPage({super.key});

  @override
  State<ChildsActivityPage> createState() => _ChildsActivityPageState();
}

class _ChildsActivityPageState extends State<ChildsActivityPage> {
  Map<String, List<Map<String, dynamic>>> groupedLogs = {};
  Map<String, List<Map<String, dynamic>>> filteredLogs = {};
  bool isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  String getFormattedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final inputDate = DateTime(date.year, date.month, date.day);

    if (inputDate == today) {
      return 'Today';
    } else if (inputDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLogs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterLogs(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredLogs = Map.from(groupedLogs);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    Map<String, List<Map<String, dynamic>>> filtered = {};

    groupedLogs.forEach((date, logs) {
      final matchingLogs = logs.where((log) {
        final pageUrl = log['page_url'].toString().toLowerCase();
        return pageUrl.contains(lowercaseQuery);
      }).toList();

      if (matchingLogs.isNotEmpty) {
        filtered[date] = matchingLogs;
      }
    });

    setState(() {
      filteredLogs = filtered;
    });
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

  Future<void> fetchLogs() async {
    try {
      final ids = HiveDBHelper.getAllChildDevices();

      final List<dynamic> res = await Future.wait(
          ids.map((id) => GraphQLRequests().childsActivities(id)));

// Explicitly cast the expanded result to a List<Map<String, dynamic>>
      final List<Map<String, dynamic>> logs = res
          .expand((result) =>
              (result as List<dynamic>).whereType<Map<String, dynamic>>())
          .toList();

      logs.sort((a, b) =>
          int.parse(b['Timestamp']).compareTo(int.parse(a['Timestamp'])));
      // debugPrint(logs.toString());
      Map<String, List<Map<String, dynamic>>> grouped = {};
      for (var log in logs) {
        final timestamp = log['Timestamp'];
        final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
        final dateKey = getFormattedDate(date);

        if (!grouped.containsKey(dateKey)) {
          grouped[dateKey] = [];
        }
        grouped[dateKey]?.add(log);
      }

      final sortedGrouped = Map.fromEntries(
        grouped.entries.toList()
          ..sort((a, b) {
            // Special handling for Today and Yesterday
            final aDate = a.key == 'Today'
                ? DateTime.now()
                : a.key == 'Yesterday'
                    ? DateTime.now().subtract(const Duration(days: 1))
                    : DateFormat('MMM dd, yyyy').parse(a.key);
            final bDate = b.key == 'Today'
                ? DateTime.now()
                : b.key == 'Yesterday'
                    ? DateTime.now().subtract(const Duration(days: 1))
                    : DateFormat('MMM dd, yyyy').parse(b.key);
            return bDate.compareTo(aDate);
          }),
      );

      setState(() {
        groupedLogs = sortedGrouped;
        filteredLogs = Map.from(sortedGrouped);
        isLoading = false;
      });
    } catch (e) {
      showSnackBar(message: 'Error fetching logs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Child's Activities"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search activities...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filterLogs('');
                        },
                      )
                    : null,
              ),
              onChanged: filterLogs,
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredLogs.isEmpty
                    ? const Center(
                        child: Text('No matching activities found.'),
                      )
                    : ListView.builder(
                        itemCount: filteredLogs.length,
                        itemBuilder: (context, index) {
                          final date = filteredLogs.keys.elementAt(index);
                          final logs = filteredLogs[date];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              ...logs!.map((log) {
                                final pageUrl = log['page_url'];
                                final timestamp = log['Timestamp'];
                                final deviceName = log["Device_id"]
                                        ?["deviceName"] ??
                                    "Device Deleted";

                                final time = DateFormat('hh:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                    int.parse(timestamp),
                                  ),
                                );

                                return ListTile(
                                  title: Text(
                                    pageUrl,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  subtitle:
                                      Text('Visited at $time, by $deviceName'),
                                  leading: const Icon(Icons.link),
                                  onTap: () {
                                    addNewTab(url: WebUri(pageUrl));
                                    Navigator.pop(context);
                                  },
                                );
                              }),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
