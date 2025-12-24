import 'package:sqflite/sqflite.dart';
import '../providers/database_helper.dart';
import '../models/memorization_model.dart';
import '../models/evaluation_model.dart';
import '../models/user_model.dart';

/// Database service for all database operations
class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  DatabaseService._init();

  // ========== DATABASE ACCESS ==========

  /// Get database instance
  Future<Database> get database => DatabaseHelper.instance.database;

  // ========== USER & AUTHENTICATION OPERATIONS ==========

  /// Get user by ID
  Future<UserModel?> getUserById(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  /// Get user by username/email
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'email = ? OR name = ?',
      whereArgs: [username, username],
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  /// Create new user
  Future<int> createUser({
    required String username,
    required String password,
    required String fullName,
    required String role,
    String? email,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('users', {
      'name': fullName,
      'email': email ?? username,
      'password': password,
      'role': role,
      'points': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get all students
  Future<List<UserModel>> getAllStudents() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['student'],
    );

    return results.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Get student count
  Future<int> getStudentCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM users WHERE role = ?',
      ['student'],
    );
    return result.first['count'] as int;
  }

  // ========== STUDENT STATISTICS OPERATIONS ==========

  /// Get total verses memorized by user
  Future<int> getTotalVersesMemorized(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      '''
      SELECT SUM(to_verse - from_verse + 1) as count
      FROM memorization_logs
      WHERE user_id = ?
    ''',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get current memorization streak for user
  Future<int> getCurrentStreak(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final logs = await db.query(
      'memorization_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    if (logs.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (var log in logs) {
      final createdAt = DateTime.parse(log['created_at'] as String);
      final logDate = DateTime(createdAt.year, createdAt.month, createdAt.day);

      if (lastDate == null) {
        lastDate = logDate;
        streak = 1;
      } else {
        final difference = lastDate.difference(logDate).inDays;
        if (difference == 1) {
          streak++;
          lastDate = logDate;
        } else if (difference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  /// Get longest streak for user
  Future<int> getLongestStreak(int userId) async {
    // Simplified - return current streak for now
    return await getCurrentStreak(userId);
  }

  /// Get user badges count
  Future<int> getUserBadgesCount(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM user_badges WHERE user_id = ? AND earned_at IS NOT NULL',
      [userId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get recent memorization logs
  Future<List<MemorizationModel>> getRecentMemorizationLogs(
    int userId, {
    int limit = 10,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'memorization_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((map) => MemorizationModel.fromMap(map)).toList();
  }

  /// Get verses memorized today
  Future<int> getVersesMemorizedToday(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    final result = await db.rawQuery(
      '''
      SELECT SUM(to_verse - from_verse + 1) as count
      FROM memorization_logs
      WHERE user_id = ? AND created_at >= ?
    ''',
      [userId, startOfDay.toIso8601String()],
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Get verses memorized this week
  Future<int> getVersesMemorizedThisWeek(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final result = await db.rawQuery(
      '''
      SELECT SUM(to_verse - from_verse + 1) as count
      FROM memorization_logs
      WHERE user_id = ? AND created_at >= ?
    ''',
      [userId, startOfWeekDay.toIso8601String()],
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Get verses memorized this month
  Future<int> getVersesMemorizedThisMonth(int userId) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final result = await db.rawQuery(
      '''
      SELECT SUM(to_verse - from_verse + 1) as count
      FROM memorization_logs
      WHERE user_id = ? AND created_at >= ?
    ''',
      [userId, startOfMonth.toIso8601String()],
    );

    return result.first['count'] as int? ?? 0;
  }

  /// Check if user has recent activity
  Future<bool> hasRecentActivity(int userId, {int days = 7}) async {
    final db = await DatabaseHelper.instance.database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    final result = await db.rawQuery(
      '''
      SELECT COUNT(*) as count
      FROM memorization_logs
      WHERE user_id = ? AND created_at >= ?
    ''',
      [userId, cutoffDate.toIso8601String()],
    );

    return (result.first['count'] as int? ?? 0) > 0;
  }

  // ========== TEACHER & EVALUATION OPERATIONS ==========

  /// Get teacher evaluations
  Future<List<EvaluationModel>> getTeacherEvaluations(
    int teacherId, {
    int limit = 10,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'evaluations',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
      orderBy: 'created_at DESC',
      limit: limit,
    );

    return results.map((map) => EvaluationModel.fromMap(map)).toList();
  }

  /// Get teacher evaluations count
  Future<int> getTeacherEvaluationsCount(int teacherId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM evaluations WHERE teacher_id = ?',
      [teacherId],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get pending evaluations count
  Future<int> getPendingEvaluationsCount() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM evaluations WHERE status = ?',
      ['pending'],
    );
    return result.first['count'] as int? ?? 0;
  }

  /// Get average evaluation score
  Future<double> getAverageEvaluationScore(int teacherId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT AVG(score) as avg FROM evaluations WHERE teacher_id = ?',
      [teacherId],
    );
    return result.first['avg'] as double? ?? 0.0;
  }

  /// Get student evaluations
  Future<List<EvaluationModel>> getStudentEvaluations(int studentId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'evaluations',
      where: 'student_id = ?',
      whereArgs: [studentId],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => EvaluationModel.fromMap(map)).toList();
  }

  /// Create evaluation
  Future<int> createEvaluation({
    required int studentId,
    required int teacherId,
    required int surahNumber,
    required int fromVerse,
    required int toVerse,
    required int score,
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('evaluations', {
      'student_id': studentId,
      'teacher_id': teacherId,
      'surah_number': surahNumber,
      'from_verse': fromVerse,
      'to_verse': toVerse,
      'score': score,
      'notes': notes,
      'status': 'completed',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Update evaluation
  Future<bool> updateEvaluation({
    required int evaluationId,
    required int score,
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.update(
      'evaluations',
      {
        'score': score,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'evaluation_id = ?',
      whereArgs: [evaluationId],
    );
    return count > 0;
  }

  /// Delete evaluation
  Future<bool> deleteEvaluation(int evaluationId) async {
    final db = await DatabaseHelper.instance.database;
    final count = await db.delete(
      'evaluations',
      where: 'evaluation_id = ?',
      whereArgs: [evaluationId],
    );
    return count > 0;
  }

  /// Get recent system activity
  Future<List<Map<String, dynamic>>> getRecentSystemActivity() async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.rawQuery('''
      SELECT * FROM activity_logs
      ORDER BY created_at DESC
      LIMIT 20
    ''');
    return results;
  }

  // Note: All other existing methods from the original file should remain here
  // This is a simplified version showing only the new methods added
}
