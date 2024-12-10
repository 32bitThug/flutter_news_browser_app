class PageAttributes {
  String id;
  int pageNumber;
  String bookID;
  String text;
  String type;
  int order;

  PageAttributes({
    required this.id,
    required this.pageNumber,
    required this.bookID,
    required this.text,
    required this.type,
    required this.order,
  });

  PageAttributes copyWith({
    String? id,
    int? pageNumber,
    String? bookId,
    String? text,
    String? type,
    int? order,
  }) =>
      PageAttributes(
        id: id ?? this.id,
        pageNumber: pageNumber ?? this.pageNumber,
        bookID: bookId ?? this.bookID,
        text: text ?? this.text,
        type: type ?? this.type,
        order: order ?? this.order,
      );

  factory PageAttributes.fromMap(Map<String, dynamic> json) => PageAttributes(
        id: json["id"],
        pageNumber: json["pageNumber"],
        bookID: json["bookID"],
        text: json["text"],
        type: json["type"],
        order: json["order"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "pageNumber": pageNumber,
        "bookID": bookID,
        "text": text,
        "type": type,
        "order": order,
      };
}