class Halaqah {
  final int? id;
  final String name;
  final int teacherId;
  final String
  schedule; // JSON string: {"days": ["Sun", "Tue"], "time": "16:00"}
  final String? description;
  final DateTime createdAt;
  final String status; // active, paused, archived

  Halaqah({
    this.id,
    required this.name,
    required this.teacherId,
    required this.schedule,
    this.description,
    DateTime? createdAt,
    this.status = 'active',
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'teacher_id': teacherId,
      'schedule': schedule,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  factory Halaqah.fromMap(Map<String, dynamic> map) {
    return Halaqah(
      id: map['id'],
      name: map['name'],
      teacherId: map['teacher_id'],
      schedule: map['schedule'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      status: map['status'] ?? 'active',
    );
  }
}

class HalaqahStudent {
  final int? id;
  final int halaqahId;
  final int studentId;
  final DateTime joinedAt;
  final String status; // active, inactive

  HalaqahStudent({
    this.id,
    required this.halaqahId,
    required this.studentId,
    DateTime? joinedAt,
    this.status = 'active',
  }) : joinedAt = joinedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'halaqah_id': halaqahId,
      'student_id': studentId,
      'joined_at': joinedAt.toIso8601String(),
      'status': status,
    };
  }

  factory HalaqahStudent.fromMap(Map<String, dynamic> map) {
    return HalaqahStudent(
      id: map['id'],
      halaqahId: map['halaqah_id'],
      studentId: map['student_id'],
      joinedAt: DateTime.parse(map['joined_at']),
      status: map['status'] ?? 'active',
    );
  }
}

class HalaqahSession {
  final int? id;
  final int halaqahId;
  final DateTime date;
  final String? notes;
  final String? topic; // e.g., "Surah Al-Baqarah 1-10"
  final List<int>? attendedStudentIds;

  HalaqahSession({
    this.id,
    required this.halaqahId,
    required this.date,
    this.notes,
    this.topic,
    this.attendedStudentIds,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'halaqah_id': halaqahId,
      'date': date.toIso8601String(),
      'notes': notes,
      'topic': topic,
      'attended_students': attendedStudentIds?.join(','),
    };
  }

  factory HalaqahSession.fromMap(Map<String, dynamic> map) {
    return HalaqahSession(
      id: map['id'],
      halaqahId: map['halaqah_id'],
      date: DateTime.parse(map['date']),
      notes: map['notes'],
      topic: map['topic'],
      attendedStudentIds: map['attended_students'] != null
          ? (map['attended_students'] as String)
                .split(',')
                .map((e) => int.parse(e))
                .toList()
          : null,
    );
  }
}

class HalaqahReport {
  final int halaqahId;
  final String halaqahName;
  final DateTime startDate;
  final DateTime endDate;
  final int totalSessions;
  final int totalStudents;
  final Map<int, int> studentAttendance; // studentId -> attendance count
  final Map<int, double> studentProgress; // studentId -> progress percentage

  HalaqahReport({
    required this.halaqahId,
    required this.halaqahName,
    required this.startDate,
    required this.endDate,
    required this.totalSessions,
    required this.totalStudents,
    required this.studentAttendance,
    required this.studentProgress,
  });
}
