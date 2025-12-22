/// Settings model for user preferences
class SettingsModel {
  final int? settingId;
  final int userId;
  final String language;
  final String theme;
  final bool notificationsEnabled;
  final bool dailyReminderEnabled;
  final double quranFontSize;
  final bool readingMode;
  final String highlightColor;

  SettingsModel({
    this.settingId,
    required this.userId,
    this.language = 'ar',
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.dailyReminderEnabled = true,
    this.quranFontSize = 28.0,
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
      quranFontSize: (map['quran_font_size'] as num?)?.toDouble() ?? 28.0,
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
      'quran_font_size': quranFontSize,
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
    double? quranFontSize,
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
      quranFontSize: quranFontSize ?? this.quranFontSize,
      readingMode: readingMode ?? this.readingMode,
      highlightColor: highlightColor ?? this.highlightColor,
    );
  }

  static SettingsModel defaultSettings(int userId) {
    return SettingsModel(userId: userId);
  }
}
