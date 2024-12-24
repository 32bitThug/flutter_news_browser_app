import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/provider/timer_provider.dart';
import 'package:flutter_browser/rss_news/screens/app_language_selection_screen.dart';
import 'package:flutter_browser/rss_news/services/http_ovverides.dart';
import 'package:flutter_browser/rss_news/services/unique_id.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_browser/models/browser_model.dart';
import 'package:flutter_browser/models/webview_model.dart';
import 'browser.dart';

// ignore: non_constant_identifier_names
late final String WEB_ARCHIVE_DIR;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_1;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_2;
// ignore: non_constant_identifier_names
late final double TAB_VIEWER_BOTTOM_OFFSET_3;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_1 = 0.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_2 = 10.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_OFFSET_3 = 20.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
// ignore: constant_identifier_names
const double TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // WebViewPlatform.instance = WebWebViewPlatform();
  // HandShakeException fix
  HttpOverrides.global = MyHttpOverrides();
  // Initialize Hive and other services
  await Hive.initFlutter();
  await HiveDBHelper.initializeHive();
  deviceId = await UniqueId.initUniqueIdentifierState();
  store = await HiveStore.open(boxName: "graphql");
  // BackgroundTokenService.initialize();

  WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;
  TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
  TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
  TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;

  await FlutterDownloader.initialize(debug: kDebugMode);

  // Start the app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WebViewModel()),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          create: (_) => BrowserModel(),
          update: (context, webViewModel, browserModel) {
            browserModel ??= BrowserModel();
            browserModel.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
        ),
        ChangeNotifierProvider(create: (_) => TimerProvider()),
      ],
      child: const FlutterBrowserApp(),
    ),
  );
}

class FlutterBrowserApp extends StatelessWidget {
  const FlutterBrowserApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News Browser',
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      navigatorKey: myNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => ValueListenableBuilder(
              valueListenable:
                  Hive.box<List<String>>('preferences').listenable(),
              builder:
                  (BuildContext context, Box<List<String>> box, Widget? child) {
                // Provider.of<TimerProvider>(context, listen: false).startTimer();
                final sources = box.get('selectedSources') ?? [];
                return sources.isNotEmpty
                    ? const Browser()
                    : AppLanguageSelectionScreen();
              },
            ),
      },
    );
  }
}
