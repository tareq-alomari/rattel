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

/// Ayah model
class Ayah {
  final int ayahId;
  final int surahNumber;
  final String surahName;
  final String surahNameEn;
  final int ayahNumber;
  final String ayahText;
  final String? cleanText;
  final int? pageNumber;
  final int? juzNumber;

  Ayah({
    required this.ayahId,
    required this.surahNumber,
    required this.surahName,
    required this.surahNameEn,
    required this.ayahNumber,
    required this.ayahText,
    this.cleanText,
    this.pageNumber,
    this.juzNumber,
  });

  factory Ayah.fromMap(Map<String, dynamic> map) {
    // Handle 'id' vs 'ayah_id' difference if needed, defaulting to 0 or -1 if missing
    final id = map['ayah_id'] ?? map['id'] ?? 0;

    return Ayah(
      ayahId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      surahNumber: (map['surah_number'] as int?) ?? 0,
      surahName: (map['surah_name'] as String?) ?? '',
      surahNameEn: (map['surah_name_en'] as String?) ?? '',
      ayahNumber: (map['ayah_number'] as int?) ?? 0,
      ayahText: (map['ayah_text'] as String?) ?? '',
      cleanText: map['clean_text'] as String?,
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
      'page_number': pageNumber,
      'juz_number': juzNumber,
    };
  }
}

/// Surah info with verse count
class SurahInfo {
  final int surahNumber;
  final String surahName;
  final String surahNameEn;
  final int versesCount;
  final String revelationType;

  SurahInfo({
    required this.surahNumber,
    required this.surahName,
    required this.surahNameEn,
    required this.versesCount,
    this.revelationType = 'meccan',
  });

  factory SurahInfo.fromMap(Map<String, dynamic> map) {
    return SurahInfo(
      surahNumber: map['surah_number'] as int,
      surahName: map['surah_name'] as String,
      surahNameEn: map['surah_name_en'] as String,
      versesCount: map['verses_count'] as int,
    );
  }
}

/// Page mapping model
class QuranPage {
  final int pageNumber;
  final int surahNumber;
  final int startAyah;
  final int endAyah;

  QuranPage({
    required this.pageNumber,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });

  factory QuranPage.fromMap(Map<String, dynamic> map) {
    return QuranPage(
      pageNumber: map['page_number'] as int,
      surahNumber: map['surah_number'] as int,
      startAyah: map['start_ayah'] as int,
      endAyah: map['end_ayah'] as int,
    );
  }
}

/// Tafseer model
class Tafseer {
  final int id;
  final String name;
  final String author;
  final String language;

  Tafseer({
    required this.id,
    required this.name,
    required this.author,
    required this.language,
  });
}
