/// Memorization model
class MemorizationModel {
  final int? memId;
  final int userId;
  final int surahNumber;
  final int fromAyah;
  final int toAyah;
  final String type; // 'memorization' or 'revision'
  final String date;

  MemorizationModel({
    this.memId,
    required this.userId,
    required this.surahNumber,
    required this.fromAyah,
    required this.toAyah,
    required this.type,
    required this.date,
  });

  factory MemorizationModel.fromMap(Map<String, dynamic> map) {
    return MemorizationModel(
      memId: map['mem_id'] as int?,
      userId: map['user_id'] as int,
      surahNumber: map['surah_number'] as int,
      fromAyah: map['from_ayah'] as int,
      toAyah: map['to_ayah'] as int,
      type: map['type'] as String,
      date: map['date'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mem_id': memId,
      'user_id': userId,
      'surah_number': surahNumber,
      'from_ayah': fromAyah,
      'to_ayah': toAyah,
      'type': type,
      'date': date,
    };
  }

  int get versesCount => toAyah - fromAyah + 1;
  bool get isMemorization => type == 'memorization';
  bool get isRevision => type == 'revision';
}
