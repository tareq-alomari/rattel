import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; // for rootBundle
import 'dart:convert'; // for json
import 'package:sqflite/sqflite.dart'; // for Sqflite
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
        await _seedAzkarIfEmpty(); // Separate check for Azkar
        await _seedAllahNamesIfEmpty(); // Separate check for Allah Names
        return;
      }

      await seedHadithData();
      await seedAzkarData();
      await seedAllahNamesData();

      debugPrint('🎉 Data seeding completed!');
    } catch (e) {
      debugPrint('❌ Error seeding data: $e');
      rethrow;
    }
  }

  Future<void> _seedAzkarIfEmpty() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM azkar'),
    );
    if (count == 0) {
      debugPrint('⚠️ Azkar table empty. Seeding now...');
      await seedAzkarData();
    }
  }

  Future<void> _seedAllahNamesIfEmpty() async {
    final db = await DatabaseHelper.instance.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM allah_names'),
    );
    if (count == 0) {
      debugPrint('⚠️ Allah Names table empty. Seeding now...');
      await seedAllahNamesData();
    }
  }

  /// Seed Allah Names data
  Future<void> seedAllahNamesData() async {
    try {
      debugPrint('📿 Seeding Allah Names data...');
      final db = await DatabaseHelper.instance.database;

      // Load JSON
      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/Quran-App-Data/names_of_allah.json',
        );
        final Map<String, dynamic> jsonData = json.decode(jsonString);
        final List<dynamic> namesList = jsonData['data'];

        final batch = db.batch();
        int index = 1;
        for (var item in namesList) {
          batch.insert('allah_names', {
            'number': index,
            'name': item['name'],
            'transliteration': '', // Missing in this JSON
            'en_meaning': '', // Missing in this JSON
            'found': '', // Missing in this JSON
          });
          index++;
        }
        await batch.commit(noResult: true);
        debugPrint('✅ Seeded ${namesList.length} Allah names.');
      } catch (e) {
        debugPrint('⚠️ Not finding asset or parse error: $e');
        // Simple fallback
        await db.insert('allah_names', {
          'number': 1,
          'name': 'الله',
          'transliteration': 'Allah',
          'en_meaning': 'The One True God',
          'found': '',
        });
      }
    } catch (e) {
      debugPrint('❌ Error seeding Allah names: $e');
    }
  }

  /// Seed Hadith data
  Future<void> seedHadithData() async {
    try {
      debugPrint('📚 Seeding Hadith data...');

      final db = await DatabaseHelper.instance.database;

      // Check if already seeded
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM hadith_books'),
      );
      if (count != null && count > 0) return;

      // Sample Hadith books (rest of the list...)
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
        // ... (truncated for brevity, ensure existing items are kept)
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

  /// Seed Azkar data from JSON
  Future<void> seedAzkarData() async {
    try {
      debugPrint('📿 Seeding Azkar data...');
      final db = await DatabaseHelper.instance.database;

      // Load JSON
      try {
        final jsonString = await rootBundle.loadString(
          'assets/data/Quran-App-Data/azkar.json',
        );
        final List<dynamic> azkarList = json.decode(jsonString);

        final batch = db.batch();
        for (var item in azkarList) {
          batch.insert('azkar', {
            'category': item['category'],
            'zekr': item['zekr'],
            'description': item['description'] ?? '',
            'reference': item['reference'] ?? '',
            'count': item['count']?.toString() ?? '1',
          });
        }
        await batch.commit(noResult: true);
        debugPrint('✅ Seeded ${azkarList.length} azkar.');
      } catch (e) {
        debugPrint('⚠️ Not finding asset or parse error: $e');
        // Fallback sample
        await db.insert('azkar', {
          'category': 'أذكار الصباح',
          'zekr': 'سبحان الله وبحمده',
          'count': '100',
          'description':
              'من قالها حين يصبح وحين يمسى مائة مرة لم يأت أحد يوم القيامة بأفضل مما جاء به إلا أحد قال مثل ما قال أو زاد عليه',
          'reference': 'مسلم',
        });
      }
    } catch (e) {
      debugPrint('❌ Error seeding Azkar: $e');
    }
  }
}
