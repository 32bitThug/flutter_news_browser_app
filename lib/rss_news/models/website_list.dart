// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:hive/hive.dart';

part 'website_list.g.dart';

@HiveType(typeId: 12)
class Website extends HiveObject {
  @HiveField(0)
  final String domain;

  Website({
    required this.domain,
  });

  Website copyWith({
    String? domain,
  }) {
    return Website(
      domain: domain ?? this.domain,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'domain': domain,
    };
  }

  factory Website.fromMap(Map<String, dynamic> map) {
    return Website(
      domain: map['domain'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Website.fromJson(String source) => Website.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Website(domain: $domain)';

  @override
  bool operator ==(covariant Website other) {
    if (identical(this, other)) return true;
  
    return 
      other.domain == domain;
  }

  @override
  int get hashCode => domain.hashCode;
}
