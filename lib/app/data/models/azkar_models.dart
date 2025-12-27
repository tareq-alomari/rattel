class Zekr {
  final String category;
  final String count;
  final String description;
  final String reference;
  final String zekr;

  Zekr({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
    required this.zekr,
  });

  factory Zekr.fromJson(Map<String, dynamic> json) {
    return Zekr(
      category: json['category'] ?? '',
      count: json['count'] ?? '',
      description: json['description'] ?? '',
      reference: json['reference'] ?? '',
      zekr: json['zekr'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'count': count,
      'description': description,
      'reference': reference,
      'zekr': zekr,
    };
  }
}

class AllahName {
  final String name;
  final String transliteration;
  final int number;
  final String enMeaning;
  final String found;

  AllahName({
    required this.name,
    this.transliteration = '',
    this.number = 0,
    this.enMeaning = '',
    this.found = '',
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      name: json['name'] ?? '',
      transliteration: json['transliteration'] ?? '',
      number: json['number'] ?? 0,
      enMeaning: json['en.meaning'] ?? '',
      found: json['found'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'transliteration': transliteration,
      'number': number,
      'en.meaning': enMeaning,
      'found': found,
    };
  }
}
