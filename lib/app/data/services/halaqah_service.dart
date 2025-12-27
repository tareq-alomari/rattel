import 'package:get/get.dart';
import '../models/halaqah_model.dart';
import '../providers/database_helper.dart';

class HalaqahService extends GetxService {
  static HalaqahService get to => Get.find();

  /// Create new Halaqah
  Future<int> createHalaqah(Halaqah halaqah) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('halaqat', halaqah.toMap());
  }

  /// Get all Halaqat for a teacher
  Future<List<Halaqah>> getTeacherHalaqat(int teacherId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'halaqat',
      where: 'teacher_id = ? AND status = ?',
      whereArgs: [teacherId, 'active'],
      orderBy: 'created_at DESC',
    );

    return results.map((map) => Halaqah.fromMap(map)).toList();
  }

  /// Get count of active Halaqat for a teacher
  Future<int> getTeacherHalaqahCount(int teacherId) async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM halaqat WHERE teacher_id = ? AND status = ?',
      [teacherId, 'active'],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  /// Get Halaqah by ID
  Future<Halaqah?> getHalaqah(int halaqahId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'halaqat',
      where: 'id = ?',
      whereArgs: [halaqahId],
    );

    if (results.isEmpty) return null;
    return Halaqah.fromMap(results.first);
  }

  /// Update Halaqah
  Future<int> updateHalaqah(Halaqah halaqah) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'halaqat',
      halaqah.toMap(),
      where: 'id = ?',
      whereArgs: [halaqah.id],
    );
  }

  /// Add student to Halaqah
  Future<int> addStudentToHalaqah(int halaqahId, int studentId) async {
    final db = await DatabaseHelper.instance.database;
    final student = HalaqahStudent(halaqahId: halaqahId, studentId: studentId);

    try {
      return await db.insert('halaqah_students', student.toMap());
    } catch (e) {
      Get.snackbar('خطأ', 'الطالب موجود بالفعل في الحلقة');
      return -1;
    }
  }

  /// Remove student from Halaqah
  Future<int> removeStudentFromHalaqah(int halaqahId, int studentId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.update(
      'halaqah_students',
      {'status': 'inactive'},
      where: 'halaqah_id = ? AND student_id = ?',
      whereArgs: [halaqahId, studentId],
    );
  }

  /// Get students in Halaqah
  Future<List<Map<String, dynamic>>> getHalaqahStudents(int halaqahId) async {
    final db = await DatabaseHelper.instance.database;
    return await db.rawQuery(
      '''
      SELECT u.*, hs.joined_at, hs.status as halaqah_status
      FROM users u
      INNER JOIN halaqah_students hs ON u.user_id = hs.student_id
      WHERE hs.halaqah_id = ? AND hs.status = 'active'
      ORDER BY u.name
    ''',
      [halaqahId],
    );
  }

  /// Create session
  Future<int> createSession(HalaqahSession session) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('halaqah_sessions', session.toMap());
  }

  /// Get Halaqah sessions
  Future<List<HalaqahSession>> getHalaqahSessions(int halaqahId) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'halaqah_sessions',
      where: 'halaqah_id = ?',
      whereArgs: [halaqahId],
      orderBy: 'date DESC',
      limit: 50,
    );

    return results.map((map) => HalaqahSession.fromMap(map)).toList();
  }

  /// Generate weekly report
  Future<HalaqahReport> generateWeeklyReport(int halaqahId) async {
    final halaqah = await getHalaqah(halaqahId);
    if (halaqah == null) {
      throw Exception('Halaqah not found');
    }

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    final sessions = await _getSessionsInRange(halaqahId, weekStart, weekEnd);

    final students = await getHalaqahStudents(halaqahId);
    final attendance = <int, int>{};
    final progress = <int, double>{};

    // Calculate attendance
    for (var student in students) {
      final studentId = student['user_id'] as int;
      int attendanceCount = 0;

      for (var session in sessions) {
        if (session.attendedStudentIds?.contains(studentId) ?? false) {
          attendanceCount++;
        }
      }

      attendance[studentId] = attendanceCount;
      progress[studentId] = sessions.isEmpty
          ? 0.0
          : (attendanceCount / sessions.length) * 100;
    }

    return HalaqahReport(
      halaqahId: halaqahId,
      halaqahName: halaqah.name,
      startDate: weekStart,
      endDate: weekEnd,
      totalSessions: sessions.length,
      totalStudents: students.length,
      studentAttendance: attendance,
      studentProgress: progress,
    );
  }

  Future<List<HalaqahSession>> _getSessionsInRange(
    int halaqahId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      'halaqah_sessions',
      where: 'halaqah_id = ? AND date >= ? AND date <= ?',
      whereArgs: [halaqahId, start.toIso8601String(), end.toIso8601String()],
    );

    return results.map((map) => HalaqahSession.fromMap(map)).toList();
  }

  /// Get upcoming sessions for a teacher
  Future<List<Map<String, dynamic>>> getTeacherUpcomingSessions(
    int teacherId,
  ) async {
    final db = await DatabaseHelper.instance.database;
    final now = DateTime.now().toIso8601String();

    // Join sessions with halaqat to filter by teacher and getting halaqah name
    return await db.rawQuery(
      '''
      SELECT hs.*, h.name as halaqah_name, 
             (SELECT COUNT(*) FROM halaqah_students WHERE halaqah_id = h.id AND status = 'active') as student_count
      FROM halaqah_sessions hs
      JOIN halaqat h ON hs.halaqah_id = h.id
      WHERE h.teacher_id = ? AND hs.date >= ?
      ORDER BY hs.date ASC
      LIMIT 5
    ''',
      [teacherId, now],
    );
  }
}
