import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

enum Language {
  // ignore: constant_identifier_names
  English,
  // ignore: constant_identifier_names
  Hindi,
  // ignore: constant_identifier_names
  Telugu
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

const apiUrl = "https://dev-api-news-rss-sr235aqw.pragament.com/graphql";

const staticApiUrl = "https://staticapis.pragament.com/rss_news/rss_feeds.json";

const parentalControlApiUrl = "http://192.168.1.112:5008/graphql";

const erpSchoolApiUrl = "http://192.168.1.106:5002/graphql";

late Store store;
late String deviceId;

class Loader extends StatelessWidget {
  // ignore: use_key_in_widget_constructors
  const Loader({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
