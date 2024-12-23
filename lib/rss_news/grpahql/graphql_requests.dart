import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/constants/constants.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_raw.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_services.dart';
import 'package:flutter_browser/rss_news/models/book_model.dart';
import 'package:flutter_browser/rss_news/models/device_model.dart';
import 'package:flutter_browser/rss_news/models/feed_model.dart';
import 'package:flutter_browser/rss_news/models/page_attributes_model.dart';
import 'package:flutter_browser/rss_news/models/session_model.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';

class GraphQLRequests {
  GraphQLRequests();

  Future<List<Feed>?> getFeeds() async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performQuery(GraphQLRaw.getFeeds, variables: {});

    if (response.hasException) {
      debugPrint('GraphQL Error: ${response.exception}');
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getFeeds')
        ? (data['getFeeds'] as List<dynamic>)
            .map((e) => Feed.fromJson(e as Map<String, dynamic>))
            .toList()
        : null;
  }

  Future<Map<String, dynamic>?> createDevice(Device device) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performMutation(GraphQLRaw.createDevice, variables: {
      'id': device.deviceId,
      'name': device.deviceName,
      'gid': device.groupId,
      'pid': device.profileId
    });

    if (response.hasException) {
      showSnackBar(message: response.exception!.raw![0]["message"].toString());
      return null;
    } else {
      showSnackBar(message: "device registerd succesfully");
    }
    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('createDevice')
        ? data['createDevice'] as Map<String, dynamic>
        : null;
  }

  Future<Map<String, dynamic>?> updateDevice(Device device) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performMutation(GraphQLRaw.updateDevice, variables: {
      'id': device.id,
      'name': device.deviceName,
    });

    if (response.hasException) {
      showSnackBar(message: response.exception!.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('updateDevice')
        ? data['updateDevice'] as Map<String, dynamic>
        : null;
  }

  Future<Map<String, dynamic>?> getDeviceById(String id) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performQuery(GraphQLRaw.getDeviceById, variables: {
      'id': id,
    });

    if (response.hasException) {
      showSnackBar(message: response.exception!.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getDeviceById')
        ? data['getDeviceById'] as Map<String, dynamic>
        : null;
  }

  Future<Map<String, dynamic>?> pushLog(
      String domain, String pageUrl, String deviceId, String category) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performQuery(GraphQLRaw.pushLog, variables: {
      'domain': domain,
      'page_url': pageUrl,
      'device_id': deviceId,
      'category': category,
    });

    if (response.hasException) {
      showSnackBar(message: response.exception!.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('pushLog')
        ? data['pushLog'] as Map<String, dynamic>
        : null;
  }

  Future<List<Object?>> childsActivities(String deviceId) async {
    final response = await GraphQLService(parentalControlApiUrl).performQuery(
      GraphQLRaw.childsActivities,
      variables: {
        'deviceId': deviceId,
      },
    );

    if (response.hasException) {
      showSnackBar(message: response.exception!.toString());
      return [];
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getAllWebsiteUsageLogs')
        ? data['getAllWebsiteUsageLogs'] as List<Object?>
        : [];
  }

  Future<Map<String, dynamic>?> createSession(Session session) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performQuery(GraphQLRaw.createSession, variables: {
      "class": session.className,
      "subject": session.subject,
      "chapter": session.chapter,
      "topics": session.topics,
      "subtopics": session.subtopics,
      "duration": session.duration
    });

    if (response.hasException) {
      showSnackBar(message: response.exception!.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('createSession')
        ? data['createSession'] as Map<String, dynamic>
        : null;
  }

  Future<List<Book>?> getBooks() async {
    final response = await GraphQLService(erpSchoolApiUrl)
        .performQuery(GraphQLRaw.getBooks, variables: {});

    if (response.hasException) {
      showSnackBar(message: response.exception.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getBooks')
        ? (data['getBooks'] as List<dynamic>)
            .map((e) => Book.fromMap(e as Map<String, dynamic>))
            .toList()
        : null;
  }

  Future<Map<String, dynamic>?> getDeviceBydeviceID(String deviceId) async {
    final response = await GraphQLService(parentalControlApiUrl)
        .performQuery(GraphQLRaw.getDeviceBydeviceID, variables: {
      "deviceID": deviceId,
    });

    if (response.hasException) {
      showSnackBar(message: response.exception.toString());
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getDeviceBydeviceID')
        ? data['getDeviceBydeviceID'] as Map<String, dynamic>?
        : null;
  }

  Future<List<PageAttributes>?> getPageAttributesByBookID(String bookID) async {
    final response = await GraphQLService(erpSchoolApiUrl).performQuery(
        GraphQLRaw.getPageAttributesByBookID,
        variables: {'bookID': bookID});
    debugPrint('Has exeption: ${response.exception}');

    if (response.hasException) {
      showSnackBar(message: 'GraphQL Error: ${response.exception}');
      return null;
    }

    final Map<String, dynamic>? data = response.data;

    return data != null && data.containsKey('getPageAttributesByBookID')
        ? (data['getPageAttributesByBookID'] as List<dynamic>)
            .map((e) => PageAttributes.fromMap(e as Map<String, dynamic>))
            .toList()
        : null;
  }
}
