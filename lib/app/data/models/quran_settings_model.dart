/// Quran reading settings model
class QuranSettings {
  final double arabicFontSize;
  final double translationFontSize;
  final bool showTranslation;
  final List<String> selectedLanguages;
  final bool showTransliteration;
  final String arabicFont;
  final String theme; // 'light', 'dark', 'sepia'

  QuranSettings({
    this.arabicFontSize = 24.0,
    this.translationFontSize = 16.0,
    this.showTranslation = true,
    this.selectedLanguages = const ['en'],
    this.showTransliteration = false,
    this.arabicFont = 'Amiri',
    this.theme = 'light',
  });

  factory QuranSettings.fromMap(Map<String, dynamic> map) {
    return QuranSettings(
      arabicFontSize: (map['arabic_font_size'] as num?)?.toDouble() ?? 24.0,
      translationFontSize:
          (map['translation_font_size'] as num?)?.toDouble() ?? 16.0,
      showTranslation: (map['show_translation'] as int?) == 1,
      selectedLanguages: map['selected_languages'] != null
          ? (map['selected_languages'] as String).split(',')
          : ['en'],
      showTransliteration: (map['show_transliteration'] as int?) == 1,
      arabicFont: map['arabic_font'] as String? ?? 'Amiri',
      theme: map['theme'] as String? ?? 'light',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'arabic_font_size': arabicFontSize,
      'translation_font_size': translationFontSize,
      'show_translation': showTranslation ? 1 : 0,
      'selected_languages': selectedLanguages.join(','),
      'show_transliteration': showTransliteration ? 1 : 0,
      'arabic_font': arabicFont,
      'theme': theme,
    };
  }

  QuranSettings copyWith({
    double? arabicFontSize,
    double? translationFontSize,
    bool? showTranslation,
    List<String>? selectedLanguages,
    bool? showTransliteration,
    String? arabicFont,
    String? theme,
  }) {
    return QuranSettings(
      arabicFontSize: arabicFontSize ?? this.arabicFontSize,
      translationFontSize: translationFontSize ?? this.translationFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      selectedLanguages: selectedLanguages ?? this.selectedLanguages,
      showTransliteration: showTransliteration ?? this.showTransliteration,
      arabicFont: arabicFont ?? this.arabicFont,
      theme: theme ?? this.theme,
    );
  }

  /// Get theme colors
  Map<String, dynamic> getThemeColors() {
    switch (theme) {
      case 'dark':
        return {
          'background': 0xFF1E1E1E,
          'surface': 0xFF2D2D2D,
          'text': 0xFFE0E0E0,
        };
      case 'sepia':
        return {
          'background': 0xFFF5E6D3,
          'surface': 0xFFFFFFFF,
          'text': 0xFF5C4033,
        };
      default: // light
        return {
          'background': 0xFFFAF8F5,
          'surface': 0xFFFFFFFF,
          'text': 0xFF000000,
        };
    }
  }
}
