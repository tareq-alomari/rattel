class HadithBook {
  final int? id;
  final String name; // e.g., 'bukhari'
  final String titleAr; // e.g., 'صحيح البخاري'
  final String author;
  final int hadithCount;

  HadithBook({
    this.id,
    required this.name,
    required this.titleAr,
    required this.author,
    required this.hadithCount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'title_ar': titleAr,
      'author': author,
      'hadith_count': hadithCount,
    };
  }

  factory HadithBook.fromMap(Map<String, dynamic> map) {
    return HadithBook(
      id: map['id'],
      name: map['name'],
      titleAr: map['title_ar'],
      author: map['author'],
      hadithCount: map['hadith_count'],
    );
  }
}
