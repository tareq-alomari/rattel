/// Dua (Supplication) Model
class DuaModel {
  final int? id;
  final String titleAr;
  final String? titleEn;
  final String duaText;
  final String? transliteration;
  final String? translation;
  final String category;
  final String? source;
  final int? count;
  final String? createdAt;

  DuaModel({
    this.id,
    required this.titleAr,
    this.titleEn,
    required this.duaText,
    this.transliteration,
    this.translation,
    required this.category,
    this.source,
    this.count,
    this.createdAt,
  });

  factory DuaModel.fromMap(Map<String, dynamic> map) {
    return DuaModel(
      id: map['id'] as int?,
      titleAr: map['title_ar'] as String,
      titleEn: map['title_en'] as String?,
      duaText: map['dua_text'] as String,
      transliteration: map['transliteration'] as String?,
      translation: map['translation'] as String?,
      category: map['category'] as String,
      source: map['source'] as String?,
      count: map['count'] as int?,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title_ar': titleAr,
      'title_en': titleEn,
      'dua_text': duaText,
      'transliteration': transliteration,
      'translation': translation,
      'category': category,
      'source': source,
      'count': count,
      'created_at': createdAt,
    };
  }
}
