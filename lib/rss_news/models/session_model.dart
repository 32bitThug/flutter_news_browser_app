// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class Session {
  final String board;
  final String className;
  final String subject;
  final String chapter;
  final List<String> topics;
  final List<String> subtopics;
  final int duration;
  Session({
    required this.board,
    required this.className,
    required this.subject,
    required this.chapter,
    required this.topics,
    required this.subtopics,
    required this.duration,
  });

  Session copyWith({
    String? board,
    String? className,
    String? subject,
    String? chapter,
    List<String>? topics,
    List<String>? subtopics,
    int? duration,
  }) {
    return Session(
      board: board ?? this.board,
      className: className ?? this.className,
      subject: subject ?? this.subject,
      chapter: chapter ?? this.chapter,
      topics: topics ?? this.topics,
      subtopics: subtopics ?? this.subtopics,
      duration: duration ?? this.duration,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'board': board,
      'className': className,
      'subject': subject,
      'chapter': chapter,
      'topics': topics,
      'subtopics': subtopics,
      'duration': duration,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      board: map['board'] as String,
      className: map['className'] as String,
      subject: map['subject'] as String,
      chapter: map['chapter'] as String,
      topics: List<String>.from((map['topics'] as List<String>)),
      subtopics: List<String>.from((map['subtopics'] as List<String>)),
      duration: map['duration'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) =>
      Session.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Session(board: $board, className: $className, subject: $subject, chapter: $chapter, topics: $topics, subtopics: $subtopics, duration: $duration)';
  }

  @override
  bool operator ==(covariant Session other) {
    if (identical(this, other)) return true;

    return other.board == board &&
        other.className == className &&
        other.subject == subject &&
        other.chapter == chapter &&
        listEquals(other.topics, topics) &&
        listEquals(other.subtopics, subtopics) &&
        other.duration == duration;
  }

  @override
  int get hashCode {
    return board.hashCode ^
        className.hashCode ^
        subject.hashCode ^
        chapter.hashCode ^
        topics.hashCode ^
        subtopics.hashCode ^
        duration.hashCode;
  }
}
