/// Settings model for user preferences
class SettingsModel {
  final int? settingId;
  final int userId;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final bool circleNotifications;
  final bool achievementNotifications;
  final double quranFontSize;
  final double audioVolume;
  final bool readingMode;
  final String highlightColor;

  SettingsModel({
    this.settingId,
    required this.userId,
    this.language = 'ar',
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.circleNotifications = true,
    this.achievementNotifications = true,
    this.quranFontSize = 28.0,
    this.audioVolume = 0.7,
    this.readingMode = false,
    this.highlightColor = '#4CAF50',
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      settingId: map['setting_id'] as int?,
      userId: map['user_id'] as int,
      language: map['language'] as String? ?? 'ar',
      theme: map['theme'] as String? ?? 'light',
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
      dailyReminderEnabled: (map['daily_reminder_enabled'] as int? ?? 1) == 1,
      circleNotifications: (map['circle_notifications'] as int? ?? 1) == 1,
      achievementNotifications:
          (map['achievement_notifications'] as int? ?? 1) == 1,
      quranFontSize: (map['quran_font_size'] as num?)?.toDouble() ?? 28.0,
      audioVolume: (map['audio_volume'] as num?)?.toDouble() ?? 0.7,
      readingMode: (map['reading_mode'] as int? ?? 0) == 1,
      highlightColor: map['highlight_color'] as String? ?? '#4CAF50',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'setting_id': settingId,
      'user_id': userId,
      'language': language,
      'theme': theme,
      'notifications_enabled': notificationsEnabled ? 1 : 0,
      'daily_reminder_enabled': dailyReminderEnabled ? 1 : 0,
      'circle_notifications': circleNotifications ? 1 : 0,
      'achievement_notifications': achievementNotifications ? 1 : 0,
      'quran_font_size': quranFontSize,
      'audio_volume': audioVolume,
      'reading_mode': readingMode ? 1 : 0,
      'highlight_color': highlightColor,
    };
  }

  SettingsModel copyWith({
    int? settingId,
    int? userId,
    String? language,
    String? theme,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
    bool? circleNotifications,
    bool? achievementNotifications,
    double? quranFontSize,
    double? audioVolume,
    bool? readingMode,
    String? highlightColor,
  }) {
    return SettingsModel(
      settingId: settingId ?? this.settingId,
      userId: userId ?? this.userId,
      language: language ?? this.language,
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      circleNotifications: circleNotifications ?? this.circleNotifications,
      achievementNotifications:
          achievementNotifications ?? this.achievementNotifications,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      audioVolume: audioVolume ?? this.audioVolume,
      readingMode: readingMode ?? this.readingMode,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  static SettingsModel defaultSettings(int userId) {
    return SettingsModel(userId: userId);
  }
}
