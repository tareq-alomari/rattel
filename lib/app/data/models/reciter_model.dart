class Reciter {
  final String id;
  final String name;
  final String arabicName;
  final String? r2Path;
  final String? format;

  Reciter({
    required this.id,
    required this.name,
    required this.arabicName,
    this.r2Path,
    this.format,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'arabicName': arabicName,
      'r2Path': r2Path,
      'format': format,
    };
  }

  factory Reciter.fromMap(Map<String, dynamic> map) {
    return Reciter(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      arabicName: map['arabicName'] ?? '',
      r2Path: map['r2Path'],
      format: map['format'],
    );
  }
}

enum RepeatMode { none, ayah, range }
