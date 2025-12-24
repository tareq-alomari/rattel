/// Surah model
class Surah {
  final int surahNumber;
  final String surahName;
  final String surahNameEn;
  final int versesCount;

  Surah({
    required this.surahNumber,
    required this.surahName,
    required this.surahNameEn,
    required this.versesCount,
  });
}

/// Ayah model with translation and transliteration support
class Ayah {
  final int ayahId;
  final int surahNumber;
  final String surahName;
  final String surahNameEn;
  final int ayahNumber;
  final String ayahText;
  final String? cleanText;
  final String? transliteration;
  final int? pageNumber;
  final int? juzNumber;
  final Map<String, String>? translations; // languageCode -> translation text

  Ayah({
    required this.ayahId,
    required this.surahNumber,
    required this.surahName,
    required this.surahNameEn,
    required this.ayahNumber,
    required this.ayahText,
    this.cleanText,
    this.transliteration,
    this.pageNumber,
    this.juzNumber,
    this.translations,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    return Ayah(
      ayahId: map['ayah_id'] as int,
      surahNumber: map['surah_number'] as int,
      surahName: map['surah_name'] as String,
      surahNameEn: map['surah_name_en'] as String,
      ayahNumber: map['ayah_number'] as int,
      ayahText: map['ayah_text'] as String,
      cleanText: map['clean_text'] as String?,
      transliteration: map['transliteration'] as String?,
      pageNumber: map['page_number'] as int?,
      juzNumber: map['juz_number'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ayah_id': ayahId,
      'surah_number': surahNumber,
      'surah_name': surahName,
      'surah_name_en': surahNameEn,
      'ayah_number': ayahNumber,
      'ayah_text': ayahText,
      'clean_text': cleanText,
      'transliteration': transliteration,
      'page_number': pageNumber,
      'juz_number': juzNumber,
    };
  }

  /// Create a copy with translations
  Ayah copyWithTranslations(Map<String, String> translations) {
    return Ayah(
      ayahId: ayahId,
      surahNumber: surahNumber,
      surahName: surahName,
      surahNameEn: surahNameEn,
      ayahNumber: ayahNumber,
      ayahText: ayahText,
      cleanText: cleanText,
      transliteration: transliteration,
      pageNumber: pageNumber,
      juzNumber: juzNumber,
      translations: translations,
    );
  }
}

/// Translation model for verse translations
class Translation {
  final int translationId;
  final int verseId;
  final String languageCode;
  final String text;

  Translation({
    required this.translationId,
    required this.verseId,
    required this.languageCode,
    required this.text,
  });

  factory Translation.fromMap(Map<String, dynamic> map) {
    return Translation(
      translationId: map['translation_id'] as int,
      verseId: map['verse_id'] as int,
      languageCode: map['language_code'] as String,
      text: map['text'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'translation_id': translationId,
      'verse_id': verseId,
      'language_code': languageCode,
      'text': text,
    };
  }
}

/// Chapter metadata with comprehensive information
class ChapterMetadata {
  final int id;
  final String nameArabic;
  final String transliteration;
  final String translationEn;
  final String type; // meccan or medinan
  final int totalVerses;

  ChapterMetadata({
    required this.id,
    required this.nameArabic,
    required this.transliteration,
    required this.translationEn,
    required this.type,
    required this.totalVerses,
  });

  factory ChapterMetadata.fromMap(Map<String, dynamic> map) {
    return ChapterMetadata(
      id: map['chapter_id'] as int,
      nameArabic: map['name_arabic'] as String,
      transliteration: map['transliteration'] as String,
      translationEn: map['translation_en'] as String,
      type: map['type'] as String,
      totalVerses: map['total_verses'] as int,
    );
  }

  factory ChapterMetadata.fromJson(Map<String, dynamic> json) {
    return ChapterMetadata(
      id: json['id'] as int,
      nameArabic: json['name'] as String,
      transliteration: json['transliteration'] as String,
      translationEn: json['translation'] as String,
      type: json['type'] as String,
      totalVerses: json['total_verses'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chapter_id': id,
      'name_arabic': nameArabic,
      'transliteration': transliteration,
      'translation_en': translationEn,
      'type': type,
      'total_verses': totalVerses,
    };
  }
}

/// Surah info with verse count and metadata
class SurahInfo {
  final int surahNumber;
  final String surahName;
  final String surahNameEn;
  final int versesCount;
  final String revelationType;
  final String? transliteration;

  SurahInfo({
    required this.surahNumber,
    required this.surahName,
    required this.surahNameEn,
    required this.versesCount,
    this.revelationType = 'meccan',
    this.transliteration,
  });

  factory SurahInfo.fromMap(Map<String, dynamic> map) {
    return SurahInfo(
      surahNumber: map['surah_number'] as int,
      surahName: map['surah_name'] as String,
      surahNameEn: map['surah_name_en'] as String,
      versesCount: map['verses_count'] as int,
      revelationType: map['revelation_type'] as String? ?? 'meccan',
      transliteration: map['transliteration'] as String?,
    );
  }

  factory SurahInfo.fromChapterMetadata(ChapterMetadata metadata) {
    return SurahInfo(
      surahNumber: metadata.id,
      surahName: metadata.nameArabic,
      surahNameEn: metadata.translationEn,
      versesCount: metadata.totalVerses,
      revelationType: metadata.type,
      transliteration: metadata.transliteration,
    );
  }
}
