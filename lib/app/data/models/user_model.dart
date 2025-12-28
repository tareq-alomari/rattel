/// User model for authentication
class UserModel {
  final int? userId;
  final String? firebaseId;
  final String name;
  final String email;
  final String password;
  final String role; // 'student' or 'teacher'
  final int points;
  final String? createdAt;

  UserModel({
    this.userId,
    this.firebaseId,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.points = 0,
    this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as int?,
      firebaseId: map['firebase_id'] as String?,
      name: map['name'] as String,
      email: map['email'] as String,
      password: map['password'] as String,
      role: map['role'] as String,
      points: map['points'] as int? ?? 0,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'firebase_id': firebaseId,
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'points': points,
      'created_at': createdAt,
    };
  }

  UserModel copyWith({
    int? userId,
    String? firebaseId,
    String? name,
    String? email,
    String? password,
    String? role,
    int? points,
    String? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      firebaseId: firebaseId ?? this.firebaseId,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isStudent => role == 'student';
  bool get isTeacher => role == 'teacher';
}
