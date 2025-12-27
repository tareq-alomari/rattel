import 'package:flutter/foundation.dart';
import '../providers/database_helper.dart';

/// Service to seed database with initial data
class DataSeederService {
  static final DataSeederService instance = DataSeederService._init();
  DataSeederService._init();

  /// Check if data has been seeded
  Future<bool> isDataSeeded() async {
    final db = await DatabaseHelper.instance.database;

    // Check if hadith_books table has data
    final hadithBooks = await db.query('hadith_books', limit: 1);

    return hadithBooks.isNotEmpty;
  }

  /// Seed all data
  Future<void> seedAllData() async {
    try {
      debugPrint('🌱 Starting data seeding...');

      final isSeeded = await isDataSeeded();
      if (isSeeded) {
        debugPrint('✅ Data already seeded, skipping...');
        return;
      }

      await seedHadithData();

      debugPrint('🎉 Data seeding completed!');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  /// Seed Hadith data
  Future<void> seedHadithData() async {
    try {
      debugPrint('📚 Seeding Hadith data...');

      final db = await DatabaseHelper.instance.database;

      // Sample Hadith books
      final books = [
        {
          'name': 'sahih_bukhari',
          'title_ar': 'صحيح البخاري',
          'author': 'الإمام البخاري',
          'hadith_count': 7563,
        },
        {
          'name': 'sahih_muslim',
          'title_ar': 'صحيح مسلم',
          'author': 'الإمام مسلم',
          'hadith_count': 7190,
        },
        {
          'name': 'sunan_abudawud',
          'title_ar': 'سنن أبي داود',
          'author': 'الإمام أبو داود',
          'hadith_count': 5274,
        },
        {
          'name': 'jami_tirmidhi',
          'title_ar': 'جامع الترمذي',
          'author': 'الإمام الترمذي',
          'hadith_count': 3956,
        },
        {
          'name': 'sunan_nasai',
          'title_ar': 'سنن النسائي',
          'author': 'الإمام النسائي',
          'hadith_count': 5758,
        },
        {
          'name': 'sunan_ibnmajah',
          'title_ar': 'سنن ابن ماجه',
          'author': 'الإمام ابن ماجه',
          'hadith_count': 4341,
        },
      ];

      // Insert books
      for (var book in books) {
        await db.insert('hadith_books', book);
      }

      // Sample Hadiths for each book
      final sampleHadiths = [
        {
          'book_id': 1,
          'hadith_number': 1,
          'text':
              'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ، وَإِنَّمَا لِكُلِّ امْرِئٍ مَا نَوَى',
          'explanation': 'الأعمال بحسب النيات، وكل شخص له ما نواه',
          'search_term': 'الأعمال بالنيات',
        },
        {
          'book_id': 1,
          'hadith_number': 2,
          'text':
              'بُنِيَ الإِسْلاَمُ عَلَى خَمْسٍ: شَهَادَةِ أَنْ لاَ إِلَهَ إِلاَّ اللَّهُ وَأَنَّ مُحَمَّدًا رَسُولُ اللَّهِ، وَإِقَامِ الصَّلاَةِ، وَإِيتَاءِ الزَّكَاةِ، وَالحَجِّ، وَصَوْمِ رَمَضَانَ',
          'explanation': 'أركان الإسلام الخمسة',
          'search_term': 'أركان الإسلام',
        },
        {
          'book_id': 2,
          'hadith_number': 1,
          'text': 'الطُّهُورُ شَطْرُ الإِيمَانِ',
          'explanation': 'الطهارة نصف الإيمان',
          'search_term': 'الطهور',
        },
        {
          'book_id': 2,
          'hadith_number': 2,
          'text': 'مَنْ غَشَّنَا فَلَيْسَ مِنَّا',
          'explanation': 'من غش المسلمين فليس منهم',
          'search_term': 'الغش',
        },
        {
          'book_id': 3,
          'hadith_number': 1,
          'text':
              'الْمُؤْمِنُ لِلْمُؤْمِنِ كَالْبُنْيَانِ يَشُدُّ بَعْضُهُ بَعْضًا',
          'explanation': 'المؤمنون كالبنيان المتماسك',
          'search_term': 'المؤمن للمؤمن',
        },
      ];

      for (var hadith in sampleHadiths) {
        await db.insert('hadiths', hadith);
      }

      debugPrint('✅ Hadith data seeded successfully');
    } catch (e) {
      debugPrint('❌ Error seeding Hadith data: $e');
      rethrow;
    }
  }
}
