// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WebHighlight {
  final String url;
  final String text;
  WebHighlight({
    required this.url,
    required this.text,
  });

  WebHighlight copyWith({
    String? url,
    String? text,
  }) {
    return WebHighlight(
      url: url ?? this.url,
      text: text ?? this.text,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'text': text,
    };
  }

  factory WebHighlight.fromMap(Map<String, dynamic> map) {
    return WebHighlight(
      url: map['url'] as String,
      text: map['text'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory WebHighlight.fromJson(String source) => WebHighlight.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'WebHighlight(url: $url, text: $text)';

  @override
  bool operator ==(covariant WebHighlight other) {
    if (identical(this, other)) return true;
  
    return 
      other.url == url &&
      other.text == text;
  }

  @override
  int get hashCode => url.hashCode ^ text.hashCode;
}
