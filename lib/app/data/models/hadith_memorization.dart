class HadithMemorization {
  final int? id;
  final int hadithId;
  final String status;
  final String createdAt;

  HadithMemorization({
    this.id,
    required this.hadithId,
    this.status = 'memorized',
    required this.createdAt,
  });

  factory HadithMemorization.fromMap(Map<String, dynamic> map) {
    return HadithMemorization(
      id: map['id'],
      hadithId: map['hadith_id'],
      status: map['status'],
      createdAt: map['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hadith_id': hadithId,
      'status': status,
      'created_at': createdAt,
    };
  }
}
