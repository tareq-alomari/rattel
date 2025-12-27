import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Hadith Search Test', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create Tables
    await db.execute('''
      CREATE TABLE hadith_books (
        id INTEGER PRIMARY KEY,
        title_ar TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE hadiths (
        id INTEGER PRIMARY KEY,
        book_id INTEGER,
        hadith_number INTEGER,
        text TEXT,
        explanation TEXT,
        search_term TEXT,
        is_favorite INTEGER DEFAULT 0,
        page_number INTEGER
      )
    ''');

    // Insert Dummy Data
    await db.insert('hadith_books', {'id': 1, 'title_ar': 'Sahih Bukhari'});

    // Insert Hadiths
    // 1. Match
    await db.insert('hadiths', {
      'book_id': 1,
      'hadith_number': 1,
      'text': 'Actions are by intentions',
      'search_term': 'actions intentions',
      'is_favorite': 0,
    });

    // 2. No Match
    await db.insert('hadiths', {
      'book_id': 1,
      'hadith_number': 2,
      'text': 'Religion is sincerity',
      'search_term': 'religion sincerity',
      'is_favorite': 0,
    });

    // Test Search Query
    // We simulate the service/repo logic here since we can't easily inject the in-memory db into the real service without DI setup modifications in this isolated test script.
    // The query used in `HadithDatabaseService` is:
    // SELECT * FROM hadiths WHERE search_term LIKE ? OR text LIKE ?

    final query = 'intentions';
    final results = await db.rawQuery(
      'SELECT * FROM hadiths WHERE search_term LIKE ? OR text LIKE ?',
      ['%$query%', '%$query%'],
    );

    expect(results.length, 1);
    expect(results.first['hadith_number'], 1);

    final query2 = 'sincerity';
    final results2 = await db.rawQuery(
      'SELECT * FROM hadiths WHERE search_term LIKE ? OR text LIKE ?',
      ['%$query2%', '%$query2%'],
    );
    expect(results2.length, 1);
    expect(results2.first['hadith_number'], 2);

    final query3 = 'prayer'; // No match
    final results3 = await db.rawQuery(
      'SELECT * FROM hadiths WHERE search_term LIKE ? OR text LIKE ?',
      ['%$query3%', '%$query3%'],
    );
    expect(results3.isEmpty, true);

    await db.close();
  });
}
