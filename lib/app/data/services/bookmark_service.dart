import '../providers/database_helper.dart';

/// Service to manage bookmarks and resume position
class BookmarkService {
  static final BookmarkService instance = BookmarkService._init();
  BookmarkService._init();

  /// Add a bookmark for a user
  Future<int> addBookmark({
    required int userId,
    required int surahNumber,
    required int ayahNumber,
    String? note,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('bookmarks', {
      'user_id': userId,
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
      'note': note ?? '',
    });
    return id;
  }

  /// Remove bookmark by id
  Future<void> removeBookmark(int bookmarkId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'bookmarks',
      where: 'bookmark_id = ?',
      whereArgs: [bookmarkId],
    );
  }

  /// Get all bookmarks for a user
  Future<List<Map<String, dynamic>>> getBookmarks(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'bookmarks',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return results;
  }

  /// Set or update resume position for user
  Future<void> setResumePosition({
    required int userId,
    required int surahNumber,
    required int ayahNumber,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Use insert OR REPLACE to upsert
    await db.rawInsert(
      '''
      INSERT OR REPLACE INTO resume_position (user_id, surah_number, ayah_number, updated_at)
      VALUES (?, ?, ?, CURRENT_TIMESTAMP)
    ''',
      [userId, surahNumber, ayahNumber],
    );
  }

  /// Get resume position for user
  Future<Map<String, dynamic>?> getResumePosition(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'resume_position',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;
    return results.first;
  }

  /// Clear resume position for user
  Future<void> clearResumePosition(int userId) async {
    final db = await DatabaseHelper.instance.database;
    await db.delete(
      'resume_position',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }
}
