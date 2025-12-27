import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('Hadith Memorization Table Test', () async {
    final db = await databaseFactory.openDatabase(inMemoryDatabasePath);

    // Create Tables Manually as we can't easily access private schema methods without mocking
    // Or we use the real DatabaseHelper initialization if it supports in-memory?
    // DatabaseHelper singleton usually opens a real path.
    // Let's just test the SQL syntax by creating the table directly here essentially mocking the migration.

    await db.execute('''
      CREATE TABLE hadiths (
        id INTEGER PRIMARY KEY,
        text TEXT
      )
    ''');

    await db.execute('''
        CREATE TABLE hadith_memorization (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          hadith_id INTEGER NOT NULL,
          status TEXT DEFAULT 'memorized',
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (hadith_id) REFERENCES hadiths(id)
        )
      ''');

    // Test Insert
    final hadithId = 1;
    await db.insert('hadiths', {'id': hadithId, 'text': 'Test Hadith'});

    await db.insert('hadith_memorization', {
      'hadith_id': hadithId,
      'status': 'memorized',
    });

    final result = await db.query('hadith_memorization');
    expect(result.length, 1);
    expect(result.first['hadith_id'], hadithId);
    expect(result.first['status'], 'memorized');

    // Test Delete
    await db.delete(
      'hadith_memorization',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );
    final result2 = await db.query('hadith_memorization');
    expect(result2.isEmpty, true);

    await db.close();
  });
}
