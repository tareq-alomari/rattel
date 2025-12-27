import '../models/hadith.dart';
import '../models/hadith_book.dart';
import '../providers/database_helper.dart';

class HadithDatabaseService {
  Future<List<HadithBook>> getAllBooks() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query('hadith_books', orderBy: 'id ASC');
    return result.map((map) => HadithBook.fromMap(map)).toList();
  }

  Future<HadithBook?> getBookById(int id) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadith_books',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isNotEmpty) {
      return HadithBook.fromMap(result.first);
    }
    return null;
  }

  Future<List<Hadith>> getHadithsByBook(
    int bookId, {
    int limit = 20,
    int offset = 0,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadiths',
      where: 'book_id = ?',
      whereArgs: [bookId],
      orderBy: 'hadith_number ASC',
      limit: limit,
      offset: offset,
    );
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Future<Hadith?> getHadith(int bookId, int hadithNumber) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadiths',
      where: 'book_id = ? AND hadith_number = ?',
      whereArgs: [bookId, hadithNumber],
    );
    if (result.isNotEmpty) {
      return Hadith.fromMap(result.first);
    }
    return null;
  }

  Future<List<Hadith>> searchHadiths(String query, {int limit = 50}) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadiths',
      where: 'search_term LIKE ? OR text LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: limit,
    );
    return result.map((map) => Hadith.fromMap(map)).toList();
  }

  Future<void> updateHadithFavoriteStatus(int id, bool isFavorite) async {
    final db = await DatabaseHelper.instance.database;
    await db.update(
      'hadiths',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> toggleMemorization(int hadithId) async {
    final db = await DatabaseHelper.instance.database;
    final existing = await db.query(
      'hadith_memorization',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );

    if (existing.isNotEmpty) {
      await db.delete(
        'hadith_memorization',
        where: 'hadith_id = ?',
        whereArgs: [hadithId],
      );
    } else {
      await db.insert('hadith_memorization', {
        'hadith_id': hadithId,
        'status': 'memorized',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Helper to check status (if not embedded in Hadith object query via JOINs)
  Future<bool> isMemorized(int hadithId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadith_memorization',
      where: 'hadith_id = ?',
      whereArgs: [hadithId],
    );
    return result.isNotEmpty;
  }

  Future<Set<int>> getMemorizedHadithIds() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'hadith_memorization',
      columns: ['hadith_id'],
      where: "status = 'memorized'",
    );
    return result.map((row) => row['hadith_id'] as int).toSet();
  }
}
