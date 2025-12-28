class Surah {
  final int number;
  final String name;
  final String transliteration;
  final String translation;
  final int ayahCount;
  final int startAyah;
  final int endAyah;
  final String revelationType; // "Meccan" or "Medinan"

  Surah({
    required this.number,
    required this.name,
    required this.transliteration,
    required this.translation,
    required this.ayahCount,
    required this.startAyah,
    required this.endAyah,
    required this.revelationType,
  });

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'name': name,
      'transliteration': transliteration,
      'translation': translation,
      'ayahCount': ayahCount,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'revelationType': revelationType,
    };
  }

  factory Surah.fromMap(Map<String, dynamic> map) {
    return Surah(
      number: map['number'] ?? 0,
      name: map['name'] ?? '',
      transliteration: map['transliteration'] ?? '',
      translation: map['translation'] ?? '',
      ayahCount: map['ayahCount'] ?? 0,
      startAyah: map['startAyah'] ?? 0,
      endAyah: map['endAyah'] ?? 0,
      revelationType: map['revelationType'] ?? '',
    );
  }
}
