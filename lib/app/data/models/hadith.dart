class Hadith {
  final int? id;
  final int bookId;
  final int hadithNumber;
  final String text;
  final String explanation;
  final String searchTerm;
  final bool isFavorite;
  final int? pageNumber;

  Hadith({
    this.id,
    required this.bookId,
    required this.hadithNumber,
    required this.text,
    required this.explanation,
    required this.searchTerm,
    this.isFavorite = false,
    this.pageNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'book_id': bookId,
      'hadith_number': hadithNumber,
      'text': text,
      'explanation': explanation,
      'search_term': searchTerm,
      'is_favorite': isFavorite ? 1 : 0,
      'page_number': pageNumber,
    };
  }

  factory Hadith.fromMap(Map<String, dynamic> map) {
    return Hadith(
      id: map['id'],
      bookId: map['book_id'],
      hadithNumber: map['hadith_number'],
      text: map['text'],
      explanation: map['explanation'],
      searchTerm: map['search_term'],
      isFavorite: (map['is_favorite'] ?? 0) == 1,
      pageNumber: map['page_number'],
    );
  }
}
