class Reciter {
  final String id;
  final String nameAr;
  final String nameEn;
  final String folder;
  final String? description;

  Reciter({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.folder,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nameAr': nameAr,
      'nameEn': nameEn,
      'folder': folder,
      'description': description,
    };
  }

  factory Reciter.fromMap(Map<String, dynamic> map) {
    return Reciter(
      id: map['id'],
      nameAr: map['nameAr'],
      nameEn: map['nameEn'],
      folder: map['folder'],
      description: map['description'],
    );
  }
}

enum RepeatMode { none, ayah, range }
