// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_browser/Db/hive_db_helper.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_requests.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Timer? timer;
  Map<String, Map<String, Map<String, String>>> groupedBooks = {};
  List<String>? boards = [];
  List<String>? classNames = [];
  List<String>? subjects = [];
  String? selectedBoard;
  String? className;
  String? subject;
  String? chapter;
  String? topic;
  String? subtopic;
  String? duration;

  TextEditingController chapterController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  TextEditingController subtopicController = TextEditingController();
  TextEditingController durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _startTokenExpirationCheck();
    getBooks();
  }

  @override
  void dispose() {
    timer?.cancel();
    chapterController.dispose();
    topicController.dispose();
    subtopicController.dispose();
    durationController.dispose();
    super.dispose();
  }

  // void _startTokenExpirationCheck() {
  //   timer = Timer.periodic(
  //     const Duration(minutes: 10),
  //     (timer) async {
  //       DateTime? expirationTime = HiveDBHelper.getToken();
  //       debugPrint('Token Expiration Time: $expirationTime');
  //       if (expirationTime != null && DateTime.now().isAfter(expirationTime)) {
  //         // You may handle token expiration here
  //       } else {
  //         debug('Token is still valid');
  //       }
  //     },
  //   );
  // }

  void getBooks() async {
    final books = await GraphQLRequests().getBooks();
    if (books != null) {
      for (var book in books) {
        // Group by board
        if (!groupedBooks.containsKey(book.board)) {
          groupedBooks[book.board!] = {};
        }

        // Group by class within the board
        if (!groupedBooks[book.board]!.containsKey(book.classNumber)) {
          groupedBooks[book.board]![book.classNumber!] = {};
        }

        // Add subject with ID to the class dictionary
        groupedBooks[book.board]![book.classNumber!]![book.subject!] = book.id!;
      }

      setState(() {
        boards = groupedBooks.keys.toList();
      });
    }
  }

  void createSession() async {
    if (className == null ||
        subtopic == null ||
        subject == null ||
        duration == null ||
        chapter == null ||
        topic == null) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error"),
          content: const Text("All fields are required."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      final op = await GraphQLRequests().createSession(
        className!,
        subject!,
        topic!,
        chapter!,
        subtopic!,
        int.parse(duration!),
      );
      debug(op);
      if (op != null) {
        final expirationTime = DateTime.now().add(const Duration(minutes: 60));
        debug(expirationTime);
        await HiveDBHelper.setToken(expirationTime);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Session Created Successfully!")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Session"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 80, // Width to ensure consistent sizing
                    child: DropdownButtonFormField<String>(
                      value: selectedBoard,
                      items: boards?.map((String board) {
                        return DropdownMenuItem(
                          value: board,
                          child: Text(board),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          selectedBoard = value;
                          classNames = selectedBoard != null
                              ? groupedBooks[selectedBoard]!.keys.toList()
                              : [];
                          className = null;
                          subject = null;
                          if (classNames != null) {
                            classNames?.sort(
                                (a, b) => int.parse(a).compareTo(int.parse(b)));
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Board",
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: DropdownButtonFormField<String>(
                      value: className,
                      items: classNames?.map((String className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Text("Class $className"),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          className = value;
                          subject = null;
                          subjects = className != null && selectedBoard != null
                              ? groupedBooks[selectedBoard]![className]!
                                  .keys
                                  .toList()
                              : [];
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Class",
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 150,
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: subject,
                      items: subjects?.map((String sub) {
                        return DropdownMenuItem(
                          value: sub,
                          child: Text(sub),
                        );
                      }).toList(),
                      onChanged: (String? value) async {
                        subject = value;
                        String? bookId =
                            groupedBooks[selectedBoard]?[className]?[subject];
                       final res= await GraphQLRequests()
                            .getPageAttributesByBookID(bookId!);
                        setState(() {
                          
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Subject",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: chapterController,
              decoration: const InputDecoration(labelText: "Chapter"),
              onChanged: (value) => chapter = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: topicController,
              decoration: const InputDecoration(labelText: "Topic"),
              onChanged: (value) => topic = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: subtopicController,
              decoration: const InputDecoration(labelText: "Subtopic"),
              onChanged: (value) => subtopic = value,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration:
                  const InputDecoration(labelText: "Duration (in minutes)"),
              keyboardType: TextInputType.number,
              onChanged: (value) => duration = value,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: createSession,
              child: const Text("Add Session"),
            ),
          ],
        ),
      ),
    );
  }
}
