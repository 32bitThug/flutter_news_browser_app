// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_browser/rss_news/grpahql/graphql_requests.dart';
import 'package:flutter_browser/rss_news/models/book_model.dart';
import 'package:flutter_browser/rss_news/models/page_attributes_model.dart';
import 'package:flutter_browser/rss_news/models/session_model.dart';
import 'package:flutter_browser/rss_news/provider/timer_provider.dart';
import 'package:flutter_browser/rss_news/services/session_services.dart';
import 'package:flutter_browser/rss_news/utils/debug.dart';
import 'package:flutter_browser/rss_news/utils/show_snackbar.dart';
import 'package:provider/provider.dart';

class SessionScreen extends StatefulWidget {
  const SessionScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SessionScreenState createState() => _SessionScreenState();
}

class _SessionScreenState extends State<SessionScreen> {
  Future<List<PageAttributes>?>? res;
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
  String selectedChapter = '';
  Set<String> selectedTopics = {};
  Set<String> selectedSubtopics = {};
  int time = 0;

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

  test() async {
    await Provider.of<TimerProvider>(context, listen: false)
        .updateLastSessionTime();
    // Provider.of<TimerProvider>(context, listen: false).startTimer();
    Navigator.pop(context);
  }

  void getBooks() async {
    List<Book>? books = await GraphQLRequests().getBooks();
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

  List<Map<String, dynamic>> hierarchy = [];

  void saveSession() async {
    debug(selectedChapter);
    if (selectedChapter.length > 1) {
      Session session = Session(
          board: "",
          className: className!,
          subject: subject!,
          chapter: selectedChapter,
          topics:
              selectedTopics.isEmpty ? selectedTopics.toList() : ["No topics"],
          subtopics: selectedSubtopics.isEmpty
              ? selectedSubtopics.toList()
              : ["No Subtopics"],
          duration: time);
      debug(session);
      final op = await GraphQLRequests().createSession(session);
      debug(op);
      if (op != null) {
        showSnackBar(message: "Session Created Successfully!");
        await Provider.of<TimerProvider>(context, listen: false)
            .updateLastSessionTime();
        Navigator.pop(context);
      }
    } else {
      showSnackBar(message: "Select Atleast One Chapter Or A Topic");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text("Create Session"),
          actions: [
            ElevatedButton.icon(
              // icon: const Icon(Icons.save),
              label: const Text("Save Session"),
              onPressed: () {
                // Add your save functionality here
                saveSession();
                print("Save button clicked");
              },
            ),
          ],
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
                              classNames?.sort((a, b) =>
                                  int.parse(a).compareTo(int.parse(b)));
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
                            subjects =
                                className != null && selectedBoard != null
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
                          // Fetch the page attributes when subject is selected
                          res = GraphQLRequests()
                              .getPageAttributesByBookID(bookId!);
                          setState(() {});
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
              if (res != null)
                FutureBuilder<List<PageAttributes>?>(
                  future:
                      res, // Make sure items is a Future that will resolve with the list of items
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (snapshot.hasData) {
                      final items = snapshot.data!;

                      if (items.isNotEmpty) {
                        hierarchy =
                            SessionServices.createHierarchy(items.toList());
                      }

                      return items.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: hierarchy.length,
                              itemBuilder: (context, index) {
                                final chapter = hierarchy[index];
                                final chapterItem =
                                    chapter['item'] as PageAttributes;
                                final topics = chapter['topics']
                                    as List<Map<String, dynamic>>;
                                final directSubtopics = chapter['subtopics']
                                    as List<Map<String, dynamic>>;
                                return Padding(
                                  padding: EdgeInsets.only(
                                      bottom: index + 1 == hierarchy.length
                                          ? 64.0
                                          : 0),
                                  child: Card(
                                    elevation: 0,
                                    margin: const EdgeInsets.all(4.0),
                                    child: ExpansionTile(
                                      title: GestureDetector(
                                        onTap: () {
                                          if (chapterItem.pageNumber > 0) {
                                            // onTap(chapterItem.pageNumber);
                                          }
                                        },
                                        child: Text(
                                          chapterItem.text,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      subtitle: Text(
                                          'Page ${chapterItem.pageNumber}'),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (topics.isEmpty)
                                            Checkbox(
                                              value: selectedChapter ==
                                                  chapterItem.text,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  if (selectedChapter ==
                                                      chapterItem.text) {
                                                    selectedChapter =
                                                        ""; // Uncheck if already selected
                                                  } else {
                                                    selectedChapter = chapterItem
                                                        .text; // Check the new value
                                                  }
                                                });
                                                debug(
                                                    selectedChapter); // Use debugPrint to log
                                              },
                                            ),
                                          if (topics.isNotEmpty)
                                            const Icon(Icons.expand_more),
                                        ],
                                      ),
                                      children: [
                                        // Render topics
                                        ...topics.map<Widget>((topic) {
                                          final topicItem =
                                              topic['item'] as PageAttributes;
                                          final subtopics = topic['subtopics']
                                              as List<Map<String, dynamic>>;

                                          if (subtopics.isEmpty) {
                                            return ListTile(
                                              title: Text(topicItem.text),
                                              subtitle: Text(
                                                  'Page ${topicItem.pageNumber}'),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 32.0, right: 16.0),
                                              trailing: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 32.0),
                                                child: Checkbox(
                                                    value:
                                                        selectedTopics.contains(
                                                            topicItem.text),
                                                    onChanged: (bool? value) {
                                                      setState(() {
                                                        if (value == true) {
                                                          selectedTopics.add(
                                                              topicItem.text);
                                                          selectedChapter =
                                                              chapterItem.text;
                                                        } else {
                                                          selectedTopics.remove(
                                                              topicItem.text);
                                                          if (selectedTopics
                                                              .isEmpty) {
                                                            selectedChapter =
                                                                "";
                                                          }
                                                        }
                                                        // debug(selectedSubtopics);
                                                        debug(selectedTopics);
                                                        debug(selectedChapter);
                                                      });
                                                    }),
                                              ),
                                              onTap: () {
                                                if (topicItem.pageNumber > 0) {
                                                  // onTap(topicItem.pageNumber);
                                                }
                                              },
                                            );
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 16.0),
                                            child: ExpansionTile(
                                              title: GestureDetector(
                                                onTap: () {
                                                  // if (topicItem.pageNumber > 0) {
                                                  //   onTap(topicItem.pageNumber);
                                                  // }
                                                },
                                                child: Text(topicItem.text),
                                              ),
                                              subtitle: Text(
                                                  'Page ${topicItem.pageNumber}'),
                                              trailing: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  //
                                                  Icon(Icons
                                                      .expand_more), // Default arrow
                                                ],
                                              ),
                                              childrenPadding:
                                                  const EdgeInsets.only(
                                                      left:
                                                          32.0), // Indentation
                                              children: subtopics
                                                  .map<Widget>((subtopic) {
                                                final subtopicItem =
                                                    subtopic['item']
                                                        as PageAttributes;

                                                return ListTile(
                                                  title:
                                                      Text(subtopicItem.text),
                                                  subtitle: Text(
                                                      'Page ${subtopicItem.pageNumber}'),
                                                  contentPadding: const EdgeInsets
                                                      .only(
                                                      left:
                                                          16.0), // Adjusted padding
                                                  trailing: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 48.0),
                                                    child: Checkbox(
                                                        value: selectedSubtopics
                                                            .contains(
                                                                subtopicItem
                                                                    .text),
                                                        onChanged:
                                                            (bool? value) {
                                                          setState(() {
                                                            if (value == true) {
                                                              selectedSubtopics
                                                                  .add(subtopicItem
                                                                      .text);
                                                              selectedTopics
                                                                  .add(topicItem
                                                                      .text);
                                                              selectedChapter =
                                                                  chapterItem
                                                                      .text;
                                                            } else {
                                                              selectedSubtopics
                                                                  .remove(
                                                                      subtopicItem
                                                                          .text);
                                                              selectedTopics
                                                                  .remove(
                                                                      topicItem
                                                                          .text);
                                                              if (selectedTopics
                                                                  .isEmpty) {
                                                                selectedChapter =
                                                                    "";
                                                              }
                                                            }
                                                            debug(
                                                                selectedChapter);
                                                            debug(
                                                                selectedSubtopics);
                                                            debug(
                                                                selectedTopics);
                                                          });
                                                        }),
                                                  ),

                                                  onTap: () {
                                                    if (subtopicItem
                                                            .pageNumber >
                                                        0) {
                                                      // onTap(subtopicItem.pageNumber);
                                                    }
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                          );
                                        }),

                                        // Render direct subtopics if no topics exist
                                        if (topics.isEmpty)
                                          ...directSubtopics
                                              .map<Widget>((subtopic) {
                                            final subtopicItem =
                                                subtopic['item']
                                                    as PageAttributes;

                                            return ListTile(
                                              title: Text(subtopicItem.text),
                                              subtitle: Text(
                                                  'Page ${subtopicItem.pageNumber}'),
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                      left: 32.0, right: 16.0),
                                            );
                                          }),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                          : const Center(child: Text('No index data'));
                    } else {
                      return const Center(child: Text("No items found"));
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
