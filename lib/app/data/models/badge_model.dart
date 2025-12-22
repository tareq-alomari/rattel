/// Badge model for gamification
class BadgeModel {
  final int? badgeId;
  final String badgeName;
  final String badgeNameEn;
  final String? description;
  final String? iconPath;
  final String? criteriaType;
  final int? criteriaValue;
  final String? earnedDate;

  BadgeModel({
    this.badgeId,
    required this.badgeName,
    required this.badgeNameEn,
    this.description,
    this.iconPath,
    this.criteriaType,
    this.criteriaValue,
    this.earnedDate,
  });

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      badgeId: map['badge_id'] as int?,
      badgeName: map['badge_name'] as String,
      badgeNameEn: map['badge_name_en'] as String,
      description: map['description'] as String?,
      iconPath: map['icon_path'] as String?,
      criteriaType: map['criteria_type'] as String?,
      criteriaValue: map['criteria_value'] as int?,
      earnedDate: map['earned_date'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'badge_id': badgeId,
      'badge_name': badgeName,
      'badge_name_en': badgeNameEn,
      'description': description,
      'icon_path': iconPath,
      'criteria_type': criteriaType,
      'criteria_value': criteriaValue,
    };
  }

  bool get isEarned => earnedDate != null;
}
