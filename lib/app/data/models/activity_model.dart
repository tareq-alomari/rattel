/// Activity model for heatmap
class ActivityModel {
  final int? activityId;
  final int userId;
  final String date;
  final int versesCount;

  ActivityModel({
    this.activityId,
    required this.userId,
    required this.date,
    required this.versesCount,
  });

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      activityId: map['activity_id'] as int?,
      userId: map['user_id'] as int,
      date: map['date'] as String,
      versesCount: map['verses_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'user_id': userId,
      'date': date,
      'verses_count': versesCount,
    };
  }

  /// Heatmap level 0-4 based on activity
  int get heatmapLevel {
    if (versesCount == 0) return 0;
    if (versesCount <= 5) return 1;
    if (versesCount <= 10) return 2;
    if (versesCount <= 20) return 3;
    return 4;
  }
}
