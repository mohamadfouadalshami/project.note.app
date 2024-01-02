class Note {
  String id;
  String title;
  String content;
  DateTime modifiedTime;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.modifiedTime,
  });
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'],
      title: json['title'] as String,
      content: json['content'] as String,
      modifiedTime: DateTime.parse(json['modifiedTime'] as String),
    );
  }
}
