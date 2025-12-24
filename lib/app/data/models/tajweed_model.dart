class TajweedModel {
  final int? id;
  final String category;
  final String title;
  final String content;
  final String
  examples; // Stored as pipe-separated string "Example 1|Example 2"

  TajweedModel({
    this.id,
    required this.category,
    required this.title,
    required this.content,
    this.examples = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'content': content,
      'examples': examples,
    };
  }

  factory TajweedModel.fromMap(Map<String, dynamic> map) {
    return TajweedModel(
      id: map['id'],
      category: map['category'],
      title: map['title'],
      content: map['content'],
      examples: map['examples'] ?? '',
    );
  }

  List<String> get examplesList => examples.isEmpty ? [] : examples.split('|');
}
